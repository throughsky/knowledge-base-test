# Bridge Service 上下文

> 最后更新: 2024-01-15
> 此文件由开发者维护，定期聚合到项目知识库

## 仓库概述

Web2桥接服务负责连接传统金融系统(Web2)与区块链网络(Web3)，处理法币出入金、银行账户集成和支付通道对接。

## 架构概览

```
┌─────────────────────────────────────────────────────┐
│                   API Gateway                        │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│                 Bridge Service                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │ OnRamp API  │  │OffRamp API │  │BankAcct API │  │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  │
│         │                │                │          │
│  ┌──────▼────────────────▼────────────────▼──────┐  │
│  │              Domain Service                    │  │
│  │  - OnRampService (入金)                       │  │
│  │  - OffRampService (出金)                      │  │
│  │  - BankAccountService                         │  │
│  │  - QuoteService (汇率报价)                    │  │
│  │  - ReconciliationService (对账)               │  │
│  └──────────────────────┬────────────────────────┘  │
│                         │                           │
│  ┌──────────────────────▼────────────────────────┐  │
│  │            Payment Gateway Layer              │  │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ │  │
│  │  │ SWIFT  │ │ SEPA   │ │ ACH    │ │ Card   │ │  │
│  │  └────────┘ └────────┘ └────────┘ └────────┘ │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
           │              │              │
           ▼              ▼              ▼
    ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
    │ Stablecoin  │ │ Compliance  │ │  External   │
    │  Service    │ │  Service    │ │   Banks     │
    └─────────────┘ └─────────────┘ └─────────────┘
```

## 核心领域模型

### 聚合根

```java
// PaymentChannel - 支付通道
public class PaymentChannel {
    private ChannelId id;
    private ChannelType type;       // BANK_WIRE, SEPA, ACH, CARD
    private String providerName;
    private List<String> supportedCurrencies;
    private FeeStructure feeStructure;
    private ChannelLimits limits;
    private ChannelStatus status;
}

// FiatTransaction - 法币交易
public class FiatTransaction {
    private TransactionId id;
    private UserId userId;
    private TransactionType type;    // ON_RAMP, OFF_RAMP
    private Money fiatAmount;
    private Money cryptoAmount;
    private BigDecimal exchangeRate;
    private TransactionStatus status;
}

// BankAccount - 银行账户
public class BankAccount {
    private AccountId id;
    private UserId userId;
    private BankInfo bankInfo;
    private String accountNumber;    // 加密存储
    private VerificationStatus verificationStatus;
}
```

## 关键业务流程

### 入金流程 (OnRamp)

```
1. 用户请求入金报价
2. 锁定汇率(5分钟有效)
3. 创建入金订单
4. 生成支付指引(银行转账/卡支付)
5. 等待用户付款(15分钟超时)
6. 确认收款 → 调用Stablecoin服务铸币
7. 发布OnRampCompleted事件
```

### 出金流程 (OffRamp)

```
1. 用户请求出金(需验证银行账户)
2. 合规检查
3. 锁定汇率(30分钟有效)
4. 调用Stablecoin服务销毁代币
5. 发起银行转账
6. 追踪转账状态
7. 发布OffRampCompleted事件
```

## 外部依赖

| 服务 | 用途 | 接口 |
|------|------|------|
| Stablecoin Service | 铸币/销毁 | gRPC |
| Compliance Service | AML检查 | gRPC |
| 银行API | 转账执行 | REST |
| 支付网关 | 卡支付 | REST |

## 发布的领域事件

| 事件 | 触发条件 | 消费者 |
|------|----------|--------|
| OnRampOrderCreated | 入金订单创建 | 合规服务 |
| PaymentReceived | 收到付款 | 处理服务 |
| OnRampCompleted | 入金完成 | 账户服务, 通知服务 |
| OffRampOrderCreated | 出金订单创建 | 合规服务 |
| FiatSent | 法币已发送 | 对账服务 |
| OffRampCompleted | 出金完成 | 账户服务, 通知服务 |
| BankAccountVerified | 银行账户验证 | 用户服务 |

## 配置说明

```yaml
bridge:
  channels:
    - type: BANK_WIRE
      provider: swift
      currencies: [USD, EUR, GBP]
      min-amount: 100
      max-amount: 1000000
    - type: CARD
      provider: stripe
      currencies: [USD, EUR]
      min-amount: 10
      max-amount: 10000

  quote:
    validity-seconds: 300       # 报价5分钟有效
    lock-validity-seconds: 1800 # 锁定30分钟有效

  onramp:
    payment-timeout-minutes: 15

  offramp:
    large-amount-threshold: 50000
    require-manual-review: true
```

## 已知问题和待办

- [ ] 支持更多支付通道(Apple Pay, Google Pay)
- [ ] 实现实时汇率推送
- [ ] 添加自动对账调度

## 近期变更

### 2024-01-12
- 新增SEPA即时转账支持
- 优化汇率报价缓存

### 2024-01-08
- 修复银行账户验证超时问题
- 添加对账差异告警
