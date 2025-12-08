## Java开发规范（七）| 并发编程规范—高并发场景的编码避坑指南

## 前言

高并发场景下，并发编程是提升系统吞吐量的核心手段，但也是“故障重灾区”——很多开发人员因不熟悉并发原理，写出看似“正常”却暗藏线程安全隐患的代码：

并发编程的核心目标是“**线程安全+性能均衡**”——既要保证多线程操作数据的一致性，又要避免过度同步导致的性能瓶颈。大厂的并发编程规范，是基于无数线上故障总结的“避坑指南”，从线程池、锁机制、线程安全、并发工具等维度，明确“能做什么、不能做什么、推荐怎么做”。

本文将拆解大厂必守的并发编程规范，每个规则都配正反示例和避坑指南，帮你在高并发场景下写出“安全、高效、稳定”的并发代码。

## 一、为什么并发编程必须“守规矩”？

不规范的并发编程，会导致数据不一致、性能崩溃等难以排查的故障，且故障具有随机性和隐蔽性，测试阶段往往难以发现：

### 反面案例：线程池不当使用+无锁共享变量，导致库存超卖

### 并发编程的3个核心价值

1. **线程安全**：保证多线程操作数据的一致性，避免超卖、余额错乱等业务故障；
2. **性能优化**：合理利用CPU资源，提升系统吞吐量（如秒杀场景从QPS 1000提升至10000）；
3. **稳定性保障**：避免线程泄漏、死锁、OOM等并发相关的系统级故障。

## 二、线程池规范【强制】：高并发的“资源调度核心”

线程池是并发编程的基础，其配置直接决定系统的并发能力和稳定性，禁止随意使用 `Executors`创建，必须手动配置核心参数。

### 1\. 核心规则：手动创建 `ThreadPoolExecutor`，拒绝 `Executors`

### 2\. 线程池参数配置（大厂标准）

参数

配置规则

核心线程数（corePoolSize）

CPU密集型任务（如计算）：核心线程数=CPU核数+1；IO密集型任务（如DB/HTTP调用）：核心线程数=CPU核数×2

最大线程数（maximumPoolSize）

IO密集型任务可设为核心线程数的2倍，避免线程过多导致上下文切换开销；CPU密集型任务与核心线程数一致

队列（workQueue）

必须使用有界队列（`ArrayBlockingQueue`），容量根据业务调整（如1000），禁止无界队列（`LinkedBlockingQueue`）

空闲线程存活时间（keepAliveTime）

非核心线程空闲时间，IO密集型设为60秒，CPU密集型设为10秒

拒绝策略（RejectedExecutionHandler）

核心业务用 `CallerRunsPolicy`（调用者执行，避免任务丢失）；非核心业务用 `AbortPolicy`（直接抛异常）

线程工厂（ThreadFactory）

自定义线程工厂，设置线程名（便于排查），设置为守护线程（避免阻塞JVM退出）

### 3\. 实战示例：按场景配置线程池

```
import com.google.common.util.concurrent.ThreadFactoryBuilder;
import java.util.concurrent.*;

@Configuration
public class ThreadPoolConfig { // CPU核数（通过Runtime获取，适配不同环境） private static final int CPU_CORES = Runtime.getRuntime().availableProcessors(); /** * IO密集型线程池（如数据库查询、HTTP调用） * 核心线程数=CPU核数×2，最大线程数=核心线程数×2，有界队列容量1000 */ @Bean(name = "ioIntensiveThreadPool") public ExecutorService ioIntensiveThreadPool() { ThreadFactory threadFactory = new ThreadFactoryBuilder() .setNameFormat("io-thread-%d") // 线程名：io-thread-0、io-thread-1... .setDaemon(true) // 守护线程 .build(); return new ThreadPoolExecutor( CPU_CORES * 2, // 核心线程数 CPU_CORES * 4, // 最大线程数 60, // 空闲线程存活时间（秒） TimeUnit.SECONDS, new ArrayBlockingQueue<>(1000), // 有界队列 threadFactory, new ThreadPoolExecutor.CallerRunsPolicy() // 拒绝策略：调用者执行 ); } /** * CPU密集型线程池（如计算、序列化） * 核心线程数=CPU核数+1，最大线程数=CPU核数+1，有界队列容量500 */ @Bean(name = "cpuIntensiveThreadPool") public ExecutorService cpuIntensiveThreadPool() { ThreadFactory threadFactory = new ThreadFactoryBuilder() .setNameFormat("cpu-thread-%d") .setDaemon(true) .build(); return new ThreadPoolExecutor( CPU_CORES + 1, CPU_CORES + 1, 10, TimeUnit.SECONDS, new ArrayBlockingQueue<>(500), threadFactory, new ThreadPoolExecutor.AbortPolicy() ); }
}

// 服务层使用
@Service
public class OrderService { @Autowired @Qualifier("ioIntensiveThreadPool") private ExecutorService ioIntensiveThreadPool; public void processOrderAsync(Order order) { ioIntensiveThreadPool.submit(() -> { // 异步处理订单（如调用物流接口、发送通知） log.info("异步处理订单，orderId:{}", order.getId()); logisticsService.sendOrder(order); }); }
}
```

### 4\. 避坑点

## 三、锁机制规范【强制】：线程安全的“同步屏障”

锁是解决线程安全问题的核心手段，但滥用锁会导致性能下降，需根据场景选择合适的锁类型，控制锁粒度。

### 1\. 锁选型规则：按场景选择锁类型

锁类型

适用场景

优点

缺点

`synchronized`

简单同步场景（如单例、简单方法同步）

用法简单、JVM优化好（偏向锁→轻量级锁→重量级锁）

锁粒度粗、无法中断、无法超时

`ReentrantLock`

复杂同步场景（如超时控制、中断、公平锁）

支持超时、中断、公平锁，锁粒度灵活

需手动释放锁（finally中调用unlock()）

`ReadWriteLock`

读多写少场景（如缓存查询、商品详情）

读操作共享，写操作互斥，性能优于独占锁

实现复杂，写操作会阻塞读操作

`StampedLock`

高并发读多写少场景（JDK 8+）

读操作无锁（乐观读），性能最优

不支持重入，使用复杂

### 2\. 实战示例：不同场景的锁使用

#### （1）`synchronized`：简单方法同步

```
@Service
public class StockService { private int stock = 100; /** * 简单扣库存：用synchronized修饰方法（锁当前对象） * 适用场景：并发量适中，无需复杂控制 */ public synchronized boolean decreaseStock(int quantity) { if (stock >= quantity) { stock -= quantity; log.info("扣库存成功，剩余库存:{}", stock); return true; } log.info("扣库存失败，库存不足"); return false; }
}
```

#### （2）`ReentrantLock`：支持超时和中断

```
@Service
public class OrderService { private final ReentrantLock lock = new ReentrantLock(); private final Map<Long, Order> orderMap = new HashMap<>(); /** * 创建订单：支持超时获取锁，避免死锁 */ public Long createOrder(OrderCreateRequest request) { Long orderId = generateOrderId(); boolean locked = false; try { // 尝试获取锁，最多等待3秒 locked = lock.tryLock(3, TimeUnit.SECONDS); if (locked) { // 临界区操作（线程安全） orderMap.put(orderId, buildOrder(request)); return orderId; } else { throw new ServiceException("创建订单过于频繁，请稍后重试"); } } catch (InterruptedException e) { log.error("获取订单锁失败", e); throw new ServiceException("创建订单失败"); } finally { // 必须手动释放锁 if (locked) { lock.unlock(); } } }
}
```

#### （3）`ReadWriteLock`：读多写少场景

```
@Service
public class ProductService { private final ReadWriteLock rwLock = new ReentrantReadWriteLock(); private final Lock readLock = rwLock.readLock(); private final Lock writeLock = rwLock.writeLock(); private final Map<Long, Product> productMap = new ConcurrentHashMap<>(); /** * 查询商品：读锁（共享） */ public Product getProductById(Long productId) { readLock.lock(); try { return productMap.get(productId); } finally { readLock.unlock(); } } /** * 更新商品：写锁（独占） */ public void updateProduct(Product product) { writeLock.lock(); try { productMap.put(product.getId(), product); } finally { writeLock.unlock(); } }
}
```

### 3\. 锁使用避坑点

## 四、线程安全规范【强制】：避免数据竞争的“核心准则”

线程安全的核心是“**共享变量的安全访问**”——要么让变量不共享，要么对共享变量的访问加同步措施，禁止无保护地修改共享变量。

### 1\. 核心规则：共享变量必须线程安全

### 2\. 实战示例：线程安全的共享变量访问

#### （1）原子类：简单计数/库存

```
@Service
public class SeckillService { // 原子类：线程安全的库存计数器 private final AtomicInteger stock = new AtomicInteger(100); /** * 秒杀扣库存：原子操作，无需手动加锁 */ public boolean seckill() { // CAS操作：compareAndSet（预期值，目标值） int currentStock = stock.get(); if (currentStock <= 0) { return false; } // 原子性扣减（避免并发修改导致的库存超卖） return stock.compareAndSet(currentStock, currentStock - 1); }
}
```

#### （2）并发容器：多线程共享数据存储

```
@Service
public class CartService { // ConcurrentHashMap：线程安全的Map，支持高并发读写 private final Map<Long, List<CartItem>> userCartMap = new ConcurrentHashMap<>(); /** * 添加商品到购物车：无需手动加锁 */ public void addCartItem(Long userId, CartItem item) { // computeIfAbsent：原子操作，避免NPE userCartMap.computeIfAbsent(userId, k -> new CopyOnWriteArrayList<>()) .add(item); } /** * 查询购物车：线程安全 */ public List<CartItem> getCartByUserId(Long userId) { return userCartMap.getOrDefault(userId, Collections.emptyList()); }
}
```

#### （3）不可变对象：共享无风险

```
// 不可变对象：final修饰类和字段，无setter方法
@Data
public final class UserDTO { private final Long userId; private final String userName; private final String phone; // 仅通过构造函数赋值 public UserDTO(Long userId, String userName, String phone) { this.userId = userId; this.userName = userName; this.phone = phone; } // 禁止setter方法，如需修改，返回新对象 public UserDTO withPhone(String newPhone) { return new UserDTO(this.userId, this.userName, newPhone); }
}
```

### 3\. 避坑点

## 五、并发工具类规范【推荐】：高效解决并发问题

JDK提供了丰富的并发工具类，合理使用可大幅简化并发编程，避免手动造轮子，同时提升代码安全性和性能。

### 1\. 核心工具类使用场景与示例

#### （1）`CountDownLatch`：等待多线程完成

#### （2）`CyclicBarrier`：多线程同步等待

#### （3）`Semaphore`：控制并发访问量

#### （4）`ThreadLocal`：线程私有数据存储

### 2\. 并发工具类避坑点

## 六、并发编程避坑其他规范【强制】

### 1\. 避免线程泄漏

### 2\. 线程安全的日期时间处理

### 3\. 异步任务异常处理

### 4\. 禁止使用 `stop()`和 `suspend()`

## 七、工具支持与落地保障

### 1\. 工具链集成

### 2\. 流程保障

## 八、常见反模式清单（团队自查用）

1. 使用 `Executors`创建线程池（如 `newFixedThreadPool`）；
2. 多线程共享 `HashMap`、`ArrayList`等非线程安全容器；
3. 多线程修改静态变量且不加锁，导致数据不一致；
4. `synchronized`修饰整个方法（包含IO操作），锁粒度过粗；
5. 多个锁获取顺序不一致，导致死锁；
6. `ThreadLocal`使用后未调用 `remove()`，导致内存泄漏；
7. 使用 `SimpleDateFormat`处理日期时间；
8. 异步任务未处理异常，导致故障无法排查；
9. 线程池任务队列使用无界队列（`LinkedBlockingQueue`）；
10. 循环中创建线程（`new Thread()`），导致线程泄漏。

## 九、落地 Checklist（团队上线前必查）

检查项

检查内容

责任人

完成标准

线程池配置

是否手动创建 `ThreadPoolExecutor`，参数合理

开发人员

核心线程数、队列、拒绝策略符合场景

锁使用

锁粒度是否合理，避免死锁和嵌套锁

代码评审人

仅对临界区加锁，无多层嵌套

共享变量

共享变量是否线程安全（原子类/并发容器）

开发人员

无裸奔的共享可变变量

ThreadLocal

使用后是否调用 `remove()`

开发人员

拦截器/任务结束时清理

并发工具

工具类选择合理，`acquire()`和 `release()`成对

开发人员

场景与工具匹配，无资源泄漏

异常处理

异步任务是否捕获异常

开发人员

无吞异常，异常可追溯

## 十、总结：并发编程是“双刃剑”，规范是“安全鞘”

并发编程能让系统在高并发场景下发挥最大性能，但也伴随着线程安全、死锁、OOM等风险——它就像一把“双刃剑”，规范则是保护系统的“安全鞘”。

大厂的并发编程规范，本质是“**场景化选型+精细化控制+全流程监控**”：线程池按IO/CPU密集型场景配置，锁按简单/复杂场景选择，共享变量按安全级别保护，同时通过工具监控和流程保障落地。这些规范看似繁琐，但每一条都来自线上故障的血与泪教训，能帮你避开90%的并发问题。

对于开发人员来说，掌握并发编程规范，不仅能写出“安全稳定”的高并发代码，更能理解底层原理，应对复杂场景的技术挑战。在实际开发中，需牢记“**无共享则无竞争，有共享则必同步**”的核心原则，结合业务场景选择合适的并发方案，平衡线程安全和性能。
