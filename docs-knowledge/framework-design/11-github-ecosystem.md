# 第11章 GitHub 生态全栈方案

本章介绍基于 GitHub 生态的 AI Coding 研发流程完整技术栈，覆盖规划、开发、交付、安全全链路。

## 11.1 技术栈全景

```
┌─────────────────────────────────────────────────────────────────────┐
│                    GitHub 生态 AI Coding 全栈                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐               │
│  │  规划层     │   │  开发层     │   │  交付层     │               │
│  │             │   │             │   │             │               │
│  │ • Projects  │   │ • Copilot   │   │ • Actions   │               │
│  │ • Issues    │   │ • Workspace │   │ • Packages  │               │
│  │ • Milestones│   │ • Codespaces│   │ • Pages     │               │
│  └──────┬──────┘   └──────┬──────┘   └──────┬──────┘               │
│         │                 │                 │                       │
│         └─────────────────┼─────────────────┘                       │
│                           │                                         │
│  ┌────────────────────────┴────────────────────────┐               │
│  │                 安全与质量层                      │               │
│  │                                                  │               │
│  │  • Secret Protection  • Code Security           │               │
│  │  • Dependabot        • Code Scanning            │               │
│  │  • Push Protection   • Security Campaigns       │               │
│  └──────────────────────────────────────────────────┘               │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 11.2 规划层：GitHub Projects + Issues

### 11.2.1 核心能力

| 能力 | GitHub 工具 | AI 增强 | 说明 |
|------|-------------|---------|------|
| **需求管理** | Issues + Sub-issues | Copilot 自动拆解 | 支持父子层级，复杂项目分解 |
| **看板管理** | Projects (Board) | 自动化规则 | 支持 Scrum/Kanban 视图 |
| **路线图** | Projects (Roadmap) | - | 时间线规划，依赖关系可视化 |
| **任务分配** | Assignees + Copilot | **可直接分配给 Copilot** | Copilot 自主编码、创建 PR |
| **里程碑** | Milestones | - | 版本规划，进度跟踪 |

### 11.2.2 Issue 模板配置

```yaml
# .github/ISSUE_TEMPLATE/feature_request.yml
name: 功能需求
description: 提交新功能需求
title: "[Feature] "
labels: ["enhancement", "triage"]
body:
  - type: markdown
    attributes:
      value: |
        请按照 SDD 规范填写需求信息

  - type: textarea
    id: user-story
    attributes:
      label: 用户故事
      description: 作为[角色]，我希望[功能]，以便[价值]
      placeholder: "作为用户，我希望..."
    validations:
      required: true

  - type: textarea
    id: acceptance-criteria
    attributes:
      label: 验收标准
      description: 列出验收条件（Given-When-Then）
      placeholder: |
        - [ ] Given...When...Then...
    validations:
      required: true

  - type: dropdown
    id: priority
    attributes:
      label: 优先级
      options:
        - P0-紧急
        - P1-高
        - P2-中
        - P3-低
    validations:
      required: true
```

### 11.2.3 Projects 自动化规则

```yaml
# Projects 自动化配置示例
automations:
  # Issue 创建时自动添加到 Backlog
  - trigger: issue_opened
    action: add_to_project
    column: Backlog

  # PR 创建时自动关联 Issue
  - trigger: pull_request_opened
    action: link_to_issue
    pattern: "closes #\\d+"

  # PR 合并时自动移动到 Done
  - trigger: pull_request_merged
    action: move_to_column
    column: Done

  # 分配给 Copilot 时自动添加标签
  - trigger: assigned_to_copilot
    action: add_label
    label: "ai-coding"
```

---

## 11.3 开发层：GitHub Copilot 家族

### 11.3.1 Copilot 产品矩阵

| 产品 | 定位 | 适用场景 | 价格 |
|------|------|----------|------|
| **Copilot Free** | 基础代码补全 | 个人学习、小项目 | 免费（2000补全/月） |
| **Copilot Pro** | 完整 AI 编程助手 | 个人开发者 | $10/月 |
| **Copilot Pro+** | 高级功能 + Coding Agent | 专业开发者 | $39/月 |
| **Copilot Business** | 团队协作 | 中小团队 | $19/人/月 |
| **Copilot Enterprise** | 企业级 + 知识库 | 大型企业 | $39/人/月 |

### 11.3.2 Copilot 核心能力

| 能力 | 说明 | 触发方式 |
|------|------|----------|
| **代码补全** | 智能代码建议 | 自动触发 |
| **Chat** | 对话式编程助手 | `Ctrl+I` 或侧边栏 |
| **Agent Mode** | 自主多文件编辑 | Chat 中启用 |
| **Inline Chat** | 行内代码修改 | 选中代码后 `Ctrl+I` |
| **Explain** | 代码解释 | 右键菜单 |
| **Fix** | 自动修复错误 | 错误提示处点击 |
| **Generate Tests** | 生成测试代码 | 右键菜单 |
| **Generate Docs** | 生成文档注释 | 右键菜单 |

### 11.3.3 Copilot Workspace 工作流

```
┌─────────────────────────────────────────────────────────────────────┐
│                  Copilot Workspace 工作流                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐               │
│  │  Issue      │ → │  Spec       │ → │  Plan       │               │
│  │  输入需求   │   │  生成规格   │   │  生成计划   │               │
│  └─────────────┘   └─────────────┘   └─────────────┘               │
│                                              ↓                      │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐               │
│  │  PR         │ ← │  Test       │ ← │  Code       │               │
│  │  提交审查   │   │  运行测试   │   │  生成代码   │               │
│  └─────────────┘   └─────────────┘   └─────────────┘               │
│                                                                     │
│  全程可人工介入编辑，保持完全控制                                    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 11.3.4 Copilot Coding Agent

将 Issue 直接分配给 Copilot，AI 自主完成编码：

**工作机制**：

1. 开发者将 Issue 分配给 `@copilot`
2. Copilot 在云端启动开发环境（基于 Actions）
3. 自主分析代码库、编写代码、运行测试
4. 创建 Draft PR 并持续推送 commits
5. 开发者审查、反馈，Copilot 响应修改

**适用场景**：

| 场景 | 适合度 | 说明 |
|------|--------|------|
| Bug 修复 | ⭐⭐⭐⭐⭐ | 明确的问题，有测试验证 |
| 小功能实现 | ⭐⭐⭐⭐ | 边界清晰的独立功能 |
| 重构任务 | ⭐⭐⭐ | 需要清晰的重构指令 |
| 复杂功能 | ⭐⭐ | 建议人工主导，AI 辅助 |
| 架构设计 | ⭐ | 不适合，需人类决策 |

### 11.3.5 Agent HQ 多 Agent 编排

GitHub Agent HQ（Universe 2025 发布）支持多家 AI Agent 协作：

| Agent 提供商 | 特点 | 集成状态 |
|--------------|------|----------|
| **GitHub Copilot** | 原生集成，深度优化 | ✅ 可用 |
| **Anthropic Claude** | 长上下文，复杂推理 | ✅ 可用 |
| **OpenAI** | GPT-4o, o1, o3-mini | ✅ 可用 |
| **Google Gemini** | Gemini 2.0 Flash | ✅ 可用 |
| **Cognition Devin** | 自主软件工程师 | 🔜 即将 |
| **xAI Grok** | 实时信息 | 🔜 即将 |

---

## 11.4 交付层：GitHub Actions

### 11.4.1 CI/CD 核心能力

| 能力 | 说明 | 配额（Team） |
|------|------|--------------|
| **构建** | 多语言构建支持 | 3000分钟/月 |
| **测试** | 单元测试、集成测试、E2E | 包含在构建配额 |
| **部署** | 支持所有主流云平台 | 包含在构建配额 |
| **Runners** | GitHub 托管 / 自托管 | 无限（自托管） |
| **Marketplace** | 25000+ 预置 Actions | 免费使用 |

### 11.4.2 AI 增强的 Actions

**Issue 智能分类**：

```yaml
# .github/workflows/ai-issue-triage.yml
name: AI Issue Triage

on:
  issues:
    types: [opened]

jobs:
  triage:
    runs-on: ubuntu-latest
    steps:
      - name: AI 分析 Issue
        uses: actions/ai-inference@v1
        id: analysis
        with:
          model: gpt-4o-mini
          prompt: |
            分析以下 Issue，返回 JSON 格式：
            {
              "type": "bug|feature|question|docs",
              "priority": "P0|P1|P2|P3",
              "components": ["组件列表"],
              "is_complete": true/false,
              "missing_info": ["缺失信息列表"]
            }

            Issue 标题: ${{ github.event.issue.title }}
            Issue 内容: ${{ github.event.issue.body }}

      - name: 添加标签
        uses: actions/github-script@v7
        with:
          script: |
            const analysis = JSON.parse('${{ steps.analysis.outputs.result }}');
            await github.rest.issues.addLabels({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              labels: [analysis.type, analysis.priority]
            });
```

**PR 自动摘要**：

```yaml
# .github/workflows/pr-summary.yml
name: PR Summary

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  summarize:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: 获取变更
        id: diff
        run: |
          echo "diff<<EOF" >> $GITHUB_OUTPUT
          git diff ${{ github.event.pull_request.base.sha }}...${{ github.event.pull_request.head.sha }} --stat >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - name: AI 生成摘要
        uses: actions/ai-inference@v1
        id: summary
        with:
          model: gpt-4o-mini
          prompt: |
            根据以下代码变更，生成 PR 摘要：

            变更统计:
            ${{ steps.diff.outputs.diff }}

            请生成：
            1. 变更概述（1-2句话）
            2. 主要改动点（bullet points）
            3. 潜在影响
            4. 建议的审查重点

      - name: 更新 PR 描述
        uses: actions/github-script@v7
        with:
          script: |
            const summary = `${{ steps.summary.outputs.result }}`;
            const currentBody = context.payload.pull_request.body || '';
            const newBody = currentBody + '\n\n---\n## AI 生成摘要\n' + summary;
            await github.rest.pulls.update({
              owner: context.repo.owner,
              repo: context.repo.repo,
              pull_number: context.payload.pull_request.number,
              body: newBody
            });
```

**每周 Issue 总结**：

```yaml
# .github/workflows/weekly-summary.yml
name: Weekly Issue Summary

on:
  schedule:
    - cron: '0 9 * * 1'  # 每周一早9点
  workflow_dispatch:

jobs:
  summary:
    runs-on: ubuntu-latest
    steps:
      - name: 获取本周 Issues
        uses: actions/github-script@v7
        id: issues
        with:
          script: |
            const lastWeek = new Date();
            lastWeek.setDate(lastWeek.getDate() - 7);
            const issues = await github.rest.issues.listForRepo({
              owner: context.repo.owner,
              repo: context.repo.repo,
              since: lastWeek.toISOString(),
              state: 'all'
            });
            return issues.data.map(i => ({
              title: i.title,
              state: i.state,
              labels: i.labels.map(l => l.name)
            }));

      - name: AI 生成周报
        uses: actions/ai-inference@v1
        id: report
        with:
          model: gpt-4o-mini
          prompt: |
            根据以下本周 Issues 数据生成周报：
            ${{ steps.issues.outputs.result }}

            包含：
            1. 本周新增 Issues 统计
            2. 已关闭 Issues 统计
            3. 按类型分类汇总
            4. 优先级分布
            5. 建议下周关注重点

      - name: 创建周报 Issue
        uses: actions/github-script@v7
        with:
          script: |
            await github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `📊 Weekly Summary - ${new Date().toISOString().split('T')[0]}`,
              body: `${{ steps.report.outputs.result }}`,
              labels: ['weekly-summary']
            });
```

---

## 11.5 安全与质量层

### 11.5.1 GitHub Security 产品

| 产品 | 价格 | 核心能力 |
|------|------|----------|
| **GitHub Secret Protection** | $19/人/月 | 密钥泄露检测、Push 保护、AI 密码检测、自定义模式 |
| **GitHub Code Security** | $30/人/月 | CodeQL 扫描、Copilot Autofix、安全战役、依赖审查 |
| **Dependabot** | 免费 | 依赖漏洞告警、自动更新 PR、版本更新 |

### 11.5.2 安全配置

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
    open-pull-requests-limit: 10
    labels:
      - "dependencies"
      - "security"
    reviewers:
      - "security-team"
    commit-message:
      prefix: "chore(deps)"
    groups:
      production-dependencies:
        patterns:
          - "*"
        exclude-patterns:
          - "@types/*"
          - "*-types"
      development-dependencies:
        dependency-type: "development"
```

```yaml
# .github/workflows/security-scan.yml
name: Security Scan

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 2 * * 1'  # 每周一凌晨2点

jobs:
  codeql:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
    steps:
      - uses: actions/checkout@v4

      - name: Initialize CodeQL
        uses: github/codeql-action/init@v3
        with:
          languages: javascript, typescript
          queries: security-extended

      - name: Autobuild
        uses: github/codeql-action/autobuild@v3

      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v3
        with:
          category: "/language:javascript"

  secret-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Secret Scanning
        uses: trufflesecurity/trufflehog@main
        with:
          extra_args: --only-verified

  dependency-review:
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v4

      - name: Dependency Review
        uses: actions/dependency-review-action@v4
        with:
          fail-on-severity: high
          deny-licenses: GPL-3.0, AGPL-3.0
```

### 11.5.3 安全门禁配置

```yaml
# Branch Protection Rules（通过 GitHub UI 或 API 配置）
branch_protection:
  required_status_checks:
    strict: true
    contexts:
      - "codeql"
      - "secret-scan"
      - "dependency-review"
      - "test"
      - "build"

  required_pull_request_reviews:
    required_approving_review_count: 2
    dismiss_stale_reviews: true
    require_code_owner_reviews: true
    require_last_push_approval: true

  restrictions:
    users: []
    teams: ["maintainers"]

  enforce_admins: true
  required_linear_history: true
  allow_force_pushes: false
  allow_deletions: false
```

---

## 11.6 项目级 AI 配置

### 11.6.1 .copilot-instructions.md

```markdown
# Copilot Instructions

## 项目概述
这是一个 TypeScript + React 的前端项目，使用 Vite 构建。

## 编码规范

### 命名约定
- 组件: PascalCase (e.g., `UserProfile.tsx`)
- 函数: camelCase (e.g., `getUserData()`)
- 常量: UPPER_SNAKE_CASE (e.g., `MAX_RETRY_COUNT`)
- 类型/接口: PascalCase with prefix (e.g., `IUserProps`, `TUserState`)

### 代码风格
- 使用 TypeScript strict 模式
- 优先使用函数组件 + Hooks
- 使用 named exports 而非 default exports
- 每个文件不超过 300 行

### 测试要求
- 所有公共函数必须有单元测试
- 测试文件放在 `__tests__` 目录
- 使用 Vitest 测试框架
- 覆盖率目标: 80%

## 禁止事项
- 不要使用 `any` 类型
- 不要使用 `console.log`（使用 logger）
- 不要提交 `.env` 文件
- 不要使用已废弃的 API
```

### 11.6.2 AGENTS.md

```markdown
# AGENTS.md - AI Agent 协作配置

## 环境配置

### 构建命令
npm install      # 安装依赖
npm run build    # 构建项目
npm run dev      # 启动开发服务器

### 测试命令
npm test              # 运行所有测试
npm run test:unit     # 单元测试
npm run test:e2e      # E2E 测试
npm run coverage      # 生成覆盖率报告

### Linter 命令
npm run lint          # 运行 ESLint
npm run lint:fix      # 自动修复
npm run typecheck     # TypeScript 类型检查

## 质量门禁

### 必须通过
- [ ] `npm run lint` 无错误
- [ ] `npm run typecheck` 无错误
- [ ] `npm test` 全部通过
- [ ] 代码覆盖率 ≥ 80%

### 提交前检查
- [ ] 新代码有对应测试
- [ ] 更新相关文档
- [ ] 无敏感信息泄露

## 文件操作权限

### 可修改
- `src/**/*` - 源代码
- `tests/**/*` - 测试文件
- `docs/**/*` - 文档

### 禁止修改
- `.env*` - 环境变量
- `credentials.*` - 凭证文件
- `secrets/` - 密钥目录
- `.github/workflows/*` - CI/CD 配置（需人工审批）

### 禁止删除
- `tests/` - 测试目录
- `migrations/` - 数据库迁移
- `src/core/` - 核心模块

## 代码审查要点

### 安全检查
- 无硬编码密钥
- 输入已校验
- SQL 已参数化
- XSS 已防护

### 性能检查
- 无 N+1 查询
- 大循环已优化
- 内存泄漏已处理

### 架构检查
- 遵循分层架构
- 依赖方向正确
- 接口契约完整
```

---

## 11.7 与 AI Coding 流程体系集成

### 11.7.1 流程映射

| AI Coding 流程阶段 | GitHub 工具 | 集成方式 |
|--------------------|-------------|----------|
| **SDD 规范驱动** | Issues + Projects | Issue 模板定义规格，Projects 管理工作流 |
| **TDD 测试驱动** | Actions + Copilot | Actions 运行测试，Copilot 生成测试代码 |
| **Code Review** | PR + Code Security | Copilot 自动审查，CodeQL 安全扫描 |
| **知识库 L2** | `.copilot-instructions.md` + `AGENTS.md` | 项目级 AI 指令配置 |
| **文档生成** | Actions + CodeWiki | PR 合并触发文档更新 |
| **安全保障** | Secret Protection + Dependabot | 自动检测密钥泄露和依赖漏洞 |

### 11.7.2 SDD 工作流集成

```
┌─────────────────────────────────────────────────────────────────────┐
│              SDD + GitHub 集成工作流                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Issue (需求)                                                 │   │
│  │ • 使用 Issue 模板填写需求                                    │   │
│  │ • AI 自动分类、添加标签                                      │   │
│  │ • 添加到 Projects Board                                      │   │
│  └──────────────────────────┬──────────────────────────────────┘   │
│                              ↓                                      │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Copilot Workspace / Speckit                                  │   │
│  │ • 从 Issue 生成 Spec (spec.md)                               │   │
│  │ • 生成实施计划 (plan.md)                                     │   │
│  │ • 生成任务列表 (tasks.md)                                    │   │
│  └──────────────────────────┬──────────────────────────────────┘   │
│                              ↓                                      │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Coding Agent / 人工开发                                      │   │
│  │ • 简单任务：分配给 @copilot 自主完成                         │   │
│  │ • 复杂任务：人工 + Copilot Agent Mode                        │   │
│  └──────────────────────────┬──────────────────────────────────┘   │
│                              ↓                                      │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Pull Request                                                 │   │
│  │ • Actions 自动运行测试、安全扫描                             │   │
│  │ • AI 生成 PR 摘要                                            │   │
│  │ • Copilot 辅助 Code Review                                   │   │
│  │ • 人工最终审批                                               │   │
│  └──────────────────────────┬──────────────────────────────────┘   │
│                              ↓                                      │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Merge & Deploy                                               │   │
│  │ • Actions 自动部署                                           │   │
│  │ • CodeWiki 更新知识库                                        │   │
│  │ • Issue 自动关闭                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 11.7.3 D-R-O 职责映射

| SDLC 阶段 | 委派 (GitHub AI) | 审查 (人类 + GitHub) | 掌控 (人类) |
|-----------|------------------|---------------------|-------------|
| **规划** | Copilot 分解 Issue、估算工时 | Projects 看板审查 | 优先级决策、里程碑规划 |
| **设计** | Copilot Workspace 生成 Spec | PR Review 验证设计 | 架构决策、技术选型 |
| **构建** | Coding Agent 实现功能 | Actions 测试 + CodeQL 扫描 | 复杂逻辑、核心模块 |
| **测试** | Copilot 生成测试用例 | Actions 运行测试 + 覆盖率 | 测试策略、质量标准 |
| **审查** | Copilot Code Review | 人工审查 + 安全门禁 | 最终合并决策 |
| **文档** | CodeWiki 自动生成 | 人工验证准确性 | 对外文档、关键文档 |
| **运维** | Dependabot 自动更新 | 安全告警审查 | 生产事故处理 |

---

## 11.8 推荐方案

### 11.8.1 按团队规模选型

**个人开发者 / 小团队（1-5人）**：

```
GitHub Free + Copilot Pro ($10/月)
├── Issues + Projects（基础看板）
├── Copilot 代码补全 + Chat
├── Actions（2000分钟/月）
├── Dependabot（免费）
├── Secret Scanning（公开仓库免费）
└── 月成本: ~$10/人
```

**中型团队（5-50人）**：

```
GitHub Team ($4/人/月) + Copilot Business ($19/人/月)
├── Projects 高级功能
├── Copilot Agent Mode
├── Actions（3000分钟/月）
├── Secret Protection（可选 $19/人/月）
├── Protected Branches + Required Reviews
├── CODEOWNERS
└── 月成本: ~$23-42/人
```

**大型团队 / 企业（50+人）**：

```
GitHub Enterprise + Copilot Enterprise ($39/人/月)
├── Copilot Workspace + Coding Agent
├── Agent HQ（多 Agent 编排）
├── GitHub Advanced Security（完整套件）
├── SAML SSO + SCIM
├── Audit Log API
├── 自托管 Runners
├── 专属支持
└── 月成本: ~$60-100/人（含 GHAS）
```

### 11.8.2 实施路径

**第一阶段：基础能力（1-2周）**

- [ ] 配置 `.copilot-instructions.md`
- [ ] 配置 `AGENTS.md`
- [ ] 启用 Dependabot
- [ ] 配置 Issue 模板
- [ ] 建立 Projects 看板

**第二阶段：CI/CD 自动化（2-4周）**

- [ ] 配置 Actions 构建流程
- [ ] 集成测试自动化
- [ ] 启用 CodeQL 扫描
- [ ] 配置 Branch Protection

**第三阶段：AI 深度集成（4-8周）**

- [ ] 启用 Copilot Agent Mode
- [ ] 配置 AI Issue 分类
- [ ] 集成 CodeWiki 文档生成
- [ ] 尝试 Coding Agent 处理简单任务

**第四阶段：持续优化（持续）**

- [ ] 优化 Copilot 指令
- [ ] 完善 Actions 工作流
- [ ] 建立效能度量
- [ ] 迭代改进流程

---

## 相关章节

- [上一章：风险与应对](./10-risk-management.md)
- [下一章：附录](./12-appendix.md)
- [返回概要](./00-overview.md)
