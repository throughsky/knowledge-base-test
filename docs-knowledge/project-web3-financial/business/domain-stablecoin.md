# 稳定币领域模型

## 领域概述

稳定币领域负责管理与法币锚定的数字货币的发行、流通和赎回。

## 核心概念

### 聚合根

| 聚合根 | 定义 |
|--------|------|
| **Stablecoin** | 稳定币实体，包含符号、精度、总供应量 |
| **Reserve** | 储备金池，支撑稳定币价值 |

### 关键实体

| 实体 | 定义 |
|------|------|
| MintRequest | 铸币请求 |
| RedemptionRequest | 赎回请求 |
| ReserveAsset | 储备资产明细 |

### 值对象

```yaml
PegType: FIAT_BACKED | CRYPTO_BACKED | ALGORITHMIC
StablecoinStatus: ACTIVE | PAUSED | DEPRECATED
MintStatus: PENDING → APPROVED → MINTED | REJECTED
RedemptionStatus: PENDING → PROCESSING → SETTLED
```

## 核心流程

### 铸币流程
```
用户提交 → 抵押验证 → 合规检查 → 审批 → 铸币上链
```

### 赎回流程
```
用户提交 → 销毁代币 → 合规检查 → 法币结算
```

## 业务规则

1. **储备率**: 必须 >= 100%
2. **铸币**: 大额需多签审批
3. **赎回**: 扣除手续费后T+1结算
4. **锚定**: 偏离>1%触发稳定机制

## 领域事件

| 事件 | 触发 | 订阅者 |
|------|------|--------|
| MintCompleted | 铸币完成 | 储备服务, 统计服务 |
| RedemptionSettled | 赎回完成 | 储备服务, 通知服务 |
| ReserveRatioChanged | 储备率变化 | 风控服务, 监控服务 |

## 依赖关系

- **上游**: 无
- **下游**: Lending, Staking, RWA (作为计价单位)
