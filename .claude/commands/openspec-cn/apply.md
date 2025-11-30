---
name: OpenSpec: Apply
description: 实现一个已批准的 OpenSpec 变更并保持任务同步。
category: OpenSpec
tags: [openspec, apply]
---
<!-- OPENSPEC:START -->
**开发准则**
- 优先采用直接、最小的实现方式，仅在明确需要时才增加复杂性。
- 保持变更范围严格聚焦于请求的结果。
- 如果需要额外的 OpenSpec 约定或说明，请参考 `openspec/AGENTS.md`（位于 `openspec/` 目录内——如果看不到，请运行 `ls openspec` 或 `openspec update`）。

**步骤**
将这些步骤作为 TODO 逐一跟踪并完成。
1. 阅读 `changes/<id>/proposal.md`、`design.md`（如果存在）和 `tasks.md`，以确认范围和验收标准。
2. 按顺序执行任务，保持编辑最小化并专注于请求的变更。
3. 在更新状态之前确认完成——确保 `tasks.md` 中的每个项目都已完成。
4. 在所有工作完成后更新清单，使每个任务标记为 `- [x]` 并反映实际情况。
5. 当需要更多上下文时，参考 `openspec list` 或 `openspec show <item>`。

**参考**
- 如果在实现过程中需要从提案中获取额外上下文，请使用 `openspec show <id> --json --deltas-only`。
<!-- OPENSPEC:END -->
