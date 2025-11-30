# 质押领域模型

## 领域概述

质押领域管理用户的资产质押、收益计算、奖励分发和解质押流程，支持多种质押模式。

## 核心概念

### 聚合根

| 聚合根 | 定义 |
|--------|------|
| **StakingPool** | 质押池，包含类型、APY、锁定期 |
| **StakingPosition** | 质押仓位，包含数量、份额、奖励 |
| **LiquidStakingToken** | 流动性质押代币，包含汇率、供应量 |

### 关键实体

| 实体 | 定义 |
|------|------|
| RewardDistribution | 奖励分发记录 |
| UnstakeRequest | 解质押请求 |
| ValidatorInfo | 验证节点信息 |

### 值对象

```yaml
PoolType: NATIVE_STAKING | LIQUID_STAKING | YIELD_FARMING | FIXED_TERM
PositionStatus: ACTIVE | UNSTAKING | COOLDOWN | WITHDRAWN
```

## 核心流程

### 质押流程
```
选择池 → 质押资产 → 获得份额/LST → 累积奖励
```

### 解质押流程
```
请求解质押 → 进入冷却期 → 冷却期结束 → 可提取 → 完成
```

## 业务规则

1. **锁定期**: 锁定期内不可解质押
2. **冷却期**: 解质押后需等待冷却期
3. **LST汇率**: 随奖励累积增长
4. **奖励分发**: 按份额比例分发

## 质押池类型

| 类型 | 说明 | 锁定期 | 收益 |
|------|------|--------|------|
| NATIVE_STAKING | 原生PoS质押 | 有 | 网络奖励 |
| LIQUID_STAKING | 流动性质押 | 无(LST) | 网络奖励 |
| YIELD_FARMING | 收益农场 | 灵活 | 激励代币 |
| FIXED_TERM | 固定期限 | 固定 | 固定收益 |

## LST汇率机制

```
初始: 1 stETH = 1 ETH
随时间: 1 stETH = 1.05 ETH (包含5%累计收益)

totalSupply * exchangeRate ≈ 池totalStaked + 累计奖励
```

## 领域事件

| 事件 | 触发 | 订阅者 |
|------|------|--------|
| Staked | 质押完成 | 奖励服务, 统计服务 |
| UnstakeRequested | 解质押请求 | 通知服务 |
| UnstakeCompleted | 解质押完成 | 统计服务 |
| RewardsDistributed | 奖励分发 | 用户服务, 统计服务 |
| RewardsClaimed | 奖励领取 | 统计服务, 税务服务 |
| LSTMinted | LST铸造 | 代币服务 |
| LSTBurned | LST销毁 | 代币服务 |

## 依赖关系

- **上游**: Custody (资产托管), Stablecoin (奖励支付)
- **下游**: Lending (LST作为抵押品)
