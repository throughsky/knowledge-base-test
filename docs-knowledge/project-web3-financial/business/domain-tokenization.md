# 存款代币化领域模型

## 领域概述

存款代币化领域负责将传统银行存款转换为链上代币，实现存款的数字化、可编程化和可组合性。

## 核心概念

### 聚合根

| 聚合根 | 定义 |
|--------|------|
| **DepositToken** | 存款代币，包含符号、供应量、利率 |
| **DepositAccount** | 存款账户，包含余额、应计利息 |

### 关键实体

| 实体 | 定义 |
|------|------|
| TokenizationRequest | 代币化请求 |
| RedemptionRequest | 赎回请求 |
| InterestDistribution | 利息分发记录 |
| ReconciliationRecord | 对账记录 |

### 值对象

```yaml
DepositType: DEMAND | TIME_1M | TIME_3M | TIME_6M | TIME_1Y
InterestModel: SIMPLE | COMPOUND_DAILY | COMPOUND_CONTINUOUS
TokenizationStatus: PENDING → DEPOSIT_RECEIVED → BANK_CONFIRMED → MINTING → COMPLETED
RedemptionStatus: PENDING → TOKEN_BURNED → PROCESSING → BANK_TRANSFER → SETTLED
```

## 核心流程

### 代币化流程
```
银行存款 → 存款确认 → 合规检查 → 铸造代币 → 完成
```

### 赎回流程
```
赎回请求 → 销毁代币 → 银行转账 → 结算完成
```

## 业务规则

1. **供应量不变式**: 代币总供应量 = 托管存款总额
2. **银行确认**: 铸币前必须有银行确认
3. **利息分发**: 按持有份额自动分发
4. **每日对账**: 确保代币与存款1:1映射

## 领域事件

| 事件 | 触发 | 订阅者 |
|------|------|--------|
| TokenizationInitiated | 代币化请求创建 | 银行网关 |
| TokenizationCompleted | 代币化完成 | 账户服务, 统计服务 |
| RedemptionInitiated | 赎回请求创建 | 银行网关 |
| RedemptionSettled | 赎回完成 | 账户服务 |
| InterestDistributed | 利息分发 | 账户服务, 统计服务 |
| DiscrepancyDetected | 差异检测 | 风控服务, 告警 |

## 依赖关系

- **上游**: Custody (代币托管), Compliance (KYC验证), Partner Banks
- **下游**: Lending (作为抵押品)
