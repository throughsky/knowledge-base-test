# Java 编码规范 (Java Coding Standards)

**版本**: 2.0
**最后更新**: 2025-11-30
**适用版本**: Java 17+
**状态**: 已发布

---

## 概述

本文档定义了企业Java项目的编码规范，所有Java项目必须遵循。

<!-- AI-CONTEXT
Java编码规范是L0层强制要求。
AI生成Java代码时必须遵循以下规范。
关键检查点：命名规范、注释要求、异常处理、代码结构
-->

---

## 1. 命名约定 (Naming Conventions)

### 通用规则

| 类型 | 规范 | 示例 |
|------|------|------|
| **类/接口** | UpperCamelCase | `UserService`, `OrderController` |
| **方法/变量** | lowerCamelCase | `getUserById()`, `orderCount` |
| **常量** | UPPER_SNAKE_CASE | `MAX_RETRIES`, `DEFAULT_TIMEOUT` |
| **包名** | 全小写，点分隔 | `com.company.project.service` |
| **泛型参数** | 单个大写字母 | `T`, `E`, `K`, `V` |

### 特殊命名

```java
// 布尔值：使用 is/has/can/should 前缀
boolean isEnabled;
boolean hasPermission;
boolean canDelete;

// 集合：使用复数形式
List<User> users;
Map<String, Order> orderMap;

// 接口实现：Impl后缀
interface UserService {}
class UserServiceImpl implements UserService {}

// 抽象类：Abstract前缀
abstract class AbstractRepository {}

// 异常类：Exception后缀
class OrderNotFoundException extends RuntimeException {}
```

---

## 2. 代码结构 (Code Structure)

### 类结构顺序

```java
public class UserService {

    // 1. 静态常量
    private static final Logger log = LoggerFactory.getLogger(UserService.class);
    private static final int MAX_RETRY = 3;

    // 2. 静态变量
    private static AtomicInteger counter = new AtomicInteger();

    // 3. 实例变量（按访问级别：public > protected > default > private）
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    // 4. 构造函数
    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    // 5. 公共方法
    public User createUser(CreateUserRequest request) { ... }
    public User getUserById(String id) { ... }

    // 6. 保护方法
    protected void validateUser(User user) { ... }

    // 7. 私有方法
    private String generateUserId() { ... }

    // 8. 内部类
    private static class UserIdGenerator { ... }
}
```

### 方法长度限制

| 指标 | 建议值 | 硬限制 |
|------|--------|--------|
| **方法行数** | ≤ 30行 | ≤ 50行 |
| **方法参数** | ≤ 4个 | ≤ 7个 |
| **类行数** | ≤ 300行 | ≤ 500行 |
| **圈复杂度** | ≤ 10 | ≤ 15 |

---

## 3. 注释规范 (Comments)

### Javadoc 要求

```java
/**
 * 用户服务，提供用户的创建、查询、更新和删除功能。
 *
 * <p>该服务是用户域的核心服务，处理所有与用户账户相关的业务逻辑。
 *
 * @author zhangsan
 * @since 1.0.0
 * @see UserRepository
 */
public class UserService {

    /**
     * 根据ID查询用户。
     *
     * @param userId 用户ID，不能为空
     * @return 用户对象
     * @throws UserNotFoundException 当用户不存在时抛出
     * @throws IllegalArgumentException 当userId为空时抛出
     */
    public User getUserById(String userId) {
        // ...
    }
}
```

### 注释原则

```java
// ✅ 好的注释：解释"为什么"
// 由于第三方支付API的速率限制(100次/分钟)，这里需要指数退避重试
for (int i = 0; i < MAX_RETRY; i++) {
    // ...
}

// ❌ 差的注释：解释"做什么"（代码本身应该清晰）
// 循环遍历用户列表
for (User user : users) {
    // ...
}
```

---

## 4. 异常处理 (Exception Handling)

### 异常分类

```java
// 业务异常：继承 RuntimeException，表示可预期的业务错误
public class OrderNotFoundException extends RuntimeException {
    private final String orderId;

    public OrderNotFoundException(String orderId) {
        super("Order not found: " + orderId);
        this.orderId = orderId;
    }

    public String getOrderId() {
        return orderId;
    }
}

// 系统异常：通常由框架处理，记录日志并返回500
```

### 异常处理规则

```java
// ✅ 正确：捕获具体异常，记录上下文
try {
    return orderRepository.findById(orderId)
        .orElseThrow(() -> new OrderNotFoundException(orderId));
} catch (DataAccessException e) {
    log.error("Failed to query order, orderId={}", orderId, e);
    throw new ServiceException("Database error", e);
}

// ❌ 错误：吞掉异常
try {
    // some operation
} catch (Exception e) {
    // 禁止空catch块
}

// ❌ 错误：捕获过宽的异常类型
try {
    // some operation
} catch (Exception e) {
    // 应该捕获具体的异常类型
}
```

### 统一异常处理

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ErrorResponse> handleBusinessException(BusinessException e) {
        log.warn("Business exception: {}", e.getMessage());
        return ResponseEntity.badRequest()
            .body(new ErrorResponse(e.getCode(), e.getMessage()));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleUnknownException(Exception e) {
        log.error("Unexpected error", e);
        return ResponseEntity.internalServerError()
            .body(new ErrorResponse("INTERNAL_ERROR", "服务器内部错误"));
    }
}
```

---

## 5. 日志规范 (Logging)

### 日志级别使用

| 级别 | 使用场景 |
|------|----------|
| **ERROR** | 影响功能的错误，需要立即关注 |
| **WARN** | 潜在问题，不影响主流程 |
| **INFO** | 重要业务事件，如订单创建 |
| **DEBUG** | 开发调试信息 |
| **TRACE** | 详细的追踪信息 |

### 日志格式

```java
// ✅ 正确：使用占位符，包含上下文
log.info("User created, userId={}, email={}", user.getId(), user.getEmail());
log.error("Failed to create order, userId={}, request={}", userId, request, e);

// ❌ 错误：字符串拼接（性能差）
log.info("User created, userId=" + user.getId());

// ❌ 错误：缺少上下文
log.error("Error occurred", e);

// ❌ 错误：记录敏感信息
log.info("User login, password={}", password);  // 禁止记录密码
```

---

## 6. 代码风格 (Code Style)

### 格式化配置

```xml
<!-- checkstyle.xml 核心配置 -->
<module name="Checker">
    <property name="charset" value="UTF-8"/>

    <module name="TreeWalker">
        <!-- 缩进：4个空格 -->
        <module name="Indentation">
            <property name="basicOffset" value="4"/>
        </module>

        <!-- 行长度：120字符 -->
        <module name="LineLength">
            <property name="max" value="120"/>
        </module>

        <!-- 大括号风格 -->
        <module name="LeftCurly"/>
        <module name="RightCurly"/>

        <!-- 空格 -->
        <module name="WhitespaceAround"/>
    </module>
</module>
```

### IDE配置

建议使用统一的IDE格式化配置：
- IntelliJ IDEA: `.idea/codeStyles/Project.xml`
- VS Code: `.vscode/settings.json`

---

## 7. 最佳实践 (Best Practices)

### Optional 使用

```java
// ✅ 正确用法
public Optional<User> findById(String id) {
    return userRepository.findById(id);
}

// 使用时
User user = userService.findById(id)
    .orElseThrow(() -> new UserNotFoundException(id));

// ❌ 错误：Optional作为字段
public class User {
    private Optional<String> nickname;  // 禁止
}

// ❌ 错误：Optional作为参数
public void updateUser(Optional<String> name) {  // 禁止
}
```

### Stream 使用

```java
// ✅ 简洁的Stream操作
List<String> activeUserEmails = users.stream()
    .filter(User::isActive)
    .map(User::getEmail)
    .collect(Collectors.toList());

// ❌ 过度复杂的Stream（考虑拆分或使用传统循环）
users.stream()
    .filter(u -> u.getStatus() == Status.ACTIVE)
    .flatMap(u -> u.getOrders().stream())
    .filter(o -> o.getAmount().compareTo(BigDecimal.valueOf(100)) > 0)
    .map(o -> new OrderDTO(o.getId(), o.getAmount()))
    .sorted(Comparator.comparing(OrderDTO::getAmount).reversed())
    .limit(10)
    .collect(Collectors.groupingBy(OrderDTO::getCategory));
```

---

## 检查工具配置

### Maven

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-checkstyle-plugin</artifactId>
    <version>3.3.0</version>
    <configuration>
        <configLocation>checkstyle.xml</configLocation>
        <failsOnError>true</failsOnError>
    </configuration>
</plugin>
```

### Gradle

```groovy
plugins {
    id 'checkstyle'
}

checkstyle {
    toolVersion = '10.12.0'
    configFile = file("${rootDir}/checkstyle.xml")
}
```

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| 2.0 | 2025-11-30 | 增加AI上下文、Optional最佳实践 | @架构委员会 |
| 1.0 | 2025-01-01 | 初始版本 | @架构委员会 |
