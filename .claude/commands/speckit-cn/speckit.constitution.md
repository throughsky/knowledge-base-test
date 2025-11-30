---
description: 从交互式或提供的原则输入创建或更新项目章程，确保所有依赖模板保持同步。
handoffs:
  - label: Build Specification
    agent: speckit.specify
    prompt: Implement the feature specification based on the updated constitution. I want to build...
---

## 用户输入

```text
$ARGUMENTS
```

你**必须**在继续之前考虑用户输入（如果非空）。

## 概述

你正在更新位于 `.specify/memory/constitution.md` 的项目章程。此文件是一个模板，包含方括号中的占位符令牌（例如 `[PROJECT_NAME]`、`[PRINCIPLE_1_NAME]`）。你的工作是 (a) 收集/派生具体值，(b) 精确填充模板，以及 (c) 在依赖制品之间传播任何修正。

遵循此执行流程：

1. 在 `.specify/memory/constitution.md` 加载现有章程模板。
   - 识别形式为 `[ALL_CAPS_IDENTIFIER]` 的每个占位符令牌。
   **重要**：用户可能需要比模板中使用的原则更少或更多的原则。如果指定了数字，请尊重 - 遵循一般模板。你将相应地更新文档。

2. 收集/派生占位符的值：
   - 如果用户输入（对话）提供值，使用它。
   - 否则从现有仓库上下文（README、文档、先前章程版本如果嵌入）推断。
   - 对于治理日期：`RATIFICATION_DATE` 是原始采用日期（如果未知询问或标记 TODO），如果进行更改，`LAST_AMENDED_DATE` 是今天，否则保留之前的。
   - `CONSTITUTION_VERSION` 必须根据语义版本控制规则递增：
     - 主要：向后不兼容的治理/原则删除或重新定义。
     - 次要：添加或实质性扩展的新原则/章节。
     - 补丁：澄清、措辞、拼写错误修复、非语义改进。
   - 如果版本升级类型模糊，在最终确定前提出理由。

3. 起草更新的章程内容：
   - 用具体文本替换每个占位符（除非项目选择尚未定义的故意保留的模板槽，否则不留下带括号的令牌 - 明确证明任何保留的）。
   - 保留标题层次结构，一旦替换就可以删除注释，除非它们仍添加澄清指导。
   - 确保每个原则章节：简洁的名称行、捕获不可协商规则的段落（或项目符号列表）、如果不明显则明确理由。
   - 确保治理章节列出修正程序、版本控制政策和合规审查期望。

4. 一致性传播检查清单（将先前的检查清单转换为主动验证）：
   - 读取 `.specify/templates/plan-template.md` 并确保任何"章程检查"或规则与更新的原则对齐。
   - 读取 `.specify/templates/spec-template.md` 以进行范围/需求对齐 - 如果章程添加/删除强制性章节或约束，则更新。
   - 读取 `.specify/templates/tasks-template.md` 并确保任务分类反映新的或删除的原则驱动的任务类型（例如，可观察性、版本控制、测试纪律）。
   - 读取 `.specify/templates/commands/*.md` 中的每个命令文件（包括此文件）以验证当需要通用指导时不存在过时的引用（仅特定于代理的名称，如 CLAUDE）。
   - 读取任何运行时指导文档（例如，`README.md`、`docs/quickstart.md` 或特定于代理的指导文件（如果存在））。更新对更改的原则的引用。

5. 生成同步影响报告（在更新后作为 HTML 注释添加到章程文件顶部）：
   - 版本更改：旧 → 新
   - 修改的原则列表（如果重命名，旧标题 → 新标题）
   - 添加的章节
   - 删除的章节
   - 需要更新的模板（✅ 已更新 / ⚠ 待处理）以及文件路径
   - 如果任何占位符故意延迟，则跟进 TODO

6. 最终输出前的验证：
   - 没有剩余的未解释的括号令牌。
   - 版本行与报告匹配。
   - 日期 ISO 格式 YYYY-MM-DD。
   - 原则是声明性的、可测试的，并且没有模糊语言（"应该" → 在适当的地方用 MUST/SHOULD 理由替换）。

7. 将完成的章程写回 `.specify/memory/constitution.md`（覆盖）。

8. 向用户输出最终摘要：
   - 新版本和升级理由。
   - 任何标记为手动跟进的文件。
   - 建议的提交消息（例如，`docs: amend constitution to vX.Y.Z (principle additions + governance update)`）。

格式和样式要求：

- 完全按照模板中的 Markdown 标题使用（不要降级/升级级别）。
- 包装长理由行以保持可读性（<100 个字符理想情况下），但不要使用笨拙的中断强制执行。
- 在章节之间保留一个空行。
- 避免尾随空格。

如果用户提供部分更新（例如，仅一个原则修订），仍然执行验证和版本决策步骤。

如果缺少关键信息（例如，批准日期真正未知），插入 `TODO(<FIELD_NAME>): explanation` 并在延迟项目下的同步影响报告中包含。

不要创建新模板；始终在现有的 `.specify/memory/constitution.md` 文件上操作。
