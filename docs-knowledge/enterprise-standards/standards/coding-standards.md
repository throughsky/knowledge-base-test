# 编码规范

**版本**: 1.1.0
**最后更新**: 2025-12-01

---

## 通用规范

### 命名约定

| 类型 | 规范 | 示例 |
|------|------|------|
| 类名 | UpperCamelCase + 后缀 | `UserService`, `OrderController` |
| 方法 | lowerCamelCase + 动词 | `createUser()`, `findById()` |
| 常量 | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT` |
| 包名 | 小写 + 层级 | `com.company.project.service` |
| 测试类 | `{ClassName}Test` | `UserServiceTest` |
| 请求对象 | `{Action}{Entity}Request` | `CreateUserRequest` |
| 响应对象 | `{Entity}Response` | `UserResponse` |
| 事件监听器 | `{Purpose}Listener` | `ApprovalNodeCompletedListener` |
| AOP 切面 | `{Purpose}Aspect` | `WebLogAspect` |
| 枚举类 | `{Name}Enum` | `ErrorCodeEnum`, `StatusEnum` |

### 代码组织 (强制)

```
src/
├── main/
│   ├── java/com/{company}/{project}/
│   │   ├── {AppName}Application.java
│   │   ├── config/           # 配置类
│   │   ├── controller/       # API层
│   │   ├── service/          # 业务层
│   │   │   └── impl/         # 实现类
│   │   ├── entity/           # 数据库实体
│   │   ├── mapper/           # MyBatis Mapper（非 repository）
│   │   ├── vo/               # 值对象
│   │   │   ├── request/      # 请求对象
│   │   │   └── response/     # 响应对象
│   │   ├── exception/        # 自定义异常
│   │   ├── util/             # 工具类
│   │   ├── constants/        # 常量
│   │   ├── enums/            # 枚举类
│   │   ├── validation/       # 自定义验证器
│   │   ├── aspect/           # AOP 切面（用户追踪、日志）
│   │   ├── listener/         # 事件监听器（工作流事件）
│   │   └── handler/          # 事件处理器（业务处理）
│   └── resources/
│       ├── application.yml
│       ├── application-dev.yml
│       ├── application-prod.yml
│       └── sql/
└── test/
    ├── java/com/{company}/{project}/
    │   ├── controller/       # Controller 测试
    │   ├── service/          # Service 测试
    │   ├── mapper/           # Mapper 测试
    │   ├── listener/         # 事件监听器测试
    │   └── aspect/           # AOP 切面测试
    └── resources/
        └── application-test.yml
```

**强制要求**：
- test 目录结构必须与 main 目录对应
- 必须创建 `application-test.yml` 配置文件
- 错误码必须使用枚举（`ErrorCodeEnum`），禁止常量类
- 枚举文件必须以 `Enum.java` 结尾
- 事件监听器必须放在 `listener/` 目录
- AOP 切面必须放在 `aspect/` 目录
- 数据访问层使用 `mapper/`（MyBatis），不使用 `repository/`

---

## 分层架构 (强制)

```
Controller → Service → Mapper
     ↓           ↓          ↓
   API层     业务逻辑    数据访问
```

**禁止跨层调用**：
- ❌ Controller 直接调用 Mapper
- ❌ Service 调用其他 Service 的私有方法
- ✅ Controller → Service → Mapper

---

## 测试规范 (TDD 强制)

### 测试覆盖要求

| 类型 | 覆盖率 | 说明 |
|------|--------|------|
| 核心业务 | ≥ 80% | Controller、Service、Mapper |
| 工具类 | ≥ 90% | util 包下所有类 |
| 异常场景 | 必须覆盖 | 每个公共方法的异常路径 |

### 测试模式

```java
@SpringBootTest
class UserServiceTest {

    @Autowired
    private UserService userService;

    @MockBean
    private UserMapper userMapper;

    @BeforeEach
    void setUp() {
        // Arrange: 准备测试数据
    }

    @AfterEach
    void tearDown() {
        // 清理测试数据（保证幂等性）
    }

    @Test
    void createUser_shouldSuccess_whenValidInput() {
        // Arrange
        CreateUserRequest request = CreateUserRequest.builder()
            .name("张三")
            .walletAddress("0x123...")
            .build();

        when(userMapper.insert(any())).thenReturn(1);

        // Act
        UserResponse response = userService.createUser(request);

        // Assert
        assertThat(response).isNotNull();
        assertThat(response.getName()).isEqualTo("张三");
        verify(userMapper, times(1)).insert(any());
    }

    @Test
    void createUser_shouldThrow_whenNameIsBlank() {
        // Arrange
        CreateUserRequest request = CreateUserRequest.builder()
            .name("")
            .build();

        // Act & Assert
        assertThatThrownBy(() -> userService.createUser(request))
            .isInstanceOf(BusinessException.class)
            .hasMessage("用户名不能为空");
    }
}
```

**禁止项**：
- ❌ `@Disabled` 跳过测试
- ❌ `// TODO: add test` 占位注释
- ❌ 注释掉的测试代码
- ❌ 没有断言的测试方法

---

## 异常处理

```java
// ✅ 业务异常使用自定义异常 + 枚举错误码
throw new BusinessException(ErrorCodeEnum.USER_NOT_FOUND);

// ✅ 必须记录日志并重新抛出
try {
    // ...
} catch (Exception e) {
    log.error("操作失败, userId={}", userId, e);
    throw new ServiceException(ErrorCodeEnum.SYSTEM_ERROR, e);
}

// ❌ 禁止空 catch 块
try {
    // ...
} catch (Exception e) {
    // 禁止！
}

// ❌ 禁止吞异常
try {
    // ...
} catch (Exception e) {
    return null;  // 禁止！
}
```

---

## 日志规范

```java
// ✅ 结构化日志
log.info("订单创建成功, orderId={}, userId={}, amount={}",
    orderId, userId, amount);

// ✅ 关键入口日志
log.info("开始处理用户注册, request={}", request);

// ✅ 异常日志（必须包含堆栈）
log.error("处理失败, orderId={}", orderId, e);

// ❌ 禁止输出敏感信息
log.info("用户登录, password={}", password);  // 禁止！
log.info("钱包私钥={}", privateKey);           // 禁止！
```

---

## 依赖注入

```java
// ✅ 使用 @Autowired 字段注入（项目约定）
@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private WalletService walletService;
}
```

---

## 事务管理

```java
// ✅ Service 层使用 @Transactional
@Service
public class OrderServiceImpl implements OrderService {

    @Transactional(rollbackFor = Exception.class)
    public void createOrder(CreateOrderRequest request) {
        // 多表操作
    }

    @Transactional(readOnly = true)
    public OrderResponse getOrder(Long id) {
        // 只读查询
    }
}
```

---

## 代码风格

| 项目 | 要求 |
|------|------|
| 缩进 | 4 空格（不使用 Tab） |
| 行长度 | 建议 ≤ 120 字符 |
| 花括号 | K&R 风格（左花括号不换行） |
| 导入 | 禁止通配符导入（`import xxx.*`） |
| 注释 | 说明"为什么"而非"是什么" |

---

## Web3/金融特殊规范

### 金额处理

```java
// ✅ 必须使用 BigDecimal
BigDecimal amount = new BigDecimal("100.50");

// ✅ 字符串构造（避免精度丢失）
BigDecimal price = new BigDecimal("0.1");

// ❌ 禁止浮点数
double amount = 100.50;  // 禁止！
float price = 0.1f;      // 禁止！
```

### 区块链地址验证

```java
// 自定义验证器
@Constraint(validatedBy = AccountAddressValidator.class)
@Target({ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
public @interface AccountAddress {
    String message() default "无效的区块链地址";
    // ...
}

public class AccountAddressValidator
    implements ConstraintValidator<AccountAddress, String> {

    @Override
    public boolean isValid(String address, ConstraintValidatorContext context) {
        // 严格验证区块链地址格式
        return address != null
            && address.startsWith("0x")
            && address.length() == 42;
    }
}
```

### 链上交易

```java
// ✅ 必须幂等
@Idempotent(key = "#txHash")
public void processTransaction(String txHash) { }

// ✅ 必须重试机制
@Retryable(maxAttempts = 3, backoff = @Backoff(delay = 1000))
public TransactionReceipt sendTransaction() { }
```

---

## 事件驱动编码规范

### 事件监听器

```java
// 命名规范：{Purpose}Listener
@Component
public class ApprovalNodeCompletedListener
    implements ExecutionListener {

    @Autowired
    private AuditMessageSender auditMessageSender;

    @Override
    public void notify(DelegateExecution execution) {
        // 幂等性检查
        String taskId = execution.getProcessInstanceId();
        if (isProcessed(taskId)) {
            return;
        }

        // 异步发送审计消息
        auditMessageSender.send(buildAuditMessage(execution));
    }
}
```

### AOP 切面

```java
// 命名规范：{Purpose}Aspect
@Aspect
@Component
public class WebLogAspect {

    @Around("@annotation(org.springframework.web.bind.annotation.RequestMapping)")
    public Object logAround(ProceedingJoinPoint joinPoint) throws Throwable {
        long start = System.currentTimeMillis();

        log.info("请求开始, method={}, args={}",
            joinPoint.getSignature().getName(),
            joinPoint.getArgs());

        Object result = joinPoint.proceed();

        log.info("请求结束, method={}, duration={}ms",
            joinPoint.getSignature().getName(),
            System.currentTimeMillis() - start);

        return result;
    }
}
```
