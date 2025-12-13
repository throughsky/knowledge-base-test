# 企业级知识库(L0)补充建议文档

> 生成日期: 2025-12-12
> 对比来源: enterprise-standards/ vs ai-rules/
> 目的: 识别企业知识库缺失内容，提供补充建议

---

## 一、整体评估矩阵

### 1.1 覆盖度对比

| 领域 | enterprise-standards | ai-rules | 覆盖度 | 优先级 |
|------|---------------------|----------|--------|--------|
| 技术宪法/架构原则 | constitution/ | 01-overview | ✅ 100% | - |
| 安全基线 | security-baseline.md | 08-security | ✅ 95% | 🟢 低 |
| 合规要求 | compliance-requirements.md | 12-compliance | ✅ 90% | 🟢 低 |
| 编码基础 | java.md | 02-coding-basics | ✅ 85% | 🟢 低 |
| API设计 | api-design-guide.md | 05-api-design | ✅ 90% | 🟢 低 |
| 测试规范 | testing-standards.md | 09-testing | ✅ 85% | 🟢 低 |
| 发布流程 | release-process.md | 10-deployment | ✅ 80% | 🟢 低 |
| 代码评审 | review-process.md | 13-team-collaboration | ✅ 75% | 🟡 中 |
| 技术雷达 | technology-radar/ | - | ✅ 100% | - |
| AI编码策略 | ai-coding-policy.md | 01-overview | ✅ 90% | - |
| **数据库规范** | ⚠️ 分散在java.md | 03-database | ❌ 40% | 🔴 高 |
| **缓存规范** | ❌ 无 | 04-cache | ❌ 0% | 🔴 高 |
| **微服务治理** | ⚠️ 概念级 | 06-microservice | ❌ 30% | 🔴 高 |
| **并发编程** | ⚠️ 基础级 | 07-concurrency | ❌ 45% | 🟡 中 |
| **数据治理** | ❌ 无 | 11-data-governance | ❌ 0% | 🔴 高 |

### 1.2 优先级说明

- 🔴 **高优先级**: 生产环境必备，缺失可能导致严重问题
- 🟡 **中优先级**: 提升代码质量和可维护性
- 🟢 **低优先级**: 锦上添花，可后续迭代

---

## 二、🔴 高优先级 - 建议新增文件

### 2.1 新增 `standards/cache-standards.md`

**来源**: ai-rules/04-cache.md

**必要性**: 缓存是高并发系统核心组件，缺失规范会导致：
- 缓存穿透导致数据库被打垮
- 缓存击穿导致热点Key失效时的流量洪峰
- 缓存雪崩导致大面积服务不可用
- 缓存与数据库不一致导致业务错误

**建议内容结构**:

```markdown
# 缓存使用规范

## 1. 缓存类型选择 [MUST]

### 1.1 选型矩阵

| 场景 | 并发量 | 数据规模 | 推荐方案 |
|------|--------|----------|----------|
| 低并发 | <1000 QPS | <10K条 | Caffeine 本地缓存 |
| 高并发 | ≥1000 QPS | >10K条 | Redis 分布式缓存 |
| 超高并发 | ≥10K QPS | 热点数据 | 多级缓存(本地+Redis) |

### 1.2 本地缓存配置示例
```java
@Bean
public Cache<String, Object> localCache() {
    return Caffeine.newBuilder()
        .maximumSize(10_000)           // 最大条目数
        .expireAfterWrite(5, TimeUnit.MINUTES)  // 写后过期
        .recordStats()                 // 开启统计
        .build();
}
```

## 2. 三大缓存风险防护 [MUST]

### 2.1 缓存穿透防护（查询不存在的数据）

**方案一：缓存空值**
```java
public User getUser(Long userId) {
    String key = "user:info:" + userId;
    User user = redis.get(key);
    if (user != null) {
        return user.getId() == null ? null : user;  // 空对象标记
    }

    user = userMapper.selectById(userId);
    if (user == null) {
        // 缓存空值，短TTL防止长期占用
        redis.setex(key, 300, new User());  // 5分钟
    } else {
        redis.setex(key, 1800, user);  // 30分钟
    }
    return user;
}
```

**方案二：布隆过滤器（海量数据场景）**
```java
@PostConstruct
public void initBloomFilter() {
    RBloomFilter<Long> bloomFilter = redisson.getBloomFilter("user:bloom");
    bloomFilter.tryInit(1_000_000L, 0.01);  // 100万容量，1%误判率

    // 预热已有用户ID
    userMapper.selectAllIds().forEach(bloomFilter::add);
}

public User getUser(Long userId) {
    // 布隆过滤器前置检查
    if (!bloomFilter.contains(userId)) {
        return null;  // 一定不存在
    }
    // 正常缓存查询逻辑...
}
```

### 2.2 缓存击穿防护（热点Key过期瞬间）

**方案一：分布式互斥锁**
```java
public User getUser(Long userId) {
    String key = "user:info:" + userId;
    User user = redis.get(key);
    if (user != null) return user;

    String lockKey = "lock:user:" + userId;
    RLock lock = redisson.getLock(lockKey);
    try {
        // 等待获取锁，最多等3秒，锁自动释放10秒
        if (lock.tryLock(3, 10, TimeUnit.SECONDS)) {
            // 双重检查
            user = redis.get(key);
            if (user != null) return user;

            user = userMapper.selectById(userId);
            redis.setex(key, 1800, user);
            return user;
        }
    } finally {
        if (lock.isHeldByCurrentThread()) {
            lock.unlock();
        }
    }
    // 未获取到锁，返回降级数据或抛异常
    throw new ServiceException("系统繁忙，请稍后重试");
}
```

**方案二：逻辑过期（永不真正过期）**
```java
@Data
public class CacheWrapper<T> {
    private T data;
    private LocalDateTime logicalExpireTime;  // 逻辑过期时间
}

public User getUser(Long userId) {
    String key = "user:info:" + userId;
    CacheWrapper<User> wrapper = redis.get(key);

    if (wrapper == null) {
        // 缓存未命中，同步加载
        return loadAndCache(userId);
    }

    if (wrapper.getLogicalExpireTime().isBefore(LocalDateTime.now())) {
        // 逻辑过期，异步刷新
        asyncRefreshExecutor.submit(() -> loadAndCache(userId));
    }

    return wrapper.getData();  // 返回旧数据，不阻塞
}
```

### 2.3 缓存雪崩防护（大量Key同时过期）

**方案：TTL随机化**
```java
public void cacheUser(User user) {
    String key = "user:info:" + user.getId();
    // 基础TTL 30分钟 + 随机0-5分钟
    int baseTtl = 1800;
    int randomTtl = ThreadLocalRandom.current().nextInt(0, 300);
    redis.setex(key, baseTtl + randomTtl, user);
}
```

## 3. 缓存一致性策略 [MUST]

### 3.1 读写策略

```
读操作：缓存 → 未命中 → 数据库 → 回写缓存
写操作：更新数据库 → 删除缓存（不是更新缓存！）
```

**为什么删除而不是更新？**
- 避免并发写导致的数据不一致
- 避免缓存计算逻辑重复
- 惰性加载，节省不必要的缓存更新

### 3.2 高并发场景：延迟双删

```java
@Transactional
public void updateUser(User user) {
    // 1. 删除缓存
    redis.del("user:info:" + user.getId());

    // 2. 更新数据库
    userMapper.updateById(user);

    // 3. 延迟再次删除（防止并发读写导致脏数据回写）
    asyncDeleteExecutor.schedule(() -> {
        redis.del("user:info:" + user.getId());
    }, 500, TimeUnit.MILLISECONDS);
}
```

## 4. Redis Key 命名规范 [MUST]

### 4.1 命名格式

```
{域}:{模块}:{资源}:{标识}
```

**示例**:
```
mall:user:info:1001          # 用户信息
mall:order:detail:3001       # 订单详情
mall:product:stock:2001      # 商品库存
mall:cart:items:1001         # 购物车
```

### 4.2 命名规则

| 规则 | 说明 | 正例 | 反例 |
|------|------|------|------|
| 小写字母 | 统一小写 | `user:info` | `User:Info` |
| 冒号分隔 | 层级分隔符 | `user:info:1001` | `user_info_1001` |
| 长度限制 | ≤128字节 | `mall:user:info:1001` | 超长Key |
| 语义清晰 | 可读性强 | `order:detail` | `od` |

## 5. 大Key预防 [MUST]

### 5.1 大Key定义

| 数据类型 | 大Key阈值 |
|----------|-----------|
| String | >100KB |
| Hash/List/Set/ZSet | >5000元素 |

### 5.2 解决方案

**水平拆分**:
```java
// 原始：一个Key存所有用户签到记录
// mall:signin:records:1001 → 365条记录

// 拆分：按月分Key
// mall:signin:records:1001:202501 → 31条记录
// mall:signin:records:1001:202502 → 28条记录
```

**分页读取**:
```java
// 禁止：一次性获取所有元素
Set<String> all = redis.smembers("large:set");  // ❌

// 正确：使用SCAN分批获取
ScanOptions options = ScanOptions.scanOptions().count(100).build();
Cursor<String> cursor = redis.sscan("large:set", options);
while (cursor.hasNext()) {
    String item = cursor.next();
    // 处理单个元素
}
```

## 6. 分布式锁规范 [MUST]

### 6.1 Redisson 标准用法

```java
public void doBusinessWithLock(String bizId) {
    String lockKey = "lock:business:" + bizId;
    RLock lock = redisson.getLock(lockKey);

    try {
        // 尝试加锁：等待时间3秒，锁持有时间30秒
        boolean acquired = lock.tryLock(3, 30, TimeUnit.SECONDS);
        if (!acquired) {
            throw new ServiceException("操作频繁，请稍后重试");
        }

        // 执行业务逻辑
        doBusiness(bizId);

    } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
        throw new ServiceException("操作被中断");
    } finally {
        // 只有当前线程持有锁才能释放
        if (lock.isHeldByCurrentThread()) {
            lock.unlock();
        }
    }
}
```

### 6.2 禁止模式

```java
// ❌ 禁止：不设置等待时间（可能永久阻塞）
lock.lock();

// ❌ 禁止：不检查锁持有者直接释放
lock.unlock();

// ❌ 禁止：手动实现分布式锁（用SETNX）
redis.setnx("lock:key", "value");
```

## 7. 数据类型选择 [SHOULD]

| 数据类型 | 适用场景 | 示例 |
|----------|----------|------|
| String | 简单KV、计数器 | 用户Token、接口限流计数 |
| Hash | 对象存储、部分字段更新 | 用户信息、商品详情 |
| List | 队列、最新N条记录 | 消息队列、最近浏览 |
| Set | 去重、集合运算 | 标签、共同好友 |
| ZSet | 排行榜、延时队列 | 热销榜、订单超时 |
| BitMap | 签到、布尔状态 | 用户签到记录 |

## 8. 监控与告警 [SHOULD]

### 8.1 关键指标

| 指标 | 阈值 | 告警级别 |
|------|------|----------|
| 缓存命中率 | <80% | Warning |
| 缓存命中率 | <60% | Critical |
| 内存使用率 | >80% | Warning |
| 连接数 | >80%最大连接 | Warning |
| 慢查询 | >10ms | Warning |

### 8.2 大Key扫描（定期执行）

```bash
# 扫描大Key
redis-cli --bigkeys

# 内存分析
redis-cli memory doctor
```
```

---

### 2.2 新增 `standards/database-standards.md`

**来源**: ai-rules/03-database.md

**必要性**: 当前数据库规范分散在 java.md 中，缺乏系统性。缺失会导致：
- 连接池配置不当导致连接耗尽
- 索引设计不合理导致慢查询
- 事务边界不清导致数据不一致
- 批量操作不当导致内存溢出

**建议内容结构**:

```markdown
# 数据库使用规范

## 1. 连接池配置 [MUST]

### 1.1 HikariCP 强制使用

```yaml
spring:
  datasource:
    hikari:
      # 最大连接数 = CPU核心数 × 2 + 磁盘数（通常SSD按1计算）
      # 8核CPU + 1 SSD = 8 × 2 + 1 = 17
      maximum-pool-size: 17

      # 最小空闲连接 = CPU核心数
      minimum-idle: 8

      # 连接超时：30秒
      connection-timeout: 30000

      # 空闲超时：10分钟
      idle-timeout: 600000

      # 连接最大生命周期：30分钟（必须小于数据库wait_timeout）
      max-lifetime: 1800000

      # 连接泄漏检测：5秒
      leak-detection-threshold: 5000

      # 连接测试查询
      connection-test-query: SELECT 1
```

### 1.2 配置公式

```
maxPoolSize = CPU_cores × 2 + disk_count
minimumIdle = CPU_cores
```

## 2. SQL 安全规范 [MUST]

### 2.1 参数化查询（强制）

**MyBatis**:
```xml
<!-- ✅ 正确：使用 #{} 参数化 -->
<select id="selectUser" resultType="User">
    SELECT * FROM user WHERE id = #{id} AND status = #{status}
</select>

<!-- ❌ 禁止：使用 ${} 字符串拼接 -->
<select id="selectUser" resultType="User">
    SELECT * FROM user WHERE id = ${id}
</select>
```

**${} 唯一允许场景**（必须配合白名单）:
```java
// 动态表名、排序字段（必须白名单校验）
public List<Order> queryOrders(String tableSuffix, String sortField) {
    // 白名单校验
    Set<String> allowedTables = Set.of("order_2024", "order_2025");
    Set<String> allowedSorts = Set.of("create_time", "amount");

    if (!allowedTables.contains("order_" + tableSuffix)) {
        throw new IllegalArgumentException("非法表名");
    }
    if (!allowedSorts.contains(sortField)) {
        throw new IllegalArgumentException("非法排序字段");
    }

    return orderMapper.selectByDynamicTable(tableSuffix, sortField);
}
```

### 2.2 JDBC PreparedStatement

```java
// ✅ 正确
String sql = "SELECT * FROM user WHERE id = ? AND status = ?";
PreparedStatement ps = conn.prepareStatement(sql);
ps.setLong(1, userId);
ps.setInt(2, status);

// ❌ 禁止
String sql = "SELECT * FROM user WHERE id = " + userId;
Statement stmt = conn.createStatement();
stmt.executeQuery(sql);
```

## 3. 索引设计规范 [MUST]

### 3.1 基本规则

| 规则 | 说明 |
|------|------|
| 单表索引数量 | ≤5个（含主键） |
| 组合索引字段数 | ≤5个 |
| 索引选择性 | 避免低区分度字段（如 status、gender） |
| 最左前缀 | 组合索引遵循最左匹配原则 |

### 3.2 组合索引顺序

```sql
-- 原则：区分度高的字段放前面

-- ✅ 正确：user_id 区分度高，status 区分度低
CREATE INDEX idx_user_status ON orders(user_id, status);

-- 查询能命中索引
SELECT * FROM orders WHERE user_id = 1001 AND status = 1;
SELECT * FROM orders WHERE user_id = 1001;

-- 查询无法命中索引（跳过了最左字段）
SELECT * FROM orders WHERE status = 1;
```

### 3.3 索引失效场景

```sql
-- ❌ 函数作用于索引列
SELECT * FROM user WHERE DATE(create_time) = '2025-01-01';
-- ✅ 改为范围查询
SELECT * FROM user WHERE create_time >= '2025-01-01' AND create_time < '2025-01-02';

-- ❌ 隐式类型转换
SELECT * FROM user WHERE phone = 13800138000;  -- phone是VARCHAR
-- ✅ 使用正确类型
SELECT * FROM user WHERE phone = '13800138000';

-- ❌ 前模糊匹配
SELECT * FROM user WHERE name LIKE '%张';
-- ✅ 后模糊可以命中
SELECT * FROM user WHERE name LIKE '张%';

-- ❌ OR 连接非索引字段
SELECT * FROM user WHERE id = 1 OR name = '张三';
-- ✅ 使用 UNION ALL
SELECT * FROM user WHERE id = 1
UNION ALL
SELECT * FROM user WHERE name = '张三' AND id != 1;
```

## 4. 事务规范 [MUST]

### 4.1 事务边界

```java
// ✅ @Transactional 只能在 Service 层
@Service
public class OrderService {

    @Transactional(rollbackFor = Exception.class)  // 必须指定 rollbackFor
    public void createOrder(OrderDTO dto) {
        // 业务逻辑
    }
}

// ❌ 禁止在 Controller 层
@RestController
public class OrderController {
    @Transactional  // 禁止！
    public Result createOrder() { }
}
```

### 4.2 事务内禁止操作

```java
@Transactional(rollbackFor = Exception.class)
public void createOrder(OrderDTO dto) {
    orderMapper.insert(order);

    // ❌ 禁止：事务内调用外部HTTP服务
    httpClient.post("http://external-service/notify", dto);

    // ❌ 禁止：事务内发送MQ消息
    rabbitTemplate.send("order.created", order);

    // ❌ 禁止：事务内上传文件
    ossClient.upload(file);
}

// ✅ 正确做法：事务提交后执行
@Transactional(rollbackFor = Exception.class)
public void createOrder(OrderDTO dto) {
    orderMapper.insert(order);
}

@TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
public void onOrderCreated(OrderCreatedEvent event) {
    // 事务提交后发送通知
    rabbitTemplate.send("order.created", event.getOrder());
}
```

### 4.3 事务超时与传播

```java
// 事务超时：默认5秒
@Transactional(rollbackFor = Exception.class, timeout = 5)
public void createOrder(OrderDTO dto) { }

// 独立事务（如审计日志，不受主事务回滚影响）
@Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
public void saveAuditLog(AuditLog log) { }
```

## 5. 高并发场景 [MUST]

### 5.1 乐观锁

```java
// 实体类
@Data
public class Product {
    private Long id;
    private Integer stock;
    @Version
    private Integer version;  // 乐观锁版本号
}

// Mapper
@Update("UPDATE product SET stock = stock - #{quantity}, version = version + 1 " +
        "WHERE id = #{id} AND version = #{version} AND stock >= #{quantity}")
int decreaseStock(@Param("id") Long id,
                  @Param("quantity") Integer quantity,
                  @Param("version") Integer version);

// Service
public void decreaseStock(Long productId, Integer quantity) {
    Product product = productMapper.selectById(productId);
    int affected = productMapper.decreaseStock(productId, quantity, product.getVersion());
    if (affected == 0) {
        throw new OptimisticLockException("库存扣减失败，请重试");
    }
}
```

### 5.2 分页查询（强制）

```java
// ✅ 必须分页
public PageResult<Order> listOrders(OrderQuery query) {
    // 限制单页最大条数
    int pageSize = Math.min(query.getPageSize(), 100);

    PageHelper.startPage(query.getPageNum(), pageSize);
    List<Order> list = orderMapper.selectByCondition(query);
    PageInfo<Order> pageInfo = new PageInfo<>(list);

    return PageResult.of(pageInfo);
}

// ❌ 禁止：不分页查询全表
public List<Order> listAllOrders() {
    return orderMapper.selectAll();  // 禁止！
}
```

### 5.3 深度分页优化

```java
// ❌ 问题：深度分页性能差
SELECT * FROM orders ORDER BY id LIMIT 1000000, 20;

// ✅ 方案一：游标分页（推荐）
SELECT * FROM orders WHERE id > #{lastId} ORDER BY id LIMIT 20;

// ✅ 方案二：延迟关联
SELECT o.* FROM orders o
INNER JOIN (SELECT id FROM orders ORDER BY id LIMIT 1000000, 20) t
ON o.id = t.id;
```

## 6. MyBatis 规范 [MUST]

### 6.1 ResultMap 强制

```xml
<!-- ✅ 正确：使用 ResultMap -->
<resultMap id="orderResultMap" type="Order">
    <id property="id" column="id"/>
    <result property="userId" column="user_id"/>
    <result property="orderNo" column="order_no"/>
    <result property="createTime" column="create_time"/>
</resultMap>

<select id="selectById" resultMap="orderResultMap">
    SELECT id, user_id, order_no, create_time FROM orders WHERE id = #{id}
</select>

<!-- ❌ 禁止：resultType="map" -->
<select id="selectById" resultType="map">
    SELECT * FROM orders WHERE id = #{id}
</select>
```

### 6.2 动态SQL嵌套限制

```xml
<!-- 动态SQL最多3层嵌套 -->
<select id="selectOrders" resultMap="orderResultMap">
    SELECT * FROM orders
    <where>
        <if test="userId != null">           <!-- 第1层 -->
            AND user_id = #{userId}
        </if>
        <if test="status != null">           <!-- 第1层 -->
            AND status = #{status}
        </if>
        <if test="dateRange != null">        <!-- 第1层 -->
            <if test="dateRange.start != null">   <!-- 第2层 -->
                AND create_time >= #{dateRange.start}
            </if>
            <if test="dateRange.end != null">     <!-- 第2层 -->
                AND create_time &lt;= #{dateRange.end}
            </if>
        </if>
    </where>
</select>
```

### 6.3 批量操作

```xml
<!-- 批量插入：每批500条 -->
<insert id="batchInsert">
    INSERT INTO orders (user_id, order_no, amount)
    VALUES
    <foreach collection="list" item="order" separator=",">
        (#{order.userId}, #{order.orderNo}, #{order.amount})
    </foreach>
</insert>
```

```java
// Service层分批处理
public void batchInsertOrders(List<Order> orders) {
    int batchSize = 500;
    List<List<Order>> batches = Lists.partition(orders, batchSize);
    for (List<Order> batch : batches) {
        orderMapper.batchInsert(batch);
    }
}
```

```yaml
# 开启批量重写（提升批量插入性能）
spring:
  datasource:
    url: jdbc:mysql://host:3306/db?rewriteBatchedStatements=true
```

## 7. 查询优化 [SHOULD]

### 7.1 禁止 SELECT *

```sql
-- ❌ 禁止
SELECT * FROM orders WHERE user_id = 1001;

-- ✅ 明确指定字段
SELECT id, order_no, amount, status, create_time
FROM orders WHERE user_id = 1001;
```

### 7.2 EXPLAIN 分析

```sql
-- 执行计划分析
EXPLAIN SELECT * FROM orders WHERE user_id = 1001;

-- 关注指标：
-- type: 至少 ref，避免 ALL（全表扫描）
-- rows: 扫描行数，越少越好
-- Extra: 避免 Using filesort、Using temporary
```
```

---

### 2.3 新增 `standards/data-governance.md`

**来源**: ai-rules/11-data-governance.md

**必要性**: 数据治理是企业级系统必备能力，缺失会导致：
- 分布式ID冲突
- 数据分片策略不当导致热点
- 数据生命周期管理缺失导致存储膨胀
- 数据质量问题影响业务决策

**建议内容结构**:

```markdown
# 数据治理规范

## 1. 数据字典规范 [MUST]

### 1.1 字段命名规范

| 字段类型 | 命名规则 | Java类型 | MySQL类型 | 示例 |
|----------|----------|----------|-----------|------|
| 主键 | {表名}_id | Long | BIGINT | user_id, order_id |
| 外键 | {关联表}_id | Long | BIGINT | user_id (在order表) |
| 金额 | xxx_amount | BigDecimal | DECIMAL(19,2) | order_amount |
| 时间 | xxx_time | LocalDateTime | DATETIME | create_time |
| 状态 | xxx_status | Integer | TINYINT | order_status |
| 布尔 | is_xxx | Boolean | TINYINT(1) | is_deleted |
| 版本号 | version | Integer | INT | version |

### 1.2 表设计规范

```sql
CREATE TABLE `order` (
    `order_id` BIGINT NOT NULL COMMENT '订单ID（雪花算法）',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `order_no` VARCHAR(32) NOT NULL COMMENT '订单编号',
    `order_amount` DECIMAL(19,2) NOT NULL COMMENT '订单金额',
    `order_status` TINYINT NOT NULL DEFAULT 0 COMMENT '订单状态：0-待支付,1-已支付,2-已发货',
    `is_deleted` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否删除：0-否,1-是',
    `version` INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`order_id`),
    UNIQUE KEY `uk_order_no` (`order_no`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';
```

## 2. 分布式ID生成 [MUST]

### 2.1 雪花算法（64位）

```
 1位符号  |  41位时间戳  |  10位机器ID  |  12位序列号
    0     | timestamp    | datacenterId + workerId | sequence
```

**配置示例**:
```java
@Configuration
public class SnowflakeConfig {

    @Value("${snowflake.datacenter-id}")
    private long datacenterId;

    @Value("${snowflake.worker-id}")
    private long workerId;

    @Bean
    public Snowflake snowflake() {
        return new Snowflake(datacenterId, workerId);
    }
}

// 使用
@Autowired
private Snowflake snowflake;

public Long generateId() {
    return snowflake.nextId();
}
```

### 2.2 业务流水号

**格式**: `{业务前缀}{日期}{序列号}{随机数}`

```java
// 订单号：ORD + 日期 + 6位序列 + 4位随机
// 示例：ORD202501120001231234

public String generateOrderNo() {
    String prefix = "ORD";
    String date = LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE);
    String sequence = String.format("%06d", getRedisSequence("order:" + date));
    String random = String.format("%04d", ThreadLocalRandom.current().nextInt(10000));
    return prefix + date + sequence + random;
}

private long getRedisSequence(String key) {
    // Redis INCR 原子递增，设置2天过期
    Long seq = redis.incr(key);
    if (seq == 1) {
        redis.expire(key, 2, TimeUnit.DAYS);
    }
    return seq;
}
```

### 2.3 禁止使用 UUID

```java
// ❌ 禁止：UUID无序，索引效率低，占用空间大
String id = UUID.randomUUID().toString();

// ✅ 使用雪花算法
Long id = snowflake.nextId();
```

## 3. 数据分片策略 [SHOULD]

### 3.1 分片键选择

| 数据类型 | 分片策略 | 分片键 | 说明 |
|----------|----------|--------|------|
| 用户/订单 | 哈希分片 | user_id | 均匀分布 |
| 日志/流水 | 范围分片 | create_time | 按月分表 |
| 商品/配置 | 不分片 | - | 数据量小 |

### 3.2 Sharding-JDBC 配置示例

```yaml
spring:
  shardingsphere:
    datasource:
      names: ds0, ds1
      ds0:
        url: jdbc:mysql://host1:3306/db
      ds1:
        url: jdbc:mysql://host2:3306/db
    rules:
      sharding:
        tables:
          order:
            actual-data-nodes: ds$->{0..1}.order_$->{0..15}
            table-strategy:
              standard:
                sharding-column: user_id
                sharding-algorithm-name: order-table-inline
            database-strategy:
              standard:
                sharding-column: user_id
                sharding-algorithm-name: order-db-inline
        sharding-algorithms:
          order-db-inline:
            type: INLINE
            props:
              algorithm-expression: ds$->{user_id % 2}
          order-table-inline:
            type: INLINE
            props:
              algorithm-expression: order_$->{user_id % 16}
```

## 4. 数据生命周期 [MUST]

### 4.1 数据分层

| 层级 | 定义 | 存储位置 | 保留期限 |
|------|------|----------|----------|
| 热数据 | 日访问≥1次 | MySQL主库 | 实时 |
| 温数据 | 日访问<1次，<6个月 | MySQL从库 | 6个月 |
| 冷数据 | 月访问<1次，<3年 | OSS/S3 (Parquet) | 3年 |
| 归档数据 | 年访问<1次 | 低成本存储 | 5年+ |

### 4.2 自动迁移任务

```java
@Scheduled(cron = "0 0 2 * * ?")  // 每天凌晨2点
public void migrateWarmToCold() {
    // 1. 查询需要迁移的数据
    LocalDateTime threshold = LocalDateTime.now().minusMonths(6);
    List<Order> warmOrders = orderMapper.selectByCreateTimeBefore(threshold);

    // 2. 导出为Parquet格式
    String ossPath = "cold-data/orders/" + LocalDate.now() + ".parquet";
    parquetExporter.export(warmOrders, ossPath);

    // 3. 校验完整性
    if (!verifyIntegrity(warmOrders, ossPath)) {
        throw new DataMigrationException("数据校验失败");
    }

    // 4. 删除MySQL数据
    orderMapper.deleteByIds(warmOrders.stream().map(Order::getId).toList());

    // 5. 记录审计日志
    auditLogService.log("DATA_MIGRATION", "迁移" + warmOrders.size() + "条订单到冷存储");
}
```

## 5. 数据安全分级 [MUST]

### 5.1 分级标准

| 级别 | 数据类型 | 加密方式 | 密钥管理 |
|------|----------|----------|----------|
| 核心 | 身份证、银行卡、密码 | SM4 + 信封加密 | KMS托管 |
| 重要 | 手机号、邮箱、地址 | AES-256-GCM | 配置中心加密 |
| 一般 | 昵称、头像 | 可逆脱敏 | - |

### 5.2 加密实现

```java
// 核心数据：SM4 + 信封加密
@Service
public class CoreDataEncryptor {

    @Autowired
    private KmsClient kmsClient;

    public String encrypt(String plaintext) {
        // 1. 生成数据密钥
        DataKey dataKey = kmsClient.generateDataKey();

        // 2. SM4加密数据
        String ciphertext = SM4Util.encrypt(plaintext, dataKey.getPlaintext());

        // 3. 返回密文 + 加密的数据密钥
        return Base64.encode(dataKey.getCiphertext()) + ":" + ciphertext;
    }

    public String decrypt(String encrypted) {
        String[] parts = encrypted.split(":");

        // 1. KMS解密数据密钥
        byte[] dataKeyPlaintext = kmsClient.decrypt(Base64.decode(parts[0]));

        // 2. SM4解密数据
        return SM4Util.decrypt(parts[1], dataKeyPlaintext);
    }
}

// 重要数据：AES-256-GCM
public class ImportantDataEncryptor {

    @Value("${encryption.aes-key}")
    private String aesKey;

    public String encrypt(String plaintext) {
        return AESUtil.encryptGCM(plaintext, aesKey);
    }

    public String decrypt(String ciphertext) {
        return AESUtil.decryptGCM(ciphertext, aesKey);
    }
}
```

### 5.3 脱敏规则

```java
public class DesensitizeUtil {

    // 手机号：138****8000
    public static String phone(String phone) {
        if (StringUtils.isBlank(phone) || phone.length() != 11) {
            return phone;
        }
        return phone.substring(0, 3) + "****" + phone.substring(7);
    }

    // 身份证：310***********1234
    public static String idCard(String idCard) {
        if (StringUtils.isBlank(idCard) || idCard.length() < 15) {
            return idCard;
        }
        return idCard.substring(0, 3) + "***********" + idCard.substring(idCard.length() - 4);
    }

    // 银行卡：************1234
    public static String bankCard(String bankCard) {
        if (StringUtils.isBlank(bankCard) || bankCard.length() < 8) {
            return bankCard;
        }
        return "************" + bankCard.substring(bankCard.length() - 4);
    }

    // 邮箱：z***@example.com
    public static String email(String email) {
        if (StringUtils.isBlank(email) || !email.contains("@")) {
            return email;
        }
        String[] parts = email.split("@");
        return parts[0].charAt(0) + "***@" + parts[1];
    }
}
```

## 6. 数据质量监控 [SHOULD]

### 6.1 监控维度

| 维度 | 监控内容 | 告警阈值 |
|------|----------|----------|
| 准确性 | 重复数据、枚举值合法性 | 重复率>0.1% |
| 完整性 | 必填字段空值率 | 空值率>1% |
| 一致性 | 跨表关联数据一致 | 不一致>0.01% |
| 时效性 | 数据更新延迟 | 延迟>1小时 |

### 6.2 自动化检查

```java
@Scheduled(cron = "0 0 6 * * ?")  // 每天早上6点
public void dataQualityCheck() {
    // 检查订单表数据质量
    DataQualityReport report = new DataQualityReport();

    // 1. 检查重复订单号
    int duplicateCount = orderMapper.countDuplicateOrderNo();
    report.addMetric("duplicate_order_no", duplicateCount);

    // 2. 检查空值率
    double nullAmountRate = orderMapper.countNullAmount() * 100.0 / orderMapper.count();
    report.addMetric("null_amount_rate", nullAmountRate);

    // 3. 检查枚举值合法性
    int invalidStatusCount = orderMapper.countInvalidStatus();
    report.addMetric("invalid_status", invalidStatusCount);

    // 4. 发送报告
    if (report.hasIssues()) {
        alertService.send("数据质量告警", report.toString());
    }
}
```
```

---

## 三、🟡 中优先级 - 建议增强现有文件

### 3.1 增强 `architecture-principles.md`

**当前状态**: 有微服务架构概念，但缺少实现细节
**来源**: ai-rules/06-microservice.md

**建议补充内容**:

```markdown
## 微服务治理实现规范 [MUST]

### 1. 服务注册与发现（Nacos）

#### 1.1 集群部署要求
- 生产环境 Nacos 集群≥3节点
- 健康检查：5秒心跳，15秒超时
- 双重探针：Nacos健康检查 + K8s探针

#### 1.2 服务命名规范
```yaml
spring:
  cloud:
    nacos:
      discovery:
        server-addr: ${NACOS_ADDR}
        namespace: ${ENV}                    # dev/test/prod
        group: MALL_GROUP                    # 业务线分组
        service: mall-order                  # 业务线-服务名
```

### 2. 远程调用（Feign）

#### 2.1 API模块独立
```
mall-order/
├── mall-order-api/           # Feign接口+DTO（独立模块）
│   ├── OrderFeignClient.java
│   └── OrderDTO.java
└── mall-order-service/       # 业务实现
    └── OrderFeignClientImpl.java
```

#### 2.2 降级处理（强制）
```java
@FeignClient(name = "mall-user", fallbackFactory = UserFeignFallbackFactory.class)
public interface UserFeignClient {
    @GetMapping("/api/v1/users/{id}")
    Result<UserDTO> getUser(@PathVariable Long id);
}

@Component
public class UserFeignFallbackFactory implements FallbackFactory<UserFeignClient> {
    @Override
    public UserFeignClient create(Throwable cause) {
        return new UserFeignClient() {
            @Override
            public Result<UserDTO> getUser(Long id) {
                log.error("获取用户降级, userId={}", id, cause);
                return Result.fail("用户服务暂不可用");
            }
        };
    }
}
```

#### 2.3 TraceId传递（强制）
```java
@Component
public class FeignTraceInterceptor implements RequestInterceptor {
    @Override
    public void apply(RequestTemplate template) {
        String traceId = MDC.get("traceId");
        if (StringUtils.isNotBlank(traceId)) {
            template.header("X-Trace-Id", traceId);
        }
    }
}
```

### 3. 流量管理（Sentinel）

#### 3.1 持久化配置
```yaml
spring:
  cloud:
    sentinel:
      transport:
        dashboard: ${SENTINEL_DASHBOARD}
      datasource:
        flow:
          nacos:
            server-addr: ${NACOS_ADDR}
            dataId: ${spring.application.name}-flow-rules
            groupId: SENTINEL_GROUP
            rule-type: flow
```

#### 3.2 熔断配置
```java
@SentinelResource(
    value = "getUser",
    blockHandler = "getUserBlockHandler",
    fallback = "getUserFallback"
)
public UserDTO getUser(Long userId) {
    return userFeignClient.getUser(userId).getData();
}

// 限流/熔断时触发
public UserDTO getUserBlockHandler(Long userId, BlockException ex) {
    log.warn("用户服务限流, userId={}", userId);
    return new UserDTO();  // 返回默认值
}

// 业务异常时触发
public UserDTO getUserFallback(Long userId, Throwable ex) {
    log.error("用户服务异常, userId={}", userId, ex);
    return new UserDTO();
}
```

### 4. 分布式事务

#### 4.1 选型原则
| 场景 | 方案 | 示例 |
|------|------|------|
| 核心业务（强一致） | Seata AT | 支付、转账 |
| 非核心业务（最终一致） | 可靠消息 | 通知、积分 |
| 跨系统（长事务） | TCC | 库存预占 |

#### 4.2 Seata AT模式
```java
@GlobalTransactional(rollbackFor = Exception.class, timeoutMills = 30000)
public void createOrder(OrderDTO dto) {
    // 1. 创建订单
    orderMapper.insert(order);

    // 2. 扣减库存（远程服务）
    productFeignClient.decreaseStock(dto.getProductId(), dto.getQuantity());

    // 3. 扣减积分（远程服务）
    userFeignClient.decreasePoints(dto.getUserId(), dto.getPoints());
}
```
```

---

### 3.2 增强 `java.md` 并发编程部分

**当前状态**: 有基础线程池和ThreadLocal规范
**来源**: ai-rules/07-concurrency.md

**建议补充内容**:

```markdown
## 并发编程规范（增强）

### 1. 线程池配置公式 [MUST]

#### 1.1 按任务类型配置

| 任务类型 | 核心线程数 | 最大线程数 | 队列容量 |
|----------|------------|------------|----------|
| IO密集型 | CPU × 2 | CPU × 4 | 1000 |
| CPU密集型 | CPU + 1 | CPU + 1 | 500 |
| 混合型 | CPU × 1.5 | CPU × 3 | 800 |

#### 1.2 配置示例
```java
@Configuration
public class ThreadPoolConfig {

    private static final int CPU_COUNT = Runtime.getRuntime().availableProcessors();

    // IO密集型（HTTP调用、数据库查询）
    @Bean("ioExecutor")
    public ThreadPoolExecutor ioExecutor() {
        return new ThreadPoolExecutor(
            CPU_COUNT * 2,                    // 核心线程
            CPU_COUNT * 4,                    // 最大线程
            60, TimeUnit.SECONDS,             // 空闲时间
            new LinkedBlockingQueue<>(1000),  // 有界队列
            new ThreadFactoryBuilder()
                .setNameFormat("io-pool-%d")
                .setUncaughtExceptionHandler((t, e) ->
                    log.error("IO线程异常: {}", t.getName(), e))
                .build(),
            new ThreadPoolExecutor.CallerRunsPolicy()  // 拒绝策略：调用者执行
        );
    }

    // CPU密集型（计算、加密）
    @Bean("cpuExecutor")
    public ThreadPoolExecutor cpuExecutor() {
        return new ThreadPoolExecutor(
            CPU_COUNT + 1,
            CPU_COUNT + 1,
            60, TimeUnit.SECONDS,
            new LinkedBlockingQueue<>(500),
            new ThreadFactoryBuilder()
                .setNameFormat("cpu-pool-%d")
                .build(),
            new ThreadPoolExecutor.AbortPolicy()  // 拒绝策略：直接拒绝
        );
    }
}
```

### 2. 锁选型矩阵 [SHOULD]

| 场景 | 推荐锁 | 说明 |
|------|--------|------|
| 简单同步（低竞争） | synchronized | JVM优化好，代码简洁 |
| 复杂同步（需超时/中断） | ReentrantLock | 支持tryLock、lockInterruptibly |
| 读多写少 | ReentrantReadWriteLock | 读锁共享，写锁独占 |
| 超高并发读 | StampedLock | 乐观读，性能最高（不可重入） |
| 简单计数 | AtomicLong | CAS无锁，最轻量 |

### 3. CompletableFuture 异常处理 [MUST]

```java
// ✅ 正确：链式异常处理
CompletableFuture.supplyAsync(() -> {
    return doSomething();
}, ioExecutor)
.thenApply(result -> {
    return process(result);
})
.exceptionally(ex -> {
    log.error("异步任务异常", ex);
    return defaultValue;  // 返回默认值
})
.thenAccept(finalResult -> {
    // 最终处理
});

// ❌ 禁止：吞掉异常
CompletableFuture.runAsync(() -> {
    try {
        doSomething();
    } catch (Exception e) {
        // 空catch，异常被吞
    }
});
```

### 4. TransmittableThreadLocal（线程池场景）[MUST]

```java
// 普通ThreadLocal在线程池中会丢失上下文
// 必须使用TransmittableThreadLocal

// 1. 定义TTL
private static final TransmittableThreadLocal<String> USER_CONTEXT =
    new TransmittableThreadLocal<>();

// 2. 包装线程池
@Bean("ttlExecutor")
public Executor ttlExecutor(ThreadPoolExecutor ioExecutor) {
    return TtlExecutors.getTtlExecutor(ioExecutor);
}

// 3. 使用
USER_CONTEXT.set("user123");
ttlExecutor.execute(() -> {
    String user = USER_CONTEXT.get();  // 可以获取到"user123"
});
```
```

---

### 3.3 增强 `security-baseline.md` RBAC部分

**当前状态**: 有权限控制原则，缺少分层模型
**来源**: ai-rules/08-security.md

**建议补充内容**:

```markdown
## RBAC 4层权限模型 [MUST]

### 1. 模型结构

```
用户 (User)
   ↓ 多对多
角色 (Role)
   ↓ 多对多
权限 (Permission)
   ↓ 关联
数据范围 (DataScope)
```

### 2. 四层校验

| 层级 | 校验内容 | 实现方式 |
|------|----------|----------|
| 前端层 | UI展示控制 | v-permission指令 |
| 网关层 | Token有效性、基础权限 | Spring Cloud Gateway过滤器 |
| 接口层 | 功能权限 | @PreAuthorize注解 |
| 业务层 | 数据权限 | MyBatis拦截器 |

### 3. 实现示例

#### 3.1 接口层权限
```java
@RestController
@RequestMapping("/api/v1/orders")
public class OrderController {

    @GetMapping
    @PreAuthorize("hasAuthority('order:list')")
    public Result<List<OrderVO>> listOrders() { }

    @PostMapping
    @PreAuthorize("hasAuthority('order:create')")
    public Result<Long> createOrder(@RequestBody OrderDTO dto) { }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('order:delete') and @orderService.isOwner(#id)")
    public Result<Void> deleteOrder(@PathVariable Long id) { }
}
```

#### 3.2 数据权限（MyBatis拦截器）
```java
@Intercepts({
    @Signature(type = Executor.class, method = "query",
               args = {MappedStatement.class, Object.class, RowBounds.class, ResultHandler.class})
})
public class DataScopeInterceptor implements Interceptor {

    @Override
    public Object intercept(Invocation invocation) throws Throwable {
        // 获取当前用户数据权限范围
        DataScope scope = SecurityUtils.getCurrentUser().getDataScope();

        if (scope == DataScope.ALL) {
            return invocation.proceed();  // 全部数据
        }

        // 修改SQL，添加数据范围过滤
        MappedStatement ms = (MappedStatement) invocation.getArgs()[0];
        BoundSql boundSql = ms.getBoundSql(invocation.getArgs()[1]);
        String originalSql = boundSql.getSql();

        String newSql = addDataScopeFilter(originalSql, scope);
        // ... 替换SQL并执行
    }

    private String addDataScopeFilter(String sql, DataScope scope) {
        return switch (scope) {
            case DEPT -> sql + " AND dept_id = " + SecurityUtils.getDeptId();
            case DEPT_AND_CHILD -> sql + " AND dept_id IN (" + getDeptAndChildIds() + ")";
            case SELF -> sql + " AND create_by = " + SecurityUtils.getUserId();
            default -> sql;
        };
    }
}
```
```

---

## 四、🟢 低优先级 - 可选增强

### 4.1 可考虑新增 `governance/team-collaboration.md`

**来源**: ai-rules/13-team-collaboration.md

**内容**: Git工作流、分支命名、Commit规范、PR模板等

**理由**: 当前review-process.md已包含部分内容，但不够系统化

### 4.2 可考虑补充消息队列规范

**当前状态**: 仅在technology-radar/adopt.md提及RocketMQ/Kafka
**建议**: 新增消息队列使用规范（消息幂等、顺序消息、死信处理）

---

## 五、建议实施路径

### Phase 1（立即执行）
1. ✅ 新增 `standards/cache-standards.md`
2. ✅ 新增 `standards/database-standards.md`
3. ✅ 新增 `standards/data-governance.md`

### Phase 2（1-2周内）
1. 增强 `architecture-principles.md` 微服务治理部分
2. 增强 `java.md` 并发编程部分
3. 增强 `security-baseline.md` RBAC部分

### Phase 3（后续迭代）
1. 评估是否需要独立的团队协作规范
2. 评估是否需要消息队列规范
3. 持续收集实践反馈，迭代完善

---

## 六、附录：文件清单对照表

| 序号 | ai-rules文件 | enterprise-standards对应 | 补充建议 |
|------|-------------|-------------------------|----------|
| 01 | 01-overview.md | ai-coding-policy.md | ✅ 已覆盖 |
| 02 | 02-coding-basics.md | java.md | ✅ 基本覆盖 |
| 03 | 03-database.md | 分散 | 🔴 新增database-standards.md |
| 04 | 04-cache.md | 无 | 🔴 新增cache-standards.md |
| 05 | 05-api-design.md | api-design-guide.md | ✅ 已覆盖 |
| 06 | 06-microservice.md | architecture-principles.md | 🟡 增强微服务治理 |
| 07 | 07-concurrency.md | java.md | 🟡 增强并发部分 |
| 08 | 08-security.md | security-baseline.md | 🟡 增强RBAC部分 |
| 09 | 09-testing.md | testing-standards.md | ✅ 已覆盖 |
| 10 | 10-deployment.md | release-process.md | ✅ 已覆盖 |
| 11 | 11-data-governance.md | 无 | 🔴 新增data-governance.md |
| 12 | 12-compliance.md | compliance-requirements.md | ✅ 已覆盖 |
| 13 | 13-team-collaboration.md | review-process.md | 🟢 可选增强 |

---

> **文档说明**: 本文档基于 enterprise-standards/ 与 ai-rules/ 目录对比生成，建议配合实际业务需求进行调整后实施。
