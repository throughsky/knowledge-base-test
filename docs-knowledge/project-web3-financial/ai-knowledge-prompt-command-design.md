下面是一份可以直接落到仓库的「设计文档」，你可以整体保存为：

* 路径示例：`AI-Coding-L1/AI-Coding-knowledge-system.md`
* 或在你当前项目中作为《AI Coding 研发流程体系知识与 AI 使用方案》保存。

---

# AI Coding 研发流程体系：知识空间与 AI 使用方案（设计文档）

## 0. 文档说明

* 文档目的：
  为「AI Coding 研发流程体系」建立一套可落地的项目级知识结构（L1），并定义如何用 AI 来：
  * 管理业务/方法论知识；
  * 设计各业务线的落地方案；
  * 设计相关平台/工具的技术架构；
  * 做高质量的日常问答。
* 适用对象：
  * AI Native开发团队
  * 架构委员会 / 技术委员会
  * 各业务线 Tech Lead / 架构师
  * 平台工程团队（CI/CD、知识库、Agent 平台）

---

## 1. 本项目在知识体系中的定位

### 1.1 项目概述

* 项目名称：**AI Coding 研发流程体系**
* 类型：**横向研发方法论 + 工具链平台化能力**
* 来源文档：
  * 《AI Coding 研发流程体系 - 汇报材料》（版本 1.0，基于文档版本 2.8）
* 目标：
  * 将 SDD（规范驱动开发）+ TDD（测试驱动开发）+ D-R-O（委派-审查-掌控）+ 多级知识空间 + 统一工具链，固化为一套可复用的「团队级研发操作系统」。
  * 让 AI 在这套体系下稳定承担：
    * 规格生成、测试生成、代码初稿；
    * 业务方案和架构方案的「第一轮草案设计」；
    * 日常高质量问答与辅导。

### 1.2 多级知识空间中的位置（L0/L1/L2）

结合汇报文档中的设计：

* **L0 企业级知识库（不可覆盖）**
  * 内容：安全与合规约束、架构底线约束、企业级 AI Coding 约束（禁止敏感信息、审查必须、安全扫描必须、采纳率统计等）。
  * 维护主体：架构委员会 / 安全与合规团队。
  * 对 AI 的意义：所有项目与仓库的 **红线** ，AI 在方案与代码生成时必须遵守。
* **L1 项目级知识库（本设计文档聚焦）**
  * 内容：围绕「AI Coding 研发流程体系」自身的项目级知识，包括：
    * 背景与目标（质量可控 / 效率提升 / 知识沉淀）
    * 核心理念（SDD/TDD + D-R-O + 多级知识空间 + 统一工具链）
    * 端到端研发流程（从需求/Feature → SDD → TDD → Code Review → 知识沉淀 → 度量与优化）
    * 能力视图（SpecKit、CodeWiki、Agent 架构、GitHub 生态方案）
    * 对其它业务线的接入要求与落地方案模板
  * 维护主体：AI Native开发团队（李元主导）+ 架构委员会代表。
  * 对 AI 的意义：回答「这套体系是什么」「怎么用」「怎么接入」的 **主数据源** 。
* **L2 仓库级知识库（实现层）**
  * 内容：每个具体代码仓库中的 `.knowledge/`，包括：
    * `context.md`：仓库在整体业务 & 流程中的角色；
    * `decisions.md`：与业务/架构强相关的实现决策；
    * `features/registry.json` 及各 Feature 文档；
    * `code-derived/`: 由 CodeWiki 自动生成的 overview/module docs；
    * `upstream/L1-project/` 与 `upstream/L0-enterprise/`：通过 Git Subtree 引入的 L1/L0。
  * 维护主体：开发团队 + AI 工具（CodeWiki 自动生成部分）。
  * 对 AI 的意义：回答「具体代码实现」相关的问题时的上下文来源。

---

## 2. AI Coding 项目级知识库目录设计（L1）

建议为「AI Coding 研发流程体系」专门创建一棵 L1 目录：

```text
AI-Coding-L1/
├── overview.md
├── domain-model/
│   ├── entities.md
│   └── glossary.md
├── process-flows/
│   ├── end-to-end-flow.md
│   ├── sdd-tdd-flow.md
│   └── dro-responsibilities.md
├── knowledge-space/
│   ├── tiers.md
│   ├── l1-guidelines.md
│   └── l2-guidelines.md
├── capabilities/
│   ├── modules.md
│   └── roadmap.md
├── external-apis/
│   ├── api-principles.md
│   └── integration-guides/
│       └── onboarding-flow.md
├── decisions/
│   ├── ADR-business-template.md
│   ├── ADR-business-examples.md
│   └── FAQ.md
└── templates/
    ├── business_design_prompt.md
    ├── architecture_design_prompt.md
    └── ai_qa_prompt.md
```

    下面给出各关键文件的「可直接落库」内容或骨架。

---

## 3. `overview.md`（项目概览）

```markdown
# 项目概览（Project Overview）- AI Coding 研发流程体系

## 1. 项目基本信息

- 项目名称：AI Coding 研发流程体系
- 所属板块：AI Native开发团队 / 研发效能
- 来源文档：AI Coding 研发流程体系 - 汇报材料（版本 1.0，基于文档版本 2.8）
- 适用对象：
  - 各研发团队（后端 / 前端 / 移动 / 全栈）
  - 架构师 / Tech Lead
  - 工具平台团队（CI/CD、知识库、Agent 平台）

## 2. 背景与问题

参考汇报文档 1.1：

- 现状：
  - AI 编码工具（GitHub Copilot、Claude Code、Cursor 等）快速普及。
  - 多数团队停留在「个人试用」阶段，缺乏体系化方法与统一标准。

- 核心问题：
  - 业务设计难度大：例如 Web3、金融等复杂领域，团队认知门槛高。
  - AI 过度联想不精准：生成超出需求范围的代码，导致功能蔓延与维护成本增加。
  - 质量不可控：缺乏统一标准约束 AI 输出，代码质量参差不齐。
  - 知识碎片化：AI 无法获取完整项目上下文，生成结果与架构不一致。
  - 人机职责模糊：不知道哪些任务交给 AI，哪些由人掌控，导致效率与责任问题。

## 3. 设计目标

对应汇报文档 1.2：

- 质量可控：
  - 规范驱动（SDD：先有设计规范，后有代码实现）
  - 测试先行（TDD：先写测试定义行为，再生成实现）
  - 架构合规（在 plan 阶段强制执行架构合规检查）

- 效率提升：
  - AI 承担机械性工作（样板代码、初稿生成、模式应用）。
  - 人类聚焦决策（业务设计、架构决策、最终审批）。

- 知识沉淀：
  - 多级知识空间（三层知识架构：L0/L1/L2）
  - 自动化文档（CodeWiki 等）
  - 决策可追溯（Feature Registry + ADR 体系）

## 4. 核心理念

对应汇报文档第 2 章：

- SDD 驱动：规范先行，设计即约束。
- TDD 驱动：测试先行，质量内建。
- AI 协同：人机结对，D-R-O 框架明确职责。
- 多级知识空间 + 统一工具链：L0/L1/L2 分层 + 统一 IDE/Agent/MCP/质量工具链。
- 持续改进：通过效能度量与 Agent 评测体系持续优化。

## 5. 范围

本知识库（AI-Coding-L1）负责：

- 解释整套 AI Coding 研发流程体系的概念、流程和能力。
- 定义业务线/项目如何接入这套体系的「接入规范与模板」。
- 为 AI 提供回答「如何使用这套体系」的结构化知识来源。
```

    ---

## 4. `domain-model/entities.md`（核心实体）

```markdown
# 领域模型（Domain Model）- AI Coding 研发流程体系

## 1. 核心实体概览

| 实体名           | 描述                                                |
|------------------|-----------------------------------------------------|
| Feature          | 可交付的业务特性，SDD/TDD 的基本单元               |
| Spec             | 功能规格文档（spec.md），「设计即约束」的载体     |
| Plan             | 实施计划文档（plan.md），在此阶段做架构合规检查   |
| Tasks            | 任务列表文档（tasks.md），驱动实现与 TDD           |
| Implementation   | 实现产物（代码、测试、配置）                       |
| ADR              | 架构/重要设计决策记录                              |
| FeatureRegistry  | 特性注册表（registry.json），汇总 Feature 元数据   |
| KnowledgeSpaceL0 | 企业级知识库（安全/架构/AI 底线）                  |
| KnowledgeSpaceL1 | 项目级知识库（本 AI-Coding-L1 即为一例）           |
| KnowledgeSpaceL2 | 仓库级知识库（context/decisions/code-derived 等）  |
| Agent            | AI Agent（SpecKit Agent / Code Agent / Review Agent / CodeWiki Agent 等） |

## 2. 实体关系简述

- Feature
  - 1 个 Feature 对应 1 个 Spec、1 个 Plan、1 个 Tasks。
  - Feature 在 FeatureRegistry 中有一条记录。
  - Feature 可能关联多个 ADR（如中间件选型、安全策略决策）。
- KnowledgeSpace
  - L0 被所有项目继承（不可覆盖）。
  - L1（本项目）聚合多仓库的 L2 知识，并为 AI 提供「方法论 + 流程」上下文。
  - L2 仓库通过 `.knowledge/upstream` 引用 L1/L0。
```

    ---

## 5. `process-flows/end-to-end-flow.md`（端到端流程）

```markdown
# 端到端研发流程（End-to-End AI Coding Flow）

## 1. 总览

1. 需求/Feature 提出
2. SDD：规范驱动开发
3. TDD：测试驱动开发
4. Code Review：双层机制
5. 知识沉淀：Feature Registry + ADR + CodeWiki
6. 质量门禁 & 上线
7. 度量与优化

## 2. 步骤描述（结合汇报文档）

### Step 1：需求 / Feature 提出

- 由业务/产品或 Tech Lead 提出新 Feature。
- 在 FeatureRegistry 中创建初始条目（status: proposed）。

### Step 2：SDD 规范驱动开发

- specify：
  - 使用 `/speckit.specify` 从自然语言描述生成 `spec.md` 初稿。
  - 内容结构包括：需求详细说明、技术设计文档、接口契约、约束条件（技术栈/行数/排除功能）。
- 规格评审：
  - 人类（产品 + 架构师）审查 `spec.md`，确保业务和技术边界清晰。
- plan：
  - 使用 `/speckit.plan` 生成 `plan.md`，并在此阶段执行架构合规检查：
    - TDD 策略与覆盖率目标
    - 微服务分层与技术栈合规
    - 安全与审计要求
    - RESTful 设计、生产就绪、简洁性等。
- tasks：
  - 使用 `/speckit.tasks` 生成 `tasks.md`，拆分为可执行子任务（实现/测试/文档/运维）。

### Step 3：TDD 测试驱动开发

- 人定义测试策略：核心场景、边界条件与覆盖率目标（≥ 80%）。
- AI 生成测试用例：根据 Spec/Plan/Tasks 输出单测、集成测试草稿。
- 人审查测试：防止假测试，确保断言有意义。
- AI 生成实现代码：以通过测试为目标生成最小实现，避免过度实现。
- 人验收重构：优化性能与架构，保持测试全部通过。

### Step 4：Code Review 双层机制

- 第一层：AI 自动审查
  - 工具：ESLint/Prettier、SonarQube、GHAS/Snyk、Jest/pytest 覆盖率等。
- 第二层：人工审查
  - 关注架构一致性、业务逻辑正确性、可维护性、性能。

### Step 5：知识沉淀（Archive + CodeWiki）

- `/speckit.archive`：
  - 更新 FeatureRegistry，记录 Feature 状态、影响模块、API、新增 ADR。
- ADR：
  - 对关键设计与取舍形成 ADR 文档（架构或业务）。
- L2 仓库：
  - 运行 CodeWiki，从代码生成 overview/module docs 和模块树。
- L1 聚合：
  - 将与方法论/流程相关的经验、决策回写到 AI-Coding-L1（本知识库）。

### Step 6：质量门禁与上线

- SDD 门禁：spec 完整性、架构合规必过。
- TDD 门禁：测试覆盖率 ≥ 80%、无假测试。
- 代码质量门禁：无阻断级静态分析问题、无高危安全漏洞、风格通过。
- 通过后进入项目自身的 CI/CD & 发布流程。

### Step 7：度量与优化

- Agent 评测体系：
  - 代码采纳率 > 70%
  - 一次通过率 > 50%
  - 人工修改量 < 20%
  - 规格一致性 > 90%
- 基于这些指标不断调整：
  - Prompt 模板
  - Agent 能力与工具链
  - 知识库结构与内容
```

    ---

## 6. `knowledge-space/tiers.md`（多级知识空间说明）

```markdown
# 多级知识空间（L0 / L1 / L2）- AI Coding 研发流程体系

## 1. 核心理念

参考汇报文档 4 章：

- L2 仓库级：**AI 自动化优先**
  - 仓库级知识库尽量依靠 AI 自动生成（CodeWiki）。
  - 开发者只需维护核心决策文档（context.md, decisions.md）。
- L1 项目级：**业务/方法论枢纽**
  - 向内：串联多个仓库，指导具体开发。
  - 向外：以流程与规范的形式，对业务线/项目提供接入指南。
- L0 企业级：**底线约束**
  - 架构原则、安全规范、治理流程、AI 使用底线（不可覆盖）。

## 2. 在 AI Coding 项目中的具体体现

- L0：
  - 来自企业级安全/架构/AI 规范文档（不在本知识库内维护）。
- L1（本知识库）：
  - 解释和固化「AI Coding 研发流程体系」本身：
    - SDD/TDD/D-R-O 流程、质量门禁、Agent 评测体系等。
    - 面向所有项目的「方法论与实践规范」。
- L2：
  - 每个使用该体系的仓库，按照 `.knowledge` 结构维护自身上下文与决策：
    - `.knowledge/context.md`
    - `.knowledge/decisions.md`
    - `.knowledge/features/registry.json`
    - `.knowledge/code-derived/*`

## 3. AI 检索优先级建议

当 AI 需要回答「某个仓库中的问题」时，建议遵循下面的 context 搜索顺序：

1. 当前仓库：
   - `.knowledge/context.md`
   - `.knowledge/code-derived/`
2. 项目级：
   - `.knowledge/upstream/L1-project/`（指向本 AI-Coding-L1）
3. 企业级：
   - `.knowledge/upstream/L0-enterprise/`（企业安全/架构/AI 底线）

当 AI 需要回答「方法论 or 如何使用这套体系」问题时，优先：

1. AI-Coding-L1/overview.md
2. AI-Coding-L1/process-flows/*
3. AI-Coding-L1/capabilities/modules.md
4. AI-Coding-L1/knowledge-space/*
```

    ---

## 7. `knowledge-space/l1-guidelines.md`（L1 维护规范）

```markdown
# L1 项目级知识库维护规范 - AI Coding 研发流程体系

## 1. 目标

- 让 AI 能稳定回答：
  - 这套「AI Coding 研发流程体系」是什么、怎么运转？
  - 一个新项目/仓库如何接入这套体系？
- 让方法论与实践保持同步演进，而不只是停留在 PPT。

## 2. 目录与职责

- `overview.md`：
  - 说明背景、目标、适用范围。
- `domain-model/`：
  - 抽象核心实体：Feature、Spec、Plan、Tasks、ADR、KnowledgeSpace、Agent 等。
- `process-flows/`：
  - 端到端流程、SDD/TDD 流程细节、D-R-O 职责分配。
- `knowledge-space/`：
  - L0/L1/L2 的定义与示例，提供给其它业务线参考。
- `capabilities/`：
  - 列出 SDD、TDD、SpecKit、CodeWiki、Agent 架构、GitHub 生态等能力与模块映射。
- `external-apis/`：
  - 不是 HTTP API，而是流程/规范接口：各业务线接入 AI Coding 流程时需要遵守的规则。
- `decisions/`：
  - 与方法论演进相关的 ADR 与 FAQ。

## 3. 维护触发规则

以下情况之一发生时，L1 必须更新：

1. SDD/TDD/D-R-O 相关流程或原则有重大调整。
2. 多级知识空间（L0/L1/L2）职责或集成方式有变化。
3. 统一工具链栈发生重大调整（如 Agent 平台迁移）。
4. 质量门禁或 Agent 评测指标发生变更。
5. 新增/废弃重要实践（例如引入/淘汰某类 Agent 能力）。

## 4. 责任人

- 内容所有者：AI Native开发团队（李元）
- 审核者：架构委员会代表 + 研发效能负责人
- 建议节奏：
  - 每半年进行一次体系级回顾。
  - 重大实践变更时同步更新相关章节与 ADR。
```

    ---

## 8. `capabilities/modules.md`（能力视图）

```markdown
# 能力视图（Capabilities → Modules）- AI Coding 研发流程体系

## 1. 总览

| 能力类别             | 描述                                            | 实现方式/工具示例           |
|----------------------|-------------------------------------------------|-----------------------------|
| SDD 规范驱动开发     | 以 Spec/Plan/Tasks 为中心的规范驱动流程        | SpecKit + 模板 + ADR        |
| TDD 测试驱动开发     | 先写测试再写实现，以测试为行为定义             | AI 辅助生成测试 + 人审查    |
| Code Review 双层机制 | AI 自动审查 + 人工深度审查                     | ESLint/Prettier/SonarQube 等|
| 多级知识空间         | L0/L1/L2 分层，让 AI 获取完整上下文            | .knowledge 结构 + Subtree   |
| CodeWiki 自动文档    | 从代码生成 overview/module docs                | 代码解析 + 调用图 + LLM     |
| GitHub 生态集成      | Projects / Actions / Copilot / GHAS 一体化方案 | GitHub 全家桶              |
| Agent 架构           | 通过 Agent 协调层对接文件/代码/终端/知识检索   | Cursor / Claude Code / MCP 等|
| 质量与度量           | SDD/TDD/Code Review 质量门禁 + Agent 评测体系  | 门禁规则 + 采纳率等指标     |

## 2. 核心能力详情（示例）

### 能力：SDD 规范驱动开发

- 目标：
  - 让「规范」成为 AI 生成代码的直接输入，避免过度实现。
- 关键 artefacts：
  - `spec.md`、`plan.md`、`tasks.md`、ADR、FeatureRegistry。
- 工具与集成：
  - SpecKit 命令：`/speckit.specify`、`/speckit.plan`、`/speckit.tasks`、`/speckit.implement`、`/speckit.archive`。
```

    ---

## 9. AI 模式模板（`templates/*.md`）

### 9.1 `templates/business_design_prompt.md`

```markdown
你现在是「AI Coding 研发流程体系」的业务设计顾问。

目标：基于本体系的 SDD/TDD、多级知识空间和统一工具链，为某个具体业务线设计一套落地方案（如何使用这套流程与工具）。

【上下文加载要求】
- 必须读取：
  - AI-Coding-L1/overview.md
  - AI-Coding-L1/process-flows/end-to-end-flow.md
  - AI-Coding-L1/knowledge-space/tiers.md
  - AI-Coding-L1/capabilities/modules.md

【输入信息】（由提问人补充）：
1. 目标业务线/团队的基本情况：
2. 现有开发流程简要说明（不含 AI 时）：
3. 当前或计划使用的 AI 工具（Copilot/Claude/Cursor 等）：
4. 当前主要痛点（质量/效率/协作/知识沉淀）：
5. 强约束（安全、合规、技术栈等）：

【输出要求】：
请按以下结构输出：

# AI Coding 落地方案草案（针对 <业务线名称>）

## 1. 现状与问题摘要
## 2. 目标与适配原则（质量可控 / 效率提升 / 知识沉淀）
## 3. 流程适配方案（现有流程 → SDD/TDD 流程映射）
## 4. 知识空间建设方案（L1/L2 如何搭建与维护）
## 5. 工具链与集成建议（IDE/Agent/GitHub 生态）
## 6. 推进节奏（按四阶段实施计划给出建议）

【原则】：
- 所有建议必须引用 AI Coding 体系中的现有概念和流程，不要发明一套全新方法。
```

    ### 9.2`templates/architecture_design_prompt.md`

```markdown
你现在是「AI Coding 研发流程体系」相关平台/工具的技术架构顾问。

目标：基于现有方法论和能力视图，为「AI Coding 平台」本身（或其中一个子组件，如 SpecKit、CodeWiki、Agent 协调层）设计技术架构草案。

【上下文加载要求】
- AI-Coding-L1/overview.md
- AI-Coding-L1/domain-model/entities.md
- AI-Coding-L1/capabilities/modules.md
- AI-Coding-L1/process-flows/end-to-end-flow.md
- L0 企业级架构与安全约束（分层、可观测性、AI 安全等）

【输入信息】：
1. 本次设计的对象（例如：SpecKit 服务、CodeWiki 服务、Agent 协调层）：
2. 目标与非功能性要求（SLA/QPS/扩展性/安全等）：
3. 现有系统约束（语言/框架/存储/依赖）：
4. 必须集成的外部系统（GitHub、CI/CD、监控等）：

【输出要求】：
按以下结构输出技术架构草案：

# 技术架构草案 - <对象名称>

## 1. 目标与范围
## 2. 业务/能力映射（与 AI Coding 能力视图对应）
## 3. 系统边界与依赖关系（可用 mermaid 图描述）
## 4. 数据与存储设计（高层）
## 5. 接口与集成方式（内部/外部、同步/异步）
## 6. 非功能性设计（可用性/性能/安全/可观测性）
## 7. 风险与待决问题

【原则】：
- 必须遵守 L0 架构与安全底线。
- 优先复用已有组件，避免无必要的新服务。
```

    ### 9.3`templates/ai_qa_prompt.md`

```markdown
你现在是「AI Coding 研发流程体系」的问答助手。

【知识加载顺序】：
1. AI-Coding-L1/overview.md
2. AI-Coding-L1/domain-model/entities.md
3. AI-Coding-L1/process-flows/end-to-end-flow.md
4. AI-Coding-L1/knowledge-space/tiers.md
5. AI-Coding-L1/capabilities/modules.md
6. 相关仓库的 .knowledge/context.md 和 .knowledge/decisions.md
7. L0 企业级约束（安全/架构/AI 使用底线）

【回答规则】：
1. 优先使用 AI Coding 体系中的术语与结构（SDD/TDD/D-R-O、多级知识空间、统一工具链）。
2. 如涉及「某业务线如何接入」，先解释主流程，再建议其如何建设 L1/L2 知识空间与工具链。
3. 回答末尾列出主要参考的文档路径，示例：
   - 参考：
     - AI-Coding-L1/process-flows/end-to-end-flow.md
     - AI-Coding-L1/knowledge-space/tiers.md
     - repo-x/.knowledge/context.md
4. 如发现知识存在冲突或缺失，请在回答中指出，并给出「应补充/更新哪份文档」的建议。
```

    ---

## 10. 落地建议

* 第一步：在你当前的 AI Native 开发团队知识库或代码仓中，创建 `AI-Coding-L1/` 目录，将本设计文档拆分为对应的文件。
* 第二步：选择 1~2 个真实项目作为试点：
  * 为它们补齐 L1 项目级知识库（业务 + 架构）；
  * 在至少 1 个仓库中补齐 `.knowledge/context.md` 与 `.knowledge/decisions.md`。
* 第三步：在实际 AI 使用环境（IDE Agent/知识库问答）中：
  * 配置上述 `search_priority`；
  * 开始用 `business_design_prompt.md` 和 `architecture_design_prompt.md` 驱动真实需求。

这样，你就有了一个与《AI Coding 研发流程体系 - 汇报材料》紧密对齐、又可直接支持 AI 的「知识与流程操作系统」。
