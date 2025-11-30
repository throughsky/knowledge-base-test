当前设计的问题

1. 仓库级知识库过于复杂

  当前每个仓库要维护：
  .knowledge/
  ├── inheritance.yaml        # 继承配置
  ├── ai-context.md           # AI上下文
  ├── project-charter.md      # 项目章程
  ├── glossary.md             # 术语词典
  ├── architecture/           # 8+ 文件
  ├── technology/             # 3+ 文件
  ├── implementation/         # 10+ 文件
  ├── ai-collaboration/       # 5+ 文件
  ├── code-derived/           # AI生成
  └── evolution/              # 10+ 文件

  问题：

- 每个仓库 30-40 个文档，维护成本高
- 很多内容与其他仓库重复
- 开发者不愿意维护，最终变成死文档

2. 层级边界模糊

- L1 领域知识 vs L2 项目基座 边界不清
- 业务知识应该放哪里？仓库级还是项目级？

---

  新的设计思路：三层聚合模式

  核心理念

  自底向上生成，自顶向下继承

  ┌─────────────────────────────────────────────────────────────┐
  │                    项目级知识库 (Project)                     │
  │                   (多仓库聚合，AI定期总结)                     │
  │                                                               │
  │  业务知识 + 领域模型 + 服务拓扑 + 架构决策 + 技术规范          │
  └─────────────────────────────────────────────────────────────┘
                                ▲
                                │ AI 定期聚合
            ┌───────────────────┼───────────────────┐
            │                   │                   │
  ┌─────────▼─────────┐ ┌───────▼───────┐ ┌────────▼────────┐
  │   仓库A (精简)     │ │   仓库B       │ │    仓库C        │
  │  CLAUDE.md        │ │  CLAUDE.md    │ │   CLAUDE.md     │
  │  .knowledge/      │ │  .knowledge/  │ │   .knowledge/   │
  │   └── context.md  │ │   └── ...     │ │    └── ...      │
  └───────────────────┘ └───────────────┘ └─────────────────┘

  层级重新定义

| 层级 | 名称       | 存储位置      | 内容                           | 维护方式          |
| ---- | ---------- | ------------- | ------------------------------ | ----------------- |
| L0   | 企业宪法   | 独立仓库      | 编码规范、安全基线、技术雷达   | 架构委员会        |
| L1   | 项目知识库 | 独立仓库/目录 | 业务领域 + 架构决策 + 服务目录 | AI聚合 + 人工审核 |
| L2   | 仓库知识库 | 各Git仓库     | 精简的仓库上下文               | 开发者 + AI生成   |

---

  精简的仓库级知识库设计

  每个仓库只需 3-5 个文件

  {repo}/
  ├── CLAUDE.md                    # AI入口 (必须)
  └── .knowledge/
      ├── context.md               # 仓库上下文 (必须，1个文件搞定)
      ├── decisions.md             # 重要决策记录 (可选)
      └── code-derived/            # AI自动生成 (可选)
          └── overview.md

  context.md 模板（精简版）

# 仓库上下文:

## 1. 仓库定位

- **职责**: [一句话描述]
- **所属项目**: [项目名]
- **上游依赖**: [依赖的仓库/服务]
- **下游消费者**: [谁调用我]

## 2. 技术栈

- 语言: Java 17
- 框架: Spring Boot 3.2
- 数据库: PostgreSQL

## 3. 核心模块

| 模块         | 职责     | 入口           |
| ------------ | -------- | -------------- |
| user-api     | 用户接口 | UserController |
| user-service | 业务逻辑 | UserService    |

## 4. 本仓库特殊规则

- [仓库特有的约定，如特殊的命名规则]
- [与项目通用规范的差异说明]

## 5. 快速链接

- 项目知识库: [链接]
- API文档: [链接]

  CLAUDE.md 精简版

# AI 入口

## 上下文

- 读取 [.knowledge/context.md] 了解本仓库
- 项目知识库: {project-knowledge-repo-url}

## 规则

1. 遵循项目编码规范 (继承自项目知识库)
2. [本仓库特有规则]

## 禁止

1. [具体禁止事项]

---

  项目级知识库设计

  项目知识库结构

  project-knowledge/
  ├── README.md                     # 项目总览
  ├── BUSINESS.md                   # 业务知识入口
  ├── ARCHITECTURE.md               # 架构知识入口
  │
  ├── business/                     # 业务领域知识
  │   ├── domain-model.md          # 领域模型
  │   ├── glossary.md              # 术语词典
  │   ├── workflows/               # 业务流程
  │   └── rules.md                 # 业务规则
  │
  ├── architecture/                 # 架构知识
  │   ├── service-catalog.md       # 服务目录
  │   ├── repo-map.md              # 仓库地图
  │   ├── data-flow.md             # 数据流
  │   └── decisions/               # ADR记录
  │
  ├── standards/                    # 项目规范
  │   ├── coding.md                # 编码规范 (可继承L0)
  │   ├── api.md                   # API规范
  │   └── testing.md               # 测试规范
  │
  └── aggregated/                   # AI聚合区
      ├── last-updated.json        # 更新记录
      ├── repo-summaries/          # 各仓库摘要
      │   ├── user-service.md
      │   ├── order-service.md
      │   └── ...
      └── cross-repo-analysis.md   # 跨仓库分析

  AI 聚合机制

# aggregation-config.yaml

  aggregation:
    schedule: "weekly"  # 每周聚合一次

    sources:
      - repo: "user-service"
        path: ".knowledge/context.md"
      - repo: "order-service"
        path: ".knowledge/context.md"
      - repo: "payment-service"
        path: ".knowledge/context.md"

    tasks:
      - name: "repo_summary"
        description: "从各仓库context.md生成摘要"
        output: "aggregated/repo-summaries/"

    - name: "service_topology"
        description: "分析服务依赖关系，更新服务目录"
        output: "architecture/service-catalog.md"

    - name: "cross_repo_analysis"
        description: "发现跨仓库的模式、问题、改进点"
        output: "aggregated/cross-repo-analysis.md"

---

  信息流向

  ┌─────────────────────────────────────────────────────────────┐
  │                                                              │
  │  开发者在仓库中维护                AI 定期向上聚合            │
  │  ─────────────────────────        ────────────────────       │
  │                                                              │
  │  仓库A/.knowledge/context.md  ─────┐                         │
  │  仓库B/.knowledge/context.md  ─────┼──→ 项目知识库           │
  │  仓库C/.knowledge/context.md  ─────┘    /aggregated/         │
  │                                              │                │
  │                                              ▼                │
  │                                    人工审核 + 补充            │
  │                                              │                │
  │                                              ▼                │
  │                                    项目知识库正式区           │
  │                                    /business/                │
  │                                    /architecture/            │
  │                                              │                │
  │  ┌───────────────────────────────────────────┘                │
  │  │                                                            │
  │  ▼  开发者/AI 向下继承                                        │
  │                                                              │
  │  仓库D（新仓库）从项目知识库获取上下文                         │
  │                                                              │
  └─────────────────────────────────────────────────────────────┘

---

  对比总结

| 维度         | 当前设计     | 精简设计           |
| ------------ | ------------ | ------------------ |
| 仓库文件数   | 30-40个      | 3-5个              |
| 维护成本     | 高，容易荒废 | 低，开发者可接受   |
| 业务知识位置 | 分散在各仓库 | 集中在项目知识库   |
| 更新机制     | 人工维护     | AI聚合 + 人工审核  |
| 跨仓库理解   | 需要逐个查看 | 项目知识库统一视图 |

---

  核心原则

1. 仓库知识库做减法：只保留该仓库特有的、AI无法推断的信息
2. 项目知识库做加法：业务知识、架构决策、跨仓库分析集中管理
3. AI 做聚合：定期从仓库向上聚合，减少人工维护
4. 代码衍生自动化：技术细节让 AI 从代码生成，不需人工写

  这样设计后，开发者只需要维护一个 context.md，其他都由 AI 生成或从项目知识库继承。
