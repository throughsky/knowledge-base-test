# 架构原则 (Architecture Principles)

**版本**: 2.0
**最后更新**: 2025-11-30
**负责人**: @架构委员会
**状态**: 已发布

---

## 概述

本文档定义了我们在构建所有软件系统时必须遵循的核心架构原则。这些原则是企业的**技术宪法**，旨在确保系统的一致性、可维护性和可扩展性。

<!-- AI-CONTEXT
本文档是L0层企业级强制规范，所有项目必须遵循。
AI在进行架构审查或代码生成时，应验证是否符合以下原则。
违规检测关键词：硬编码配置、有状态进程、跨边界直接调用
-->

---

## 原则一：12要素应用 (12-Factor App)

### 描述
严格遵循 [12-Factor](https://12factor.net/) 方法论，构建适应云原生环境的SaaS应用。

### 关键实践

| 要素 | 要求 | 检查点 |
|------|------|--------|
| **I. 基准代码** | 一份基准代码，多份部署 | 单一仓库，环境分支策略 |
| **II. 依赖** | 显式声明依赖 | package.json/build.gradle 完整 |
| **III. 配置** | 在环境中存储配置 | 无硬编码配置，使用环境变量 |
| **IV. 后端服务** | 把后端服务当作附加资源 | 可切换的服务连接 |
| **V. 构建、发布、运行** | 严格分离构建和运行 | CI/CD流水线隔离 |
| **VI. 进程** | 无状态进程 | 会话状态外部存储 |
| **VII. 端口绑定** | 通过端口绑定提供服务 | 自包含服务 |
| **VIII. 并发** | 通过进程模型扩展 | 水平扩展能力 |
| **IX. 可任意处置** | 快速启动和优雅关闭 | 健康检查、优雅终止 |
| **X. 开发/生产等价** | 保持环境一致性 | 容器化部署 |
| **XI. 日志** | 把日志当作事件流 | 结构化日志输出 |
| **XII. 管理进程** | 后台管理任务一次性运行 | 独立的管理脚本 |

### 示例

```yaml
# ✅ 正确: 通过环境变量配置
database:
  url: ${DATABASE_URL}
  username: ${DB_USERNAME}
  password: ${DB_PASSWORD}

# ❌ 错误: 硬编码配置
database:
  url: "jdbc:postgresql://localhost:5432/mydb"
  username: "admin"
  password: "secret123"
```

---

## 原则二：领域驱动设计 (Domain-Driven Design)

### 描述
以业务领域为核心，构建反映业务复杂性的软件模型。

### 关键实践

| 概念 | 定义 | 应用场景 |
|------|------|----------|
| **限界上下文** | 清晰划分不同业务领域的边界 | 微服务边界定义 |
| **通用语言** | 开发人员和业务专家使用相同术语 | 命名规范、文档 |
| **聚合根** | 保证领域对象的一致性 | 事务边界、数据一致性 |
| **领域事件** | 记录业务中发生的重要事件 | 服务间通信、审计 |

### 示例

```java
// 聚合根示例：Order是聚合根，所有订单操作必须通过Order进行
public class Order {
    private OrderId id;
    private List<OrderItem> items;  // 内部实体
    private OrderStatus status;

    // 业务行为通过聚合根暴露
    public void addItem(Product product, int quantity) {
        // 业务规则验证
        if (status != OrderStatus.DRAFT) {
            throw new OrderNotEditableException();
        }
        items.add(new OrderItem(product, quantity));
    }

    // 发布领域事件
    public OrderConfirmedEvent confirm() {
        this.status = OrderStatus.CONFIRMED;
        return new OrderConfirmedEvent(this.id, LocalDateTime.now());
    }
}
```

---

## 原则三：API 优先 (API-First)

### 描述
在编写任何实现代码之前，首先设计和约定 API 契约。

### 关键实践

1. **契约先行**: 使用 OpenAPI 3.0 定义 API
2. **设计评审**: API 设计需经过团队评审
3. **并行开发**: 使用 Mock Server 进行前后端并行开发
4. **契约测试**: 自动化验证实现与契约一致性

### 开发流程

```
OpenAPI Spec 设计
       ↓
  API 设计评审
       ↓
  Mock Server 启动
       ↓
前端开发 ←──并行──→ 后端开发
       ↓
  契约测试验证
       ↓
     集成
```

### 示例

```yaml
# openapi.yaml - API契约先于实现
openapi: 3.0.3
info:
  title: User Service API
  version: 1.0.0
paths:
  /users/{userId}:
    get:
      operationId: getUserById
      parameters:
        - name: userId
          in: path
          required: true
          schema:
            type: string
            format: uuid
      responses:
        '200':
          description: 用户信息
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '404':
          description: 用户不存在
```

---

## 原则四：可观测性设计 (Design for Observability)

### 描述
系统应天生具备从外部理解其内部状态的能力，而无需修改代码。

### 三大支柱

| 支柱 | 要求 | 工具选型 |
|------|------|----------|
| **日志 (Logging)** | 结构化 JSON 日志 | ELK / Loki |
| **指标 (Metrics)** | 业务和系统指标暴露 | Prometheus / OpenTelemetry |
| **追踪 (Tracing)** | 分布式追踪头传递 | Jaeger / Zipkin |

### 日志规范

```json
{
  "timestamp": "2025-11-30T10:15:30.123Z",
  "level": "INFO",
  "service": "order-service",
  "traceId": "abc123def456",
  "spanId": "789xyz",
  "userId": "user-001",
  "message": "Order created successfully",
  "orderId": "order-12345",
  "amount": 199.99
}
```

### 指标规范

```java
// 必须暴露的指标类型
@Component
public class OrderMetrics {

    // 计数器: 业务事件
    private final Counter ordersCreated = Counter.builder("orders_created_total")
        .description("Total orders created")
        .register(meterRegistry);

    // 直方图: 响应时间
    private final Timer orderProcessingTime = Timer.builder("order_processing_seconds")
        .description("Order processing duration")
        .register(meterRegistry);

    // 仪表盘: 当前状态
    private final Gauge pendingOrders = Gauge.builder("orders_pending", this,
        OrderMetrics::countPendingOrders)
        .description("Current pending orders")
        .register(meterRegistry);
}
```

---

## 原则五：安全内建 (Security by Design)

### 描述
安全不是事后添加的功能，而是从设计阶段就内建到系统中。

### 关键实践

| 领域 | 要求 |
|------|------|
| **认证** | OAuth 2.0 / OIDC 标准 |
| **授权** | RBAC/ABAC 模型，最小权限原则 |
| **数据保护** | 传输加密(TLS)、存储加密、脱敏 |
| **输入验证** | 所有输入必须验证，防注入 |
| **审计** | 关键操作记录审计日志 |

### 安全检查清单

- [ ] 所有API端点都有认证保护
- [ ] 敏感数据传输使用TLS 1.2+
- [ ] 密码使用bcrypt/argon2加密存储
- [ ] SQL查询使用参数化防注入
- [ ] 日志中不包含敏感信息
- [ ] 定期进行依赖漏洞扫描

---

## 合规检查

### AI辅助检查Prompt

```markdown
请检查以下代码/架构是否符合企业架构原则：

1. 12-Factor合规性:
   - 是否有硬编码配置？
   - 进程是否无状态？
   - 日志是否结构化输出？

2. DDD合规性:
   - 是否正确识别聚合根？
   - 是否有跨边界直接调用？

3. API-First合规性:
   - 是否有OpenAPI契约？
   - 实现是否与契约一致？

4. 可观测性合规性:
   - 是否有适当的日志/指标/追踪？

5. 安全合规性:
   - 是否有未保护的端点？
   - 是否有敏感信息泄露风险？
```

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| 2.0 | 2025-11-30 | 增加AI协作上下文、安全原则 | @架构委员会 |
| 1.0 | 2025-01-01 | 初始版本 | @架构委员会 |
