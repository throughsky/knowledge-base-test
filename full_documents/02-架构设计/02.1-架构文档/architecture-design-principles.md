---
title: 架构设计原则
created: 2024-01-01
updated: 2024-11-30
version: 2.0
status: 已发布
tags: [架构设计, 设计原则, 项目规范, Spring Boot, 代码规范]
---

# 架构设计原则

> 团队架构设计的核心原则和决策指南
> 基于 @rules/ 目录规范的关键要求总结

## 0. 关键规范总览

### 0.1 项目结构规范（强制要求）

**包命名规则**：
- 根包名格式：`com.{company}.{project}`
- 示例：`com.example.appname`
- 必须提供有意义的group名和项目名

**强制目录结构**：
```
src/
├── main/java/com/company/app/
│   ├── {AppName}Application.java      # 主入口类（首字母大写）
│   ├── config/                        # 配置类目录
│   ├── controller/                    # REST控制器目录
│   ├── service/                       # 业务逻辑服务目录
│   │   └── impl/                      # 服务实现类目录
│   ├── entity/                        # 实体类目录（对应数据库表结构）
│   ├── mapper/                        # Mapper接口目录（MyBatis）
│   ├── dto/                           # 数据传输对象目录
│   ├── enums/                         # 枚举类目录（必须以Enum.java结尾）
│   ├── constants/                     # 常量类目录（错误码必须用枚举）
│   ├── vo/                            # 视图对象目录
│   │   ├── request/                   # 请求对象目录
│   │   │   ├── CommonRequest.java     # 通用请求基类（必须）
│   │   │   ├── CommonPageRequest.java # 分页请求基类（必须）
│   │   │   └── {Feature}Request.java  # 具体请求对象
│   │   └── response/                  # 响应对象目录
│   │       ├── CommonResponse.java    # 通用响应基类（必须）
│   │       ├── PageData.java          # 分页数据封装（必须）
│   │       └── {Feature}Response.java # 具体响应对象
│   ├── exception/                     # 自定义异常目录
│   ├── task/                          # 定时任务目录（按需）
│   ├── util/                          # 工具类目录
│   └── security/                      # 安全相关类目录（按需）
└── test/java/com/company/app/         # 测试目录（必须与main对应）
    ├── controller/                    # 控制器测试目录
    ├── service/                       # 服务测试目录
    └── mapper/                        # Mapper测试目录
```

**构建工具要求**：
- **必须使用Gradle**（禁止Maven）
- 必需文件：`build.gradle`、`settings.gradle`
- 版本要求：Gradle ≥ 8.14

### 0.2 技术栈规范（强制要求）

**核心框架**：
- Spring Boot（应用启动、自动装配、生产级特性）
- Spring Framework（依赖注入、AOP、事务、Web MVC）
- Spring Security（认证、授权、过滤链、方法级安全）

**数据访问**：
- MyBatis/MyBatis-Spring（半自动化SQL映射，注解模式）
- MySQL + mysql-connector-j
- 数据库设计规范：参考 `@rules/02-design/database.mdc`

**API与文档**：
- Spring MVC（RESTful API、请求映射、拦截器、参数校验）
- Springdoc OpenAPI（OpenAPI 3文档生成、Swagger UI）
- Jakarta Validation（Bean参数校验：@Valid、@NotNull等）

**其他组件**：
- Jackson（JSON序列化/反序列化、时间格式、忽略策略）
- Spring Cache（方法级缓存）
- SLF4J + Logback（日志）
- Spring Boot Actuator（健康检查、指标）

**测试框架**：
- JUnit 5（单元测试标准框架）
- Mockito（Mock依赖、交互验证）
- Spring Boot Test/MockMvc（集成测试、Web层测试）

### 0.3 设计模式规范（L2层级）

**创建型模式**：
- **Builder模式**：复杂对象构建（配置对象、请求对象）
- **Factory模式**：对象创建管理（Service工厂、Validator工厂）
- **Singleton模式**：资源管理（配置管理、缓存管理）

**结构型模式**：
- **Adapter模式**：接口适配（第三方服务适配、数据格式转换）
- **Decorator模式**：功能增强（AOP切面、日志增强、缓存增强）
- **Facade模式**：简化接口（复杂子系统封装、API网关）

**行为型模式**：
- **Strategy模式**：算法选择（支付方式、验证策略）
- **Observer模式**：事件通知（用户注册、订单状态变更）
- **Chain of Responsibility模式**：责任链处理（权限验证、数据校验）

### 0.4 编码规范要求

**命名规范**：
- 包名：全小写，点分隔（com.example.project）
- 类名：UpperCamelCase（UserService）
- 方法名：lowerCamelCase（getUserById）
- 常量：全大写，下划线分隔（MAX_PAGE_SIZE）

**代码风格**：
- 使用Lombok简化POJO
- 每个方法必须有Javadoc注释
- 复杂业务逻辑必须添加行内注释
- 禁止使用魔法值，必须定义常量

**测试要求**：
- 测试类名：被测试类名 + Test（UserServiceTest）
- 测试方法名：should_预期行为_when_条件
- 必须覆盖核心业务逻辑
- 集成测试使用@Testcontainers

## 1. 架构设计目标

### 1.1 核心目标
- **高可用性**: 系统可用性 ≥ 99.9%
- **高性能**: API 响应时间 < 200ms
- **可扩展性**: 支持水平扩展，应对业务增长
- **可维护性**: 代码清晰，文档完善
- **安全性**: 符合安全最佳实践

### 1.2 设计权衡

```
性能 ←────→ 可维护性
   ↓            ↓
开发速度   系统复杂度
```

| 优先级 | 考虑因素 | 权衡策略 |
|--------|----------|----------|
| P0 | 核心业务可靠性 | 牺牲部分性能保证可靠性 |
| P1 | 开发效率 | 优先选择团队熟悉的技术 |
| P2 | 性能优化 | 在保证可维护性前提下优化 |

## 2. 核心原则

### 2.1 SOLID 原则应用

#### S - 单一职责原则 (Single Responsibility)
每个模块/类只负责一个功能，只有一个改变的理由。

```typescript
// ❌ 违反 SRP
class UserService {
  async createUser() { /* ... */ }
  async sendEmail() { /* ... */ }  // 不同职责
  async logActivity() { /* ... */ } // 不同职责
}

// ✅ 遵循 SRP
class UserService {
  async createUser() { /* ... */ }
}

class EmailService {
  async sendEmail() { /* ... */ }
}

class ActivityLogService {
  async logActivity() { /* ... */ }
}
```

#### O - 开闭原则 (Open/Closed)
对扩展开放，对修改关闭。通过抽象和多态实现。

```typescript
// ✅ 遵循 OCP
interface PaymentMethod {
  pay(amount: number): Promise<void>;
}

class Alipay implements PaymentMethod {
  async pay(amount: number) { /* ... */ }
}

class WechatPay implements PaymentMethod {
  async pay(amount: number) { /* ... */ }
}

// 新增支付方式，无需修改现有代码
class BankCard implements PaymentMethod {
  async pay(amount: number) { /* ... */ }
}
```

#### L - 里氏替换原则 (Liskov Substitution)
子类必须能够替换其父类而不破坏程序的正确性。

```typescript
// ✅ 遵循 LSP
class Bird {
  fly(): void { /* ... */ }
}

class Sparrow extends Bird {
  fly(): void { /* 实现飞行 */ }
}

// 企鹅不会飞，不应该继承 Bird
class Penguin { // 不继承 Bird
  swim(): void { /* ... */ }
}
```

#### I - 接口隔离原则 (Interface Segregation)
客户端不应该依赖它不需要的接口。

```typescript
// ❌ 接口过大
interface Worker {
  work(): void;
  eat(): void;
  sleep(): void;
  attendMeeting(): void;
}

// ✅ 接口分离
interface Workable {
  work(): void;
}

interface Eatable {
  eat(): void;
}

interface MeetingParticipant {
  attendMeeting(): void;
}

class Developer implements Workable, MeetingParticipant {
  work() { /* ... */ }
  attendMeeting() { /* ... */ }
}
```

#### D - 依赖倒置原则 (Dependency Inversion)
高层模块不应该依赖低层模块，两者都应该依赖抽象。

```typescript
// ❌ 高层依赖具体实现
class NotificationService {
  private emailSender = new EmailSender(); // 直接依赖

  async notify(user: User, message: string) {
    await this.emailSender.send(user.email, message);
  }
}

// ✅ 依赖抽象
interface MessageSender {
  send(to: string, message: string): Promise<void>;
}

class NotificationService {
  constructor(private sender: MessageSender) {} // 依赖注入

  async notify(user: User, message: string) {
    await this.sender.send(user.email, message);
  }
}
```

### 2.2 DRY 原则 (Don't Repeat Yourself)

避免重复代码，提取公共逻辑。

```typescript
// ❌ 重复代码
function validateUser(user: User) {
  if (!user.email) throw new Error('Email required');
  if (!isValidEmail(user.email)) throw new Error('Invalid email');
}

function validateAdmin(admin: Admin) {
  if (!admin.email) throw new Error('Email required');
  if (!isValidEmail(admin.email)) throw new Error('Invalid email');
  // admin 特有验证...
}

// ✅ 提取公共函数
function validateEmail(email: string) {
  if (!email) throw new Error('Email required');
  if (!isValidEmail(email)) throw new Error('Invalid email');
}

function validateUser(user: User) {
  validateEmail(user.email);
  // 用户特有验证...
}

function validateAdmin(admin: Admin) {
  validateEmail(admin.email);
  // admin 特有验证...
}
```

### 2.3 KISS 原则 (Keep It Simple, Stupid)

保持简单，避免过度设计。

```typescript
// ❌ 过度设计
class UserFactory {
  static createUser(type: 'simple' | 'admin' | 'premium') {
    switch (type) {
      case 'simple': return new SimpleUser();
      case 'admin': return new AdminUser();
      case 'premium': return new PremiumUser();
    }
  }
}

// ✅ 简单实现
interface User {
  role: string;
  permissions: string[];
}

function createUser(role: string): User {
  const permissionMap = {
    simple: ['read'],
    admin: ['read', 'write', 'delete'],
    premium: ['read', 'write']
  };

  return { role, permissions: permissionMap[role] };
}
```

### 2.4 YAGNI 原则 (You Aren't Gonna Need It)

不要添加不需要的功能。

```typescript
// ❌ 过度准备
class OrderService {
  // 当前只需要同步处理
  async processOrder(orderId: string) { /* ... */ }

  // 未来可能需要异步，但现在不需要
  async processOrderAsync(orderId: string) { /* ... */ }

  // 可能支持批量处理
  async processOrdersBatch(orderIds: string[]) { /* ... */ }
}

// ✅ 按需实现
class OrderService {
  async processOrder(orderId: string) { /* ... */ }

  // 真的需要时再添加
}
```

## 3. 模块设计原则

### 3.1 高内聚

模块内部的元素应该紧密相关。

```typescript
// ✅ 高内聚: 用户相关功能在一起
user/
├── user.service.ts      # 用户业务逻辑
├── user.controller.ts   # 用户接口
├── user.repository.ts   # 用户数据访问
├── user.dto.ts         # 用户数据传输
└── user.entity.ts      # 用户实体定义

// ❌ 低内聚: 功能分散
controllers/
  └── user.controller.ts
services/
  └── user.service.ts
repositories/
  └── user.repository.ts
```

### 3.2 低耦合

模块之间依赖最小化。

```typescript
// ❌ 紧密耦合
class OrderService {
  private userService = new UserService(); // 直接实例化
  private paymentService = new PaymentService(); // 直接实例化

  async createOrder(userId: string, items: Item[]) {
    const user = await this.userService.getUser(userId);
    // ...
  }
}

// ✅ 松散耦合
class OrderService {
  constructor(
    private userService: IUserService,  // 依赖接口
    private paymentService: IPaymentService  // 依赖接口
  ) {}

  async createOrder(userId: string, items: Item[]) {
    const user = await this.userService.getUser(userId);
    // ...
  }
}

// 使用依赖注入容器
const orderService = new OrderService(
  container.get(IUserService),
  container.get(IPaymentService)
);
```

### 3.3 限界上下文

明确模块的边界。

```typescript
// 订单上下文
order/
  ├── order.service.ts
  ├── order.entity.ts
  └── value-objects/
      └── order-status.ts

// 用户上下文
user/
  ├── user.service.ts
  ├── user.entity.ts
  └── value-objects/
      ├── user-id.ts
      └── email.ts

// 明确的上下文边界
class Order {
  private userId: UserId;  // 引用用户上下文的值对象
  private orderStatus: OrderStatus;
}
```

## 4. 架构模式

### 4.1 分层架构

```
Presentation Layer (表示层)
    ↓
Application Layer (应用层 - Services)
    ↓
Domain Layer (领域层 - Entities, Value Objects)
    ↓
Infrastructure Layer (基础设施层 - Repositories, External Services)
```

#### 各层职责

**表示层**: HTTP 请求处理、DTO 转换
```typescript
@Controller('/users')
class UserController {
  constructor(private userService: UserService) {}

  @Post()
  async createUser(@Body() dto: CreateUserDto): Promise<UserDto> {
    const user = await this.userService.create(dto);
    return UserDto.fromDomain(user);
  }
}
```

**应用层**: 业务逻辑编排
```typescript
class UserService {
  constructor(
    private userRepository: UserRepository,
    private emailService: EmailService
  ) {}

  async createUser(dto: CreateUserDto): Promise<User> {
    // 1. 验证输入
    // 2. 创建用户实体
    const user = User.create({
      email: new Email(dto.email),
      password: await this.hashPassword(dto.password)
    });

    // 3. 保存到数据库
    await this.userRepository.save(user);

    // 4. 发送欢迎邮件
    await this.emailService.sendWelcomeEmail(user.email);

    return user;
  }
}
```

**领域层**: 核心业务逻辑
```typescript
class User {
  private constructor(
    public readonly id: UserId,
    public readonly email: Email,
    private passwordHash: string,
    private status: UserStatus
  ) {}

  // 业务规则封装
  static create(props: UserProps): User {
    if (!props.email.isValid()) {
      throw new InvalidEmailError();
    }

    return new User(
      UserId.generate(),
      props.email,
      props.password,
      UserStatus.Pending
    );
  }

  activate(token: string): void {
    // 验证激活令牌
    // 改变用户状态
    this.status = UserStatus.Active;
  }
}
```

**基础设施层**: 外部依赖实现
```typescript
class PostgresUserRepository implements UserRepository {
  constructor(private db: Database) {}

  async save(user: User): Promise<void> {
    await this.db.query(
      'INSERT INTO users (id, email, password) VALUES ($1, $2, $3)',
      [user.id.value, user.email.value, user.passwordHash]
    );
  }
}
```

### 4.2 Ports and Adapters (六边形架构)

```
          ┌────────────────────────────────┐
          │       Application Core         │
          │                                │
          │  ┌────────┐    ┌──────────┐  │
          │  │  User  │    │  Order   │  │
          │  │ Service│    │ Service  │  │
          │  └───┬────┘    └────┬─────┘  │
          │      │              │        │
          │  ┌───▼──────────────▼───┐    │
          │  │     Domain Model     │    │
          │  └┬───────────────────┬─┘    │
          └───┼───────────────────┼──────┘
              │                   │
              ▼                   ▼
      ┌──────────┐        ┌──────────┐
      │   Port   │        │   Port   │
      └┬──────────┘        └─────────┬┘
       │                            │
       ▼                            ▼
┌─────────────┐            ┌─────────────┐
│  Adapter    │            │  Adapter    │
│ (HTTP API)  │            │ (Database)  │
└─────────────┘            └─────────────┘
```

### 4.3 CQRS (Command Query Responsibility Segregation)

```typescript
// Command 模型 - 修改数据
class CreateOrderCommand {
  constructor(
    public readonly userId: string,
    public readonly items: OrderItem[]
  ) {}
}

class CreateOrderHandler {
  async handle(command: CreateOrderCommand): Promise<void> {
    // 业务逻辑
    // 验证库存
    // 创建订单
    // 发布事件
  }
}

// Query 模型 - 查询数据
class GetOrderQuery {
  constructor(public readonly orderId: string) {}
}

class GetOrderHandler {
  async handle(query: GetOrderQuery): Promise<OrderDto> {
    // 查询优化
    // 可以直接读从库
    // 读缓存
  }
}
```

### 4.4 Event Sourcing

```typescript
// 事件溯源模式
interface Event {
  type: string;
  aggregateId: string;
  timestamp: Date;
  data: any;
}

class Order {
  private events: Event[] = [];

  apply(event: Event): void {
    this.events.push(event);
    // 更新状态
  }

  getEvents(): Event[] {
    return [...this.events];
  }
}

// 订单事件
class OrderCreatedEvent implements Event {
  type = 'ORDER_CREATED';
}

class OrderPaidEvent implements Event {
  type = 'ORDER_PAID';
}

class OrderShippedEvent implements Event {
  type = 'ORDER_SHIPPED';
}
```

## 5. 微服务设计原则

### 5.1 服务拆分原则

#### 按业务能力拆分
```
✅ 推荐:
- 用户服务: 用户注册、登录、个人信息
- 订单服务: 订单创建、支付、物流
- 商品服务: 商品管理、库存管理

❌ 不推荐:
- 混合服务: 包含用户、订单、商品所有功能
```

#### 按数据边界拆分
```typescript
// 用户服务的数据边界
user_service_db:
  - users 表
  - user_profiles 表
  - user_addresses 表

// 订单服务的数据边界
order_service_db:
  - orders 表
  - order_items 表
  - payments 表
```

### 5.2 服务间通信

#### 同步调用 (REST/gRPC)
```typescript
// 使用 gRPC 定义服务接口
service UserService {
  rpc GetUser(GetUserRequest) returns (User);
  rpc CreateUser(CreateUserRequest) returns (User);
}

// 订单服务调用用户服务
class OrderService {
  constructor(private userClient: UserServiceClient) {}

  async createOrder(createOrderDto: CreateOrderDto): Promise<Order> {
    // 同步调用用户服务验证
    const user = await this.userClient.getUser({
      id: createOrderDto.userId
    });

    if (!user) {
      throw new UserNotFoundError();
    }

    // 创建订单...
  }
}
```

#### 异步通信 (消息队列)
```typescript
// 使用事件驱动
class OrderService {
  constructor(private eventBus: EventBus) {}

  async createOrder(order: Order): Promise<void> {
    await this.orderRepository.save(order);

    // 发布订单创建事件
    await this.eventBus.publish({
      type: 'ORDER_CREATED',
      data: { orderId: order.id, userId: order.userId }
    });
  }
}

// 邮件服务订阅订单事件
class EmailService {
  constructor(private eventBus: EventBus) {
    this.eventBus.subscribe('ORDER_CREATED', this.onOrderCreated);
  }

  private onOrderCreated(event: OrderCreatedEvent): void {
    this.sendOrderConfirmation(event.data.orderId);
  }
}
```

### 5.3 数据一致性

#### Saga 模式 (分布式事务)

```typescript
// Choreography Saga (编排式)
// 每个服务监听事件并做出响应

// 订单服务
class OrderService {
  async createOrder(order: Order) {
    await this.save(order);
    await this.eventBus.publish('ORDER_CREATED', { orderId: order.id });
  }

  async onPaymentFailed(event: PaymentFailedEvent) {
    await this.cancelOrder(event.orderId);
    await this.eventBus.publish('ORDER_CANCELLED', { orderId: event.orderId });
  }
}

// 支付服务
class PaymentService {
  async onOrderCreated(event: OrderCreatedEvent) {
    try {
      await this.processPayment(event.orderId);
      await this.eventBus.publish('PAYMENT_SUCCEEDED', { orderId: event.orderId });
    } catch (error) {
      await this.eventBus.publish('PAYMENT_FAILED', { orderId: event.orderId });
    }
  }
}

// 库存服务
class InventoryService {
  async onOrderCreated(event: OrderCreatedEvent) {
    await this.reserveStock(event.orderId);
    await this.eventBus.publish('STOCK_RESERVED', { orderId: event.orderId });
  }

  async onOrderCancelled(event: OrderCancelledEvent) {
    await this.releaseStock(event.orderId);
  }
}
```

## 6. 性能和可扩展性

### 6.1 缓存策略

```typescript
// 多层缓存
class UserService {
  constructor(
    private cache: RedisCache,
    private db: Database
  ) {}

  async getUser(id: string): Promise<User> {
    // 1. 本地缓存 (Caffeine)
    const localCache = this.getLocalCache(id);
    if (localCache) return localCache;

    // 2. Redis 缓存
    const cached = await this.cache.get(`user:${id}`);
    if (cached) {
      this.setLocalCache(id, cached);
      return cached;
    }

    // 3. 数据库
    const user = await this.db.query('SELECT * FROM users WHERE id = ?', [id]);

    // 4. 回填缓存
    await this.cache.set(`user:${id}`, user, { ttl: 3600 });
    this.setLocalCache(id, user);

    return user;
  }
}
```

### 6.2 数据库优化

```typescript
// 读写分离
class OrderRepository {
  constructor(
    private readDb: Database,  // 从库
    private writeDb: Database  // 主库
  ) {}

  async findById(id: string): Promise<Order> {
    return this.readDb.query('SELECT * FROM orders WHERE id = ?', [id]);
  }

  async save(order: Order): Promise<void> {
    await this.writeDb.query(
      'INSERT INTO orders ...',
      [order.id, order.userId, /* ... */]
    );
  }
}
```

## 7. 技术债务管理

### 7.1 技术债务识别

- 代码坏味道 (Code Smells)
- 过度复杂的代码
- 缺乏测试的代码
- 过时的依赖
- 性能瓶颈

### 7.2 还款策略

```typescript
// 在每个 Sprint 分配 20% 时间还技术债

// 标记技术债
// TODO: 重构这段代码，使用策略模式
deleteUser(id: string) {
  // 复杂逻辑
}

// 债务清单
const techDebtRegister = [
  {
    id: 'TD-001',
    description: 'UserService 过于复杂，需要拆分',
    severity: 'high',
    effort: '2 weeks',
    file: 'src/user/user.service.ts'
  }
];
```

---

## 8. 架构决策记录 (ADR)

### 8.1 ADR 模板

```markdown
# ADR-001: 使用微服务架构

## 状态
已接受

## 背景
单体应用规模扩大，团队增长，需要更好的扩展性和独立部署能力。

## 决策
将应用拆分为微服务：
- 用户服务
- 订单服务
- 商品服务
- 支付服务

每个服务独立部署，通过 gRPC 通信。

## 后果
积极：
- 独立部署
- 技术异构
- 团队自治

消极：
- 复杂性增加
- 分布式系统挑战
- 监控和调试困难
```

---

## 9. 架构审查清单

### 9.1 设计前检查

- [ ] 需求是否清晰？
- [ ] 是否有非功能需求？
- [ ] 技术选型是否合理？
- [ ] 团队是否熟悉该技术？

### 9.2 设计中检查

- [ ] 是否遵循 SOLID 原则？
- [ ] 模块化程度如何？
- [ ] 依赖关系是否清晰？
- [ ] 扩展性是否考虑？

### 9.3 设计后检查

- [ ] 是否有架构文档？
- [ ] 是否有风险评估？
- [ ] 监控告警是否配置？
- [ ] 部署方案是否清晰？

---

## 附录

### 相关文档
- [技术栈规范](../02.4-技术选型/technology-stack.md)
- [设计模式指南](../02.3-设计模式/design-patterns-overview.md)
- [微服务最佳实践](../02.2-架构决策记录/adr-003-microservices.md)

### 工具推荐
- **架构图**: draw.io, PlantUML
- **API 设计**: Swagger/OpenAPI
- **技术雷达**: ThoughtWorks Technology Radar

### 版本历史

| 版本 | 日期 | 更新内容 | 更新人 |
|------|------|----------|--------|
| 2.0 | 2024-11-30 | 新增 @rules/ 目录规范集成 | 架构团队 |
| 1.0 | 2024-01-01 | 初始版本创建 | 架构团队 |

**维护者**: 架构团队
**审核周期**: 每季度
**状态**: 持续更新中