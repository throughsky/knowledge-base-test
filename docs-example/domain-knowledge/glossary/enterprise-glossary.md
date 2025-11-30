# 企业术语词典 (Enterprise Glossary)

**最后更新**: 2025-11-30
**负责人**: @架构委员会

---

## 概述

本词典统一了企业内的业务和技术术语定义，建立"通用语言"，消除团队间的沟通歧义。

<!-- AI-CONTEXT
企业术语词典是跨团队沟通的基础。
AI在理解业务需求或生成文档时应使用这些标准术语。
注意区分业务术语和技术术语。
-->

---

## 业务术语

| 术语 | 英文 | 定义 | 使用上下文 | 关联代码/服务 |
|------|------|------|------------|---------------|
| **GMV** | Gross Merchandise Volume | 商品交易总额，衡量平台成交规模的核心指标 | 运营报表、KPI | `AnalyticsService.calculateGmv()` |
| **SKU** | Stock Keeping Unit | 库存量单位，商品的最小可销售单元 | 库存管理、商品上架 | `ProductSku.java` |
| **SPU** | Standard Product Unit | 标准产品单元，同款商品的抽象 | 商品管理 | `Product.java` |
| **AOV** | Average Order Value | 平均客单价 = GMV / 订单数 | 运营分析 | `AnalyticsService.getAov()` |
| **DAU/MAU** | Daily/Monthly Active Users | 日/月活跃用户数 | 用户分析 | 分析服务 |
| **履约** | Fulfillment | 订单从确认到送达的全过程 | 订单流程 | `FulfillmentService` |
| **核销** | Verification | 优惠券或权益的使用确认 | 营销活动 | `CouponService.verify()` |

---

## 技术术语

| 术语 | 英文 | 定义 | 使用上下文 |
|------|------|------|------------|
| **聚合根** | Aggregate Root | DDD中保证一致性边界的实体 | 领域建模 |
| **限界上下文** | Bounded Context | 业务领域的边界定义 | 微服务划分 |
| **幂等性** | Idempotency | 多次执行产生相同结果的特性 | API设计 |
| **熔断** | Circuit Breaker | 防止故障扩散的保护机制 | 服务治理 |
| **降级** | Degradation | 在故障时提供有限功能 | 容错设计 |
| **灰度发布** | Canary Release | 逐步放量的部署策略 | 发布管理 |

---

## 缩写对照

| 缩写 | 全称 | 含义 |
|------|------|------|
| **API** | Application Programming Interface | 应用程序接口 |
| **SLA** | Service Level Agreement | 服务等级协议 |
| **SLO** | Service Level Objective | 服务等级目标 |
| **SLI** | Service Level Indicator | 服务等级指标 |
| **P99** | 99th Percentile | 99分位数 |
| **QPS** | Queries Per Second | 每秒查询数 |
| **TPS** | Transactions Per Second | 每秒事务数 |
| **RT** | Response Time | 响应时间 |
| **ADR** | Architecture Decision Record | 架构决策记录 |

---

## 状态术语

### 订单状态

| 状态 | 英文 | 含义 |
|------|------|------|
| 待支付 | PENDING_PAYMENT | 订单已创建，等待支付 |
| 已支付 | PAID | 支付完成 |
| 处理中 | PROCESSING | 仓库处理中 |
| 已发货 | SHIPPED | 已交付物流 |
| 已签收 | DELIVERED | 用户已签收 |
| 已完成 | COMPLETED | 订单完结 |
| 已取消 | CANCELLED | 订单取消 |
| 已退款 | REFUNDED | 已完成退款 |

### 用户状态

| 状态 | 英文 | 含义 |
|------|------|------|
| 待激活 | PENDING | 注册未激活 |
| 活跃 | ACTIVE | 正常使用 |
| 已停用 | INACTIVE | 账户停用 |
| 已锁定 | LOCKED | 安全原因锁定 |

---

## 词典维护规则

1. **新术语审批**: 新术语需经架构委员会审核
2. **修改流程**: 修改定义需提交PR并获得审批
3. **定期审查**: 每季度审查词典完整性
4. **同步更新**: 代码中的术语需与词典保持一致

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| 1.0 | 2025-11-30 | 初始版本 | @架构委员会 |
