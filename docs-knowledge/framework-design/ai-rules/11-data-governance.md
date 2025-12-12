# 数据治理规范 - AI编码约束

> 适用于：数据标准、数据质量、分库分表、数据生命周期场景

## 一、数据标准规范 [MUST]

### 1.1 字段命名标准

| 类型 | 格式 | Java类型 | MySQL类型 | 示例 |
|------|------|----------|-----------|------|
| 主键 | {表名}_id | Long | BIGINT | order_id |
| 外键 | {关联表}_id | Long | BIGINT | user_id |
| 金额 | xxx_amount | BigDecimal | DECIMAL(19,2) | pay_amount |
| 时间 | xxx_time | LocalDateTime | DATETIME | create_time |
| 状态 | xxx_status | Integer | TINYINT | order_status |
| 标识 | is_xxx | Boolean | TINYINT(1) | is_deleted |

### 1.2 数据字典管理

```yaml
required_fields:
  - 表名
  - 字段名
  - 字段类型
  - 是否非空
  - 敏感级别（一般/重要/核心）
  - 业务含义
  - 保留期限
```

### 1.3 标准落地

```yaml
tools:
  - DataHub/Navicat管理数据字典
  - MyBatis插件校验字段命名
  - CI/CD集成校验不通过阻断
```

## 二、数据质量规范 [MUST]

### 2.1 入库校验

```java
// ✅ 正确：使用JSR303校验
@Data
public class OrderCreateRequest {
    @NotNull(message = "用户ID不能为空")
    private Long userId;

    @NotNull(message = "订单金额不能为空")
    @DecimalMin(value = "0.01", message = "订单金额必须大于0")
    private BigDecimal amount;

    @NotNull(message = "订单状态不能为空")
    @EnumValue(enumClass = OrderStatusEnum.class, message = "订单状态非法")
    private Integer orderStatus;
}

// ✅ 正确：业务校验
public void createOrder(OrderCreateRequest request) {
    // 跨服务校验：用户是否存在
    User user = userService.getById(request.getUserId());
    if (user == null) {
        throw new BusinessException("用户不存在");
    }

    // 跨表校验：库存是否充足
    Integer stock = productService.getStock(request.getProductId());
    if (stock < request.getQuantity()) {
        throw new BusinessException("库存不足");
    }
}
```

### 2.2 质量监控

```yaml
metrics:
  accuracy:
    - 唯一索引重复数
    - 枚举值非法数
    threshold: >0告警
  completeness:
    - 核心字段空值率
    - 字段缺失率
    threshold: >1%告警
  consistency:
    - 订单表与支付表金额不一致数
    threshold: >0告警
```

```java
// ✅ 正确：暴露质量指标
@Component
public class DataQualityMetrics implements MeterBinder {
    @Autowired
    private OrderMapper orderMapper;

    @Override
    public void bindTo(MeterRegistry registry) {
        // 订单表非法状态数
        Gauge.builder("data_quality_order_invalid_status_count",
            () -> orderMapper.countByOrderStatusNotIn(Arrays.asList(0,1,2)))
            .description("订单表非法状态数量")
            .register(registry);

        // 支付金额空值率
        Gauge.builder("data_quality_order_pay_amount_null_rate",
            () -> {
                long total = orderMapper.count();
                long nullCount = orderMapper.countByPayAmountIsNull();
                return total == 0 ? 0 : (double) nullCount / total;
            })
            .register(registry);
    }
}
```

### 2.3 数据清洗

```yaml
rules:
  - 定时任务自动清洗
  - 清洗前备份原数据
  - 清洗后发送报告
```

## 三、分库分表规范 [MUST]

### 3.1 分片策略选型

| 场景 | 分片键 | 策略 | 示例 |
|------|--------|------|------|
| 用户数据 | user_id | Hash取模 | user_id % 4 |
| 订单数据 | user_id | Hash取模 | user_id % 4 |
| 日志数据 | create_time | 按时间范围 | 按月分表 |

### 3.2 Sharding-JDBC配置

```yaml
spring:
  shardingsphere:
    datasource:
      names: ds0,ds1
      ds0:
        url: jdbc:mysql://db0:3306/mall
      ds1:
        url: jdbc:mysql://db1:3306/mall
    rules:
      sharding:
        tables:
          order_info:
            actual-data-nodes: ds$->{0..1}.order_info_$->{0..3}
            database-strategy:
              standard:
                sharding-column: user_id
                sharding-algorithm-name: db-hash
            table-strategy:
              standard:
                sharding-column: user_id
                sharding-algorithm-name: table-hash
        sharding-algorithms:
          db-hash:
            type: INLINE
            props:
              algorithm-expression: ds$->{user_id % 2}
          table-hash:
            type: INLINE
            props:
              algorithm-expression: order_info_$->{user_id % 4}
```

### 3.3 分布式ID生成

```java
// ✅ 正确：雪花算法（防时钟回拨）
public class SnowflakeIdGenerator {
    private static final long START_TIMESTAMP = 1704067200000L;
    private static final int WORKER_ID_BITS = 5;
    private static final int SEQUENCE_BITS = 12;

    private final long workerId;
    private final long dataCenterId;
    private long sequence = 0L;
    private long lastTimestamp = -1L;

    public synchronized long nextId() {
        long timestamp = System.currentTimeMillis();

        // 时钟回拨处理
        if (timestamp < lastTimestamp) {
            long waitTime = lastTimestamp - timestamp;
            if (waitTime < 1000) {
                Thread.sleep(waitTime + 1);
                timestamp = System.currentTimeMillis();
            } else {
                throw new RuntimeException("时钟回拨超出阈值");
            }
        }

        if (lastTimestamp == timestamp) {
            sequence = (sequence + 1) & SEQUENCE_MASK;
            if (sequence == 0) {
                timestamp = nextMillis(lastTimestamp);
            }
        } else {
            sequence = 0L;
        }

        lastTimestamp = timestamp;

        return ((timestamp - START_TIMESTAMP) << TIMESTAMP_SHIFT)
                | (dataCenterId << DATA_CENTER_ID_SHIFT)
                | (workerId << WORKER_ID_SHIFT)
                | sequence;
    }
}

// ❌ 错误：UUID（无序、占空间）
String id = UUID.randomUUID().toString();
```

### 3.4 分片键选择

```yaml
rules:
  - 选择查询频率最高的字段
  - 避免跨分片查询
  - 考虑数据分布均匀性
```

```java
// ✅ 正确：按分片键查询
orderMapper.selectByUserId(userId);  // 单分片查询

// ❌ 错误：跨分片全表扫描
orderMapper.selectByOrderNo(orderNo);  // 未带分片键
```

## 四、数据血缘规范 [SHOULD]

### 4.1 自动化采集

```java
// MyBatis插件采集SQL血缘
@Intercepts({
    @Signature(type = Executor.class, method = "query", args = {...})
})
public class LineageInterceptor implements Interceptor {
    @Override
    public Object intercept(Invocation invocation) throws Throwable {
        BoundSql boundSql = ms.getBoundSql(parameter);
        String sql = boundSql.getSql();

        // 解析SQL获取表和字段
        Statement statement = CCJSqlParserUtil.parse(sql);
        TablesNamesFinder tablesNamesFinder = new TablesNamesFinder();
        List<String> tableList = tablesNamesFinder.getTableList(statement);

        // 发送血缘信息到Atlas
        lineageService.sendLineage(tableList, interfaceName);

        return invocation.proceed();
    }
}
```

### 4.2 血缘应用

```yaml
use_cases:
  - 影响分析：字段变更前评估影响范围
  - 问题定位：数据异常时追溯来源
  - 合规审计：敏感数据流转追踪
```

## 五、数据安全规范 [MUST]

### 5.1 分级加密

| 敏感级别 | 加密算法 | 密钥管理 | 示例 |
|----------|----------|----------|------|
| 核心 | SM4+信封加密 | KMS | 身份证、银行卡 |
| 重要 | AES-256 | 配置中心加密 | 手机号、邮箱 |
| 一般 | 可逆脱敏 | 无 | 浏览记录 |

```java
// ✅ 正确：SM4加密（国密）
public class Sm4Utils {
    public static String encrypt(String data, String key) {
        SM4Engine engine = new SM4Engine();
        KeyParameter keyParam = new KeyParameter(Hex.decode(key));
        engine.init(true, keyParam);
        byte[] encrypted = new byte[engine.getOutputSize(data.getBytes().length)];
        engine.processBytes(data.getBytes(), 0, data.length(), encrypted, 0);
        return Hex.toHexString(encrypted);
    }
}
```

### 5.2 访问控制

```java
// ✅ 正确：细粒度数据权限
@PreAuthorize("@dataPermService.hasPermission('order', 'read')")
@DataPermission(table = "order_info", column = "user_id")
public List<Order> listOrders(OrderQuery query) {
    // MyBatis拦截器自动追加数据权限条件
    return orderMapper.selectList(query);
}
```

### 5.3 审计日志

```java
// ✅ 正确：敏感数据访问审计
@AuditLog(dataType = "sensitive", operation = "查询用户手机号")
public String getUserPhone(Long userId) {
    return userMapper.selectPhoneById(userId);
}
```

## 六、数据生命周期规范 [MUST]

### 6.1 冷热分层

| 层级 | 访问频率 | 存储介质 | 保留时长 |
|------|----------|----------|----------|
| 热数据 | 日均≥1次 | MySQL主库+SSD | 1个月 |
| 温数据 | 日均<1次 | MySQL从库+HDD | 6个月 |
| 冷数据 | 月均<1次 | OSS/S3 | 3年 |
| 归档 | 年均<1次 | 低成本存储 | 5年 |

### 6.2 自动迁移

```java
// ✅ 正确：定时迁移冷数据
@Scheduled(cron = "0 0 1 * * ?")  // 每日凌晨1点
public void migrateColdData() {
    // 1. 查询温数据
    LocalDateTime oneMonthAgo = LocalDateTime.now().minusMonths(1);
    List<OrderDO> warmData = orderMapper.queryByCreateTimeBefore(oneMonthAgo);

    // 2. 导出为Parquet格式
    ParquetUtils.write(warmData, "/tmp/order_cold.parquet");

    // 3. 上传到OSS
    ossClient.putObject("cold-data-bucket", "order/" + LocalDate.now() + ".parquet",
        new File("/tmp/order_cold.parquet"));

    // 4. 删除MySQL数据
    orderMapper.deleteByCreateTimeBefore(oneMonthAgo);

    // 5. 校验完整性
    if (!verifyIntegrity()) {
        alertService.send("冷数据迁移失败");
    }
}
```

### 6.3 数据销毁

```yaml
rules:
  - 电子数据：多次覆写(≥3次)+逻辑删除
  - 云存储：调用合规删除API
  - 销毁日志：保留至少3年
```

## 七、分区表管理 [SHOULD]

### 7.1 按时间分区

```sql
-- 创建分区表
CREATE TABLE user_browse_log (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    browse_time DATETIME NOT NULL
) PARTITION BY RANGE (TO_DAYS(browse_time)) (
    PARTITION p202401 VALUES LESS THAN (TO_DAYS('2024-02-01')),
    PARTITION p202402 VALUES LESS THAN (TO_DAYS('2024-03-01')),
    PARTITION p202403 VALUES LESS THAN (TO_DAYS('2024-04-01'))
);
```

### 7.2 自动管理分区

```java
// ✅ 正确：定时新增/删除分区
@Scheduled(cron = "0 0 2 1 * ?")  // 每月1日凌晨2点
public void managePartition() {
    // 新增下月分区
    LocalDate nextMonth = LocalDate.now().plusMonths(1);
    String addSql = String.format(
        "ALTER TABLE user_browse_log ADD PARTITION (PARTITION p%s VALUES LESS THAN (TO_DAYS('%s')))",
        nextMonth.format(DateTimeFormatter.ofPattern("yyyyMM")),
        nextMonth.withDayOfMonth(1).toString()
    );
    jdbcTemplate.execute(addSql);

    // 删除3个月前的分区
    LocalDate threeMonthsAgo = LocalDate.now().minusMonths(3);
    String dropSql = String.format(
        "ALTER TABLE user_browse_log DROP PARTITION p%s",
        threeMonthsAgo.format(DateTimeFormatter.ofPattern("yyyyMM"))
    );
    jdbcTemplate.execute(dropSql);
}
```

## 八、反模式检查清单

| 序号 | 反模式 | 检测方式 |
|------|--------|----------|
| 1 | 数据标准缺失 | 检查数据字典完整性 |
| 2 | 单表无限制膨胀 | 检查表行数阈值 |
| 3 | 分布式ID用UUID | 检查ID生成方式 |
| 4 | 敏感数据明文存储 | 检查加密配置 |
| 5 | 冷热数据未分层 | 检查数据存储位置 |
| 6 | 血缘靠人工记录 | 检查采集插件配置 |
| 7 | 跨分片全表查询 | 检查SQL是否带分片键 |
| 8 | 数据销毁不彻底 | 检查销毁日志 |
| 9 | 无数据质量监控 | 检查Prometheus指标 |
| 10 | 分区表未自动管理 | 检查定时任务 |
