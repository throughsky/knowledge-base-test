# Lending Service 上下文

> 最后更新: 2024-01-15
> 此文件由开发者维护，定期聚合到项目知识库

## 仓库概述

借贷服务是Web3金融平台的核心DeFi协议，管理去中心化借贷，包括抵押品管理、借款发放、利率模型和清算机制。

## 架构概览

```
┌─────────────────────────────────────────────────────┐
│                  Lending Service                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │ Deposit API │  │ Borrow API  │  │  Liq API    │  │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  │
│         │                │                │          │
│  ┌──────▼────────────────▼────────────────▼──────┐  │
│  │              Domain Services                   │  │
│  │  - DepositService                             │  │
│  │  - BorrowService                              │  │
│  │  - InterestService                            │  │
│  │  - LiquidationService                         │  │
│  │  - RiskManagementService                      │  │
│  └──────────────────────┬────────────────────────┘  │
│                         │                           │
│  ┌──────────────────────▼────────────────────────┐  │
│  │              Oracle Layer                      │  │
│  │  (价格预言机 - Chainlink/内部聚合)            │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
           │              │              │
           ▼              ▼              ▼
    ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
    │ Stablecoin  │ │   Staking   │ │   Custody   │
    │  (借贷资产) │ │ (LST抵押品) │ │ (资产托管)  │
    └─────────────┘ └─────────────┘ └─────────────┘
```

## 核心领域模型

### 聚合根

```java
// LendingPool - 借贷池
public class LendingPool {
    private PoolId id;
    private AssetInfo asset;
    private BigDecimal totalDeposits;
    private BigDecimal totalBorrows;
    private BigDecimal utilizationRate;
    private BigDecimal depositAPY;
    private BigDecimal borrowAPY;
    private InterestRateModel interestRateModel;
    private RiskParameters riskParams;
}

// UserAccount - 用户账户
public class UserAccount {
    private AccountId id;
    private UserId userId;
    private List<DepositPosition> deposits;
    private List<BorrowPosition> borrows;
    private BigDecimal healthFactor;
    private AccountStatus status;
}

// Liquidation - 清算
public class Liquidation {
    private LiquidationId id;
    private AccountId liquidatedAccount;
    private AccountId liquidatorAccount;
    private BigDecimal debtRepaid;
    private BigDecimal collateralSeized;
    private BigDecimal liquidationBonus;
}
```

## 利率模型

```
利用率 = 总借款 / 总存款

当 utilization <= optimal (如80%):
  借款利率 = baseRate + utilization * slope1 / optimal

当 utilization > optimal:
  借款利率 = baseRate + slope1 + (utilization - optimal) * slope2 / (1 - optimal)

存款利率 = 借款利率 * 利用率 * (1 - 储备金因子)
```

## 风险参数示例

| 资产 | 抵押因子(LTV) | 清算阈值 | 清算罚金 |
|------|---------------|----------|----------|
| ETH | 80% | 85% | 5% |
| USDC | 85% | 90% | 4% |
| stETH | 75% | 80% | 7% |
| RWA代币 | 60% | 70% | 10% |

## 健康因子计算

```
健康因子 = (总抵押价值 * 加权清算阈值) / 总借款价值

健康因子 < 1 → 可被清算
健康因子 < 1.2 → 风险预警
```

## 外部依赖

| 服务 | 用途 | 接口 |
|------|------|------|
| Custody Service | 资产托管/清算执行 | gRPC |
| Stablecoin Service | 稳定币借贷 | gRPC |
| Staking Service | LST作为抵押品 | gRPC |
| Oracle Service | 价格喂价 | gRPC |

## 发布的领域事件

| 事件 | 触发条件 | 消费者 |
|------|----------|--------|
| Deposited | 存款完成 | 利息服务, 统计服务 |
| Withdrawn | 提款完成 | 利息服务, 统计服务 |
| Borrowed | 借款完成 | 风险服务, 统计服务 |
| Repaid | 还款完成 | 风险服务, 统计服务 |
| LiquidationExecuted | 清算执行 | 通知服务, 审计服务 |
| HealthFactorAlert | 健康因子预警 | 通知服务, 风控服务 |
| InterestRateUpdated | 利率更新 | 前端服务, 统计服务 |

## 配置说明

```yaml
lending:
  pools:
    - asset: ETH
      collateral-factor: 0.80
      liquidation-threshold: 0.85
      liquidation-penalty: 0.05
      borrow-cap: 10000
      supply-cap: 50000

  interest-rate:
    base-rate: 0.02        # 基础利率2%
    slope1: 0.04           # 低利用率斜率
    slope2: 0.75           # 高利用率斜率
    optimal-utilization: 0.80

  liquidation:
    close-factor: 0.50     # 单次最多清算50%
    health-factor-alert: 1.2
```

## 已知问题和待办

- [ ] 支持闪电贷功能
- [ ] 实现隔离模式(Isolation Mode)
- [ ] 添加E-Mode高效模式

## 近期变更

### 2024-01-12
- 新增RWA代币作为抵押品支持
- 优化清算机器人响应时间

### 2024-01-08
- 升级价格预言机聚合逻辑
- 修复利息累计精度问题
