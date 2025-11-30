# 测试策略 (Test Strategy)

**版本**: 1.0
**最后更新**: 2025-11-30

---

## 1. 测试金字塔

```
        /\
       /  \         E2E Tests (10%)
      /----\        - 关键用户流程
     /      \
    /--------\      Integration Tests (20%)
   /          \     - API测试、服务间集成
  /------------\
 /              \   Unit Tests (70%)
/________________\  - 业务逻辑、工具类
```

---

## 2. 测试类型

### 2.1 单元测试 (Unit Tests)

**目标**: 测试单个类或方法的逻辑正确性

**覆盖率要求**: ≥ 80%

**工具**: JUnit 5 + Mockito

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserServiceImpl userService;

    @Test
    void shouldCreateUserSuccessfully() {
        // Given
        CreateUserRequest request = new CreateUserRequest("test@example.com", "password123");
        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        when(userRepository.save(any(User.class))).thenAnswer(i -> i.getArgument(0));

        // When
        User result = userService.createUser(request);

        // Then
        assertThat(result.getEmail()).isEqualTo("test@example.com");
        verify(userRepository).save(any(User.class));
    }

    @Test
    void shouldThrowExceptionWhenEmailExists() {
        // Given
        CreateUserRequest request = new CreateUserRequest("existing@example.com", "password123");
        when(userRepository.existsByEmail(anyString())).thenReturn(true);

        // When & Then
        assertThrows(BusinessException.class, () -> userService.createUser(request));
    }
}
```

### 2.2 集成测试 (Integration Tests)

**目标**: 测试组件间的集成

**工具**: Spring Boot Test + Testcontainers

```java
@SpringBootTest
@Testcontainers
class UserControllerIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15");

    @Autowired
    private MockMvc mockMvc;

    @Test
    void shouldCreateUser() throws Exception {
        String request = """
            {
                "email": "test@example.com",
                "password": "password123",
                "name": "Test User"
            }
            """;

        mockMvc.perform(post("/api/v1/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(request))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.email").value("test@example.com"));
    }
}
```

### 2.3 E2E测试 (End-to-End Tests)

**目标**: 测试完整用户流程

**工具**: Playwright / Cypress

```typescript
test('用户注册流程', async ({ page }) => {
  // 访问注册页面
  await page.goto('/register');

  // 填写表单
  await page.fill('[data-testid="email"]', 'test@example.com');
  await page.fill('[data-testid="password"]', 'password123');
  await page.fill('[data-testid="name"]', 'Test User');

  // 提交
  await page.click('[data-testid="submit"]');

  // 验证
  await expect(page).toHaveURL('/dashboard');
  await expect(page.locator('[data-testid="welcome"]')).toContainText('Test User');
});
```

---

## 3. 测试命名规范

```java
// 格式: should{Expected}When{Condition}
@Test
void shouldReturnUserWhenUserExists() { }

@Test
void shouldThrowExceptionWhenUserNotFound() { }

@Test
void shouldCreateOrderWhenStockAvailable() { }
```

---

## 4. 测试数据管理

### 4.1 测试数据原则

- 每个测试独立，不依赖其他测试的数据
- 使用 Builder 模式创建测试数据
- 测试完成后清理数据

### 4.2 测试数据 Builder

```java
public class UserTestData {

    public static User.UserBuilder defaultUser() {
        return User.builder()
            .id(UUID.randomUUID().toString())
            .email("test@example.com")
            .name("Test User")
            .status(UserStatus.ACTIVE)
            .createdAt(LocalDateTime.now());
    }

    public static User activeUser() {
        return defaultUser().status(UserStatus.ACTIVE).build();
    }

    public static User pendingUser() {
        return defaultUser().status(UserStatus.PENDING).build();
    }
}
```

---

## 5. CI 集成

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          java-version: '17'
      - name: Run Unit Tests
        run: ./gradlew test

  integration-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Integration Tests
        run: ./gradlew integrationTest

  coverage:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Tests with Coverage
        run: ./gradlew jacocoTestReport
      - name: Check Coverage
        run: ./gradlew jacocoTestCoverageVerification
```

---

## 6. 覆盖率要求

| 模块 | 行覆盖率 | 分支覆盖率 |
|------|----------|------------|
| Service | ≥ 85% | ≥ 80% |
| Repository | ≥ 70% | ≥ 60% |
| Controller | ≥ 80% | ≥ 70% |
| Utils | ≥ 90% | ≥ 85% |
| **整体** | **≥ 80%** | **≥ 70%** |

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| 1.0 | 2025-11-30 | 初始版本 | @测试负责人 |
