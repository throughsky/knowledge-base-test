# Java 编码规范

> 企业级编码基线，L1 项目级可细化

## 规范优先级

| 级别 | 标识 | 含义 | AI 行为 |
|------|------|------|--------|
| 🔴 强制 | `[MUST]` | 违反将导致严重问题 | 必须遵守，不可妥协 |
| 🟡 推荐 | `[SHOULD]` | 最佳实践 | 默认遵守，特殊情况可调整 |
| 🟢 建议 | `[MAY]` | 可选优化 | 视情况采用 |

---

## 一、命名规范 [MUST]

### 1.1 类/接口/枚举命名

```yaml
rules:
  format: UpperCamelCase（大驼峰）
  requirements:
    - 名词或名词短语
    - 体现"业务域+角色"
    - 禁止拼音/拼音英文混合
    - 禁止无意义缩写
```

| 类型 | 格式 | 正确示例 | 错误示例 |
|------|------|----------|----------|
| 普通类 | `XxxYyy` | `OrderService` | `orderservice` |
| 接口 | `XxxYyy` | `PaymentGateway` | `IPayment` |
| 实现类 | `XxxYyyImpl` | `OrderServiceImpl` | `OrderServiceImp` |
| 抽象类 | `AbstractXxx` | `AbstractValidator` | `BaseValidator` |
| 枚举 | `XxxEnum` | `OrderStatusEnum` | `OrderStatus` |
| 异常 | `XxxException` | `OrderNotFoundException` | `OrderError` |
| DTO | `XxxDTO` | `UserDTO` | `UserDto` |
| VO | `XxxVO` | `OrderVO` | `OrderVo` |
| DO/Entity | `XxxDO`/`Xxx` | `OrderDO` | `TOrder` |

### 1.2 方法命名

```yaml
rules:
  format: lowerCamelCase（小驼峰）
  structure: 动词 + 名词
  requirements:
    - 动词开头
    - 明确语义
    - 禁止数字后缀（get1, get2）
```

| 动词前缀 | 适用场景 | 示例 |
|----------|----------|------|
| `get` | 简单查询（单条） | `getUserById(Long userId)` |
| `query` | 复杂查询（多条件/分页） | `queryOrdersByCondition(OrderQuery query)` |
| `find` | 查找（可能返回 null/集合） | `findActiveUsers()` |
| `list` | 返回集合 | `listOrdersByUserId(Long userId)` |
| `create` | 新建（无 ID） | `createOrder(OrderDTO dto)` |
| `save` | 保存（有 ID 更新，无 ID 新增） | `saveUser(UserDTO dto)` |
| `update` | 更新指定字段 | `updateOrderStatus(Long id, Integer status)` |
| `delete`/`remove` | 删除 | `deleteById(Long id)` |
| `validate` | 校验 | `validateParams(Request req)` |
| `calculate` | 计算 | `calculateTotalAmount(List<Item> items)` |
| `convert`/`to` | 转换 | `convertToDTO(Entity entity)` |
| `is`/`has`/`can` | 布尔判断 | `isValid()`, `hasPermission()` |

### 1.3 变量命名

```java
// ❌ 错误
int a = 100;
String str = "test";
List list = new ArrayList();
User u = getUser();

// ✅ 正确
int maxRetryCount = 100;
String userName = "test";
List<Order> orderList = new ArrayList<>();
User currentUser = getUser();
```

### 1.4 常量命名

```java
// ✅ 正确
public static final int MAX_RETRY_COUNT = 3;
public static final String DEFAULT_CHARSET = "UTF-8";
public static final long CACHE_EXPIRE_SECONDS = 3600L;

// ❌ 错误
public static int maxRetry = 3;  // 缺少 final
public static final int MAX = 3;  // 语义不完整
```

### 1.5 包命名

```
✅ 正确结构：
com.company.mall.order.service
com.company.mall.order.controller
com.company.mall.order.mapper
com.company.mall.order.dto

❌ 错误结构：
com.company.Mall.order  // 大写
com.company.mall_order  // 下划线
```

---

## 二、注释规范 [MUST]

### 2.1 类/接口注释

```java
/**
 * 订单服务实现类
 * <p>
 * 处理订单创建、查询、状态变更等核心业务逻辑
 * 依赖：UserService、ProductService、PaymentService
 * </p>
 *
 * @author zhangsan
 * @since 2024-01-01
 * @see OrderMapper
 */
@Service
public class OrderServiceImpl implements OrderService {
    // ...
}
```

### 2.2 方法注释

```java
/**
 * 创建订单
 * <p>
 * 业务流程：参数校验 → 库存检查 → 创建订单 → 扣减库存 → 发送消息
 * </p>
 *
 * @param request 订单创建请求，包含用户 ID、商品列表、收货地址
 * @return 创建成功的订单 ID
 * @throws IllegalArgumentException 参数校验失败
 * @throws InsufficientStockException 库存不足
 * @throws OrderCreateException 订单创建失败
 */
public Long createOrder(OrderCreateRequest request) {
    // ...
}
```

### 2.3 代码块注释

```java
// ✅ 正确：说明业务原因
// 订单超过 30 天未支付，自动关闭（业务规则：防止库存长期占用）
if (order.getCreateTime().plusDays(30).isBefore(LocalDateTime.now())) {
    closeOrder(order);
}

// ❌ 错误：重复代码逻辑
// 如果创建时间加 30 天在当前时间之前
if (order.getCreateTime().plusDays(30).isBefore(LocalDateTime.now())) {
    closeOrder(order);
}
```

### 2.4 注释禁止项

```yaml
prohibited:
  - 注释掉的代码块（删除而非注释）
  - 过时的注释（代码改了注释没改）
  - 无意义的注释（如：// 获取用户）
  - TODO 后无责任人和时间
```

```java
// ❌ 禁止
// User user = userService.getById(id);  // 注释掉的代码
// TODO: 待优化  // 无责任人

// ✅ 正确
// TODO(zhangsan): 2024-02-01 优化 N+1 查询问题
```

---

## 三、语法避坑规范 [MUST]

### 3.1 集合使用

```java
// ✅ 正确：指定容量和泛型
List<User> userList = new ArrayList<>(100);
Map<Long, Order> orderMap = new HashMap<>(16);
Set<String> tagSet = new HashSet<>(8);

// ✅ 正确：遍历删除
Iterator<User> iterator = userList.iterator();
while (iterator.hasNext()) {
    if (iterator.next().isInvalid()) {
        iterator.remove();
    }
}

// ✅ 正确：多线程场景
Map<Long, User> concurrentMap = new ConcurrentHashMap<>();
List<String> threadSafeList = new CopyOnWriteArrayList<>();

// ❌ 错误
List list = new ArrayList();  // 无泛型
Map map = new HashMap();  // 无容量无泛型
for (User user : userList) {  // 遍历中删除
    if (user.isInvalid()) userList.remove(user);
}
```

### 3.2 异常处理

```java
// ✅ 正确
try {
    orderService.createOrder(request);
} catch (InsufficientStockException e) {
    log.warn("库存不足, productId={}, required={}",
             e.getProductId(), e.getRequiredQuantity());
    throw new BusinessException("库存不足，请稍后重试");
} catch (Exception e) {
    log.error("创建订单失败, userId={}, request={}",
              userId, JSON.toJSONString(request), e);
    throw new SystemException("系统繁忙，请稍后重试");
}

// ❌ 错误：吞异常
try {
    orderService.createOrder(request);
} catch (Exception e) {
    // 吞异常
}

// ❌ 错误：使用 e.printStackTrace()
try {
    orderService.createOrder(request);
} catch (Exception e) {
    e.printStackTrace();  // 禁止
}
```

### 3.3 空值处理

```java
// ✅ 正确：Optional
public String getUserName(Long userId) {
    return Optional.ofNullable(userMapper.selectById(userId))
            .map(User::getName)
            .orElse("未知用户");
}

// ✅ 正确：返回空集合
public List<Order> getOrders(Long userId) {
    List<Order> orders = orderMapper.selectByUserId(userId);
    return orders != null ? orders : Collections.emptyList();
}

// ✅ 正确：字符串判空
if (StringUtils.isNotBlank(userName)) {
    // ...
}

// ❌ 错误：多层判空
if (user != null && user.getAddress() != null
    && user.getAddress().getCity() != null) {
    // ...
}
```

### 3.4 字符串拼接

```java
// ✅ 正确
StringBuilder sb = new StringBuilder();
for (String item : items) {
    sb.append(item).append(",");
}

String message = String.format("用户%s创建订单%d成功", userName, orderId);

// ❌ 错误
String result = "";
for (String item : items) {
    result += item + ",";  // 性能差
}
```

### 3.5 equals 比较

```java
// ✅ 正确
if ("ACTIVE".equals(status)) { }
if (Objects.equals(status, targetStatus)) { }

// ❌ 错误（可能 NPE）
if (status.equals("ACTIVE")) { }
```

---

## 四、参数校验规范 [MUST]

### 4.1 JSR303 注解

```java
@Data
public class OrderCreateRequest {

    @NotNull(message = "用户 ID 不能为空")
    private Long userId;

    @NotEmpty(message = "商品列表不能为空")
    @Size(min = 1, max = 100, message = "商品数量 1-100 件")
    private List<OrderItemDTO> items;

    @NotNull(message = "订单金额不能为空")
    @DecimalMin(value = "0.01", message = "订单金额必须大于 0")
    private BigDecimal amount;

    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
    private String phone;

    @Email(message = "邮箱格式不正确")
    private String email;
}
```

### 4.2 Controller 层启用校验

```java
@PostMapping("/orders")
public Result<Long> createOrder(@Valid @RequestBody OrderCreateRequest request) {
    return Result.success(orderService.createOrder(request));
}
```

---

## 五、线程池规范 [MUST]

### 5.1 禁止使用 Executors

```yaml
prohibited:
  - Executors.newFixedThreadPool()    # 无界队列，OOM 风险
  - Executors.newCachedThreadPool()   # 无限线程，资源耗尽
  - Executors.newSingleThreadExecutor()
  - Executors.newScheduledThreadPool()
required: 手动创建 ThreadPoolExecutor
```

### 5.2 线程池配置

| 参数 | IO 密集型 | CPU 密集型 |
|------|----------|-----------|
| 核心线程数 | CPU 核数×2 | CPU 核数+1 |
| 最大线程数 | CPU 核数×4 | CPU 核数+1 |
| 队列容量 | 有界队列 1000 | 有界队列 500 |
| 空闲时间 | 60 秒 | 10 秒 |
| 拒绝策略 | CallerRunsPolicy | AbortPolicy |

```java
@Configuration
public class ThreadPoolConfig {
    private static final int CPU_CORES = Runtime.getRuntime().availableProcessors();

    @Bean(name = "ioIntensiveThreadPool")
    public ExecutorService ioIntensiveThreadPool() {
        ThreadFactory threadFactory = new ThreadFactoryBuilder()
                .setNameFormat("io-thread-%d")
                .setDaemon(true)
                .build();
        return new ThreadPoolExecutor(
            CPU_CORES * 2,
            CPU_CORES * 4,
            60, TimeUnit.SECONDS,
            new ArrayBlockingQueue<>(1000),
            threadFactory,
            new ThreadPoolExecutor.CallerRunsPolicy()
        );
    }
}
```

---

## 六、锁机制规范 [MUST]

### 6.1 锁选型

| 锁类型 | 适用场景 | 优点 | 缺点 |
|--------|----------|------|------|
| synchronized | 简单同步 | 用法简单、JVM 优化好 | 锁粒度粗、无法中断 |
| ReentrantLock | 复杂同步 | 支持超时、中断、公平锁 | 需手动释放 |
| ReadWriteLock | 读多写少 | 读操作共享 | 实现复杂 |

### 6.2 ReentrantLock 使用

```java
private final ReentrantLock lock = new ReentrantLock();

public Long createOrder(OrderCreateRequest request) {
    boolean locked = false;
    try {
        locked = lock.tryLock(3, TimeUnit.SECONDS);
        if (locked) {
            return doCreate(request);
        } else {
            throw new ServiceException("创建订单过于频繁");
        }
    } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
        throw new ServiceException("操作被中断");
    } finally {
        if (locked) {
            lock.unlock();  // 必须手动释放
        }
    }
}
```

---

## 七、ThreadLocal 规范 [MUST]

```java
// ✅ 正确：使用后清理
private static final ThreadLocal<User> USER_HOLDER = new ThreadLocal<>();

@Override
public boolean preHandle(HttpServletRequest request, ...) {
    USER_HOLDER.set(getCurrentUser());
    return true;
}

@Override
public void afterCompletion(HttpServletRequest request, ...) {
    USER_HOLDER.remove();  // 必须清理
}

// ❌ 错误：未清理 ThreadLocal
public void process() {
    USER_HOLDER.set(user);
    // 未调用 remove()，线程复用时数据混乱
}
```

---

## 八、日期时间规范 [MUST]

```java
// ❌ 错误：SimpleDateFormat 非线程安全
private static final SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

// ✅ 正确：使用 DateTimeFormatter
private static final DateTimeFormatter formatter =
    DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

public String formatDate(LocalDateTime dateTime) {
    return formatter.format(dateTime);
}
```

---

## 九、数据库交互规范 [MUST]

### 9.1 连接池选型

```yaml
required: HikariCP
prohibited:
  - C3P0（性能差，已过时）
  - DBCP（性能差）
```

### 9.2 HikariCP 配置

```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 20
      minimum-idle: 10
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
      leak-detection-threshold: 5000
      connection-test-query: SELECT 1
```

### 9.3 资源释放

```java
// ✅ 正确：try-with-resources
try (Connection conn = dataSource.getConnection();
     PreparedStatement ps = conn.prepareStatement(sql);
     ResultSet rs = ps.executeQuery()) {
    while (rs.next()) {
        // 处理结果
    }
}
```

### 9.4 MyBatis ResultMap

```xml
<!-- ✅ 正确：ResultMap -->
<resultMap id="OrderResultMap" type="com.example.entity.Order">
    <id column="id" property="id"/>
    <result column="order_no" property="orderNo"/>
    <result column="user_id" property="userId"/>
</resultMap>

<!-- ❌ 错误：resultType="map" -->
<select id="selectById" resultType="map">
    SELECT * FROM order_info WHERE id = #{id}
</select>
```

### 9.5 批量操作

```java
// ✅ 正确：分批处理
public void batchInsertOrders(List<Order> orders) {
    int batchSize = 500;
    for (int i = 0; i < orders.size(); i += batchSize) {
        List<Order> batch = orders.subList(i, Math.min(i + batchSize, orders.size()));
        orderMapper.batchInsert(batch);
    }
}
```

---

## 十、缓存规范 [MUST]

### 10.1 选型矩阵

| 场景 | 缓存类型 | 工具选型 | 适用条件 |
|------|----------|----------|----------|
| 低并发静态数据 | 本地缓存 | Caffeine | QPS≤1000 |
| 高并发共享数据 | 分布式缓存 | Redis | QPS≥1000 |
| 超高并发热点 | 多级缓存 | 本地+Redis | QPS≥10000 |

### 10.2 Redis Key 命名

```yaml
format: 业务域:模块:资源:唯一标识
separator: 冒号(:)
```

```java
// ✅ 正确命名
String userKey = "mall:user:info:" + userId;
String orderKey = "mall:order:detail:" + orderId;
String lockKey = "mall:lock:order:" + orderId;

// ❌ 错误命名
String key1 = "user_" + userId;           // 分隔符不规范
String key2 = "USER:" + userId;           // 大写
```

### 10.3 过期时间

```java
// ✅ 正确：设置过期时间
redisTemplate.opsForValue().set(key, value, 30, TimeUnit.MINUTES);

// ❌ 错误：不设过期时间
redisTemplate.opsForValue().set(key, value);  // 永不过期
```

### 10.4 分布式锁

```java
// ✅ 正确：使用 Redisson
public void processOrder(Long orderId) {
    String lockKey = "lock:order:" + orderId;
    RLock lock = redissonClient.getLock(lockKey);

    try {
        if (lock.tryLock(3, 10, TimeUnit.SECONDS)) {
            doProcess(orderId);
        } else {
            throw new BusinessException("系统繁忙，请稍后重试");
        }
    } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
        throw new BusinessException("操作被中断");
    } finally {
        if (lock.isHeldByCurrentThread()) {
            lock.unlock();
        }
    }
}
```

---

## 十一、反模式检查清单

| 序号 | 反模式 | 检测方式 |
|------|--------|----------|
| 1 | 类名用小驼峰 | 检查 class 声明 |
| 2 | 变量用单字母/拼音 | 检查变量名 |
| 3 | 常量未加 final | 检查 static 变量 |
| 4 | 集合不指定容量和泛型 | 检查 new ArrayList/HashMap |
| 5 | 吞异常或 e.printStackTrace() | 检查 catch 块 |
| 6 | 字符串用 == 比较 | 检查 String 比较 |
| 7 | 循环中用 + 拼接字符串 | 检查 for 循环内的字符串操作 |
| 8 | 多层 if 判空 | 检查嵌套 null 判断 |
| 9 | 使用 Executors 创建线程池 | 检查 newFixedThreadPool 等 |
| 10 | ThreadLocal 未 remove | 检查 afterCompletion/finally |
| 11 | 使用 SimpleDateFormat | 检查日期格式化方式 |
| 12 | 缓存无过期时间 | 检查 set 方法是否有 expire 参数 |
