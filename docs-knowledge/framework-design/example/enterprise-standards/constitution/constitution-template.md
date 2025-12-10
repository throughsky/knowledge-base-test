<!--
  SYNC IMPACT REPORT
  Version Change: 1.1.0 → 2.0.0 (MAJOR - 重构原则体系以整合企业级标准)
  Modified Principles:
    - IV. 金融级安全优先 → IV. 安全红线（增强为企业级强制约束）
    - IX. 事件驱动与审计追踪 → X. 审计追踪与合规（强化合规要求）
  Added Principles:
    - XI. 数据一致性与事务边界
    - XII. 容错韧性与服务治理
    - XIII. 合规性要求（个保法/GDPR/等保2.0）
  Removed Principles: None
  Templates Requiring Updates:
    ✅ plan-template.md - Constitution Check section aligns with new enterprise principles
    ✅ spec-template.md - User story structure supports compliance and audit requirements
    ✅ tasks-template.md - Task organization supports security and compliance checkpoints
  Follow-up TODOs: None - all principles derived from enterprise-standards documents
-->

# 项目章程

> 企业级技术宪法 - 下级项目/仓库不可覆盖的强制约束

## 核心原则

### I. 测试驱动开发（强制执行）

**TDD 严格执行**：所有代码必须遵循测试驱动开发流程。测试优先，实现在后。

- 每个 Controller、Service、Mapper 都必须有对应的测试类
- 所有公共方法都必须有测试用例，包含正常场景和异常场景
- 核心业务逻辑测试覆盖率必须 ≥ 80%
- 必须使用 AAA 模式（Arrange-Act-Assert）和 AssertJ 断言
- 测试必须具备幂等性，使用 @BeforeEach 准备数据，@AfterEach 清理数据
- 禁止跳过测试、使用 TODO 标记或注释掉测试代码
- 集成测试必须使用 @SpringBootTest，单元测试必须 Mock 外部依赖

**理由**：金融级系统要求零容错，TDD 确保代码质量和业务逻辑正确性，降低生产环境风险。

### II. 规则至上架构

**规则执行优先级**：`.cursor/rules/` 中定义的规则高于任何其他考虑，必须零偏差执行。

- 规则分层：L0（企业级）→ L1（项目级）→ L2（仓库级）
- L0 约束不可被下级覆盖
- 严格按照规则定义的目录结构和包结构创建文件
- 不允许创建规则中未定义的目录或文件位置
- 规则冲突时，优先级：L0 > L1 > L2
- 遇到错误必须立即停止、删除错误文件、重新按规则执行

**理由**：确保代码库一致性、可维护性和团队协作效率，避免架构腐化。

### III. 分层架构纯粹性

**架构约束**：项目必须符合严格的分层架构原则。

```
┌─────────────────────────────────────┐
│         Controller / Handler        │  ← 接口层
├─────────────────────────────────────┤
│              Service                │  ← 业务逻辑层
├─────────────────────────────────────┤
│         Repository / DAO            │  ← 数据访问层
├─────────────────────────────────────┤
│           Infrastructure            │  ← 基础设施层
└─────────────────────────────────────┘
```

- **禁止**：Controller 直接访问 Mapper/Repository（必须经过 Service）
- **禁止**：循环依赖（A→B→C→A）
- **禁止**：基础设施层依赖业务层
- **禁止**：领域层依赖应用层
- 使用 Spring Boot 3.x + Gradle（≥8.14）作为构建工具
- 必须使用 MyBatis 注解模式进行数据访问

**理由**：保持架构清晰，降低系统复杂度，支持水平扩展和独立部署。

### IV. 安全红线（企业级强制约束）

**认证授权**：

- **禁止**：硬编码密码、API Key、Token、证书
- **禁止**：在日志中输出敏感信息（密码、身份证、手机号、银行卡）
- **禁止**：使用 MD5/SHA1 加密密码（必须使用 BCrypt/Argon2）
- 所有外部接口必须进行身份认证
- Session/Token 必须设置合理过期时间
- 密钥必须通过 KMS 管理，定期轮换

**输入校验**：

- **禁止**：SQL 字符串拼接（必须使用参数化查询）
- **禁止**：MyBatis 使用 `${}`（必须使用 `#{}`）
- **禁止**：直接输出用户输入到页面（XSS 防护）
- 所有外部输入必须校验（长度、格式、范围、类型）
- 文件上传必须校验类型、大小、内容

**数据保护**：

- PII（个人身份信息）数据必须加密存储
- 敏感数据删除必须物理删除或脱敏，禁止仅逻辑删除
- 强制 HTTPS，核心服务 mTLS 双向认证

**理由**：金融领域对安全性和合规性有极高要求，任何安全漏洞都可能导致重大损失。

### V. RESTful API 标准化

**API 设计规范**：所有 HTTP 接口必须遵循 RESTful 原则和项目约定。

- 必须使用资源化路径，禁止动词化路径（如 `/users` 而非 `/getUsers`）
- URL 使用名词复数，全小写，连字符分隔
- 版本号放在路径中（如 `/api/v1/`）
- 所有接口必须返回统一响应格式（code/msg/data/timestamp）
- 必须使用 OpenAPI 3（Springdoc）生成 API 文档
- 必须正确使用 HTTP 状态码

**业务状态码规范**：

| 码段      | 含义             |
| --------- | ---------------- |
| 200       | 成功             |
| 400-499   | 客户端错误       |
| 500-599   | 服务端错误       |
| 5001-5999 | 用户模块业务错误 |
| 6001-6999 | 订单模块业务错误 |
| 7001-7999 | 支付模块业务错误 |

**理由**：统一的 API 规范降低前后端联调成本，提升接口可维护性和可测试性。

### VI. 生产就绪代码完整性

**代码质量标准**：所有提交的代码必须符合生产环境标准。

- 代码必须可编译、可运行、可测试
- **禁止**：TODO 标记、简化实现、占位代码
- 必须包含完整的错误处理、日志记录、参数验证
- 必须合理使用 `@Transactional` 管理事务（必须指定 rollbackFor）
- 必须遵循 SOLID 原则和设计模式
- 工具类测试覆盖率必须 ≥ 90%

**理由**：半成品代码增加技术债务，降低系统稳定性，影响团队效率。

### VII. 可观测性要求

**健康检查**：

- 所有服务必须暴露健康检查端点（/actuator/health）
- 所有服务必须接入统一监控体系（metrics/traces/logs）
- 关键业务流程必须有全链路追踪（TraceId 贯穿）
- 异常必须上报监控系统，禁止静默吞掉

**K8s 探针配置**：

- 必须配置 livenessProbe（存活探针）
- 必须配置 readinessProbe（就绪探针）

**日志规范**：

- 日志格式必须包含 traceId
- 必须在关键入口、核心步骤、异常处记录日志
- **禁止**：日志明文打印敏感数据

**理由**：可观测性是生产系统稳定运行的基础，便于问题定位和性能优化。

### VIII. 简洁性原则

**YAGNI 与 KISS**：保持系统简单，避免过度设计。

- 不允许创建未在规则中定义的目录（按需创建原则）
- 禁止引入未使用的依赖和框架
- 优先使用 Spring Boot 内置功能，避免重复造轮子
- 设计模式应用必须有明确业务场景支撑
- 避免过度抽象和过早优化
- 配置必须外部化，支持多环境（dev/test/staging/prod）

**理由**：简洁的系统更容易理解、测试和维护，降低认知负担。

### IX. 容器化部署规范

**Dockerfile 规范**：

- 必须使用多阶段构建
- **禁止**：root 用户运行容器
- 必须使用只读文件系统
- 必须配置 HEALTHCHECK

**镜像标签规范**：

- 格式：版本号-CommitID（如 v1.0.0-7a3f2d9）
- **禁止**：latest、dev、test 等非版本化标签

**K8s 安全配置**：

- 必须配置 securityContext（runAsNonRoot: true）
- 必须配置资源限制（requests/limits）

**理由**：容器化部署是云原生的基础，安全配置防止权限提升攻击。

### X. 审计追踪与合规

**审计日志**：

- 关键操作必须记录审计日志（who/when/what/where/result）
- 审计日志禁止删除或篡改，保留期限 ≥6 个月
- 登录失败、权限变更、数据导出必须记录
- 核心日志必须支持区块链存证

**事件驱动架构**：

- 必须使用 AOP 实现横切关注点（用户身份追踪、Web 日志、操作审计）
- 审计消息必须异步发送，保证业务操作不被审计影响
- 所有事件处理器必须支持幂等性

**理由**：金融系统必须满足合规审计要求，确保每个操作都可追溯、可审计、可回溯。

### XI. 数据一致性与事务边界

**事务规范**：

- **禁止**：在数据库事务中调用外部 HTTP 服务
- 跨服务数据修改必须使用分布式事务或最终一致性方案
- 所有写接口必须支持幂等性（可安全重试）
- 并发修改必须有乐观锁或悲观锁保护
- @Transactional 必须指定 rollbackFor = Exception.class

**乐观锁**：

- 并发修改场景必须使用版本号乐观锁
- 更新失败必须抛出明确异常

**理由**：数据一致性是金融系统的生命线，事务边界错误会导致资金损失。

### XII. 容错韧性与服务治理

**超时与熔断**：

- 外部依赖调用必须设置超时时间
- 核心链路必须有降级方案
- 禁止单点故障（数据库、缓存、MQ 等）
- Feign 调用必须配置 FallbackFactory

**服务治理**：

- 注册中心：Nacos 集群（≥3 节点）
- 服务名格式：业务线-服务名（如 mall-order）
- 命名空间：按环境隔离（dev/test/prod）
- 链路 ID 必须在服务间传递

**理由**：分布式系统必须具备容错能力，防止故障级联扩散。

### XIII. 合规性要求（个保法/GDPR/等保 2.0）

**用户授权**：

- 敏感操作必须后端强制校验授权状态
- 授权记录必须持久化存证
- 必须支持授权撤回

**数据留存与删除**：

| 数据类型          | 留存期限       |
| ----------------- | -------------- |
| 浏览日志/搜索记录 | ≤90 天        |
| 订单/支付记录     | ≤3 年         |
| 用户基本信息      | 注销后 72 小时 |

- 用户注销必须全链路删除（MySQL/Redis/ES/OSS）
- 删除后必须校验清理结果

**等保 2.0**：

- 敏感操作必须双因素认证
- 必须遵循最小权限原则
- 生产环境必须关闭调试模式
- 敏感配置必须加密存储

**数据分级加密**：

| 敏感级别 | 加密算法     | 示例           |
| -------- | ------------ | -------------- |
| 核心     | SM4+信封加密 | 身份证、银行卡 |
| 重要     | AES-256      | 手机号、邮箱   |
| 一般     | 可逆脱敏     | 浏览记录       |

**理由**：合规是企业生存的底线，违规将面临巨额罚款和业务中断。

## 开发标准

### 技术栈约束

- **语言与版本**：Java 17+ LTS，Spring Boot 3.x
- **构建工具**：Gradle ≥ 8.14（强制，禁止 Maven）
- **数据访问**：MyBatis 注解模式 + MySQL 8.0+
- **缓存**：Redis 7.x（分布式缓存）、Caffeine（本地缓存）
- **消息队列**：RocketMQ 5.x / Kafka 3.x
- **测试框架**：JUnit 5 + Mockito + AssertJ + Testcontainers
- **API 文档**：Springdoc OpenAPI 3
- **日志框架**：SLF4J + Logback
- **服务治理**：Nacos 2.x + Sentinel + OpenFeign
- **容器化**：Docker + Kubernetes
- **CI/CD**：GitHub Actions + ArgoCD
- **监控**：Prometheus + Grafana + ELK

### 目录结构规范

```
src/
├── main/
│   ├── java/com/{company}/{project}/
│   │   ├── {AppName}Application.java
│   │   ├── config/
│   │   ├── controller/
│   │   ├── service/
│   │   │   └── impl/
│   │   ├── entity/
│   │   ├── mapper/
│   │   ├── vo/
│   │   │   ├── request/
│   │   │   └── response/
│   │   ├── exception/
│   │   ├── util/
│   │   ├── constants/
│   │   ├── enums/
│   │   ├── validation/
│   │   ├── aspect/          # AOP 切面
│   │   ├── listener/        # 事件监听器
│   │   └── handler/         # 事件处理器
│   └── resources/
│       ├── application.yml
│       ├── application-dev.yml
│       ├── application-test.yml
│       ├── application-staging.yml
│       ├── application-prod.yml
│       └── db/migration/    # Flyway 脚本
└── test/
    ├── java/com/{company}/{project}/
    │   ├── controller/
    │   ├── service/
    │   ├── mapper/
    │   └── integration/
    └── resources/
        └── application-test.yml
```

### 命名规范

- **包命名**：全小写，`com.{company}.{project}.{layer}`
- **类命名**：大驼峰（PascalCase），如 `UserController`、`UserServiceImpl`
- **方法命名**：小驼峰（camelCase），如 `getUserById`
- **常量命名**：全大写下划线分隔，如 `MAX_RETRY_COUNT`
- **测试类命名**：`{ClassName}Test`，如 `UserServiceTest`
- **请求对象**：`{Action}{Entity}Request`，如 `CreateUserRequest`
- **响应对象**：`{Entity}Response`，如 `UserResponse`
- **Flyway 脚本**：`V{version}_{date}_{REQ-ID}_{description}.sql`

### 代码风格

- **缩进**：4 空格（不使用 Tab）
- **行长度**：建议 ≤ 120 字符
- **花括号**：K&R 风格（左花括号不换行）
- **导入**：禁止使用通配符导入（`import xxx.*`）
- **注释**：关键业务逻辑必须添加注释，说明"为什么"而非"是什么"

## 治理规则

### 章程管理

- **章程地位**：本章程优先级高于所有其他实践和约定
- **修订流程**：修订需文档化、审批、制定迁移计划
- **版本控制**：遵循语义化版本（MAJOR.MINOR.PATCH）
  - MAJOR：向后不兼容的治理/原则移除或重新定义
  - MINOR：新增原则/章节或重大扩展
  - PATCH：澄清、措辞、拼写修正、非语义改进

### 合规检查

- 所有 PR/代码审查必须验证章程符合性
- 安全相关变更必须安全团队成员 Review
- 架构变更必须架构委员会审批
- 数据库 Schema 变更必须 DBA Review
- 复杂性（如引入新设计模式、新中间件）必须在 plan.md 中论证

### 质量门禁

- **代码审查**：所有代码必须经过 Peer Review，普通 PR 24 小时内完成
- **测试覆盖率**：核心业务 ≥ 80%，工具类 ≥ 90%
- **静态检查**：必须通过 CheckStyle、SonarQube 检查（无 Critical/Blocker）
- **安全扫描**：必须通过依赖漏洞扫描（CVSS ≥ 7 阻断）
- **镜像扫描**：必须通过 Trivy 镜像安全扫描
- **性能基准**：关键接口响应时间 < 200ms（P95）
- **审计完整性**：所有关键操作必须有审计日志

### 发布流程

- 生产发布必须经过 staging 环境验证
- 发布必须有可执行的回滚方案
- 业务高峰期禁止发布
- 发布后必须进行冒烟测试验证
- 灰度发布：先 1 个 Pod，观察 10 分钟，再扩展

### 异常处理

- **规则冲突**：优先级 L0 > L1 > L2
- **技术债务**：必须在 plan.md 的 Complexity Tracking 章节中记录和论证
- **架构偏差**：需技术委员会审批

## 反模式检查清单

| 序号 | 反模式                     | 检测方式                 |
| ---- | -------------------------- | ------------------------ |
| 1    | Controller 直接访问 Mapper | 代码审查                 |
| 2    | MyBatis 使用 ${}           | 检查 Mapper 注解和 XML   |
| 3    | 密码明文/MD5 存储          | 检查加密方式             |
| 4    | 密钥硬编码                 | 检查代码中的常量         |
| 5    | 事务内调用外部服务         | 检查 @Transactional 方法 |
| 6    | 未指定 rollbackFor         | 检查 @Transactional 注解 |
| 7    | Feign 无 FallbackFactory   | 检查 FeignClient 注解    |
| 8    | 容器 root 用户运行         | 检查 Dockerfile          |
| 9    | 镜像标签用 latest          | 检查 Deployment 配置     |
| 10   | 无健康检查探针             | 检查 K8s Deployment      |
| 11   | 日志明文打印敏感数据       | 检查 log 语句            |
| 12   | 无审计日志                 | 检查敏感操作             |
| 13   | 授权仅前端校验             | 检查接口注解             |
| 14   | 用户注销数据残留           | 检查分布式存储           |
| 15   | 依赖有高危漏洞             | 运行 OWASP 扫描          |

**版本**：2.0.0 | **批准日期**：2025-11-27 | **最后修订**：2025-12-10
