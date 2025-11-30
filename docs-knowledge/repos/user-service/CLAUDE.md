# User Service

> 用户服务 - 负责用户身份、认证、授权和基本信息管理

## 快速导航

- 项目架构: 参考 `../../project-web3-financial/ARCHITECTURE.md`
- 服务目录: 参考 `../../project-web3-financial/architecture/service-catalog.md`
- 本仓库上下文: `.knowledge/context.md`

## 核心职责

1. **用户注册登录**: 账户创建和身份验证
2. **密码管理**: 密码重置和修改
3. **角色权限**: RBAC权限管理
4. **会话管理**: JWT令牌管理

## 关键约束

- 密码加密存储(BCrypt)
- 登录失败次数限制
- JWT令牌有效期管理
- 敏感数据不共享

## 技术栈

- Java 17 + Spring Boot 3.x
- PostgreSQL (业务数据)
- Redis (会话缓存)
- Spring Security

## 本地开发

```bash
docker-compose up -d postgres redis
./gradlew bootRun
./gradlew test
```

## 主要入口

| 模块 | 路径 | 说明 |
|------|------|------|
| 认证模块 | `src/main/java/.../auth/` | 登录认证 |
| 用户模块 | `src/main/java/.../user/` | 用户管理 |
| 角色权限 | `src/main/java/.../rbac/` | RBAC |
| 会话管理 | `src/main/java/.../session/` | JWT |
