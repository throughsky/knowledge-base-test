# 知识聚合方案对比与推荐

## 方案对比

| 维度 | Git Subtree | Git Submodule | AI 主动拉取 (推荐) |
|------|------------|---------------|-------------------|
| **子仓库复杂度** | 高 (需维护subtree) | 中 (需submodule命令) | 低 (无额外依赖) |
| **知识同步** | 手动 subtree pull | 手动 submodule update | 自动定时聚合 |
| **子仓库体积** | 增大 (包含知识库) | 不变 (仅引用) | 不变 |
| **开发者学习成本** | 高 | 中 | 低 |
| **智能分析能力** | 无 | 无 | 有 (AI驱动) |
| **变更追踪** | 手动 | 手动 | 自动报告 |
| **适用规模** | 小型项目 | 中型项目 | 任意规模 |

## 推荐方案：AI 主动拉取

```
┌────────────────────────────────────────────────────────────────┐
│                      整体架构                                   │
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
│   │ ├─ src/      │              └──────────────────────┘      │
│   │ ├─ CLAUDE.md │                       │                    │
│   │ └─ .knowledge│              ┌────────▼────────┐          │
│   │    └─context │ ───拉取───▶  │   AI 聚合系统   │          │
│   └──────────────┘              │  ┌────────────┐ │          │
│         ...                     │  │ 1.收集变更 │ │          │
│                                 │  │ 2.分析影响 │ │          │
│                                 │  │ 3.更新文档 │ │          │
│                                 │  │ 4.生成报告 │ │          │
│                                 │  └────────────┘ │          │
│                                 └─────────────────┘          │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

## 快速开始

### 1. 配置知识库仓库

```bash
# 克隆知识库
git clone https://github.com/org/knowledge-base.git
cd knowledge-base

# 配置聚合
vim docs-knowledge/aggregation/config.yaml

# 测试聚合
./docs-knowledge/aggregation/scripts/aggregate.sh --dry-run
```

### 2. 配置子仓库

每个子仓库只需：

```
子仓库/
├── src/
├── CLAUDE.md              # 简洁入口 (见模板)
└── .knowledge/
    └── context.md         # 详细上下文 (开发者维护)
```

**CLAUDE.md 模板**:

```markdown
# [服务名] Service

> [一句话描述]

## 项目上下文

本仓库是 Web3 金融服务平台的一部分。
项目知识库: https://github.com/org/knowledge-base

## 本仓库上下文

详见: `.knowledge/context.md`
```

### 3. 设置自动聚合

```bash
# 复制 GitHub Actions 配置
cp docs-knowledge/aggregation/github-actions-example.yaml \
   .github/workflows/knowledge-aggregation.yml

# 配置 secrets
# - ANTHROPIC_API_KEY: Claude API 密钥
# - SLACK_WEBHOOK: (可选) Slack 通知
```

### 4. 触发聚合

```bash
# 方式1: 定时自动 (每周一)
# 已在 GitHub Actions 中配置

# 方式2: 手动触发
gh workflow run knowledge-aggregation.yml

# 方式3: 本地执行
./docs-knowledge/aggregation/scripts/aggregate.sh --mode full
```

## 聚合输出

每次聚合产出：

1. **聚合报告** (`aggregation/reports/YYYY-MM-DD.md`)
2. **更新 PR** (包含文档变更)
3. **Slack 通知** (可选)

## 为什么不推荐 Git Subtree/Submodule？

| 问题 | 影响 |
|------|------|
| 增加子仓库复杂度 | 开发者需要学习额外的 git 命令 |
| 同步负担分散 | 每个子仓库都要执行同步操作 |
| 无智能分析 | 无法自动识别变更影响 |
| 版本冲突风险 | 多仓库同时修改可能冲突 |
| 难以审计 | 知识更新分散在各仓库历史中 |

**AI 主动拉取**解决了这些问题：
- ✅ 子仓库零负担
- ✅ 聚合逻辑集中
- ✅ AI 智能分析
- ✅ 自动变更报告
- ✅ 审核流程清晰
