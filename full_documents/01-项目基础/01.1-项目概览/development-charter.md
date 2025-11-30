---
title: 开发章程
created: 2024-01-01
updated: 2024-11-30
version: 2.0
status: 已发布
tags: [开发章程, 核心原则, 编码规范, 项目规范, AI协作]
---

# 开发章程

> 团队开发的核心原则和基本约定
> 基于 @rules/ 目录规范的关键要求总结

## 0. 强制规范总览（来自 @rules/ 目录）

### 0.1 项目结构规范（强制）

**包命名规则**：
- 根包名：`com.{company}.{project}`
- 示例：`com.example.appname`
- 主类命名：`{AppName}Application.java`（首字母大写）

**强制目录结构**：
- `config/` - 配置类目录
- `controller/` - REST控制器目录
- `service/` - 服务接口目录
- `service/impl/` - 服务实现目录
- `entity/` - 实体类目录（对应数据库表）
- `mapper/` - MyBatis Mapper目录
- `vo/request/` - 请求对象目录
- `vo/response/` - 响应对象目录
- `exception/` - 自定义异常目录

**测试目录**：必须与 `main` 目录结构完全对应

### 0.2 构建工具规范（强制）

**Gradle 要求**：
- 唯一构建工具（**禁止Maven**）
- 版本：≥ 8.14
- 必需文件：`build.gradle`、`settings.gradle`
- 禁止生成 `pom.xml`

### 0.3 技术栈规范（强制）

**核心框架**：
- Spring Boot（应用启动、自动装配）
- Spring Framework（IoC、AOP、事务）
- Spring Security（认证、授权）

**数据访问**：
- MyBatis/MyBatis-Spring（**注解模式优先**）
- MySQL 8.0+

**API层**：
- Spring MVC（RESTful API）
- Springdoc OpenAPI（文档生成）
- Jakarta Validation（参数校验）

**测试框架**：
- JUnit 5（单元测试）
- Mockito（Mock依赖）
- Spring Boot Test（集成测试）

### 0.4 编码规范（关键要求）

**命名规范**：
- 包名：全小写，点分隔
- 类名：UpperCamelCase
- 方法名：lowerCamelCase
- 常量：全大写，下划线分隔

**控制器规范**（@rules/04-conventions/controller.mdc）：
- 使用 `@RestController` 注解
- 类级别 `@RequestMapping` 指定版本（如 `/api/v1`）
- 统一返回 `CommonResponse` 包装对象
- 参数校验使用 `@Valid` 注解

**服务层规范**（@rules/04-conventions/service.mdc）：
- 接口在 `service` 包
- 实现在 `service.impl` 包，命名为 `{Interface}Impl`
- 使用 `@Service` 注解
- 事务使用 `@Transactional`

**数据访问规范**（@rules/04-conventions/mapper.mdc）：
- MyBatis注解模式优先
- SQL写在 `@Select`, `@Insert`, `@Update`, `@Delete` 中
- 复杂SQL使用 `@Results` 和 `@Result` 映射

**异常处理规范**（@rules/04-conventions/exception.mdc）：
- 自定义异常继承 `RuntimeException`
- 使用 `@ControllerAdvice` 统一处理
- 错误码使用枚举定义

**日志规范**（@rules/04-conventions/logging-aspect.mdc）：
- 使用 SLF4J Logger
- 统一格式：`[className] [methodName] [params] [result] [costTime]`
- 使用AOP统一记录方法调用日志

### 0.5 设计模式应用（L2层级）

**创建型模式**：
- Builder模式：复杂对象构建
- Factory模式：对象创建管理
- Singleton模式：资源管理

**结构型模式**：
- Adapter模式：第三方服务适配
- Decorator模式：功能增强（日志、缓存）
- Facade模式：复杂子系统封装

**行为型模式**：
- Strategy模式：算法选择（支付、验证）
- Observer模式：事件通知
- Chain of Responsibility模式：责任链处理

### 0.6 质量要求

**测试覆盖率**：≥ 80%
**代码审查**：必须通过
**静态检查**：无严重问题
**安全扫描**：无高危漏洞

**禁止事项**：
- ❌ 直接提交到主分支
- ❌ 提交没有测试的代码
- ❌ 提交没有文档的功能
- ❌ 忽略 Code Review 意见

## 1. 开发理念

### 1.1 质量第一
- **测试覆盖**: 所有代码必须有相应的测试用例
- **Code Review**: 所有代码必须经过同行评审
- **文档同步**: 代码变更必须同步更新文档

### 1.2 规范驱动
- **先设计后实现**: 任何功能都必须先编写设计规范
- **规范即文档**: SDD 规范作为单一事实源
- **AI 友好**: 规范格式要便于 AI 理解和生成代码

### 1.3 持续改进
- **重构文化**: 定期重构，保持代码健康
- **技术债务管理**: 有计划地偿还技术债务
- **最佳实践**: 持续学习和应用行业最佳实践

### 1.4 AI 协作原则
- **清晰规范**: 提供详细的SDD文档和设计模式说明
- **充分上下文**: 在AI提示中包含@rules/规范要求
- **渐进式开发**: 小步快跑，快速验证
- **人机协作**: AI生成代码，人类审查优化

## 2. 开发流程

### 2.1 标准工作流

```
需求分析 → 规范编写 → 测试用例 → AI代码生成 → 代码审查 → 合并 → 部署
```

### 2.2 关键要求

| 阶段 | 要求 | 工具 | 交付物 |
|------|------|------|--------|
| 需求分析 | 用户故事必须清晰 | Jira | 用户故事 |
| 规范编写 | SDD 文档评审通过 | Confluence | SDD 文档 |
| 测试用例 | 测试覆盖率 > 80% | Jest/JUnit | 测试代码 |
| AI代码生成 | 基于SDD和设计模式 | AI工具 | 业务代码 |
| 代码审查 | 至少 1 人批准 | GitLab/GitHub | Review 记录 |
| 合并部署 | 自动化部署 | Jenkins/GitLab CI | 成功部署 |

### 2.3 AI协作流程

```
需求分析 → 选择设计模式 → 编写SDD → AI提示生成 → 代码验证 → 重构优化
```

**AI提示最佳实践**:
```
"根据以下SDD规范，使用{设计模式}生成Spring Boot代码：
- 遵循@rules/项目结构规范
- 使用MyBatis注解模式
- 实现统一响应模型
- 包含完整的单元测试"
```

## 3. 代码规范

### 3.1 基本原则
- **可读性**: 代码是写给人类看的，附带让机器执行
- **简洁性**: 简单优于复杂，清晰优于技巧
- **一致性**: 团队遵循统一的编码风格
- **AI友好**: 代码结构清晰，便于AI理解和维护

### 3.2 命名规范
- 使用有意义的英文命名
- 遵循语言社区惯例
- 避免缩写和拼音

```typescript
// ✅ 推荐
function calculateTotalPrice(items: CartItem[]): number

// ❌ 避免
function calcTtlPrc(itms: any[]): number
function jisuanJiage(shopingche: any[]): number
```

### 3.3 函数规范
- 单一职责: 一个函数只做一件事
- 短小精悍: 不超过 50 行
- 参数数量: 不超过 3 个

### 3.4 Spring Boot 编码规范

**控制器层**:
```java
@RestController
@RequestMapping("/api/v1/users")
@Tag(name = "用户管理", description = "用户相关操作")
public class UserController {

    @Operation(summary = "创建用户")
    @PostMapping
    public CommonResponse<UserResponse> createUser(@Valid @RequestBody CreateUserRequest request) {
        User user = userService.createUser(request);
        return CommonResponse.success(UserResponse.from(user));
    }
}
```

**服务层**:
```java
@Service
@Slf4j
public class UserServiceImpl implements UserService {

    @Override
    @Transactional
    public User createUser(CreateUserRequest request) {
        log.info("创建用户: {}", request.getEmail());

        // 1. 参数校验
        validateCreateUserRequest(request);

        // 2. 业务逻辑
        User user = User.create(request.getEmail(), request.getPassword());

        // 3. 保存数据
        userRepository.save(user);

        log.info("用户创建成功: {}", user.getId());
        return user;
    }
}
```

**数据访问层**:
```java
@Mapper
public interface UserMapper {

    @Select("SELECT * FROM users WHERE id = #{id}")
    @Results({
        @Result(column = "id", property = "id", id = true),
        @Result(column = "email", property = "email"),
        @Result(column = "password_hash", property = "passwordHash"),
        @Result(column = "status", property = "status"),
        @Result(column = "created_at", property = "createdAt"),
        @Result(column = "updated_at", property = "updatedAt")
    })
    User findById(Long id);

    @Insert("INSERT INTO users(email, password_hash, status) VALUES(#{email}, #{passwordHash}, #{status})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    void insert(User user);
}
```

## 4. 文档规范

### 4.1 必须文档
- **SDD 文档**: 功能设计规范
- **API 文档**: 接口说明
- **架构文档**: 技术决策和架构设计
- **部署文档**: 部署和运维说明

### 4.2 AI协作文档规范

**SDD文档要求**:
- 明确指定设计模式
- 提供完整的输入输出定义
- 包含边界条件和错误处理
- 给出AI提示模板

**代码注释要求**:
```java
/**
 * 用户服务实现类
 *
 * @author 架构团队
 * @since 2024-01-01
 * @see UserService
 */
@Service
@Slf4j
public class UserServiceImpl implements UserService {

    /**
     * 创建用户
     *
     * 使用工厂模式创建用户实体，使用策略模式选择用户类型
     *
     * @param request 创建用户请求
     * @return 创建的用户
     * @throws BusinessException 业务异常
     */
    @Override
    @Transactional
    public User createUser(CreateUserRequest request) {
        // 具体实现
    }
}
```

## 5. 质量门禁

### 5.1 代码质量
- 测试覆盖率: ≥ 80%
- Code Review: 必须通过
- 静态检查: 无严重问题
- 安全扫描: 无高危漏洞

### 5.2 AI生成代码质量
- **正确性**: 符合SDD规范要求
- **规范性**: 遵循@rules/编码规范
- **完整性**: 包含必要的注释和文档
- **可测试性**: 代码结构清晰，易于测试

### 5.3 禁止事项
- ❌ 直接提交到主分支
- ❌ 提交没有测试的代码
- ❌ 提交没有文档的功能
- ❌ 忽略 Code Review 意见
- ❌ 使用AI生成代码而不验证

## 6. 协作规范

### 6.1 沟通原则
- 异步优先: 邮件、文档 > 会议
- 文档说话: 重要的决策必须文档化
- 及时反馈: 24 小时内回复讨论

### 6.2 Code Review 规范
- 友善评论: 对事不对人
- 具体建议: 给出具体的改进建议
- 解释原因: 说明为什么要这样改
- 及时评审: 收到 PR 后 24 小时内评审
- AI代码审查: 特别关注设计模式实现和规范符合性

### 6.3 AI协作规范

**提示编写规范**:
```
角色：Spring Boot专家
任务：根据SDD规范生成代码
要求：
1. 遵循@rules/项目结构规范
2. 使用指定的设计模式
3. 包含完整的错误处理
4. 生成对应的单元测试
5. 使用MyBatis注解模式

SDD规范：
[粘贴SDD内容]
```

**代码验证流程**:
1. 检查代码是否符合SDD规范
2. 验证设计模式实现是否正确
3. 确认是否遵循编码规范
4. 运行测试确保功能正确
5. 审查代码质量和可维护性

## 7. 技术债务管理

### 7.1 识别和记录
- 在代码中添加 `TODO` 注释
- 在 Jira 中创建技术债务任务
- 定期审查技术债务清单

### 7.2 偿还计划
- 每个 Sprint 预留 20% 时间
- 技术债务专项 Sprint
- 重构与功能开发并行

### 7.3 AI辅助重构

**重构提示模板**:
```
角色：代码重构专家
任务：重构以下代码，解决技术债务
要求：
1. 应用指定的设计模式
2. 提高代码可读性和可维护性
3. 保持功能不变
4. 生成重构后的完整代码

需要重构的代码：
[粘贴代码]

重构目标：
[说明重构要求]
```

## 8. 持续学习

### 8.1 学习计划
- 每周技术分享会
- 每月读书学习会
- 季度技术大会

### 8.2 AI工具学习
- 学习新的AI编码工具
- 分享AI协作最佳实践
- 探索AI在软件开发中的应用

### 8.3 知识沉淀
- 将学习成果写入文档
- 分享最佳实践
- 建立案例库

## 9. 度量与改进

### 9.1 关键指标
- 代码质量: 测试覆盖率、缺陷密度
- 开发效率: 交付速度、返工率、AI生成代码采纳率
- 团队满意度: 代码审查满意度、技术债务感知

### 9.2 AI协作指标
- **AI代码生成成功率**: 生成的代码无需大幅修改的比例
- **AI辅助开发效率提升**: 相比传统开发的时间节省
- **AI生成代码质量**: 缺陷率、维护成本

### 9.3 定期回顾
- 每周团队回顾
- 每月流程审视
- 季度架构审查

## 10. 附录

### 10.1 快速参考卡

#### Spring Boot 项目创建
```bash
# 使用 Spring Initializr
spring init --dependencies=web,mybatis,security,myssql myapp

# 或者使用 curl
curl https://start.spring.io/starter.zip \
  -d dependencies=web,mybatis,security,mysql \
  -d packageName=com.example.myapp \
  -o myapp.zip
```

#### 常用AI提示模板

**生成Service层代码**:
```
角色：Spring Boot专家
任务：根据以下SDD规范生成Service层代码
要求：
1. 遵循@rules/服务层规范
2. 使用@Transactional管理事务
3. 使用@Slf4j记录日志
4. 包含参数校验和业务逻辑
5. 返回统一响应模型

SDD规范：
[粘贴SDD内容]
```

**生成Controller层代码**:
```
角色：Spring Boot专家
任务：根据以下SDD规范生成Controller层代码
要求：
1. 遵循@rules/控制器规范
2. 使用@RestController和@RequestMapping
3. 使用@Valid进行参数校验
4. 返回CommonResponse包装对象
5. 使用@Tag生成API文档

SDD规范：
[粘贴SDD内容]
```

### 10.2 故障排查指南

#### AI生成代码常见问题
1. **不符合规范**: 检查提示是否包含@rules/规范要求
2. **缺少注解**: 明确指定需要使用的Spring注解
3. **包结构错误**: 在提示中指定正确的包路径
4. **测试不完整**: 要求生成完整的测试用例

#### 规范执行问题
1. **项目结构不符**: 使用脚手架工具强制生成
2. **命名不规范**: 配置IDE代码模板
3. **缺少文档**: 建立文档审查流程
4. **测试覆盖不足**: 设置质量门禁

### 10.3 相关文档

- [架构设计原则](../../02-架构设计/02.1-架构文档/architecture-design-principles.md)
- [技术栈规范](../../02-架构设计/02.4-技术选型/technology-stack-specification.md)
- [SDD规范模板](../../05-需求与设计/05.2-SDD规范/SDD-specification-template.md)
- [TDD实践指南](../../03-开发规范/TDD实践指南.md)

---

## 版本历史

| 版本 | 日期 | 更新内容 | 更新人 |
|------|------|----------|--------|
| 2.0 | 2024-11-30 | 新增AI协作规范和@rules/目录规范集成 | 架构团队 |
| 1.0 | 2024-01-01 | 初始版本创建 | 架构团队 |

**维护者**: 架构团队
**审核周期**: 每季度
**状态**: 持续更新中

---

> **提示**: 本文档基于 @rules/ 目录规范制定，所有开发活动必须遵循相关强制要求。完整规范请参考项目根目录下的 @rules/ 目录。`