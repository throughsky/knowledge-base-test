# AI 知识聚合机制

## 设计理念

**核心原则**: 子仓库保持简单，聚合逻辑集中管理

```
┌─────────────────────────────────────────────────────────────────┐
│                      知识流向                                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   L2 仓库知识                    L1 项目知识                    │
│   ┌─────────┐                   ┌─────────────────┐            │
│   │ repo-1  │ ──┐               │ project-web3-   │            │
│   │context.md│   │   AI聚合      │ financial/      │            │
│   └─────────┘   │   ┌─────┐    │ ├─ARCHITECTURE.md│            │
│                 ├──▶│ 分析 │───▶│ ├─BUSINESS.md   │            │
│   ┌─────────┐   │   │ 合并 │    │ └─business/     │            │
│   │ repo-2  │ ──┤   │ 更新 │    └─────────────────┘            │
│   │context.md│   │   └─────┘                                    │
│   └─────────┘   │                                               │
│                 │                                               │
│   ┌─────────┐   │                                               │
│   │ repo-N  │ ──┘                                               │
│   │context.md│                                                   │
│   └─────────┘                                                   │
│                                                                 │
│   开发者维护 ◀────────────────────────▶ AI自动聚合              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 聚合触发方式

### 1. 定时聚合 (推荐)

```yaml
# GitHub Actions: .github/workflows/knowledge-aggregation.yml
name: Knowledge Aggregation

on:
  schedule:
    - cron: '0 2 * * 1'  # 每周一凌晨2点
  workflow_dispatch:      # 手动触发

jobs:
  aggregate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Clone sub-repositories
        run: |
          ./scripts/clone-repos.sh

      - name: Run AI aggregation
        run: |
          ./scripts/ai-aggregate.sh

      - name: Create PR if changes
        run: |
          ./scripts/create-pr.sh
```

### 2. Webhook 触发

当子仓库 `.knowledge/context.md` 变更时触发：

```yaml
# 子仓库配置
on:
  push:
    paths:
      - '.knowledge/**'
    branches:
      - main
```

### 3. 手动触发

```bash
# 在知识库仓库执行
./scripts/aggregate.sh --repos all --mode full
```

## 聚合脚本设计

### 目录结构

```
docs-knowledge/
├── aggregation/
│   ├── README.md           # 本文档
│   ├── config.yaml         # 聚合配置
│   ├── scripts/
│   │   ├── clone-repos.sh  # 克隆子仓库
│   │   ├── aggregate.sh    # 聚合主脚本
│   │   └── prompts/        # AI提示词
│   │       ├── analyze-changes.md
│   │       └── update-docs.md
│   └── cache/              # 上次聚合快照 (gitignore)
└── project-web3-financial/ # 项目知识库
```

## 子仓库 CLAUDE.md 模板

子仓库只需维护简单的 CLAUDE.md：

```markdown
# [服务名] Service

> [一句话描述]

## 项目上下文

本仓库是 Web3 金融服务平台的一部分。

- 项目知识库: https://github.com/org/knowledge-base
- 架构文档: knowledge-base/project-web3-financial/ARCHITECTURE.md
- 业务文档: knowledge-base/project-web3-financial/BUSINESS.md

## 本仓库上下文

详细上下文请查看: `.knowledge/context.md`

## AI 助手提示

当需要理解项目整体架构时，请参考项目知识库。
当需要理解本服务细节时，请参考 `.knowledge/context.md`。
```

## 聚合产出

每次聚合产出：

1. **变更报告** (`aggregation/reports/YYYY-MM-DD.md`)
   - 各仓库 context.md 变更摘要
   - 跨仓库影响分析
   - 建议的项目文档更新

2. **更新 PR**
   - 自动更新项目级文档
   - 包含变更说明和 reviewer 建议

3. **聚合日志** (`aggregation/logs/`)
   - 聚合过程记录
   - 错误和警告
