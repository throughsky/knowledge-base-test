# 第12章 附录

## 12.1 术语表

| 术语 | 定义 |
|------|------|
| **SDD** | Specification-Driven Development，规范驱动开发 |
| **TDD** | Test-Driven Development，测试驱动开发 |
| **MCP** | Model Context Protocol，模型上下文协议 |
| **RAG** | Retrieval-Augmented Generation，检索增强生成 |
| **ADR** | Architecture Decision Record，架构决策记录 |
| **HITL** | Human-In-The-Loop，人工监督 |
| **GHAS** | GitHub Advanced Security，GitHub 高级安全 |
| **CodeQL** | GitHub 代码查询语言，用于安全扫描 |

---

## 12.2 参考资源

- [Speckit 工作流文档](./speckit/)
- [OpenSpec 变更管理](./openspec/)
- [知识库架构设计](./knowledge-design.md)
- [有赞 AI Coding 实践](../docs-example/youzan-ai-coding.md)
- [OpenAI: 构建 AI 原生工程团队](./openai-native-team.md)
- [GitHub Copilot 文档](https://docs.github.com/copilot)
- [GitHub Actions 文档](https://docs.github.com/actions)
- [GitHub Advanced Security](https://docs.github.com/code-security)

---

## 12.3 未来优化建议

以下为后续版本可考虑增强的方向，基于 OpenAI《构建 AI 原生工程团队》最佳实践：

### 12.3.1 AI 辅助运维与事故响应

**能力范围**：

| 能力 | AI 可做 | 人类必做 |
|------|--------|---------|
| 日志分析 | 异常模式识别、根因推测、关联日志-提交-部署历史 | 确认根因、决定修复方案 |
| 事故分诊 | 浮现异常指标、识别可疑代码变更 | 最终判断、敏感操作签署 |
| 热修复 | 生成修复建议、提出补救步骤 | 审批修复、确保合规 |

**MCP 集成建议**：
- 日志聚合系统（ELK、Datadog、Splunk）
- 部署系统（ArgoCD、Jenkins、GitHub Actions）
- 告警系统（PagerDuty、OpsGenie）

### 12.3.2 AGENTS.md 配置标准化

建议在 L2 仓库级知识库中标准化 `AGENTS.md` 配置：

```markdown
# AGENTS.md 模板

## 测试配置
- 运行命令: `npm test` / `pytest`
- 覆盖率工具: `npm run coverage`
- 最低覆盖率: 80%

## Linter 配置
- 运行命令: `npm run lint`
- 自动修复: `npm run lint:fix`

## 构建验证
- 构建命令: `npm run build`
- 类型检查: `npm run typecheck`

## 禁止操作
- 不得修改: .env*, credentials*, secrets/
- 不得删除: tests/, migrations/, core/
```

### 12.3.3 持久项目记忆增强

**跨会话记忆能力**：

- 记住之前的设计选择和约束
- 跟踪功能从提案到部署的全过程
- 压缩技术保持长上下文窗口效率

**效果对比**：

- 未接入记忆：5-10轮对话修正
- 接入记忆：1-3轮对话

### 12.3.4 各阶段入门清单模板

**规划阶段**：

- [ ] 确定需要特征和源代码对齐的常见流程
- [ ] 从基本工作流开始（如标记和去重问题）
- [ ] 考虑高级工作流（如根据功能描述添加子任务）

**设计阶段**：

- [ ] 使用多模态编程智能体（接受文本和图像）
- [ ] 通过 MCP 将设计工具与编程智能体集成
- [ ] 利用类型化语言定义有效的属性和子组件

**构建阶段**：

- [ ] 从明确指定的任务开始
- [ ] 让智能体通过 MCP 使用规划工具或编写 PLAN.md
- [ ] 迭代 AGENTS.md 解锁测试和 linter 反馈循环

**测试阶段**：

- [ ] 引导模型作为单独步骤实施测试
- [ ] 在 AGENTS.md 中设置测试覆盖率指南
- [ ] 给智能体具体的代码覆盖率工具示例

**审查阶段**：

- [ ] 整理黄金标准 PR 示例作为评估集
- [ ] 选择专门针对代码审查训练的模型
- [ ] 定义审查质量衡量方式（如 PR 评论反应）

### 12.3.5 CodeWiki 知识库自动构建 CI/CD 集成

将 CodeWiki 集成到 CI/CD 流水线，实现代码变更时自动更新知识库：

**GitHub Actions 配置示例**：

```yaml
name: CodeWiki Documentation Update

on:
  push:
    branches: [main, develop]
    paths:
      - 'src/**'
      - 'lib/**'
  workflow_dispatch:

jobs:
  update-docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install CodeWiki
        run: pip install codewiki

      - name: Configure CodeWiki
        run: |
          codewiki config set --api-key ${{ secrets.LLM_API_KEY }}
          codewiki config set --base-url ${{ secrets.LLM_BASE_URL }}

      - name: Generate Documentation
        run: |
          codewiki generate . \
            --output .knowledge/code-derived/ \
            --model gpt-4

      - name: Commit and Push
        run: |
          git config user.name "CodeWiki Bot"
          git config user.email "codewiki@bot.local"
          git add .knowledge/code-derived/
          git diff --staged --quiet || git commit -m "docs: auto-update code-derived documentation"
          git push

      - name: Validate Documentation
        run: |
          # 检查关键文件存在
          test -f .knowledge/code-derived/overview.md
          test -f .knowledge/code-derived/module_tree.json
          test -f .knowledge/code-derived/metadata.json
```

**触发策略**：

| 触发条件 | 更新范围 | 说明 |
|----------|----------|------|
| **代码推送** | 增量更新 | 仅更新变更模块的文档 |
| **版本发布** | 全量更新 | 重新生成完整文档 |
| **手动触发** | 可选 | 支持按需更新 |
| **定时任务** | 全量更新 | 周期性全量同步 |

**与现有流程集成**：

```
┌─────────────────────────────────────────────────────────────────┐
│                  CI/CD 集成流程                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  代码推送 → 单元测试 → 构建 → CodeWiki生成 → 文档校验 → 部署     │
│                                    ↓                            │
│                              知识库更新                          │
│                                    ↓                            │
│                          AI Agent 可消费                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 12.3.6 代码分析技术选型参考

**AST vs Tree-sitter 对比**：

| 维度 | 原生 AST | Tree-sitter |
|------|----------|-------------|
| **语言支持** | 单语言（如 Python ast） | 多语言统一接口 |
| **解析精度** | 高（语言原生） | 高（增量解析） |
| **错误容忍** | 低（语法错误即失败） | 高（支持部分解析） |
| **性能** | 快 | 更快（增量解析） |
| **维护成本** | 高（每语言单独实现） | 低（统一查询语法） |
| **生态成熟度** | 语言相关 | 广泛（GitHub Linguist 使用） |

**选型建议**：

| 场景 | 推荐方案 | 理由 |
|------|----------|------|
| **Python 单语言项目** | 原生 `ast` 模块 | 原生支持，精度高，无额外依赖 |
| **多语言混合项目** | Tree-sitter | 统一接口，降低复杂度 |
| **大型代码库** | Tree-sitter | 增量解析，性能优势明显 |
| **语法不完整代码** | Tree-sitter | 错误容忍能力强 |
| **IDE 集成场景** | Tree-sitter | 实时解析，支持高亮、折叠 |

**Tree-sitter 查询示例**：

```scheme
; 查询 Python 类定义
(class_definition
  name: (identifier) @class.name
  body: (block) @class.body)

; 查询 JavaScript 函数
(function_declaration
  name: (identifier) @function.name
  parameters: (formal_parameters) @function.params)

; 查询 TypeScript 接口
(interface_declaration
  name: (type_identifier) @interface.name
  body: (object_type) @interface.body)
```

**语言分析器实现参考**：

| 分析器 | 语言 | 核心类 | 提取能力 |
|--------|------|--------|----------|
| `PythonASTAnalyzer` | Python | 基于 `ast.NodeVisitor` | 类、函数、装饰器、类型注解 |
| `TreeSitterJSAnalyzer` | JS | 基于 `tree-sitter-javascript` | 函数、类、模块导出 |
| `TreeSitterTSAnalyzer` | TS | 基于 `tree-sitter-typescript` | 类型定义、接口、泛型 |
| `TreeSitterJavaAnalyzer` | Java | 基于 `tree-sitter-java` | 类、方法、注解 |
| `TreeSitterCSharpAnalyzer` | C# | 基于 `tree-sitter-c-sharp` | 类、方法、属性 |
| `TreeSitterCAnalyzer` | C | 基于 `tree-sitter-c` | 函数、结构体、宏 |
| `TreeSitterCppAnalyzer` | C++ | 基于 `tree-sitter-cpp` | 类、方法、模板 |

---

## 12.4 版本历史

| 版本 | 日期 | 作者 | 变更说明 |
|------|------|------|----------|
| 1.0 | 2025-12-01 | 架构团队 | 初始版本 |
| 2.0 | 2025-12-01 | 架构团队 | 新增代码设计规范（SOLID原则、设计模式）、编码技巧规范；完善Code Review流程与检查清单 |
| 2.1 | 2025-12-01 | 架构团队 | 整合SpecKit知识库增强：SDD阶段知识库集成、架构合规检查机制、知识库配置 |
| 2.2 | 2025-12-01 | 架构团队 | 新增前端AI Coding模式（6.8节）：Figma MCP实时访问方案、工作流程、设计规范、质量保障 |
| 2.3 | 2025-12-01 | 架构团队 | 基于OpenAI最佳实践优化：新增D-R-O框架（1.4节）、AI文档生成（7.5节）、各阶段D-R-O职责、未来优化建议附录 |
| 2.4 | 2025-12-01 | 架构团队 | 集成CodeWiki知识库自动构建：新增code-derived自动生成工具（5.4.1节）、代码分析技术栈（6.3.1节）、渐进式文档生成策略（7.5.6节）；附录新增CI/CD集成指南、代码分析技术选型参考 |
| 2.5 | 2025-12-01 | 架构团队 | 新增第11章GitHub生态全栈方案：规划层（Projects+Issues）、开发层（Copilot家族+Workspace+Coding Agent+Agent HQ）、交付层（Actions+AI增强）、安全层（Secret Protection+Code Security+Dependabot）；项目级AI配置（.copilot-instructions.md+AGENTS.md）；与AI Coding流程体系集成映射；按团队规模推荐方案 |
| 2.6 | 2025-12-01 | 架构团队 | 集成知识生命周期管理增强（2.1.6节）：Feature Registry特性注册表、/speckit.archive知识沉淀命令、历史感知specify/plan增强、ADR自动生成、冲突检测机制；更新SDD工作流命令表（2.1.2节）；更新L2知识库目录结构（5.4节）新增features/目录 |
| 2.7 | 2025-12-01 | 架构团队 | 新增上级知识库引用方案（5.4.2节）：Git Subtree vs Submodule对比、目录结构设计、.knowledge-config.yaml配置文件、操作命令与封装脚本、CLAUDE.md集成模板；更新L2目录结构新增upstream/目录 |
| 2.8 | 2025-12-03 | 架构团队 | 新增约束规范分层设计：L0企业级约束（5.2.1节）包含安全合规、架构底线、治理流程、AI Coding企业级约束；L1项目级约束（5.3.1节）包含技术栈、编码规范、API设计、测试规范、领域模型术语、AI Coding项目级指导；新增L0/L1约束分层总结表（5.3.2节） |

---

## 相关章节

- [上一章：GitHub生态方案](./11-github-ecosystem.md)
- [返回概要](./00-overview.md)
