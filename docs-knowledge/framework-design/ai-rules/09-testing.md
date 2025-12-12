# 测试规范 - AI编码约束

> 适用于：单元测试、集成测试、接口测试、性能测试场景

## 一、测试分层规范 [MUST]

### 1.1 测试层级

| 层级 | 核心目标 | 覆盖范围 | 工具选型 |
|------|----------|----------|----------|
| 单元测试 | 验证单个类/方法逻辑 | Service核心逻辑≥80% | JUnit5+Mockito |
| 集成测试 | 验证依赖协作 | DB+Redis+跨服务 | JUnit5+Testcontainers |
| 契约测试 | 验证服务间接口契约 | 所有对外API | Spring Cloud Contract |
| 接口测试 | 验证HTTP接口 | 所有对外接口100% | RestAssured |
| 性能测试 | 验证高并发稳定性 | 核心接口 | JMeter/Gatling |

### 1.2 覆盖率要求

```yaml
coverage:
  service_layer: 80%   # Service层核心逻辑
  dao_layer: 50%       # Dao层
  controller_layer: 60%
  overall: 70%
```

## 二、单元测试规范 [MUST]

### 2.1 核心原则

```yaml
principles:
  - 隔离外部依赖（DB、Redis、HTTP）
  - 覆盖正常+异常+边界场景
  - 可重复执行
  - 命名规范：方法名_场景_预期结果
```

### 2.2 Mock规范

```java
@SpringBootTest
class OrderServiceTest {
    @Autowired
    private OrderService orderService;

    @MockBean
    private OrderMapper orderMapper;

    @MockBean
    private UserFeignApi userFeignApi;

    @MockBean
    private RedisTemplate<String, String> redisTemplate;

    // ✅ 正确：测试正常场景
    @Test
    void createOrder_ValidParams_ReturnOrderId() {
        // Arrange - 准备Mock数据
        when(userFeignApi.getUserById(1001L)).thenReturn(Result.success(mockUser));
        when(redisTemplate.opsForValue().get("stock:2001")).thenReturn("10");
        when(orderMapper.insert(any(Order.class))).thenReturn(1);

        // Act - 执行测试方法
        Long orderId = orderService.createOrder(validRequest);

        // Assert - 断言结果
        assertNotNull(orderId);
        verify(orderMapper, times(1)).insert(any(Order.class));
    }

    // ✅ 正确：测试异常场景
    @Test
    void createOrder_UserNotFound_ThrowServiceException() {
        when(userFeignApi.getUserById(1001L)).thenReturn(Result.success(null));

        ServiceException exception = assertThrows(ServiceException.class, () -> {
            orderService.createOrder(validRequest);
        });

        assertEquals("用户不存在", exception.getMessage());
        verifyNoInteractions(orderMapper);  // 验证Mapper未被调用
    }

    // ✅ 正确：测试边界场景
    @Test
    void createOrder_StockZero_ThrowServiceException() {
        when(userFeignApi.getUserById(1001L)).thenReturn(Result.success(mockUser));
        when(redisTemplate.opsForValue().get("stock:2001")).thenReturn("0");

        assertThrows(ServiceException.class, () -> {
            orderService.createOrder(validRequest);
        });
    }
}
```

### 2.3 禁止项

```yaml
prohibited:
  - 单元测试依赖真实DB/Redis
  - 测试用例之间有依赖
  - 只测试正常场景
  - 吞异常不断言
```

```java
// ❌ 错误：依赖真实数据库
@Test
void testCreateOrder() {
    Order order = orderMapper.selectById(1L);  // 依赖真实DB
    assertNotNull(order);
}

// ❌ 错误：只断言不抛异常
@Test
void testCreateOrder() {
    try {
        orderService.createOrder(null);
    } catch (Exception e) {
        // 吞异常，测试永远通过
    }
}
```

## 三、测试幂等性规范 [MUST]

### 3.1 核心原则

```yaml
idempotency_rules:
  - 每个测试用例必须独立执行
  - 测试执行顺序不影响结果
  - 重复执行测试必须得到相同结果
  - 禁止测试用例之间共享可变状态
```

### 3.2 数据管理策略

```java
@SpringBootTest
class OrderServiceTest {

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private DataSource dataSource;

    /**
     * ✅ 正确：每个测试前初始化数据
     * 使用@BeforeEach确保每个测试用例有干净的初始状态
     */
    @BeforeEach
    void setUp() {
        // 清理并初始化测试数据
        orderMapper.delete(new QueryWrapper<>());

        // 插入测试基础数据
        Order testOrder = new Order();
        testOrder.setUserId(1001L);
        testOrder.setStatus(OrderStatusEnum.CREATED.getCode());
        testOrder.setAmount(new BigDecimal("100.00"));
        orderMapper.insert(testOrder);
    }

    /**
     * ✅ 正确：每个测试后清理数据
     * 使用@AfterEach确保不影响其他测试
     */
    @AfterEach
    void tearDown() {
        // 清理测试产生的数据
        orderMapper.delete(new QueryWrapper<>());
    }

    @Test
    void createOrder_ValidParams_ReturnOrderId() {
        // 测试逻辑...
        // 使用动态生成的数据，而非固定ID
        Long orderId = orderService.createOrder(validRequest);
        assertNotNull(orderId);
    }
}
```

### 3.3 禁止项

```yaml
prohibited:
  - 使用固定ID作为测试数据（可能与其他测试冲突）
  - 依赖测试执行顺序
  - 在测试中修改共享静态变量
  - 不清理测试产生的数据
```

```java
// ❌ 错误：使用固定ID
@Test
void testGetOrder() {
    Long orderId = 1L;  // 固定ID，可能与其他测试冲突
    Order order = orderService.getById(orderId);
    assertNotNull(order);
}

// ❌ 错误：依赖其他测试创建的数据
@Test
@Order(2)  // 依赖@Order(1)创建的数据
void testUpdateOrder() {
    // 假设testCreateOrder已经创建了数据
    orderService.updateStatus(1L, OrderStatusEnum.PAID);
}

// ✅ 正确：每个测试独立准备数据
@Test
void testGetOrder() {
    // 测试内部创建数据
    Order order = createTestOrder();
    Long orderId = orderMapper.insert(order);

    // 执行测试
    Order result = orderService.getById(orderId);
    assertNotNull(result);
    assertEquals(order.getAmount(), result.getAmount());
}
```

### 3.4 数据隔离策略

```java
/**
 * 使用@Transactional实现测试数据自动回滚
 */
@SpringBootTest
@Transactional
class OrderServiceTransactionalTest {

    @Test
    void createOrder_WithTransaction_AutoRollback() {
        // 测试完成后自动回滚，无需手动清理
        Long orderId = orderService.createOrder(validRequest);
        assertNotNull(orderId);
        // 事务结束后自动回滚
    }
}

/**
 * 使用唯一前缀隔离测试数据
 */
class OrderServiceIsolationTest {

    private String testPrefix;

    @BeforeEach
    void setUp() {
        // 每个测试使用唯一前缀
        testPrefix = "TEST_" + UUID.randomUUID().toString().substring(0, 8) + "_";
    }

    @AfterEach
    void tearDown() {
        // 只清理本测试的数据
        orderMapper.delete(new QueryWrapper<Order>()
            .likeRight("order_no", testPrefix));
    }

    @Test
    void createOrder_WithPrefix_Isolated() {
        OrderCreateRequest request = new OrderCreateRequest();
        request.setOrderNo(testPrefix + "ORDER001");
        // ...
    }
}
```

## 四、集成测试规范 [MUST]

### 4.1 Testcontainers使用

```java
@SpringBootTest
@Testcontainers
class OrderServiceIntegrationTest {

    @Container
    static MySQLContainer<?> mysqlContainer = new MySQLContainer<>("mysql:8.0")
            .withDatabaseName("test_order_db")
            .withUsername("test")
            .withPassword("test123");

    @Container
    static GenericContainer<?> redisContainer = new GenericContainer<>("redis:6.2")
            .withExposedPorts(6379);

    @DynamicPropertySource
    static void registerProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", mysqlContainer::getJdbcUrl);
        registry.add("spring.datasource.username", mysqlContainer::getUsername);
        registry.add("spring.datasource.password", mysqlContainer::getPassword);
        registry.add("spring.redis.host", redisContainer::getHost);
        registry.add("spring.redis.port", redisContainer::getFirstMappedPort);
    }

    @BeforeEach
    void setUp() {
        // 初始化测试数据
        ScriptUtils.executeSqlScript(dataSource.getConnection(),
            new ClassPathResource("sql/schema.sql"));
        redisTemplate.opsForValue().set("stock:2001", "10");
    }

    @AfterEach
    void tearDown() {
        // 清理测试数据
        orderMapper.delete(new QueryWrapper<>());
        redisTemplate.delete("stock:2001");
    }

    @Test
    void testCreateOrder_RealDependencies_Success() {
        Long orderId = orderService.createOrder(validRequest);

        assertNotNull(orderId);
        // 验证数据库
        Order order = orderMapper.selectById(orderId);
        assertEquals(1001L, order.getUserId());
        // 验证Redis
        assertEquals("8", redisTemplate.opsForValue().get("stock:2001"));
    }
}
```

### 3.2 数据隔离

```yaml
rules:
  - 每个测试用例数据独立
  - @BeforeEach初始化数据
  - @AfterEach清理数据
  - 禁止测试间共享数据
```

## 五、契约测试规范 [SHOULD]

### 4.1 提供者端契约定义

```groovy
// src/test/resources/contracts/createOrder.groovy
Contract.make {
    request {
        method POST()
        url "/api/v1/orders"
        headers { contentType applicationJson() }
        body("""
            {
                "userId": 1001,
                "goodsList": [{"goodsId": 2001, "quantity": 2}],
                "amount": 200
            }
        """)
    }
    response {
        status OK()
        headers { contentType applicationJson() }
        body("""
            {
                "code": 200,
                "msg": "成功",
                "data": 3001
            }
        """)
        bodyMatchers {
            jsonPath('$.code', equalTo(200))
            jsonPath('$.data', nonNull())
        }
    }
}
```

### 4.2 消费者端契约验证

```java
@SpringBootTest
@AutoConfigureStubRunner(
    ids = "com.mall:order-service:+:stubs:8090",
    stubsMode = StubRunnerProperties.StubsMode.LOCAL
)
class PayServiceContractTest {
    @Test
    void testPaySuccess_UpdateOrderStatus_Success() {
        // 基于契约模拟调用
        Result<?> result = payService.paySuccess(3001L);
        assertEquals(200, result.getCode());
    }
}
```

## 六、接口测试规范 [MUST]

### 5.1 RestAssured测试

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class OrderControllerTest {
    @LocalServerPort
    private int port;

    @BeforeEach
    void setUp() {
        RestAssured.baseURI = "http://localhost";
        RestAssured.port = port;
    }

    // ✅ 正确：测试正常场景
    @Test
    void testCreateOrder_Success() {
        given()
            .contentType(ContentType.JSON)
            .body("""
                {
                    "userId": 1001,
                    "goodsList": [{"goodsId": 2001, "quantity": 2}],
                    "amount": 200
                }
            """)
        .when()
            .post("/api/v1/orders")
        .then()
            .statusCode(200)
            .body("code", equalTo(200))
            .body("data", notNullValue());
    }

    // ✅ 正确：测试权限场景
    @Test
    void testUpdateOrder_UnLogin_Fail() {
        given()
            .contentType(ContentType.JSON)
            .body("{\"orderId\": 3001, \"status\": 2}")
        .when()
            .post("/api/v1/orders/status")
        .then()
            .statusCode(200)
            .body("code", equalTo(401))
            .body("msg", equalTo("未登录"));
    }

    // ✅ 正确：测试幂等性
    @Test
    void testCreateOrder_DuplicateRequest_Idempotent() {
        String requestId = "test-123456";

        // 重复发送2次请求
        for (int i = 0; i < 2; i++) {
            given()
                .contentType(ContentType.JSON)
                .header("X-Request-Id", requestId)
                .body(validRequestJson)
            .when()
                .post("/api/v1/orders")
            .then()
                .statusCode(200)
                .body("data", equalTo(3001));
        }

        verify(orderService, times(1)).createOrder(any());
    }

    // ✅ 正确：测试SQL注入防护
    @Test
    void testQueryOrder_SqlInjection_Fail() {
        given()
            .pathParam("orderId", "3001' OR '1'='1")
        .when()
            .get("/api/v1/orders/{orderId}")
        .then()
            .statusCode(400)
            .body("msg", containsString("非法参数"));
    }
}
```

### 5.2 覆盖场景

```yaml
scenarios:
  - 正常请求
  - 参数校验失败
  - 权限校验失败
  - 业务异常
  - 幂等性
  - SQL注入防护
  - XSS防护
```

## 七、性能测试规范 [SHOULD]

### 6.1 测试指标

```yaml
metrics:
  qps: 目标QPS（如2000）
  rt_p99: P99响应时间（如200ms）
  rt_p95: P95响应时间（如100ms）
  error_rate: 错误率（<0.1%）
  resource:
    cpu: <80%
    memory: <85%
    gc_pause: <100ms
```

### 6.2 测试环境

```yaml
rules:
  - 预发环境执行（与生产配置一致）
  - 清理历史数据
  - 监控JVM指标
  - 持续压测30分钟
```

### 6.3 JMeter配置

```yaml
thread_group:
  threads: 100
  ramp_up: 60      # 60秒启动所有线程
  duration: 1800   # 持续30分钟

http_request:
  method: POST
  path: /api/v1/orders
  content_type: application/json
  body: |
    {
      "userId": ${userId},
      "goodsList": [{"goodsId": 2001, "quantity": 1}],
      "amount": 100
    }
```

## 八、CI/CD集成规范 [MUST]

### 7.1 流水线配置

```yaml
# .github/workflows/test.yml
name: Test Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  unit-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: maven

      - name: Run Unit Tests
        run: mvn test -Dtest=*ServiceTest

      - name: Generate Coverage Report
        run: mvn jacoco:report

      - name: Check Coverage Threshold
        run: |
          COVERAGE=$(grep -oP 'Total.*?([0-9]+)%' target/site/jacoco/index.html | grep -oP '[0-9]+' | head -1)
          if [ "$COVERAGE" -lt 80 ]; then
            echo "Coverage $COVERAGE% is below 80% threshold"
            exit 1
          fi

      - name: Upload Coverage Report
        uses: actions/upload-artifact@v4
        with:
          name: jacoco-report
          path: target/site/jacoco/

  integration-test:
    runs-on: ubuntu-latest
    needs: unit-test
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: test123
          MYSQL_DATABASE: test_db
        ports:
          - 3306:3306
        options: --health-cmd="mysqladmin ping" --health-interval=10s --health-timeout=5s --health-retries=3
      redis:
        image: redis:6.2
        ports:
          - 6379:6379
        options: --health-cmd="redis-cli ping" --health-interval=10s --health-timeout=5s --health-retries=3

    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: maven

      - name: Run Integration Tests
        run: mvn test -Dtest=*IntegrationTest
        env:
          SPRING_DATASOURCE_URL: jdbc:mysql://localhost:3306/test_db
          SPRING_REDIS_HOST: localhost

  api-test:
    runs-on: ubuntu-latest
    needs: integration-test
    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: maven

      - name: Run API Tests
        run: mvn test -Dtest=*ControllerTest
```

### 7.2 质量门禁

```yaml
quality_gates:
  - unit_test_coverage >= 80%
  - all_tests_passed
  - no_critical_issues (SonarQube)
  - no_high_vulnerabilities
```

## 九、反模式检查清单

| 序号 | 反模式 | 检测方式 |
|------|--------|----------|
| 1 | 单元测试依赖真实DB | 检查是否使用@MockBean |
| 2 | 只覆盖正常场景 | 检查异常场景测试用例 |
| 3 | 接口测试仅验证code=200 | 检查响应体断言 |
| 4 | 性能测试在开发环境执行 | 检查测试环境配置 |
| 5 | 契约测试缺失 | 检查服务间接口定义 |
| 6 | 测试数据未隔离 | 检查@BeforeEach/@AfterEach |
| 7 | 覆盖率低于80% | JaCoCo报告检查 |
| 8 | 未集成CI/CD | 检查流水线配置 |
| 9 | 测试用例未随代码更新 | 检查测试代码提交记录 |
| 10 | 吞异常不断言 | 检查catch块处理 |
