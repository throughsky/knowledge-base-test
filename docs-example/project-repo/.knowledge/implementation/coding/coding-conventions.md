# 编码约定 (Coding Conventions)

**版本**: 1.0
**最后更新**: 2025-11-30
**继承自**: [L0 Java编码规范](../../../../enterprise-standards/standards/coding-standards/java-standards.md)

---

## 概述

本文档定义了项目的编码约定，继承企业编码规范并补充项目特定要求。

<!-- AI-CONTEXT
项目编码约定继承L0企业规范，并定义项目特定规则。
AI在生成代码时必须遵循这些约定。
-->

---

## 1. 包结构

```
com.company.ecommerce.{service}/
├── config/                 # 配置类
├── controller/             # REST控制器
├── service/                # 业务服务
│   ├── impl/              # 服务实现
├── repository/             # 数据访问
├── entity/                 # 数据库实体
├── mapper/                 # MyBatis Mapper
├── vo/                     # 值对象
│   ├── request/           # 请求DTO
│   └── response/          # 响应DTO
├── exception/              # 异常类
├── event/                  # 领域事件
└── util/                   # 工具类
```

---

## 2. 命名规范

### 2.1 类命名

| 类型 | 后缀 | 示例 |
|------|------|------|
| Controller | Controller | `UserController` |
| Service接口 | Service | `UserService` |
| Service实现 | ServiceImpl | `UserServiceImpl` |
| Repository | Repository | `UserRepository` |
| Mapper | Mapper | `UserMapper` |
| Entity | 无 | `User` |
| Request DTO | Request | `CreateUserRequest` |
| Response DTO | Response | `UserResponse` |
| Exception | Exception | `UserNotFoundException` |

### 2.2 方法命名

| 操作 | 前缀 | 示例 |
|------|------|------|
| 查询单个 | get/find | `getUserById()`, `findByEmail()` |
| 查询列表 | list/find | `listUsers()`, `findByStatus()` |
| 创建 | create | `createUser()` |
| 更新 | update | `updateUser()` |
| 删除 | delete | `deleteUser()` |
| 检查 | check/is/has | `checkPermission()`, `isActive()` |

---

## 3. API 路径规范

```
/api/v1/{resource}              # 资源列表
/api/v1/{resource}/{id}         # 单个资源
/api/v1/{resource}/{id}/{sub}   # 子资源
```

**示例**:
```
GET    /api/v1/users           # 获取用户列表
POST   /api/v1/users           # 创建用户
GET    /api/v1/users/{id}      # 获取用户详情
PUT    /api/v1/users/{id}      # 更新用户
DELETE /api/v1/users/{id}      # 删除用户
GET    /api/v1/users/{id}/orders  # 获取用户订单
```

---

## 4. 注释要求

### 4.1 类注释

```java
/**
 * 用户服务实现类。
 *
 * <p>处理用户的创建、查询、更新和删除操作。
 *
 * @author 张三
 * @since 1.0.0
 */
@Service
public class UserServiceImpl implements UserService {
}
```

### 4.2 方法注释

```java
/**
 * 根据ID查询用户。
 *
 * @param userId 用户ID，不能为空
 * @return 用户对象
 * @throws UserNotFoundException 当用户不存在时抛出
 */
public User getUserById(String userId) {
}
```

---

## 5. 异常处理

### 5.1 业务异常定义

```java
public class BusinessException extends RuntimeException {
    private final String code;
    private final String message;

    public BusinessException(String code, String message) {
        super(message);
        this.code = code;
        this.message = message;
    }
}

// 使用示例
throw new BusinessException("USER_NOT_FOUND", "用户不存在");
```

### 5.2 异常码规范

| 模块 | 前缀 | 示例 |
|------|------|------|
| 用户 | USER_ | `USER_NOT_FOUND` |
| 订单 | ORDER_ | `ORDER_CANCELLED` |
| 支付 | PAYMENT_ | `PAYMENT_FAILED` |
| 通用 | COMMON_ | `COMMON_VALIDATION_ERROR` |

---

## 6. 日志规范

```java
// 使用SLF4J
private static final Logger log = LoggerFactory.getLogger(UserService.class);

// INFO: 重要业务事件
log.info("User created, userId={}, email={}", user.getId(), user.getEmail());

// WARN: 潜在问题
log.warn("User login failed, email={}, attempt={}", email, attemptCount);

// ERROR: 异常情况，需要排查
log.error("Failed to create user, request={}", request, e);
```

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| 1.0 | 2025-11-30 | 初始版本 | @技术负责人 |
