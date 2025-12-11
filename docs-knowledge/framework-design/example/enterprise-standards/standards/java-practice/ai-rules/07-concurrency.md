# 并发编程规范 - AI编码约束

> 适用于：线程池、锁机制、线程安全、并发工具使用场景

## 一、线程池规范 [MUST]

### 1.1 禁止使用Executors

```yaml
prohibited:
  - Executors.newFixedThreadPool()    # 无界队列，OOM风险
  - Executors.newCachedThreadPool()   # 无限线程，资源耗尽
  - Executors.newSingleThreadExecutor()
  - Executors.newScheduledThreadPool()
required: 手动创建ThreadPoolExecutor
```

```java
// ❌ 错误：使用Executors
ExecutorService executor = Executors.newFixedThreadPool(10);

// ✅ 正确：手动创建ThreadPoolExecutor
ThreadPoolExecutor executor = new ThreadPoolExecutor(
    corePoolSize,
    maxPoolSize,
    keepAliveTime,
    TimeUnit.SECONDS,
    new ArrayBlockingQueue<>(1000),  // 有界队列
    threadFactory,
    new ThreadPoolExecutor.CallerRunsPolicy()
);
```

### 1.2 线程池参数配置

| 参数 | IO密集型 | CPU密集型 |
|------|----------|-----------|
| 核心线程数 | CPU核数×2 | CPU核数+1 |
| 最大线程数 | CPU核数×4 | CPU核数+1 |
| 队列容量 | 有界队列1000 | 有界队列500 |
| 空闲时间 | 60秒 | 10秒 |
| 拒绝策略 | CallerRunsPolicy | AbortPolicy |

### 1.3 标准线程池配置

```java
@Configuration
public class ThreadPoolConfig {
    private static final int CPU_CORES = Runtime.getRuntime().availableProcessors();

    // IO密集型线程池
    @Bean(name = "ioIntensiveThreadPool")
    public ExecutorService ioIntensiveThreadPool() {
        ThreadFactory threadFactory = new ThreadFactoryBuilder()
                .setNameFormat("io-thread-%d")
                .setDaemon(true)
                .build();
        return new ThreadPoolExecutor(
            CPU_CORES * 2,
            CPU_CORES * 4,
            60, TimeUnit.SECONDS,
            new ArrayBlockingQueue<>(1000),
            threadFactory,
            new ThreadPoolExecutor.CallerRunsPolicy()
        );
    }

    // CPU密集型线程池
    @Bean(name = "cpuIntensiveThreadPool")
    public ExecutorService cpuIntensiveThreadPool() {
        ThreadFactory threadFactory = new ThreadFactoryBuilder()
                .setNameFormat("cpu-thread-%d")
                .setDaemon(true)
                .build();
        return new ThreadPoolExecutor(
            CPU_CORES + 1,
            CPU_CORES + 1,
            10, TimeUnit.SECONDS,
            new ArrayBlockingQueue<>(500),
            threadFactory,
            new ThreadPoolExecutor.AbortPolicy()
        );
    }
}
```

## 二、锁机制规范 [MUST]

### 2.1 锁选型规则

| 锁类型 | 适用场景 | 优点 | 缺点 |
|--------|----------|------|------|
| synchronized | 简单同步 | 用法简单、JVM优化好 | 锁粒度粗、无法中断 |
| ReentrantLock | 复杂同步 | 支持超时、中断、公平锁 | 需手动释放 |
| ReadWriteLock | 读多写少 | 读操作共享 | 实现复杂 |
| StampedLock | 高并发读多写少 | 乐观读性能最优 | 不支持重入 |

### 2.2 synchronized使用

```java
// ✅ 正确：简单方法同步
public synchronized boolean decreaseStock(int quantity) {
    if (stock >= quantity) {
        stock -= quantity;
        return true;
    }
    return false;
}

// ❌ 错误：锁粒度过粗（包含IO操作）
public synchronized void process() {
    readFromDatabase();  // IO操作不应在同步块内
    doCalculation();
    writeToDatabase();
}

// ✅ 正确：仅锁住临界区
public void process() {
    Data data = readFromDatabase();
    synchronized (this) {
        doCalculation(data);
    }
    writeToDatabase(data);
}
```

### 2.3 ReentrantLock使用

```java
// ✅ 正确：支持超时获取锁
private final ReentrantLock lock = new ReentrantLock();

public Long createOrder(OrderCreateRequest request) {
    boolean locked = false;
    try {
        locked = lock.tryLock(3, TimeUnit.SECONDS);
        if (locked) {
            // 临界区操作
            return doCreate(request);
        } else {
            throw new ServiceException("创建订单过于频繁");
        }
    } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
        throw new ServiceException("操作被中断");
    } finally {
        if (locked) {
            lock.unlock();  // 必须手动释放
        }
    }
}

// ❌ 错误：finally中无条件释放
finally {
    lock.unlock();  // 可能释放其他线程的锁
}
```

### 2.4 ReadWriteLock使用

```java
// ✅ 正确：读多写少场景
private final ReadWriteLock rwLock = new ReentrantReadWriteLock();
private final Lock readLock = rwLock.readLock();
private final Lock writeLock = rwLock.writeLock();

// 查询：读锁（共享）
public Product getProductById(Long productId) {
    readLock.lock();
    try {
        return productMap.get(productId);
    } finally {
        readLock.unlock();
    }
}

// 更新：写锁（独占）
public void updateProduct(Product product) {
    writeLock.lock();
    try {
        productMap.put(product.getId(), product);
    } finally {
        writeLock.unlock();
    }
}
```

### 2.5 锁使用禁止项

```yaml
prohibited:
  - 嵌套锁导致死锁
  - synchronized锁String常量
  - 锁粒度过粗（锁整个方法）
  - finally中无条件unlock
```

## 三、线程安全规范 [MUST]

### 3.1 共享变量处理

```yaml
rules:
  - 简单计数/状态：原子类（AtomicInteger/AtomicLong）
  - 共享集合：并发容器（ConcurrentHashMap/CopyOnWriteArrayList）
  - 跨线程共享：volatile/不可变对象/线程安全类
  - 线程私有：ThreadLocal
```

### 3.2 原子类使用

```java
// ✅ 正确：原子类
private final AtomicInteger stock = new AtomicInteger(100);

public boolean seckill() {
    int currentStock = stock.get();
    if (currentStock <= 0) {
        return false;
    }
    // CAS操作
    return stock.compareAndSet(currentStock, currentStock - 1);
}

// ❌ 错误：非原子操作
private int stock = 100;

public boolean seckill() {
    if (stock > 0) {
        stock--;  // 非原子操作，线程不安全
        return true;
    }
    return false;
}
```

### 3.3 并发容器使用

```java
// ✅ 正确：ConcurrentHashMap
private final Map<Long, List<CartItem>> userCartMap = new ConcurrentHashMap<>();

public void addCartItem(Long userId, CartItem item) {
    userCartMap.computeIfAbsent(userId, k -> new CopyOnWriteArrayList<>())
            .add(item);
}

// ❌ 错误：非线程安全HashMap
private final Map<Long, List<CartItem>> userCartMap = new HashMap<>();
```

### 3.4 不可变对象

```java
// ✅ 正确：不可变对象
public final class UserDTO {
    private final Long userId;
    private final String userName;

    public UserDTO(Long userId, String userName) {
        this.userId = userId;
        this.userName = userName;
    }

    // 无setter方法，需修改时返回新对象
    public UserDTO withUserName(String newName) {
        return new UserDTO(this.userId, newName);
    }
}
```

## 四、ThreadLocal规范 [MUST]

### 4.1 使用规范

```yaml
rules:
  - 必须在finally或拦截器afterCompletion中调用remove()
  - 避免跨线程传递（需使用TransmittableThreadLocal）
  - 初始化用withInitial()
```

```java
// ✅ 正确：使用后清理
private static final ThreadLocal<User> USER_HOLDER = new ThreadLocal<>();

@Override
public boolean preHandle(HttpServletRequest request, ...) {
    USER_HOLDER.set(getCurrentUser());
    return true;
}

@Override
public void afterCompletion(HttpServletRequest request, ...) {
    USER_HOLDER.remove();  // 必须清理
}

// ❌ 错误：未清理ThreadLocal
public void process() {
    USER_HOLDER.set(user);
    // 未调用remove()，线程复用时数据混乱
}
```

### 4.2 跨线程池传递

```java
// ✅ 正确：使用TransmittableThreadLocal
private static final TransmittableThreadLocal<String> TRACE_ID = new TransmittableThreadLocal<>();

// 配合TTL线程池使用
ExecutorService executor = TtlExecutors.getTtlExecutorService(originalExecutor);
```

## 五、并发工具类规范 [SHOULD]

### 5.1 CountDownLatch

```java
// 等待多线程完成
CountDownLatch latch = new CountDownLatch(3);

executor.submit(() -> {
    try {
        doTask1();
    } finally {
        latch.countDown();
    }
});
// ... 其他任务

latch.await(30, TimeUnit.SECONDS);  // 超时等待
```

### 5.2 Semaphore

```java
// 控制并发访问量
private final Semaphore semaphore = new Semaphore(100);

public Result<String> limitedApi() {
    if (!semaphore.tryAcquire(3, TimeUnit.SECONDS)) {
        return Result.fail("系统繁忙");
    }
    try {
        return doProcess();
    } finally {
        semaphore.release();  // 必须释放
    }
}
```

### 5.3 CyclicBarrier

```java
// 多线程同步等待
CyclicBarrier barrier = new CyclicBarrier(3, () -> {
    // 所有线程到达后执行
    System.out.println("所有线程准备完毕");
});

executor.submit(() -> {
    prepare();
    barrier.await();  // 等待其他线程
    execute();
});
```

## 六、异步任务规范 [MUST]

### 6.1 异常处理

```java
// ✅ 正确：异步任务捕获异常
CompletableFuture.supplyAsync(() -> {
    return doTask();
}, executor).exceptionally(e -> {
    log.error("异步任务失败", e);
    return defaultValue;
});

// ✅ 正确：线程池配置UncaughtExceptionHandler
ThreadFactory factory = new ThreadFactoryBuilder()
    .setNameFormat("async-thread-%d")
    .setUncaughtExceptionHandler((t, e) -> {
        log.error("线程异常，thread:{}", t.getName(), e);
    })
    .build();

// ❌ 错误：吞异常
executor.submit(() -> {
    doTask();  // 异常被吞掉，无法排查
});
```

## 七、日期时间规范 [MUST]

### 7.1 线程安全的日期处理

```java
// ❌ 错误：SimpleDateFormat非线程安全
private static final SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

// ✅ 正确：使用DateTimeFormatter
private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

public String formatDate(LocalDateTime dateTime) {
    return formatter.format(dateTime);
}
```

## 八、禁止操作 [MUST]

```yaml
prohibited:
  - Thread.stop()     # 已废弃，不安全
  - Thread.suspend()  # 已废弃，不安全
  - 循环中new Thread()  # 线程泄漏
  - 无界队列           # OOM风险
```

```java
// ❌ 错误：循环中创建线程
for (int i = 0; i < 100; i++) {
    new Thread(() -> doTask()).start();  // 线程泄漏
}

// ✅ 正确：使用线程池
for (int i = 0; i < 100; i++) {
    executor.submit(() -> doTask());
}
```

## 九、反模式检查清单

| 序号 | 反模式 | 检测方式 |
|------|--------|----------|
| 1 | 使用Executors创建线程池 | 检查newFixedThreadPool等 |
| 2 | 多线程共享HashMap/ArrayList | 检查非并发容器的共享使用 |
| 3 | 静态变量无锁修改 | 检查static变量的并发修改 |
| 4 | synchronized锁粒度过粗 | 检查是否包含IO操作 |
| 5 | 多锁获取顺序不一致 | 检查锁获取顺序 |
| 6 | ThreadLocal未remove | 检查afterCompletion/finally |
| 7 | 使用SimpleDateFormat | 检查日期格式化方式 |
| 8 | 异步任务未处理异常 | 检查exceptionally处理 |
| 9 | 无界队列LinkedBlockingQueue | 检查队列类型 |
| 10 | 循环中new Thread() | 检查for循环内的线程创建 |
