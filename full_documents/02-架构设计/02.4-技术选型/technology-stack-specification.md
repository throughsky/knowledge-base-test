---
title: 技术栈规范
author:
created: 2024-01-01
updated: 2024-11-30
version: 2.0
status: 已发布
tags: [技术栈, 选型规范, 后端规范, Spring Boot]
---

# 技术栈规范

> 项目的核心技术栈和工具选择指南
> 基于 @rules/ 目录规范的关键要求总结

## 0. Spring Boot 核心规范（强制要求）

### 0.1 核心技术栈（来自 @rules/01-structure/tech-stack.mdc）

**构建工具（强制）**：
- **Gradle ≥ 8.14**（唯一构建工具，禁止Maven）
- 必需文件：`build.gradle`、`settings.gradle`、`gradle.properties`
- 禁止生成 `pom.xml`

**核心框架**：
- Spring Boot（应用启动、自动装配、生产级特性）
- Spring Framework（依赖注入、AOP、事务、Web MVC）
- Spring Security（认证、授权、过滤链、方法级安全）

**数据访问（强制）**：
- MyBatis/MyBatis-Spring（半自动化SQL映射，**注解模式**）
- MySQL 8.0+ + mysql-connector-j
- 数据库设计规范：参考 `@rules/02-design/database.mdc`

**API层**：
- Spring MVC（RESTful API、请求映射、拦截器、参数校验）
- Springdoc OpenAPI（OpenAPI 3文档生成、Swagger UI）
- Jakarta Validation（Bean参数校验：@Valid、@NotNull等）

**数据处理**：
- Jackson（JSON序列化/反序列化、时间格式、忽略策略）
- 统一响应模型：必须实现 `CommonResponse`、`PageData`

**缓存与性能**：
- Spring Cache（方法级缓存：@Cacheable/@CacheEvict）
- Redis（分布式缓存、会话共享、限流）

**异步与消息**：
- Spring @Async/Scheduling（异步任务与定时任务）
- Apache Kafka/RabbitMQ（可选：事件驱动架构）

**观测性**：
- SLF4J + Logback（日志门面与实现、分环境日志策略）
- Spring Boot Actuator（健康检查、指标、环境信息）

**测试框架（强制）**：
- JUnit 5（单元测试标准框架）
- Mockito（Mock依赖、交互验证）
- Spring Boot Test/MockMvc（集成测试、Web层测试）

### 0.2 代码结构规范（来自 @rules/01-structure/project.mdc）

**强制包结构**：
```
com.{company}.{app}/
├── {AppName}Application.java          # 主类（首字母大写）
├── config/                            # 配置类
├── controller/                        # REST控制器
├── service/                           # 服务接口
│   └── impl/                          # 服务实现
├── entity/                            # JPA实体
├── mapper/                            # MyBatis Mapper
├── dto/                               # 数据传输对象
├── enums/                             # 枚举（*Enum.java结尾）
├── constants/                         # 常量（错误码用枚举）
├── vo/
│   ├── request/                       # 请求对象
│   │   ├── CommonRequest.java         # 必须
│   │   ├── CommonPageRequest.java     # 必须
│   │   └── {Feature}Request.java
│   └── response/                      # 响应对象
│       ├── CommonResponse.java        # 必须
│       ├── PageData.java              # 必须
│       └── {Feature}Response.java
├── exception/                         # 自定义异常
├── task/                              # 定时任务
├── util/                              # 工具类
└── security/                          # 安全相关
```

**测试目录（必须创建）**：
```
test/java/com/{company}/{app}/
├── controller/                        # 控制器测试
├── service/                           # 服务测试
└── mapper/                            # Mapper测试
```

### 0.3 设计模式应用（来自 @rules/02-design/patterns.mdc）

**配置管理** → Builder模式：
- 复杂配置对象构建
- 配置参数验证
- 链式配置设置

**服务层设计** → Strategy模式：
- 业务策略选择（支付、验证、处理策略）
- 算法动态切换
- 策略组合使用

**异常处理** → Chain of Responsibility模式：
- 异常处理链
- 责任链传递
- 动态异常处理

**事件驱动** → Observer模式：
- 事件发布订阅
- 状态变更通知
- 解耦事件处理

**对象创建** → Factory模式：
- Service工厂创建
- Validator工厂创建
- Processor工厂创建

### 0.4 代码规范（来自 @rules/03-coding/ 和 @rules/04-conventions/）

**控制器规范**（@rules/04-conventions/controller.mdc）：
- 使用 `@RestController` 注解
- 类级别 `@RequestMapping` 指定版本（如 `/api/v1`）
- 方法级别映射使用具体HTTP方法注解
- 参数校验使用 `@Valid` 注解
- 统一返回 `CommonResponse` 包装对象

**服务层规范**（@rules/04-conventions/service.mdc 和 service-impl.mdc）：
- 接口定义在 service 包
- 实现类在 service.impl 包，命名为 `{Interface}Impl`
- 使用 `@Service` 注解
- 事务管理使用 `@Transactional`

**数据访问规范**（@rules/04-conventions/mapper.mdc）：
- MyBatis注解模式优先
- SQL写在 `@Select`, `@Insert`, `@Update`, `@Delete` 注解中
- 复杂SQL使用 `@Results` 和 `@Result` 映射

**异常处理规范**（@rules/04-conventions/exception.mdc 和 exception-handler.mdc）：
- 自定义异常继承 `RuntimeException`
- 使用 `@ControllerAdvice` 统一异常处理
- 错误码使用枚举定义（@rules/04-conventions/error-code-enum.mdc）

**日志规范**（@rules/04-conventions/logging-aspect.mdc）：
- 使用 SLF4J Logger
- 统一日志格式：`[className] [methodName] [params] [result] [costTime]`
- 使用AOP统一记录方法调用日志

## 1. 前端技术栈

### 1.1 框架选型

**React 18+ (推荐)**
- 适用场景: 大型 SPA, 需要高度交互的应用
- 优势: 生态成熟, 社区活跃, 灵活性高
- 关键库:
  - `react-router-dom` - 路由管理
  - `@tanstack/react-query` - 数据获取和缓存
  - `zustand` - 状态管理 (轻量级)
  - `formik` - 表单处理

**Next.js 14 (推荐)**
- 适用场景: SSR, SSG, 全栈应用
- 优势: 开箱即用, SEO 友好, 性能优秀
- App Router - React Server Components
- TypeScript 支持良好

### 1.2 语言
- **TypeScript 5.3+**: 强制类型安全
- 配置严格的 tsconfig.json
- 启用 strict mode

### 1.3 UI 库

**Ant Design 5.x**
- 企业级 UI 组件库
- TypeScript 支持
- 完善的国际化

**Tailwind CSS**
- 原子化 CSS 框架
- 高度可定制
- 文件体积小

### 1.4 构建工具
- **Vite 5.x**: 开发体验优秀, 构建速度快

### 1.5 测试工具
- **Jest**: 单元测试框架
- **React Testing Library**: React 组件测试
- **Cypress**: E2E 测试

### 1.6 代码质量
- **ESLint**: 代码检查
- **Prettier**: 代码格式化

## 2. 后端技术栈

### 2.1 Spring Boot 生态（强制）

**核心依赖管理**：
```xml
<!-- Spring Boot Starter -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>

<!-- MyBatis Spring Boot Starter -->
<dependency>
    <groupId>org.mybatis.spring.boot</groupId>
    <artifactId>mybatis-spring-boot-starter</artifactId>
    <version>3.0.1</version>
</dependency>

<!-- SpringDoc OpenAPI -->
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.1.0</version>
</dependency>
```

**Gradle 配置示例**（来自 @rules/04-conventions/gradle.mdc）：
```gradle
plugins {
    id 'java'
    id 'org.springframework.boot' version '3.1.0'
    id 'io.spring.dependency-management' version '1.1.0'
}

group = 'com.example'
version = '0.0.1-SNAPSHOT'

java {
    sourceCompatibility = '17'
}

configurations {
    compileOnly {
        extendsFrom annotationProcessor
    }
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-security'
    implementation 'org.mybatis.spring.boot:mybatis-spring-boot-starter:3.0.1'
    implementation 'org.springdoc:springdoc-openapi-starter-webmvc-ui:2.1.0'

    runtimeOnly 'mysql:mysql-connector-java:8.0.33'

    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'org.mybatis.spring.boot:mybatis-spring-boot-starter-test:3.0.1'
}
```

### 2.2 数据库

**PostgreSQL 15+ (推荐)**
- 功能最丰富
- 强大的 JSONB 支持

**MySQL 8.0+ (强制)**
- 使用广泛
- 性能优秀

**Redis 7+**
- 缓存和会话存储

### 2.3 消息队列

**RabbitMQ**
- 可靠的消息传递

**Apache Kafka**
- 高吞吐量
- 持久化日志

**应用场景**: 异步处理、服务解耦、流量削峰

### 2.4 容器化

**Docker**
```dockerfile
# 多阶段构建优化
FROM openjdk:17-alpine AS builder
WORKDIR /app
COPY build.gradle settings.gradle ./
RUN ./gradlew dependencies --no-daemon
COPY . .
RUN ./gradlew build --no-daemon

FROM openjdk:17-alpine
WORKDIR /app
COPY --from=builder /app/build/libs/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### 2.5 CI/CD

**GitHub Actions** 或 **GitLab CI**

**Jenkins**（企业级）

### 2.6 API 网关

**Kong** 或 **Nginx**

### 2.7 监控和日志

**Prometheus + Grafana** - 监控
**ELK Stack** - 日志收集和分析

## 3. 安全规范

### 3.1 依赖安全

**定期扫描**
```bash
# Gradle 依赖检查
./gradlew dependencyCheckAnalyze

# OWASP 依赖检查
./gradlew dependency-check --info
```

### 3.2 密钥管理

```typescript
// ✅ 使用环境变量
const API_KEY = process.env.API_KEY;

// ❌ 不要硬编码
const API_KEY = 'sk-1234567890abcdef';
```

### 3.3 Spring Security 配置（来自 @rules/04-conventions/security-config.mdc）

```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf().disable()
            .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            .and()
            .authorizeHttpRequests(authz -> authz
                .requestMatchers("/api/v1/auth/**").permitAll()
                .requestMatchers("/swagger-ui/**", "/v3/api-docs/**").permitAll()
                .anyRequest().authenticated()
            )
            .oauth2ResourceServer(OAuth2ResourceServerConfigurer::jwt);

        return http.build();
    }
}
```

## 4. 性能目标

### 4.1 API 性能

| 指标 | 目标 |
|------|------|
| P50 响应时间 | < 100ms |
| P95 响应时间 | < 200ms |
| P99 响应时间 | < 500ms |
| 错误率 | < 0.1% |
| 吞吐量 | 1000+ TPS |

### 4.2 前端性能

| 指标 | 目标 |
|------|------|
| 首屏加载时间 | < 3s |
| FCP | < 1.8s |
| LCP | < 2.5s |
| CLS | < 0.1 |

## 5. 技术选型标准

### 5.1 后端框架选择矩阵

| 因素 | Spring Boot | NestJS | FastAPI |
|------|-------------|---------|---------|
| 团队熟悉度 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| 生态成熟度 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| 性能 | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| 类型安全 | ⭐⭐⭐ (Java) | ⭐⭐⭐⭐⭐ (TS) | ⭐⭐⭐⭐ (Python类型提示) |

### 5.2 数据库选择

| 场景 | 推荐 | 备选 |
|------|------|------|
| 关系型数据 | PostgreSQL | MySQL |
| 键值存储 | Redis | Memcached |
| 文档存储 | MongoDB | DynamoDB |

### 5.3 技术选型决策树

```
需要类型安全?
├─ 是 → 团队熟悉 Java?
│   ├─ 是 → Spring Boot
│   └─ 否 → NestJS
└─ 否 → 需要高性能?
    ├─ 是 → FastAPI
    └─ 否 → Express.js
```

## 6. 技术债务管理

### 6.1 依赖更新策略

```json
{
  "dependencies": {
    "主要依赖": "及时更新",
    "次要依赖": "定期更新"
  }
}
```

### 6.2 版本控制

```bash
# 使用 lockfile
./gradlew build --write-locks        # 更新依赖锁
./gradlew build --refresh-dependencies # 强制刷新依赖

# 版本管理
springBootVersion = "3.1.0"
mybatisVersion = "3.0.1"
```

### 6.3 升级计划

| 技术 | 当前版本 | 目标版本 | 升级时间 |
|------|----------|----------|----------|
| Spring Boot | 2.7.x | 3.1.x | Q4 2024 |
| Java | 11 | 17 | Q1 2024 |
| MySQL | 5.7 | 8.0 | Q2 2024 |

## 7. 监控与运维

### 7.1 应用监控

**Micrometer + Prometheus**
```java
@RestController
@Timed
public class UserController {

    @GetMapping("/users/{id}")
    @Timed(value = "user.get", description = "Time taken to get user")
    public User getUser(@PathVariable Long id) {
        return userService.findById(id);
    }
}
```

### 7.2 链路追踪

**Spring Cloud Sleuth + Zipkin**
```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-sleuth</artifactId>
</dependency>
```

### 7.3 日志聚合

**ELK Stack (Elasticsearch + Logstash + Kibana)**

## 8. 开发工具

### 8.1 IDE 配置

**IntelliJ IDEA**（推荐）
- 启用 Spring Boot 插件
- 配置代码模板
- 集成 SonarLint

### 8.2 代码质量工具

**SonarQube**
- 静态代码分析
- 技术债务追踪
- 质量门禁

### 8.3 API 开发工具

**Postman** / **Insomnia**
**Swagger UI**（自动生成）

## 9. 最佳实践

### 9.1 配置管理

**Spring Boot Configuration**
```yaml
# application.yml
spring:
  profiles:
    active: dev
  datasource:
    url: jdbc:mysql://localhost:3306/myapp
    username: ${DB_USER}
    password: ${DB_PASSWORD}

# application-prod.yml
spring:
  datasource:
    url: jdbc:mysql://prod-server:3306/myapp
    hikari:
      maximum-pool-size: 20
```

### 9.2 异常处理

**统一异常处理**（来自 @rules/04-conventions/exception-handler.mdc）
```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<CommonResponse<Void>> handleBusinessException(BusinessException e) {
        return ResponseEntity.badRequest()
            .body(CommonResponse.error(e.getCode(), e.getMessage()));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<CommonResponse<Void>> handleException(Exception e) {
        log.error("系统异常", e);
        return ResponseEntity.internalServerError()
            .body(CommonResponse.error("INTERNAL_ERROR", "系统内部错误"));
    }
}
```

### 9.3 API 设计规范

**RESTful API 设计**
```
GET    /api/v1/users          # 获取用户列表
POST   /api/v1/users          # 创建用户
GET    /api/v1/users/{id}     # 获取指定用户
PUT    /api/v1/users/{id}     # 更新用户信息
DELETE /api/v1/users/{id}     # 删除用户
```

## 10. 版本历史

| 版本 | 日期 | 更新内容 | 更新人 |
|------|------|----------|--------|
| 2.0 | 2024-11-30 | 新增 @rules/ 目录规范集成 | 架构团队 |
| 1.0 | 2024-01-01 | 初始版本创建 | 架构团队 |

**维护者**: 架构团队
**审核周期**: 每季度
**状态**: 持续更新中

---

## 附录

### A. 相关文档
- [架构设计原则](../02.1-架构文档/architecture-design-principles.md)
- [设计模式指南](../02.3-设计模式/design-patterns-overview.md)
- [Spring Boot 配置参考](../02.1-架构文档/spring-boot-configuration.md)

### B. 快速参考卡

#### Spring Boot 注解速查
```java
@RestController     // REST控制器
@Service           // 业务服务
@Repository        // 数据访问
@Component         // 通用组件
@Configuration     // 配置类

@GetMapping        // GET请求
@PostMapping       // POST请求
@PutMapping        // PUT请求
@DeleteMapping     // DELETE请求

@RequestBody       // 请求体
@PathVariable      // 路径参数
@RequestParam      // 请求参数
@Valid             // 参数校验

@Transactional     // 事务管理
@Cacheable         // 方法缓存
@Async             // 异步方法
@Scheduled         // 定时任务
```

#### MyBatis 注解速查
```java
@Select            // 查询
@Insert            // 插入
@Update            // 更新
@Delete            // 删除

@Results           // 结果映射
@Result            // 字段映射
@One               // 一对一关联
@Many              // 一对多关联
```

### C. 常用命令

```bash
# 创建 Spring Boot 项目
spring init --dependencies=web,mybatis,security myapp

# 运行项目
./gradlew bootRun

# 构建项目
./gradlew build

# 运行测试
./gradlew test

# 生成 API 文档
./gradlew openapi3
```

### D. 故障排查

#### 常见问题
1. **依赖冲突**: 使用 `./gradlew dependencies` 检查
2. **端口占用**: 修改 `application.yml` 中的端口配置
3. **数据库连接失败**: 检查连接字符串和凭据
4. **MyBatis 映射错误**: 检查注解配置和字段映射

#### 性能调优
1. **连接池优化**: 调整 HikariCP 配置
2. **JVM 参数**: 设置合适的堆内存大小
3. **SQL 优化**: 使用 EXPLAIN 分析查询计划
4. **缓存配置**: 合理使用 Spring Cache

---

> **提示**: 本文档基于 @rules/ 目录规范制定，所有项目必须遵循相关强制要求。完整规范请参考项目根目录下的 @rules/ 目录。`