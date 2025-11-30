# SpecKit 知识库增强方案

**版本**: 1.0
**创建日期**: 2025-12-01
**状态**: 草案

---

## 1. 概述

### 1.1 背景

SpecKit 是一套基于 SDD（Specification-Driven Development）的规范驱动开发框架。当前框架专注于需求规范、技术规划、任务生成的流程，但缺乏与企业知识库的深度集成。

### 1.2 目标

将三层知识库架构（L0 企业级、L1 项目级、L2 仓库级）与 SpecKit 工作流深度整合，实现：

1. **需求阶段**：理解业务领域、遵循术语规范、识别模块边界
2. **规划阶段**：遵循架构原则、复用现有组件、符合技术规范
3. **架构评审**：强制架构合规检查、ADR 一致性验证

### 1.3 知识库架构回顾

```
┌─────────────────────────────────────────────────────────────┐
│                    企业级 (L0)                              │
│   ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│   │  技术宪法     │ │  编码规范     │ │  技术雷达     │       │
│   │  架构原则     │ │  API设计      │ │  adopt/hold  │       │
│   └──────────────┘ └──────────────┘ └──────────────┘       │
├─────────────────────────────────────────────────────────────┤
│                    项目级 (L1)                              │
│   ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│   │  业务领域     │ │  服务目录     │ │  架构决策     │       │
│   │  术语词典     │ │  技术栈       │ │  ADR记录     │       │
│   └──────────────┘ └──────────────┘ └──────────────┘       │
├─────────────────────────────────────────────────────────────┤
│                    仓库级 (L2)                              │
│   ┌──────────────┐ ┌──────────────────────────────┐        │
│   │  context.md  │ │  code-derived/                │        │
│   │  (人工维护)   │ │  ├── overview.md (架构图)    │        │
│   │              │ │  ├── module_tree.json        │        │
│   │              │ │  └── {module}.md (详细文档)  │        │
│   └──────────────┘ └──────────────────────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. 增强优先级总览

| 优先级 | 命令 | 增强类型 | 核心价值 |
|--------|------|----------|----------|
| 🔴 P0 | `/speckit.plan` | 架构合规检查 + 知识库集成 | 确保技术方案符合架构原则 |
| 🔴 P0 | `/speckit.specify` | 业务知识集成 + 边界检查 | 确保需求与业务领域一致 |
| 🟡 P1 | `/speckit.analyze` | 架构一致性扩展 | 跨产物架构验证 |
| 🟡 P1 | `/speckit.clarify` | 知识辅助澄清 | 减少不必要的澄清问题 |
| 🟢 P2 | `/speckit.tasks` | 路径规范验证 | 任务文件路径一致性 |
| 🟢 P2 | `/speckit.implement` | 代码模式参考 | 实现阶段的模式指导 |

---

## 3. 详细增强方案

### 3.1 `/speckit.specify` - 需求规范阶段

#### 3.1.1 增强目标

- 确保需求使用正确的业务术语
- 识别与现有系统的关系
- 检查功能归属模块边界
- 避免重复定义已有实体

#### 3.1.2 知识库读取清单

```yaml
L1_项目级:
  business/glossary.md:
    用途: 术语词典
    应用: 确保需求描述使用规范术语

  business/domain-model.md:
    用途: 领域模型
    应用: 理解实体关系，避免重复定义

  business/rules.md:
    用途: 业务规则
    应用: 了解业务约束条件

L2_仓库级:
  .knowledge/context.md:
    用途: 仓库上下文
    应用: 了解技术边界和核心依赖

  .knowledge/code-derived/overview.md:
    用途: 仓库架构概览
    应用: 理解模块职责边界，识别功能归属

  .knowledge/code-derived/module_tree.json:
    用途: 组件索引
    应用: 识别已有实体/服务，避免重复需求
```

#### 3.1.3 具体修改内容

**插入位置**：步骤 2（解析用户描述）之后，步骤 3（unclear aspects）之前

**新增步骤内容**：

```markdown
## 知识库上下文加载

在解析用户描述后，执行知识库上下文加载：

### 1. 检测知识库存在性

检查以下路径是否存在：
- `.knowledge/context.md`（仓库级，必须）
- `.knowledge/code-derived/overview.md`（仓库级，可选）
- `.knowledge/code-derived/module_tree.json`（仓库级，可选）

如果 `.knowledge/` 目录不存在，跳过知识库加载，继续原有流程。

### 2. 加载仓库级知识

如果存在 `.knowledge/code-derived/`：

a) **读取 overview.md**：
   - 提取仓库定位和核心职责
   - 提取模块职责边界表
   - 识别新功能应归属的模块

b) **读取 module_tree.json**：
   - 获取现有组件清单（类名列表）
   - 识别是否存在相似实体/服务
   - 如发现相似组件，在需求中标注：
     `[参考现有: {module}/{component}]`

### 3. 加载项目级知识（如配置）

检查 `.knowledge/context.md` 中是否配置了项目知识库路径。
如果配置了且可访问：

a) **读取 glossary.md**（术语词典）：
   - 构建术语映射表
   - 在填充需求时，将非规范术语替换为规范术语
   - 记录术语映射到 Assumptions 章节

b) **读取 domain-model.md**（领域模型）：
   - 理解领域实体关系
   - 在 Key Entities 章节参考已有领域模型

### 4. 边界检查

基于 overview.md 中的模块职责表，检查新功能：
- 是否属于当前仓库职责范围
- 如果可能跨越模块边界，在需求中标注：
  `[跨模块提示: 可能涉及 {module_a} 和 {module_b}]`
- 如果明显超出仓库职责，警告用户可能需要在其他仓库实现
```

**修改步骤 4（填充 Functional Requirements）**：

在现有内容后追加：

```markdown
   - **新增**: 如果发现与现有组件相似的需求，标注参考：
     `[参考: {module}.md 中的 {component} 实现模式]`
   - **新增**: 使用术语词典中的规范术语
```

---

### 3.2 `/speckit.plan` - 技术规划阶段（最关键）

#### 3.2.1 增强目标

- **架构合规检查**：确保技术方案符合企业架构原则
- **技术栈一致性**：遵循项目技术选型
- **组件复用**：识别可复用的现有组件
- **ADR 一致性**：不与已有架构决策冲突

#### 3.2.2 知识库读取清单

```yaml
L0_企业级:
  enterprise-standards/constitution/architecture-principles.md:
    用途: 九大核心架构原则
    应用: 强制合规检查
    优先级: 必须

  enterprise-standards/standards/api-design.md:
    用途: API 设计规范
    应用: API 设计验证
    优先级: 推荐

  enterprise-standards/technology-radar/adopt.md:
    用途: 推荐技术
    应用: 技术选型参考
    优先级: 可选

L1_项目级:
  architecture/tech-stack.md:
    用途: 项目技术栈
    应用: 技术选型合规
    优先级: 推荐

  architecture/decisions/ADR-*.md:
    用途: 架构决策记录
    应用: ADR 一致性检查
    优先级: 推荐

  architecture/service-catalog.md:
    用途: 服务目录
    应用: 了解现有服务边界
    优先级: 可选

L2_仓库级:
  .knowledge/context.md:
    用途: 仓库上下文
    应用: 核心依赖和约束
    优先级: 必须

  .knowledge/code-derived/overview.md:
    用途: 仓库架构概览
    应用: 端到端架构理解
    优先级: 必须

  .knowledge/code-derived/module_tree.json:
    用途: 组件索引
    应用: 路径规范、组件复用
    优先级: 推荐

  .knowledge/code-derived/{module}.md:
    用途: 相关模块详细文档
    应用: 分层架构、集成点、配置模式
    优先级: 推荐
```

#### 3.2.3 具体修改内容

**修改步骤 2（加载上下文）- 新增知识库加载**：

在现有步骤 2 内容后追加：

```markdown
   **新增 - 知识库上下文加载**:

   ### 2.1 仓库级知识（必须）

   a) **读取 `.knowledge/context.md`**：
      - 提取技术栈信息
      - 提取核心依赖
      - 提取仓库特有规则

   b) **读取 `.knowledge/code-derived/overview.md`**：
      - 提取端到端架构图
      - 提取模块职责速览表
      - 识别新功能应放置的模块位置

   c) **读取 `.knowledge/code-derived/module_tree.json`**：
      - 获取模块路径映射
      - 获取现有组件清单
      - 确定文件命名规范

   d) **读取相关 `.knowledge/code-derived/{module}.md`**：
      - 基于功能归属，读取相关模块文档
      - 提取分层架构模式（Controller/Service/Mapper）
      - 提取集成点和依赖关系
      - 提取配置模式

   ### 2.2 企业级架构原则（必须）

   检查并读取企业架构原则文档：
   - 优先检查 `enterprise-standards/constitution/architecture-principles.md`
   - 如果路径不存在，检查项目配置中的企业知识库路径
   - 提取九大核心原则要点，用于后续合规检查

   ### 2.3 项目级架构知识（推荐）

   如果项目知识库路径已配置且可访问：

   a) **读取 `architecture/tech-stack.md`**：
      - 获取项目统一技术栈
      - 验证技术选型合规性

   b) **读取 `architecture/decisions/` 目录**：
      - 列出所有 ADR 文件
      - 提取 ADR 标题和状态
      - 用于后续 ADR 一致性检查
```

**新增步骤 - Phase 0.5: 架构合规检查**：

在 Phase 0 和 Phase 1 之间插入：

```markdown
### Phase 0.5: 架构合规检查（新增）

**前置条件**: Technical Context 已填充

**目的**: 确保技术方案符合企业架构原则，阻止违规设计进入后续阶段

#### 1. 加载架构原则

从已读取的 `architecture-principles.md` 提取检查项：

**九大核心原则检查点**:

| 原则 | 检查项 |
|------|--------|
| I. TDD | 是否规划了测试策略？测试覆盖目标？ |
| II. 规则至上 | 是否遵循项目规则层级？ |
| III. 微服务架构 | 分层是否符合 Controller→Service→Mapper？技术栈是否合规？ |
| IV. 安全优先 | 是否考虑输入校验、敏感信息、审计日志？ |
| V. RESTful | API 设计是否符合规范？HTTP 方法使用是否正确？ |
| VI. 生产就绪 | 是否有完整的错误处理、日志记录？ |
| VII. 多平台 | 是否考虑移动端/PC端兼容？ |
| VIII. 简洁性 | 是否有过度设计？是否引入不必要的依赖？ |
| IX. 事件驱动 | 是否需要事件机制？审计追踪是否完整？ |

#### 2. 执行合规检查

对照 Technical Context 中的技术方案，逐项检查：

```text
FOR each principle in 架构原则:
    IF principle 适用于当前功能:
        检查 Technical Context 是否满足要求
        记录检查结果: ✅ 合规 | ⚠️ 需调整 | ❌ 违规
    ELSE:
        标记为 N/A
```

#### 3. 生成合规矩阵

在 plan.md 中输出：

```markdown
## Architecture Compliance Check

| 原则 | 适用性 | 检查结果 | 说明 |
|------|--------|----------|------|
| I. TDD | ✓ | ✅ | 已规划单元测试和集成测试 |
| III. 微服务架构 | ✓ | ⚠️ | 技术栈合规，但分层需调整 |
| IV. 安全优先 | ✓ | ✅ | 已规划输入校验和审计日志 |
| V. RESTful | ✓ | ✅ | API 设计符合规范 |
| ... | | | |

**调整建议**:
1. [具体调整建议]

**例外说明**:
- [如有原则无法满足，说明理由和替代方案]
```

#### 4. 处理检查结果

| 结果 | 处理方式 |
|------|----------|
| 全部 ✅ | 继续 Phase 1 |
| 存在 ⚠️ | 更新 Technical Context 后继续，记录调整说明 |
| 存在 ❌ | **ERROR**: 停止流程，输出违规详情，要求重新设计 |

#### 5. ADR 一致性检查

如果项目有 ADR 记录：

```text
FOR each ADR in architecture/decisions/:
    IF ADR.status == "Accepted":
        检查当前方案是否与 ADR 冲突
        IF 冲突:
            标记为 ⚠️ 或 ❌
            记录冲突详情
```

**如果引入新架构决策**:
- 建议创建新 ADR
- 输出 ADR 模板建议

#### 6. 输出

在 plan.md 中新增章节：

```markdown
## Architecture Compliance

### 检查时间
[YYYY-MM-DD HH:MM]

### 合规矩阵
[生成的合规矩阵表格]

### ADR 一致性
- 检查的 ADR: [列表]
- 冲突项: [无/列表]

### 调整记录
[如有调整，记录调整内容和理由]

### 例外说明
[如有原则例外，记录理由]
```
```

**修改 Phase 1（Design & Contracts）**：

在现有 Phase 1 内容中追加：

```markdown
**Prerequisites:** `research.md` complete, **Architecture Compliance check passed**

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable
   - **新增**: 参考 `module_tree.json` 检查是否存在相似实体
   - **新增**: 遵循现有实体的命名和字段模式

2. **Generate API contracts** from functional requirements:
   - For each user action → endpoint
   - Use standard REST/GraphQL patterns
   - Output OpenAPI/GraphQL schema to `/contracts/`
   - **新增**: 遵循 `api-design.md` 中的规范
   - **新增**: 参考相关 `{module}.md` 中的 API 模式

3. **Project Structure**（新增强调）:
   - **必须**: 遵循 `module_tree.json` 中的路径约定
   - **必须**: 遵循现有模块的分层命名规范
   - **参考**: 相关 `{module}.md` 中的组件组织方式
```

---

### 3.3 `/speckit.analyze` - 分析阶段

#### 3.3.1 增强目标

- 扩展 Constitution Alignment 为完整架构检查
- 增加企业架构原则验证
- 增加 ADR 一致性验证

#### 3.3.2 具体修改内容

**修改步骤 4 Detection Passes - 扩展 "D. Constitution Alignment"**：

将原有的 `D. Constitution Alignment` 替换为：

```markdown
#### D. Architecture & Constitution Alignment（扩展）

**D1. 项目宪法检查**（现有）
- 任何需求或计划元素与项目宪法 MUST 原则冲突
- 缺少宪法要求的必需章节或质量门禁

**D2. 企业架构原则检查**（新增）

如果企业架构原则文档存在 (`enterprise-standards/constitution/architecture-principles.md`)：

检查项:
- plan.md 中的技术选型是否符合九大原则
- 是否遵循 12-Factor App 要求
- 是否符合微服务架构约束
- API 设计是否符合 RESTful 规范
- 是否考虑安全内建要求

输出:

| 原则 | plan.md 内容 | 合规状态 | 说明 |
|------|-------------|----------|------|

**D3. 项目 ADR 一致性检查**（新增）

如果项目有 ADR 记录 (`architecture/decisions/ADR-*.md`)：

检查项:
- plan.md 中的技术决策是否与已有 ADR 冲突
- 是否需要创建新 ADR

输出:

| ADR | 状态 | 相关性 | 冲突检测 |
|-----|------|--------|----------|

**D4. 仓库架构边界检查**（新增）

如果仓库有 code-derived 文档：

检查项:
- tasks.md 中的任务是否超出模块职责边界
- 依赖关系是否合理
- 文件路径是否符合现有约定

输出:

| 模块 | 职责边界 | 任务分布 | 边界状态 |
|------|----------|----------|----------|
```

**修改严重级别分配**：

在现有 Severity Assignment 规则中追加：

```markdown
- **CRITICAL**（新增规则）:
  - 违反企业架构核心原则（安全、TDD、微服务架构）
  - 与已接受的 ADR 直接冲突

- **HIGH**（新增规则）:
  - 与企业架构推荐原则不符
  - ADR 冲突但有合理理由
  - 超出模块职责边界
```

---

### 3.4 `/speckit.clarify` - 澄清阶段

#### 3.4.1 增强目标

- 利用知识库自动解决部分歧义
- 减少不必要的澄清问题

#### 3.4.2 具体修改内容

**修改步骤 2（歧义扫描）之前新增**：

在步骤 2 开头插入：

```markdown
   **新增 - 知识库辅助**:

   在执行歧义扫描前，加载知识库上下文：

   a) **术语歧义自动解决**:
      - 如果 `business/glossary.md` 存在
      - 对于术语类歧义，自动查找术语词典
      - 如果找到规范定义，自动应用而非询问用户
      - 记录自动解决的术语映射

   b) **模块归属自动判断**:
      - 如果 `.knowledge/code-derived/overview.md` 存在
      - 对于功能归属类歧义，参考模块职责表自动判断
      - 如果可明确判断，自动应用而非询问用户

   c) **减少澄清问题**:
      - 如果歧义可通过知识库解决，不计入 5 个问题配额
      - 在 Clarifications 章节记录：
        `[自动解决-知识库]: {问题} → {答案} (来源: {知识库文件})`
```

---

### 3.5 `/speckit.tasks` - 任务生成阶段

#### 3.5.1 增强目标

- 确保任务中的文件路径与现有结构一致

#### 3.5.2 具体修改内容

**修改步骤 2（加载设计文档）**：

在现有内容后追加：

```markdown
   **新增 - 仓库结构参考**:

   如果 `.knowledge/code-derived/` 存在：

   a) **读取 `module_tree.json`**:
      - 获取现有模块路径映射
      - 获取组件命名规范

   b) **路径生成规则**:
      - 任务中的文件路径必须遵循 `module_tree.json` 中的路径约定
      - 新文件应放置在对应模块目录下
      - 命名应遵循现有组件的命名模式
```

**修改步骤 4（生成 tasks.md）**：

在现有内容后追加：

```markdown
   - **新增**: 文件路径验证
     - 检查路径是否符合 `module_tree.json` 中的约定
     - 如果路径不符合，调整为正确路径或标注警告
```

---

### 3.6 `/speckit.implement` - 实现阶段

#### 3.6.1 增强目标

- 提供代码模式参考

#### 3.6.2 具体修改内容

**修改步骤 3（加载实现上下文）**：

在现有内容后追加：

```markdown
   **新增 - 代码模式参考**:

   如果 `.knowledge/code-derived/` 存在：

   a) **读取相关 `{module}.md`**:
      - 提取分层架构模式
      - 提取组件交互流程（序列图）
      - 提取配置示例

   b) **应用模式指导**:
      - 新 Controller 参考现有 Controller 模式
      - 新 Service 参考现有 Service 模式
      - 配置文件参考现有配置格式
```

---

## 4. 知识库配置机制

### 4.1 配置文件

建议在 `.specify/` 目录下支持知识库路径配置：

**文件路径**: `.specify/knowledge-config.yaml`

```yaml
# SpecKit 知识库配置

knowledge_sources:
  # 企业级知识库
  enterprise:
    enabled: true
    path: "../docs-knowledge/enterprise-standards"
    # 或使用 Git URL
    # url: "git@github.com:company/enterprise-standards.git"
    # ref: "v2.1"

  # 项目级知识库
  project:
    enabled: true
    path: "../docs-knowledge/project-xxx"

  # 仓库级知识库
  repository:
    context: ".knowledge/context.md"
    code_derived: ".knowledge/code-derived/"

# 架构合规检查配置
architecture_compliance:
  enabled: true
  strict_mode: true  # true: 违规阻止流程, false: 仅警告

  # 可跳过的原则（需要理由）
  skip_principles: []
  # 示例:
  # skip_principles:
  #   - principle: "TDD"
  #     reason: "Prototype phase, tests will be added later"
```

### 4.2 知识库检测逻辑

```text
知识库加载优先级:
1. 检查 .specify/knowledge-config.yaml
2. 如果不存在，检查 .knowledge/context.md 中的配置
3. 如果都不存在，使用默认路径检测
4. 对于不存在的知识库，跳过相关检查（不报错）
```

### 4.3 默认路径约定

```text
企业级:
  enterprise-standards/
  ├── constitution/architecture-principles.md
  ├── standards/api-design.md
  └── technology-radar/adopt.md

项目级:
  project-xxx/
  ├── business/glossary.md
  ├── business/domain-model.md
  ├── architecture/tech-stack.md
  └── architecture/decisions/ADR-*.md

仓库级:
  .knowledge/
  ├── context.md
  └── code-derived/
      ├── overview.md
      ├── module_tree.json
      └── {module}.md
```

---

## 5. 实施计划

### 5.1 阶段一：核心增强（1-2 周）

**目标**：完成 P0 优先级增强

| 任务 | 命令 | 工作量 | 产出 |
|------|------|--------|------|
| 1.1 | `/speckit.plan` 架构合规检查 | 3-4 天 | Phase 0.5 实现 |
| 1.2 | `/speckit.plan` 知识库集成 | 2-3 天 | 步骤 2 扩展 |
| 1.3 | `/speckit.specify` 知识库集成 | 2-3 天 | 新增知识库加载步骤 |
| 1.4 | 知识库配置机制 | 1-2 天 | knowledge-config.yaml |

### 5.2 阶段二：扩展增强（1 周）

**目标**：完成 P1 优先级增强

| 任务 | 命令 | 工作量 | 产出 |
|------|------|--------|------|
| 2.1 | `/speckit.analyze` 架构检查扩展 | 2-3 天 | D2-D4 检查项 |
| 2.2 | `/speckit.clarify` 知识辅助 | 1-2 天 | 自动澄清机制 |

### 5.3 阶段三：完善增强（1 周）

**目标**：完成 P2 优先级增强

| 任务 | 命令 | 工作量 | 产出 |
|------|------|--------|------|
| 3.1 | `/speckit.tasks` 路径验证 | 1-2 天 | 路径合规检查 |
| 3.2 | `/speckit.implement` 模式参考 | 1-2 天 | 代码模式指导 |
| 3.3 | 文档和测试 | 2-3 天 | 完整文档 |

---

## 6. 风险与缓解

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| 知识库不存在 | 流程中断 | 所有知识库检查设计为可选，不存在时优雅降级 |
| 知识库过时 | 错误指导 | 检查 metadata.json 中的时间戳，过时时警告 |
| 合规检查过严 | 阻碍开发 | 提供 skip_principles 配置，支持例外说明 |
| 性能影响 | 流程变慢 | 知识库内容缓存，增量加载 |

---

## 7. 成功指标

| 指标 | 目标 | 测量方式 |
|------|------|----------|
| 架构违规检出率 | >90% | 人工审核样本 |
| 术语一致性 | >95% | 自动检查 |
| 组件复用率 | 提升 20% | 对比增强前后 |
| 澄清问题减少 | 减少 30% | 统计平均问题数 |
| 开发者满意度 | >80% | 调研反馈 |

---

## 8. 错误代码定义

| 错误代码 | 含义 | 处理 |
|----------|------|------|
| ARCH-001 | 违反企业架构原则 | 阻止流程，要求修改 |
| ARCH-002 | ADR 冲突 | 阻止流程，要求说明 |
| ARCH-003 | 模块边界越界 | 警告，建议调整 |
| KNOW-001 | 知识库不可访问 | 警告，跳过相关检查 |
| KNOW-002 | 知识库过时 | 警告，继续使用 |

---

## 附录 A：架构原则检查项详细映射

基于 `enterprise-standards/constitution/architecture-principles.md` 的九大原则：

| 原则 | 检查项 | 严重级别 |
|------|--------|----------|
| I. TDD | 测试策略、覆盖率目标、测试模式 | CRITICAL |
| II. 规则至上 | 规则层级遵循 | HIGH |
| III. 微服务架构 | 分层结构、技术栈、数据访问模式 | CRITICAL |
| IV. 安全优先 | 输入校验、异常处理、审计日志 | CRITICAL |
| V. RESTful | API 路径设计、HTTP 方法、响应格式 | HIGH |
| VI. 生产就绪 | 代码完整性、错误处理、事务管理 | HIGH |
| VII. 多平台 | 移动端兼容、响应简洁、版本控制 | MEDIUM |
| VIII. 简洁性 | YAGNI、依赖管理、配置外部化 | MEDIUM |
| IX. 事件驱动 | 事件监听、审计消息、幂等性 | HIGH |

---

## 附录 B：知识库文件内容要求

### B.1 overview.md 必须包含

- 仓库目的（一段话描述）
- 端到端架构图（Mermaid）
- 核心模块速览表（模块、职责、关键组件、文档链接）

### B.2 module_tree.json 结构

```json
{
  "module-name": {
    "path": "relative/path/to/module",
    "components": ["ClassA", "ClassB", "..."],
    "children": {}
  }
}
```

### B.3 {module}.md 必须包含

- 模块简介
- 核心功能列表
- 架构图（分层、依赖）
- 核心组件详解
- 集成点说明
- 配置示例

---

**文档结束**
