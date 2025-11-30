# API设计规范

## RESTful规范

### URL设计

```
GET    /api/v1/users          # 列表
GET    /api/v1/users/{id}     # 详情
POST   /api/v1/users          # 创建
PUT    /api/v1/users/{id}     # 全量更新
PATCH  /api/v1/users/{id}     # 部分更新
DELETE /api/v1/users/{id}     # 删除
```

### 响应格式

```json
{
  "code": "SUCCESS",
  "message": "操作成功",
  "data": { },
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

### HTTP状态码

| 状态码 | 场景 |
|-------|------|
| 200 | 成功 |
| 201 | 创建成功 |
| 400 | 请求参数错误 |
| 401 | 未认证 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 409 | 冲突 (如重复创建) |
| 500 | 服务器错误 |

## 分页规范

```
GET /api/v1/users?page=1&size=20&sort=createdAt,desc
```

```json
{
  "data": [],
  "pagination": {
    "page": 1,
    "size": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

## 版本控制

- URL路径版本：`/api/v1/`, `/api/v2/`
- 大版本号变更表示不兼容
