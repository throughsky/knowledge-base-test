# 微服务治理规范 - AI编码约束

> 适用于：微服务架构、服务注册发现、远程调用、流量治理场景

## 一、服务注册发现规范 [MUST]

### 1.1 注册中心选型

```yaml
required: Nacos集群（≥3节点）
rules:
  - 服务名格式：业务线-服务名（如mall-order）
  - 命名空间：按环境隔离（dev/test/prod）
  - 分组：按业务线分组
  - 健康检查：心跳间隔5秒，超时15秒
```

### 1.2 服务配置

```yaml
# bootstrap.yml
spring:
  application:
    name: mall-order
  cloud:
    nacos:
      discovery:
        server-addr: nacos1:8848,nacos2:8849,nacos3:8850
        namespace: prod
        group: MALL_GROUP
        metadata:
          k8s-namespace: prod
          weight: 10
        heart-beat-interval: 5000
        heart-beat-timeout: 15000
```

### 1.3 健康检查

```yaml
rules:
  - 必须配置双探针（Nacos+K8s）
  - 存活探针：检测服务是否存活
  - 就绪探针：检测服务是否可接收流量
```

```yaml
# K8s Deployment
livenessProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8080
  initialDelaySeconds: 60
  periodSeconds: 10
readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 5
```

## 二、远程调用规范 [MUST]

### 2.1 Feign客户端规范

```yaml
rules:
  - 独立API模块（仅含Feign接口、DTO、枚举）
  - 必须配置FallbackFactory
  - 禁止写操作开启重试
  - 链路ID必须传递
```

```java
// ✅ 正确：API包独立
@FeignClient(
    name = "mall-order",
    fallbackFactory = OrderFeignFallbackFactory.class
)
public interface OrderFeignApi {
    @GetMapping("/api/v1/orders/{orderId}")
    Result<OrderDetailDTO> getOrderDetail(@PathVariable("orderId") Long orderId);

    @PostMapping("/api/v1/orders")
    Result<Long> createOrder(@RequestBody OrderCreateDTO request);
}

// ❌ 错误：无降级处理
@FeignClient(name = "mall-order")
public interface OrderFeignApi { }
```

### 2.2 超时与重试配置

```yaml
spring:
  cloud:
    openfeign:
      client:
        config:
          default:
            connect-timeout: 3000
            read-timeout: 5000
          mall-order:
            read-timeout: 8000
      retry:
        enabled: true
        max-attempts: 3
```

```java
// ✅ 正确：自定义重试策略（读操作重试，写操作不重试）
public class CustomFeignRetryer implements Retryer {
    @Override
    public void continueOrPropagate(RetryableException e) {
        boolean isWriteOp = e.request().httpMethod() == HttpMethod.POST
                || e.request().httpMethod() == HttpMethod.PUT;
        if (isWriteOp) {
            throw e;  // 写操作不重试
        }
        // 读操作可重试
    }
}
```

### 2.3 链路ID传递

```java
// ✅ 正确：Feign拦截器传递链路ID
@Component
public class FeignTraceInterceptor implements RequestInterceptor {
    @Override
    public void apply(RequestTemplate template) {
        String traceId = MDC.get("traceId");
        if (StringUtils.isNotBlank(traceId)) {
            template.header("X-Trace-Id", traceId);
        }
    }
}

// ✅ 正确：接收链路ID
@Component
public class TraceInterceptor implements HandlerInterceptor {
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        String traceId = request.getHeader("X-Trace-Id");
        if (StringUtils.isBlank(traceId)) {
            traceId = UUID.randomUUID().toString().replace("-", "");
        }
        MDC.put("traceId", traceId);
        return true;
    }

    @Override
    public void afterCompletion(...) {
        MDC.clear();  // 必须清除，避免线程复用混乱
    }
}
```

## 三、流量治理规范 [MUST]

### 3.1 Sentinel限流配置

```yaml
spring:
  cloud:
    sentinel:
      transport:
        dashboard: sentinel-dashboard:8080
      datasource:
        ds1:
          nacos:
            server-addr: ${spring.cloud.nacos.discovery.server-addr}
            data-id: mall-order-sentinel-rules
            group-id: SENTINEL_GROUP
            rule-type: flow
```

### 3.2 限流降级实现

```java
// ✅ 正确：限流+热点限流
@PostMapping
@SentinelResource(
    value = "mall-order:createOrder",
    blockHandler = "createOrderBlockHandler",
    fallback = "createOrderFallback"
)
public Result<Long> createOrder(@RequestBody OrderCreateDTO request) {
    return Result.success(orderService.createOrder(request));
}

// 限流处理
public Result<Long> createOrderBlockHandler(OrderCreateDTO request, BlockException e) {
    log.warn("下单限流/熔断，request:{}", request, e);
    return Result.fail(429, "下单人数过多，请稍后重试");
}

// 业务异常降级
public Result<Long> createOrderFallback(OrderCreateDTO request) {
    log.error("下单业务异常，request:{}", request);
    return Result.fail(500, "下单失败，请重试");
}
```

### 3.3 熔断降级工厂

```java
// ✅ 正确：FallbackFactory获取异常信息
@Component
public class OrderFeignFallbackFactory implements FallbackFactory<OrderFeignApi> {
    @Override
    public OrderFeignApi create(Throwable cause) {
        return new OrderFeignApi() {
            @Override
            public Result<OrderDetailDTO> getOrderDetail(Long orderId) {
                log.error("熔断：调用订单服务失败，orderId:{}, cause:{}", orderId, cause.getMessage());
                return Result.fail(503, "订单服务暂时不可用");
            }
        };
    }
}
```

## 四、容错与隔离规范 [MUST]

### 4.1 隔离策略选型

| 服务类型 | 隔离方式 | 核心配置 |
|----------|----------|----------|
| 核心服务（支付、订单） | 线程池隔离 | 核心线程10，最大线程20，队列50 |
| 非核心服务（日志、通知） | 信号量隔离 | 信号量100 |

### 4.2 Resilience4j配置

```yaml
resilience4j:
  bulkhead:
    instances:
      orderService:
        thread-pool:
          core-thread-pool-size: 10
          max-thread-pool-size: 20
          queue-capacity: 50
  circuitbreaker:
    instances:
      orderService:
        sliding-window-size: 10
        failure-rate-threshold: 50
        wait-duration-in-open-state: 5000
```

```java
// ✅ 正确：线程池隔离+熔断
@Bulkhead(name = "orderService", type = Bulkhead.Type.THREADPOOL, fallbackMethod = "fallback")
@CircuitBreaker(name = "orderService", fallbackMethod = "fallback")
public CompletableFuture<Result<Boolean>> updateOrderStatus(Long orderId, Integer status) {
    return CompletableFuture.supplyAsync(() -> orderFeignApi.updateOrderStatus(request));
}
```

## 五、分布式事务规范 [MUST]

### 5.1 场景化选型

| 业务场景 | 推荐方案 | 适用条件 |
|----------|----------|----------|
| 核心业务（支付下单） | Seata AT模式 | 数据库支持事务，需undo_log表 |
| 非核心业务（发通知） | 可靠消息最终一致性 | 消息队列支持事务消息 |
| 强一致性（转账） | TCC模式 | 需手写Try-Confirm-Cancel |

### 5.2 Seata AT模式

```java
// ✅ 正确：全局事务
@GlobalTransactional(rollbackFor = Exception.class, timeoutMills = 60000)
public Long createOrder(OrderCreateDTO request) {
    // 1. 创建订单（本地事务）
    orderMapper.insert(order);

    // 2. 远程调用扣库存（参与者）
    Result<Boolean> stockResult = stockFeignApi.decreaseStock(stockDTO);
    if (stockResult.getCode() != 200 || !stockResult.getData()) {
        throw new BusinessException("扣库存失败，事务回滚");
    }

    return order.getId();
}
```

## 六、配置管理规范 [MUST]

### 6.1 配置分层

```yaml
# bootstrap.yml
spring:
  cloud:
    nacos:
      config:
        ext-config[0]:
          data-id: mall-common.yml    # 通用配置
          group: MALL_GROUP
          refresh: true
        ext-config[1]:
          data-id: mall-order.yml     # 服务配置
          group: MALL_GROUP
          refresh: true
        ext-config[2]:
          data-id: mall-order-prod.yml  # 环境配置
          group: MALL_GROUP
          refresh: true
```

### 6.2 敏感配置加密

```yaml
# Nacos中配置
spring:
  datasource:
    username: ${encrypted:QWEasd123==}
    password: ${encrypted:ASDqwe456==}
```

### 6.3 动态刷新

```java
// ✅ 正确：@RefreshScope支持动态刷新
@RestController
@RefreshScope
public class OrderController {
    @Value("${order.timeout:30}")
    private Integer orderTimeout;
}
```

## 七、监控追踪规范 [MUST]

### 7.1 可观测性三件套

| 类型 | 工具 | 用途 |
|------|------|------|
| 指标监控 | Prometheus+Grafana | QPS、RT、错误率、JVM指标 |
| 日志监控 | ELK | 集中日志收集、按TraceID检索 |
| 链路追踪 | SkyWalking | 跨服务调用链路追踪 |

### 7.2 日志格式规范

```xml
<!-- logback-spring.xml -->
<pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{36} - traceId:%X{traceId} - %msg%n</pattern>
```

### 7.3 核心监控指标

```yaml
metrics:
  - 接口QPS
  - 接口RT（P99、P95、P50）
  - 接口错误率
  - JVM堆内存使用率
  - GC频率和耗时
  - 线程池活跃线程数
```

## 八、反模式检查清单

| 序号 | 反模式 | 检测方式 |
|------|--------|----------|
| 1 | Nacos单节点部署 | 检查server-addr配置 |
| 2 | Feign写操作开启重试 | 检查重试策略配置 |
| 3 | Sentinel规则未持久化 | 检查datasource配置 |
| 4 | Seata未创建undo_log表 | 检查数据库表结构 |
| 5 | 敏感配置明文存储 | 检查Nacos配置内容 |
| 6 | 链路ID未传递 | 检查Feign拦截器 |
| 7 | 核心服务未做线程池隔离 | 检查隔离策略 |
| 8 | 监控指标粒度太粗 | 检查Prometheus配置 |
| 9 | 无FallbackFactory | 检查FeignClient注解 |
| 10 | 无健康检查探针 | 检查K8s Deployment |
