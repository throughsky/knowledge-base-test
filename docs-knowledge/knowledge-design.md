# 项目级知识库架构设计

**版本**: 2.0
**创建日期**: 2025-11-30
**作者**: 架构团队
**状态**: 设计中

---

## 1. 设计目标

### 1.1 核心痛点

**现状问题**:

- 大型项目包含多个仓库，知识分散在各处
- 业务知识与技术知识混杂，难以查找
- 仓库级知识库过于复杂，维护成本高
- 新人难以快速理解整个项目结构和业务逻辑

**设计目标**:

- 简化仓库级知识库，降低维护成本，使用最简单的方式维护关键文档，例如context.md和code-drivered目录的codewiki。
- 集中管理项目级业务知识和架构决策
- 支持AI自动聚合和更新
- 建立清晰的信息流向：仓库 → 项目 → 企业
- 级别定义是只例如稳定币是一个项目，稳定币是一个项目级，稳定币下面的前端，后台，审批，gateway等是多个仓库级别。

### 1.2 架构原则

1. **仓库知识库做减法**：只保留该仓库特有的信息，自动生成。与speckit集成，以及有summary实现功能，结合codewiki完成仓库级知识的维护。其他中间文档都尽可能的保留，遵循各自要求即可，需要的时候各个仓库写代码的时候主动引用，为了保留更多的细节。
2. **项目知识库做加法**：集中管理跨仓库的业务和架构知识。
3. **AI做聚合**：定期从仓库向上聚合，减少人工维护
4. **代码衍生自动化**：技术细节让AI从代码生成

---

## 2. 整体架构

### 2.1 核心理念

**自底向上生成，自顶向下继承**

```
┌─────────────────────────────────────────────────────────────┐
│                    项目级知识库 (Project)                    │
│                   (多仓库聚合，AI定期总结)                    │
│                                                             │
│  业务知识 + 领域模型 + 服务拓扑 + 架构决策 + 技术规范         │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │ AI 定期聚合
          ┌───────────────────┼───────────────────┐
          │                   │                   │
┌─────────▼─────────┐ ┌───────▼───────┐ ┌────────▼────────┐
│   仓库A (精简)     │ │   仓库B       │ │    仓库C        │
│  CLAUDE.md        │ │  CLAUDE.md    │ │   CLAUDE.md     │
│  .knowledge/      │ │  .knowledge/  │ │   .knowledge/   │
│   └── context.md  │ │   └── ...     │ │    └── ...      │
└───────────────────┘ └───────────────┘ └─────────────────┘
```

### 2.2 层级定义

| 层级         | 名称       | 存储位置      | 内容                           | 维护方式                    |
| ------------ | ---------- | ------------- | ------------------------------ | --------------------------- |
| **L0** | 企业宪法   | 独立仓库      | 编码规范、安全基线、技术雷达   | 架构委员会                  |
| **L1** | 项目知识库 | 独立仓库/目录 | 业务领域 + 架构决策 + 服务目录 | **AI聚合 + 人工审核** |
| **L2** | 仓库知识库 | 各Git仓库     | **精简的仓库上下文**     | 开发者 + AI生成             |

### 2.3 三层架构图

```
┌─────────────────────────────────────────────────────────────┐
│                    企业级 (L0)                              │
│              (Enterprise Standards)                         │
│   ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│   │  技术宪法     │ │  编码规范     │ │  技术雷达     │       │
│   └──────────────┘ └──────────────┘ └──────────────┘       │
├─────────────────────────────────────────────────────────────┤
│                    项目级 (L1)                              │
│              (Project Knowledge)                            │
│   ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│   │  业务领域     │ │  服务目录     │ │  架构决策     │       │
│   │  领域模型     │ │  依赖拓扑     │ │  数据流图     │       │
│   └──────────────┘ └──────────────┘ └──────────────┘       │
├─────────────────────────────────────────────────────────────┤
│                    仓库级 (L2)                              │
│              (Repository Context)                           │
│   ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│   │  仓库A        │ │  仓库B        │ │  仓库C        │       │
│   │  context.md  │ │  context.md  │ │  context.md  │       │
│   └──────────────┘ └──────────────┘ └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

### 2.4 信息流向

```
仓库级 (L2)  ←──────  开发者维护
    │                  ▲
    │ AI定期聚合       │ 向下继承
    ▼                  │
项目级 (L1)  ──────→  AI聚合 + 人工审核
    │                  ▲
    │ 向上汇总         │ 向下继承
    ▼                  │
企业级 (L0)  ←──────  架构委员会
```

---

## 3. 企业级知识库 (L0)

### 3.1 职责

- 企业级强制规范
- 跨项目统一标准
- 技术选型指导

### 3.2 目录结构

```
enterprise-standards/
├── constitution/               # 技术宪法
│   ├── architecture-principles.md
│   ├── security-baseline.md
│   └── compliance-requirements.md
├── standards/                  # 编码规范
│   ├── coding-standards/
│   ├── api-design-guide.md
│   └── testing-standards.md
└── technology-radar/           # 技术雷达
    ├── adopt.md
    ├── trial.md
    ├── assess.md
    └── hold.md
```

---

## 4. 项目级知识库 (L1)

### 4.1 职责

- 跨仓库业务知识
- 项目级架构决策
- 服务间依赖关系
- AI定期聚合各仓库信息

### 4.2 目录结构

```
project-knowledge/
├── README.md                   # 项目总览
├── BUSINESS.md                 # 业务知识入口
├── ARCHITECTURE.md             # 架构知识入口
│
├── business/                   # 业务领域知识
│   ├── domain-model.md        # 领域模型
│   ├── glossary.md            # 术语词典
│   ├── workflows/             # 业务流程
│   │   ├── user-registration.md
│   │   └── order-lifecycle.md
│   └── rules.md               # 业务规则
│
├── architecture/               # 架构知识
│   ├── service-catalog.md     # 服务目录
│   ├── repo-map.md           # 仓库地图
│   ├── data-flow.md          # 数据流
│   ├── tech-stack.md         # 技术栈
│   └── decisions/            # 架构决策记录
│       ├── ADR-001-microservices.md
│       └── ADR-002-event-driven.md
│
├── standards/                  # 项目规范
│   ├── coding.md              # 编码规范 (可继承L0)
│   ├── api.md                 # API规范
│   └── testing.md             # 测试规范
│
└── aggregated/                 # AI聚合区 (自动生成)
    ├── last-updated.json      # 更新记录
    ├── repo-summaries/        # 各仓库摘要
    │   ├── user-service.md
    │   ├── order-service.md
    │   └── payment-service.md
    ├── service-topology.md    # 服务拓扑
    ├── cross-repo-patterns.md # 跨仓库模式
    └── improvement-suggestions.md # 改进建议
```

### 4.3 AI聚合机制

#### 方案选型

| 方案                    | 优点                     | 缺点                                 | 推荐度     |
| ----------------------- | ------------------------ | ------------------------------------ | ---------- |
| **Git Subtree**   | 子仓库可直接访问项目知识 | 增加子仓库复杂度和体积，同步负担分散 | ⭐⭐       |
| **Git Submodule** | 引用而非复制，体积小     | 需要额外git命令，对新手不友好        | ⭐⭐⭐     |
| **AI主动拉取**    | 子仓库零负担，智能分析   | 需要CI/CD配置                        | ⭐⭐⭐⭐⭐ |

**推荐方案：AI主动拉取**

```
┌────────────────────────────────────────────────────────────────┐
│                      AI主动拉取架构                             │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│   子仓库 (保持简单)              知识库仓库 (集中管理)          │
│   ┌──────────────┐              ┌──────────────────────┐      │
│   │ user-service │              │  docs-knowledge/     │      │
│   │ ├─ src/      │              │  ├─ aggregation/     │      │
│   │ ├─ CLAUDE.md │ ◀──引用────  │  │  ├─ config.yaml  │      │
│   │ └─ .knowledge│              │  │  └─ scripts/     │      │
│   │    └─context │ ───拉取───▶  │  ├─ repos/          │      │
│   └──────────────┘              │  │  └─ (聚合副本)   │      │
│                                 │  └─ project-xxx/    │      │
│   ┌──────────────┐              │     ├─ ARCH.md     │      │
│   │lending-service│              │     └─ BUSINESS.md │      │
│   │ └─ .knowledge│              └──────────────────────┘      │
│   │    └─context │ ───拉取───▶           │                    │
│   └──────────────┘              ┌────────▼────────┐          │
│         ...                     │   AI 聚合系统   │          │
│                                 │  ┌────────────┐ │          │
│                                 │  │ 1.收集变更 │ │          │
│                                 │  │ 2.分析影响 │ │          │
│                                 │  │ 3.更新文档 │ │          │
│                                 │  │ 4.生成报告 │ │          │
│                                 │  └────────────┘ │          │
│                                 └─────────────────┘          │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

#### 聚合目录结构

```
docs-knowledge/
├── aggregation/
│   ├── README.md               # 聚合机制说明
│   ├── config.yaml             # 聚合配置
│   ├── github-actions-example.yaml  # CI/CD配置
│   ├── scripts/
│   │   ├── aggregate.sh        # 聚合主脚本
│   │   └── prompts/            # AI提示词
│   │       ├── analyze-changes.md
│   │       └── update-docs.md
│   ├── cache/                  # 上次聚合快照 (gitignore)
│   └── reports/                # 聚合报告
│       └── YYYY-MM-DD.md
└── project-xxx/                # 项目知识库
```

#### 聚合配置

```yaml
# aggregation/config.yaml
version: "2.0"

# 聚合调度
schedule:
  type: weekly              # daily | weekly | manual
  day: monday
  time: "02:00"             # UTC时间

# 仓库源配置
repositories:
  github_org:
    org: "your-org"
    repos:
      - name: "user-service"
        knowledge_path: ".knowledge/context.md"
      - name: "bridge-service"
        knowledge_path: ".knowledge/context.md"
      # ... 更多仓库

  # 本地开发环境
  local_paths:
    enabled: true
    base_path: "../repos"

# 聚合任务
tasks:
  collect_changes:
    description: "收集各仓库 context.md 的变更"
    output: "aggregation/cache/changes.json"

  analyze_impact:
    description: "分析变更对项目文档的影响"
    prompt: "aggregation/scripts/prompts/analyze-changes.md"

  update_docs:
    description: "更新项目级文档"
    targets:
      - "project-xxx/ARCHITECTURE.md"
      - "project-xxx/BUSINESS.md"
    mode: "suggest"  # suggest | auto

# 审核配置
review:
  auto_merge:
    enabled: true
    conditions:
      - "only_additions"
      - "confidence_score >= 0.9"

  manual_review:
    reviewers: ["@architect", "@tech-lead"]
    required_for:
      - "architecture/*"
      - "business/domain-*.md"

# AI 配置
ai:
  provider: "anthropic"
  model: "claude-sonnet-4-20250514"
  temperature: 0.3
```

#### 触发方式

**1. 定时触发 (推荐)**

```yaml
# GitHub Actions
on:
  schedule:
    - cron: '0 2 * * 1'  # 每周一凌晨2点
```

**2. Webhook触发**

```yaml
# 子仓库 .knowledge 变更时触发
on:
  push:
    paths: ['.knowledge/**']
```

**3. 手动触发**

```bash
./aggregation/scripts/aggregate.sh --mode full
```

#### 聚合流程

```
1. 收集阶段
   ├── 克隆/拉取各子仓库
   ├── 读取 .knowledge/context.md
   ├── 与上次快照对比，识别变更
   └── 生成变更列表

2. 分析阶段 (AI驱动)
   ├── 变更分类 (API/领域模型/架构/配置)
   ├── 影响分析 (哪些项目文档需更新)
   ├── 冲突检测 (多仓库修改同一概念)
   └── 生成分析报告

3. 更新阶段 (AI驱动)
   ├── 根据分析结果更新项目文档
   ├── 保持文档风格一致
   ├── 标注变更来源
   └── 验证交叉引用

4. 审核阶段
   ├── 自动创建 PR
   ├── 低风险变更自动合并
   ├── 高风险变更人工审核
   └── 发送通知 (Slack/邮件)
```

#### 聚合产出

每次聚合产出：

| 产出               | 说明                       | 位置                                  |
| ------------------ | -------------------------- | ------------------------------------- |
| **变更报告** | 各仓库变更摘要、影响分析   | `aggregation/reports/YYYY-MM-DD.md` |
| **更新PR**   | 包含文档变更、reviewer建议 | GitHub PR                             |
| **通知**     | Slack/邮件通知             | 配置的通道                            |

#### AI提示词设计

**变更分析提示词** (`prompts/analyze-changes.md`):

- 输入：各仓库 context.md 的 diff
- 任务：分类变更、评估影响、检测冲突
- 输出：结构化分析报告 (YAML格式)

**文档更新提示词** (`prompts/update-docs.md`):

- 输入：变更分析结果、当前文档
- 任务：生成最小化更新、保持风格一致
- 输出：更新建议 (包含置信度和审核标记)

---

## 5. 仓库级知识库 (L2) - 精简版

### 5.1 设计原则

- **极简原则**：只保留仓库特有信息
- **继承原则**：通用规范从上层继承
- **聚焦原则**：专注当前仓库的核心信息

### 5.2 目录结构

```
{repo}/
├── CLAUDE.md                    # AI入口 (必须)
└── .knowledge/
    ├── context.md               # 仓库上下文 (必须，1个文件)
    ├── decisions.md             # 重要决策记录 (可选)
    └── code-derived/            # AI生成 (可选，自动生成)
        ├── overview.md          # 代码概览
        └── module-docs/         # 模块文档
```

### 5.3 context.md 模板

```markdown
# 仓库上下文: {repo-name}

## 1. 仓库定位
- **职责**: [一句话描述核心职责]
- **所属项目**: [项目名]
- **上游依赖**: [依赖的仓库/服务]
- **下游消费者**: [谁调用我]

## 2. 技术栈
- 语言: Java 17
- 框架: Spring Boot 3.2
- 数据库: PostgreSQL 14
- 特殊依赖: Redis, RabbitMQ

## 3. 核心模块
| 模块 | 职责 | 主要类 |
|------|------|--------|
| user-api | 用户接口层 | UserController |
| user-service | 业务逻辑层 | UserService |
| user-repository | 数据访问层 | UserRepository |

## 4. 本仓库特有规则
- 用户ID必须使用雪花算法生成
- 密码必须加密存储，使用 bcrypt
- 所有接口需要支持幂等性

## 5. 快速链接
- 项目知识库: [链接]
- API文档: [链接]
- 数据库ER图: [链接]
```

### 5.4 CLAUDE.md 精简版

```markdown
# Claude Code 入口

## 快速开始
1. 先阅读 [.knowledge/context.md] 了解本仓库
2. 项目知识库: {project-knowledge-url}

## 继承的规范
- ✅ 遵循项目编码规范
- ✅ 使用 Spring Boot 3.2
- ✅ 遵循 RESTful API 设计

## 本仓库规则
1. 所有用户ID使用雪花算法
2. 密码必须加密存储
3. 接口需要幂等性设计

## 快速导航
- 核心业务: src/main/java/com/xxx/user/service/
- API接口: src/main/java/com/xxx/user/controller/
- 数据模型: src/main/java/com/xxx/user/entity/
```

---

## 6. 信息继承机制

### 6.1 继承配置 (project-inheritance.yaml)

```yaml
# 项目级继承配置
version: "2.0"

# 继承企业规范
enterprise:
  source: "git@github.com:company/enterprise-standards.git"
  ref: "v2.1"
  paths:
    - "standards/coding-standards/java.md"
    - "standards/api-design.md"
    - "technology-radar/adopt.md"

# 项目特有覆盖
project_overrides:
  - source: "standards/coding-standards/java.md"
    target: "standards/coding.md"
    reason: "项目使用Spring Boot而非原生Java"

# 仓库列表
repositories:
  - name: "user-service"
    path: "services/user-service"
    type: "microservice"
    domain: "用户域"
  - name: "order-service"
    path: "services/order-service"
    type: "microservice"
    domain: "订单域"

# AI上下文聚合
ai_context:
  sources:
    - "business/domain-model.md"
    - "architecture/service-catalog.md"
    - "standards/coding.md"
  output: "ai-context-summary.md"
```

### 6.2 双向继承

```
向下继承 (Downward):
企业规范 → 项目规范 → 仓库规则

向上聚合 (Upward):
仓库信息 → 项目知识库 → 企业洞察
```

---

## 7. AI协作设计

### 7.1 AI上下文分层

#### 查询优先级

```
1. 当前仓库 context.md (最高优先级)
2. 项目知识库相关域
3. 企业级编码规范
4. 通用最佳实践 (最低优先级)
```

#### 上下文聚合示例

```markdown
# AI 上下文摘要 (自动生成)

## 企业规范 (L0)
- Java 17 + Spring Boot 3.2
- RESTful API 设计原则
- 12-Factor App 方法论

## 项目知识 (L1)
### 用户域
- 用户生命周期: 注册→认证→授权→注销
- 用户状态: 正常、冻结、注销
- 用户类型: 个人、企业

## 仓库知识 (L2)
### 当前仓库: user-service
- 职责: 用户管理核心服务
- 特殊规则: 用户ID使用雪花算法
- 依赖: MySQL, Redis, RabbitMQ
```

### 7.2 Prompt模板

#### 代码生成模板

```markdown
## 任务
根据以下上下文生成用户注册功能的代码

## 上下文
{ai-context-summary}

## 当前仓库
- 类型: 微服务
- 框架: Spring Boot 3.2
- 已有模块: user-api, user-service, user-repository

## 需求
实现用户邮箱注册功能，包含：
1. 邮箱格式验证
2. 密码强度检查
3. 发送验证邮件
4. 防重复注册

## 约束
1. 遵循项目RESTful API规范
2. 使用雪花算法生成用户ID
3. 密码使用bcrypt加密
4. 所有接口需要幂等性
```

---

## 8. 实施指南

### 8.1 迁移策略

#### 阶段一：试点 (2周)

```
1. 选择1个核心项目 (3-5个仓库)
2. 创建项目知识库
3. 精简各仓库知识库到3个文件
4. 配置AI聚合
5. 验证效果
```

#### 阶段二：推广 (4周)

```
1. 扩展到更多项目
2. 完善项目知识库模板
3. 建立定期聚合机制
4. 培训开发者
```

#### 阶段三：优化 (持续)

```
1. 根据反馈优化模板
2. 提高AI聚合准确性
3. 建立质量度量
4. 扩展到更多场景
```

### 8.2 工具支持

#### 初始化工具

```bash
# 初始化项目知识库
knowledge-init --type project --name order-system

# 初始化仓库知识库
knowledge-init --type repo --project order-system

# 聚合项目知识
knowledge-aggregate --project order-system
```

#### 检查工具

```bash
# 检查知识库完整性
knowledge-check --project order-system

# 生成AI上下文
knowledge-context --repo user-service
```

---

## 9. 质量保障

### 9.1 质量指标

| 指标         | 目标  | 检查方式             |
| ------------ | ----- | -------------------- |
| 知识覆盖率   | >90%  | 自动扫描代码vs知识库 |
| 知识新鲜度   | <30天 | 检查最后更新时间     |
| 聚合准确率   | >85%  | 人工抽样检查         |
| 开发者满意度 | >80%  | 定期调研             |

### 9.2 审核机制

```yaml
# 聚合结果审核配置
review:
  auto_merge:
    - "aggregated/repo-summaries/"  # 低风险内容自动合并

  manual_review:
    - "architecture/service-catalog.md"  # 架构变更需人工确认
    - "business/domain-model.md"         # 业务模型变更需确认

  reviewers:
    - "@architect"      # 架构相关
    - "@domain-expert"  # 业务相关
```

---

## 10. 最佳实践

### 10.1 维护原则

1. **渐进式完善**：不要一次性写全，逐步补充
2. **问题导向**：遇到问题时才补充相关知识
3. **AI辅助**：让AI帮助生成和维护部分内容
4. **定期回顾**：每月回顾和更新过时内容

### 10.2 内容标准

#### 业务知识 (L1)

- 使用业务语言，避免技术细节
- 包含完整的业务规则
- 提供具体的例子和场景

#### 架构知识 (L1)

- 清晰的模块边界和职责
- 准确的依赖关系
- 关键的技术决策和原因

#### 仓库知识 (L2)

- 专注当前仓库特有内容
- 避免重复通用规范
- 提供快速导航信息

### 10.3 常见问题

**Q: 业务知识和技术知识如何区分？**
A: 业务知识回答"做什么"和"为什么做"，技术知识回答"怎么做"。

**Q: AI聚合的准确性如何保证？**
A: 通过模板约束 + 人工审核 + 持续优化来提高准确性。

**Q: 项目知识库应该由谁维护？**
A: 由项目架构师或技术负责人维护，开发者贡献内容。

---

## 11. 演进路线

### 11.1 短期 (1-3个月)

- ✅ 完成基础架构设计
- ✅ 建立项目知识库模板
- ✅ 实现AI聚合功能
- ✅ 在1-2个项目试点

### 11.2 中期 (3-6个月)

- 🔄 扩展到更多项目
- 🔄 优化聚合算法
- 🔄 建立质量度量体系
- 🔄 集成到CI/CD流程

### 11.3 长期 (6-12个月)

- 📈 支持复杂聚合场景
- 📈 实现智能推荐
- 📈 建立知识图谱
- 📈 支持多项目知识共享

---

## 附录

### A. 模板集合

[所有模板已内嵌在文档中]

### B. 工具命令

```bash
# 项目管理
knowledge-init project    # 初始化项目知识库
knowledge-aggregate      # 聚合项目知识
knowledge-check          # 检查知识库完整性

# 仓库管理
knowledge-init repo      # 初始化仓库知识库
knowledge-update         # 更新仓库知识
knowledge-context        # 生成AI上下文
```

### C. 参考资源

- [12-Factor App](https://12factor.net/)
- [Domain-Driven Design](https://domainlanguage.com/ddd/)
- [C4 Model](https://c4model.com/)
- [Diátaxis Documentation Framework](https://diataxis.fr/)

---

**文档结束**
