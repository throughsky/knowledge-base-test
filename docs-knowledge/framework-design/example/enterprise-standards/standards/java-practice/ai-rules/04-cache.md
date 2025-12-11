# 缓存规范 - AI编码约束

> 适用于：Redis操作、本地缓存、缓存策略设计场景

## 一、缓存选型规范 [MUST]

### 1.1 选型决策矩阵

| 场景 | 缓存类型 | 工具选型 | 适用条件 |
|------|----------|----------|----------|
| 低并发静态数据 | 本地缓存 | Caffeine/Guava | QPS≤1000，数据量≤1万 |
| 高并发共享数据 | 分布式缓存 | Redis | QPS≥1000，需集群共享 |
| 超高并发热点 | 多级缓存 | 本地+Redis | QPS≥10000，热点数据 |

### 1.2 本地缓存配置

```java
// Caffeine配置
@Bean
public Cache<String, Object> localCache() {
    return Caffeine.newBuilder()
            .maximumSize(10000)           // 最大条目数
            .expireAfterWrite(5, TimeUnit.MINUTES)  // 写入后过期
            .recordStats()                 // 统计命中率
            .build();
}
```

### 1.3 Redis配置

```yaml
spring:
  redis:
    host: ${REDIS_HOST:localhost}
    port: 6379
    password: ${REDIS_PASSWORD}
    timeout: 3000
    lettuce:
      pool:
        max-active: 20
        max-idle: 10
        min-idle: 5
        max-wait: 3000
```

## 二、缓存风险防护规范 [MUST]

### 2.1 缓存穿透防护

```yaml
problem: 查询不存在的数据，请求直击数据库
solutions:
  - 缓存空值（短过期时间）
  - 布隆过滤器（海量数据）
```

```java
// ✅ 方案1：缓存空值
public User getUser(Long userId) {
    String key = "user:" + userId;
    String cached = redisTemplate.opsForValue().get(key);

    // 空值标记，表示数据不存在
    if ("NULL".equals(cached)) {
        return null;
    }

    if (cached != null) {
        return JSON.parseObject(cached, User.class);
    }

    // 查询数据库
    User user = userMapper.selectById(userId);
    if (user != null) {
        redisTemplate.opsForValue().set(key, JSON.toJSONString(user), 30, TimeUnit.MINUTES);
    } else {
        // 缓存空值，短过期时间
        redisTemplate.opsForValue().set(key, "NULL", 5, TimeUnit.MINUTES);
    }
    return user;
}

// ✅ 方案2：布隆过滤器（海量数据）
@Autowired
private RBloomFilter<Long> userBloomFilter;

public User getUser(Long userId) {
    // 布隆过滤器判断是否存在
    if (!userBloomFilter.contains(userId)) {
        return null;  // 一定不存在
    }

    // 可能存在，查缓存和数据库
    // ...
}
```

### 2.2 缓存击穿防护

```yaml
problem: 热点key过期瞬间，大量请求直击数据库
solutions:
  - 互斥锁（推荐）
  - 热点key永不过期+异步刷新
```

```java
// ✅ 方案1：互斥锁
public Product getHotProduct(Long productId) {
    String key = "product:hot:" + productId;
    String lockKey = "lock:product:" + productId;

    // 1. 查缓存
    String cached = redisTemplate.opsForValue().get(key);
    if (cached != null) {
        return JSON.parseObject(cached, Product.class);
    }

    // 2. 获取分布式锁
    RLock lock = redissonClient.getLock(lockKey);
    try {
        // 等待获取锁，最多等待3秒
        if (lock.tryLock(3, 10, TimeUnit.SECONDS)) {
            // 双重检查
            cached = redisTemplate.opsForValue().get(key);
            if (cached != null) {
                return JSON.parseObject(cached, Product.class);
            }

            // 查询数据库
            Product product = productMapper.selectById(productId);
            if (product != null) {
                redisTemplate.opsForValue().set(key, JSON.toJSONString(product), 30, TimeUnit.MINUTES);
            }
            return product;
        }
        // 未获取到锁，短暂等待后重试
        Thread.sleep(100);
        return getHotProduct(productId);
    } finally {
        if (lock.isHeldByCurrentThread()) {
            lock.unlock();
        }
    }
}

// ✅ 方案2：永不过期+异步刷新
public Product getHotProductV2(Long productId) {
    String key = "product:hot:" + productId;

    ProductCache cache = redisTemplate.opsForValue().get(key);
    if (cache != null) {
        // 检查逻辑过期时间
        if (cache.getExpireTime() > System.currentTimeMillis()) {
            return cache.getData();
        }
        // 已逻辑过期，异步刷新
        asyncRefreshCache(productId, key);
        return cache.getData();  // 返回旧数据
    }

    // 缓存不存在，同步加载
    return loadAndCache(productId, key);
}

@Async
public void asyncRefreshCache(Long productId, String key) {
    // 异步刷新缓存
    Product product = productMapper.selectById(productId);
    ProductCache cache = new ProductCache(product, System.currentTimeMillis() + 30 * 60 * 1000);
    redisTemplate.opsForValue().set(key, cache);  // 永不过期
}
```

### 2.3 缓存雪崩防护

```yaml
problem: 大量key同时过期，请求瞬间压垮数据库
solutions:
  - 过期时间随机化
  - 集群高可用
  - 限流降级
```

```java
// ✅ 过期时间随机化
public void setCacheWithRandomExpire(String key, Object value, int baseExpireSeconds) {
    // 在基础时间上增加随机偏移（10%-20%）
    int randomOffset = baseExpireSeconds * (10 + new Random().nextInt(11)) / 100;
    int actualExpire = baseExpireSeconds + randomOffset;
    redisTemplate.opsForValue().set(key, JSON.toJSONString(value), actualExpire, TimeUnit.SECONDS);
}

// 使用示例：基础30分钟，实际33-36分钟
setCacheWithRandomExpire("product:" + productId, product, 1800);
```

## 三、缓存一致性规范 [MUST]

### 3.1 读写策略

```yaml
read_strategy: Cache-Aside
  1. 先查缓存
  2. 缓存命中返回
  3. 缓存未命中查数据库
  4. 回写缓存

write_strategy: 先更数据库，再删缓存
  1. 更新数据库
  2. 删除缓存（非更新）
```

```java
// ✅ 正确：读流程
public User getUser(Long userId) {
    String key = "user:" + userId;

    // 1. 先查缓存
    String cached = redisTemplate.opsForValue().get(key);
    if (cached != null) {
        return JSON.parseObject(cached, User.class);
    }

    // 2. 查数据库
    User user = userMapper.selectById(userId);

    // 3. 回写缓存
    if (user != null) {
        redisTemplate.opsForValue().set(key, JSON.toJSONString(user), 30, TimeUnit.MINUTES);
    }
    return user;
}

// ✅ 正确：写流程（先更数据库，再删缓存）
@Transactional(rollbackFor = Exception.class)
public void updateUser(User user) {
    // 1. 更新数据库
    userMapper.updateById(user);

    // 2. 删除缓存
    String key = "user:" + user.getId();
    redisTemplate.delete(key);
}
```

### 3.2 延迟双删（高并发场景）

```java
// ✅ 延迟双删策略
@Transactional(rollbackFor = Exception.class)
public void updateUser(User user) {
    String key = "user:" + user.getId();

    // 1. 删除缓存
    redisTemplate.delete(key);

    // 2. 更新数据库
    userMapper.updateById(user);

    // 3. 延迟再删一次（异步）
    executor.schedule(() -> redisTemplate.delete(key), 500, TimeUnit.MILLISECONDS);
}
```

### 3.3 禁止策略

```yaml
prohibited:
  - 先删缓存再更数据库（脏数据风险）
  - 只更数据库不删缓存
  - 更数据库同时更缓存（并发冲突）
```

## 四、Redis使用规范 [MUST]

### 4.1 Key命名规范

```yaml
format: 业务域:模块:资源:唯一标识
separator: 冒号(:)
requirements:
  - 全小写
  - 可读性强
  - 避免过长（建议≤128字节）
```

```java
// ✅ 正确命名
String userKey = "mall:user:info:" + userId;        // 用户信息
String orderKey = "mall:order:detail:" + orderId;   // 订单详情
String lockKey = "mall:lock:order:" + orderId;      // 订单锁
String stockKey = "mall:product:stock:" + productId; // 商品库存

// ❌ 错误命名
String key1 = "user_" + userId;           // 分隔符不规范
String key2 = "USER:" + userId;           // 大写
String key3 = userId.toString();          // 无业务标识
```

### 4.2 数据类型选型

| 场景 | 推荐类型 | 禁止类型 |
|------|----------|----------|
| 单值缓存 | String | - |
| 对象属性 | Hash | String存JSON（无法部分更新） |
| 列表/队列 | List | - |
| 去重集合 | Set | - |
| 排行榜 | ZSet | - |
| 计数器 | String(INCR) | - |
| 位图/签到 | BitMap | - |

```java
// ✅ 正确：Hash存储用户信息（支持部分更新）
public void saveUser(User user) {
    String key = "mall:user:info:" + user.getId();
    Map<String, String> fields = new HashMap<>();
    fields.put("name", user.getName());
    fields.put("age", String.valueOf(user.getAge()));
    fields.put("phone", user.getPhone());
    redisTemplate.opsForHash().putAll(key, fields);
    redisTemplate.expire(key, 30, TimeUnit.MINUTES);
}

// 部分更新
public void updateUserName(Long userId, String newName) {
    String key = "mall:user:info:" + userId;
    redisTemplate.opsForHash().put(key, "name", newName);
}

// ❌ 错误：String存JSON（更新需全量替换）
public void saveUserWrong(User user) {
    String key = "user:" + user.getId();
    redisTemplate.opsForValue().set(key, JSON.toJSONString(user));
}
```

### 4.3 大Key防护

```yaml
definition:
  - String类型：value > 100KB
  - Hash/List/Set/ZSet：元素数 > 5000

prevention:
  - 拆分大Key
  - 压缩数据
  - 定期扫描检测
```

```java
// ✅ 正确：拆分大Hash（按时间分片）
// 原始Key: order:user:1001 (存储用户所有订单)
// 拆分后: order:user:1001:202401 (按月分片)
public void saveUserOrder(Long userId, Order order) {
    String yearMonth = order.getCreateTime().format(DateTimeFormatter.ofPattern("yyyyMM"));
    String key = "mall:order:user:" + userId + ":" + yearMonth;
    redisTemplate.opsForHash().put(key, order.getId().toString(), JSON.toJSONString(order));
}

// ✅ 正确：分页存储大List
public void saveLargeList(String key, List<String> items) {
    int pageSize = 1000;
    for (int i = 0; i < items.size(); i += pageSize) {
        int end = Math.min(i + pageSize, items.size());
        String pageKey = key + ":" + (i / pageSize);
        redisTemplate.opsForList().rightPushAll(pageKey, items.subList(i, end));
    }
}
```

### 4.4 过期时间

```yaml
rules:
  - 所有缓存必须设置过期时间
  - 禁止永不过期（除热点key设计）
  - 建议过期时间：5分钟-24小时
```

```java
// ✅ 正确：设置过期时间
redisTemplate.opsForValue().set(key, value, 30, TimeUnit.MINUTES);
redisTemplate.expire(key, 1, TimeUnit.HOURS);

// ❌ 错误：不设过期时间
redisTemplate.opsForValue().set(key, value);  // 永不过期
```

## 五、分布式锁规范 [MUST]

### 5.1 Redisson分布式锁

```java
// ✅ 正确：使用Redisson
@Autowired
private RedissonClient redissonClient;

public void processOrder(Long orderId) {
    String lockKey = "lock:order:" + orderId;
    RLock lock = redissonClient.getLock(lockKey);

    try {
        // 尝试获取锁，最多等待3秒，锁自动释放时间10秒
        if (lock.tryLock(3, 10, TimeUnit.SECONDS)) {
            // 业务逻辑
            doProcess(orderId);
        } else {
            throw new BusinessException("系统繁忙，请稍后重试");
        }
    } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
        throw new BusinessException("操作被中断");
    } finally {
        // 释放锁（仅当前线程持有时释放）
        if (lock.isHeldByCurrentThread()) {
            lock.unlock();
        }
    }
}
```

### 5.2 锁使用禁止项

```yaml
prohibited:
  - 不设过期时间（死锁风险）
  - finally中不释放锁
  - 非当前线程释放锁
  - 业务逻辑时间超过锁过期时间
```

```java
// ❌ 错误：不设过期时间
redisTemplate.opsForValue().setIfAbsent(lockKey, "1");

// ❌ 错误：无条件释放锁
finally {
    lock.unlock();  // 可能释放其他线程的锁
}
```

## 六、反模式检查清单

| 序号 | 反模式 | 检测方式 |
|------|--------|----------|
| 1 | 缓存无过期时间 | 检查set方法是否有expire参数 |
| 2 | 先删缓存再更数据库 | 检查写操作顺序 |
| 3 | 无穿透防护 | 检查是否缓存空值或使用布隆过滤器 |
| 4 | 无击穿防护 | 检查热点key是否有锁或永不过期 |
| 5 | 过期时间相同 | 检查是否有随机偏移 |
| 6 | Key命名不规范 | 检查命名格式 |
| 7 | String存储复杂对象 | 检查是否应该用Hash |
| 8 | 分布式锁不设超时 | 检查tryLock参数 |
| 9 | finally不释放锁 | 检查finally块 |
| 10 | 大Key未拆分 | 检查Hash/List元素数量 |
