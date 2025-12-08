# 团队协作规范 - AI编码约束

> 适用于：Git分支管理、代码评审、变更管理、跨角色协作场景

## 一、分支管理规范 [MUST]

### 1.1 分支类型

| 分支类型 | 格式 | 用途 | 生命周期 |
|----------|------|------|----------|
| main | main | 生产环境基准 | 永久 |
| develop | develop | 开发集成基准 | 永久 |
| feature | feature/REQ-ID-描述 | 新功能开发 | 临时（合并后删除） |
| hotfix | hotfix/BUG-ID-描述 | 生产紧急修复 | 临时（合并后删除） |

### 1.2 分支命名

```yaml
format: {type}/REQ-{需求ID}-{简要描述}
examples:
  - feature/REQ-2025001-order-batch-create
  - hotfix/BUG-2025100-payment-timeout-fix
prohibited:
  - feature/test
  - feature/new-function
  - hotfix/fix
```

### 1.3 操作流程

```bash
# 1. 拉取feature分支
git checkout develop
git pull origin develop
git checkout -b feature/REQ-2025001-order-batch-create

# 2. 提交代码（必须包含配套文件）
git add src/main/java/com/mall/order/service/OrderBatchService.java
git add src/main/resources/db/migration/V1_20250105_REQ2025001_add_order_batch.sql
git add src/test/java/com/mall/order/service/OrderBatchServiceTest.java

# 3. 提交信息规范
git commit -m "feat(order): 新增订单批量创建接口 [REQ-2025001]"

# 4. 推送并创建MR
git push origin feature/REQ-2025001-order-batch-create
```

### 1.4 提交信息格式

```yaml
format: "{type}({scope}): {description} [REQ-ID]"
types:
  - feat: 新功能
  - fix: Bug修复
  - refactor: 重构
  - perf: 性能优化
  - test: 测试
  - docs: 文档
  - chore: 构建/工具
examples:
  - "feat(order): 新增订单批量创建接口 [REQ-2025001]"
  - "fix(payment): 修复支付超时问题 [BUG-2025100]"
```

### 1.5 Flyway脚本规范

```yaml
format: V{version}_{date}_{REQ-ID}_{description}.sql
examples:
  - V1_20250105_REQ2025001_add_order_batch_column.sql
  - V2_20250110_REQ2025002_create_product_index.sql
rules:
  - 必须与代码一起提交
  - 禁止修改已执行的脚本
  - 生产变更需DBA评审
```

## 二、代码评审规范 [MUST]

### 2.1 自动化前置检查

```yaml
# GitLab CI自动检查
automated_checks:
  - 代码规范（CheckStyle+SonarQube）
  - 单元测试覆盖率≥80%（JaCoCo）
  - 无Critical/Blocker问题
  - MyBatis使用#{}
  - 无硬编码密钥
```

### 2.2 MR模板

```markdown
## MR基本信息
- 关联需求：REQ-2025001（订单批量创建功能）
- 核心修改：OrderBatchService.java（180行）、Flyway脚本
- 测试情况：单元测试覆盖率85%；接口测试通过
- 依赖变更：无新增依赖

## Java核心评审点（必查）
1. 事务边界：@Transactional是否加在正确位置？rollbackFor是否指定？
2. 线程池：线程池参数是否合理？是否会引发OOM？
3. SQL性能：是否有索引？是否有全表扫描？
4. 缓存一致性：缓存更新策略是否正确？

## 风险说明
- 无破坏性变更
- 数据库影响：仅新增字段和索引
- 并发测试：压测1000QPS无超时
```

### 2.3 评审检查清单

#### 业务逻辑

| 检查项 | 反例 | 正例 |
|--------|------|------|
| 事务边界 | @Transactional加在子方法 | 加在入口方法+rollbackFor |
| 循环依赖 | Controller注入Service，Service又注入Controller | 用@Lazy或拆分服务 |
| 异常处理 | catch后只打印日志 | catch后抛出业务异常 |
| 线程池 | new Thread()执行任务 | 注入全局线程池 |

#### 性能与安全

| 检查项 | 反例 | 正例 |
|--------|------|------|
| SQL性能 | SELECT *；无索引 | 只查必要字段；有索引 |
| 缓存使用 | 无过期时间；先删后更 | 设过期时间；先更后删 |
| 并发安全 | static int计数 | AtomicInteger |
| JVM资源 | 一次加载1000条到内存 | 分页查询每次100条 |

#### 兼容性

| 检查项 | 反例 | 正例 |
|--------|------|------|
| 接口兼容 | 修改v1接口参数类型 | 新增v2接口 |
| 代码复用 | 3个Service都写日期格式化 | 抽为DateUtils工具类 |
| 配置管理 | 硬编码Redis地址 | @Value读取配置 |

## 三、变更管理规范 [MUST]

### 3.1 变更分类

| 类型 | 定义 | 审批级别 |
|------|------|----------|
| 微小变更 | 调整日志级别、新增监控指标 | 开发负责人 |
| 一般变更 | 新增接口、优化SQL索引 | 技术负责人 |
| 重大变更 | 分库分表、JVM参数调整、框架升级 | 技术+产品+运维联合审批 |

### 3.2 变更流程

```yaml
before:
  - 登记CMDB（变更内容、影响范围、执行时间）
  - 准备回滚方案
  - 非业务高峰期执行

during:
  - 灰度发布（先1个Pod，观察10分钟）
  - 慢启动（preStop延迟10秒）
  - 实时监控指标

after:
  - 开发验证
  - 测试验证
  - 观察30分钟
  - 无异常标记完成
```

### 3.3 回滚方案

```yaml
rollback_steps:
  1. 回滚代码（helm rollback）
  2. 回滚数据库（执行回滚脚本）
  3. 清理缓存（Redis删除相关key）
  4. 通知团队
```

### 3.4 灰度发布

```yaml
# K8s灰度发布
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 0
    maxSurge: 1

# 流量灰度（Istio）
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
spec:
  http:
    - match:
        - headers:
            x-canary:
              exact: "true"
      route:
        - destination:
            host: mall-order
            subset: canary
    - route:
        - destination:
            host: mall-order
            subset: stable
```

## 四、跨角色协作规范 [MUST]

### 4.1 开发→测试

```yaml
提测要求:
  - 自测通过（功能+接口自测）
  - 提测文档（含测试账号、场景说明）
  - 单元测试覆盖率≥80%
  - 关联Jira需求

Bug处理:
  - P0/P1：24小时内修复
  - P2：3天内修复
  - P3：迭代内修复
```

### 4.2 开发→运维

```yaml
部署要求:
  - Dockerfile符合规范
  - K8s YAML完整（资源限制、探针、反亲和）
  - 部署文档（启动参数、依赖服务）

故障处理:
  - 提供traceId
  - 告知最近变更
  - 提供排查思路
```

### 4.3 工具链联动

| 场景 | 工具组合 | 联动逻辑 |
|------|----------|----------|
| 需求→开发→测试 | Jira+GitLab+SonarQube | Jira关联GitLab分支→质量达标→状态更新 |
| 部署→监控 | GitLab CI+K8s+Prometheus | MR合并→CI构建→K8s部署→Prometheus监控 |
| 故障排查 | Arthas+ELK+SkyWalking | SkyWalking定位→Arthas排查→ELK查日志 |

## 五、文档规范 [SHOULD]

### 5.1 接口文档

```yaml
rules:
  - 使用Swagger/OpenAPI自动生成
  - 禁止手动编写接口文档
  - 代码修改自动更新文档
```

```java
// ✅ 正确：Swagger注解
@Operation(summary = "创建订单", description = "用户下单接口")
@ApiResponses({
    @ApiResponse(responseCode = "200", description = "创建成功"),
    @ApiResponse(responseCode = "400", description = "参数错误")
})
@PostMapping("/api/v1/orders")
public Result<Long> createOrder(@RequestBody @Valid OrderCreateRequest request) {
    return Result.success(orderService.createOrder(request));
}
```

### 5.2 技术文档

```yaml
required_docs:
  - 架构设计文档
  - 数据库设计文档
  - 部署文档
  - 运维手册
location: 统一文档平台（Confluence/语雀）
```

## 六、故障复盘规范 [MUST]

### 6.1 复盘流程

```yaml
steps:
  1. 故障时间线梳理
  2. 根因分析（5 Why）
  3. 影响评估
  4. 改进措施
  5. 责任认定（非追责）
  6. 经验沉淀
```

### 6.2 复盘报告模板

```markdown
## 故障概述
- 故障时间：2025-01-05 10:00 - 10:30
- 影响范围：订单服务，影响用户1000人
- 故障级别：P1

## 时间线
- 10:00 监控告警：订单服务错误率>5%
- 10:05 值班人员响应，查看日志
- 10:15 定位原因：数据库连接池耗尽
- 10:20 扩容数据库连接池
- 10:30 服务恢复正常

## 根因分析
直接原因：数据库连接池配置过小（maxPoolSize=10）
根本原因：新增批量查询接口未评估连接池压力

## 改进措施
- 短期：连接池配置调整为maxPoolSize=50
- 长期：新增接口必须进行压测评审

## 责任认定
- 主责：开发人员（未评估连接池压力）
- 次责：评审人员（未发现问题）
```

## 七、反模式检查清单

| 序号 | 反模式 | 检测方式 |
|------|--------|----------|
| 1 | feature分支未提交Flyway脚本 | 检查MR文件列表 |
| 2 | MR代码量超500行 | GitLab MR统计 |
| 3 | 事务加在子方法 | 代码评审检查 |
| 4 | 生产变更未登记CMDB | CMDB记录查询 |
| 5 | 业务高峰期执行重大变更 | 变更时间检查 |
| 6 | 接口文档手动编写 | 检查Swagger配置 |
| 7 | 故障后无复盘 | 复盘记录查询 |
| 8 | 提交信息不规范 | Git log检查 |
| 9 | 合并未关联Jira | MR描述检查 |
| 10 | 评审只关注代码风格 | 评审记录检查 |
