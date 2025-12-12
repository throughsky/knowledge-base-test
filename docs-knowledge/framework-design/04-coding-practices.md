# 第4章 编码技巧规范

## 4.1 AI 编码优先级

### 4.1.1 优先级定义

| 级别 | 标识 | 含义 | AI 行为 |
|------|------|------|---------|
| 🔴 强制 | `[MUST]` | 违反将导致严重问题 | 必须遵守，不可妥协 |
| 🟡 推荐 | `[SHOULD]` | 最佳实践 | 默认遵守，特殊情况可调整 |
| 🟢 建议 | `[MAY]` | 可选优化 | 视情况采用 |

### 4.1.2 安全优先原则 [MUST]

```yaml
priorities:
  - SQL 注入防护 > 功能实现
  - 密码加密存储 > 快速开发
  - 敏感数据脱敏 > 日志完整性
  - 权限验证 > 业务逻辑
```

### 4.1.3 性能意识原则 [SHOULD]

```yaml
checks:
  - 索引是否合理设计
  - 是否存在 N+1 查询
  - 缓存策略是否正确
  - 线程池参数是否合理
  - 大数据量是否分页
```

---

## 4.2 方法级优化技巧

### 4.2.1 提炼方法与意图导向编程 [SHOULD]

**适用场景**：
- 多个方法代码重复
- 方法中代码过长（一般不超过80行）
- 方法中语句不在同一抽象层级

**意图导向编程原则**：
- 将处理流程和具体实现分离
- 把问题分解为一系列功能性步骤
- 假定功能步骤已实现，先组织整体流程
- 最后再实现各个具体方法

### 4.2.2 其他方法级技巧 [MAY]

| 技巧 | 说明 |
|------|------|
| **以函数对象取代函数** | 将大型函数放进单独对象中，局部变量变成对象字段 |
| **引入参数对象** | 方法参数较多时，将参数封装为参数对象 |
| **移除对参数的赋值** | 有返回值的方法不应有副作用，避免修改参数值 |
| **引入解释性变量** | 将复杂表达式结果放入临时变量，用变量名解释用途 |
| **try-catch内部代码抽成方法** | 保持核心逻辑清晰 |

---

## 4.3 条件判断优化

### 4.3.1 使用卫语句替代嵌套条件 [SHOULD]

```java
// ❌ 反例：多层嵌套
if (condition1) {
    if (condition2) {
        if (condition3) {
            // 核心逻辑
        }
    }
}

// ✅ 正例：卫语句
if (!condition1) return;
if (!condition2) return;
if (!condition3) return;
// 核心逻辑
```

**优势**：降低复杂度、提高可读性、核心逻辑更清晰

### 4.3.2 使用多态替代条件判断 [MAY]

**适用场景**：当存在根据对象类型选择不同行为的条件表达式时

**实现方式**：
- 将每个分支放进子类内的覆写方法
- 将原始函数声明为抽象函数
- 利用多态机制自动选择正确的实现

---

## 4.4 异常处理规范

### 4.4.1 禁止行为 [MUST]

```java
// ❌ 禁止：吞掉异常
try {
    // 业务逻辑
} catch (Exception e) {
    // 空处理
}

// ❌ 禁止：只打印异常
catch (Exception e) {
    e.printStackTrace();
}

// ✅ 正确：记录并处理异常
catch (Exception e) {
    log.error("操作失败, userId={}", userId, e);
    throw new BusinessException("操作失败");
}
```

### 4.4.2 异常处理原则 [SHOULD]

- 通过最上层统一处理异常，转换成标准返回码
- 不要使用异常处理正常的业务流程控制
- 尽量使用标准异常
- 避免在 finally 语句块中抛出异常
- finally 块中只做关闭资源类操作

### 4.4.3 引入断言 [MAY]

- 只用于检查"一定必须为真"的条件
- 不用于检查"应该为真"的条件

---

## 4.5 空值处理

### 4.5.1 引入 Null 对象或特殊对象 [SHOULD]

**解决方案**：
- 创建一个特殊的空对象类
- 空对象提供默认的安全行为
- 使用 Optional 优雅处理

```java
// ✅ 正确：Optional
public String getUserName(Long userId) {
    return Optional.ofNullable(userMapper.selectById(userId))
            .map(User::getName)
            .orElse("未知用户");
}

// ✅ 正确：返回空集合
public List<Order> getOrders(Long userId) {
    List<Order> orders = orderMapper.selectByUserId(userId);
    return orders != null ? orders : Collections.emptyList();
}
```

---

## 4.6 类设计优化

### 4.6.1 组合优先于继承 [SHOULD]

**继承的局限性**：
- 打破封装性
- 子类依赖父类实现细节
- 父类变化可能破坏子类

**组合的优势**：
- 通过私有域引用现有类实例
- 不依赖现有类实现细节
- 更加稳固和灵活

### 4.6.2 链式调用限制 [MUST]

```java
// ❌ 禁止：继承体系中使用 @Accessors(chain = true)
@Data
@Accessors(chain = true)
public class BaseRequest { private String traceId; }

@Data
@Accessors(chain = true)
public class OrderRequest extends BaseRequest { private Long orderId; }

// ✅ 正确：使用 @Builder 替代
@Builder
public class OrderRequest {
    private String traceId;
    private Long orderId;
}
```

### 4.6.3 接口优于抽象类 [SHOULD]

**最佳实践**：接口 + 骨架实现类（模板方法设计模式）

---

## 4.7 安全编码规范

### 4.7.1 SQL 安全 [MUST]

```java
// ❌ 禁止：SQL 拼接
String sql = "SELECT * FROM user WHERE id = " + userId;

// ❌ 禁止：MyBatis 使用 ${}
@Select("SELECT * FROM user WHERE name = '${name}'")

// ✅ 正确：MyBatis 参数化查询
@Select("SELECT * FROM user WHERE id = #{userId}")
User selectById(@Param("userId") Long userId);
```

### 4.7.2 密码与敏感信息 [MUST]

```java
// ❌ 禁止：明文存储密码
user.setPassword(rawPassword);

// ❌ 禁止：硬编码敏感信息
String apiKey = "sk-xxxx";

// ✅ 正确：密码 BCrypt 加密
user.setPassword(BCrypt.hashpw(rawPassword, BCrypt.gensalt()));

// ✅ 正确：从配置中心读取
@Value("${api.key}")
private String apiKey;
```

---

## 4.8 并发编程规范

### 4.8.1 线程池规范 [MUST]

```java
// ❌ 禁止：使用 Executors 创建线程池
ExecutorService executor = Executors.newFixedThreadPool(10);

// ✅ 正确：手动创建线程池
new ThreadPoolExecutor(
    coreSize,
    maxSize,
    keepAlive,
    TimeUnit.SECONDS,
    new ArrayBlockingQueue<>(100),
    new ThreadFactoryBuilder().setNameFormat("biz-pool-%d").build(),
    new ThreadPoolExecutor.CallerRunsPolicy()
);
```

### 4.8.2 其他并发规范 [SHOULD]

| 规范 | 说明 |
|------|------|
| **涉及线程间可见性加 volatile** | 保证线程间的可见性 |
| **减小锁使用范围** | 只给需要加锁的代码加锁，在 finally 中释放锁 |
| **分布式锁规范** | 必须设置过期时间和获取锁的超时时间 |

---

## 4.9 缓存规范

### 4.9.1 缓存使用 [MUST]

```java
// ❌ 禁止：缓存无过期时间
redisTemplate.opsForValue().set(key, value);

// ✅ 正确：设置缓存过期时间
redisTemplate.opsForValue().set(key, value, 30, TimeUnit.MINUTES);
```

### 4.9.2 Redis Key 命名 [SHOULD]

```yaml
format: 业务域:模块:资源:唯一标识
separator: 冒号(:)
```

```java
// ✅ 正确命名
String userKey = "mall:user:info:" + userId;
String orderKey = "mall:order:detail:" + orderId;
```

---

## 4.10 数据查询规范

### 4.10.1 分页查询 [MUST]

```java
// ❌ 禁止：无限制查询
List<Order> orders = orderMapper.selectAll();

// ✅ 正确：分页查询
PageHelper.startPage(pageNum, pageSize);
List<Order> orders = orderMapper.selectByUserId(userId);
```

### 4.10.2 性能优化 [SHOULD]

| 技巧 | 说明 |
|------|------|
| **集合指定初始化大小** | 避免扩容消耗性能 |
| **不要使用 BeanUtils 拷贝属性** | 基于反射性能较差，使用 MapStruct |
| **使用 StringBuilder 拼接字符串** | 减少对象创建 |
| **不循环调用数据库** | 批量查询 + 转换为 Map + 内存匹配 |
| **用业务代码代替多表 join** | 在应用层进行数据关联 |

---

## 4.11 错误码规范

### 4.11.1 错误码格式 [MUST]

```
格式：[系统编码4位][类型1位][序列号8位]
类型：B=业务错误, C=客户端错误, T=系统错误
成功码："0"
```

```java
public enum ErrorCodeEnum {
    SUCCESS("0", "success"),
    USER_NOT_FOUND("1001B00000001", "用户不存在"),
    PARAM_ERROR("1001C00000001", "参数校验失败"),
    SYSTEM_ERROR("1001T00000001", "系统内部错误");
}
```

---

## 4.12 参数校验与返回规范

### 4.12.1 参数校验 [MUST]

**格式校验**：
- 使用 hibernate-validator 框架
- 在实体类上使用 @NotBlank、@NotNull 等注解
- Controller 方法上使用 @Valid 注解

**业务校验**：
- 自定义校验注解
- 实现 ConstraintValidator 接口

### 4.12.2 统一返回值 [MUST]

```java
@Data
public class CommonResponse<T> {
    private String code;
    private String message;
    private T data;

    public boolean isSuccess() { return "0".equals(code); }
}
```

---

## 4.13 反模式检查清单

| 序号 | 反模式 | 检测方式 |
|------|--------|----------|
| 1 | SQL 字符串拼接 | 检查 SQL 语句构造方式 |
| 2 | 使用 Executors 创建线程池 | 检查线程池创建方式 |
| 3 | 空 catch 块 | 检查异常处理逻辑 |
| 4 | 明文密码存储 | 检查密码处理方式 |
| 5 | 缓存无过期时间 | 检查 Redis 操作 |
| 6 | 无限制查询 | 检查是否有分页/条数限制 |
| 7 | 硬编码敏感信息 | 检查配置管理方式 |
| 8 | 日志打印敏感数据 | 检查日志输出内容 |
| 9 | 未验证输入参数 | 检查参数校验注解 |
| 10 | 资源未关闭 | 检查 try-with-resources |
| 11 | 继承体系使用 @Accessors(chain=true) | 检查 extends + 链式注解 |
| 12 | 测试使用固定 ID 数据 | 检查测试数据生成方式 |
| 13 | 错误码格式不符合规范 | 检查是否为 13 位标准格式 |

---

## 相关章节

- [上一章：代码设计规范](./03-code-design-standards.md)
- [下一章：多级知识空间](./05-knowledge-spaces.md)
- [返回概要](./00-overview.md)
