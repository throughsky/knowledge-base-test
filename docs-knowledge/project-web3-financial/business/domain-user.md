# 用户领域模型

## 领域概述

用户领域负责管理平台所有用户的身份、认证、授权和基本信息，是整个系统的基础领域。

## 核心概念

### 聚合根

| 聚合根 | 定义 |
|--------|------|
| **User** | 用户实体，包含身份信息、状态、租户 |
| **Account** | 账户实体，包含登录凭证、认证信息 |
| **Role** | 角色实体，包含权限集合 |
| **Session** | 会话实体，包含令牌、设备信息 |

### 关键实体

| 实体 | 定义 |
|------|------|
| Permission | 权限定义 (resource:action) |
| DeviceInfo | 设备信息 |
| MFAConfig | 多因素认证配置 |

### 值对象

```yaml
UserStatus: PENDING → ACTIVE → DEACTIVATED | REJECTED
AccountType: EMAIL | PHONE | OAUTH
MFAMethod: TOTP | SMS | EMAIL
```

## 核心流程

### 用户注册流程
```
注册提交 → 邮箱验证 → 基础KYC → 激活 → 可操作
```

### 登录认证流程
```
凭证提交 → 密码验证 → MFA验证 → 签发JWT → 会话创建
```

## 业务规则

1. **密码策略**: 最少8位，需包含字母数字
2. **登录失败**: 5次失败锁定30分钟
3. **令牌有效期**: access_token 15分钟，refresh_token 7天
4. **权限继承**: 用户 → 角色 → 权限

## 领域事件

| 事件 | 触发 | 订阅者 |
|------|------|--------|
| UserRegistered | 用户注册 | 合规服务, 通知服务 |
| UserActivated | 用户激活 | 分析服务 |
| UserLoggedIn | 用户登录 | 安全服务, 分析服务 |
| UserPasswordChanged | 密码修改 | 通知服务 |
| UserRoleAssigned | 角色分配 | 审计服务 |
| UserDeactivated | 用户停用 | 所有相关服务 |

## 依赖关系

- **上游**: 无
- **下游**: 所有服务 (作为身份验证基础)
