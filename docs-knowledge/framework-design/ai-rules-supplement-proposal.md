# AI Rules 补充建议文档

> 本文档基于 `rules/` 目录（Cursor IDE 代码生成规则）与 `ai-rules/` 目录（企业级开发规范）的对比分析，提出需要补充到 ai-rules 的内容建议。

## 文档概述

| 项目             | 说明                        |
| ---------------- | --------------------------- |
| 分析日期         | 2025-12-12                  |
| rules/ 文件数    | 38个 .mdc 文件（5个子目录） |
| ai-rules/ 文件数 | 13个 .md 文件               |
| 补充建议数量     | 15项                        |

---

## 第一部分：高优先级补充建议

### 1.1 统一请求/响应结构模板

**建议补充到**: `05-api-design.md`

**当前状态**: ai-rules 提到"统一响应格式"但未给出具体实现

**补充内容**:

#### 1.1.1 通用请求基类 CommonRequest

```java
package com.example.vo.request;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

/**
 * 通用请求基类
 * 所有请求对象必须继承此类
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Accessors(chain = true)
@Schema(description = "通用请求基类")
public class CommonRequest {

    @Schema(description = "请求追踪ID（可选）",
            example = "createUser_20250127150000_123456")
    private String traceId;
}
```

#### 1.1.2 通用分页请求基类 CommonPageRequest

```java
package com.example.vo.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

/**
 * 通用分页请求基类
 * 所有分页查询请求必须继承此类
 */
@Data
@NoArgsConstructor
@EqualsAndHashCode(callSuper = true)
@Accessors(chain = true)
@Schema(description = "通用分页请求基类")
public abstract class CommonPageRequest extends CommonRequest {

    @Schema(description = "页码", example = "1", minimum = "1")
    @NotNull(message = "页码不能为空")
    @Min(value = 1, message = "页码最小为1")
    private Integer pageNumber = 1;

    @Schema(description = "每页数量", example = "10", minimum = "1", maximum = "100")
    @NotNull(message = "每页数量不能为空")
    @Min(value = 1, message = "每页数量最小为1")
    @Max(value = 100, message = "每页数量不能超过100")
    private Integer pageSize = 10;

    @Schema(description = "排序字段", example = "createTime")
    private String sortBy;

    @Schema(description = "排序方向", example = "desc", allowableValues = {"asc", "desc"})
    private String sortDirection = "desc";
}
```

#### 1.1.3 通用响应基类 CommonResponse

```java
package com.example.vo.response;

import com.example.enums.ErrorCodeEnum;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

/**
 * 通用响应基类
 * 所有API必须返回此类型
 */
@Data
@NoArgsConstructor
@Accessors(chain = true)
@Schema(description = "通用响应基类")
public class CommonResponse<T> {

    @Schema(description = "响应状态码", example = "0")
    private String code;

    @Schema(description = "响应消息", example = "success")
    private String message;

    @Schema(description = "响应数据")
    private T data;

    public boolean isSuccess() {
        return "0".equals(code);
    }

    public static <T> CommonResponse<T> success() {
        return new CommonResponse<T>().setCode("0").setMessage("success");
    }

    public static <T> CommonResponse<T> success(T data) {
        return new CommonResponse<T>().setCode("0").setMessage("success").setData(data);
    }

    public static <T> CommonResponse<T> error(ErrorCodeEnum errorCode) {
        return new CommonResponse<T>().setCode(errorCode.getCode()).setMessage(errorCode.getMessage());
    }

    public static <T> CommonResponse<T> error(String code, String message) {
        return new CommonResponse<T>().setCode(code).setMessage(message);
    }
}
```

#### 1.1.4 分页数据封装类 PageData

```java
package com.example.vo.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 分页数据封装类
 * 作为 CommonResponse<PageData<T>> 的 data 字段类型
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Schema(description = "分页数据封装类")
public class PageData<T> {

    @Schema(description = "总条数", example = "100")
    private Long total;

    @Schema(description = "当前页码", example = "1")
    private Integer pageNumber;

    @Schema(description = "每页数量", example = "10")
    private Integer pageSize;

    @Schema(description = "数据列表")
    private List<T> list;

    /**
     * 计算总页数
     */
    public Integer getTotalPages() {
        if (total == null || pageSize == null || pageSize == 0) {
            return 0;
        }
        return (int) Math.ceil((double) total / pageSize);
    }
}
```

**评估要点**:

- [ ] 是否采纳统一请求/响应结构
- [ ] traceId 字段是否必要
- [ ] 分页参数默认值是否合适（pageNumber=1, pageSize=10, max=100）
- [ ] 是否需要添加更多公共字段（如 timestamp、version）

---

### 1.2 错误码格式规范

**建议补充到**: `05-api-design.md`

**当前状态**: ai-rules 未定义错误码格式标准

**补充内容**:

#### 1.2.1 错误码格式定义

| 位置 | 长度 | 含义          | 示例     |
| ---- | ---- | ------------- | -------- |
| 1-4  | 4位  | 系统/模块代码 | 1001     |
| 5    | 1位  | 错误类型      | B/C/T    |
| 6-13 | 8位  | 错误序号      | 00000001 |

**错误类型说明**:

- **B** (Business): 业务错误，如用户名已存在、余额不足
- **C** (Client): 客户端错误，如参数校验失败、未认证
- **T** (Technical): 技术错误，如数据库异常、服务超时

#### 1.2.2 错误码枚举模板

```java
package com.example.enums;

import lombok.Getter;

/**
 * 错误码枚举
 *
 * 格式：[系统代码4位][类型1位][序号8位]
 * - B: 业务错误 (Business)
 * - C: 客户端错误 (Client)
 * - T: 技术错误 (Technical)
 */
@Getter
public enum ErrorCodeEnum {

    // ==================== 成功码 ====================
    SUCCESS("0", "success"),

    // ==================== 业务错误码 (1001B00000001-1001B00000999) ====================
    USERNAME_EXISTS("1001B00000001", "用户名已存在"),
    USER_NOT_FOUND("1001B00000002", "用户不存在"),
    PASSWORD_INCORRECT("1001B00000003", "密码错误"),
    ACCOUNT_DISABLED("1001B00000004", "账户已禁用"),
    INSUFFICIENT_BALANCE("1001B00000005", "余额不足"),

    // ==================== 客户端错误码 (1001C00000001-1001C00000999) ====================
    VALIDATION_ERROR("1001C00000001", "参数校验失败"),
    UNAUTHORIZED("1001C00000002", "未认证"),
    FORBIDDEN("1001C00000003", "权限不足"),
    RESOURCE_NOT_FOUND("1001C00000004", "资源不存在"),
    METHOD_NOT_ALLOWED("1001C00000005", "请求方法不允许"),

    // ==================== 技术错误码 (1001T00000001-1001T00000999) ====================
    INTERNAL_ERROR("1001T00000001", "系统内部错误"),
    DATABASE_ERROR("1001T00000002", "数据库操作失败"),
    CACHE_ERROR("1001T00000003", "缓存操作失败"),
    REMOTE_SERVICE_ERROR("1001T00000004", "远程服务调用失败"),
    TIMEOUT_ERROR("1001T00000005", "请求超时");

    private final String code;
    private final String message;

    ErrorCodeEnum(String code, String message) {
        this.code = code;
        this.message = message;
    }

    /**
     * 根据错误码查找枚举值
     */
    public static ErrorCodeEnum fromCode(String code) {
        for (ErrorCodeEnum errorCode : values()) {
            if (errorCode.code.equals(code)) {
                return errorCode;
            }
        }
        throw new IllegalArgumentException("Invalid error code: " + code);
    }
}
```

#### 1.2.3 多系统错误码分配

| 系统代码 | 系统名称 | 错误码范围                  |
| -------- | -------- | --------------------------- |
| 1001     | 用户中心 | 1001B/C/T 00000001-00000999 |
| 1002     | 订单系统 | 1002B/C/T 00000001-00000999 |
| 1003     | 支付系统 | 1003B/C/T 00000001-00000999 |
| 1004     | 商品系统 | 1004B/C/T 00000001-00000999 |

**评估要点**:

- [ ] 是否采纳13位错误码格式
- [ ] 系统代码分配规则是否合适
- [ ] 是否需要支持国际化错误消息
- [ ] 是否需要错误码文档自动生成

---

### 1.3 测试幂等性详细规范

**建议补充到**: `09-testing.md`

**当前状态**: ai-rules 仅提到覆盖率≥80%，未涉及测试幂等性

**补充内容**:

#### 1.3.1 测试幂等性核心原则

| 原则         | 说明                                 | 实现方式                             |
| ------------ | ------------------------------------ | ------------------------------------ |
| 测试独立性   | 每个测试方法独立运行，不依赖其他测试 | 每个测试有独立的数据准备和清理       |
| 测试可重复性 | 同一个测试可多次运行，结果一致       | 避免使用固定ID，使用动态生成的唯一值 |
| 测试隔离性   | 测试之间不共享状态，不相互影响       | 使用@BeforeEach/@AfterEach管理数据   |

#### 1.3.2 数据管理规范

**🔴 强制要求（MUST）**:

- 必须使用 `@BeforeEach` 准备测试数据
- 必须使用 `@AfterEach` 清理测试数据
- 必须确保测试方法可重复运行
- 必须确保测试方法相互独立
- 必须清理所有 Mock 对象状态

**🔴 禁止要求（MUST NOT）**:

- 禁止使用固定ID（应使用数据库自增或UUID）
- 禁止使用固定用户名/手机号等唯一字段
- 禁止依赖测试执行顺序
- 禁止共享可变的类级别变量

#### 1.3.3 正确示例

```java
@SpringBootTest
class UserServiceTest {

    @Autowired
    private UserService userService;

    @Autowired
    private UserMapper userMapper;

    private UserEntity testUser;

    @BeforeEach
    void setUp() {
        // 1. 清理可能存在的旧数据
        cleanupTestData();

        // 2. 准备测试数据（使用时间戳保证唯一性）
        testUser = new UserEntity();
        testUser.setUsername("testuser_" + System.currentTimeMillis());
        testUser.setEmail("test_" + System.currentTimeMillis() + "@example.com");
        testUser.setPasswordHash("hashed_password");
        testUser.setIsEnabled(true);

        // 3. 插入数据库
        userMapper.insert(testUser);
    }

    @AfterEach
    void tearDown() {
        // 1. 删除测试数据
        if (testUser != null && testUser.getId() != null) {
            userMapper.deleteById(testUser.getId());
        }

        // 2. 重置Mock对象（如有）
        // Mockito.reset(mockService);
    }

    @Test
    void testGetUserById_Success() {
        // Arrange - 数据已在@BeforeEach准备

        // Act
        CommonResponse<UserResponse> response = userService.getUserById(testUser.getId());

        // Assert
        assertThat(response.isSuccess()).isTrue();
        assertThat(response.getData().getUsername()).isEqualTo(testUser.getUsername());
    }

    @Test
    void testGetUserById_NotFound() {
        // Arrange - 使用不存在的ID
        Long nonExistentId = 999999999L;

        // Act & Assert
        assertThatThrownBy(() -> userService.getUserById(nonExistentId))
                .isInstanceOf(BusinessException.class)
                .hasFieldOrPropertyWithValue("code", ErrorCodeEnum.USER_NOT_FOUND.getCode());
    }

    private void cleanupTestData() {
        // 清理以 testuser_ 开头的测试用户
        // 实际项目中可能需要更精细的清理策略
    }
}
```

#### 1.3.4 错误示例

```java
// ❌ 错误示例1：使用固定ID
@Test
void testCreateUser() {
    UserEntity user = new UserEntity();
    user.setId(1L);  // 固定ID，第二次运行会冲突
    user.setUsername("john");  // 固定用户名，重复运行会失败
    userMapper.insert(user);
    // ...
}

// ❌ 错误示例2：没有清理数据
@Test
void testCreateUser() {
    UserEntity user = new UserEntity();
    user.setUsername("testuser");
    userMapper.insert(user);
    // 没有清理，下次运行会因为用户名重复而失败
}

// ❌ 错误示例3：依赖其他测试
@Test
void testUpdateUser() {
    // 假设 testCreateUser 已经创建了用户
    UserEntity user = userMapper.findByUsername("john");  // 依赖其他测试的数据
    // ...
}
```

#### 1.3.5 集成测试事务回滚

```java
@SpringBootTest
@Transactional  // 测试结束自动回滚，无需手动清理
class UserServiceIntegrationTest {

    @Autowired
    private UserService userService;

    @Test
    void testCreateUser_WithTransaction() {
        // 测试代码
        // 数据库变更会自动回滚
    }
}
```

**评估要点**:

- [ ] 是否将测试幂等性作为强制要求
- [ ] 是否需要提供测试数据工厂模式的示例
- [ ] 是否需要规范测试数据的命名前缀
- [ ] 是否需要添加测试数据清理的定时任务

---

### 1.4 HTTP方法限制规范

**建议补充到**: `05-api-design.md`

**当前状态**: ai-rules 遵循标准 RESTful（GET/POST/PUT/DELETE），未作限制

**补充内容**:

#### 1.4.1 简化HTTP方法策略

| 操作类型              | 推荐方法 | 说明                           |
| --------------------- | -------- | ------------------------------ |
| 查询单条数据          | GET      | `/api/v1/users/{id}`         |
| 查询列表（简单）      | GET      | `/api/v1/users?role=admin`   |
| 查询列表（复杂/分页） | POST     | `/api/v1/users/search`       |
| 创建资源              | POST     | `/api/v1/users/create`       |
| 更新资源              | POST     | `/api/v1/users/update`       |
| 删除资源              | POST     | `/api/v1/users/delete/{id}`  |
| 批量操作              | POST     | `/api/v1/users/batch-delete` |

#### 1.4.2 采纳理由

| 优点           | 说明                             |
| -------------- | -------------------------------- |
| 简化防火墙配置 | 部分企业防火墙默认阻止PUT/DELETE |
| 统一请求体格式 | POST 统一使用 JSON Body          |
| 便于日志记录   | POST 请求参数在 Body 中，更安全  |
| 降低 CSRF 风险 | PUT/DELETE 的 CSRF 防护更复杂    |

#### 1.4.3 不采纳理由

| 缺点              | 说明                             |
| ----------------- | -------------------------------- |
| 违反 RESTful 规范 | 标准 REST 使用完整 HTTP 动词语义 |
| 缓存不友好        | POST 请求默认不可缓存            |
| 幂等性语义丢失    | PUT 天然幂等，POST 非幂等        |
| 工具兼容性        | 部分 API 测试工具依赖 HTTP 动词  |

**评估要点**:

- [ ] 是否采纳仅 GET/POST 的简化策略
- [ ] 如采纳，是否作为强制要求还是推荐要求
- [ ] 是否需要区分内部API和对外API的规范
- [ ] 是否需要提供两套方案（严格RESTful / 简化版）

---

### 1.5 链式调用禁止规则

**建议补充到**: `02-coding-basics.md`

**当前状态**: ai-rules 未提及继承关系中的链式调用问题

**补充内容**:

#### 1.5.1 问题描述

当子类继承父类且都使用 `@Accessors(chain = true)` 时，链式调用会导致返回类型为父类，后续调用子类特有方法会编译错误。

#### 1.5.2 错误示例

```java
// 父类
@Data
@Accessors(chain = true)
public class CommonPageRequest {
    private Integer pageNumber;
    private Integer pageSize;
}

// 子类
@Data
@EqualsAndHashCode(callSuper = true)
@Accessors(chain = true)
public class SearchUserRequest extends CommonPageRequest {
    private String keyword;
    private String role;
}

// ❌ 错误使用：链式调用会导致编译错误
SearchUserRequest request = new SearchUserRequest()
    .setPageNumber(1)    // 返回 CommonPageRequest，不是 SearchUserRequest
    .setKeyword("test"); // 编译错误：CommonPageRequest 没有 setKeyword 方法
```

#### 1.5.3 正确示例

```java
// ✅ 正确做法：分步设置属性
SearchUserRequest request = new SearchUserRequest();
request.setPageNumber(1);
request.setPageSize(10);
request.setKeyword("test");
request.setRole("admin");
```

#### 1.5.4 规范要求

**🔴 禁止要求（MUST NOT）**:

- 禁止在继承关系中使用链式调用
- 禁止假设链式调用返回当前类型

**🟢 推荐做法（SHOULD）**:

- 使用分步设置属性的方式
- 使用 Builder 模式替代链式 Setter
- 在测试代码中特别注意此问题

**评估要点**:

- [ ] 是否将此作为编码规范的一部分
- [ ] 是否建议不使用 `@Accessors(chain = true)`
- [ ] 是否提供 Builder 模式的替代方案

---

## 第二部分：中优先级补充建议

### 2.1 代码生成工作流，这一章的内容暂不执行

**建议补充到**: `01-overview.md` 或新建 `14-ai-code-generation.md`

**补充内容**:

#### 2.1.1 AI代码生成6阶段流程

```
阶段1: 准备阶段
├── 检查 doc/ 目录是否存在设计文档
├── 评估设计文档完整性（0-100分）
└── 如果 <60 分，提出补充建议

阶段2: 规则加载阶段
├── 加载项目级规则
├── 加载框架级规则
└── 按优先级合并规则

阶段3: 代码生成阶段
├── 按层级顺序生成：Entity → Mapper → Service → Controller
├── 同时生成对应的测试类
└── 生成配置文件

阶段4: 验证阶段
├── 编译检查
├── 规范检查（命名、注释、结构）
└── 测试执行

阶段5: 修复阶段
├── 自动修复编译错误
├── 自动修复规范问题
└── 记录无法自动修复的问题

阶段6: 提交阶段
├── 生成变更清单
├── 用户确认
└── 提交代码
```

#### 2.1.2 设计文档完整性评分标准

| 评分项        | 权重 | 说明                   |
| ------------- | ---- | ---------------------- |
| API定义完整性 | 30%  | 路径、方法、参数、响应 |
| 数据模型定义  | 25%  | 表结构、字段、关系     |
| 业务规则说明  | 20%  | 验证规则、业务约束     |
| 错误码定义    | 15%  | 业务错误、系统错误     |
| 非功能需求    | 10%  | 性能、安全、限制       |

**评估要点**:

- [ ] 是否需要规范AI代码生成的流程
- [ ] 是否需要定义设计文档模板
- [ ] 是否需要建立代码生成的质量门禁

---

### 2.2 Swagger UI 路径放行清单

**建议补充到**: `05-api-design.md` 或 `08-security.md`

**补充内容**:

#### 2.2.1 必须放行的Swagger路径

```java
// Spring Security 配置中必须放行以下所有路径
.requestMatchers(
    "/swagger-ui.html",      // Swagger UI 入口页面
    "/swagger-ui/**",        // Swagger UI 静态资源（CSS/JS）
    "/v3/api-docs/**",       // OpenAPI 3 规范 JSON
    "/swagger-resources/**", // Swagger 资源（兼容性）
    "/webjars/**"            // WebJars 依赖资源
).permitAll()
```

#### 2.2.2 常见错误

| 错误配置                  | 后果                 |
| ------------------------- | -------------------- |
| 只放行 `/swagger-ui/**` | 无法访问入口页面     |
| 遗漏 `/v3/api-docs/**`  | API 文档数据无法加载 |
| 遗漏 `/webjars/**`      | 第三方库无法加载     |

#### 2.2.3 环境配置建议

| 环境    | Swagger 状态 | 配置                |
| ------- | ------------ | ------------------- |
| dev     | 开启         | 放行所有路径        |
| test    | 开启         | 放行所有路径        |
| staging | 可选         | 内网访问或关闭      |
| prod    | 关闭         | 不放行，禁用Swagger |

**评估要点**:

- [ ] 是否需要规范 Swagger 的环境配置策略
- [ ] 是否需要提供完整的 SecurityConfig 模板
- [ ] 是否需要支持 Swagger 的认证访问

---

### 2.3 定时任务详细规范

**建议补充到**: `07-concurrency.md`

**补充内容**:

#### 2.3.1 定时任务类规范

**🔴 强制要求（MUST）**:

- 必须使用 `@Component` 注册为 Spring 组件
- 必须使用 `@Slf4j` 进行日志记录
- 类名必须以 `Task` 结尾
- 必须在方法内部 try-catch，禁止异常传播导致任务中断
- 必须记录任务开始、结束和耗时

**🔴 禁止要求（MUST NOT）**:

- 禁止长时间阻塞操作（应异步处理）
- 禁止任务中断（必须完整处理异常）
- 禁止非幂等操作（任务可能重复执行）

#### 2.3.2 定时任务模板

```java
@Component
@Slf4j
public class DataSyncTask {

    @Autowired
    private DataSyncService dataSyncService;

    /**
     * 每5分钟执行一次数据同步
     */
    @Scheduled(fixedDelay = 5 * 60 * 1000, initialDelay = 60 * 1000)
    public void syncData() {
        long startTime = System.currentTimeMillis();

        try {
            log.info("========== 数据同步任务开始 ==========");

            int syncCount = dataSyncService.sync();

            long timeCost = System.currentTimeMillis() - startTime;
            log.info("数据同步完成: 同步{}条, 耗时{}ms", syncCount, timeCost);

        } catch (Exception e) {
            log.error("数据同步失败", e);
            // 不抛出异常，避免任务中断
        }
    }

    /**
     * 每天凌晨2点执行清理
     * 使用配置文件控制 cron 表达式
     */
    @Scheduled(cron = "${task.cleanup.cron:0 0 2 * * ?}")
    public void cleanup() {
        // 同样的异常处理模式
    }
}
```

**评估要点**:

- [ ] 是否需要规范定时任务的监控方式
- [ ] 是否需要支持分布式定时任务（如 XXL-JOB）
- [ ] 是否需要规范任务的超时处理

---

### 2.4 Gradle/Java 版本映射

**建议补充到**: `10-deployment.md`

**补充内容**:

#### 2.4.1 版本兼容性矩阵

| Java 版本 | Gradle 版本范围 | 推荐版本 | Spring Boot |
| --------- | --------------- | -------- | ----------- |
| Java 8    | 6.9 - 7.6       | 7.6.4    | 2.x         |
| Java 11   | 7.0 - 8.5       | 8.5      | 2.x - 3.x   |
| Java 17   | 7.3 - 8.10      | 8.10     | 3.x         |
| Java 21   | 8.4 - 8.10      | 8.10     | 3.2+        |

#### 2.4.2 推荐技术栈组合

| 场景     | Java | Gradle | Spring Boot |
| -------- | ---- | ------ | ----------- |
| 新项目   | 21   | 8.10+  | 3.2+        |
| 维护项目 | 17   | 8.5+   | 3.0+        |
| 遗留系统 | 11   | 7.6+   | 2.7.x       |

**评估要点**:

- [ ] 是否需要强制指定版本组合
- [ ] 是否需要提供版本升级指南
- [ ] 是否需要规范 Gradle Wrapper 的使用

---

## 第三部分：低优先级补充建议

### 3.1 各层代码模板

**建议**: 作为附录或单独文档，提供以下代码模板：

- Entity 实体类模板
- Mapper 接口模板（注解模式）
- Service 接口模板
- ServiceImpl 实现类模板
- Controller 控制器模板
- Request/Response DTO 模板

### 3.2 自定义验证器模板

**建议**: 补充到 `02-coding-basics.md`，提供自定义 Bean Validation 注解和验证器的模板。

### 3.3 日志切面模板

**建议**: 补充到 `02-coding-basics.md` 或 `07-concurrency.md`，提供 AOP 日志切面的标准实现。

---

## 第四部分：冲突解决建议

### 4.1 依赖注入方式冲突

**冲突点**:

- `rules/`: 强制使用 `@Autowired` 字段注入
- `ai-rules/`: 推荐构造器注入

**解决建议**:

在 `02-coding-basics.md` 中明确：

```markdown
## 依赖注入规范

### 推荐方式（人工编码）

🟡 **推荐使用构造器注入**:
- 更好的测试性（便于 Mock）
- 强制依赖的不可变性
- 便于发现过多依赖的设计问题

```java
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
}
```

### 可接受方式（AI生成代码）

🟢 **字段注入在以下情况可接受**:

- AI 自动生成的代码
- 简单的 CRUD 服务
- 原型/POC 项目

```java
@Service
public class UserServiceImpl implements UserService {
    @Autowired
    private UserMapper userMapper;
}
```

### 禁止方式

🔴 **禁止 Setter 注入**:

- 破坏依赖的不可变性
- 容易引入空指针

```

**评估要点**:
- [ ] 是否同意上述分层建议
- [ ] 是否需要强制统一一种方式
- [ ] 是否需要配置代码检查工具（如 ArchUnit）

---

## 评估清单

### 高优先级（建议采纳）

| 序号 | 补充项 | 采纳 | 修改意见 |
|-----|--------|-----|---------|
| 1.1 | 统一请求/响应结构模板 | ☐ | |
| 1.2 | 错误码格式规范 | ☐ | |
| 1.3 | 测试幂等性详细规范 | ☐ | |
| 1.4 | HTTP方法限制规范 | ☐ | |
| 1.5 | 链式调用禁止规则 | ☐ | |

### 中优先级（建议评估）

| 序号 | 补充项 | 采纳 | 修改意见 |
|-----|--------|-----|---------|
| 2.1 | 代码生成工作流 | ☐ | |
| 2.2 | Swagger UI路径放行清单 | ☐ | |
| 2.3 | 定时任务详细规范 | ☐ | |
| 2.4 | Gradle/Java版本映射 | ☐ | |

### 低优先级（可选）

| 序号 | 补充项 | 采纳 | 修改意见 |
|-----|--------|-----|---------|
| 3.1 | 各层代码模板 | ☐ | |
| 3.2 | 自定义验证器模板 | ☐ | |
| 3.3 | 日志切面模板 | ☐ | |

### 冲突解决

| 序号 | 冲突项 | 解决方案 | 修改意见 |
|-----|--------|---------|---------|
| 4.1 | 依赖注入方式 | ☐ 分层建议 / ☐ 统一构造器 / ☐ 统一字段 | |

---

## 附录：文件对应关系

| rules/ 文件 | 建议补充到 ai-rules 文件 |
|------------|------------------------|
| 04-conventions/common-*.mdc | 05-api-design.md |
| 04-conventions/error-code-enum.mdc | 05-api-design.md |
| 03-coding/testing.mdc | 09-testing.md |
| 02-design/api.mdc | 05-api-design.md |
| 04-conventions/controller.mdc | 05-api-design.md |
| 00-interaction/*.mdc | 01-overview.md (新增章节) |
| 04-conventions/security-config.mdc | 08-security.md |
| 04-conventions/task.mdc | 07-concurrency.md |
| 01-structure/tech-stack.mdc | 10-deployment.md |
```
