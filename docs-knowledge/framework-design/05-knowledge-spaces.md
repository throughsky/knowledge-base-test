# 第5章 多级知识空间

## 5.1 三层架构体系

```
┌─────────────────────────────────────────────────────────────┐
│                    企业级 (L0)                              │
│              (Enterprise Standards)                         │
│   ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│   │  技术宪法     │ │  编码规范     │ │  技术雷达     │       │
│   └──────────────┘ └──────────────┘ └──────────────┘       │
├─────────────────────────────────────────────────────────────┤
│                    项目级 (L1)                              │
│              (Project Knowledge)                            │
│   ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│   │  业务领域     │ │  服务目录     │ │  架构决策     │       │
│   │  领域模型     │ │  依赖拓扑     │ │  数据流图     │       │
│   └──────────────┘ └──────────────┘ └──────────────┘       │
├─────────────────────────────────────────────────────────────┤
│                    仓库级 (L2)                              │
│              (Repository Context)                           │
│   ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│   │  仓库A        │ │  仓库B        │ │  仓库C        │       │
│   │  context.md  │ │  context.md  │ │  context.md  │       │
│   └──────────────┘ └──────────────┘ └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

---

## 5.2 L0 企业级知识库

**职责**：企业级强制规范、跨项目统一标准

**目录结构**：

```
enterprise-standards/
├── constitution/               # 技术宪法（不可覆盖）
│   ├── architecture-principles.md  # 架构底线：分层、事务、可观测性、日志格式、
│   │                               #           容错韧性、微服务通信、容器化部署
│   ├── security-baseline.md        # 安全红线：认证、输入校验、数据保护、审计
│   └── compliance-requirements.md  # 合规要求：GDPR、数据出境、审计保留
│   └── constitution-template.md  # 宪章模板
│
├── standards/                  # 编码规范（L0 基线，L1 可细化）
│   ├── coding-standards/
│   │   ├── java.md            # Java 规范：命名、异常、并发、缓存、分布式ID
│   │   ├── typescript.md
│   │   └── python.md
│   ├── api-design-guide.md    # API 设计：RESTful、响应格式、版本控制
│   └── testing-standards.md   # 测试规范：单测覆盖率、集成测试
│
├── governance/                 # 治理流程（不可覆盖）
│   ├── review-process.md      # 代码评审：Review 要求、安全审查、架构审批
│   └── release-process.md     # 发布流程：环境验证、回滚方案、冒烟测试
│
├── ai-coding/                  # AI 编码策略（不可覆盖）
│   └── ai-coding-policy.md    # AI 约束：访问控制、代码审查、测试要求、审计
│
└── technology-radar/           # 技术雷达
    ├── adopt.md               # 推荐采用：生产验证、鼓励使用
    ├── trial.md               # 试用阶段：小范围验证、项目可选
    ├── assess.md              # 评估阶段：关注探索、待验证
    └── hold.md                # 暂缓使用：禁止新项目采用、需迁移
```

**维护方式**：架构委员会统一维护

### 5.2.1 L0 约束规范（不可覆盖）

L0 企业级约束是全公司必须遵循的底线规范，**下级知识库（L1/L2）不可覆盖**。AI Coding 场景下必须强制执行。

#### 5.2.1.1 安全与合规约束

**security-baseline.md 核心内容**：

```yaml
# 安全红线规范（不可覆盖）

authentication:  # 认证授权
  - "禁止硬编码密码、API Key、Token、证书"
  - "禁止在日志中输出敏感信息（密码、身份证、手机号、银行卡）"
  - "所有外部接口必须进行身份认证"
  - "密码必须使用 bcrypt/argon2 加密存储，禁止 MD5/SHA1"
  - "Session/Token 必须设置合理过期时间"

input_validation:  # 输入校验
  - "所有外部输入必须校验（长度、格式、范围、类型）"
  - "SQL 必须使用参数化查询，禁止字符串拼接"
  - "禁止直接输出用户输入到页面（XSS 防护）"
  - "文件上传必须校验类型、大小、内容（禁止仅校验扩展名）"
  - "反序列化必须使用白名单机制"

data_protection:  # 数据保护
  - "PII（个人身份信息）数据必须加密存储"
  - "跨境数据传输需符合 GDPR/数据出境规定"
  - "数据删除敏感数据必须物理删除或脱敏，禁止仅逻辑删除"
  - "备份数据与生产数据同等安全级别"

audit_logging:  # 审计追溯
  - "关键操作必须记录审计日志（who/when/what/where/result）"
  - "审计日志禁止删除或篡改，保留期限 ≥6 个月"
  - "登录失败、权限变更、数据导出必须记录"

forbidden_patterns:  # 绝对禁止的代码模式
  - "禁止 eval()、exec() 执行动态代码"
  - "禁止反序列化不可信数据源"
  - "禁止使用已知漏洞的依赖版本（CVE 高危）"
  - "禁止禁用 SSL/TLS 证书校验"
  - "禁止在生产代码中使用 TODO/FIXME 绕过安全逻辑"
```

#### 5.2.1.2 架构底线约束

**architecture-principles.md 核心内容**：

```yaml
# 架构底线规范（不可覆盖）

layering:  # 分层架构
  - "禁止 Controller/Handler 直接访问 Repository/DAO（必须经过 Service）"
  - "禁止循环依赖（A→B→C→A）"
  - "基础设施层不得依赖业务层"
  - "领域层不得依赖应用层"

data_consistency:  # 数据一致性
  - "跨服务数据修改必须使用分布式事务或最终一致性方案"
  - "禁止在数据库事务中调用外部 HTTP 服务"
  - "所有写接口必须支持幂等性（可安全重试）"
  - "并发修改必须有乐观锁或悲观锁保护"

observability:  # 可观测性
  - "所有服务必须暴露健康检查端点 /health 或 /actuator/health"
  - "所有服务必须接入统一监控体系（metrics/traces/logs）"
  - "关键业务流程必须有全链路追踪（TraceId 贯穿）"
  - "异常必须上报监控系统，禁止静默吞掉"

resilience:  # 容错韧性
  - "外部依赖调用必须设置超时时间"
  - "核心链路必须有降级方案"
  - "禁止单点故障（数据库、缓存、MQ 等）"
```

#### 5.2.1.3 治理流程约束

**governance/review-process.md 核心内容**：

```yaml
# 治理流程规范（不可覆盖）

code_review:  # 代码审查
  - "所有代码必须至少 1 人 Review 后方可合并"
  - "安全相关变更必须安全团队成员 Review"
  - "架构变更（新增服务、中间件、重大重构）必须架构委员会审批"
  - "数据库 Schema 变更必须 DBA Review"

release_process:  # 发布流程
  - "生产发布必须经过 staging/pre-production 环境验证"
  - "发布必须有可执行的回滚方案"
  - "业务高峰期禁止发布（由各业务线定义高峰时段）"
  - "发布后必须进行冒烟测试验证"

incident_response:  # 事故响应
  - "P0/P1 事故必须在 15 分钟内响应"
  - "事故处理必须记录时间线和处理过程"
  - "事故必须进行复盘并输出改进措施"
```

#### 5.2.1.4 AI Coding 企业级约束

**ai-coding-policy.md 核心内容**：

```yaml
# AI Coding 企业级约束（不可覆盖）

ai_code_generation:  # 代码生成约束
  - "AI 生成的代码必须经过人工 Review 后方可合并"
  - "AI 不得自动提交到 main/master/release 分支"
  - "AI 不得修改安全相关配置文件（.env、secrets、credentials）"
  - "AI 生成的密钥/凭证必须立即失效并重新生成"

ai_testing:  # 测试约束
  - "AI 生成的测试必须有有效断言（禁止空断言、仅验证无异常）"
  - "AI 生成的测试必须人工验证覆盖了正确的场景"
  - "禁止 AI 自动跳过或删除失败的测试"

ai_access_control:  # 访问控制
  - "AI 工具不得访问生产环境数据库"
  - "AI 工具不得访问包含真实用户数据的环境"
  - "AI 对话历史中禁止包含敏感数据（脱敏后可用）"

ai_audit:  # 审计要求
  - "AI 生成的代码变更必须在 commit message 中标注"
  - "AI 辅助的架构决策必须记录到 ADR"
  - "AI 使用情况纳入研发效能度量"
```

#### 5.2.1.5 日志与可观测性约束

**architecture-principles.md 日志格式规范**：

```yaml
# 日志格式规范（不可覆盖）

log_format:
  - "所有服务必须使用统一日志格式"
  - "日志必须包含 traceId、spanId"
  - "禁止日志明文打印敏感数据"
  - "日志级别：ERROR（异常）、WARN（警告）、INFO（关键流程）、DEBUG（调试）"

trace_format:
  traceId: "32 位小写十六进制，全链路唯一标识"
  spanId: "16 位小写十六进制，单次调用标识"
  timestamp: "yyyy-MM-dd HH:mm:ss.SSS 毫秒级"

desensitization:  # 脱敏规则
  phone: "138****8000"
  id_card: "310***********1234"
  bank_card: "************1234"
```

#### 5.2.1.6 容错与韧性约束

**architecture-principles.md 容错韧性规范**：

```yaml
# 容错韧性规范（不可覆盖）

timeout:
  - "外部依赖调用必须设置超时时间"
  - "Feign 默认 connect-timeout: 3000ms, read-timeout: 5000ms"

circuit_breaker:
  - "核心链路必须有降级方案"
  - "Feign 接口必须配置 FallbackFactory"
  - "禁止写操作开启重试"

high_availability:
  - "禁止单点故障（数据库、缓存、MQ 等）"
  - "Nacos 注册中心必须集群部署（≥3 节点）"
```

#### 5.2.1.7 容器化部署约束

**architecture-principles.md 容器化规范**：

```yaml
# 容器化部署规范（不可覆盖）

dockerfile:
  - "必须使用多阶段构建"
  - "必须使用非 root 用户运行"
  - "必须配置 HEALTHCHECK"

kubernetes:
  - "必须配置 livenessProbe 和 readinessProbe"
  - "必须设置 resources.requests 和 resources.limits"
  - "securityContext.runAsNonRoot: true"
  - "securityContext.allowPrivilegeEscalation: false"

image_tag:
  format: "版本号-CommitID（如 v1.0.0-7a3f2d9）"
  prohibited:
    - "latest"
    - "dev"
    - "test"
```

#### 5.2.1.8 技术雷达约束

**technology-radar/hold.md 核心约束**：

```yaml
# 技术雷达 Hold 约束（不可覆盖）

hold_policy:
  - "Hold 技术新项目禁止采用"
  - "存量项目必须制定迁移计划"
  - "使用 Hold 技术需架构委员会例外审批"

hold_examples:
  languages:
    - "Java 8/11 → 迁移至 Java 17"
    - "Spring Boot 2.x → 迁移至 Spring Boot 3.x"
  components:
    - "Eureka/Hystrix/Ribbon → 迁移至 Nacos/Sentinel/LoadBalancer"
    - "MySQL 5.x → 迁移至 MySQL 8.0+"
  security:
    - "MD5/SHA-1 → 迁移至 BCrypt/Argon2/SHA-256+"
```

---

## 5.3 L1 项目级知识库

**职责**：跨仓库业务知识、项目级架构决策、AI定期聚合

**目录结构**：

```
project-knowledge/
├── README.md                   # 项目总览
├── BUSINESS.md                 # 业务知识入口
├── ARCHITECTURE.md             # 架构知识入口
│
├── upstream/                   # 上级知识库（Git Subtree 引入）
│   └── L0-enterprise/         # 企业级知识库
│       ├── constitution/      # 技术宪法（不可覆盖）
│       ├── standards/         # 编码规范（可细化）
│       ├── governance/        # 治理流程
│       ├── ai-coding/         # AI 编码策略
│       └── technology-radar/  # 技术雷达
│
├── business/                   # 业务领域知识
│   ├── domain-model.md        # 领域模型
│   ├── glossary.md            # 术语词典
│   ├── workflows/             # 业务流程
│   │   ├── user-registration.md
│   │   └── order-lifecycle.md
│   └── rules.md               # 业务规则
│   └── other.md               # 人工文档
│
├── architecture/               # 架构知识
│   ├── service-catalog.md     # 服务目录
│   ├── repo-map.md            # 仓库地图
│   ├── data-flow.md           # 数据流图
│   ├── tech-stack.md          # 技术栈
│   ├── other.md               # 人工文档
│   └── decisions/             # 架构决策记录
│       ├── ADR-001-microservices.md
│       └── ADR-002-event-driven.md
│
├── standards/                  # 项目规范（继承并细化 L0）
│   ├── coding.md              # 项目编码规范（细化 L0）
│   ├── api.md                 # 项目 API 规范
│   └── testing.md             # 项目测试规范
│
└── aggregated/                 # AI聚合区（自动生成）
    ├── last-updated.json
    ├── repo-summaries/        # 各仓库摘要
    ├── service-topology.md    # 服务拓扑
    ├── cross-repo-patterns.md # 跨仓库模式
    └── improvement-suggestions.md
```

**维护方式**：AI聚合 + 人工审核

### 5.3.1 L1 约束规范（可部分覆盖）

L1 项目级约束是项目内部统一的规范，**部分可被 L2 仓库级覆盖**（如编码风格），但核心约束需保持一致。

#### 5.3.1.1 技术栈规范

**tech-stack.md 核心内容**：

```yaml
# 项目技术栈规范（项目内统一，L2 不可覆盖）

languages:  # 语言版本
  java: "17"
  node: "20 LTS"
  python: "3.11+"
  go: "1.21+"

frameworks:  # 框架选型
  backend:
    primary: "Spring Boot 3.2"
    alternatives: []  # 禁止引入其他后端框架
  frontend:
    primary: "React 18 + TypeScript 5"
    state_management: "Zustand"
    ui_library: "Ant Design 5"
  mobile:
    primary: "Flutter 3.x"

middleware:  # 中间件
  database:
    primary: "PostgreSQL 15"
    cache: "Redis 7"
  messaging:
    primary: "RabbitMQ 3.12"
    alternative: "Kafka 3.x"  # 仅高吞吐场景
  search: "Elasticsearch 8"
```

#### 5.3.1.2 领域模型与术语

**business/glossary.md 核心内容**：

```yaml
# 项目术语词典（AI 必读，确保术语一致性）

# 核心实体术语
entities:
  user: "用户（非：客户、会员、账号、账户）"
  order: "订单（非：工单、单据、交易单）"
  product: "商品（非：产品、货品、SKU）"
  payment: "支付（非：付款、结算、交易）"
  merchant: "商户（非：商家、卖家、店铺）"

# 状态枚举（AI 生成代码时必须使用这些状态值）
enums:
  order_status:
    CREATED: "已创建 - 订单刚创建，未支付"
    PENDING_PAYMENT: "待支付 - 等待用户支付"
    PAID: "已支付 - 支付成功，待发货"
    SHIPPED: "已发货 - 商品已出库"
    DELIVERED: "已送达 - 用户已签收"
    COMPLETED: "已完成 - 交易完成"
    CANCELLED: "已取消 - 订单取消"

# 禁止混用的术语
forbidden_aliases:
  - "禁止将 '用户' 写成 '客户'（客户专指 B 端）"
  - "禁止将 '订单' 写成 '工单'（工单指内部流程单）"
  - "禁止将 '商品' 写成 '产品'（产品指产品线）"
```

### 5.3.2 L0/L1 约束分层总结

| 约束类别              | L0 企业级（不可覆盖） | L1 项目级（部分可覆盖） | 说明                                   |
| --------------------- | --------------------- | ----------------------- | -------------------------------------- |
| **安全红线**          | ✅ 强制               | -                       | 密码、注入、加密等绝对底线             |
| **合规要求**          | ✅ 强制               | -                       | GDPR、审计日志等法规要求               |
| **架构底线**          | ✅ 强制               | -                       | 分层、事务、数据一致性                 |
| **日志与可观测性**    | ✅ 强制               | -                       | TraceId/SpanId 格式、脱敏规则          |
| **容错韧性**          | ✅ 强制               | -                       | 超时、熔断、降级方案                   |
| **微服务通信**        | ✅ 强制               | -                       | 注册中心、Feign 规范、链路传递         |
| **容器化部署**        | ✅ 强制               | -                       | Dockerfile、K8s 安全配置、镜像标签     |
| **治理流程**          | ✅ 强制               | -                       | Review、发布、事故响应                 |
| **AI 安全约束**       | ✅ 强制               | 细化指导                | AI 访问控制、审计要求                  |
| **技术雷达 Hold**     | ✅ 禁止               | -                       | Hold 技术禁止使用，需迁移              |
| **技术雷达 Trial**    | -                     | ✅ 可选                 | 试用阶段技术，项目可选择采用           |
| **分布式 ID**         | 基线                  | ✅ 细化                 | L0 定义雪花算法，L1 细化业务流水号前缀 |
| **技术栈版本**        | -                     | ✅ 统一                 | 项目内统一，跨项目可不同               |
| **编码风格**          | 基线                  | ✅ 细化                 | L0 定义基线，L1 细化                   |
| **API 格式**          | -                     | ✅ 统一                 | 项目内统一响应格式                     |
| **测试标准**          | 基线                  | ✅ 细化                 | L0 定义底线，L1 定义覆盖率             |
| **领域模型**          | -                     | ✅ 定义                 | 项目业务独有                           |
| **术语词典**          | -                     | ✅ 定义                 | AI 必须使用标准术语                    |

---

## 5.4 L2 仓库级知识库

**设计原则**：

- **极简原则**：只保留仓库特有信息
- **继承原则**：通用规范从上层继承
- **自动化原则**：code-derived 由 AI 自动生成，尽量减轻人工维护成本

**目录结构**：

```
{repo}/
├── CLAUDE.md                    # AI入口（必须）
└── .knowledge/
    ├── context.md               # 仓库上下文（必须，人工维护）
    ├── decisions.md             # 重要决策记录（可选）
    │
    ├── upstream/                # 上级知识库（Git Subtree 引入）
    │   └── L1-project/          # 项目级知识库（已包含 L0 企业级）
    │       ├── upstream/        # L0 企业级知识库
    │       ├── business/        # 业务领域知识
    │       ├── architecture/    # 架构知识
    │       ├── standards/       # 项目规范
    │       └── aggregated/      # AI 聚合区
    │
    ├── features/                # 特性知识沉淀
    │   ├── registry.json        # Feature Registry 特性注册表
    │   └── {feature-id}/        # 各功能归档目录
    │       ├── spec.md
    │       ├── plan.md
    │       └── ADR-*.md
    │
    ├── .knowledge-config.yaml   # 知识库配置
    │
    └── code-derived/            # 代码衍生文档（AI自动生成）
        ├── metadata.json        # 生成元信息
        ├── overview.md          # 仓库概览
        ├── module_tree.json     # 模块依赖树
        └── {module-name}.md     # 各模块详细文档
```

**context.md 模板**：

```markdown
# 仓库上下文: {repo-name}

## 1. 仓库定位
- **职责**: [一句话描述核心职责]
- **所属项目**: [项目名]
- **上游依赖**: [依赖的仓库/服务]
- **下游消费者**: [谁调用我]

## 2. 技术栈
- 语言: Java 17
- 框架: Spring Boot 3.2
- 数据库: PostgreSQL 14
- 特殊依赖: Redis, RabbitMQ

## 3. 核心模块
| 模块 | 职责 | 主要类 |
|------|------|--------|
| user-api | 用户接口层 | UserController |
| user-service | 业务逻辑层 | UserService |
| user-repository | 数据访问层 | UserRepository |

## 4. 本仓库特有规则
- 用户ID必须使用雪花算法生成
- 密码必须加密存储，使用 bcrypt
- 所有接口需要支持幂等性

## 5. 快速链接
- 项目知识库: [链接]
- API文档: [链接]
- 数据库ER图: [链接]
```

### 5.4.1 code-derived 自动生成工具（CodeWiki）

**工具定位**：CodeWiki 是端到端的 AI 驱动文档生成平台，自动分析代码仓库的结构、依赖关系与模块层次，为每个模块生成高质量技术文档。

**核心能力**：

| 能力                   | 说明                                | 技术实现               |
| ---------------------- | ----------------------------------- | ---------------------- |
| **多语言分析**   | 支持 Python、JS/TS、Java、C#、C/C++ | AST + Tree-sitter      |
| **依赖图构建**   | 识别调用关系、构建模块依赖树        | DependencyGraphBuilder |
| **渐进式生成**   | 叶子模块 → 父模块 → 仓库概览      | 动态规划 + 拓扑排序    |
| **缓存增量更新** | 避免重复分析，支持秒级返回          | 文件哈希 + 变更检测    |

**CLI 命令**：

```bash
# 安装
pip install codewiki

# 配置 AI 服务
codewiki config set --api-key <KEY> --base-url <URL>

# 一键生成文档
codewiki generate https://github.com/org/repo --output .knowledge/code-derived/
```

### 5.4.2 上级知识库引用方案（Git Subtree）

**选择 Git Subtree 的理由**：

1. **AI 零障碍访问** - 文件直接存在于仓库，Claude/Copilot 可直接读取
2. **简化 CI/CD** - 无需 `--recursive` 或 submodule 初始化步骤
3. **离线友好** - clone 后即可完整访问所有知识库内容
4. **历史可追溯** - 可选择保留或 squash 上游历史

**操作命令**：

```bash
# ═══════════════════════════════════════════════════════════════
# L1 项目级知识库：引入 L0 企业级知识库
# ═══════════════════════════════════════════════════════════════

# 1. 添加远程仓库（一次性）
git remote add L0-knowledge git@github.com:org/enterprise-knowledge.git

# 2. 首次引入 L0 subtree
git subtree add --prefix=upstream/L0-enterprise L0-knowledge main --squash

# 3. 更新 L0 Subtree
git subtree pull --prefix=upstream/L0-enterprise L0-knowledge main --squash

# ═══════════════════════════════════════════════════════════════
# L2 仓库级知识库：只引入 L1（L1 已包含 L0）
# ═══════════════════════════════════════════════════════════════

# 1. 添加远程仓库（一次性）
git remote add L1-knowledge git@github.com:org/project-knowledge.git

# 2. 首次引入 L1 subtree（L1 内部已包含 L0）
git subtree add --prefix=.knowledge/upstream/L1-project L1-knowledge main --squash

# 3. 更新 L1 Subtree
git subtree pull --prefix=.knowledge/upstream/L1-project L1-knowledge main --squash
```

> **注意**：L2 仓库只需引入 L1，因为 L1 的 `upstream/L0-enterprise/` 目录已包含完整的企业级知识库。

---

## 5.5 信息流向机制

```
┌─────────────────────────────────────────────────────────────┐
│                    信息流向                                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  自底向上生成 (Upward Aggregation)                          │
│  ─────────────────────────────────                          │
│  仓库级 (L2)  ───AI定期聚合───→  项目级 (L1)  ───→  企业级  │
│                                                             │
│  • 收集 context.md 变更                                     │
│  • 收集 code-derived 文档                                   │
│  • 分析变更影响                                             │
│  • 生成聚合报告                                             │
│  • 更新项目文档                                             │
│                                                             │
│  自顶向下继承 (Downward Inheritance)                        │
│  ─────────────────────────────────                          │
│  企业级 (L0)  ───规范传递───→  项目级 (L1)  ───→  仓库级    │
│                                                             │
│  • 编码规范继承                                             │
│  • 技术选型约束                                             │
│  • 安全基线要求                                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 5.6 SpecKit 知识库配置

**配置文件** (`.specify/knowledge-config.yaml`)：

```yaml
knowledge_sources:
  enterprise:
    enabled: true
    path: "../docs-knowledge/enterprise-standards"
  project:
    enabled: true
    path: "../docs-knowledge/project-xxx"
  repository:
    context: ".knowledge/context.md"
    code_derived: ".knowledge/code-derived/"

architecture_compliance:
  enabled: true
  strict_mode: true  # true: 违规阻止流程
  skip_principles: []  # 可跳过的原则（需理由）
```

**错误代码**：

| 代码     | 含义             | 处理     |
| -------- | ---------------- | -------- |
| ARCH-001 | 违反企业架构原则 | 阻止流程 |
| ARCH-002 | ADR 冲突         | 阻止流程 |
| ARCH-003 | 模块边界越界     | 警告     |
| KNOW-001 | 知识库不可访问   | 跳过检查 |

---

## 相关章节

- [上一章：编码技巧规范](./04-coding-practices.md)
- [下一章：统一工具链](./06-unified-toolchain.md)
- [返回概要](./00-overview.md)
