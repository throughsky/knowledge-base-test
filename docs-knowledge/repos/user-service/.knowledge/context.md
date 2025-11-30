# User Service 上下文

> 最后更新: 2024-01-15
> 此文件由开发者维护，定期聚合到项目知识库

## 仓库概述

用户服务是整个系统的基础领域，负责管理平台所有用户的身份、认证、授权和基本信息。几乎所有其他领域都依赖用户服务提供的身份服务。

## 架构概览

```
┌─────────────────────────────────────────────────────┐
│                   User Service                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │  Auth API   │  │  User API   │  │  RBAC API   │  │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  │
│         │                │                │          │
│  ┌──────▼────────────────▼────────────────▼──────┐  │
│  │              Domain Services                   │  │
│  │  - AuthenticationService                      │  │
│  │  - UserService                                │  │
│  │  - RoleService                                │  │
│  │  - SessionService                             │  │
│  │  - MFAService                                 │  │
│  └──────────────────────┬────────────────────────┘  │
│                         │                           │
│  ┌──────────────────────▼────────────────────────┐  │
│  │              Security Layer                    │  │
│  │  (Spring Security + JWT)                      │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
           │
           ▼
    ┌─────────────────────────────────────────────────┐
    │              All Other Services                 │
    │  (依赖用户服务进行身份验证和权限校验)          │
    └─────────────────────────────────────────────────┘
```

## 核心领域模型

### 聚合根

```java
// User - 用户
public class User {
    private UserId id;
    private String email;
    private String name;
    private UserStatus status;
    private TenantId tenantId;
    private LocalDateTime createdAt;
}

// Account - 账户
public class Account {
    private AccountId id;
    private UserId userId;
    private AccountType type;
    private String credential;       // 加密存储
    private LocalDateTime lastLoginAt;
}

// Role - 角色
public class Role {
    private RoleId id;
    private String name;
    private String description;
    private List<Permission> permissions;
}

// Session - 会话
public class Session {
    private SessionId id;
    private UserId userId;
    private String token;
    private LocalDateTime expiresAt;
    private DeviceInfo device;
}
```

## 权限模型

```
用户 1 ──── * 角色 * ──── * 权限
                              │
                              └── resource:action
                                  例: user:read, order:create
```

## 常用权限示例

| 权限 | 说明 |
|------|------|
| `user:read` | 读取用户信息 |
| `user:write` | 修改用户信息 |
| `order:create` | 创建订单 |
| `admin:*` | 管理员全部权限 |

## 用户状态流转

```
PENDING (待激活) → ACTIVE (已激活) → DEACTIVATED (已停用)
      │                  │
      └── REJECTED ──────┘
```

## 登录安全机制

```yaml
安全策略:
  - 密码加密: BCrypt (strength: 12)
  - 登录失败: 5次后锁定账户30分钟
  - JWT有效期: access_token 15分钟, refresh_token 7天
  - MFA支持: TOTP, SMS
```

## 外部依赖

| 服务 | 用途 | 接口 |
|------|------|------|
| Notification Service | 邮件/短信 | gRPC |
| Cache Service | 会话缓存 | Redis |

## 下游消费者

| 服务 | 依赖内容 | SLA |
|------|----------|-----|
| 订单服务 | 用户信息、权限校验 | 99.9% |
| 支付服务 | 用户身份验证 | 99.9% |
| API网关 | Token验证 | 99.95% |

## 发布的领域事件

| 事件 | 触发条件 | 消费者 |
|------|----------|--------|
| UserRegistered | 用户注册 | 通知服务, 分析服务 |
| UserActivated | 用户激活 | 分析服务 |
| UserLoggedIn | 用户登录 | 安全服务, 分析服务 |
| UserPasswordChanged | 密码修改 | 通知服务 |
| UserRoleAssigned | 角色分配 | 审计服务 |
| UserDeactivated | 用户停用 | 所有相关服务 |

## 数据所有权

| 数据 | 所有者 | 访问权限 |
|------|--------|----------|
| 用户基本信息 | 用户服务 | 只读共享 |
| 登录凭证 | 用户服务 | 不共享 |
| 角色权限 | 用户服务 | 只读共享 |
| 会话信息 | 用户服务 | 不共享 |

## 配置说明

```yaml
user:
  security:
    password-min-length: 8
    login-failure-limit: 5
    lockout-duration: 30m

  jwt:
    access-token-validity: 15m
    refresh-token-validity: 7d
    secret-key: ${JWT_SECRET}

  mfa:
    enabled: true
    methods: [TOTP, SMS]
```

## 已知问题和待办

- [ ] 支持更多第三方登录(Google, GitHub)
- [ ] 实现设备管理功能
- [ ] 添加登录地点异常检测

## 近期变更

### 2024-01-12
- 新增MFA支持
- 优化JWT刷新逻辑

### 2024-01-05
- 修复密码重置邮件发送延迟
- 添加登录日志审计
