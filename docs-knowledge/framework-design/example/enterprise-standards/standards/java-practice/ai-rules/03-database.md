# 数据库交互规范 - AI编码约束

> 适用于：数据库操作、SQL编写、MyBatis使用场景

## 一、连接管理规范 [MUST]

### 1.1 连接池选型

```yaml
rules:
  required: HikariCP
  prohibited:
    - C3P0（性能差，已过时）
    - DBCP（性能差）
    - Druid仅用于需要监控场景
```

### 1.2 HikariCP标准配置

```yaml
# application.yml
spring:
  datasource:
    hikari:
      # 连接池大小：CPU核数 * 2 + 磁盘数
      maximum-pool-size: 20
      minimum-idle: 10
      # 连接超时：30秒
      connection-timeout: 30000
      # 空闲超时：10分钟
      idle-timeout: 600000
      # 最大生命周期：30分钟
      max-lifetime: 1800000
      # 连接泄露检测：5秒
      leak-detection-threshold: 5000
      # 连接验证
      connection-test-query: SELECT 1
```

### 1.3 资源释放

```yaml
rules:
  - 必须使用try-with-resources
  - 禁止手动close（易遗漏）
```

```java
// ✅ 正确：try-with-resources
try (Connection conn = dataSource.getConnection();
     PreparedStatement ps = conn.prepareStatement(sql);
     ResultSet rs = ps.executeQuery()) {
    while (rs.next()) {
        // 处理结果
    }
}

// ❌ 错误：手动关闭
Connection conn = null;
try {
    conn = dataSource.getConnection();
    // ...
} finally {
    if (conn != null) conn.close();  // 易遗漏
}
```

## 二、SQL安全规范 [MUST]

### 2.1 防SQL注入

```yaml
rules:
  - MyBatis必须使用#{}，禁止${}
  - JDBC必须使用PreparedStatement
  - 禁止字符串拼接SQL
```

```java
// ✅ 正确：MyBatis #{}
@Select("SELECT * FROM user WHERE id = #{userId}")
User selectById(@Param("userId") Long userId);

// ✅ 正确：MyBatis XML
<select id="selectByName" resultType="User">
    SELECT * FROM user WHERE name = #{name}
</select>

// ❌ 错误：MyBatis ${}（SQL注入风险）
@Select("SELECT * FROM user WHERE name = '${name}'")
User selectByName(@Param("name") String name);

// ❌ 错误：字符串拼接
String sql = "SELECT * FROM user WHERE id = " + userId;
```

### 2.2 ${}仅允许场景

```yaml
allowed_scenarios:
  - 动态表名（需白名单校验）
  - 动态排序字段（需白名单校验）
```

```java
// ✅ 允许：动态表名（需校验）
@Select("SELECT * FROM ${tableName} WHERE id = #{id}")
Object selectByTable(@Param("tableName") String tableName, @Param("id") Long id);

// 调用前必须校验
private static final Set<String> ALLOWED_TABLES = Set.of("order_2024", "order_2025");
if (!ALLOWED_TABLES.contains(tableName)) {
    throw new IllegalArgumentException("非法表名");
}
```

### 2.3 敏感数据处理

```yaml
rules:
  - 密码：禁止明文存储，使用BCrypt
  - 手机号/身份证：加密存储，查询时解密
  - 禁止SELECT *查询敏感字段
```

```java
// ✅ 正确：密码BCrypt加密
user.setPassword(BCrypt.hashpw(rawPassword, BCrypt.gensalt()));

// ✅ 正确：只查询必要字段
@Select("SELECT id, name, status FROM user WHERE id = #{id}")
UserDTO selectBasicById(@Param("id") Long id);

// ❌ 错误：SELECT * 包含密码
@Select("SELECT * FROM user WHERE id = #{id}")
User selectById(@Param("id") Long id);
```

## 三、索引设计规范 [MUST]

### 3.1 索引基本原则

```yaml
rules:
  - 单表索引数量 ≤ 5个
  - 禁止在低基数字段加索引（如性别、状态）
  - WHERE条件字段、JOIN字段、ORDER BY字段优先加索引
  - 字符串前缀索引长度 ≤ 20
```

### 3.2 联合索引设计

```yaml
rules:
  - 遵循最左前缀原则
  - 高选择性字段在前
  - 范围查询字段放最后
```

```sql
-- ✅ 正确：联合索引设计
-- 查询场景：WHERE user_id = ? AND status = ? ORDER BY create_time DESC
CREATE INDEX idx_user_status_time ON order_info(user_id, status, create_time);

-- 索引命中分析：
-- user_id = 1001                        ✅ 命中
-- user_id = 1001 AND status = 1         ✅ 命中
-- status = 1                            ❌ 不命中（缺少最左字段）
-- user_id = 1001 ORDER BY create_time   ✅ 命中
```

### 3.3 索引失效场景

```yaml
avoid:
  - 对索引列使用函数：WHERE DATE(create_time) = '2024-01-01'
  - 对索引列进行计算：WHERE id + 1 = 100
  - 使用 != 或 <>
  - LIKE左模糊：WHERE name LIKE '%张'
  - OR连接非索引字段
  - 隐式类型转换：WHERE varchar_id = 123（应为'123'）
```

```sql
-- ❌ 错误：函数导致索引失效
SELECT * FROM order_info WHERE DATE(create_time) = '2024-01-01';

-- ✅ 正确：范围查询
SELECT * FROM order_info
WHERE create_time >= '2024-01-01 00:00:00'
  AND create_time < '2024-01-02 00:00:00';

-- ❌ 错误：LIKE左模糊
SELECT * FROM user WHERE name LIKE '%张';

-- ✅ 正确：LIKE右模糊
SELECT * FROM user WHERE name LIKE '张%';
```

### 3.4 标准表索引示例

```sql
CREATE TABLE `order_info` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '订单ID',
    `order_no` varchar(64) NOT NULL COMMENT '订单号',
    `user_id` bigint NOT NULL COMMENT '用户ID',
    `amount` decimal(10,2) NOT NULL COMMENT '订单金额',
    `status` tinyint NOT NULL COMMENT '订单状态',
    `create_time` datetime NOT NULL COMMENT '创建时间',
    `update_time` datetime NOT NULL COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_order_no` (`order_no`),
    KEY `idx_user_create` (`user_id`, `create_time`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';
```

## 四、MyBatis使用规范 [MUST]

### 4.1 结果映射

```yaml
rules:
  - 必须使用ResultMap，禁止resultType="map"
  - 字段与属性映射必须显式声明
```

```xml
<!-- ✅ 正确：ResultMap -->
<resultMap id="OrderResultMap" type="com.example.entity.Order">
    <id column="id" property="id"/>
    <result column="order_no" property="orderNo"/>
    <result column="user_id" property="userId"/>
    <result column="create_time" property="createTime"/>
</resultMap>

<select id="selectById" resultMap="OrderResultMap">
    SELECT id, order_no, user_id, create_time FROM order_info WHERE id = #{id}
</select>

<!-- ❌ 错误：resultType="map" -->
<select id="selectById" resultType="map">
    SELECT * FROM order_info WHERE id = #{id}
</select>
```

### 4.2 动态SQL

```yaml
rules:
  - 复杂逻辑移至Java层
  - 禁止深层嵌套（超过3层）
```

```xml
<!-- ✅ 正确：简单动态SQL -->
<select id="selectByCondition" resultMap="OrderResultMap">
    SELECT id, order_no, user_id, create_time FROM order_info
    <where>
        <if test="userId != null">AND user_id = #{userId}</if>
        <if test="status != null">AND status = #{status}</if>
        <if test="startTime != null">AND create_time >= #{startTime}</if>
    </where>
    ORDER BY create_time DESC
</select>
```

### 4.3 批量操作

```yaml
rules:
  - 批量插入使用foreach
  - 单批次数量 ≤ 500
  - 开启rewriteBatchedStatements
```

```yaml
# 数据源配置
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/db?rewriteBatchedStatements=true
```

```xml
<!-- ✅ 正确：批量插入 -->
<insert id="batchInsert">
    INSERT INTO order_info (order_no, user_id, amount, status, create_time)
    VALUES
    <foreach collection="list" item="item" separator=",">
        (#{item.orderNo}, #{item.userId}, #{item.amount}, #{item.status}, #{item.createTime})
    </foreach>
</insert>
```

```java
// ✅ 正确：分批处理
public void batchInsertOrders(List<Order> orders) {
    int batchSize = 500;
    for (int i = 0; i < orders.size(); i += batchSize) {
        List<Order> batch = orders.subList(i, Math.min(i + batchSize, orders.size()));
        orderMapper.batchInsert(batch);
    }
}
```

## 五、事务规范 [MUST]

### 5.1 事务边界

```yaml
rules:
  - 事务仅加在Service层
  - 禁止Controller层加事务
  - 禁止Dao层加事务
  - 必须指定rollbackFor
```

```java
// ✅ 正确：Service层事务
@Service
public class OrderServiceImpl implements OrderService {

    @Transactional(rollbackFor = Exception.class)
    public Long createOrder(OrderCreateRequest request) {
        // 1. 创建订单
        Order order = buildOrder(request);
        orderMapper.insert(order);

        // 2. 扣减库存
        stockService.decrease(request.getProductId(), request.getQuantity());

        // 3. 记录日志
        orderLogMapper.insert(buildLog(order));

        return order.getId();
    }
}

// ❌ 错误：Controller层加事务
@RestController
public class OrderController {
    @Transactional  // 禁止
    @PostMapping("/orders")
    public Result<Long> createOrder(@RequestBody OrderRequest request) {
        // ...
    }
}
```

### 5.2 事务传播行为

```yaml
common_propagation:
  - REQUIRED（默认）：当前有事务加入，没有则新建
  - REQUIRES_NEW：挂起当前事务，新建独立事务
  - NESTED：嵌套事务，外部回滚则回滚
```

```java
// 场景：订单创建失败不影响日志记录
@Service
public class OrderServiceImpl {

    @Transactional(rollbackFor = Exception.class)
    public Long createOrder(OrderCreateRequest request) {
        Order order = buildOrder(request);
        orderMapper.insert(order);

        // 日志记录独立事务，订单回滚不影响日志
        try {
            logService.recordOrderLog(order);
        } catch (Exception e) {
            log.error("日志记录失败", e);
            // 不抛出，不影响主事务
        }

        return order.getId();
    }
}

@Service
public class LogServiceImpl {

    @Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
    public void recordOrderLog(Order order) {
        // 独立事务
        orderLogMapper.insert(buildLog(order));
    }
}
```

### 5.3 事务禁止项

```yaml
prohibited:
  - 事务内调用第三方接口
  - 事务内进行文件上传
  - 事务内发送MQ消息（改用事务消息）
  - 长事务（执行时间>5秒）
```

```java
// ❌ 错误：事务内调用外部服务
@Transactional(rollbackFor = Exception.class)
public void createOrder(OrderRequest request) {
    orderMapper.insert(order);
    paymentService.pay(order);  // 外部HTTP调用，可能超时
    notificationService.send(order);  // 外部调用
}

// ✅ 正确：事务外调用外部服务
@Transactional(rollbackFor = Exception.class)
public Long createOrder(OrderRequest request) {
    orderMapper.insert(order);
    return order.getId();
}

public void processOrder(OrderRequest request) {
    Long orderId = createOrder(request);  // 事务内
    paymentService.pay(orderId);  // 事务外
    notificationService.send(orderId);  // 事务外
}
```

## 六、高并发规范 [SHOULD]

### 6.1 乐观锁

```yaml
scenario: 并发更新同一记录
solution: 版本号乐观锁
```

```sql
-- 表结构
ALTER TABLE order_info ADD COLUMN version INT DEFAULT 0;
```

```java
// MyBatis-Plus乐观锁
@Version
private Integer version;

// 手动实现
@Update("UPDATE order_info SET status = #{status}, version = version + 1 " +
        "WHERE id = #{id} AND version = #{version}")
int updateWithVersion(@Param("id") Long id,
                      @Param("status") Integer status,
                      @Param("version") Integer version);

// 业务代码
public void updateOrderStatus(Long orderId, Integer newStatus) {
    Order order = orderMapper.selectById(orderId);
    int affected = orderMapper.updateWithVersion(orderId, newStatus, order.getVersion());
    if (affected == 0) {
        throw new ConcurrentModificationException("数据已被修改，请重试");
    }
}
```

### 6.2 分页查询

```yaml
rules:
  - 禁止无分页的全表查询
  - 深度分页使用游标
```

```java
// ✅ 正确：分页查询
PageHelper.startPage(pageNum, pageSize);
List<Order> orders = orderMapper.selectByUserId(userId);
PageInfo<Order> pageInfo = new PageInfo<>(orders);

// ✅ 正确：深度分页优化（游标分页）
@Select("SELECT * FROM order_info WHERE id > #{lastId} AND user_id = #{userId} " +
        "ORDER BY id LIMIT #{limit}")
List<Order> selectByUserIdWithCursor(@Param("userId") Long userId,
                                      @Param("lastId") Long lastId,
                                      @Param("limit") Integer limit);

// ❌ 错误：无分页全表查询
List<Order> allOrders = orderMapper.selectAll();
```

## 七、反模式检查清单

| 序号 | 反模式 | 检测方式 |
|------|--------|----------|
| 1 | MyBatis使用${} | 检查Mapper XML和注解 |
| 2 | SELECT * | 检查SQL语句 |
| 3 | 无索引的WHERE条件 | 检查大表查询 |
| 4 | 事务加在非Service层 | 检查@Transactional位置 |
| 5 | 未指定rollbackFor | 检查@Transactional注解 |
| 6 | 批量操作无分批 | 检查循环insert |
| 7 | 无分页的列表查询 | 检查selectList无limit |
| 8 | 低基数字段加索引 | 检查索引设计 |
| 9 | 联合索引字段顺序错误 | 检查查询条件与索引匹配 |
| 10 | 事务内调用外部服务 | 检查事务方法内的HTTP调用 |
