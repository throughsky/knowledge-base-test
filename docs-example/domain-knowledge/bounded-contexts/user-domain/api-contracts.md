# 用户域 API 契约 (User Domain API Contracts)

**版本**: 1.0
**最后更新**: 2025-11-30
**负责人**: @用户平台团队

---

## 概述

本文档定义了用户域对外提供的所有API契约，供其他服务集成使用。

<!-- AI-CONTEXT
用户域API契约是其他服务集成的依据。
AI在生成调用用户服务的代码时应参考此契约。
所有调用都需要认证，内部API使用服务间Token。
-->

---

## 认证方式

### 公开API
```http
Authorization: Bearer <user_jwt_token>
```

### 内部API
```http
X-Service-Token: <service_to_service_token>
X-Request-Id: <correlation_id>
```

---

## 公开API

### 用户注册

```yaml
POST /api/v1/users/register
Content-Type: application/json

Request:
  email: string (required, email format)
  password: string (required, min 12 chars)
  name: string (required, 2-50 chars)

Response 201:
  id: string (uuid)
  email: string
  name: string
  status: "PENDING"
  createdAt: string (ISO 8601)

Response 400:
  error:
    code: "VALIDATION_ERROR"
    message: string
    details: array

Response 409:
  error:
    code: "EMAIL_EXISTS"
    message: "该邮箱已被注册"
```

### 用户登录

```yaml
POST /api/v1/users/login
Content-Type: application/json

Request:
  email: string (required)
  password: string (required)

Response 200:
  accessToken: string (JWT)
  refreshToken: string
  expiresIn: number (seconds)
  tokenType: "Bearer"

Response 401:
  error:
    code: "INVALID_CREDENTIALS"
    message: "邮箱或密码错误"

Response 423:
  error:
    code: "ACCOUNT_LOCKED"
    message: "账户已锁定，请稍后重试"
```

### 获取当前用户

```yaml
GET /api/v1/users/me
Authorization: Bearer <token>

Response 200:
  id: string
  email: string
  name: string
  status: string
  roles: array<string>
  createdAt: string
  updatedAt: string
```

---

## 内部API

### 获取用户详情 (内部)

```yaml
GET /internal/v1/users/{userId}
X-Service-Token: <service_token>

Response 200:
  id: string
  email: string
  name: string
  status: string
  tenantId: string
  roles: array
    - id: string
      name: string
  permissions: array<string>
  createdAt: string

Response 404:
  error:
    code: "USER_NOT_FOUND"
    message: "用户不存在"
```

### 批量获取用户 (内部)

```yaml
POST /internal/v1/users/batch
X-Service-Token: <service_token>
Content-Type: application/json

Request:
  userIds: array<string> (max 100)

Response 200:
  users: array
    - id: string
      email: string
      name: string
      status: string
  notFound: array<string>  # 未找到的userId
```

### 验证用户权限 (内部)

```yaml
POST /internal/v1/users/{userId}/permissions/check
X-Service-Token: <service_token>
Content-Type: application/json

Request:
  permission: string (e.g., "order:create")
  resource: string (optional, specific resource id)

Response 200:
  allowed: boolean
  reason: string (if denied)
```

---

## 错误码对照表

| 错误码 | HTTP状态码 | 描述 |
|--------|------------|------|
| `VALIDATION_ERROR` | 400 | 参数验证失败 |
| `INVALID_CREDENTIALS` | 401 | 认证失败 |
| `TOKEN_EXPIRED` | 401 | Token过期 |
| `FORBIDDEN` | 403 | 无权限 |
| `USER_NOT_FOUND` | 404 | 用户不存在 |
| `EMAIL_EXISTS` | 409 | 邮箱已存在 |
| `ACCOUNT_LOCKED` | 423 | 账户锁定 |
| `RATE_LIMITED` | 429 | 请求过多 |

---

## SDK 使用示例

### Java

```java
// 使用 Feign Client
@FeignClient(name = "user-service", url = "${user-service.url}")
public interface UserServiceClient {

    @GetMapping("/internal/v1/users/{userId}")
    UserDto getUserById(
        @PathVariable String userId,
        @RequestHeader("X-Service-Token") String serviceToken
    );

    @PostMapping("/internal/v1/users/batch")
    BatchUserResponse batchGetUsers(
        @RequestBody BatchUserRequest request,
        @RequestHeader("X-Service-Token") String serviceToken
    );
}
```

### TypeScript

```typescript
// 使用 axios
import axios from 'axios';

const userServiceClient = axios.create({
  baseURL: process.env.USER_SERVICE_URL,
  headers: {
    'X-Service-Token': process.env.SERVICE_TOKEN,
  },
});

export async function getUserById(userId: string): Promise<User> {
  const response = await userServiceClient.get(`/internal/v1/users/${userId}`);
  return response.data;
}
```

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| 1.0 | 2025-11-30 | 初始版本 | @用户平台团队 |
