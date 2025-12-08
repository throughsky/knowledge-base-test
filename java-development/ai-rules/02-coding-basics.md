# 基础编码规范 - AI编码约束

> 适用于：所有Java代码生成场景

## 一、命名规范 [MUST]

### 1.1 类/接口/枚举命名

```yaml
rules:
  format: UpperCamelCase（大驼峰）
  requirements:
    - 名词或名词短语
    - 体现"业务域+角色"
    - 禁止拼音/拼音英文混合
    - 禁止无意义缩写
```

| 类型 | 格式 | 正确示例 | 错误示例 |
|------|------|----------|----------|
| 普通类 | `XxxYyy` | `OrderService` | `orderservice` |
| 接口 | `XxxYyy` | `PaymentGateway` | `IPayment` |
| 实现类 | `XxxYyyImpl` | `OrderServiceImpl` | `OrderServiceImp` |
| 抽象类 | `AbstractXxx` | `AbstractValidator` | `BaseValidator` |
| 枚举 | `XxxEnum` | `OrderStatusEnum` | `OrderStatus` |
| 异常 | `XxxException` | `OrderNotFoundException` | `OrderError` |
| DTO | `XxxDTO` | `UserDTO` | `UserDto` |
| VO | `XxxVO` | `OrderVO` | `OrderVo` |
| DO/Entity | `XxxDO`/`Xxx` | `OrderDO` | `TOrder` |

### 1.2 方法命名

```yaml
rules:
  format: lowerCamelCase（小驼峰）
  structure: 动词 + 名词
  requirements:
    - 动词开头
    - 明确语义
    - 禁止数字后缀（get1, get2）
```

| 动词前缀 | 适用场景 | 示例 |
|----------|----------|------|
| `get` | 简单查询（单条） | `getUserById(Long userId)` |
| `query` | 复杂查询（多条件/分页） | `queryOrdersByCondition(OrderQuery query)` |
| `find` | 查找（可能返回null/集合） | `findActiveUsers()` |
| `list` | 返回集合 | `listOrdersByUserId(Long userId)` |
| `create` | 新建（无ID） | `createOrder(OrderDTO dto)` |
| `save` | 保存（有ID更新，无ID新增） | `saveUser(UserDTO dto)` |
| `update` | 更新指定字段 | `updateOrderStatus(Long id, Integer status)` |
| `delete`/`remove` | 删除 | `deleteById(Long id)` |
| `validate` | 校验 | `validateParams(Request req)` |
| `calculate` | 计算 | `calculateTotalAmount(List<Item> items)` |
| `convert`/`to` | 转换 | `convertToDTO(Entity entity)` |
| `is`/`has`/`can` | 布尔判断 | `isValid()`, `hasPermission()` |

### 1.3 变量命名

```yaml
rules:
  format: lowerCamelCase（小驼峰）
  requirements:
    - 禁止单字母（循环变量i/j/k除外）
    - 禁止拼音
    - 语义明确
```

```java
// ❌ 错误
int a = 100;
String str = "test";
List list = new ArrayList();
User u = getUser();

// ✅ 正确
int maxRetryCount = 100;
String userName = "test";
List<Order> orderList = new ArrayList<>();
User currentUser = getUser();
```

### 1.4 常量命名

```yaml
rules:
  format: UPPER_SNAKE_CASE（全大写+下划线）
  requirements:
    - 必须加final修饰
    - 类顶部集中定义
    - 语义完整
```

```java
// ✅ 正确
public static final int MAX_RETRY_COUNT = 3;
public static final String DEFAULT_CHARSET = "UTF-8";
public static final long CACHE_EXPIRE_SECONDS = 3600L;

// ❌ 错误
public static int maxRetry = 3;  // 缺少final
public static final int MAX = 3;  // 语义不完整
```

### 1.5 包命名

```yaml
rules:
  format: 全小写，点号分隔
  structure: com.公司.项目.模块.层级
  requirements:
    - 禁止大写字母
    - 禁止下划线
```

```
✅ 正确结构：
com.company.mall.order.service
com.company.mall.order.controller
com.company.mall.order.mapper
com.company.mall.order.dto
com.company.mall.common.utils

❌ 错误结构：
com.company.Mall.order  // 大写
com.company.mall_order  // 下划线
```

## 二、注释规范 [MUST]

### 2.1 类/接口注释

```java
/**
 * 订单服务实现类
 * <p>
 * 处理订单创建、查询、状态变更等核心业务逻辑
 * 依赖：UserService、ProductService、PaymentService
 * </p>
 *
 * @author zhangsan
 * @since 2024-01-01
 * @see OrderMapper
 */
@Service
public class OrderServiceImpl implements OrderService {
    // ...
}
```

### 2.2 方法注释

```yaml
rules:
  - 复杂方法必须写注释
  - 公开API方法必须写注释
  - 包含：功能描述、参数说明、返回值、异常
```

```java
/**
 * 创建订单
 * <p>
 * 业务流程：参数校验 → 库存检查 → 创建订单 → 扣减库存 → 发送消息
 * </p>
 *
 * @param request 订单创建请求，包含用户ID、商品列表、收货地址
 * @return 创建成功的订单ID
 * @throws IllegalArgumentException 参数校验失败
 * @throws InsufficientStockException 库存不足
 * @throws OrderCreateException 订单创建失败
 */
public Long createOrder(OrderCreateRequest request) {
    // ...
}
```

### 2.3 代码块注释

```yaml
rules:
  - 说明"为什么"而非"做什么"
  - 复杂逻辑必须注释
```

```java
// ✅ 正确：说明业务原因
// 订单超过30天未支付，自动关闭（业务规则：防止库存长期占用）
if (order.getCreateTime().plusDays(30).isBefore(LocalDateTime.now())) {
    closeOrder(order);
}

// ❌ 错误：重复代码逻辑
// 如果创建时间加30天在当前时间之前
if (order.getCreateTime().plusDays(30).isBefore(LocalDateTime.now())) {
    closeOrder(order);
}
```

### 2.4 注释禁止项

```yaml
prohibited:
  - 注释掉的代码块（删除而非注释）
  - 过时的注释（代码改了注释没改）
  - 无意义的注释（如：// 获取用户）
  - TODO后无责任人和时间
```

```java
// ❌ 禁止
// User user = userService.getById(id);  // 注释掉的代码
// TODO: 待优化  // 无责任人

// ✅ 正确
// TODO(zhangsan): 2024-02-01 优化N+1查询问题
```

## 三、语法避坑规范 [MUST]

### 3.1 集合使用

```yaml
rules:
  - 指定初始容量
  - 指定泛型类型
  - 遍历删除用Iterator
  - 多线程用并发容器
```

```java
// ✅ 正确：指定容量和泛型
List<User> userList = new ArrayList<>(100);
Map<Long, Order> orderMap = new HashMap<>(16);
Set<String> tagSet = new HashSet<>(8);

// ✅ 正确：遍历删除
Iterator<User> iterator = userList.iterator();
while (iterator.hasNext()) {
    if (iterator.next().isInvalid()) {
        iterator.remove();
    }
}

// ✅ 正确：多线程场景
Map<Long, User> concurrentMap = new ConcurrentHashMap<>();
List<String> threadSafeList = new CopyOnWriteArrayList<>();

// ❌ 错误
List list = new ArrayList();  // 无泛型
Map map = new HashMap();  // 无容量无泛型
for (User user : userList) {  // 遍历中删除
    if (user.isInvalid()) userList.remove(user);
}
```

### 3.2 异常处理

```yaml
rules:
  - 禁止吞异常
  - 禁止用e.printStackTrace()
  - 明确异常类型
  - 异常信息包含上下文
```

```java
// ✅ 正确
try {
    orderService.createOrder(request);
} catch (InsufficientStockException e) {
    log.warn("库存不足, productId={}, required={}",
             e.getProductId(), e.getRequiredQuantity());
    throw new BusinessException("库存不足，请稍后重试");
} catch (Exception e) {
    log.error("创建订单失败, userId={}, request={}",
              userId, JSON.toJSONString(request), e);
    throw new SystemException("系统繁忙，请稍后重试");
}

// ❌ 错误
try {
    orderService.createOrder(request);
} catch (Exception e) {
    // 吞异常
}
try {
    orderService.createOrder(request);
} catch (Exception e) {
    e.printStackTrace();  // 禁止
}
```

### 3.3 空值处理

```yaml
rules:
  - 使用Optional替代多层判空
  - 集合返回空集合而非null
  - 字符串判空用StringUtils
```

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

// ✅ 正确：字符串判空
if (StringUtils.isNotBlank(userName)) {
    // ...
}

// ❌ 错误：多层判空
if (user != null && user.getAddress() != null
    && user.getAddress().getCity() != null) {
    // ...
}
```

### 3.4 字符串拼接

```yaml
rules:
  - 循环中禁止用+号拼接
  - 使用StringBuilder或String.format
```

```java
// ✅ 正确
StringBuilder sb = new StringBuilder();
for (String item : items) {
    sb.append(item).append(",");
}

String message = String.format("用户%s创建订单%d成功", userName, orderId);

// ❌ 错误
String result = "";
for (String item : items) {
    result += item + ",";  // 性能差
}
```

### 3.5 equals比较

```yaml
rules:
  - 常量在前，变量在后
  - 使用Objects.equals
```

```java
// ✅ 正确
if ("ACTIVE".equals(status)) { }
if (Objects.equals(status, targetStatus)) { }

// ❌ 错误（可能NPE）
if (status.equals("ACTIVE")) { }
```

## 四、参数校验规范 [MUST]

### 4.1 使用JSR303注解

```java
@Data
public class OrderCreateRequest {

    @NotNull(message = "用户ID不能为空")
    private Long userId;

    @NotEmpty(message = "商品列表不能为空")
    @Size(min = 1, max = 100, message = "商品数量1-100件")
    private List<OrderItemDTO> items;

    @NotNull(message = "订单金额不能为空")
    @DecimalMin(value = "0.01", message = "订单金额必须大于0")
    private BigDecimal amount;

    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
    private String phone;

    @Email(message = "邮箱格式不正确")
    private String email;
}
```

### 4.2 Controller层启用校验

```java
@PostMapping("/orders")
public Result<Long> createOrder(@Valid @RequestBody OrderCreateRequest request) {
    // 参数校验由框架自动完成
    return Result.success(orderService.createOrder(request));
}
```

### 4.3 业务校验（跨服务/数据库）

```java
public Long createOrder(OrderCreateRequest request) {
    // 1. 用户存在性校验
    User user = userService.getById(request.getUserId());
    if (user == null) {
        throw new BusinessException("用户不存在");
    }

    // 2. 库存校验
    for (OrderItemDTO item : request.getItems()) {
        Integer stock = productService.getStock(item.getProductId());
        if (stock < item.getQuantity()) {
            throw new BusinessException("商品库存不足: " + item.getProductId());
        }
    }

    // 3. 业务逻辑...
}
```

## 五、反模式检查清单

AI生成代码时，必须检查以下反模式：

| 序号 | 反模式 | 检测方式 |
|------|--------|----------|
| 1 | 类名用小驼峰 | 检查class声明 |
| 2 | 变量用单字母/拼音 | 检查变量名 |
| 3 | 常量未加final | 检查static变量 |
| 4 | 集合不指定容量和泛型 | 检查new ArrayList/HashMap |
| 5 | 吞异常或e.printStackTrace() | 检查catch块 |
| 6 | 字符串用==比较 | 检查String比较 |
| 7 | 循环中用+拼接字符串 | 检查for循环内的字符串操作 |
| 8 | 多层if判空 | 检查嵌套null判断 |
| 9 | 方法入参未校验 | 检查公开方法首行 |
| 10 | 注释掉的代码块 | 检查多行注释内的代码 |
