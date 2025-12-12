# SpecKit 知识库集成改造方案

> 版本：1.0.0 | 创建日期：2025-12-12 | 状态：提案

## 1. 背景与目标

### 1.1 问题陈述

当前 SpecKit 命令在执行时缺乏与多级知识空间（L0/L1/L2）的系统性集成：

| 问题 | 影响 | 严重程度 |
|------|------|----------|
| 命令执行无知识库上下文 | AI 生成内容可能违反企业规范 | 🔴 高 |
| 术语使用不统一 | spec 中术语混乱，与项目标准不一致 | 🟡 中 |
| 架构决策缺乏历史参考 | plan 阶段可能与现有 ADR 冲突 | 🔴 高 |
| 代码实现缺乏规范指导 | implement 阶段可能违反编码标准 | 🔴 高 |
| 知识库加载无差异化 | 所有命令加载相同文档，效率低下 | 🟡 中 |

### 1.2 改造目标

1. **精准加载**：根据命令阶段动态加载所需知识库文档
2. **合规保障**：确保各阶段产出符合企业级约束（L0 不可覆盖）
3. **效率优化**：避免冗余加载，降低 Token 消耗
4. **一致性保证**：术语、架构、编码风格全流程一致

---

## 2. 知识空间架构回顾

```
┌─────────────────────────────────────────────────────────────┐
│                    企业级 (L0)                              │
│              (Enterprise Standards)                         │
│   ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│   │ constitution │ │  standards   │ │ tech-radar   │       │
│   │  技术宪法    │ │  编码规范    │ │  技术雷达    │       │
│   └──────────────┘ └──────────────┘ └──────────────┘       │
│   ┌──────────────┐ ┌──────────────┐                        │
│   │  governance  │ │  ai-coding   │                        │
│   │  治理流程    │ │  AI编码策略  │                        │
│   └──────────────┘ └──────────────┘                        │
├─────────────────────────────────────────────────────────────┤
│                    项目级 (L1)                              │
│              (Project Knowledge)                            │
│   ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│   │   business   │ │ architecture │ │  standards   │       │
│   │  领域模型    │ │  架构决策    │ │  项目规范    │       │
│   │  术语词典    │ │  技术栈      │ │  (细化L0)    │       │
│   └──────────────┘ └──────────────┘ └──────────────┘       │
├─────────────────────────────────────────────────────────────┤
│                    仓库级 (L2)                              │
│              (Repository Context)                           │
│   ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│   │  context.md  │ │ code-derived │ │   features   │       │
│   │  仓库上下文  │ │  代码文档    │ │  特性归档    │       │
│   └──────────────┘ └──────────────┘ └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. 命令与知识库映射设计

### 3.1 SDD 流程知识需求分析

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         SDD 工作流程                                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐ │
│  │   specify   │ → │    plan     │ → │    tasks    │ → │  implement  │ │
│  │  自然语言   │   │  实施计划   │   │  可执行任务  │   │  任务→代码  │ │
│  │  →功能规格  │   │  →设计文档  │   │  →任务列表   │   │             │ │
│  └──────┬──────┘   └──────┬──────┘   └──────┬──────┘   └──────┬──────┘ │
│         │                 │                 │                 │         │
│    知识需求:          知识需求:          知识需求:        知识需求:     │
│    - 术语词典         - 架构原则         - 模块结构        - 编码规范   │
│    - 领域模型         - 技术栈           - 文件路径        - 代码模式   │
│    - 仓库边界         - ADR历史          - 验证规则        - 安全红线   │
│                       - 技术雷达                           - AI约束     │
│                       - 安全红线                                        │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 3.2 各命令知识库加载矩阵

#### 3.2.1 `/speckit.constitution` - 项目宪章创建

| 层级 | 文档路径 | 加载方式 | 用途 |
|------|----------|----------|------|
| **L0** | `constitution/constitution-template.md` | 必须 | 宪章模板参考 |
| **L0** | `constitution/architecture-principles.md` | 必须 | 架构底线继承 |
| **L0** | `constitution/security-baseline.md` | 必须 | 安全红线继承 |
| **L0** | `constitution/compliance-requirements.md` | 可选 | 合规要求参考 |

**加载策略**：全量加载 L0 宪法层，确保项目宪章完整继承企业约束。

---

#### 3.2.2 `/speckit.specify` - 功能规格创建

| 层级 | 文档路径 | 加载方式 | 用途 |
|------|----------|----------|------|
| **L1** | `business/glossary.md` | 必须 | 术语规范，确保用词一致 |
| **L1** | `business/domain-model.md` | 必须 | 实体识别，避免重复定义 |
| **L1** | `business/rules.md` | 可选 | 业务规则约束参考 |
| **L2** | `context.md` | 必须 | 仓库定位，明确边界 |

**加载策略**：
- 优先加载术语词典，AI 生成规格时强制使用标准术语
- 加载领域模型识别已有实体，避免重复定义
- 加载仓库上下文明确本仓库职责边界

**Prompt 增强示例**：
```markdown
## 知识库上下文

### 术语规范 (必须遵循)
{glossary.md 内容}

### 领域模型 (已有实体)
{domain-model.md 内容}

### 仓库边界
{context.md 内容}

## 约束
- 必须使用术语词典中的标准术语
- 不得重新定义已有实体
- 功能边界必须在本仓库职责范围内
```

---

#### 3.2.3 `/speckit.clarify` - 需求澄清

| 层级 | 文档路径 | 加载方式 | 用途 |
|------|----------|----------|------|
| **L1** | `business/glossary.md` | 必须 | 术语一致性检查 |
| **L1** | `business/rules.md` | 必须 | 业务规则约束 |
| **L1** | `business/workflows/*.md` | 可选 | 现有流程参考 |
| **L2** | `context.md` | 必须 | 仓库职责边界 |

**加载策略**：
- 澄清问题时参考业务规则判断答案合理性
- 确保澄清结果与现有业务流程不冲突

---

#### 3.2.4 `/speckit.plan` - 实施计划生成【核心阶段】

| 层级 | 文档路径 | 加载方式 | 用途 |
|------|----------|----------|------|
| **L0** | `constitution/architecture-principles.md` | 必须 | 架构合规检查 |
| **L0** | `constitution/security-baseline.md` | 必须 | 安全红线检查 |
| **L0** | `standards/coding-standards/{lang}.md` | 必须 | 语言规范 |
| **L0** | `standards/api-design-guide.md` | 必须 | API设计规范 |
| **L0** | `standards/testing-standards.md` | 必须 | 测试规范 |
| **L0** | `technology-radar/adopt.md` | 必须 | 推荐技术 |
| **L0** | `technology-radar/hold.md` | 必须 | 禁用技术 |
| **L0** | `governance/review-process.md` | 可选 | 审批流程 |
| **L1** | `architecture/tech-stack.md` | 必须 | 项目技术栈 |
| **L1** | `architecture/decisions/ADR-*.md` | 必须 | 架构决策记录 |
| **L1** | `architecture/service-catalog.md` | 可选 | 服务目录 |
| **L1** | `standards/coding.md` | 必须 | 项目编码规范 |
| **L1** | `standards/api.md` | 必须 | 项目API规范 |
| **L2** | `code-derived/module_tree.json` | 必须 | 模块依赖树 |
| **L2** | `code-derived/overview.md` | 必须 | 仓库概览 |
| **L2** | `context.md` | 必须 | 技术栈、特有规则 |
| **L2** | `features/registry.json` | 可选 | 历史特性参考 |

**加载策略**：
```yaml
phase_0_research:
  # 技术调研阶段
  load:
    - L0/technology-radar/*  # 技术选型约束
    - L1/architecture/tech-stack.md  # 项目技术栈
    - L2/context.md  # 仓库技术上下文

phase_1_design:
  # 设计阶段
  load:
    - L0/constitution/*  # 架构合规检查
    - L0/standards/*  # 编码规范
    - L1/architecture/decisions/ADR-*.md  # ADR 一致性
    - L2/code-derived/module_tree.json  # 模块结构
    - L2/code-derived/overview.md  # 现有架构
```

**架构合规检查矩阵**（Plan 阶段必须执行）：

| 原则 | 检查项 | 知识库来源 | 严重级别 |
|------|--------|------------|----------|
| I. TDD | 测试策略、覆盖率目标 | L0/standards/testing-standards.md | CRITICAL |
| III. 分层架构 | 分层结构、技术栈合规 | L0/constitution/architecture-principles.md | CRITICAL |
| IV. 安全红线 | 输入校验、审计日志 | L0/constitution/security-baseline.md | CRITICAL |
| V. RESTful | API设计规范 | L0/standards/api-design-guide.md | HIGH |
| VI. 生产就绪 | 错误处理、事务管理 | L0/constitution/architecture-principles.md | HIGH |
| VIII. 简洁性 | YAGNI、依赖管理 | L0/constitution/architecture-principles.md | MEDIUM |
| IX. 容器化 | Dockerfile、K8s配置 | L0/constitution/architecture-principles.md | HIGH |

---

#### 3.2.5 `/speckit.tasks` - 任务列表生成

| 层级 | 文档路径 | 加载方式 | 用途 |
|------|----------|----------|------|
| **L2** | `code-derived/module_tree.json` | 必须 | 文件路径验证 |
| **L2** | `code-derived/overview.md` | 可选 | 模块结构参考 |

**加载策略**：
- Tasks 阶段主要依赖 plan.md 已生成的设计
- 仅需验证任务中的文件路径是否符合模块结构
- 轻量级加载，减少 Token 消耗

---

#### 3.2.6 `/speckit.implement` - 代码实现【核心阶段】

| 层级 | 文档路径 | 加载方式 | 用途 |
|------|----------|----------|------|
| **L0** | `standards/coding-standards/{lang}.md` | 必须 | 编码规范 |
| **L0** | `ai-coding/ai-coding-policy.md` | 必须 | AI编码约束 |
| **L0** | `constitution/security-baseline.md` | 必须 | 安全红线 |
| **L1** | `standards/coding.md` | 必须 | 项目编码规范 |
| **L1** | `standards/api.md` | 必须 | API规范 |
| **L1** | `standards/testing.md` | 必须 | 测试规范 |
| **L2** | `code-derived/{module}.md` | 必须 | 模块详细文档 |
| **L2** | `context.md` | 必须 | 本仓库特有规则 |
| **L2** | `features/registry.json` | 可选 | 历史特性参考 |

**加载策略**：
```yaml
pre_implementation:
  # 实现前加载
  load:
    - L0/ai-coding/ai-coding-policy.md  # AI 约束（必须优先）
    - L0/standards/coding-standards/{detected_lang}.md  # 语言规范
    - L2/context.md  # 仓库特有规则

per_task:
  # 每个任务加载相关模块文档
  load:
    - L2/code-derived/{target_module}.md  # 目标模块文档
    - L1/standards/api.md  # API 规范（如涉及接口）
    - L1/standards/testing.md  # 测试规范（如涉及测试）
```

**AI 编码约束强制执行**（从 L0 继承，不可覆盖）：
```markdown
## AI Coding Policy (L0 强制约束)

- AI 生成的代码必须经过人工 Review 后方可合并
- AI 不得自动提交到 main/master/release 分支
- AI 不得修改安全相关配置文件（.env、secrets、credentials）
- AI 生成的测试必须有有效断言
- 禁止 AI 自动跳过或删除失败的测试
```

---

#### 3.2.7 `/speckit.analyze` - 跨产物分析

| 层级 | 文档路径 | 加载方式 | 用途 |
|------|----------|----------|------|
| **L0** | `constitution/*` | 必须 | 宪章合规检查 |
| **L1** | `business/glossary.md` | 必须 | 术语一致性检查 |
| **L2** | `context.md` | 必须 | 仓库边界检查 |

**加载策略**：
- 分析阶段需要检查 spec/plan/tasks 之间的一致性
- 检查是否符合宪章原则
- 检查术语使用是否与词典一致

---

#### 3.2.8 `/speckit.checklist` - 检查清单生成

**动态加载策略**（根据检查清单类型）：

| 清单类型 | L0 文档 | L1 文档 | L2 文档 |
|----------|---------|---------|---------|
| **security** | security-baseline.md, ai-coding-policy.md | - | context.md |
| **testing** | testing-standards.md | testing.md | context.md |
| **api** | api-design-guide.md | api.md | context.md |
| **release** | governance/release-process.md | - | context.md |
| **ux** | - | - | context.md |
| **performance** | - | standards/*, architecture/* | context.md |

---

#### 3.2.9 `/speckit.taskstoissues` - 任务转 Issue

| 层级 | 文档路径 | 加载方式 | 用途 |
|------|----------|----------|------|
| **L2** | `context.md` | 必须 | 仓库上下文信息 |

**加载策略**：轻量级，仅需仓库基本信息。

---

### 3.3 知识库加载优先级矩阵

```
┌────────────────┬──────────────────────────────────────────────────────────┐
│                │           命令阶段                                        │
│  知识库层级     ├──────┬──────┬──────┬──────┬──────┬──────┬──────┬────────┤
│                │consti│specif│clarif│ plan │ tasks│implem│analyz│checklis│
├────────────────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼────────┤
│ L0 constitution│  ●   │      │      │  ●   │      │  ○   │  ●   │   ○    │
│ L0 standards   │      │      │      │  ●   │      │  ●   │      │   ○    │
│ L0 tech-radar  │      │      │      │  ●   │      │      │      │        │
│ L0 governance  │      │      │      │  ○   │      │      │      │   ○    │
│ L0 ai-coding   │      │      │      │  ○   │      │  ●   │      │   ○    │
├────────────────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼────────┤
│ L1 business    │      │  ●   │  ●   │  ○   │      │      │  ○   │        │
│ L1 architecture│      │      │      │  ●   │      │      │      │        │
│ L1 standards   │      │      │      │  ●   │      │  ●   │      │   ○    │
├────────────────┼──────┼──────┼──────┼──────┼──────┼──────┼──────┼────────┤
│ L2 context.md  │      │  ●   │  ●   │  ●   │      │  ●   │  ●   │   ●    │
│ L2 code-derived│      │      │      │  ●   │  ●   │  ●   │      │        │
│ L2 features    │      │      │      │  ○   │      │  ○   │      │        │
└────────────────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴────────┘

● 必须加载  ○ 可选加载（按需）  空白 不加载
```

---

## 4. 技术实现方案

### 4.1 知识库配置文件设计

**文件位置**：`.specify/knowledge-config.yaml`

```yaml
# SpecKit 知识库配置
version: "1.0"

# 知识库路径配置
knowledge_sources:
  L0_enterprise:
    enabled: true
    path: ".knowledge/upstream/L0-enterprise"
    # 或外部路径
    # path: "../enterprise-standards"

  L1_project:
    enabled: true
    path: ".knowledge/upstream/L1-project"
    # 或外部路径
    # path: "../project-knowledge"

  L2_repository:
    context: ".knowledge/context.md"
    code_derived: ".knowledge/code-derived/"
    features: ".knowledge/features/"

# 命令级知识库加载规则
command_knowledge_rules:

  constitution:
    description: "项目宪章创建"
    required:
      L0:
        - "constitution/constitution-template.md"
        - "constitution/architecture-principles.md"
        - "constitution/security-baseline.md"
    optional:
      L0:
        - "constitution/compliance-requirements.md"

  specify:
    description: "功能规格创建"
    required:
      L1:
        - "business/glossary.md"
        - "business/domain-model.md"
      L2:
        - "context.md"
    optional:
      L1:
        - "business/rules.md"
    prompt_injection:
      - section: "术语规范"
        source: "L1/business/glossary.md"
        instruction: "必须使用以下术语词典中的标准术语"
      - section: "领域模型"
        source: "L1/business/domain-model.md"
        instruction: "不得重新定义以下已有实体"

  clarify:
    description: "需求澄清"
    required:
      L1:
        - "business/glossary.md"
        - "business/rules.md"
      L2:
        - "context.md"
    optional:
      L1:
        - "business/workflows/*.md"

  plan:
    description: "实施计划生成"
    required:
      L0:
        - "constitution/architecture-principles.md"
        - "constitution/security-baseline.md"
        - "standards/coding-standards/*.md"
        - "standards/api-design-guide.md"
        - "standards/testing-standards.md"
        - "technology-radar/adopt.md"
        - "technology-radar/hold.md"
      L1:
        - "architecture/tech-stack.md"
        - "architecture/decisions/ADR-*.md"
        - "standards/coding.md"
        - "standards/api.md"
      L2:
        - "code-derived/module_tree.json"
        - "code-derived/overview.md"
        - "context.md"
    optional:
      L0:
        - "governance/review-process.md"
      L1:
        - "architecture/service-catalog.md"
      L2:
        - "features/registry.json"
    compliance_check:
      enabled: true
      strict_mode: true  # true: 违规阻止流程
      principles:
        - id: "TDD"
          source: "L0/standards/testing-standards.md"
          severity: "CRITICAL"
        - id: "LAYERED_ARCH"
          source: "L0/constitution/architecture-principles.md"
          severity: "CRITICAL"
        - id: "SECURITY"
          source: "L0/constitution/security-baseline.md"
          severity: "CRITICAL"
        - id: "RESTFUL"
          source: "L0/standards/api-design-guide.md"
          severity: "HIGH"
        - id: "CONTAINER"
          source: "L0/constitution/architecture-principles.md"
          severity: "HIGH"

  tasks:
    description: "任务列表生成"
    required:
      L2:
        - "code-derived/module_tree.json"
    optional:
      L2:
        - "code-derived/overview.md"

  implement:
    description: "代码实现"
    required:
      L0:
        - "ai-coding/ai-coding-policy.md"
        - "standards/coding-standards/*.md"
        - "constitution/security-baseline.md"
      L1:
        - "standards/coding.md"
        - "standards/api.md"
        - "standards/testing.md"
      L2:
        - "context.md"
    dynamic:
      # 根据任务目标模块动态加载
      per_task:
        - pattern: "code-derived/{module}.md"
          when: "task_targets_module"
    optional:
      L2:
        - "features/registry.json"
    prompt_injection:
      - section: "AI 编码约束"
        source: "L0/ai-coding/ai-coding-policy.md"
        instruction: "以下约束不可违反"
        priority: "HIGHEST"

  analyze:
    description: "跨产物分析"
    required:
      L0:
        - "constitution/*"
      L1:
        - "business/glossary.md"
      L2:
        - "context.md"

  checklist:
    description: "检查清单生成"
    dynamic:
      # 根据清单类型动态加载
      by_type:
        security:
          L0: ["constitution/security-baseline.md", "ai-coding/ai-coding-policy.md"]
        testing:
          L0: ["standards/testing-standards.md"]
          L1: ["standards/testing.md"]
        api:
          L0: ["standards/api-design-guide.md"]
          L1: ["standards/api.md"]
        release:
          L0: ["governance/release-process.md"]
    required:
      L2:
        - "context.md"

  taskstoissues:
    description: "任务转 Issue"
    required:
      L2:
        - "context.md"

# 加载优化配置
loading_optimization:
  cache:
    enabled: true
    ttl_minutes: 30  # 同一会话缓存时间

  lazy_loading:
    enabled: true  # 按需加载，非一次性全量加载

  token_budget:
    max_per_command: 8000  # 单命令知识库加载 Token 上限
    compression:
      enabled: true
      strategy: "summarize"  # summarize | truncate | selective

# 冲突解决规则
conflict_resolution:
  priority_order: ["L0", "L1", "L2"]  # L0 优先级最高
  override_rules:
    L0_constitution: "never"  # 不可覆盖
    L0_standards: "extend_only"  # 仅可扩展，不可减少
    L1_standards: "extend_only"
    L2_context: "full"  # 可完全自定义

# 错误处理
error_handling:
  missing_knowledge_base:
    L0: "ERROR"  # 缺失则阻止流程
    L1: "WARN"   # 缺失则警告
    L2: "SKIP"   # 缺失则跳过
```

---

### 4.2 命令脚本改造

#### 4.2.1 知识库加载器脚本

**文件位置**：`.specify/scripts/bash/load-knowledge.sh`

```bash
#!/bin/bash
# 知识库加载器

COMMAND="$1"
CONFIG_FILE=".specify/knowledge-config.yaml"

# 解析配置文件，获取命令对应的知识库列表
# 返回 JSON 格式的加载列表
load_knowledge_for_command() {
    local cmd="$1"

    # 读取配置
    local required=$(yq e ".command_knowledge_rules.${cmd}.required" "$CONFIG_FILE")
    local optional=$(yq e ".command_knowledge_rules.${cmd}.optional" "$CONFIG_FILE")

    # 构建加载列表
    local load_list=()

    # 处理 L0
    for doc in $(echo "$required" | yq e '.L0[]' -); do
        local path="${L0_PATH}/${doc}"
        if [[ -f "$path" ]]; then
            load_list+=("$path")
        else
            echo "ERROR: Missing required L0 document: $doc" >&2
            exit 1
        fi
    done

    # 处理 L1
    for doc in $(echo "$required" | yq e '.L1[]' -); do
        local path="${L1_PATH}/${doc}"
        if [[ -f "$path" ]]; then
            load_list+=("$path")
        else
            echo "WARN: Missing L1 document: $doc" >&2
        fi
    done

    # 处理 L2
    for doc in $(echo "$required" | yq e '.L2[]' -); do
        local path="${L2_PATH}/${doc}"
        if [[ -f "$path" ]]; then
            load_list+=("$path")
        fi
    done

    # 输出 JSON
    printf '%s\n' "${load_list[@]}" | jq -R . | jq -s .
}

load_knowledge_for_command "$COMMAND"
```

#### 4.2.2 命令文档改造示例

以 `/speckit.plan` 为例，在命令文档中添加知识库加载步骤：

```markdown
## Outline

1. **Setup**: Run `.specify/scripts/bash/setup-plan.sh --json` ...

2. **Load Knowledge Base** (新增步骤):
   ```bash
   # 加载知识库配置
   KNOWLEDGE_LIST=$(.specify/scripts/bash/load-knowledge.sh plan)
   ```

   **必须加载的知识库**：
   - L0/constitution/architecture-principles.md → 架构合规检查
   - L0/constitution/security-baseline.md → 安全红线检查
   - L0/standards/coding-standards/{lang}.md → 语言规范
   - L0/technology-radar/hold.md → 禁用技术检查
   - L1/architecture/tech-stack.md → 项目技术栈
   - L1/architecture/decisions/ADR-*.md → ADR 一致性
   - L2/code-derived/module_tree.json → 模块结构
   - L2/context.md → 仓库上下文

3. **Architecture Compliance Check** (新增步骤):

   在 Phase 0 和 Phase 1 之间执行架构合规检查：

   | 原则 | 检查项 | 来源 | 严重级别 |
   |------|--------|------|----------|
   | I. TDD | 测试策略 | L0/standards/testing-standards.md | CRITICAL |
   | III. 分层架构 | 分层结构 | L0/constitution/architecture-principles.md | CRITICAL |
   | IV. 安全红线 | 输入校验 | L0/constitution/security-baseline.md | CRITICAL |

   **处理规则**：
   - ✅ 全部合规 → 继续
   - ⚠️ 需调整 → 修改设计后继续
   - ❌ 违规 → 阻止流程

4. **Load context**: Read FEATURE_SPEC and `.specify/memory/constitution.md` ...
   (原有步骤)
```

---

### 4.3 Prompt 注入模板

为每个命令设计知识库注入模板：

#### 4.3.1 `/speckit.specify` Prompt 注入

```markdown
## 知识库上下文 (AI 必须遵循)

### 1. 术语规范 [L1/business/glossary.md]

{GLOSSARY_CONTENT}

**约束**：
- 必须使用上述术语词典中的标准术语
- 禁止混用同义词（如"用户"不可写成"客户"）

### 2. 领域模型 [L1/business/domain-model.md]

{DOMAIN_MODEL_CONTENT}

**约束**：
- 不得重新定义已有实体
- 新实体需与现有模型关系清晰

### 3. 仓库边界 [L2/context.md]

{CONTEXT_CONTENT}

**约束**：
- 功能边界必须在本仓库职责范围内
- 跨仓库依赖需在规格中明确标注
```

#### 4.3.2 `/speckit.plan` Prompt 注入

```markdown
## 知识库上下文 (AI 必须遵循)

### 1. 架构底线 [L0/constitution/architecture-principles.md]

{ARCH_PRINCIPLES_CONTENT}

**约束**：以下规则不可违反，违反将阻止流程。

### 2. 安全红线 [L0/constitution/security-baseline.md]

{SECURITY_BASELINE_CONTENT}

**约束**：安全相关设计必须符合上述红线。

### 3. 技术雷达 - 禁用技术 [L0/technology-radar/hold.md]

{HOLD_TECH_CONTENT}

**约束**：禁止使用上述 Hold 技术，如需使用需架构委员会审批。

### 4. 项目技术栈 [L1/architecture/tech-stack.md]

{TECH_STACK_CONTENT}

**约束**：技术选型必须符合项目技术栈，不可引入未定义技术。

### 5. 架构决策记录 [L1/architecture/decisions/ADR-*.md]

{ADR_CONTENT}

**约束**：设计决策必须与现有 ADR 一致，如有冲突需新建 ADR 说明。

### 6. 模块结构 [L2/code-derived/module_tree.json]

{MODULE_TREE_CONTENT}

**约束**：文件路径必须符合现有模块结构。
```

#### 4.3.3 `/speckit.implement` Prompt 注入

```markdown
## 知识库上下文 (AI 必须遵循)

### 1. AI 编码约束 [L0/ai-coding/ai-coding-policy.md] ⚠️ 最高优先级

{AI_CODING_POLICY_CONTENT}

**强制约束**：
- AI 生成的代码必须经过人工 Review 后方可合并
- AI 不得自动提交到 main/master/release 分支
- AI 不得修改安全相关配置文件
- AI 生成的测试必须有有效断言
- 禁止 AI 自动跳过或删除失败的测试

### 2. 编码规范 [L0/standards/coding-standards/{lang}.md]

{CODING_STANDARDS_CONTENT}

### 3. 安全红线 [L0/constitution/security-baseline.md]

{SECURITY_BASELINE_CONTENT}

### 4. 仓库特有规则 [L2/context.md]

{CONTEXT_CONTENT}

### 5. 目标模块文档 [L2/code-derived/{module}.md]

{MODULE_DOC_CONTENT}

**约束**：代码实现必须符合模块现有模式和风格。
```

---

## 5. 实施计划

### 5.1 阶段划分

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         实施阶段                                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Phase 1: 基础设施 (1-2 周)                                              │
│  ─────────────────────────                                              │
│  • 创建 knowledge-config.yaml 配置文件                                   │
│  • 实现 load-knowledge.sh 脚本                                          │
│  • 建立 L0/L1/L2 知识库目录结构                                          │
│                                                                         │
│  Phase 2: 核心命令改造 (2-3 周)                                          │
│  ─────────────────────────                                              │
│  • 改造 /speckit.plan（核心，架构合规检查）                               │
│  • 改造 /speckit.implement（核心，编码规范注入）                          │
│  • 改造 /speckit.specify（术语和领域模型注入）                            │
│                                                                         │
│  Phase 3: 辅助命令改造 (1-2 周)                                          │
│  ─────────────────────────                                              │
│  • 改造 /speckit.clarify                                                │
│  • 改造 /speckit.analyze                                                │
│  • 改造 /speckit.checklist                                              │
│                                                                         │
│  Phase 4: 优化与验证 (1 周)                                              │
│  ─────────────────────────                                              │
│  • Token 优化（缓存、压缩）                                              │
│  • 端到端测试                                                            │
│  • 文档更新                                                              │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 5.2 改造清单

| 序号 | 任务 | 优先级 | 预估工作量 | 依赖 |
|------|------|--------|------------|------|
| 1 | 创建 `.specify/knowledge-config.yaml` | P0 | 2h | - |
| 2 | 实现 `load-knowledge.sh` 脚本 | P0 | 4h | 1 |
| 3 | 建立示例 L0 知识库目录 | P0 | 2h | - |
| 4 | 建立示例 L1 知识库目录 | P0 | 2h | - |
| 5 | 建立示例 L2 知识库目录 | P0 | 1h | - |
| 6 | 改造 `speckit.plan.md` 命令 | P0 | 4h | 1,2 |
| 7 | 改造 `speckit.implement.md` 命令 | P0 | 4h | 1,2 |
| 8 | 改造 `speckit.specify.md` 命令 | P1 | 3h | 1,2 |
| 9 | 改造 `speckit.clarify.md` 命令 | P1 | 2h | 1,2 |
| 10 | 改造 `speckit.analyze.md` 命令 | P1 | 2h | 1,2 |
| 11 | 改造 `speckit.checklist.md` 命令 | P2 | 2h | 1,2 |
| 12 | 实现 Token 缓存机制 | P2 | 4h | 2 |
| 13 | 编写集成测试 | P1 | 4h | 6,7,8 |
| 14 | 更新用户文档 | P2 | 2h | 6-11 |

---

## 6. 预期收益

### 6.1 定量收益

| 指标 | 当前 | 改造后 | 提升 |
|------|------|--------|------|
| 架构合规率 | ~60% | >95% | +35% |
| 术语一致性 | ~70% | >95% | +25% |
| 代码规范符合率 | ~75% | >95% | +20% |
| 安全红线违规 | ~5次/月 | 0次/月 | -100% |
| 返工率 | ~20% | <5% | -75% |

### 6.2 定性收益

1. **合规保障**：L0 企业级约束强制执行，避免生产事故
2. **一致性提升**：术语、架构、编码风格全流程一致
3. **效率优化**：按需加载减少 Token 消耗，提高响应速度
4. **知识复用**：历史决策（ADR）、特性注册表（Feature Registry）有效复用
5. **质量门禁**：架构合规检查作为流程门禁，问题前置发现

---

## 7. 风险与缓解

| 风险 | 影响 | 概率 | 缓解措施 |
|------|------|------|----------|
| 知识库文档缺失 | 命令执行失败 | 中 | 提供默认模板，渐进式填充 |
| Token 预算超限 | 加载失败或截断 | 中 | 实现压缩策略，按需加载 |
| 配置文件复杂度 | 维护成本高 | 低 | 提供 GUI 配置工具 |
| 冲突解决不明确 | 规则执行混乱 | 低 | 明确优先级规则，提供冲突提示 |

---

## 8. 附录

### 8.1 知识库目录结构模板

```
.knowledge/
├── upstream/                    # 上级知识库（Git Subtree）
│   └── L1-project/             # 项目级知识库（含 L0）
│       ├── upstream/           # L0 企业级知识库
│       │   └── L0-enterprise/
│       │       ├── constitution/
│       │       ├── standards/
│       │       ├── governance/
│       │       ├── ai-coding/
│       │       └── technology-radar/
│       ├── business/           # L1 业务知识
│       │   ├── glossary.md
│       │   ├── domain-model.md
│       │   ├── rules.md
│       │   └── workflows/
│       ├── architecture/       # L1 架构知识
│       │   ├── tech-stack.md
│       │   ├── service-catalog.md
│       │   └── decisions/
│       └── standards/          # L1 项目规范
│           ├── coding.md
│           ├── api.md
│           └── testing.md
├── context.md                   # L2 仓库上下文（必须）
├── decisions.md                 # L2 本仓库决策（可选）
├── features/                    # L2 特性归档
│   ├── registry.json
│   └── {feature-id}/
└── code-derived/                # L2 代码衍生文档
    ├── metadata.json
    ├── overview.md
    ├── module_tree.json
    └── {module}.md
```

### 8.2 相关文档

- [02-process-redesign.md](./02-process-redesign.md) - SDD 流程设计
- [05-knowledge-spaces.md](./05-knowledge-spaces.md) - 多级知识空间设计
- [.specify/memory/constitution.md](/.specify/memory/constitution.md) - 项目宪章

---

**文档版本**：1.0.0 | **创建日期**：2025-12-12 | **作者**：Claude
