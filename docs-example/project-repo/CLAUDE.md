# Claude Code 入口 (AI Assistant Entry Point)

本项目使用五层知识架构，AI助手应从此文件开始了解项目。

## 快速导航

### 核心文档

| 优先级 | 文档 | 用途 |
|--------|------|------|
| ⭐⭐⭐ | [AI上下文摘要](.knowledge/ai-context.md) | AI理解项目的核心入口 |
| ⭐⭐⭐ | [技术栈规范](.knowledge/technology/tech-stack.md) | 了解技术选型 |
| ⭐⭐ | [系统架构](.knowledge/architecture/system-architecture.md) | 了解整体架构 |
| ⭐⭐ | [编码约定](.knowledge/implementation/coding/coding-conventions.md) | 编码规范 |
| ⭐ | [AI协作原则](.knowledge/ai-collaboration/ai-principles.md) | AI协作指南 |

### 开发相关

- **代码生成**: 使用 [SDD模板](.knowledge/ai-collaboration/sdd-template.md) 和 [Prompt模板](.knowledge/ai-collaboration/prompt-library/)
- **代码审查**: 参考 [编码约定](.knowledge/implementation/coding/coding-conventions.md)
- **测试编写**: 参考 [测试策略](.knowledge/implementation/testing/test-strategy.md)

## 项目概述

**项目**: ECP电商平台 (Example E-Commerce Platform)

**技术栈**:
- 后端: Java 17 + Spring Boot 3.2 + MyBatis + PostgreSQL
- 前端: React 18 + TypeScript + Next.js 14
- 基础设施: Kubernetes + Docker + GitHub Actions

**架构**: 微服务架构，包含用户服务、订单服务、商品服务、支付服务

## AI协作规则

### 代码生成时必须

1. ✅ 遵循项目编码规范
2. ✅ 使用指定的技术栈
3. ✅ 遵循分层架构
4. ✅ 包含必要的异常处理
5. ✅ 添加适当的日志记录

### 禁止事项

1. ❌ 使用Maven (必须用Gradle)
2. ❌ 使用JavaScript无类型 (必须用TypeScript)
3. ❌ 在Controller层写业务逻辑
4. ❌ 硬编码配置信息
5. ❌ 忽略输入验证

## 知识库结构

```
.knowledge/
├── ai-context.md           # AI上下文摘要（首先阅读）
├── inheritance.yaml        # 继承配置
├── project-charter.md      # 项目章程
├── glossary.md             # 术语词典
├── architecture/           # 架构设计 (L2)
├── technology/             # 技术规范 (L2)
├── implementation/         # 实施规范 (L3)
├── ai-collaboration/       # AI协作 (L3)
└── evolution/              # 知识演进 (L4)
```

## 相关链接

- 企业规范: `../enterprise-standards/` (L0)
- 领域知识: `../domain-knowledge/` (L1)
