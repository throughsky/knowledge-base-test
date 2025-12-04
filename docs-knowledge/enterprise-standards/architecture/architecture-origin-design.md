

## 背景：

我在做一个web3的金融项目,里面涉及托管钱包,leading,staking,rwa,用户管
  理,账务,用户充值提现,运营等服务.主要使用springboot生态相关的微服务体
  系,部署会优先考虑AWS云服务.需要设计相关的基础架构和多维度的考虑。


## 我初步考虑一些考虑点：

### 一、 技术栈选型红线（Tech Stack Baseline）

目的：减少技术熵，降低 AI 模型上下文切换的复杂度。

    1.
    语言与框架白名单：

    a.
    后端：明确主语言（如 Java/Spring Boot 或 Go/Gin）。除了特定计算密集型（可能用 Rust/C++）或脚本任务（Python），禁止随意引入新语言。

    b.
    Web3 交互：统一 SDK 选型（如 web3j vs ethers.js），统一链交互中间件。

    2.
    中间件收敛：

    a.
    消息队列：全线统一（如只用 RocketMQ 或 Kafka），禁止 A 团队用 RabbitMQ，B 团队用 Pulsar。

    b.
    缓存：统一 Redis 版本及 Client 库（如统一使用 Redisson）。

    c.
    配置中心：统一使用 Nacos 或 Apollo，禁止硬编码配置。

    3.
    依赖管理（BOM）：

    a.
    维护一个企业级的 Parent POM (Java) 或 go.mod 推荐版本库。

    b.
    AI 意义：当 AI 知道项目继承自 company-parent-v1.0，它就能准确预测可用的工具类库，减少幻觉。

### 二、 应用架构模版（Application Scaffolding）

目的：让所有服务的“骨架”长得一样，AI 打开任何一个仓库都能立刻找到代码位置。

    1.
    工程目录结构：

    a.
    强制统一分层结构。例如：

codeCode

```
/src
  /api       (Controller/Handler)
  /core      (Domain Logic, SDD 对应层)
  /infra     (DB, Redis, RPC impl)
  /client    (外部调用封装)
```

    b.
    规范：禁止有人把 SQL 写在 Controller，有人写在 DAO。

    2.
    错误码设计：

    a.
    制定全局统一的 ErrorCode 结构（如 Project_Module_ErrorType_Code）。

    b.
    统一异常处理类 GlobalExceptionHandler，保证所有 API 吐出的报错格式一致。

    3.
    工具类（Utils）下沉：

    a.
    禁止在每个微服务里重复造 DateUtil, StringUtil 的轮子。提供统一的 common-utils 包。

### 三、 API 与通信协议规范

目的：模块间协作的“普通话”，也是 AI 只要看文档就能生成调用代码的关键。

    1.
    接口定义语言（IDL）优先：

    a.
    必须通过 IDL（Protobuf, OpenAPI/Swagger）定义接口，先定义后开发。

    b.
    AI 意义：OpenAPI JSON 是 AI 能够自主调用你系统 API 的核心输入。

    2.
    RESTful 风格约束：

    a.
    明确 HTTP Method 语义（GET 查，POST 改）。

    b.
    URL 命名规范（kebab-case vs snake_case）。

    3.
    传输对象（DTO/VO）规范：

    a.
    入参（Command/Query）、出参（VO）、数据库实体（PO）必须严格分离，禁止 PO 直接暴露给前端。

### 四、 数据与持久化规范

目的：保证数据的一致性，特别是 Web3 场景下链上链下数据的对齐。

    1.
    Schema 变更规范：

    a.
    所有 DDL（建表语句）必须存放在 Git 仓库指定目录，通过 Liquibase/Flyway 管理版本。

    b.
    AI 意义：AI 读取 schema.sql 文件后，能极快地理解业务数据结构。

    2.
    ORM 使用范式：

    a.
    统一使用 MyBatis Plus 或 JPA。

    b.
    关键：统一软删除（IsDeleted）、创建时间（CreatedAt）、更新时间（UpdatedAt）的字段命名和处理逻辑。

    3.
    分布式事务策略：

    a.
    明确跨模块事务的解决方案。是强制用 TCC，还是基于消息的最终一致性？需要封装成标准注解（如 @GlobalTransactional）。

### 五、 可观测性与运维规范（Observability）

目的：当系统出问题时，AI Agent 能通过日志分析根因。

    1.
    结构化日志（Structured Logging）：

    a.
    强制日志输出为 JSON 格式。

    b.
    必须包含标准字段：traceId, spanId, serviceName, env, userId。

    c.
    规范：禁止使用 System.out.println。

    2.
    Metrics 埋点规范：

    a.
    统一 Prometheus 的 Metric Naming（如 app_request_latency_seconds）。

    b.
    统一保留黄金指标（延迟、流量、错误率、饱和度）。

    3.
    CI/CD 流水线模板：

    a.
    所有模块共用一套 Github Actions 模板（Build -> Unit Test -> SAST -> Docker Push -> Deploy）。

    b.
    AI 意义：AI 可以直接读取 .github/workflows 文件来修复构建错误。


## 我们的设计的其他重要要求:

* 第一，所有的服务是可插拔，可组装。可以只包含少数有业务服务的产品。
* 第二，适配云服务厂商，从网络，网关，流量治理，服务可用性，部署区域，可观测性，安全性等多个角度都要是业界常用标准。
* 第三，技术一致性。通讯一致性，安全标准一致
* 最后请设计一套微服务架构，以及输出一套架构要求的基本法，以及对


## 输出

* 请设计一套微服务架构，
* 输出一套架构要求的基本法
* 输出一套架构管理流程
* 另外请对在这个过程中，以上三点，我们应该如何使用ai coding 工具，来辅助提高效率。
