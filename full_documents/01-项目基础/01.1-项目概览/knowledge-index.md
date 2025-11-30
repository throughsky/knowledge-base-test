---
title: 知识索引
created: 2024-01-01
updated: 2024-11-30
version: 2.0
status: 已发布
tags: [知识索引, 导航, 项目规范, 架构规范, AI协作]
---

# 完整版知识库索引

> AI Native开发团队的完整知识体系导航
> 基于 @rules/ 目录规范的完整知识空间

## 📚 目录导航

### 01. 项目基础
**项目基础信息、团队组织和开发章程**

#### 01.1 项目概览
| 文档 | 内容概要 | 必读人群 |
|------|----------|----------|
| [项目愿景与目标](./vision-and-goals.md) | 项目长期愿景和战略目标 | 全体团队成员 |
| [项目章程](./development-charter.md) | 开发理念、流程、质量门禁 + @rules/规范总结 | 全体团队成员 |
| [术语表](./glossary.md) | 项目中使用的专业术语定义 | 新成员 |
| [知识索引](./knowledge-index.md) | 本文档，完整知识体系导航 | 所有人 |

**新增内容** (基于 @rules/ 目录规范):
- **强制规范**: 项目结构、技术栈、编码规范完整说明
- **AI协作指南**: 如何与AI协作开发，提示模板和最佳实践
- **开发流程**: 从需求到部署的完整流程，包含AI代码生成环节

#### 01.2 团队信息
| 文档 | 内容概要 | 使用场景 |
|------|----------|----------|
| [团队结构](./team-structure.md) | 团队成员组成和汇报关系 | 了解组织架构 |
| [角色职责](./roles-and-responsibilities.md) | 各角色详细职责说明 | 明确工作职责 |
| [入职指南](./onboarding-guide.md) | 新成员入职流程和必读资料 | 新成员入职 |
| [沟通指南](./communication-guide.md) | 团队沟通方式和规范 | 日常沟通协作 |
| [联系人列表](./contact-list.md) | 团队成员联系方式 | 紧急联系 |

### 02. 架构设计
**系统架构、技术选型、设计模式和架构决策**

#### 02.1 架构文档
| 文档 | 内容概要 | 适用角色 |
|------|----------|----------|
| [系统架构总览](./02.1-架构文档/system-architecture.md) | 整体架构设计和技术栈 | 全体团队成员 |
| [架构设计原则](./02.1-架构文档/architecture-design-principles.md) | SOLID原则、设计模式、微服务 + @rules/规范 | 架构师、高级开发 |

**新增内容** (基于 @rules/ 目录规范):
- **强制项目结构**: 详细的包结构和目录要求
- **技术栈规范**: Spring Boot + MyBatis + Gradle 完整要求
- **设计模式规范**: L2层级的设计模式应用标准
- **编码规范**: 命名、注释、测试等具体要求

#### 02.2 架构决策记录
| 文档 | 内容概要 | 使用场景 |
|------|----------|----------|
| [ADR-001: 使用微服务架构](./02.2-架构决策记录/adr-001-microservices.md) | 微服务架构决策背景和后果 | 架构评审 |
| [ADR-002: 数据库选型](./02.2-架构决策记录/adr-002-database-selection.md) | 数据库技术选型理由 | 技术选型 |
| [ADR-003: 前端框架选择](./02.2-架构决策记录/adr-003-frontend-framework.md) | React vs Vue决策过程 | 技术选型 |

#### 02.3 设计模式
| 文档 | 内容概要 | 学习目标 |
|------|----------|----------|
| [设计模式概览](./02.3-设计模式/design-patterns-overview.md) | 23种设计模式分类和应用场景 | 设计模式入门 |
| [创建型模式](./02.3-设计模式/creational-patterns/README.md) | Factory、Builder、Singleton等 | 对象创建最佳实践 |
| [结构型模式](./02.3-设计模式/structural-patterns/README.md) | Adapter、Decorator、Facade等 | 对象组合和结构 |
| [行为型模式](./02.3-设计模式/behavioral-patterns/README.md) | Strategy、Observer、Chain等 | 对象交互和算法 |

**与@rules/规范集成**:
- **L2层级要求**: 创建型、结构型、行为型模式的具体应用
- **Spring Boot集成**: 使用注解实现各种设计模式
- **AI提示模板**: 如何让AI正确应用设计模式

#### 02.4 技术选型
| 文档 | 内容概要 | 决策参考 |
|------|----------|----------|
| [技术栈规范](./02.4-技术选型/technology-stack-specification.md) | 完整技术栈 + @rules/强制规范 | 技术决策 |
| [前端技术选型](./02.4-技术选型/frontend-technology-selection.md) | React、Vue、Angular对比 | 前端选型 |
| [后端技术选型](./02.4-技术选型/backend-technology-selection.md) | Spring Boot、NestJS、FastAPI对比 | 后端选型 |
| [数据库选型指南](./02.4-技术选型/database-selection-guide.md) | MySQL、PostgreSQL、MongoDB对比 | 数据库选型 |

**强制要求** (来自@rules/):
- **构建工具**: Gradle ≥ 8.14 (禁止Maven)
- **后端框架**: Spring Boot + MyBatis注解模式
- **API文档**: Springdoc OpenAPI (Swagger UI)
- **测试框架**: JUnit 5 + Mockito + Spring Boot Test

### 03. 开发规范
**编码规范、TDD实践、代码质量等开发相关规范**

#### 03.1 编码规范
| 文档 | 内容概要 | 使用频率 |
|------|----------|----------|
| [Java编码规范](./03.1-编码规范/java-coding-guidelines.md) | Java代码风格、命名、注释等 | 每日使用 |
| [TypeScript编码规范](./03.1-编码规范/typescript-coding-guidelines.md) | TS/JS代码规范 | 每日使用 |
| [Spring Boot最佳实践](./03.1-编码规范/spring-boot-best-practices.md) | Spring Boot使用技巧 | 经常参考 |
| [MyBatis使用指南](./03.1-编码规范/mybatis-usage-guide.md) | MyBatis注解模式使用 | 数据访问时 |

**@rules/规范重点**:
- **包结构**: 严格遵循`com.{company}.{project}`格式
- **命名规范**: UpperCamelCase类名，lowerCamelCase方法名
- **MyBatis**: 优先使用注解模式，复杂查询使用@Results映射

#### 03.2 TDD测试驱动开发
| 文档 | 内容概要 | 学习目标 |
|------|----------|----------|
| [TDD实践指南](./03.2-TDD实践/TDD-practice-guide.md) | 完整的TDD工作流程 | 掌握测试驱动开发 |
| [单元测试最佳实践](./03.2-TDD实践/unit-testing-best-practices.md) | JUnit、Mockito使用技巧 | 提高测试质量 |
| [测试覆盖率标准](./03.2-TDD实践/test-coverage-standards.md) | 覆盖率要求和测量方法 | 质量保证 |
| [Mock和Stub使用指南](./03.2-TDD实践/mock-and-stub-guide.md) | 测试替身使用场景 | 隔离测试 |

**质量门禁**:
- **测试覆盖率**: ≥ 80%
- **测试工具**: JUnit 5 + Mockito + Spring Boot Test
- **CI集成**: 自动化测试在每次提交时运行

#### 03.3 代码质量
| 文档 | 内容概要 | 质量保障 |
|------|----------|----------|
| [代码审查指南](./03.3-代码质量/code-review-guidelines.md) | Code Review流程和标准 | 代码质量保证 |
| [SonarQube使用指南](./03.3-代码质量/sonarqube-usage-guide.md) | 静态代码分析工具 | 自动质量检查 |
| [技术债务管理](./03.3-代码质量/technical-debt-management.md) | 识别、记录和偿还技术债务 | 长期可维护性 |
| [性能优化指南](./03.3-代码质量/performance-optimization-guide.md) | 常见性能问题和优化方案 | 性能保障 |

### 04. AI协作指南
**如何与AI协作进行软件开发**

#### 04.1 AI编码最佳实践
| 文档 | 内容概要 | AI协作技巧 |
|------|----------|------------|
| [AI协作开发流程](./04.1-AI编码最佳实践/AI-collaboration-workflow.md) | 完整的AI协作开发流程 | 全流程协作 |
| [提示词工程](./04.1-AI编码最佳实践/prompt-engineering-guide.md) | 如何编写有效的AI提示 | 提高AI输出质量 |
| [AI代码审查](./04.1-AI编码最佳实践/AI-code-review.md) | 如何让AI帮助审查代码 | 辅助Code Review |
| [AI辅助重构](./04.1-AI编码最佳实践/AI-assisted-refactoring.md) | 使用AI进行代码重构 | 技术债务偿还 |

**核心技巧**:
- **小步快跑**: 需求拆分成小任务，提高AI准确率
- **充分上下文**: 提供完整的SDD规范和@rules/要求
- **明确指令**: 指定设计模式、技术栈和编码规范
- **渐进优化**: 先生成框架，再逐步完善细节

#### 04.2 提示词模板库
| 文档 | 内容概要 | 使用场景 |
|------|----------|----------|
| [Spring Boot代码生成模板](./04.2-提示词模板库/spring-boot-code-generation.md) | 生成Spring Boot代码的标准提示 | 后端开发 |
| [React组件生成模板](./04.2-提示词模板库/react-component-generation.md) | 生成React组件的提示模板 | 前端开发 |
| [设计模式实现模板](./04.2-提示词模板库/design-pattern-implementation.md) | 实现特定设计模式的提示 | 架构设计 |
| [单元测试生成模板](./04.2-提示词模板库/unit-test-generation.md) | 生成单元测试的提示模板 | 测试开发 |

**通用模板结构**:
```
角色：[专业角色]
任务：[具体任务]
要求：
1. [规范要求1]
2. [规范要求2]
3. [质量要求]

上下文：
[SDD规范内容]

输出格式：
[期望的输出格式]
```

### 05. 需求与设计
**需求分析、SDD规范和设计文档**

#### 05.1 需求文档
| 文档 | 内容概要 | 使用场景 |
|------|----------|----------|
| [需求分析指南](./05.1-需求文档/requirement-analysis-guide.md) | 如何分析和编写需求 | 需求阶段 |
| [用户故事模板](./05.1-需求文档/user-story-template.md) | 用户故事编写格式 | 敏捷开发 |
| [需求优先级划分](./05.1-需求文档/requirement-prioritization.md) | MoSCoW法则等优先级方法 | 版本规划 |

#### 05.2 SDD规范
| 文档 | 内容概要 | AI协作必备 |
|------|----------|------------|
| [SDD规范模板](./05.2-SDD规范/SDD-specification-template.md) | 完整SDD模板 + 设计模式集成 | 必备 |
| [SDD编写指南](./05.2-SDD规范/SDD-writing-guide.md) | 如何编写高质量的SDD | 编写时参考 |
| [SDD评审标准](./05.2-SDD规范/SDD-review-criteria.md) | SDD质量评审标准 | 评审时使用 |
| [设计模式选择指南](./05.2-SDD规范/design-pattern-selection-guide.md) | 如何选择合适的设计模式 | 设计阶段 |

**新增内容** (基于@rules/规范):
- **设计模式集成**: 如何在SDD中指定设计模式
- **AI提示模板**: 如何描述需求让AI更好理解
- **规范检查清单**: SDD必须包含的要素

#### 05.3 原型与线框图
| 文档 | 内容概要 | 使用工具 |
|------|----------|----------|
| [原型设计指南](./05.3-原型与线框图/prototype-design-guide.md) | 原型设计原则和方法 | Figma/Sketch |
| [线框图规范](./05.3-原型与线框图/wireframe-guidelines.md) | 线框图绘制标准 | Balsamiq |

### 06. 实施案例
**实际项目案例、代码示例和最佳实践**

#### 06.1 完整项目案例
| 文档 | 内容概要 | 学习价值 |
|------|----------|----------|
| [电商系统案例](./06.1-完整项目案例/ecommerce-system-case.md) | 完整的电商系统SDD到实现 | 全流程学习 |
| [用户管理系统](./06.1-完整项目案例/user-management-system.md) | 用户注册登录系统实现 | 基础系统开发 |
| [订单处理系统](./06.1-完整项目案例/order-processing-system.md) | 订单流转系统实现 | 复杂业务处理 |

**案例特点**:
- **完整SDD**: 从需求到设计的完整规范
- **设计模式**: 展示如何在实际项目中应用设计模式
- **AI生成**: 提供AI生成的完整代码示例
- **测试覆盖**: 包含完整的测试用例和实现

#### 06.2 代码示例库
| 文档 | 内容概要 | 参考价值 |
|------|----------|----------|
| [Spring Boot代码示例](./06.2-代码示例库/spring-boot-examples.md) | 各种Spring Boot功能实现 | 日常开发参考 |
| [React组件示例](./06.2-代码示例库/react-component-examples.md) | 常用React组件实现 | 前端开发参考 |
| [设计模式实现示例](./06.2-代码示例库/design-pattern-examples.md) | 23种设计模式代码实现 | 架构设计参考 |
| [AI协作示例](./06.2-代码示例库/AI-collaboration-examples.md) | AI协作开发完整对话示例 | AI协作学习 |

### 07. 技术文档
**具体技术实现文档和API文档**

#### 07.1 技术实现文档
| 文档 | 内容概要 | 开发人员 |
|------|----------|----------|
| [Spring Boot配置详解](./07.1-技术实现文档/spring-boot-configuration-guide.md) | 各种配置场景和最佳实践 | Spring Boot开发 |
| [MyBatis高级用法](./07.1-技术实现文档/mybatis-advanced-usage.md) | 复杂查询和高级特性 | 数据访问开发 |
| [Redis缓存策略](./07.1-技术实现文档/redis-caching-strategies.md) | 缓存更新、失效、穿透等策略 | 性能优化 |
| [Docker部署指南](./07.1-技术实现文档/docker-deployment-guide.md) | 容器化部署完整流程 | DevOps |

#### 07.2 API文档
| 文档 | 内容概要 | 使用方式 |
|------|----------|----------|
| [API设计规范](./07.2-API文档/api-design-specification.md) | RESTful API设计标准 | API设计时 |
| [API版本管理](./07.2-API文档/api-versioning-strategy.md) | API版本演进策略 | API变更时 |
| [API文档自动生成](./07.2-API文档/api-documentation-generation.md) | Swagger/OpenAPI使用 | 文档生成 |

### 08. 测试文档
**测试策略、测试工具和测试自动化**

#### 08.1 测试策略
| 文档 | 内容概要 | 测试阶段 |
|------|----------|----------|
| [测试策略总览](./08.1-测试策略/testing-strategy-overview.md) | 整体测试策略和金字塔模型 | 测试规划 |
| [集成测试指南](./08.1-测试策略/integration-testing-guide.md) | 服务集成测试方法 | 集成测试 |
| [性能测试方案](./08.1-测试策略/performance-testing-plan.md) | 性能测试场景和指标 | 性能测试 |
| [安全测试清单](./08.1-测试策略/security-testing-checklist.md) | 安全测试项目和工具 | 安全测试 |

#### 08.2 测试工具
| 文档 | 内容概要 | 工具使用 |
|------|----------|----------|
| [Jest使用指南](./08.2-测试工具/jest-usage-guide.md) | Jest测试框架详解 | 前端测试 |
| [JUnit 5高级特性](./08.2-测试工具/junit5-advanced-features.md) | JUnit 5新特性使用 | 后端测试 |
| [Testcontainers实战](./08.2-测试工具/testcontainers-practice.md) | 数据库测试容器使用 | 集成测试 |
| [Cypress端到端测试](./08.2-测试工具/cypress-e2e-testing.md) | E2E测试框架使用 | 端到端测试 |

### 09. 知识沉淀
**经验总结、最佳实践和教训反思**

#### 09.1 经验总结
| 文档 | 内容概要 | 参考价值 |
|------|----------|----------|
| [项目复盘总结](./09.1-经验总结/project-retrospective.md) | 项目完成后的复盘和经验 | 避免重复错误 |
| [技术难点攻关](./09.1-经验总结/technical-challenges-solutions.md) | 遇到的技术难题和解决方案 | 技术储备 |
| [性能优化案例](./09.1-经验总结/performance-optimization-cases.md) | 真实的性能优化案例 | 性能优化参考 |

#### 09.2 最佳实践
| 文档 | 内容概要 | 实践指导 |
|------|----------|----------|
| [Spring Boot最佳实践汇总](./09.2-最佳实践/spring-boot-best-practices-summary.md) | Spring Boot开发最佳实践 | 开发参考 |
| [React性能优化技巧](./09.2-最佳实践/react-performance-tips.md) | React性能优化方法 | 前端优化 |
| [数据库设计最佳实践](./09.2-最佳实践/database-design-best-practices.md) | 数据库设计原则和技巧 | 数据库设计 |

### 10. 培训资料
**团队培训、技能提升和知识分享材料**

#### 10.1 内部培训
| 文档 | 内容概要 | 培训对象 |
|------|----------|----------|
| [Spring Boot入门培训](./10.1-内部培训/spring-boot-intro-training.md) | Spring Boot基础培训材料 | 新员工 |
| [React Hooks深入理解](./10.1-内部培训/react-hooks-deep-dive.md) | React Hooks高级特性 | 前端开发 |
| [设计模式工作坊](./10.1-内部培训/design-patterns-workshop.md) | 设计模式互动学习材料 | 全团队 |

#### 10.2 技术分享
| 文档 | 内容概要 | 分享主题 |
|------|----------|----------|
| [微服务架构演进](./10.2-技术分享/microservices-architecture-evolution.md) | 微服务架构发展历程 | 架构演进 |
| [AI在软件开发中的应用](./10.2-技术分享/AI-in-software-development.md) | AI工具和能力介绍 | AI应用 |
| [云原生技术趋势](./10.2-技术分享/cloud-native-technology-trends.md) | 云原生技术发展 | 技术趋势 |

### 11. 流程与工具
**开发流程、工具使用和工作效率提升**

#### 11.1 开发流程
| 文档 | 内容概要 | 流程优化 |
|------|----------|----------|
| [敏捷开发流程](./11.1-开发流程/agile-development-process.md) | Scrum流程和实践 | 项目管理 |
| [CI/CD流水线的搭建](./11.1-开发流程/cicd-pipeline-setup.md) | 持续集成部署流程 | 自动化部署 |
| [Git工作流规范](./11.1-开发流程/git-workflow-guide.md) | 分支管理和提交规范 | 版本控制 |

#### 11.2 工具使用
| 文档 | 内容概要 | 效率提升 |
|------|----------|----------|
| [IDE高效使用技巧](./11.2-工具使用/ide-productivity-tips.md) | IDE高级功能使用 | 开发效率 |
| [命令行工具推荐](./11.2-工具使用/command-line-tools.md) | 提升效率的命令行工具 | 工作效率 |
| [Chrome开发者工具](./11.2-工具使用/chrome-devtools-guide.md) | 前端调试工具使用 | 调试效率 |

### 12. 安全与合规
**安全开发、合规要求和数据保护**

#### 12.1 安全开发
| 文档 | 内容概要 | 安全要求 |
|------|----------|----------|
| [安全编码规范](./12.1-安全开发/secure-coding-guidelines.md) | OWASP Top 10防范 | 安全开发 |
| [JWT认证最佳实践](./12.1-安全开发/jwt-authentication-best-practices.md) | JWT安全使用指南 | 认证安全 |
| [SQL注入防护](./12.1-安全开发/sql-injection-prevention.md) | SQL注入攻击防护 | 数据安全 |

#### 12.2 合规要求
| 文档 | 内容概要 | 合规要求 |
|------|----------|----------|
| [GDPR合规指南](./12.2-合规要求/gdpr-compliance-guide.md) | 欧盟数据保护法规 | 数据保护 |
| [代码许可证说明](./12.2-合规要求/code-license-guide.md) | 开源许可证使用 | 知识产权 |

### 13. 度量与分析
**团队度量、数据分析和持续改进**

#### 13.1 团队度量
| 文档 | 内容概要 | 度量指标 |
|------|----------|----------|
| [开发效率度量](./13.1-团队度量/development-efficiency-metrics.md) | 效率指标定义和测量 | 效率提升 |
| [代码质量度量](./13.1-团队度量/code-quality-metrics.md) | 质量指标和分析方法 | 质量保障 |
| [AI协作效果分析](./13.1-团队度量/AI-collaboration-effectiveness.md) | AI协作指标和效果 | AI优化 |

#### 13.2 数据分析
| 文档 | 内容概要 | 数据驱动 |
|------|----------|----------|
| [开发数据收集](./13.2-数据分析/development-data-collection.md) | 数据收集方法和工具 | 数据收集 |
| [数据可视化实践](./13.2-数据分析/data-visualization-practice.md) | 数据展示和分析技巧 | 数据展示 |

### 14. 参考资料
**外部资源、学习材料和参考链接**

#### 14.1 官方文档
| 资源 | 链接 | 说明 |
|------|------|------|
| Spring Boot官方文档 | https://spring.io/projects/spring-boot | Spring Boot权威参考 |
| React官方文档 | https://react.dev/ | React最新文档 |
| MyBatis官方文档 | https://mybatis.org/mybatis-3/ | MyBatis使用指南 |

#### 14.2 学习资源
| 资源 | 链接 | 说明 |
|------|------|------|
| Spring官方指南 | https://spring.io/guides | Spring系列教程 |
| MDN Web文档 | https://developer.mozilla.org/ | Web技术参考 |
| OWASP安全指南 | https://owasp.org/ | Web安全最佳实践 |

---

## 🎯 使用指南

### 新功能开发流程（基于 @rules/ 规范）

```
步骤0: 阅读 @rules/ 目录下的相关规范
    ↓
步骤1: 阅读开发章程（了解强制规范）
    ↓
步骤2: 选择设计模式（参考架构设计原则）
    ↓
步骤3: 编写SDD规范（使用设计模式指南）
    ↓
步骤4: 创建测试用例（遵循TDD流程）
    ↓
步骤5: AI辅助代码生成（提供详细规范）
    |  Prompt模板: "根据以下SDD规范，使用{设计模式}生成Spring Boot代码..."
    ↓
步骤6: 验证代码符合 @rules/ 规范
    ↓
步骤7: 验证测试通过
    ↓
步骤8: Code Review（检查规范符合性）
    ↓
步骤9: 合并部署
```

### 按角色使用指南

| 角色 | 核心文档 | 辅助文档 | 规范要求 |
|------|----------|----------|----------|
| **开发人员** | SDD模板、TDD指南、开发章程 | 架构设计原则、编码规范 | 必须遵循 @rules/ 所有编码规范 |
| **架构师** | 架构设计原则、技术栈规范 | 设计模式规范、ADR文档 | 负责制定和维护 @rules/ 规范 |
| **技术负责人** | 全部文档 | - | 确保团队遵循规范 |
| **新成员** | 开发章程、TDD指南、入职指南 | 技术栈规范 | 首先学习 @rules/ 基础规范 |
| **AI协作专员** | AI协作指南、SDD模板 | 提示词模板库 | 优化AI协作流程 |

### 快速参考（@rules/ 规范重点）

#### 开始编码前（必须完成）
1. ✅ 阅读 [开发章程](./01.1-项目概览/development-charter.md)（了解 @rules/ 强制规范）
2. ✅ 理解项目结构：`com.{company}.{project}` 包结构
3. ✅ 确认技术栈：Spring Boot + MyBatis + Gradle
4. ✅ 准备 SDD 设计文档（包含设计模式选择）
5. ✅ 了解相关技术栈规范
6. ✅ 设置开发环境

#### 编码过程中（必须遵循）
1. ✅ 遵循 TDD 流程 (红-绿-重构)
2. ✅ 使用强制目录结构（参考架构设计原则）
3. ✅ 应用设计模式（参考SDD模板中的模式指南）
4. ✅ 遵守代码规范（控制器、服务层、数据访问规范）
5. ✅ 编写单元测试（JUnit 5 + Mockito）
6. ✅ 使用统一响应模型（CommonResponse）
7. ✅ 遵循异常处理规范（@ControllerAdvice）
8. ✅ 符合日志规范（SLF4J + AOP）

#### 代码提交前（强制检查）
1. ✅ 所有测试通过
2. ✅ 代码覆盖率 ≥ 80%
3. ✅ 符合 Code Review 标准
4. ✅ 文档同步更新
5. ✅ 代码符合 @rules/ 所有规范

---

## 🔗 快速链接

### 核心流程文档
- [项目章程](./01.1-项目概览/development-charter.md) - 起点，了解@rules/强制规范
- [架构设计原则](./02.1-架构文档/architecture-design-principles.md) - 架构规范
- [技术栈规范](./02.4-技术选型/technology-stack-specification.md) - 技术选型
- [SDD模板](./05.2-SDD规范/SDD-specification-template.md) - 设计规范
- [TDD指南](./03.2-TDD实践/TDD-practice-guide.md) - 测试驱动

### AI协作核心文档
- [AI协作开发流程](./04.1-AI编码最佳实践/AI-collaboration-workflow.md) - AI协作全流程
- [提示词模板库](./04.2-提示词模板库/) - 各种场景的AI提示模板
- [设计模式选择指南](./05.2-SDD规范/design-pattern-selection-guide.md) - 设计模式应用

### 规范参考文档
- [编码规范](./03.1-编码规范/) - 各语言编码标准
- [测试策略](./08.1-测试策略/) - 测试方法和策略
- [安全开发](./12.1-安全开发/) - 安全开发要求

---

## 📋 检查清单

### 项目启动检查清单（基于 @rules/ 规范）
- [ ] 团队熟悉开发章程（特别是 @rules/ 强制规范）
- [ ] 理解 @rules/ 项目结构要求
- [ ] SDD 模板已准备好（包含设计模式指南）
- [ ] TDD 环境配置完成
- [ ] 技术栈已确定（Spring Boot + MyBatis + Gradle）
- [ ] 架构原则已明确（包括设计模式规范）
- [ ] 代码规范培训完成（@rules/ 各层级规范）
- [ ] AI协作流程培训完成

### 功能开发检查清单（基于 @rules/ 规范）
- [ ] SDD 文档评审通过（包含设计模式选择）
- [ ] 测试用例已编写（遵循TDD流程）
- [ ] AI Prompt 已准备（包含设计模式说明）
- [ ] 代码实现已完成（符合 @rules/ 规范）
- [ ] 测试覆盖率达标（≥80%）
- [ ] Code Review 通过（检查规范符合性）
- [ ] 代码符合项目结构规范
- [ ] 遵循命名和编码规范
- [ ] AI生成代码已验证

### 部署上线检查清单
- [ ] 所有功能测试通过
- [ ] 性能测试完成
- [ ] 安全扫描通过
- [ ] 文档已更新
- [ ] 监控告警配置
- [ ] 回滚方案准备

---

## 💡 最佳实践

### 文档驱动开发（DDD）
```
文档先行 → 评审通过 → AI生成 → 人工验证 → 测试确认
```

### TDD循环
```
红 (失败测试) → 绿 (通过代码) → 重构 (优化)
↑                                   ↓
└─────────────── 重复 ───────────────┘
```

### AI协作流程（基于 @rules/ 规范）
```
清晰规范（SDD+设计模式） → 充分上下文（@rules/规范） → 明确指令（模式+规范） → 验证结果（符合@rules/）
```

### 设计模式应用流程
```
业务需求 → 模式选择 → SDD描述 → AI生成 → 模式验证 → 集成测试
```

---

## 📞 反馈与更新

### 文档更新流程
1. 发现需要改进的地方
2. 发起讨论或 Issue
3. 提交 PR 更新文档
4. 团队评审和合并
5. 通知团队成员
6. 更新@rules/目录规范（如需要）

### 规范维护
- **@rules/目录**: 由架构团队维护，季度审核
- **技术文档**: 由各技术负责人维护
- **案例和示例**: 由开发团队共同维护
- **AI协作指南**: 由AI协作专员维护

### 贡献指南
- 每个文档都有明确的责任人
- 重大变更需要架构师审核
- 定期回顾和更新文档
- 保持文档与代码同步
- 及时更新@rules/目录下的规范

---

## 版本历史

| 版本 | 日期 | 更新内容 | 更新人 |
|------|------|----------|--------|
| 2.0 | 2024-11-30 | 新增@rules/目录规范完整集成 | 架构团队 |
| 1.0 | 2024-01-01 | 完整版知识库索引创建 | 架构团队 |

**维护者**: 架构团队
**审核周期**: 每季度
**状态**: 持续更新中

---

> **提示**: 本文档是完整版知识库索引，基于@rules/目录规范构建。精简版请参考[../../documents/知识索引.md](../../documents/知识索引.md)
>
> **重要**: @rules/目录下的规范是强制要求，所有开发活动必须严格遵循。完整规范请参考项目根目录下的@rules/目录。`