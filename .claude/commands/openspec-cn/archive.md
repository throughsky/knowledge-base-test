---
name: OpenSpec: Archive
description: 归档一个已部署的 OpenSpec 变更并更新规范。
category: OpenSpec
tags: [openspec, archive]
---
<!-- OPENSPEC:START -->
**开发准则**
- 优先采用直接、最小的实现方式，仅在明确需要时才增加复杂性。
- 保持变更范围严格聚焦于请求的结果。
- 如果需要额外的 OpenSpec 约定或说明，请参考 `openspec/AGENTS.md`（位于 `openspec/` 目录内——如果看不到，请运行 `ls openspec` 或 `openspec update`）。

**步骤**
1. 确定要归档的变更 ID：
   - 如果此提示已包含特定的变更 ID（例如在由斜杠命令参数填充的 `<ChangeId>` 块内），请在去除空白字符后使用该值。
   - 如果对话松散地引用了一个变更（例如通过标题或摘要），运行 `openspec list` 以列出可能的 ID，分享相关候选项，并确认用户意图。
   - 否则，查看对话内容，运行 `openspec list`，并询问用户要归档哪个变更；等待确认变更 ID后再继续。
   - 如果仍然无法识别单个变更 ID，请停止并告知用户目前还无法归档任何内容。
2. 通过运行 `openspec list`（或 `openspec show <id>`）来验证变更 ID，如果变更缺失、已归档或其他情况下未准备好归档，请停止。
3. 运行 `openspec archive <id> --yes`，使 CLI 移动变更并在无提示的情况下应用规范更新（仅针对工具性工作时使用 `--skip-specs`）。
4. 查看命令输出，确认目标规范已更新且变更已落入 `changes/archive/`。
5. 使用 `openspec validate --strict` 进行验证，如果有任何异常，使用 `openspec show <id>` 检查。

**参考**
- 在归档前使用 `openspec list` 确认变更 ID。
- 使用 `openspec list --specs` 检查刷新后的规范，并在交接前解决任何验证问题。
<!-- OPENSPEC:END -->
