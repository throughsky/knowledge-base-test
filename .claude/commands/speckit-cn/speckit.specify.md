---
description: 从自然语言功能描述创建或更新功能规范。
handoffs:
  - label: Build Technical Plan
    agent: speckit.plan
    prompt: Create a plan for the spec. I am building with...
  - label: Clarify Spec Requirements
    agent: speckit.clarify
    prompt: Clarify specification requirements
    send: true
---

## 用户输入

```text
$ARGUMENTS
```

你**必须**在继续之前考虑用户输入（如果非空）。

## 概述

用户在触发消息中 `/speckit.specify` 后输入的文本**就是**功能描述。假设你在此对话中始终可以获取它，即使下面字面上出现 `$ARGUMENTS`。除非用户提供了空命令，否则不要要求用户重复。

根据该功能描述，执行以下操作：

1. **生成简洁的短名称**（2-4个单词）用于分支：
   - 分析功能描述并提取最有意义的关键词
   - 创建一个2-4个单词的短名称，捕捉功能的本质
   - 尽可能使用动作-名词格式（例如，"add-user-auth"、"fix-payment-bug"）
   - 保留技术术语和缩写词（OAuth2、API、JWT等）
   - 保持简洁但足够描述性，以便一眼就能理解功能
   - 示例：
     - "I want to add user authentication" → "user-auth"
     - "Implement OAuth2 integration for the API" → "oauth2-api-integration"
     - "Create a dashboard for analytics" → "analytics-dashboard"
     - "Fix payment processing timeout bug" → "fix-payment-timeout"

2. **在创建新分支之前检查现有分支**：

   a. 首先，获取所有远程分支以确保我们拥有最新信息：
      ```bash
      git fetch --all --prune
      ```

   b. 为该短名称在所有来源中查找最高的功能编号：
      - 远程分支：`git ls-remote --heads origin | grep -E 'refs/heads/[0-9]+-<short-name>$'`
      - 本地分支：`git branch | grep -E '^[* ]*[0-9]+-<short-name>$'`
      - specs 目录：检查匹配 `specs/[0-9]+-<short-name>` 的目录

   c. 确定下一个可用编号：
      - 从所有三个来源提取所有编号
      - 找到最高编号 N
      - 为新分支编号使用 N+1

   d. 使用计算出的编号和短名称运行脚本 `.specify/scripts/bash/create-new-feature.sh --json "$ARGUMENTS"`：
      - 传递 `--number N+1` 和 `--short-name "your-short-name"` 以及功能描述
      - Bash 示例：`.specify/scripts/bash/create-new-feature.sh --json "$ARGUMENTS" --json --number 5 --short-name "user-auth" "Add user authentication"`
      - PowerShell 示例：`.specify/scripts/bash/create-new-feature.sh --json "$ARGUMENTS" -Json -Number 5 -ShortName "user-auth" "Add user authentication"`

   **重要**：
   - 检查所有三个来源（远程分支、本地分支、specs 目录）以查找最高编号
   - 只匹配具有精确短名称模式的分支/目录
   - 如果没有找到具有此短名称的现有分支/目录，从编号 1 开始
   - 每个功能只能运行一次此脚本
   - JSON 在终端中作为输出提供 - 始终参考它以获取你要查找的实际内容
   - JSON 输出将包含 BRANCH_NAME 和 SPEC_FILE 路径
   - 对于参数中的单引号，如 "I'm Groot"，使用转义语法：例如 'I'\''m Groot'（或如果可能使用双引号："I'm Groot"）

3. 加载 `.specify/templates/spec-template.md` 以了解所需的章节。

4. 遵循此执行流程：

    1. 从输入解析用户描述
       如果为空：错误 "No feature description provided"
    2. 从描述中提取关键概念
       识别：参与者、操作、数据、约束
    3. 对于不清楚的方面：
       - 根据上下文和行业标准做出合理猜测
       - 仅在以下情况下标记 [NEEDS CLARIFICATION: specific question]：
         - 选择显著影响功能范围或用户体验
         - 存在多种合理解释且具有不同含义
         - 不存在合理的默认值
       - **限制：最多总共 3 个 [NEEDS CLARIFICATION] 标记**
       - 按影响优先排序澄清：范围 > 安全/隐私 > 用户体验 > 技术细节
    4. 填写用户场景和测试部分
       如果没有明确的用户流程：错误 "Cannot determine user scenarios"
    5. 生成功能需求
       每个需求必须是可测试的
       对未指定的细节使用合理的默认值（在假设部分记录假设）
    6. 定义成功标准
       创建可衡量的、与技术无关的结果
       包括定量指标（时间、性能、容量）和定性指标（用户满意度、任务完成）
       每个标准必须在没有实现细节的情况下可验证
    7. 识别关键实体（如果涉及数据）
    8. 返回：成功（规范准备好进行规划）

5. 使用模板结构将规范写入 SPEC_FILE，用从功能描述（参数）派生的具体细节替换占位符，同时保留章节顺序和标题。

6. **规范质量验证**：在编写初始规范后，根据质量标准验证它：

   a. **创建规范质量检查清单**：在 `FEATURE_DIR/checklists/requirements.md` 使用检查清单模板结构生成检查清单文件，包含以下验证项：

      ```markdown
      # Specification Quality Checklist: [FEATURE NAME]

      **Purpose**: 在继续规划之前验证规范的完整性和质量
      **Created**: [DATE]
      **Feature**: [Link to spec.md]

      ## 内容质量

      - [ ] 无实现细节（语言、框架、API）
      - [ ] 专注于用户价值和业务需求
      - [ ] 为非技术利益相关者编写
      - [ ] 所有必填章节已完成

      ## 需求完整性

      - [ ] 不再保留 [NEEDS CLARIFICATION] 标记
      - [ ] 需求是可测试和明确的
      - [ ] 成功标准是可衡量的
      - [ ] 成功标准与技术无关（无实现细节）
      - [ ] 所有验收场景已定义
      - [ ] 边缘情况已识别
      - [ ] 范围已明确界定
      - [ ] 依赖关系和假设已识别

      ## 功能就绪性

      - [ ] 所有功能需求都有明确的验收标准
      - [ ] 用户场景涵盖主要流程
      - [ ] 功能满足成功标准中定义的可衡量结果
      - [ ] 没有实现细节泄漏到规范中

      ## 备注

      - 标记为不完整的项目需要在 `/speckit.clarify` 或 `/speckit.plan` 之前更新规范
      ```

   b. **运行验证检查**：根据每个检查清单项审查规范：
      - 对于每个项目，确定它是通过还是失败
      - 记录发现的具体问题（引用相关规范章节）

   c. **处理验证结果**：

      - **如果所有项目都通过**：标记检查清单完成并继续执行步骤 6

      - **如果项目失败（不包括 [NEEDS CLARIFICATION]）**：
        1. 列出失败的项目和具体问题
        2. 更新规范以解决每个问题
        3. 重新运行验证直到所有项目都通过（最多 3 次迭代）
        4. 如果在 3 次迭代后仍然失败，在检查清单备注中记录剩余问题并警告用户

      - **如果保留 [NEEDS CLARIFICATION] 标记**：
        1. 从规范中提取所有 [NEEDS CLARIFICATION: ...] 标记
        2. **限制检查**：如果存在超过 3 个标记，只保留 3 个最关键的（按范围/安全/用户体验影响），并对其余部分做出合理猜测
        3. 对于每个需要澄清的内容（最多 3 个），以此格式向用户呈现选项：

           ```markdown
           ## Question [N]: [Topic]

           **Context**: [引用相关规范章节]

           **What we need to know**: [来自 NEEDS CLARIFICATION 标记的具体问题]

           **Suggested Answers**:

           | Option | Answer | Implications |
           |--------|--------|--------------|
           | A      | [第一个建议答案] | [这对功能意味着什么] |
           | B      | [第二个建议答案] | [这对功能意味着什么] |
           | C      | [第三个建议答案] | [这对功能意味着什么] |
           | Custom | 提供你自己的答案 | [解释如何提供自定义输入] |

           **Your choice**: _[等待用户响应]_
           ```

        4. **关键 - 表格格式**：确保 markdown 表格格式正确：
           - 使用一致的间距，管道符对齐
           - 每个单元格的内容周围应有空格：`| Content |` 而不是 `|Content|`
           - 标题分隔符必须至少有 3 个破折号：`|--------|`
           - 测试表格在 markdown 预览中是否正确渲染
        5. 按顺序编号问题（Q1、Q2、Q3 - 最多总共 3 个）
        6. 在等待响应之前一起呈现所有问题
        7. 等待用户对所有问题做出选择响应（例如，"Q1: A, Q2: Custom - [details], Q3: B"）
        8. 通过用用户选择或提供的答案替换每个 [NEEDS CLARIFICATION] 标记来更新规范
        9. 解决所有澄清后重新运行验证

   d. **更新检查清单**：在每次验证迭代后，使用当前的通过/失败状态更新检查清单文件

7. 报告完成情况，包括分支名称、规范文件路径、检查清单结果，以及为下一阶段（`/speckit.clarify` 或 `/speckit.plan`）做好准备。

**注意：** 脚本在写入之前创建并检出新分支并初始化规范文件。

## 通用指南

## 快速指南

- 专注于用户需要**什么**以及**为什么**。
- 避免如何实现（没有技术栈、API、代码结构）。
- 为业务利益相关者编写，而不是开发人员。
- 不要创建嵌入在规范中的任何检查清单。那将是一个单独的命令。

### 章节要求

- **必填章节**：每个功能都必须完成
- **可选章节**：仅在与功能相关时包含
- 当章节不适用时，完全删除它（不要留为"N/A"）

### 用于 AI 生成

从用户提示创建此规范时：

1. **做出合理猜测**：使用上下文、行业标准和常见模式来填补空白
2. **记录假设**：在假设部分记录合理的默认值
3. **限制澄清**：最多 3 个 [NEEDS CLARIFICATION] 标记 - 仅用于以下关键决策：
   - 显著影响功能范围或用户体验
   - 具有多种合理解释且具有不同含义
   - 缺乏任何合理的默认值
4. **优先排序澄清**：范围 > 安全/隐私 > 用户体验 > 技术细节
5. **像测试人员一样思考**：每个模糊的需求都应该在"可测试和明确"的检查清单项中失败
6. **需要澄清的常见领域**（仅当不存在合理默认值时）：
   - 功能范围和边界（包括/排除特定用例）
   - 用户类型和权限（如果存在多种相互冲突的解释）
   - 安全/合规要求（当在法律/财务上重要时）

**合理默认值示例**（不要询问这些）：

- 数据保留：该领域的行业标准做法
- 性能目标：除非另有说明，否则为标准 web/移动应用期望
- 错误处理：具有适当回退的用户友好消息
- 身份验证方法：Web 应用的标准基于会话或 OAuth2
- 集成模式：除非另有说明，否则为 RESTful API

### 成功标准指南

成功标准必须：

1. **可衡量**：包括具体指标（时间、百分比、计数、比率）
2. **与技术无关**：不提及框架、语言、数据库或工具
3. **以用户为中心**：从用户/业务角度描述结果，而不是系统内部
4. **可验证**：可以在不知道实现细节的情况下进行测试/验证

**好的示例**：

- "用户可以在 3 分钟内完成结账"
- "系统支持 10,000 个并发用户"
- "95% 的搜索在 1 秒内返回结果"
- "任务完成率提高 40%"

**不好的示例**（以实现为中心）：

- "API 响应时间低于 200ms"（太技术性，使用"用户立即看到结果"）
- "数据库可以处理 1000 TPS"（实现细节，使用面向用户的指标）
- "React 组件高效渲染"（特定于框架）
- "Redis 缓存命中率高于 80%"（特定于技术）
