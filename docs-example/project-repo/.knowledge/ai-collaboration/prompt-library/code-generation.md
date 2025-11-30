# 代码生成 Prompt 模板库

**用途**: 标准化的Prompt模板，用于AI代码生成

---

## 1. Service 层生成

```markdown
## 任务
根据以下规范生成Service层代码

## 上下文
- 技术栈: Java 17 + Spring Boot 3.2
- 项目: ECP电商平台
- 编码规范: 参见 coding-conventions.md

## 功能需求
[描述功能需求]

## 数据结构
```java
// Entity
@Entity
public class [Entity] {
    // 字段定义
}

// Request DTO
@Data
public class Create[Entity]Request {
    // 字段定义
}

// Response DTO
@Data
public class [Entity]Response {
    // 字段定义
}
```

## 业务规则
1. [规则1]
2. [规则2]

## 输出要求
1. Service接口定义
2. Service实现类
3. 单元测试
4. 符合项目编码规范
5. 包含完整Javadoc注释
```

---

## 2. Controller 层生成

```markdown
## 任务
根据以下规范生成Controller层代码

## 上下文
- 技术栈: Java 17 + Spring Boot 3.2
- API版本: v1
- 基础路径: /api/v1

## API设计
| 方法 | 路径 | 描述 |
|------|------|------|
| POST | /[resource] | 创建资源 |
| GET | /[resource]/{id} | 获取资源 |
| PUT | /[resource]/{id} | 更新资源 |
| DELETE | /[resource]/{id} | 删除资源 |

## 请求/响应示例
```json
// POST /[resource]
Request: { }
Response: { }
```

## 输出要求
1. RESTful风格
2. 参数校验注解
3. Swagger注解
4. 统一异常处理
```

---

## 3. Repository 层生成

```markdown
## 任务
根据Entity定义生成Repository层代码

## Entity定义
```java
@Entity
@Table(name = "[table_name]")
public class [Entity] {
    @Id
    private String id;
    // 其他字段
}
```

## 查询需求
1. 根据ID查询
2. 根据[字段]查询
3. 分页查询列表
4. [自定义查询]

## 输出要求
1. Spring Data JPA Repository接口
2. 自定义查询方法
3. 使用@Query注解的复杂查询
```

---

## 4. 单元测试生成

```markdown
## 任务
为以下Service类生成单元测试

## 被测代码
```java
@Service
public class [Service] {
    // 方法定义
}
```

## 测试要求
1. 使用JUnit 5 + Mockito
2. 覆盖正常流程
3. 覆盖异常流程
4. 覆盖边界条件
5. 测试命名: should{Expected}When{Condition}

## 输出格式
```java
@ExtendWith(MockitoExtension.class)
class [Service]Test {
    @Mock
    private [Dependency] [dependency];

    @InjectMocks
    private [Service] [service];

    @Test
    void should[Expected]When[Condition]() {
        // Given
        // When
        // Then
    }
}
```
```

---

## 5. DTO 转换生成

```markdown
## 任务
生成Entity和DTO之间的转换代码

## Entity
```java
public class [Entity] {
    // 字段
}
```

## DTO
```java
public class [Entity]Response {
    // 字段
}
```

## 输出要求
1. 使用MapStruct
2. 或使用静态工厂方法
3. 处理嵌套对象转换
4. 处理集合转换
```

---

## 6. 异常类生成

```markdown
## 任务
为模块生成异常类

## 模块信息
- 模块名: [模块名]
- 异常前缀: [PREFIX]

## 异常场景
| 场景 | 错误码 | HTTP状态码 |
|------|--------|------------|
| [场景1] | [CODE1] | [STATUS1] |
| [场景2] | [CODE2] | [STATUS2] |

## 输出要求
1. 继承BusinessException
2. 包含错误码和消息
3. 提供静态工厂方法
```

---

## 使用示例

### 生成用户服务

```markdown
## 任务
根据以下规范生成Service层代码

## 上下文
- 技术栈: Java 17 + Spring Boot 3.2
- 项目: ECP电商平台

## 功能需求
用户注册功能，包括：
1. 验证邮箱格式
2. 检查邮箱是否已存在
3. 密码加密存储
4. 发送激活邮件

## 数据结构
```java
@Entity
public class User {
    @Id
    private String id;
    private String email;
    private String password;
    private String name;
    private UserStatus status;
    private LocalDateTime createdAt;
}

@Data
public class CreateUserRequest {
    @NotBlank @Email
    private String email;
    @NotBlank @Size(min = 12)
    private String password;
    @NotBlank
    private String name;
}
```

## 业务规则
1. 邮箱必须唯一
2. 密码使用BCrypt加密
3. 新用户状态为PENDING
4. 发送激活邮件

## 输出要求
1. UserService接口
2. UserServiceImpl实现
3. 单元测试
```

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| 1.0 | 2025-11-30 | 初始版本 | @技术负责人 |
