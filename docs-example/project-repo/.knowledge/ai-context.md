# AI 上下文摘要 (AI Context Summary)

**自动生成**: 基于 inheritance.yaml 配置
**最后更新**: 2025-11-30

---

## 概述

本文档是为AI编码助手准备的上下文摘要，聚合了各层级知识库的关键信息。

<!-- AI-CONTEXT
这是AI理解项目的核心入口文档。
包含了从L0到L3的关键规范和约定。
AI在进行任何代码生成或分析时应参考此文档。
-->

---

## 1. 企业规范摘要 (L0)

### 1.1 核心架构原则

| 原则 | 要求 |
|------|------|
| **12-Factor** | 无状态进程、环境变量配置、结构化日志 |
| **DDD** | 限界上下文、通用语言、聚合根 |
| **API-First** | OpenAPI契约先行、Mock并行开发 |
| **可观测性** | 日志/指标/追踪三支柱 |
| **安全内建** | OAuth2.0、最小权限、输入验证 |

### 1.2 技术雷达要点

**ADOPT (推荐使用)**:
- Java 17/21, TypeScript 5.0+
- Spring Boot 3.2, React 18, Next.js 14
- PostgreSQL 15, Redis 7
- Kubernetes, Docker, GitHub Actions

**HOLD (避免使用)**:
- Java 8/11, Maven, JavaScript(无类型)
- jQuery, Moment.js

---

## 2. 领域上下文摘要 (L1)

### 2.1 用户域 (User Domain)

**核心概念**:
- **User**: 平台用户，聚合根
- **Role**: 权限角色
- **Permission**: 具体权限
- **Session**: 登录会话

**主要API**:
```
POST /api/v1/users/register  # 用户注册
POST /api/v1/users/login     # 用户登录
GET  /api/v1/users/me        # 获取当前用户
GET  /internal/v1/users/{id} # 内部接口：获取用户
```

### 2.2 订单域 (Order Domain)

**核心概念**:
- **Order**: 订单，聚合根
- **OrderItem**: 订单项
- **OrderStatus**: 订单状态枚举

**状态流转**:
```
DRAFT → PENDING_PAYMENT → PAID → PROCESSING → SHIPPED → DELIVERED → COMPLETED
                 ↓           ↓        ↓           ↓
              CANCELLED   CANCELLED  CANCELLED  REFUNDED
```

---

## 3. 项目规范摘要 (L2)

### 3.1 技术栈

```yaml
后端:
  语言: Java 17
  框架: Spring Boot 3.2 + MyBatis
  构建: Gradle 8.14+
  数据库: PostgreSQL 15
  缓存: Redis 7

前端:
  语言: TypeScript 5.0+
  框架: React 18 + Next.js 14
  包管理: pnpm 8+
```

### 3.2 代码分层

```
Controller → Service → Repository → Database
     ↓           ↓          ↓
  参数校验    业务逻辑    数据访问
  响应封装    事务管理    SQL执行
```

**禁止事项**:
- Controller层包含业务逻辑
- Service层处理HTTP对象
- Repository层包含业务逻辑

### 3.3 包结构

```
com.company.ecommerce.{service}/
├── config/         # 配置类
├── controller/     # REST控制器
├── service/        # 业务服务
├── repository/     # 数据访问
├── entity/         # 数据库实体
├── mapper/         # MyBatis Mapper
├── vo/             # 值对象 (request/response)
├── exception/      # 异常类
└── event/          # 领域事件
```

---

## 4. 编码规范摘要 (L3)

### 4.1 命名约定

| 类型 | 规范 | 示例 |
|------|------|------|
| 类 | UpperCamelCase + 后缀 | `UserController`, `UserServiceImpl` |
| 方法 | lowerCamelCase + 动词 | `createUser()`, `getUserById()` |
| 变量 | lowerCamelCase | `userName`, `orderCount` |
| 常量 | UPPER_SNAKE_CASE | `MAX_RETRIES` |

### 4.2 异常处理

```java
// 业务异常格式
throw new BusinessException("USER_NOT_FOUND", "用户不存在");

// 异常码前缀
// USER_xxx, ORDER_xxx, PAYMENT_xxx, COMMON_xxx
```

### 4.3 日志规范

```java
// 使用占位符，包含上下文
log.info("User created, userId={}, email={}", userId, email);
log.error("Failed to create order, request={}", request, e);
```

---

## 5. AI协作要点

### 5.1 代码生成原则

1. **清晰性**: 明确表达意图和需求
2. **上下文**: 提供技术栈、规范、约束
3. **结构化**: 使用明确格式组织需求
4. **分步**: 复杂任务分解为多个步骤
5. **示例**: 提供期望输出的示例

### 5.2 质量检查清单

- [ ] 符合项目编码规范
- [ ] 遵循分层架构
- [ ] 异常处理完善
- [ ] 日志记录合理
- [ ] 无硬编码配置
- [ ] 包含必要注释
- [ ] 有对应测试用例

### 5.3 禁止事项

- ❌ 使用HOLD列表中的技术
- ❌ 违反分层架构原则
- ❌ 硬编码敏感信息
- ❌ 忽略异常处理
- ❌ 缺少输入验证

---

## 6. 快速参考

### 6.1 常用文档链接

| 文档 | 路径 |
|------|------|
| 技术栈规范 | [./technology/tech-stack.md](./technology/tech-stack.md) |
| 编码约定 | [./implementation/coding/coding-conventions.md](./implementation/coding/coding-conventions.md) |
| SDD模板 | [./ai-collaboration/sdd-template.md](./ai-collaboration/sdd-template.md) |
| Prompt模板 | [./ai-collaboration/prompt-library/](./ai-collaboration/prompt-library/) |

### 6.2 错误码速查

| 前缀 | 模块 | 示例 |
|------|------|------|
| USER_ | 用户 | USER_NOT_FOUND, USER_EMAIL_EXISTS |
| ORDER_ | 订单 | ORDER_NOT_FOUND, ORDER_CANCELLED |
| PAYMENT_ | 支付 | PAYMENT_FAILED, PAYMENT_TIMEOUT |
| COMMON_ | 通用 | COMMON_VALIDATION_ERROR |

---

## 变更历史

| 日期 | 变更 | 作者 |
|------|------|------|
| 2025-11-30 | 自动生成 | 系统 |
