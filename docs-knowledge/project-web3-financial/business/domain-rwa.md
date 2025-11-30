# RWA领域模型

## 领域概述

RWA(Real World Assets)领域负责将现实资产代币化上链，实现资产的数字化确权、分割持有和收益分配。

## 核心概念

### 聚合根

| 聚合根 | 定义 |
|--------|------|
| **RealWorldAsset** | 现实资产，包含法律实体、托管、估值信息 |
| **AssetToken** | 资产代币，代表RWA权益 |
| **InvestorHolding** | 投资者持仓 |

### 关键实体

| 实体 | 定义 |
|------|------|
| AssetOffering | 资产发行活动 |
| Subscription | 认购申请 |
| DividendDistribution | 分红分配 |
| Valuation | 估值记录 |

### 值对象

```yaml
RWAType: REAL_ESTATE | FIXED_INCOME | EQUITY | COMMODITY
TokenStandard: ERC20 | ERC1400 | ERC3643
OfferingType: STO | PRIVATE_PLACEMENT | REG_D | REG_S
AccreditationStatus: PENDING | ACCREDITED | EXPIRED
```

## 核心流程

### 资产代币化流程
```
资产入驻 → 法律审核 → 估值 → 代币创建 → 发行
```

### 投资流程
```
认购申请 → 合规检查 → 支付 → 代币分配
```

### 分红流程
```
宣布分红 → 登记日快照 → 计算权益 → 支付分红
```

## 业务规则

1. **估值**: 有效期最长90天
2. **发行**: 需监管审批
3. **转让**: 双方需在白名单
4. **分红**: 基于登记日持仓

## 领域事件

| 事件 | 触发 | 订阅者 |
|------|------|--------|
| TokenCreated | 代币创建 | 市场服务, 钱包服务 |
| OfferingSettled | 发行结算 | 代币分发, 统计服务 |
| DividendPaid | 分红支付 | 税务服务, 通知服务 |
| ValuationCompleted | 估值完成 | 代币服务, 风控服务 |

## 依赖关系

- **上游**: Custody (托管), Compliance (合规)
- **下游**: Lending (作为抵押品)
