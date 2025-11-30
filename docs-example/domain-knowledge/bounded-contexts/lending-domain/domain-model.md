# 借贷领域模型 (Lending Domain Model)

**限界上下文**: Lending Context
**上下文所有者**: DeFi借贷团队
**版本**: 1.0
**最后更新**: 2025-11-30

---

## 领域概述

借贷领域负责管理去中心化借贷协议，包括抵押品管理、借款发放、利率模型、清算机制和风险控制。本领域是Web3金融服务的核心DeFi协议，为用户提供链上借贷服务。

<!-- AI-CONTEXT
借贷领域核心职责：
1. 抵押品存入与管理
2. 借款发放与还款
3. 利率计算与调整
4. 清算执行与保护
5. 风险参数管理
关键约束：抵押率必须满足安全阈值，清算机制必须可靠执行
-->

---

## 核心概念 (Ubiquitous Language)

### 聚合根 (Aggregate Roots)

#### LendingPool (借贷池)
```yaml
定义: 单一资产的借贷市场
属性:
  - poolId: UUID
  - asset: AssetInfo # 借贷资产
  - totalDeposits: BigDecimal # 总存款
  - totalBorrows: BigDecimal # 总借款
  - availableLiquidity: BigDecimal # 可用流动性
  - utilizationRate: BigDecimal # 利用率
  - depositAPY: BigDecimal # 存款年化
  - borrowAPY: BigDecimal # 借款年化
  - interestRateModel: InterestRateModel # 利率模型
  - reserveFactor: BigDecimal # 储备金比例
  - reserveBalance: BigDecimal # 储备金余额
  - collateralFactor: BigDecimal # 抵押因子
  - liquidationThreshold: BigDecimal # 清算阈值
  - liquidationPenalty: BigDecimal # 清算罚金
  - borrowCap: BigDecimal # 借款上限
  - supplyCap: BigDecimal # 存款上限
  - contractAddress: Address
  - status: PoolStatus
  - createdAt: Timestamp
  - updatedAt: Timestamp

不变式:
  - availableLiquidity = totalDeposits - totalBorrows
  - utilizationRate = totalBorrows / totalDeposits
  - 0 < collateralFactor < liquidationThreshold < 1
```

#### UserAccount (用户账户)
```yaml
定义: 用户在借贷协议中的账户
属性:
  - accountId: UUID
  - userId: UUID
  - deposits: List<DepositPosition> # 存款仓位
  - borrows: List<BorrowPosition> # 借款仓位
  - totalCollateralValue: BigDecimal # 总抵押价值 (USD)
  - totalBorrowValue: BigDecimal # 总借款价值 (USD)
  - healthFactor: BigDecimal # 健康因子
  - availableBorrowCapacity: BigDecimal # 可借额度
  - netAPY: BigDecimal # 净收益率
  - status: AccountStatus
  - lastUpdateAt: Timestamp

不变式:
  - healthFactor = (totalCollateralValue * weightedLiqThreshold) / totalBorrowValue
  - healthFactor >= 1 (否则可被清算)
```

#### Liquidation (清算)
```yaml
定义: 清算事件
属性:
  - liquidationId: UUID
  - liquidatedAccount: UUID # 被清算账户
  - liquidatorAccount: UUID # 清算人
  - collateralAsset: AssetInfo # 抵押资产
  - debtAsset: AssetInfo # 债务资产
  - debtRepaid: BigDecimal # 偿还债务
  - collateralSeized: BigDecimal # 获得抵押品
  - liquidationBonus: BigDecimal # 清算奖励
  - healthFactorBefore: BigDecimal
  - healthFactorAfter: BigDecimal
  - txHash: String
  - timestamp: Timestamp
  - status: LiquidationStatus

不变式:
  - 清算前healthFactor < 1
  - 清算后healthFactor应改善
```

### 实体 (Entities)

#### DepositPosition (存款仓位)
```yaml
定义: 用户在特定池的存款
属性:
  - positionId: UUID
  - accountId: UUID
  - poolId: UUID
  - depositAmount: BigDecimal # 存款本金
  - aTokenBalance: BigDecimal # aToken余额
  - interestEarned: BigDecimal # 已赚取利息
  - asCollateral: Boolean # 是否作为抵押
  - depositTxHash: String
  - createdAt: Timestamp
  - updatedAt: Timestamp

说明: aToken余额随利息累积增长
```

#### BorrowPosition (借款仓位)
```yaml
定义: 用户在特定池的借款
属性:
  - positionId: UUID
  - accountId: UUID
  - poolId: UUID
  - principalAmount: BigDecimal # 借款本金
  - accruedInterest: BigDecimal # 应付利息
  - totalDebt: BigDecimal # 总债务
  - interestRateMode: InterestRateMode # 利率模式
  - stableBorrowRate: BigDecimal # 稳定利率 (如适用)
  - borrowTxHash: String
  - createdAt: Timestamp
  - updatedAt: Timestamp

不变式: totalDebt = principalAmount + accruedInterest
```

#### InterestRateModel (利率模型)
```yaml
定义: 利率计算模型
属性:
  - modelId: UUID
  - modelType: ModelType # 模型类型
  - baseRate: BigDecimal # 基础利率
  - slope1: BigDecimal # 低利用率斜率
  - slope2: BigDecimal # 高利用率斜率
  - optimalUtilization: BigDecimal # 最优利用率 (拐点)
  - maxRate: BigDecimal # 最高利率

计算公式:
  当 utilization <= optimal:
    rate = baseRate + utilization * slope1 / optimal
  当 utilization > optimal:
    rate = baseRate + slope1 + (utilization - optimal) * slope2 / (1 - optimal)
```

#### RepaymentRecord (还款记录)
```yaml
定义: 借款还款记录
属性:
  - repaymentId: UUID
  - borrowPositionId: UUID
  - repayAmount: BigDecimal # 还款金额
  - principalRepaid: BigDecimal # 偿还本金
  - interestRepaid: BigDecimal # 偿还利息
  - remainingDebt: BigDecimal # 剩余债务
  - txHash: String
  - repaidAt: Timestamp
```

### 值对象 (Value Objects)

```yaml
PoolStatus:
  枚举值:
    - ACTIVE # 正常运行
    - PAUSED # 暂停
    - FROZEN # 冻结 (只能还款、提取)
    - DEPRECATED # 已废弃

AccountStatus:
  枚举值:
    - HEALTHY # 健康
    - AT_RISK # 风险中 (接近清算)
    - LIQUIDATABLE # 可清算
    - LIQUIDATED # 已清算

InterestRateMode:
  枚举值:
    - VARIABLE # 浮动利率
    - STABLE # 稳定利率

ModelType:
  枚举值:
    - LINEAR # 线性模型
    - KINKED # 拐点模型 (Compound风格)
    - DYNAMIC # 动态调整模型

LiquidationStatus:
  枚举值:
    - INITIATED
    - COMPLETED
    - FAILED

AssetInfo:
  assetId: String
  symbol: String
  decimals: Integer
  priceUSD: BigDecimal
  chainId: Integer
  contractAddress: Address

RiskParameters:
  collateralFactor: BigDecimal # 抵押因子 (LTV)
  liquidationThreshold: BigDecimal # 清算阈值
  liquidationPenalty: BigDecimal # 清算罚金
  borrowCap: BigDecimal # 借款上限
  supplyCap: BigDecimal # 存款上限
  reserveFactor: BigDecimal # 储备金因子
```

---

## 领域服务 (Domain Services)

### DepositService
```yaml
职责: 存款管理
方法:
  - deposit(userId, poolId, amount): DepositPosition
  - withdraw(positionId, amount): WithdrawResult
  - enableAsCollateral(positionId): Result
  - disableAsCollateral(positionId): Result

规则:
  - 存款获得等量aToken
  - 提款检查流动性
  - 禁用抵押检查健康因子
```

### BorrowService
```yaml
职责: 借款管理
方法:
  - borrow(userId, poolId, amount, rateMode): BorrowPosition
  - repay(positionId, amount): RepaymentRecord
  - switchRateMode(positionId, newMode): Result
  - calculateMaxBorrowable(accountId, poolId): BigDecimal

规则:
  - 借款前检查抵押充足
  - 借款后健康因子必须>1
  - 还款先还利息后还本金
```

### InterestService
```yaml
职责: 利率计算
方法:
  - calculateDepositAPY(poolId): BigDecimal
  - calculateBorrowAPY(poolId): BigDecimal
  - accrueInterest(poolId): AccrualResult
  - updateInterestRateModel(poolId, newModel): Result

规则:
  - 每区块累计利息
  - 存款APY = 借款APY * 利用率 * (1 - 储备金因子)
  - 利率根据利用率动态调整
```

### LiquidationService
```yaml
职责: 清算执行
方法:
  - checkLiquidatable(accountId): Boolean
  - calculateLiquidationAmount(accountId, debtAsset, collateralAsset): LiquidationParams
  - executeLiquidation(liquidatorId, accountId, debtAsset, collateralAsset, amount): Liquidation
  - getLiquidationOpportunities(): List<LiquidationOpportunity>

规则:
  - 健康因子<1时可清算
  - 单次最多清算50%债务 (close factor)
  - 清算人获得清算奖励 (如5-10%)
```

### RiskManagementService
```yaml
职责: 风险管理
方法:
  - calculateHealthFactor(accountId): BigDecimal
  - assessAccountRisk(accountId): RiskAssessment
  - updateRiskParameters(poolId, params): Result
  - monitorSystemRisk(): SystemRiskReport

规则:
  - 实时监控健康因子
  - 接近清算时发送预警
  - 系统风险过高时可暂停借款
```

### OracleService
```yaml
职责: 价格预言机
方法:
  - getAssetPrice(assetId): BigDecimal
  - updatePrice(assetId, price, source): PriceUpdate
  - validatePriceDeviation(assetId, newPrice): Boolean
  - getHistoricalPrice(assetId, timestamp): BigDecimal

规则:
  - 使用多源聚合价格
  - 价格偏离过大触发告警
  - 价格更新有延迟保护
```

---

## 领域事件 (Domain Events)

```yaml
PoolCreated:
  触发: 借贷池创建
  载荷: poolId, asset, interestRateModel
  订阅者: 前端服务, 统计服务

Deposited:
  触发: 存款完成
  载荷: positionId, accountId, poolId, amount, aTokenMinted
  订阅者: 利息服务, 统计服务

Withdrawn:
  触发: 提款完成
  载荷: positionId, amount, aTokenBurned
  订阅者: 利息服务, 统计服务

Borrowed:
  触发: 借款完成
  载荷: positionId, accountId, poolId, amount, rateMode
  订阅者: 风险服务, 统计服务

Repaid:
  触发: 还款完成
  载荷: repaymentId, positionId, amount, remainingDebt
  订阅者: 风险服务, 统计服务

CollateralToggled:
  触发: 抵押状态变更
  载荷: positionId, asCollateral, healthFactorAfter
  订阅者: 风险服务

LiquidationExecuted:
  触发: 清算执行
  载荷: liquidationId, liquidatedAccount, debtRepaid, collateralSeized
  订阅者: 统计服务, 通知服务, 审计服务

HealthFactorAlert:
  触发: 健康因子预警
  载荷: accountId, currentHF, threshold
  订阅者: 通知服务, 风控服务

InterestRateUpdated:
  触发: 利率更新
  载荷: poolId, newDepositAPY, newBorrowAPY, utilizationRate
  订阅者: 前端服务, 统计服务

PriceUpdated:
  触发: 价格更新
  载荷: assetId, oldPrice, newPrice, source
  订阅者: 风险服务, 清算服务

ReserveWithdrawn:
  触发: 储备金提取
  载荷: poolId, amount, recipient
  订阅者: 审计服务
```

---

## 上下文映射 (Context Mapping)

```
┌─────────────────────────────────────────────────────────────────┐
│                      Lending Context                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ LendingPool  │  │ UserAccount  │  │ Liquidation  │          │
│  │  (聚合根)    │  │  (聚合根)    │  │  (聚合根)    │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
          │                    │                    │
          │                    │                    │
          ▼                    ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│Stablecoin Context│ │ Staking Context │  │   RWA Context   │
│  - 稳定币借贷   │  │  - LST作为抵押  │  │  - RWA作为抵押  │
│  - 利息支付     │  │  - 收益组合     │  │  - 合规借贷     │
└─────────────────┘  └─────────────────┘  └─────────────────┘
          │                    │
          ▼                    ▼
┌─────────────────┐  ┌─────────────────┐
│ Custody Context │  │  Oracle Service │
│  - 资产托管     │  │  - 价格喂价     │
│  - 清算执行     │  │  - 多源聚合     │
└─────────────────┘  └─────────────────┘
          │
          ▼
┌─────────────────┐
│Compliance Context│
│  - 借贷合规     │
│  - 清算审计     │
└─────────────────┘

集成模式:
- Stablecoin: Partnership (双向借贷)
- Staking: Customer-Supplier (LST作为抵押品)
- RWA: Customer-Supplier (RWA代币作为抵押品)
- Custody: Customer-Supplier (资产托管和清算执行)
- Oracle: Anti-Corruption Layer (价格服务)
- Compliance: Conformist (合规报告)
```

---

## 接口契约摘要

### 对外提供的API

```yaml
# 借贷池
GET /api/v1/lending/pools
  - 获取所有借贷池
  - 公开接口

GET /api/v1/lending/pools/{poolId}
  - 获取池详情和利率

GET /api/v1/lending/pools/{poolId}/history
  - 获取利率历史

# 存款操作
POST /api/v1/lending/deposit
  - 存款
  - 请求体: { poolId, amount }

POST /api/v1/lending/withdraw
  - 提款
  - 请求体: { positionId, amount }

POST /api/v1/lending/collateral/toggle
  - 切换抵押状态
  - 请求体: { positionId, enable }

# 借款操作
POST /api/v1/lending/borrow
  - 借款
  - 请求体: { poolId, amount, rateMode }

POST /api/v1/lending/repay
  - 还款
  - 请求体: { positionId, amount }

GET /api/v1/lending/borrow/max
  - 获取最大可借额

# 账户
GET /api/v1/lending/account
  - 获取我的账户状态

GET /api/v1/lending/account/health
  - 获取健康因子

# 清算
GET /api/v1/lending/liquidations/opportunities
  - 获取清算机会 (清算人使用)

POST /api/v1/lending/liquidations/execute
  - 执行清算
  - 请求体: { accountId, debtAsset, collateralAsset, amount }

# 内部服务
POST /internal/v1/lending/interest/accrue
  - 触发利息累计
  - 供调度服务调用

GET /internal/v1/lending/accounts/{accountId}/risk
  - 获取账户风险评估
  - 供风控服务调用
```

---

## 风险参数示例

```yaml
# 主流资产
ETH:
  collateralFactor: 0.80  # 80% LTV
  liquidationThreshold: 0.85
  liquidationPenalty: 0.05  # 5%

USDC:
  collateralFactor: 0.85
  liquidationThreshold: 0.90
  liquidationPenalty: 0.04

# LST资产
stETH:
  collateralFactor: 0.75
  liquidationThreshold: 0.80
  liquidationPenalty: 0.07

# RWA资产
RWA_TOKEN:
  collateralFactor: 0.60
  liquidationThreshold: 0.70
  liquidationPenalty: 0.10
```

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| 1.0 | 2025-11-30 | 初始版本 | @领域架构师 |
