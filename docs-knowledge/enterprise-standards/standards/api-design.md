# API设计规范

**版本**: 1.1.0
**最后更新**: 2025-12-01

---

## 核心约束 (强制执行)

> ⚠️ **重要**: 本规范仅允许使用 GET 和 POST 两种 HTTP 方法，禁止使用 PUT、DELETE、PATCH。

### HTTP 方法限制

| 方法 | 允许 | 用途 |
|------|------|------|
| GET | ✅ | 查询单条或简单查询 |
| POST | ✅ | 复杂查询、分页、创建、修改、删除 |
| PUT | ❌ | **禁止使用** |
| PATCH | ❌ | **禁止使用** |
| DELETE | ❌ | **禁止使用** |

---

## URL设计规范

### 资源化路径 (强制)

```
# ✅ 正确：资源化路径
GET  /api/v1/users              # 简单列表查询
GET  /api/v1/users/{id}         # 查询单条
POST /api/v1/users              # 创建用户
POST /api/v1/users/{id}         # 更新用户
POST /api/v1/users/{id}/delete  # 删除用户（软删除）
POST /api/v1/users/search       # 复杂查询/分页

# ❌ 错误：动词化路径
GET  /api/v1/getUsers           # 禁止
POST /api/v1/createUser         # 禁止
POST /api/v1/deleteUser         # 禁止
```

### 参数传递规则

| 参数数量 | 方法 | 传递方式 |
|----------|------|----------|
| 0-2 个 | GET | URL Query 参数 |
| > 2 个 | POST | 请求体 JSON |
| 复杂查询 | POST | 请求对象 |
| 分页查询 | POST | 继承 `CommonPageRequest` |

---

## 响应格式 (强制)

### 统一响应封装

所有 API 必须使用 `CommonResponse<T>` 统一封装：

```java
public class CommonResponse<T> {
    private String code;      // 业务码
    private String message;   // 提示信息
    private T data;           // 业务数据
    private String traceId;   // 追踪ID
}
```

### 成功响应

```json
{
  "code": "SUCCESS",
  "message": "操作成功",
  "data": {
    "id": 1,
    "name": "张三"
  },
  "traceId": "abc123"
}
```

### 错误响应

```json
{
  "code": "USER_NOT_FOUND",
  "message": "用户不存在",
  "details": [
    { "field": "userId", "message": "无效的用户ID" }
  ],
  "traceId": "abc123"
}
```

### 错误码规范

错误码必须使用枚举类 `ErrorCodeEnum`，禁止使用常量类：

```java
public enum ErrorCodeEnum {
    SUCCESS("SUCCESS", "操作成功"),
    USER_NOT_FOUND("USER_NOT_FOUND", "用户不存在"),
    INVALID_PARAMETER("INVALID_PARAMETER", "参数无效"),
    SYSTEM_ERROR("SYSTEM_ERROR", "系统错误");

    private final String code;
    private final String message;
}
```

---

## HTTP状态码

| 状态码 | 场景 | 说明 |
|-------|------|------|
| 200 | 成功 | 所有成功请求 |
| 400 | 参数错误 | 请求参数校验失败 |
| 500 | 服务器错误 | 服务端异常 |

> **注意**: 简化状态码使用，业务错误通过 `code` 字段区分，不使用 401/403/404/409 等状态码。

---

## 分页规范

### 分页请求 (POST + 请求对象)

```java
// 继承 CommonPageRequest
public class UserPageRequest extends CommonPageRequest {
    private String name;       // 筛选条件
    private String status;     // 筛选条件
}

// CommonPageRequest 基类
public class CommonPageRequest {
    private Integer page = 1;
    private Integer size = 20;
    private String sortField;
    private String sortOrder;  // ASC / DESC
}
```

### 分页接口

```
POST /api/v1/users/page
Content-Type: application/json

{
  "page": 1,
  "size": 20,
  "sortField": "createdAt",
  "sortOrder": "DESC",
  "name": "张三",
  "status": "ACTIVE"
}
```

### 分页响应

```json
{
  "code": "SUCCESS",
  "message": "操作成功",
  "data": {
    "records": [],
    "page": 1,
    "size": 20,
    "total": 100,
    "totalPages": 5
  },
  "traceId": "abc123"
}
```

---

## 版本控制

- URL路径版本：`/api/v1/`, `/api/v2/`
- 大版本号变更表示不兼容
- Header 版本：`X-API-Version: 1.0`（移动端可选）

---

## 输入校验 (强制)

所有请求对象必须使用 `@Valid` 进行校验：

```java
@PostMapping("/users")
public CommonResponse<UserResponse> createUser(
    @Valid @RequestBody CreateUserRequest request) {
    // ...
}

public class CreateUserRequest {
    @NotBlank(message = "用户名不能为空")
    @Size(max = 50, message = "用户名长度不能超过50")
    private String name;

    @NotBlank(message = "钱包地址不能为空")
    @AccountAddress  // 自定义区块链地址验证器
    private String walletAddress;
}
```

---

## API 文档 (强制)

必须使用 OpenAPI 3（Springdoc）生成 API 文档：

```java
@Operation(summary = "创建用户", description = "创建新用户账户")
@ApiResponses({
    @ApiResponse(responseCode = "200", description = "创建成功"),
    @ApiResponse(responseCode = "400", description = "参数错误")
})
@PostMapping("/users")
public CommonResponse<UserResponse> createUser(...) { }
```

---

## 移动端适配

| 考虑项 | 要求 |
|--------|------|
| 超时设置 | 合理的超时时间（建议 30s） |
| 重试机制 | 幂等接口支持重试 |
| 数据精简 | 避免返回冗余字段 |
| 压缩 | 支持 gzip 压缩 |
| 版本兼容 | 新增字段不影响旧客户端 |
