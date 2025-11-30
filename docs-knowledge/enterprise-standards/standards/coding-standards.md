# 编码规范

## 通用规范

### 命名约定

| 类型 | 规范 | 示例 |
|------|------|------|
| 类名 | UpperCamelCase + 后缀 | `UserService`, `OrderController` |
| 方法 | lowerCamelCase + 动词 | `createUser()`, `findById()` |
| 常量 | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT` |
| 包名 | 小写 + 层级 | `com.company.user.service` |

### 代码组织

```
src/
├── controller/     # API层
├── service/        # 业务层
├── repository/     # 数据层
├── domain/         # 领域模型
│   ├── entity/
│   ├── event/
│   └── vo/
└── infrastructure/ # 基础设施
```

### 异常处理

```java
// 业务异常使用自定义异常
throw new BusinessException(ErrorCode.USER_NOT_FOUND);

// 禁止吞异常
try {
    // ...
} catch (Exception e) {
    log.error("操作失败", e);  // 必须记录日志
    throw new ServiceException(e);
}
```

### 日志规范

```java
// 结构化日志
log.info("订单创建成功",
    kv("orderId", orderId),
    kv("userId", userId),
    kv("amount", amount));
```

## Web3/金融特殊规范

### 金额处理

```java
// 必须使用BigDecimal
BigDecimal amount = new BigDecimal("100.50");

// 禁止浮点数
double amount = 100.50; // 禁止！
```

### 链上交易

```java
// 必须幂等
@Idempotent(key = "#txHash")
public void processTransaction(String txHash) { }

// 必须重试机制
@Retryable(maxAttempts = 3)
public TransactionReceipt sendTransaction() { }
```
