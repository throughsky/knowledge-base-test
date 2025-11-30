# 五层知识架构示例 (5-Layer Knowledge Architecture Example)

本目录包含了完整的五层知识架构示例，用于指导知识库的设计和实施。

## 架构概览

```
┌─────────────────────────────────────────────────────────────────┐
│                    L0: 企业技术宪法层                            │
│         (Enterprise Constitution - 全局强制, 跨组织统一)          │
│         → enterprise-standards/                                  │
├─────────────────────────────────────────────────────────────────┤
│                    L1: 领域知识层                                │
│         (Domain Knowledge - 跨仓库共享, 业务边界定义)             │
│         → domain-knowledge/                                      │
├─────────────────────────────────────────────────────────────────┤
│                    L2: 项目基座层                                │
│         (Project Foundation - 仓库级规范, 架构决策)               │
│         → project-repo/.knowledge/ (架构、技术选型)              │
├─────────────────────────────────────────────────────────────────┤
│                    L3: 实施执行层                                │
│         (Implementation - 开发规范, AI协作, 技术文档)             │
│         → project-repo/.knowledge/ (编码、测试、部署、AI协作)     │
├─────────────────────────────────────────────────────────────────┤
│                    L4: 知识演进层                                │
│         (Evolution - 案例沉淀, 培训体系, 持续改进)                │
│         → project-repo/.knowledge/evolution/                     │
└─────────────────────────────────────────────────────────────────┘
```

## 目录结构

```
docs-example/
├── README.md                          # 本文件
│
├── enterprise-standards/              # L0: 企业技术宪法层
│   ├── constitution/                  # 核心规范
│   │   ├── architecture-principles.md # 架构原则
│   │   ├── security-baseline.md       # 安全基线
│   │   └── compliance-requirements.md # 合规要求
│   ├── standards/                     # 编码规范
│   │   ├── coding-standards/
│   │   │   ├── java-standards.md
│   │   │   └── typescript-standards.md
│   │   └── api-design-guide.md
│   ├── technology-radar/              # 技术雷达
│   │   ├── adopt.md
│   │   ├── trial.md
│   │   └── hold.md
│   └── governance/                    # 治理流程
│       └── review-process.md
│
├── domain-knowledge/                  # L1: 领域知识层
│   ├── bounded-contexts/              # 限界上下文
│   │   ├── user-domain/
│   │   │   ├── domain-model.md
│   │   │   └── api-contracts.md
│   │   ├── order-domain/
│   │   │   └── domain-model.md
│   │   └── payment-domain/
│   ├── service-mesh/                  # 服务目录
│   │   └── service-catalog.md
│   └── glossary/                      # 术语词典
│       └── enterprise-glossary.md
│
└── project-repo/                      # 项目仓库示例
    ├── CLAUDE.md                      # AI助手入口
    └── .knowledge/                    # L2-L4: 项目知识库
        ├── ai-context.md              # AI上下文摘要
        ├── inheritance.yaml           # 继承配置
        ├── project-charter.md         # 项目章程
        ├── glossary.md                # 项目术语
        │
        ├── architecture/              # L2: 架构设计
        │   ├── system-architecture.md
        │   ├── layer-summary.md
        │   └── adr/
        │       ├── ADR-001-microservices-architecture.md
        │       └── ADR-002-database-selection.md
        │
        ├── technology/                # L2: 技术规范
        │   └── tech-stack.md
        │
        ├── implementation/            # L3: 实施规范
        │   ├── coding/
        │   │   ├── coding-conventions.md
        │   │   └── git-workflow.md
        │   ├── testing/
        │   │   └── test-strategy.md
        │   └── deployment/
        │       └── deployment-guide.md
        │
        ├── ai-collaboration/          # L3: AI协作
        │   ├── sdd-template.md
        │   ├── ai-principles.md
        │   └── prompt-library/
        │       └── code-generation.md
        │
        └── evolution/                 # L4: 知识演进
            ├── cases/
            │   └── architecture-reviews/
            │       └── case-001-payment-refactoring.md
            ├── lessons-learned/
            │   ├── what-worked.md
            │   └── what-didnt.md
            ├── training/
            │   └── onboarding/
            │       └── developer-onboarding.md
            ├── metrics/
            │   └── quality-metrics.md
            └── continuous-improvement/
                └── improvement-backlog.md
```

## 各层级说明

### L0: 企业技术宪法层

**范围**: 跨组织、跨项目的全局规范

**内容**:
- 架构原则 (12-Factor, DDD, API-First)
- 安全基线和合规要求
- 编码规范 (按语言)
- API设计指南
- 技术雷达 (Adopt/Trial/Hold)
- 技术评审流程

**特点**: 强制执行，所有项目必须遵循

---

### L1: 领域知识层

**范围**: 跨仓库共享的业务领域知识

**内容**:
- 限界上下文定义
- 领域模型和通用语言
- API契约和领域事件
- 服务目录
- 企业术语词典

**特点**: 打破仓库边界，定义业务边界

---

### L2: 项目基座层

**范围**: 单个项目/仓库的架构和决策

**内容**:
- 项目章程
- 系统架构文档
- 代码分层定义
- 架构决策记录 (ADR)
- 技术栈规范
- 项目术语词典

**特点**: 继承L0规范，定义项目特有规则

---

### L3: 实施执行层

**范围**: 日常开发所需的规范和指南

**内容**:
- 编码约定
- Git工作流
- 测试策略
- 部署指南
- AI协作原则
- SDD模板和Prompt模板

**特点**: 开发人员日常参考

---

### L4: 知识演进层

**范围**: 知识沉淀和持续改进

**内容**:
- 架构评审案例
- 经验教训 (成功/失败)
- 培训资料
- 质量指标
- 改进待办

**特点**: 持续积累，促进团队成长

---

## 关键创新点

### 1. 跨仓库继承机制

通过 `inheritance.yaml` 实现：
- 继承企业规范 (L0)
- 引用领域知识 (L1)
- 本地覆盖和扩展

### 2. AI上下文自动聚合

`ai-context.md` 聚合各层关键信息：
- AI编码助手的核心参考
- 自动生成，保持最新

### 3. 依赖仓库知识传递

配置依赖仓库，自动获取相关上下文：
- 服务间调用时了解对方契约
- 跨团队协作时共享领域知识

---

## 使用指南

### 新项目接入

1. 复制 `project-repo/.knowledge/` 结构到你的项目
2. 修改 `inheritance.yaml` 配置继承关系
3. 更新 `CLAUDE.md` 为AI助手入口
4. 根据项目情况填充各层文档

### AI协作

1. AI助手从 `CLAUDE.md` 开始
2. 首先阅读 `ai-context.md` 了解项目
3. 根据任务类型参考相应文档
4. 使用 `sdd-template.md` 进行功能设计
5. 使用 `prompt-library/` 中的模板生成代码

### 知识维护

1. 代码变更时同步更新文档
2. 定期Review文档准确性
3. 持续沉淀案例和教训
4. 跟踪质量指标和改进项

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| 1.0 | 2025-11-30 | 初始版本 | @架构师 |
