# 借贷领域模型

## 领域概述

借贷领域管理去中心化借贷协议，包括抵押品管理、借款发放、利率模型和清算机制。

## 核心概念

### 聚合根

| 聚合根 | 定义 |
|--------|------|
| **LendingPool** | 借贷池，包含资产、利率、风险参数 |
| **UserAccount** | 用户账户，包含存款、借款、健康因子 |
| **Liquidation** | 清算记录，包含债务偿还、抵押品清算 |

### 关键实体

| 实体 | 定义 |
|------|------|
| DepositPosition | 存款仓位 |
| BorrowPosition | 借款仓位 |
| InterestRateModel | 利率模型 |
| RiskParameters | 风险参数 |

### 值对象

```yaml
PositionStatus: ACTIVE | LIQUIDATED | CLOSED
AccountStatus: HEALTHY | AT_RISK | LIQUIDATABLE
InterestRateType: VARIABLE | STABLE
```

## 核心流程

### 借款流程
```
存入抵押 → 启用抵押 → 申请借款 → 发放借款
```

### 清算流程
```
价格更新 → 健康因子计算 → 触发清算 → 资产划转 → 债务偿还
```

## 业务规则

1. **健康因子**: 必须 >= 1，否则可被清算
2. **清算阈值**: 低于阈值触发清算
3. **清算奖励**: 清算人获得抵押品折扣
4. **利率模型**: 基于利用率的拐点模型

## 利率模型

```
利用率 = 总借款 / 总存款

当 utilization <= optimal (80%):
  借款利率 = baseRate + utilization * slope1 / optimal

当 utilization > optimal:
  借款利率 = baseRate + slope1 + (utilization - optimal) * slope2 / (1 - optimal)
```

## 风险参数示例

| 资产 | 抵押因子(LTV) | 清算阈值 | 清算罚金 |
|------|---------------|----------|----------|
| ETH | 80% | 85% | 5% |
| USDC | 85% | 90% | 4% |
| stETH | 75% | 80% | 7% |
| RWA代币 | 60% | 70% | 10% |

## 领域事件

| 事件 | 触发 | 订阅者 |
|------|------|--------|
| Deposited | 存款完成 | 利息服务, 统计服务 |
| Borrowed | 借款完成 | 风险服务, 统计服务 |
| Repaid | 还款完成 | 风险服务, 统计服务 |
| LiquidationExecuted | 清算执行 | 通知服务, 审计服务 |
| HealthFactorAlert | 健康因子预警 | 通知服务, 风控服务 |

## 依赖关系

- **上游**: Stablecoin (借贷资产), Staking (LST抵押品), Custody (资产托管), Oracle (价格)
- **下游**: 无
