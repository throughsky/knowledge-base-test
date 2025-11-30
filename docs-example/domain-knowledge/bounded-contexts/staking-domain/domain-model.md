# 质押领域模型 (Staking Domain Model)

**限界上下文**: Staking Context
**上下文所有者**: 质押服务团队
**版本**: 1.0
**最后更新**: 2025-11-30

---

## 领域概述

质押领域负责管理用户的资产质押、收益计算、奖励分发和解质押流程。本领域支持多种质押模式，包括原生质押、流动性质押和质押池，为用户提供安全稳定的被动收益来源。

<!-- AI-CONTEXT
质押领域核心职责：
1. 资产质押与解质押管理
2. 收益率计算与APY维护
3. 奖励计算与分发
4. 流动性质押代币管理
5. 验证节点委托管理
关键约束：质押资产安全托管，收益计算透明可验证
-->

---

## 核心概念 (Ubiquitous Language)

### 聚合根 (Aggregate Roots)

#### StakingPool (质押池)
```yaml
定义: 质押资产的聚合池
属性:
  - poolId: UUID
  - name: String
  - poolType: PoolType # 质押池类型
  - stakingAsset: AssetInfo # 质押资产
  - rewardAsset: AssetInfo # 奖励资产
  - totalStaked: BigDecimal # 总质押量
  - totalRewardsDistributed: BigDecimal # 累计分发奖励
  - currentAPY: BigDecimal # 当前年化收益率
  - minStakeAmount: BigDecimal # 最小质押额
  - maxStakeAmount: BigDecimal # 最大质押额 (可选)
  - lockPeriod: Duration # 锁定期
  - cooldownPeriod: Duration # 冷却期
  - capacity: BigDecimal # 池容量
  - validatorInfo: ValidatorInfo # 验证节点信息 (如适用)
  - rewardSchedule: RewardSchedule # 奖励计划
  - status: PoolStatus
  - createdAt: Timestamp
  - updatedAt: Timestamp

不变式:
  - totalStaked <= capacity
  - currentAPY >= 0
  - 活跃池必须有足够奖励预算
```

#### StakingPosition (质押仓位)
```yaml
定义: 用户的单个质押仓位
属性:
  - positionId: UUID
  - userId: UUID
  - poolId: UUID
  - stakedAmount: BigDecimal # 质押数量
  - shares: BigDecimal # 份额 (用于流动性质押)
  - rewardsEarned: BigDecimal # 已赚取奖励
  - rewardsClaimed: BigDecimal # 已领取奖励
  - pendingRewards: BigDecimal # 待领取奖励
  - lastRewardUpdate: Timestamp # 最后奖励更新时间
  - stakingTxHash: String # 质押交易哈希
  - status: PositionStatus
  - lockEndTime: Timestamp # 锁定结束时间
  - unstakeRequestedAt: Timestamp # 请求解质押时间
  - createdAt: Timestamp
  - updatedAt: Timestamp

不变式:
  - stakedAmount >= 池最小质押额
  - 锁定期内不能解质押
  - pendingRewards = rewardsEarned - rewardsClaimed
```

#### LiquidStakingToken (流动性质押代币)
```yaml
定义: 代表质押权益的可流通代币
属性:
  - lstId: UUID
  - poolId: UUID # 关联的质押池
  - symbol: String # 代币符号 (如 stETH, rETH)
  - name: String
  - totalSupply: BigDecimal
  - exchangeRate: BigDecimal # 与原生资产的汇率
  - contractAddress: Address
  - chainId: Integer
  - status: TokenStatus
  - createdAt: Timestamp

不变式:
  - totalSupply * exchangeRate ≈ 池totalStaked
  - exchangeRate 随奖励积累增长
```

### 实体 (Entities)

#### StakeRequest (质押请求)
```yaml
定义: 质押操作请求
属性:
  - requestId: UUID
  - userId: UUID
  - poolId: UUID
  - amount: BigDecimal
  - sourceWallet: Address
  - status: RequestStatus
  - txHash: String
  - positionId: UUID # 创建的仓位
  - fee: BigDecimal # 质押费用
  - createdAt: Timestamp
  - processedAt: Timestamp

生命周期: PENDING → PROCESSING → COMPLETED | FAILED
```

#### UnstakeRequest (解质押请求)
```yaml
定义: 解质押操作请求
属性:
  - requestId: UUID
  - userId: UUID
  - positionId: UUID
  - amount: BigDecimal # 请求解质押数量
  - destinationWallet: Address
  - cooldownEndTime: Timestamp # 冷却期结束
  - status: UnstakeStatus
  - withdrawTxHash: String
  - actualAmount: BigDecimal # 实际到账
  - slashingPenalty: BigDecimal # 罚没 (如有)
  - createdAt: Timestamp
  - withdrawableAt: Timestamp
  - withdrawnAt: Timestamp

生命周期:
  REQUESTED → COOLDOWN → WITHDRAWABLE → WITHDRAWN
           → CANCELLED
```

#### RewardDistribution (奖励分发)
```yaml
定义: 奖励分发记录
属性:
  - distributionId: UUID
  - poolId: UUID
  - epoch: Integer # 分发周期
  - totalRewards: BigDecimal
  - rewardPerShare: BigDecimal # 每份额奖励
  - distributionTime: Timestamp
  - snapshotBlock: BigInteger # 快照区块
  - recipientCount: Integer
  - status: DistributionStatus
  - txHash: String
```

#### ClaimRecord (领取记录)
```yaml
定义: 用户领取奖励的记录
属性:
  - claimId: UUID
  - userId: UUID
  - positionId: UUID
  - claimedAmount: BigDecimal
  - claimTime: Timestamp
  - txHash: String
  - destinationWallet: Address
```

### 值对象 (Value Objects)

```yaml
PoolType:
  枚举值:
    - NATIVE_STAKING # 原生质押 (PoS验证)
    - LIQUID_STAKING # 流动性质押
    - YIELD_FARMING # 收益农场
    - FIXED_TERM # 固定期限
    - FLEXIBLE # 灵活存取

PoolStatus:
  枚举值:
    - ACTIVE # 活跃
    - PAUSED # 暂停
    - FULL # 已满
    - DEPRECATED # 已废弃

PositionStatus:
  枚举值:
    - ACTIVE # 活跃质押中
    - LOCKED # 锁定中
    - COOLDOWN # 冷却中
    - WITHDRAWABLE # 可提取
    - CLOSED # 已关闭

UnstakeStatus:
  枚举值:
    - REQUESTED
    - COOLDOWN
    - WITHDRAWABLE
    - WITHDRAWN
    - CANCELLED

AssetInfo:
  assetId: String
  symbol: String
  decimals: Integer
  chainId: Integer
  contractAddress: Address

ValidatorInfo:
  validatorAddress: Address
  validatorName: String
  commission: BigDecimal # 佣金率
  uptime: BigDecimal # 运行时间
  delegatorsCount: Integer

RewardSchedule:
  scheduleType: String # CONTINUOUS, EPOCH_BASED
  epochDuration: Duration # 周期时长
  rewardRate: BigDecimal # 奖励率
  totalBudget: BigDecimal # 总预算
  remainingBudget: BigDecimal # 剩余预算
  startTime: Timestamp
  endTime: Timestamp

SlashingCondition:
  conditionType: String # DOWNTIME, DOUBLE_SIGN
  penalty: BigDecimal # 罚没比例
  description: String
```

---

## 领域服务 (Domain Services)

### StakingService
```yaml
职责: 质押操作管理
方法:
  - stake(userId, poolId, amount): StakeRequest
  - validateStaking(request): ValidationResult
  - executeStaking(requestId): StakingResult
  - getPosition(positionId): StakingPosition
  - getUserPositions(userId): List<StakingPosition>

规则:
  - 质押前检查池容量
  - 验证最小质押额
  - 资产需先授权
```

### UnstakingService
```yaml
职责: 解质押操作管理
方法:
  - requestUnstake(positionId, amount): UnstakeRequest
  - cancelUnstake(requestId): Result
  - processWithdrawal(requestId): WithdrawalResult
  - checkWithdrawable(requestId): Boolean

规则:
  - 锁定期内不能解质押
  - 进入冷却期后开始倒计时
  - 冷却期结束后可提取
```

### RewardService
```yaml
职责: 奖励计算与分发
方法:
  - calculatePendingRewards(positionId): BigDecimal
  - updateRewards(poolId): RewardUpdate
  - distributeRewards(poolId, epoch): RewardDistribution
  - claimRewards(positionId): ClaimResult
  - autoCompound(positionId): CompoundResult

规则:
  - 奖励按份额比例计算
  - 支持自动复投
  - 分发前计算快照
```

### APYCalculationService
```yaml
职责: 收益率计算
方法:
  - calculateCurrentAPY(poolId): BigDecimal
  - calculateHistoricalAPY(poolId, period): APYHistory
  - projectAPY(poolId, assumptions): APYProjection
  - comparePoolAPY(poolIds): APYComparison

规则:
  - APY包含基础奖励和额外激励
  - 考虑复利效应
  - 历史APY基于实际分发
```

### LiquidStakingService
```yaml
职责: 流动性质押管理
方法:
  - mintLST(positionId): MintResult
  - burnLST(userId, amount): BurnResult
  - calculateExchangeRate(lstId): BigDecimal
  - rebase(lstId): RebaseResult

规则:
  - 汇率随奖励积累增长
  - 燃烧LST时返回原资产+收益
  - 定期Rebase更新汇率
```

---

## 领域事件 (Domain Events)

```yaml
PoolCreated:
  触发: 质押池创建
  载荷: poolId, poolType, stakingAsset, rewardAsset
  订阅者: 前端服务, 统计服务

Staked:
  触发: 质押完成
  载荷: positionId, userId, poolId, amount, txHash
  订阅者: 奖励服务, 统计服务, 通知服务

UnstakeRequested:
  触发: 解质押请求
  载荷: requestId, positionId, amount, cooldownEndTime
  订阅者: 通知服务

UnstakeCompleted:
  触发: 解质押完成
  载荷: requestId, positionId, actualAmount
  订阅者: 统计服务, 通知服务

RewardsDistributed:
  触发: 奖励分发
  载荷: distributionId, poolId, totalRewards, recipientCount
  订阅者: 用户服务, 统计服务

RewardsClaimed:
  触发: 奖励领取
  载荷: claimId, userId, amount, txHash
  订阅者: 统计服务, 税务服务

APYUpdated:
  触发: APY更新
  载荷: poolId, oldAPY, newAPY
  订阅者: 前端服务, 通知服务

SlashingOccurred:
  触发: 罚没发生
  载荷: poolId, validatorAddress, slashAmount, reason
  订阅者: 风控服务, 告警服务

LSTMinted:
  触发: LST铸造
  载荷: lstId, userId, amount, exchangeRate
  订阅者: 代币服务

LSTBurned:
  触发: LST销毁
  载荷: lstId, userId, amount, returnedAmount
  订阅者: 代币服务
```

---

## 上下文映射 (Context Mapping)

```
┌─────────────────────────────────────────────────────────────────┐
│                      Staking Context                            │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────┐         │
│  │ StakingPool  │  │StakingPosition│ │LiquidStaking │         │
│  │  (聚合根)    │  │   (聚合根)    │ │Token(聚合根) │         │
│  └──────────────┘  └──────────────┘  └───────────────┘         │
└─────────────────────────────────────────────────────────────────┘
          │                    │                    │
          │ Uses               │ Uses               │ Provides
          ▼                    ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ Custody Context │  │Stablecoin Context│ │ Lending Context │
│  - 资产托管     │  │  - 奖励支付     │  │  - LST作为抵押  │
│  - 质押执行     │  │  - 稳定币质押   │  │  - 质押收益     │
└─────────────────┘  └─────────────────┘  └─────────────────┘
          │
          ▼
┌─────────────────┐  ┌─────────────────┐
│Blockchain Layer │  │Compliance Context│
│  - PoS验证     │  │  - 收益报告     │
│  - 节点委托     │  │  - 税务计算     │
└─────────────────┘  └─────────────────┘

集成模式:
- Custody: Customer-Supplier (质押依赖托管)
- Stablecoin: Partnership (双向使用)
- Lending: Customer-Supplier (Lending使用LST)
- Blockchain: Anti-Corruption Layer (链上交互)
- Compliance: Conformist (收益报告)
```

---

## 接口契约摘要

### 对外提供的API

```yaml
# 质押池
GET /api/v1/staking/pools
  - 获取质押池列表
  - 公开接口

GET /api/v1/staking/pools/{poolId}
  - 获取池详情

GET /api/v1/staking/pools/{poolId}/apy
  - 获取当前APY

# 质押操作
POST /api/v1/staking/stake
  - 执行质押
  - 需要登录

POST /api/v1/staking/unstake
  - 请求解质押

POST /api/v1/staking/withdraw
  - 提取解质押资产

# 奖励
GET /api/v1/staking/positions/{positionId}/rewards
  - 查询待领取奖励

POST /api/v1/staking/positions/{positionId}/claim
  - 领取奖励

POST /api/v1/staking/positions/{positionId}/compound
  - 复投奖励

# 用户仓位
GET /api/v1/staking/positions
  - 获取我的所有仓位

GET /api/v1/staking/positions/{positionId}
  - 获取仓位详情

# 流动性质押
GET /api/v1/staking/lst/{lstId}/rate
  - 获取LST汇率

# 内部服务
GET /internal/v1/staking/pools/{poolId}/stats
  - 获取池统计
  - 供统计服务调用

POST /internal/v1/staking/rewards/distribute
  - 触发奖励分发
  - 供调度服务调用
```

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| 1.0 | 2025-11-30 | 初始版本 | @领域架构师 |
