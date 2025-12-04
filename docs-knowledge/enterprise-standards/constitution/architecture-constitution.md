# 架构基本法 (Architecture Constitution)

本文档定义了 Web3 金融平台的技术规范和约束，是所有开发活动必须遵循的基本准则。

## 一、技术栈白名单

### 1.1 编程语言与框架

| 领域 | 强制选型 | 备选（需审批） | 禁止 |
|------|---------|---------------|------|
| **主语言** | Java 21 + Spring Boot 3.x | Kotlin (与Java互操作) | Python后端服务, Node.js核心服务 |
| **Web3 SDK** | web3j (Java生态统一) | - | ethers.js (除前端外) |
| **构建工具** | Maven 3.9+ | Gradle (需审批) | Ant |
| **JDK发行版** | Amazon Corretto 21 | - | Oracle JDK (许可证) |

### 1.2 中间件选型

| 领域 | 强制选型 | 备选（需审批） | 禁止 |
|------|---------|---------------|------|
| **消息队列** | Kafka (MSK) | SQS (轻量异步) | RabbitMQ, Pulsar |
| **缓存** | Redis 7.x + Redisson | - | 其他Redis客户端, Memcached |
| **配置中心** | Nacos 2.x | AWS Parameter Store | 硬编码配置, Apollo |
| **服务发现** | Nacos / Kubernetes DNS | Consul | Eureka |
| **网关** | Spring Cloud Gateway | Kong | Zuul |

### 1.3 数据存储

| 领域 | 强制选型 | 备选（需审批） | 禁止 |
|------|---------|---------------|------|
| **关系型数据库** | Aurora PostgreSQL 15+ | - | MySQL, Oracle |
| **ORM框架** | MyBatis Plus 3.5+ | - | JPA/Hibernate (性能考虑) |
| **时序数据库** | AWS TimeStream | TimescaleDB | InfluxDB |
| **搜索引擎** | OpenSearch | - | Elasticsearch (许可证) |
| **对象存储** | AWS S3 | - | 自建存储 |

### 1.4 容器与编排

| 领域 | 强制选型 | 备选（需审批） | 禁止 |
|------|---------|---------------|------|
| **容器运行时** | containerd | - | Docker (生产环境) |
| **编排平台** | EKS (Kubernetes 1.28+) | - | ECS, 裸Docker |
| **服务网格** | Istio / AWS App Mesh | - | Linkerd |
| **镜像仓库** | ECR | - | Docker Hub |

### 1.5 依赖管理 (BOM)

```xml
<!-- 所有服务必须继承此Parent POM -->
<parent>
    <groupId>com.company</groupId>
    <artifactId>web3fin-parent</artifactId>
    <version>1.0.0</version>
</parent>

<!-- Parent POM 管理的核心依赖版本 -->
<properties>
    <java.version>21</java.version>
    <spring-boot.version>3.2.0</spring-boot.version>
    <spring-cloud.version>2023.0.0</spring-cloud.version>
    <mybatis-plus.version>3.5.5</mybatis-plus.version>
    <redisson.version>3.25.0</redisson.version>
    <web3j.version>4.10.3</web3j.version>
    <nacos.version>2.3.0</nacos.version>
</properties>
```

**AI意义**: 当AI知道项目继承自 `web3fin-parent-v1.0`，它就能准确预测可用的工具类库，减少幻觉。

---

## 二、工程目录结构规范

### 2.1 标准目录结构

```
{service-name}/
├── src/main/java/com/company/{service}/
│   ├── api/                    # Controller层 - HTTP/gRPC接口
│   │   ├── controller/         # REST Controllers
│   │   ├── request/            # 入参DTO (Command/Query)
│   │   └── response/           # 出参VO
│   ├── core/                   # 领域层 - 业务核心逻辑
│   │   ├── domain/             # 领域模型
│   │   │   ├── entity/         # 领域实体
│   │   │   ├── valueobject/    # 值对象
│   │   │   └── event/          # 领域事件
│   │   ├── service/            # 领域服务
│   │   └── port/               # 端口接口 (依赖倒置)
│   ├── infra/                  # 基础设施层
│   │   ├── persistence/        # 数据库实现
│   │   │   ├── entity/         # PO (数据库实体)
│   │   │   ├── mapper/         # MyBatis Mapper接口
│   │   │   └── repository/     # Repository实现
│   │   ├── cache/              # 缓存实现
│   │   ├── mq/                 # 消息队列
│   │   │   ├── producer/       # 消息生产者
│   │   │   └── consumer/       # 消息消费者
│   │   └── external/           # 外部服务调用
│   ├── client/                 # 对外暴露的客户端
│   │   ├── api/                # Feign Client接口
│   │   └── dto/                # 客户端DTO
│   ├── config/                 # 配置类
│   └── common/                 # 服务内公共组件
│       ├── constant/           # 常量定义
│       ├── enums/              # 枚举定义
│       └── exception/          # 异常定义
├── src/main/resources/
│   ├── mapper/                 # MyBatis XML映射文件
│   ├── db/migration/           # Flyway迁移脚本
│   │   ├── V1__init_schema.sql
│   │   └── V2__add_index.sql
│   ├── application.yml         # 主配置
│   ├── application-dev.yml     # 开发环境
│   ├── application-staging.yml # 预发环境
│   └── bootstrap.yml           # Nacos配置
├── src/test/
│   ├── java/
│   │   ├── unit/               # 单元测试
│   │   └── integration/        # 集成测试
│   └── resources/
├── Dockerfile
├── helm/                       # Helm Charts
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
└── pom.xml
```

### 2.2 目录职责说明

| 目录 | 职责 | 禁止行为 |
|------|------|---------|
| `api/` | HTTP接口、参数校验、响应封装 | 禁止包含业务逻辑 |
| `core/` | 领域模型、业务规则、领域服务 | 禁止依赖基础设施层 |
| `infra/` | 数据访问、外部调用、技术实现 | 禁止被api层直接调用 |
| `client/` | 供其他服务调用的Feign客户端 | 禁止包含实现逻辑 |

### 2.3 类命名规范

| 类型 | 命名模式 | 示例 |
|------|---------|------|
| Controller | `{Domain}Controller` | `WalletController` |
| Service接口 | `{Domain}Service` | `WalletService` |
| Service实现 | `{Domain}ServiceImpl` | `WalletServiceImpl` |
| Repository | `{Domain}Repository` | `WalletRepository` |
| Mapper | `{Domain}Mapper` | `WalletMapper` |
| 请求DTO | `{Action}{Domain}Request` | `CreateWalletRequest` |
| 响应VO | `{Domain}Response` / `{Domain}VO` | `WalletResponse` |
| 数据库实体 | `{Domain}PO` | `WalletPO` |
| 领域实体 | `{Domain}` | `Wallet` |

---

## 三、错误码规范

### 3.1 错误码格式

```
格式: {PROJECT}_{MODULE}_{TYPE}_{CODE}

PROJECT: WEB3FIN (项目前缀，固定)
MODULE:  模块标识 (见下表)
TYPE:    错误类型 (BIZ/SYS/VAL)
CODE:    4位数字序号
```

### 3.2 模块标识

| 模块 | 标识 | 范围 |
|------|------|------|
| 用户服务 | USER | 0001-0999 |
| 认证服务 | AUTH | 1001-1999 |
| 钱包服务 | WALLET | 2001-2999 |
| 托管服务 | CUSTODY | 3001-3999 |
| 借贷服务 | LENDING | 4001-4999 |
| 质押服务 | STAKING | 5001-5999 |
| RWA服务 | RWA | 6001-6999 |
| 账务服务 | ACCOUNT | 7001-7999 |
| 运营服务 | ADMIN | 8001-8999 |
| 公共模块 | COMMON | 9001-9999 |

### 3.3 错误类型

| 类型 | 标识 | 说明 | HTTP状态码 |
|------|------|------|-----------|
| 业务错误 | BIZ | 业务规则校验失败 | 200 (code非0) |
| 系统错误 | SYS | 系统内部异常 | 500 |
| 校验错误 | VAL | 参数校验失败 | 400 |
| 认证错误 | AUTH | 认证授权失败 | 401/403 |

### 3.4 错误码示例

```java
// 错误码枚举定义
public enum ErrorCode {
    // 用户模块
    WEB3FIN_USER_VAL_0001("用户名格式错误"),
    WEB3FIN_USER_BIZ_0001("用户不存在"),
    WEB3FIN_USER_BIZ_0002("用户已被禁用"),

    // 钱包模块
    WEB3FIN_WALLET_VAL_0001("钱包地址格式错误"),
    WEB3FIN_WALLET_BIZ_0001("余额不足"),
    WEB3FIN_WALLET_BIZ_0002("钱包已冻结"),
    WEB3FIN_WALLET_SYS_0001("链上交易失败"),

    // 借贷模块
    WEB3FIN_LENDING_BIZ_0001("抵押率不足"),
    WEB3FIN_LENDING_BIZ_0002("借款额度超限"),
    WEB3FIN_LENDING_SYS_0001("利息计算引擎不可用");
}
```

### 3.5 统一响应格式

```java
@Data
public class ApiResponse<T> {
    /**
     * 错误码，"0" 表示成功
     */
    private String code;

    /**
     * 错误信息
     */
    private String message;

    /**
     * 业务数据
     */
    private T data;

    /**
     * 链路追踪ID
     */
    private String traceId;

    /**
     * 响应时间戳
     */
    private Long timestamp;

    public static <T> ApiResponse<T> success(T data) {
        ApiResponse<T> response = new ApiResponse<>();
        response.setCode("0");
        response.setMessage("success");
        response.setData(data);
        response.setTimestamp(System.currentTimeMillis());
        return response;
    }

    public static <T> ApiResponse<T> fail(String code, String message) {
        ApiResponse<T> response = new ApiResponse<>();
        response.setCode(code);
        response.setMessage(message);
        response.setTimestamp(System.currentTimeMillis());
        return response;
    }
}
```

### 3.6 全局异常处理

```java
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(BizException.class)
    public ApiResponse<?> handleBizException(BizException e) {
        log.warn("Business exception: code={}, message={}", e.getCode(), e.getMessage());
        return ApiResponse.fail(e.getCode(), e.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ApiResponse<?> handleValidationException(MethodArgumentNotValidException e) {
        String message = e.getBindingResult().getFieldErrors().stream()
            .map(error -> error.getField() + ": " + error.getDefaultMessage())
            .collect(Collectors.joining(", "));
        return ApiResponse.fail("WEB3FIN_COMMON_VAL_0001", message);
    }

    @ExceptionHandler(Exception.class)
    public ApiResponse<?> handleException(Exception e) {
        log.error("System exception", e);
        return ApiResponse.fail("WEB3FIN_COMMON_SYS_0001", "系统繁忙，请稍后重试");
    }
}
```

---

## 四、API 规范

### 4.1 RESTful 约束

```yaml
# URL命名规范
风格: kebab-case (小写字母 + 连字符)
示例:
  正确: /api/v1/user-accounts
  错误: /api/v1/userAccounts, /api/v1/user_accounts

# 资源命名
使用名词复数: /users, /wallets, /transactions
避免动词: /getUser (错误), /users/{id} (正确)

# 层级关系
最多2层嵌套: /users/{userId}/wallets
避免过深: /users/{userId}/wallets/{walletId}/transactions/{txId}/details (错误)
```

### 4.2 HTTP Method 语义

| Method | 语义 | 幂等性 | 示例 |
|--------|------|--------|------|
| GET | 查询资源 | 是 | `GET /users/{id}` |
| POST | 创建资源 | 否 | `POST /users` |
| PUT | 全量更新 | 是 | `PUT /users/{id}` |
| PATCH | 部分更新 | 是 | `PATCH /users/{id}` |
| DELETE | 删除资源 | 是 | `DELETE /users/{id}` |

### 4.3 版本控制

```yaml
# URL路径版本 (强制)
格式: /api/v{major}/resource
示例: /api/v1/users, /api/v2/users

# 版本升级策略
- 新增字段: 不升级版本，保持向后兼容
- 删除字段: 升级Major版本
- 修改字段语义: 升级Major版本
- 废弃旧版本: 至少保留6个月过渡期
```

### 4.4 分页规范

```yaml
# 请求参数
page: 页码 (从1开始)
size: 每页大小 (默认20，最大100)
sort: 排序字段,方向 (如: createdAt,desc)

# 请求示例
GET /api/v1/transactions?page=1&size=20&sort=createdAt,desc

# 响应格式
{
  "code": "0",
  "data": {
    "content": [...],           // 数据列表
    "totalElements": 100,       // 总记录数
    "totalPages": 5,            // 总页数
    "number": 1,                // 当前页码
    "size": 20,                 // 每页大小
    "first": true,              // 是否第一页
    "last": false               // 是否最后一页
  }
}
```

### 4.5 传输对象分离

```
严格分层，禁止混用:

┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Request   │ ──▶ │   Domain    │ ──▶ │   Response  │
│   (DTO)     │     │   (Entity)  │     │   (VO)      │
└─────────────┘     └─────────────┘     └─────────────┘
       │                   │                   │
       ▼                   ▼                   ▼
  入参校验            业务处理           出参脱敏
  命令/查询           领域模型           视图展示

禁止: PO直接暴露给前端
禁止: Request直接存入数据库
```

---

## 五、数据库规范

### 5.1 命名规范

```sql
-- 表命名: t_{module}_{name}
-- 示例:
t_user_account          -- 用户账户表
t_wallet_balance        -- 钱包余额表
t_lending_order         -- 借贷订单表

-- 字段命名: snake_case
-- 示例:
user_id, created_at, is_deleted

-- 索引命名
idx_{table}_{column(s)}     -- 普通索引
uk_{table}_{column(s)}      -- 唯一索引
pk_{table}                  -- 主键 (通常自动)

-- 示例:
idx_wallet_balance_user_id
uk_wallet_balance_user_currency
```

### 5.2 公共字段规范

```sql
-- 所有表必须包含以下公共字段
CREATE TABLE t_xxx (
    -- 主键 (雪花算法生成)
    id              BIGINT PRIMARY KEY,

    -- 审计字段
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by      VARCHAR(64),
    updated_by      VARCHAR(64),

    -- 软删除
    is_deleted      BOOLEAN NOT NULL DEFAULT FALSE,

    -- 乐观锁
    version         INT NOT NULL DEFAULT 0
);

-- 自动更新 updated_at 触发器
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### 5.3 字段类型规范

| 数据类型 | PostgreSQL类型 | 说明 |
|---------|---------------|------|
| 金额 | DECIMAL(36,18) | 支持18位小数精度 |
| 时间戳 | TIMESTAMP | 统一UTC时区 |
| 布尔值 | BOOLEAN | 不使用TINYINT |
| 字符串 | VARCHAR(n) | 指定长度，避免TEXT |
| 枚举 | VARCHAR(32) | 存储枚举名称，不用数字 |
| JSON | JSONB | 非结构化数据 |

### 5.4 Schema变更规范

```sql
-- 所有DDL必须通过Flyway管理
-- 文件命名: V{version}__{description}.sql

-- 示例: V1__init_wallet_schema.sql
CREATE TABLE t_wallet_balance (
    id              BIGINT PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    currency        VARCHAR(16) NOT NULL,
    available       DECIMAL(36,18) NOT NULL DEFAULT 0,
    frozen          DECIMAL(36,18) NOT NULL DEFAULT 0,
    status          VARCHAR(16) NOT NULL DEFAULT 'ACTIVE',
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by      VARCHAR(64),
    updated_by      VARCHAR(64),
    is_deleted      BOOLEAN NOT NULL DEFAULT FALSE,
    version         INT NOT NULL DEFAULT 0
);

CREATE INDEX idx_wallet_balance_user_id ON t_wallet_balance(user_id);
CREATE UNIQUE INDEX uk_wallet_balance_user_currency
    ON t_wallet_balance(user_id, currency) WHERE is_deleted = FALSE;

COMMENT ON TABLE t_wallet_balance IS '钱包余额表';
COMMENT ON COLUMN t_wallet_balance.available IS '可用余额';
COMMENT ON COLUMN t_wallet_balance.frozen IS '冻结余额';
```

**AI意义**: AI读取 `db/migration/` 目录下的schema文件后，能极快地理解业务数据结构。

---

## 六、日志规范

### 6.1 日志格式

```json
{
  "timestamp": "2024-01-15T10:30:00.000Z",
  "level": "INFO",
  "logger": "com.company.wallet.service.TransferService",
  "message": "Transfer completed",
  "traceId": "abc123def456",
  "spanId": "span789",
  "serviceName": "wallet-service",
  "env": "prod",
  "userId": "user_001",
  "bizData": {
    "orderId": "order_123",
    "fromWallet": "wallet_001",
    "toWallet": "wallet_002",
    "amount": "100.00",
    "currency": "USDT"
  }
}
```

### 6.2 必填字段

| 字段 | 说明 | 来源 |
|------|------|------|
| timestamp | 日志时间 | 自动生成 |
| level | 日志级别 | 自动生成 |
| logger | 日志类名 | 自动生成 |
| message | 日志消息 | 开发填写 |
| traceId | 链路追踪ID | MDC自动注入 |
| spanId | Span ID | MDC自动注入 |
| serviceName | 服务名称 | 配置注入 |
| env | 环境标识 | 配置注入 |
| userId | 用户ID | MDC上下文 |

### 6.3 日志级别使用

| 级别 | 使用场景 | 示例 |
|------|---------|------|
| ERROR | 需要立即处理的错误 | 数据库连接失败、外部服务不可用 |
| WARN | 潜在问题，需关注 | 重试成功、性能下降 |
| INFO | 关键业务节点 | 订单创建、支付完成 |
| DEBUG | 调试信息 | 方法入参、中间状态 |
| TRACE | 详细追踪 | 循环内部、算法步骤 |

### 6.4 禁止行为

```java
// 禁止
System.out.println("xxx");           // 使用log替代
e.printStackTrace();                  // 使用log.error("msg", e)
log.info("user=" + user);            // 使用占位符
log.info("password=" + password);    // 禁止记录敏感信息

// 正确
log.info("Transfer completed, orderId={}, amount={}", orderId, amount);
log.error("Transfer failed, orderId={}", orderId, exception);
```

### 6.5 Logback配置模板

```xml
<configuration>
    <appender name="JSON" class="ch.qos.logback.core.ConsoleAppender">
        <encoder class="net.logstash.logback.encoder.LogstashEncoder">
            <includeMdcKeyName>traceId</includeMdcKeyName>
            <includeMdcKeyName>spanId</includeMdcKeyName>
            <includeMdcKeyName>userId</includeMdcKeyName>
            <customFields>
                {"serviceName":"${SERVICE_NAME}","env":"${ENV}"}
            </customFields>
        </encoder>
    </appender>

    <root level="INFO">
        <appender-ref ref="JSON"/>
    </root>
</configuration>
```

---

## 七、分布式事务策略

### 7.1 策略优先级

```
优先级从高到低 (优先选择简单方案):

1. 本地事务优先
   - 尽量设计单服务内完成
   - 使用 @Transactional 注解

2. 消息最终一致性
   - Kafka + 本地消息表
   - 适用于大部分跨服务场景

3. TCC模式
   - Try-Confirm-Cancel
   - 强一致性场景 (如钱包扣款)

4. Saga模式
   - 长事务补偿
   - 复杂业务流程
```

### 7.2 本地消息表模式

```sql
-- 本地消息表
CREATE TABLE t_outbox_message (
    id              BIGINT PRIMARY KEY,
    topic           VARCHAR(128) NOT NULL,
    message_key     VARCHAR(128),
    payload         JSONB NOT NULL,
    status          VARCHAR(16) NOT NULL DEFAULT 'PENDING',
    retry_count     INT NOT NULL DEFAULT 0,
    next_retry_at   TIMESTAMP,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_outbox_status_retry ON t_outbox_message(status, next_retry_at);
```

```java
// 使用示例
@Transactional
public void transfer(TransferCommand cmd) {
    // 1. 本地业务操作
    walletRepository.debit(cmd.getFromWallet(), cmd.getAmount());

    // 2. 写入本地消息表 (同一事务)
    outboxRepository.save(OutboxMessage.builder()
        .topic("wallet.transfer")
        .payload(cmd)
        .build());
}

// 定时任务发送消息
@Scheduled(fixedDelay = 1000)
public void publishOutboxMessages() {
    List<OutboxMessage> pending = outboxRepository.findPending();
    for (OutboxMessage msg : pending) {
        try {
            kafkaTemplate.send(msg.getTopic(), msg.getPayload());
            outboxRepository.markSent(msg.getId());
        } catch (Exception e) {
            outboxRepository.incrementRetry(msg.getId());
        }
    }
}
```

### 7.3 TCC模式

```java
// TCC接口定义
public interface WalletTccService {

    @TwoPhaseBusinessAction(name = "debitWallet",
        commitMethod = "confirm",
        rollbackMethod = "cancel")
    boolean tryDebit(BusinessActionContext ctx,
        @BusinessActionContextParameter(paramName = "walletId") String walletId,
        @BusinessActionContextParameter(paramName = "amount") BigDecimal amount);

    boolean confirm(BusinessActionContext ctx);

    boolean cancel(BusinessActionContext ctx);
}

// 实现
@Service
public class WalletTccServiceImpl implements WalletTccService {

    @Override
    public boolean tryDebit(BusinessActionContext ctx, String walletId, BigDecimal amount) {
        // 冻结金额
        walletRepository.freeze(walletId, amount);
        return true;
    }

    @Override
    public boolean confirm(BusinessActionContext ctx) {
        String walletId = ctx.getActionContext("walletId");
        BigDecimal amount = ctx.getActionContext("amount");
        // 扣减冻结金额
        walletRepository.confirmDebit(walletId, amount);
        return true;
    }

    @Override
    public boolean cancel(BusinessActionContext ctx) {
        String walletId = ctx.getActionContext("walletId");
        BigDecimal amount = ctx.getActionContext("amount");
        // 解冻金额
        walletRepository.unfreeze(walletId, amount);
        return true;
    }
}
```

---

## 八、安全规范

### 8.1 认证授权

```yaml
认证方式:
  - JWT (Access Token): 有效期15分钟
  - Refresh Token: 有效期7天
  - Token存储: Redis (支持主动过期和踢出)

敏感操作二次验证:
  - 提现: 需要2FA验证
  - 修改密码: 需要原密码 + 短信验证码
  - 绑定新设备: 需要邮箱验证
```

### 8.2 数据安全

```yaml
敏感字段加密:
  算法: AES-256-GCM
  字段: 身份证号、银行卡号、私钥

密钥管理:
  存储: AWS Secrets Manager
  轮换: 每90天自动轮换

传输安全:
  协议: TLS 1.3
  证书: ACM托管证书
```

### 8.3 API安全

```yaml
限流策略:
  用户级: 100 req/s per user
  IP级: 1000 req/s per IP
  接口级: 根据接口配置

请求签名:
  - 关键接口需要签名校验
  - 签名算法: HMAC-SHA256
  - 防重放: timestamp + nonce

审计日志:
  - 所有写操作记录审计日志
  - 保留期限: 7年 (合规要求)
```

### 8.4 安全编码规范

```java
// 禁止SQL拼接
String sql = "SELECT * FROM users WHERE id = " + userId;  // 禁止

// 使用参数化查询
@Select("SELECT * FROM users WHERE id = #{userId}")
User findById(@Param("userId") Long userId);

// 禁止日志打印敏感信息
log.info("User login, password={}", password);  // 禁止

// 脱敏后打印
log.info("User login, userId={}", userId);

// 输出编码防XSS
String safe = HtmlUtils.htmlEscape(userInput);
```

---

## 九、可观测性规范

### 9.1 Metrics埋点

```yaml
# Prometheus命名规范
格式: {namespace}_{subsystem}_{name}_{unit}

示例:
  web3fin_wallet_transfer_total           # 转账总次数
  web3fin_wallet_transfer_amount_sum      # 转账总金额
  web3fin_wallet_balance_query_seconds    # 余额查询耗时

# 必须保留的黄金指标
延迟 (Latency):
  - http_server_requests_seconds_bucket
  - http_server_requests_seconds_sum
  - http_server_requests_seconds_count

流量 (Traffic):
  - http_server_requests_total

错误 (Errors):
  - http_server_requests_total{status="5xx"}

饱和度 (Saturation):
  - jvm_memory_used_bytes
  - hikaricp_connections_active
```

### 9.2 链路追踪

```yaml
# 追踪上下文传播
Header: traceparent (W3C标准)
格式: 00-{traceId}-{spanId}-{flags}

# Span命名规范
HTTP: {method} {path}
RPC: {service}.{method}
DB: {operation} {table}
MQ: {topic} {operation}

# 示例
HTTP GET /api/v1/wallets/{id}
gRPC wallet.WalletService/GetBalance
PostgreSQL SELECT t_wallet_balance
Kafka wallet.transfer.events send
```

---

## 十、违规处理

### 10.1 违规分级

| 级别 | 描述 | 处理方式 |
|------|------|---------|
| P0 | 安全漏洞、生产事故风险 | 阻断发布，立即修复 |
| P1 | 违反强制规范 | Code Review不通过 |
| P2 | 违反建议规范 | 提醒改进，不阻断 |

### 10.2 自动化检查

```yaml
# 在CI流水线中强制执行
pre-commit:
  - checkstyle: 代码风格检查
  - spotbugs: 静态代码分析
  - dependency-check: 依赖漏洞扫描

build:
  - unit-test: 单元测试覆盖率 >= 80%
  - sonarqube: 代码质量门禁
  - schema-check: 数据库变更审核
```
