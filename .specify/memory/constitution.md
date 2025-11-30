<!--
  SYNC IMPACT REPORT
  Version Change: 1.0.0 → 1.1.0 (MINOR - Added new principle)
  Modified Principles: None
  Added Principles:
    - IX. 事件驱动与审计追踪
  Removed Principles: None
  Templates Requiring Updates:
    ✅ plan-template.md - Constitution Check section aligns with event-driven and audit principles
    ✅ spec-template.md - User story structure supports audit requirements
    ✅ tasks-template.md - Task organization supports event-driven architecture implementation
  Follow-up TODOs: None - event-driven principle successfully integrated from existing architecture patterns
-->

# 项目章程

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

- 规则分层：L0（交互规范）→ L1（项目结构）→ L2（设计标准）→ L3（编码规范）→ L4（文件约定）
- 严格按照规则定义的目录结构和包结构创建文件
- 不允许创建规则中未定义的目录或文件位置
- 所有代码生成必须遵循 `generation-framework.mdc` 定义的完整流程
- 规则冲突时，优先级：L0 > L1 > L2 > L3 > L4；同层级内 alwaysApply=true 优先
- 遇到错误必须立即停止、删除错误文件、重新按规则执行

**理由**：确保代码库一致性、可维护性和团队协作效率，避免架构腐化。

### III. 微服务架构纯粹性

**架构约束**：项目必须符合微服务架构原则，同时支持移动端和 PC 端的后台服务。

- 使用 Spring Boot 3.x + Gradle（≥8.14）作为唯一构建工具
- 严格分层：Controller → Service → Mapper，禁止跨层调用
- 必须使用 MyBatis 注解模式进行数据访问
- 所有 API 响应必须使用 `CommonResponse<T>` 统一封装
- 仅使用 GET 和 POST 两种 HTTP 方法
- 分页查询必须使用 POST + `CommonPageRequest` 继承类
- 禁止使用 Maven，禁止同时使用多个构建工具

**理由**：保持架构清晰，降低系统复杂度，支持水平扩展和独立部署。

### IV. 金融级安全优先

**安全要求**：作为稳定币产品后台服务，安全性是第一优先级。

- 所有输入必须使用 `@Valid` 进行校验
- 必须使用具体异常类型，禁止空 catch 块
- 敏感信息（密钥、地址、金额）必须加密存储和传输
- 所有操作必须记录审计日志（操作人、时间、内容、结果）
- 必须在关键入口、核心步骤、异常处记录日志
- 自定义验证器（如 `AccountAddressValidator`）必须严格验证区块链地址格式
- 禁止输出敏感信息到日志或响应中

**理由**：金融领域对安全性和合规性有极高要求，任何安全漏洞都可能导致重大损失。

### V. RESTful API 标准化

**API 设计规范**：所有 HTTP 接口必须遵循 RESTful 原则和项目约定。

- 必须使用资源化路径，禁止动词化路径（如 `/users` 而非 `/getUsers`）
- 仅使用 GET（查询单条或简单查询）和 POST（复杂查询、分页、修改）两种方法
- 禁止使用 PUT、DELETE、PATCH 等其他 HTTP 方法
- 所有接口必须返回 `CommonResponse<T>` 统一响应格式
- 参数超过两个的查询必须使用 POST + 请求对象
- 必须使用 OpenAPI 3（Springdoc）生成 API 文档
- 必须正确使用 HTTP 状态码（200 成功，400 参数错误，500 服务器错误）

**理由**：统一的 API 规范降低前后端联调成本，提升接口可维护性和可测试性。

### VI. 生产就绪代码完整性

**代码质量标准**：所有提交的代码必须符合生产环境标准。

- 代码必须可编译、可运行、可测试
- 禁止使用 TODO 标记、禁止简化实现、禁止占位代码
- 必须包含完整的错误处理、日志记录、参数验证
- 必须使用 `@Autowired` 字段注入（项目约定）
- 必须合理使用 `@Transactional` 管理事务
- 必须遵循 SOLID 原则和设计模式（Builder、Factory、Strategy 等）
- 工具类测试覆盖率必须 ≥ 90%

**理由**：半成品代码增加技术债务，降低系统稳定性，影响团队效率。

### VII. 多平台后台架构

**平台支持**：后台服务必须同时支持移动端和 PC 端访问。

- API 设计必须考虑移动端网络环境（超时、重试、幂等性）
- 响应数据必须简洁高效，避免冗余字段
- 必须支持版本控制（URL 路径或 Header）
- 必须提供统一的错误码和错误信息
- 必须支持分页查询，避免大数据量传输
- 移动端和 PC 端共享相同的业务逻辑层

**理由**：现代金融应用需要跨平台支持，统一后台降低维护成本。

### VIII. 简洁性原则

**YAGNI 与 KISS**：保持系统简单，避免过度设计。

- 不允许创建未在规则中定义的目录（按需创建原则）
- 禁止引入未使用的依赖和框架
- 优先使用 Spring Boot 内置功能，避免重复造轮子
- 设计模式应用必须有明确业务场景支撑
- 避免过度抽象和过早优化
- 配置必须外部化（application.yml），支持多环境（dev/prod）

**理由**：简洁的系统更容易理解、测试和维护，降低认知负担。

### IX. 事件驱动与审计追踪

**事件驱动架构**：系统必须采用事件驱动模式实现业务解耦和全链路审计追踪。

- **工作流事件监听**：必须使用 Activiti 事件监听器（ExecutionListener、TaskListener）处理流程事件
- **审计消息异步化**：所有审计消息必须通过 RabbitMQ 异步发送，保证业务操作不被审计影响
- **AOP 切面应用**：必须使用 AOP 实现横切关注点（用户身份追踪、Web 日志、操作审计）
- **外部服务回调**：必须实现回调机制处理外部服务的异步响应
- **缓存事件管理**：必须使用 @CacheEvict、@CachePut 管理缓存失效事件
- **事件命名规范**：事件监听器必须明确命名用途（如 ApprovalNodeCompletedListener）
- **幂等性保证**：所有事件处理器必须支持幂等性，防止重复处理

**关键实现模式**：

- 审批流程事件：节点完成 → 发送审计消息 → 触发回调 → 更新状态
- 用户身份追踪：InitiatorUserIdAspect 自动注入当前用户 ID 到上下文
- Web 请求日志：WebLogAspect 记录请求参数、响应结果、性能指标
- 缓存策略：流程定义缓存（1 小时）、用户信息缓存（30 秒）

**理由**：金融系统必须满足合规审计要求，事件驱动架构实现业务解耦和全链路追踪，
确保每个操作都可追溯、可审计、可回溯，同时提升系统性能和可维护性。

## 开发标准

### 技术栈约束

- **语言与版本**：Java 17+ LTS，Spring Boot 3.x
- **构建工具**：Gradle ≥ 8.14（强制，禁止 Maven）
- **数据访问**：MyBatis 注解模式 + MySQL
- **测试框架**：JUnit 5 + Mockito + AssertJ
- **API 文档**：Springdoc OpenAPI 3
- **日志框架**：SLF4J + Logback
- **序列化**：Jackson（Java 8 时间支持）
- **缓存**：Caffeine（流程定义 1 小时 TTL，用户信息 30 秒 TTL）
- **工作流引擎**：Activiti 7.x（事件监听、流程部署）
- **消息队列**：RabbitMQ（审计消息异步发送）
- **AOP 框架**：Spring AOP（用户追踪、日志记录）

### 目录结构规范

必须严格遵循 `01-structure/project.mdc` 定义的目录结构：

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
│   │   ├── aspect/          # AOP 切面（用户追踪、日志）
│   │   ├── listener/        # 事件监听器（工作流事件）
│   │   └── handler/         # 事件处理器（业务处理）
│   └── resources/
│       ├── application.yml
│       ├── application-dev.yml
│       ├── application-prod.yml
│       └── sql/
└── test/
    ├── java/com/{company}/{project}/
    │   ├── controller/
    │   ├── service/
    │   ├── mapper/
    │   ├── listener/       # 事件监听器测试
    │   └── aspect/         # AOP 切面测试
    └── resources/
        └── application-test.yml
```

**强制要求**：

- test 目录结构必须与 main 目录对应
- 必须创建 application-test.yml 配置文件
- 错误码必须使用枚举（ErrorCodeEnum），禁止常量类
- 枚举文件必须以 Enum.java 结尾
- 事件监听器必须放在 listener/ 目录
- AOP 切面必须放在 aspect/ 目录

### 命名规范

- **包命名**：全小写，`com.{company}.{project}.{layer}`
- **类命名**：大驼峰（PascalCase），如 `UserController`、`UserServiceImpl`
- **方法命名**：小驼峰（camelCase），如 `getUserById`
- **常量命名**：全大写下划线分隔，如 `MAX_RETRY_COUNT`
- **测试类命名**：`{ClassName}Test`，如 `UserServiceTest`
- **请求对象**：`{Action}{Entity}Request`，如 `CreateUserRequest`
- **响应对象**：`{Entity}Response`，如 `UserResponse`
- **事件监听器**：`{Purpose}Listener`，如 `ApprovalNodeCompletedListener`
- **AOP 切面**：`{Purpose}Aspect`，如 `WebLogAspect`

### 代码风格

- **缩进**：4 空格（不使用 Tab）
- **行长度**：建议 ≤ 120 字符
- **花括号**：K&R 风格（左花括号不换行）
- **导入**：禁止使用通配符导入（`import xxx.*`）
- **注释**：关键业务逻辑必须添加注释，说明"为什么"而非"是什么"

### 交互规范

- **进度透明**：明确说明已完成/进行中/待确认/待完成
- **精炼高效**：避免冗余，突出重点
- **关键确认**：决策点主动确认（如技术选型、架构变更）
- **响应格式**：使用结构化 Markdown 格式（当前状态、下一步、执行决策）

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
- 复杂性（如引入新设计模式、第 4 个微服务）必须在 plan.md 中论证
- 使用 `.specify/memory/constitution.md` 作为运行时开发指导

### 质量门禁

- **代码审查**：所有代码必须经过 Peer Review
- **测试覆盖率**：核心业务 ≥ 80%，工具类 ≥ 90%
- **静态检查**：必须通过 Checkstyle、SpotBugs、SonarQube 检查
- **安全扫描**：必须通过依赖漏洞扫描（OWASP Dependency-Check）
- **性能基准**：关键接口响应时间 < 200ms（P95）
- **审计完整性**：所有关键操作必须有审计日志

### 异常处理

- **规则冲突**：优先级 L0 > L1 > L2 > L3 > L4，同层 alwaysApply=true 优先
- **技术债务**：必须在 plan.md 的 Complexity Tracking 章节中记录和论证
- **架构偏差**：需技术委员会审批（如引入新的中间件、修改核心架构）

**版本**：1.1.0 | **批准日期**：2025-11-27 | **最后修订**：2025-11-27
