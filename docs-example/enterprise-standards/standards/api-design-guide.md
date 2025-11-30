# API 设计指南 (API Design Guide)

**版本**: 2.0
**最后更新**: 2025-11-30
**负责人**: @架构委员会
**状态**: 已发布

---

## 概述

本文档是设计 RESTful API 的黄金标准，所有对内和对外的 API 必须遵循。

<!-- AI-CONTEXT
API设计指南是L0层强制规范。
AI在设计或生成API时必须遵循RESTful规范。
关键检查点：资源命名、HTTP方法、状态码、错误响应格式
-->

---

## 1. 资源命名 (Resource Naming)

### 基本规则

| 规则 | 正确示例 | 错误示例 |
|------|----------|----------|
| 使用复数名词 | `/users`, `/orders` | `/user`, `/order` |
| 使用 kebab-case | `/user-profiles` | `/userProfiles`, `/user_profiles` |
| 避免动词 | `/users/{id}` | `/getUser/{id}` |
| 层级关系 | `/users/{id}/orders` | `/getUserOrders` |

### 资源层级

```
GET    /users                    # 用户列表
GET    /users/{userId}           # 单个用户
POST   /users                    # 创建用户
PUT    /users/{userId}           # 完整更新用户
PATCH  /users/{userId}           # 部分更新用户
DELETE /users/{userId}           # 删除用户

GET    /users/{userId}/orders    # 用户的订单列表
POST   /users/{userId}/orders    # 为用户创建订单
```

### 特殊操作

```
# 对于无法用CRUD表示的操作，使用动词子资源
POST   /orders/{orderId}/cancel      # 取消订单
POST   /orders/{orderId}/refund      # 申请退款
POST   /users/{userId}/verify-email  # 验证邮箱

# 批量操作
POST   /users/batch                  # 批量创建
DELETE /users/batch                  # 批量删除（body中包含ID列表）
```

---

## 2. HTTP 方法 (HTTP Methods)

| 方法 | 用途 | 幂等性 | 安全性 |
|------|------|--------|--------|
| `GET` | 读取资源 | ✅ 是 | ✅ 是 |
| `POST` | 创建资源 | ❌ 否 | ❌ 否 |
| `PUT` | 完整替换资源 | ✅ 是 | ❌ 否 |
| `PATCH` | 部分更新资源 | ❌ 否 | ❌ 否 |
| `DELETE` | 删除资源 | ✅ 是 | ❌ 否 |

### 幂等性说明

```
# GET - 幂等：多次调用结果相同
GET /users/123  # 无论调用多少次，返回相同用户

# POST - 非幂等：每次调用可能创建新资源
POST /users     # 每次调用创建新用户

# PUT - 幂等：多次调用结果相同
PUT /users/123  # 无论调用多少次，用户最终状态相同

# DELETE - 幂等：多次调用结果相同
DELETE /users/123  # 第一次删除，之后返回404或204
```

---

## 3. 状态码 (Status Codes)

### 成功响应 (2xx)

| 状态码 | 含义 | 使用场景 |
|--------|------|----------|
| `200 OK` | 请求成功 | GET, PUT, PATCH 成功 |
| `201 Created` | 资源创建成功 | POST 创建成功 |
| `204 No Content` | 成功但无返回内容 | DELETE 成功 |

### 客户端错误 (4xx)

| 状态码 | 含义 | 使用场景 |
|--------|------|----------|
| `400 Bad Request` | 请求格式错误 | 参数验证失败 |
| `401 Unauthorized` | 未认证 | 缺少或无效的认证凭证 |
| `403 Forbidden` | 无权限 | 已认证但无权限访问 |
| `404 Not Found` | 资源不存在 | 请求的资源不存在 |
| `409 Conflict` | 资源冲突 | 创建重复资源 |
| `422 Unprocessable Entity` | 业务验证失败 | 业务规则校验不通过 |
| `429 Too Many Requests` | 请求过多 | 触发限流 |

### 服务端错误 (5xx)

| 状态码 | 含义 | 使用场景 |
|--------|------|----------|
| `500 Internal Server Error` | 服务器内部错误 | 未预期的异常 |
| `502 Bad Gateway` | 网关错误 | 上游服务不可用 |
| `503 Service Unavailable` | 服务不可用 | 服务维护或过载 |
| `504 Gateway Timeout` | 网关超时 | 上游服务超时 |

---

## 4. 请求与响应格式 (Request & Response Format)

### Content-Type

- 请求体和响应体必须是 `application/json`
- 文件上传使用 `multipart/form-data`

### 字段命名

- 使用 `camelCase`（前端友好）
- 或使用 `snake_case`（需在项目级别统一）

### 响应格式

```json
// 成功响应 - 单个资源
{
  "id": "user-123",
  "name": "张三",
  "email": "zhangsan@example.com",
  "createdAt": "2025-11-30T10:15:30Z"
}

// 成功响应 - 资源列表
{
  "data": [
    { "id": "user-123", "name": "张三" },
    { "id": "user-456", "name": "李四" }
  ],
  "pagination": {
    "total": 100,
    "offset": 0,
    "limit": 20,
    "hasMore": true
  }
}

// 创建成功响应
{
  "id": "user-789",
  "name": "王五",
  "createdAt": "2025-11-30T10:15:30Z"
}
```

### 错误响应格式

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "请求参数验证失败",
    "details": [
      {
        "field": "email",
        "message": "邮箱格式不正确"
      },
      {
        "field": "password",
        "message": "密码长度至少12位"
      }
    ],
    "traceId": "abc123def456"
  }
}
```

---

## 5. 分页、排序和过滤 (Pagination, Sorting & Filtering)

### 分页

```
# Offset-based 分页（适合简单场景）
GET /users?offset=0&limit=20

# Cursor-based 分页（适合大数据集、实时数据）
GET /users?cursor=eyJpZCI6MTIzfQ&limit=20
```

### 排序

```
# 单字段排序，- 表示降序
GET /users?sort=-createdAt

# 多字段排序
GET /users?sort=-createdAt,name
```

### 过滤

```
# 等值过滤
GET /users?status=active

# 范围过滤
GET /orders?createdAt[gte]=2025-01-01&createdAt[lte]=2025-12-31

# 模糊搜索
GET /users?q=张三

# 多值过滤
GET /users?status=active,pending
```

---

## 6. 版本控制 (Versioning)

### 策略：URL路径版本

```
/api/v1/users
/api/v2/users
```

### 版本迁移原则

1. 主版本变更（v1 → v2）：Breaking Changes
2. 旧版本至少维护 12 个月
3. 发布弃用通知至少提前 6 个月

### 弃用通知

```http
HTTP/1.1 200 OK
Deprecation: true
Sunset: Sat, 01 Jun 2026 00:00:00 GMT
Link: </api/v2/users>; rel="successor-version"
```

---

## 7. 安全要求 (Security)

### 认证

```http
# Bearer Token
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

### 限流

```http
# 响应头
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1635724800
```

### CORS

```yaml
# 允许的源
Access-Control-Allow-Origin: https://app.example.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Authorization, Content-Type
Access-Control-Max-Age: 86400
```

---

## 8. OpenAPI 规范示例

```yaml
openapi: 3.0.3
info:
  title: User Service API
  version: 1.0.0
  description: 用户服务API

servers:
  - url: https://api.example.com/v1

paths:
  /users:
    get:
      operationId: listUsers
      summary: 获取用户列表
      parameters:
        - name: offset
          in: query
          schema:
            type: integer
            default: 0
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
            maximum: 100
      responses:
        '200':
          description: 成功
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserListResponse'

    post:
      operationId: createUser
      summary: 创建用户
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        '201':
          description: 创建成功
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '400':
          $ref: '#/components/responses/BadRequest'
        '409':
          $ref: '#/components/responses/Conflict'

components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
          format: uuid
        name:
          type: string
        email:
          type: string
          format: email
        createdAt:
          type: string
          format: date-time

    CreateUserRequest:
      type: object
      required:
        - name
        - email
        - password
      properties:
        name:
          type: string
          minLength: 2
          maxLength: 50
        email:
          type: string
          format: email
        password:
          type: string
          minLength: 12

  responses:
    BadRequest:
      description: 请求参数错误
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
```

---

## API 设计检查清单

- [ ] 资源命名使用复数名词
- [ ] HTTP方法使用正确
- [ ] 状态码符合语义
- [ ] 错误响应格式统一
- [ ] 分页参数已定义
- [ ] 版本控制已配置
- [ ] 认证机制已实现
- [ ] OpenAPI规范已编写
- [ ] 限流策略已配置

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| 2.0 | 2025-11-30 | 增加AI上下文、OpenAPI示例 | @架构委员会 |
| 1.0 | 2025-01-01 | 初始版本 | @架构委员会 |
