# Staking Service 上下文

> 最后更新: 2024-01-15
> 此文件由开发者维护，定期聚合到项目知识库

## 仓库概述

质押服务管理用户的资产质押、收益计算、奖励分发和解质押流程，支持多种质押模式包括原生质押、流动性质押和质押池。

## 架构概览

```
┌─────────────────────────────────────────────────────┐
│                  Staking Service                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │  Pool API   │  │Position API │  │ Reward API  │  │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  │
│         │                │                │          │
│  ┌──────▼────────────────▼────────────────▼──────┐  │
│  │              Domain Services                   │  │
│  │  - StakingService                             │  │
│  │  - UnstakingService                           │  │
│  │  - RewardService                              │  │
│  │  - APYCalculationService                      │  │
│  │  - LiquidStakingService                       │  │
│  └──────────────────────┬────────────────────────┘  │
│                         │                           │
│  ┌──────────────────────▼────────────────────────┐  │
│  │            Validator Integration              │  │
│  │  (验证节点委托管理)                           │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
           │              │              │
           ▼              ▼              ▼
    ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
    │   Custody   │ │   Lending   │ │ Stablecoin  │
    │ (资产托管)  │ │(LST作抵押) │ │ (奖励支付)  │
    └─────────────┘ └─────────────┘ └─────────────┘
```

## 核心领域模型

### 聚合根

```java
// StakingPool - 质押池
public class StakingPool {
    private PoolId id;
    private PoolType type;           // NATIVE, LIQUID, YIELD_FARMING
    private AssetInfo stakingAsset;
    private AssetInfo rewardAsset;
    private BigDecimal totalStaked;
    private BigDecimal currentAPY;
    private Duration lockPeriod;
    private Duration cooldownPeriod;
    private BigDecimal capacity;
    private PoolStatus status;
}

// StakingPosition - 质押仓位
public class StakingPosition {
    private PositionId id;
    private UserId userId;
    private PoolId poolId;
    private BigDecimal stakedAmount;
    private BigDecimal shares;
    private BigDecimal pendingRewards;
    private PositionStatus status;
    private LocalDateTime lockEndTime;
}

// LiquidStakingToken - 流动性质押代币
public class LiquidStakingToken {
    private LSTId id;
    private PoolId poolId;
    private String symbol;           // stETH, rETH
    private BigDecimal totalSupply;
    private BigDecimal exchangeRate;
    private Address contractAddress;
}
```

## 质押池类型

| 类型 | 说明 | 锁定期 | 收益 |
|------|------|--------|------|
| NATIVE_STAKING | 原生PoS质押 | 有 | 网络奖励 |
| LIQUID_STAKING | 流动性质押 | 无(LST) | 网络奖励 |
| YIELD_FARMING | 收益农场 | 灵活 | 激励代币 |
| FIXED_TERM | 固定期限 | 固定 | 固定收益 |

## 解质押流程

```
请求解质押 → 进入冷却期 → 冷却期结束 → 可提取 → 提取完成
   │              │              │           │
   │              └─ 14-28天 ─────┘           │
   │                                          │
   └──────── 锁定期内不可解质押 ──────────────┘
```

## LST汇率机制

```
初始: 1 stETH = 1 ETH
随时间: 1 stETH = 1.05 ETH (包含5%累计收益)

totalSupply * exchangeRate ≈ 池totalStaked + 累计奖励
```

## 外部依赖

| 服务 | 用途 | 接口 |
|------|------|------|
| Custody Service | 资产托管 | gRPC |
| Stablecoin Service | 奖励支付 | gRPC |
| Blockchain Layer | PoS验证 | JSON-RPC |

## 发布的领域事件

| 事件 | 触发条件 | 消费者 |
|------|----------|--------|
| Staked | 质押完成 | 奖励服务, 统计服务 |
| UnstakeRequested | 解质押请求 | 通知服务 |
| UnstakeCompleted | 解质押完成 | 统计服务 |
| RewardsDistributed | 奖励分发 | 用户服务, 统计服务 |
| RewardsClaimed | 奖励领取 | 统计服务, 税务服务 |
| APYUpdated | APY更新 | 前端服务 |
| LSTMinted | LST铸造 | 代币服务 |
| LSTBurned | LST销毁 | 代币服务 |

## 配置说明

```yaml
staking:
  pools:
    - name: "ETH Staking"
      type: LIQUID_STAKING
      asset: ETH
      reward-asset: ETH
      min-stake: 0.1
      lock-period: 0      # LST无锁定
      cooldown-period: 7d

  reward:
    distribution-interval: 1d
    auto-compound: true

  lst:
    rebase-interval: 1d
```

## 已知问题和待办

- [ ] 支持更多PoS链质押
- [ ] 实现自动选择最优验证节点
- [ ] 添加质押保险机制

## 近期变更

### 2024-01-10
- 优化APY计算精度
- 新增自动复投功能

### 2024-01-05
- 接入新验证节点
- 修复奖励分发延迟问题
