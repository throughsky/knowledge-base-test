# 法币桥接领域模型

## 领域概述

法币桥接领域负责连接传统金融系统(Web2)与区块链网络(Web3)，处理法币出入金、银行账户集成和支付通道对接。

## 核心概念

### 聚合根

| 聚合根 | 定义 |
|--------|------|
| **PaymentChannel** | 支付通道，包含类型、服务商、限额 |
| **FiatTransaction** | 法币交易，包含金额、汇率、状态 |
| **BankAccount** | 银行账户，包含账户信息、验证状态 |

### 关键实体

| 实体 | 定义 |
|------|------|
| Quote | 汇率报价 |
| Reconciliation | 对账记录 |
| FeeStructure | 费用结构 |

### 值对象

```yaml
ChannelType: BANK_WIRE | SEPA | ACH | CARD
TransactionType: ON_RAMP | OFF_RAMP
TransactionStatus: PENDING → PROCESSING → COMPLETED | FAILED
VerificationStatus: PENDING → VERIFIED | REJECTED
```

## 核心流程

### 入金流程 (OnRamp)
```
请求报价 → 锁定汇率 → 创建订单 → 用户付款 → 确认收款 → 铸币
```

### 出金流程 (OffRamp)
```
请求出金 → 合规检查 → 锁定汇率 → 销毁代币 → 银行转账 → 完成
```

## 业务规则

1. **报价有效期**: 锁定汇率5分钟有效
2. **支付超时**: 入金订单15分钟未支付自动取消
3. **银行验证**: 出金必须使用已验证银行账户
4. **大额审批**: 超过阈值需人工审批

## 领域事件

| 事件 | 触发 | 订阅者 |
|------|------|--------|
| OnRampOrderCreated | 入金订单创建 | 合规服务 |
| PaymentReceived | 收到付款 | 处理服务 |
| OnRampCompleted | 入金完成 | 账户服务, 通知服务 |
| OffRampOrderCreated | 出金订单创建 | 合规服务 |
| OffRampCompleted | 出金完成 | 账户服务, 通知服务 |
| BankAccountVerified | 银行账户验证 | 用户服务 |

## 依赖关系

- **上游**: Stablecoin (铸币/销毁), Compliance (合规检查), Custody (资产托管)
- **下游**: 无
