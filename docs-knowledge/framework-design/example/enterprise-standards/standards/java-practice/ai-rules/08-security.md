# 安全规范 - AI编码约束

> 适用于：输入输出安全、权限控制、数据加密、安全防护场景

## 一、输入输出安全规范 [MUST]

### 1.1 防SQL注入

```yaml
rules:
  - MyBatis必须使用#{}，禁止${}
  - JDBC必须使用PreparedStatement
  - 禁止字符串拼接SQL
  - ${}仅允许动态表名/排序字段（需白名单校验）
```

```java
// ✅ 正确：MyBatis #{}
@Select("SELECT * FROM user WHERE id = #{userId}")
User selectById(@Param("userId") Long userId);

// ❌ 错误：MyBatis ${}
@Select("SELECT * FROM user WHERE name = '${name}'")
User selectByName(@Param("name") String name);

// ❌ 错误：字符串拼接
String sql = "SELECT * FROM user WHERE id = " + userId;
```

```java
// ✅ 正确：动态表名需白名单校验
private static final Set<String> ALLOWED_TABLES = Set.of("order_2024", "order_2025");

public List<Order> queryByTable(String tableName) {
    if (!ALLOWED_TABLES.contains(tableName)) {
        throw new IllegalArgumentException("非法表名");
    }
    return orderMapper.selectByTable(tableName);
}
```

### 1.2 防XSS攻击

```yaml
rules:
  - 输入过滤：网关层统一过滤危险字符
  - 输出编码：响应数据HTML编码
  - CSP配置：Content-Security-Policy响应头
```

```java
// ✅ 正确：输出编码
public String sanitizeOutput(String input) {
    return StringEscapeUtils.escapeHtml4(input);
}

// ✅ 正确：网关XSS过滤
@Bean
public GlobalFilter xssFilter() {
    return (exchange, chain) -> {
        String value = exchange.getRequest().getQueryParams().getFirst("keyword");
        if (containsXss(value)) {
            return ServerResponse.status(HttpStatus.FORBIDDEN)
                .body(BodyInserters.fromValue("非法请求"));
        }
        return chain.filter(exchange);
    };
}

private boolean containsXss(String value) {
    String[] keywords = {"<script>", "javascript:", "onclick", "onerror"};
    return Arrays.stream(keywords).anyMatch(value.toLowerCase()::contains);
}
```

### 1.3 防CSRF攻击

```yaml
rules:
  - Token验证：请求必须携带CSRF Token
  - 同源策略：校验Referer/Origin
  - SameSite：Cookie设置SameSite=Strict
```

```java
// ✅ 正确：CSRF Token校验
@PostMapping("/api/v1/orders")
public Result<Long> createOrder(
        @RequestHeader("X-CSRF-Token") String csrfToken,
        @RequestBody OrderCreateRequest request) {
    // 校验Token
    if (!csrfService.validateToken(csrfToken)) {
        throw new BusinessException("CSRF Token无效");
    }
    return Result.success(orderService.createOrder(request));
}
```

## 二、权限控制规范 [MUST]

### 2.1 RBAC权限模型

```yaml
model: RBAC3.0（用户-角色-权限-数据）
rules:
  - 功能权限：控制接口访问
  - 数据权限：控制数据范围
  - 最小权限原则
```

```sql
-- 用户表
CREATE TABLE `sys_user` (user_id bigint PRIMARY KEY, username varchar(50) NOT NULL);
-- 角色表
CREATE TABLE `sys_role` (role_id bigint PRIMARY KEY, role_name varchar(50) NOT NULL);
-- 用户-角色关联
CREATE TABLE `sys_user_role` (user_id bigint NOT NULL, role_id bigint NOT NULL);
-- 功能权限表
CREATE TABLE `sys_perm` (perm_id bigint PRIMARY KEY, perm_name varchar(50), url varchar(200));
-- 角色-权限关联
CREATE TABLE `sys_role_perm` (role_id bigint NOT NULL, perm_id bigint NOT NULL);
-- 数据权限表
CREATE TABLE `sys_data_perm` (role_id bigint NOT NULL, data_scope varchar(50));
```

### 2.2 分层权限校验

```yaml
layers:
  - 前端：隐藏无权限按钮（仅辅助）
  - 网关：统一Token校验
  - 接口：@PreAuthorize注解校验
  - 业务：数据权限校验
```

```java
// ✅ 正确：接口层权限校验
@PreAuthorize("hasPermission('order:update')")
@PutMapping("/api/v1/orders/{orderId}")
public Result<Void> updateOrder(@PathVariable Long orderId, @RequestBody OrderUpdateRequest request) {
    return Result.success(orderService.updateOrder(orderId, request));
}

// ✅ 正确：业务层数据权限校验
public OrderVO getOrder(Long orderId) {
    Order order = orderMapper.selectById(orderId);
    Long currentUserId = SecurityUtils.getCurrentUserId();

    // 数据权限校验：只能查看自己的订单
    if (!order.getUserId().equals(currentUserId) && !SecurityUtils.isAdmin()) {
        throw new AccessDeniedException("无权访问该订单");
    }
    return convertToVO(order);
}
```

### 2.3 超管权限管控

```yaml
rules:
  - 超管操作必须审计日志
  - 敏感操作二次验证
  - 定期权限审查
```

```java
// ✅ 正确：超管敏感操作审计
@AuditLog(operation = "删除用户", level = LogLevel.CORE)
@PreAuthorize("hasRole('SUPER_ADMIN')")
public void deleteUser(Long userId) {
    // 二次验证
    if (!verifyService.verifySecondFactor()) {
        throw new BusinessException("请完成二次验证");
    }
    userMapper.deleteById(userId);
}
```

## 三、数据加密规范 [MUST]

### 3.1 传输加密

```yaml
rules:
  - 强制HTTPS
  - 核心服务mTLS双向认证
  - 禁止明文传输敏感数据
```

```yaml
# Spring Boot强制HTTPS
server:
  port: 443
  ssl:
    enabled: true
    key-store: classpath:keystore.jks
    key-store-password: ${SSL_PASSWORD}
```

### 3.2 存储加密

| 数据类型 | 加密方式 | 密钥管理 |
|----------|----------|----------|
| 密码 | BCrypt（不可逆） | 无需密钥 |
| 手机号/身份证 | AES-256-GCM | KMS管理 |
| 银行卡号 | RSA-2048 | HSM存储私钥 |

```java
// ✅ 正确：密码BCrypt加密
public void register(UserRegisterRequest request) {
    String encryptedPwd = BCrypt.hashpw(request.getPassword(), BCrypt.gensalt(12));
    user.setPassword(encryptedPwd);
}

// ✅ 正确：手机号AES加密
public void saveUser(User user) {
    String aesKey = kmsService.getSecret("user.phone.aes.key");
    String encryptedPhone = AesUtils.encrypt(user.getPhone(), aesKey, "GCM");
    user.setPhone(encryptedPhone);
}

// ❌ 错误：明文存储
user.setPassword(rawPassword);

// ❌ 错误：MD5加密密码（可破解）
user.setPassword(DigestUtils.md5Hex(rawPassword));
```

### 3.3 密钥管理

```yaml
rules:
  - 禁止硬编码密钥
  - 使用KMS管理密钥
  - 定期轮换密钥
```

```java
// ❌ 错误：硬编码密钥
private static final String SECRET_KEY = "my-secret-key-123";

// ✅ 正确：从KMS获取密钥
private String getSecretKey() {
    return kmsService.getSecret("aes.encryption.key");
}
```

## 四、数据脱敏规范 [MUST]

### 4.1 脱敏策略

| 数据类型 | 脱敏规则 | 示例 |
|----------|----------|------|
| 手机号 | 保留前3后4 | 138****8000 |
| 身份证 | 保留前6后4 | 310***********1234 |
| 银行卡 | 保留后4位 | ************1234 |
| 邮箱 | 保留首字母和域名 | z***@example.com |

### 4.2 脱敏实现

```java
// ✅ 正确：响应脱敏
@Data
public class UserVO {
    private Long userId;
    private String userName;

    @JsonSerialize(using = PhoneDesensitizer.class)
    private String phone;  // 138****8000

    @JsonSerialize(using = IdCardDesensitizer.class)
    private String idCard;  // 310***********1234
}

// ✅ 正确：日志脱敏
log.info("用户登录，phone={}", DesensitizeUtils.maskPhone(phone));
```

### 4.3 日志脱敏

```yaml
rules:
  - 禁止日志打印明文密码、密钥
  - 敏感字段自动脱敏
  - 生产环境禁止DEBUG日志
```

```java
// ❌ 错误：日志明文打印
log.info("用户登录，phone={}, password={}", phone, password);

// ✅ 正确：脱敏后打印
log.info("用户登录，phone={}", DesensitizeUtils.maskPhone(phone));
```

## 五、容器与微服务安全 [MUST]

### 5.1 容器安全

```yaml
rules:
  - 禁止root用户运行容器
  - 使用只读文件系统
  - 限制资源配额
  - 定期扫描镜像漏洞
```

```dockerfile
# ✅ 正确：非root用户
FROM eclipse-temurin:17-jre-alpine
RUN addgroup -S app && adduser -S app -G app
USER app
COPY target/app.jar /app/app.jar
ENTRYPOINT ["java", "-jar", "/app/app.jar"]

# ❌ 错误：root用户运行
FROM eclipse-temurin:17-jre
COPY target/app.jar /app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

```yaml
# K8s安全配置
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
```

### 5.2 微服务通信安全

```yaml
rules:
  - 服务间mTLS认证
  - JWT Token校验
  - 敏感接口限流
```

```yaml
# Istio mTLS配置
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: prod
spec:
  mtls:
    mode: STRICT
```

## 六、依赖安全规范 [MUST]

### 6.1 依赖扫描

```yaml
rules:
  - CI/CD集成依赖扫描
  - 定期更新依赖版本
  - 禁止使用有漏洞依赖
```

```xml
<!-- Maven依赖检查插件 -->
<plugin>
    <groupId>org.owasp</groupId>
    <artifactId>dependency-check-maven</artifactId>
    <version>8.2.1</version>
    <executions>
        <execution>
            <goals><goal>check</goal></goals>
        </execution>
    </executions>
    <configuration>
        <failBuildOnCVSS>7</failBuildOnCVSS>
    </configuration>
</plugin>
```

### 6.2 危险编码禁止

```java
// ❌ 错误：命令注入
Runtime.getRuntime().exec("ls " + userInput);

// ❌ 错误：反序列化漏洞
ObjectInputStream ois = new ObjectInputStream(inputStream);
Object obj = ois.readObject();  // 不安全

// ❌ 错误：路径遍历
new File("/data/" + userInput);  // 用户输入可能是../etc/passwd

// ✅ 正确：路径校验
public File getFile(String filename) {
    Path path = Paths.get("/data", filename).normalize();
    if (!path.startsWith("/data")) {
        throw new SecurityException("非法路径");
    }
    return path.toFile();
}
```

## 七、安全监控规范 [MUST]

### 7.1 监控指标

```yaml
metrics:
  - 登录失败次数/分钟
  - 异常访问IP
  - 敏感接口调用频率
  - 权限校验失败次数
```

### 7.2 告警规则

```yaml
alerts:
  - name: 暴力破解告警
    condition: login_failure_count > 10/min
    action: 封禁IP 30分钟
  - name: 敏感接口异常
    condition: api_error_rate > 5%
    action: 通知安全团队
```

### 7.3 审计日志

```java
// ✅ 正确：敏感操作审计
@Aspect
@Component
public class AuditLogAspect {
    @AfterReturning(pointcut = "@annotation(auditLog)", returning = "result")
    public void recordLog(JoinPoint joinPoint, AuditLog auditLog, Object result) {
        AuditLogEntity log = new AuditLogEntity()
            .setUserId(SecurityUtils.getCurrentUserId())
            .setOperation(auditLog.operation())
            .setIp(ServletUtils.getClientIp())
            .setParams(JSON.toJSONString(joinPoint.getArgs()))
            .setResult(JSON.toJSONString(result))
            .setOperateTime(LocalDateTime.now());
        auditLogMapper.insert(log);
    }
}
```

## 八、反模式检查清单

| 序号 | 反模式 | 检测方式 |
|------|--------|----------|
| 1 | MyBatis使用${} | 检查Mapper XML和注解 |
| 2 | 密码明文/MD5存储 | 检查加密方式 |
| 3 | 权限仅前端校验 | 检查接口注解 |
| 4 | 密钥硬编码 | 检查代码中的常量 |
| 5 | 容器root运行 | 检查Dockerfile |
| 6 | 日志明文打印敏感数据 | 检查log语句 |
| 7 | 依赖有高危漏洞 | 运行OWASP扫描 |
| 8 | 微服务通信无认证 | 检查mTLS配置 |
| 9 | 无审计日志 | 检查敏感操作 |
| 10 | 敏感配置明文 | 检查配置文件 |
