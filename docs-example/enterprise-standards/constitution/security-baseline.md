# 安全基线要求 (Security Baseline)

**版本**: 1.0
**最后更新**: 2025-11-30
**负责人**: @安全委员会
**状态**: 已发布

---

## 概述

本文档定义了所有系统必须满足的最低安全要求。这是企业安全的底线，任何项目不得突破。

<!-- AI-CONTEXT
安全基线是强制要求，AI在代码生成时必须遵循。
重点关注：认证、授权、数据保护、输入验证、日志审计
-->

---

## 1. 认证安全 (Authentication)

### 强制要求

| 要求 | 描述 | 级别 |
|------|------|------|
| **协议标准** | 使用 OAuth 2.0 / OIDC | 强制 |
| **密码存储** | bcrypt (cost≥12) 或 argon2id | 强制 |
| **会话管理** | JWT 有效期 ≤ 1小时，Refresh Token ≤ 7天 | 强制 |
| **多因素认证** | 管理后台、敏感操作必须 MFA | 强制 |

### 密码策略

```yaml
password_policy:
  min_length: 12
  require_uppercase: true
  require_lowercase: true
  require_number: true
  require_special: true
  max_age_days: 90
  history_count: 5  # 禁止重复使用最近5个密码
```

### 示例代码

```java
// ✅ 正确：使用 BCrypt 加密
@Service
public class PasswordService {
    private static final int BCRYPT_STRENGTH = 12;

    public String hashPassword(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(BCRYPT_STRENGTH));
    }

    public boolean verifyPassword(String plainPassword, String hashedPassword) {
        return BCrypt.checkpw(plainPassword, hashedPassword);
    }
}

// ❌ 错误：明文存储或弱哈希
public String hashPassword(String password) {
    return DigestUtils.md5Hex(password);  // 禁止使用MD5
}
```

---

## 2. 授权安全 (Authorization)

### 强制要求

| 要求 | 描述 |
|------|------|
| **最小权限原则** | 只授予完成任务所需的最小权限 |
| **默认拒绝** | 未明确授权的操作默认拒绝 |
| **资源级控制** | 不仅检查操作权限，还要检查资源所有权 |

### RBAC模型

```yaml
roles:
  admin:
    permissions: ["*"]
  manager:
    permissions: ["user:read", "user:update", "order:*"]
  user:
    permissions: ["profile:read", "profile:update", "order:create", "order:read:own"]
```

### 示例代码

```java
// ✅ 正确：检查资源所有权
@PreAuthorize("hasPermission(#orderId, 'Order', 'read')")
public Order getOrder(String orderId, Authentication auth) {
    Order order = orderRepository.findById(orderId)
        .orElseThrow(() -> new NotFoundException());

    // 额外检查：确保用户只能访问自己的订单
    if (!order.getUserId().equals(auth.getUserId())
        && !auth.hasRole("ADMIN")) {
        throw new AccessDeniedException("Cannot access other user's order");
    }
    return order;
}
```

---

## 3. 数据保护 (Data Protection)

### 传输安全

| 要求 | 标准 |
|------|------|
| **TLS版本** | ≥ TLS 1.2，推荐 TLS 1.3 |
| **证书管理** | 使用可信CA，禁止自签名(生产) |
| **内部通信** | 服务间通信也必须加密 |

### 存储安全

| 数据类型 | 处理方式 |
|----------|----------|
| **密码** | bcrypt/argon2 哈希 |
| **敏感个人信息** | AES-256 加密存储 |
| **支付信息** | 符合 PCI-DSS，tokenization |
| **日志中敏感数据** | 脱敏处理 |

### 脱敏规则

```java
public class DataMasking {
    // 手机号: 138****1234
    public static String maskPhone(String phone) {
        return phone.replaceAll("(\\d{3})\\d{4}(\\d{4})", "$1****$2");
    }

    // 身份证: 110***********1234
    public static String maskIdCard(String idCard) {
        return idCard.replaceAll("(\\d{3})\\d{11}(\\d{4})", "$1***********$2");
    }

    // 邮箱: u***@example.com
    public static String maskEmail(String email) {
        return email.replaceAll("(.)[^@]*(@.*)", "$1***$2");
    }
}
```

---

## 4. 输入验证 (Input Validation)

### 强制要求

- **所有输入必须验证**: 来自用户、API、文件、数据库的所有数据
- **白名单优先**: 验证允许的输入，而非禁止的输入
- **服务端验证**: 前端验证仅为用户体验，后端必须再次验证

### 防注入

```java
// ✅ 正确：参数化查询
@Query("SELECT u FROM User u WHERE u.email = :email")
User findByEmail(@Param("email") String email);

// ❌ 错误：字符串拼接（SQL注入风险）
String sql = "SELECT * FROM users WHERE email = '" + email + "'";
```

### 验证示例

```java
@Data
public class CreateUserRequest {

    @NotBlank(message = "用户名不能为空")
    @Size(min = 3, max = 50, message = "用户名长度3-50字符")
    @Pattern(regexp = "^[a-zA-Z0-9_]+$", message = "用户名只能包含字母数字下划线")
    private String username;

    @NotBlank(message = "邮箱不能为空")
    @Email(message = "邮箱格式不正确")
    private String email;

    @NotBlank(message = "密码不能为空")
    @Size(min = 12, message = "密码至少12位")
    private String password;
}
```

---

## 5. 审计日志 (Audit Logging)

### 必须记录的事件

| 事件类型 | 示例 |
|----------|------|
| **认证事件** | 登录成功/失败、登出、密码修改 |
| **授权事件** | 权限变更、角色分配 |
| **数据访问** | 敏感数据查询、批量导出 |
| **管理操作** | 用户创建/删除、配置变更 |
| **安全事件** | 异常访问、攻击检测 |

### 审计日志格式

```json
{
  "timestamp": "2025-11-30T10:15:30.123Z",
  "eventType": "USER_LOGIN",
  "eventResult": "SUCCESS",
  "actor": {
    "userId": "user-001",
    "username": "john.doe",
    "ip": "192.168.1.100",
    "userAgent": "Mozilla/5.0..."
  },
  "target": {
    "type": "USER_ACCOUNT",
    "id": "user-001"
  },
  "context": {
    "sessionId": "sess-abc123",
    "mfaUsed": true
  }
}
```

---

## 6. 依赖安全 (Dependency Security)

### 强制要求

| 要求 | 工具 | 频率 |
|------|------|------|
| **漏洞扫描** | Snyk / OWASP Dependency-Check | 每次构建 |
| **许可证检查** | license-maven-plugin | 每次构建 |
| **依赖更新** | Dependabot / Renovate | 每周 |

### CI集成示例

```yaml
# .github/workflows/security.yml
security-scan:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Run Snyk
      uses: snyk/actions/gradle@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=high
```

---

## 安全检查清单

### 开发阶段
- [ ] 所有输入已验证
- [ ] 使用参数化查询
- [ ] 敏感数据已加密/脱敏
- [ ] 日志不包含敏感信息
- [ ] 依赖无高危漏洞

### 部署前
- [ ] TLS配置正确
- [ ] 默认密码已修改
- [ ] 调试功能已关闭
- [ ] 安全扫描通过
- [ ] 渗透测试完成(高风险系统)

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| 1.0 | 2025-11-30 | 初始版本 | @安全委员会 |
