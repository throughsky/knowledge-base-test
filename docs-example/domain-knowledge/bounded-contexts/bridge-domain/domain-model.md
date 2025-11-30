# Web2桥接层领域模型 (Web2 Bridge Domain Model)

**限界上下文**: Bridge Context
**上下文所有者**: 桥接服务团队
**版本**: 1.0
**最后更新**: 2025-11-30

---

## 领域概述

Web2桥接层负责连接传统金融系统(Web2)与区块链网络(Web3)，处理法币出入金、银行账户集成、传统支付通道和企业系统对接。本领域是Web3金融服务与现实世界金融基础设施的桥梁。

<!-- AI-CONTEXT
Web2桥接层核心职责：
1. 法币出入金处理
2. 银行账户集成
3. 传统支付通道对接
4. 企业系统API集成
5. 跨系统数据同步
关键约束：资金流转需全程可追溯，合规要求必须满足
-->

---

## 核心概念 (Ubiquitous Language)

### 聚合根 (Aggregate Roots)

#### PaymentChannel (支付通道)
```yaml
定义: 与外部支付系统的集成通道
属性:
  - channelId: UUID
  - channelType: ChannelType # 通道类型
  - providerName: String # 服务商名称
  - providerCode: String # 服务商代码
  - supportedCurrencies: List<String> # 支持的法币
  - supportedDirections: List<Direction> # 支持的方向
  - feeStructure: FeeStructure # 费用结构
  - limits: ChannelLimits # 限额配置
  - processingTime: ProcessingTime # 处理时间
  - credentials: EncryptedCredentials # 加密凭证
  - webhookConfig: WebhookConfig # 回调配置
  - status: ChannelStatus
  - healthScore: BigDecimal # 健康评分
  - lastHealthCheck: Timestamp
  - createdAt: Timestamp
  - updatedAt: Timestamp

不变式:
  - 活跃通道必须有有效凭证
  - 健康评分低于阈值自动降级
```

#### FiatTransaction (法币交易)
```yaml
定义: 法币出入金交易
属性:
  - transactionId: UUID
  - userId: UUID
  - channelId: UUID
  - transactionType: TransactionType # 入金/出金
  - fiatAmount: BigDecimal # 法币金额
  - fiatCurrency: String # 法币币种
  - cryptoAmount: BigDecimal # 加密货币金额 (换算后)
  - cryptoAsset: String # 加密货币资产
  - exchangeRate: BigDecimal # 汇率
  - fees: FeeBreakdown # 费用明细
  - netAmount: BigDecimal # 净金额
  - sourceAccount: AccountInfo # 来源账户
  - destinationAccount: AccountInfo # 目标账户
  - providerReference: String # 服务商参考号
  - internalReference: String # 内部参考号
  - status: TransactionStatus
  - complianceStatus: ComplianceStatus
  - settlementInfo: SettlementInfo
  - createdAt: Timestamp
  - updatedAt: Timestamp
  - completedAt: Timestamp

生命周期 (入金):
  INITIATED → PENDING_PAYMENT → PAYMENT_RECEIVED → PROCESSING →
  CRYPTO_CREDITED → COMPLETED
  → PAYMENT_FAILED | COMPLIANCE_HOLD | CANCELLED | REFUNDED

生命周期 (出金):
  INITIATED → COMPLIANCE_CHECK → CRYPTO_DEBITED → PROCESSING →
  FIAT_SENT → COMPLETED
  → COMPLIANCE_REJECTED | TRANSFER_FAILED | CANCELLED
```

#### BankAccount (银行账户)
```yaml
定义: 用户绑定的银行账户
属性:
  - accountId: UUID
  - userId: UUID
  - accountType: BankAccountType
  - bankInfo: BankInfo # 银行信息
  - accountNumber: String # 账号 (加密存储)
  - accountName: String # 账户名
  - currency: String # 账户币种
  - routingInfo: RoutingInfo # 路由信息
  - verificationStatus: VerificationStatus
  - verificationMethod: VerificationMethod
  - isDefault: Boolean # 是否默认账户
  - lastUsedAt: Timestamp
  - status: AccountStatus
  - createdAt: Timestamp

不变式:
  - 账户必须经过验证才能出金
  - 账户名必须与KYC名称匹配
```

### 实体 (Entities)

#### OnRampOrder (入金订单)
```yaml
定义: 法币入金订单
属性:
  - orderId: UUID
  - transactionId: UUID
  - userId: UUID
  - channelId: UUID
  - requestedAmount: BigDecimal # 请求金额
  - currency: String
  - paymentMethod: PaymentMethod # 支付方式
  - paymentInstructions: PaymentInstructions # 支付指引
  - expiresAt: Timestamp # 订单过期时间
  - paymentDeadline: Timestamp # 支付截止时间
  - receivedAmount: BigDecimal # 实际收到金额
  - status: OrderStatus
  - createdAt: Timestamp

生命周期:
  CREATED → AWAITING_PAYMENT → PAYMENT_CONFIRMED → PROCESSING →
  COMPLETED → EXPIRED | CANCELLED
```

#### OffRampOrder (出金订单)
```yaml
定义: 法币出金订单
属性:
  - orderId: UUID
  - transactionId: UUID
  - userId: UUID
  - channelId: UUID
  - cryptoAmount: BigDecimal # 加密货币金额
  - cryptoAsset: String
  - fiatAmount: BigDecimal # 预计到账法币
  - fiatCurrency: String
  - destinationAccountId: UUID # 目标银行账户
  - burnTxHash: String # 加密货币销毁哈希
  - bankReference: String # 银行转账参考号
  - estimatedArrival: Timestamp # 预计到账时间
  - actualArrival: Timestamp # 实际到账时间
  - status: OrderStatus
  - createdAt: Timestamp
```

#### ExchangeQuote (汇率报价)
```yaml
定义: 法币与加密货币的汇率报价
属性:
  - quoteId: UUID
  - channelId: UUID
  - fromCurrency: String
  - toCurrency: String
  - fromAmount: BigDecimal
  - toAmount: BigDecimal
  - exchangeRate: BigDecimal
  - spread: BigDecimal # 点差
  - fees: FeeBreakdown
  - validUntil: Timestamp
  - status: QuoteStatus
  - createdAt: Timestamp
```

#### Reconciliation (对账)
```yaml
定义: 通道对账记录
属性:
  - reconciliationId: UUID
  - channelId: UUID
  - reconciliationDate: Date
  - totalTransactions: Integer
  - totalAmount: BigDecimal
  - matchedCount: Integer
  - unmatchedCount: Integer
  - discrepancies: List<Discrepancy>
  - status: ReconciliationStatus
  - report: String # 对账报告链接
  - createdAt: Timestamp
```

### 值对象 (Value Objects)

```yaml
ChannelType:
  枚举值:
    - BANK_WIRE # 银行电汇
    - SEPA # SEPA转账
    - ACH # ACH转账
    - FASTER_PAYMENTS # 英国快速支付
    - CARD # 银行卡
    - MOBILE_PAYMENT # 移动支付 (支付宝/微信)
    - PAYMENT_GATEWAY # 支付网关
    - CRYPTO_EXCHANGE # 加密交易所

TransactionType:
  枚举值:
    - ON_RAMP # 入金 (法币→加密)
    - OFF_RAMP # 出金 (加密→法币)

Direction:
  枚举值:
    - INBOUND # 入账
    - OUTBOUND # 出账
    - BIDIRECTIONAL # 双向

PaymentMethod:
  枚举值:
    - BANK_TRANSFER # 银行转账
    - DEBIT_CARD # 借记卡
    - CREDIT_CARD # 信用卡
    - APPLE_PAY # Apple Pay
    - GOOGLE_PAY # Google Pay
    - ALIPAY # 支付宝
    - WECHAT_PAY # 微信支付

TransactionStatus:
  枚举值:
    - INITIATED # 发起
    - PENDING_PAYMENT # 等待付款
    - PAYMENT_RECEIVED # 已收款
    - PROCESSING # 处理中
    - CRYPTO_CREDITED # 加密货币已入账
    - CRYPTO_DEBITED # 加密货币已扣除
    - FIAT_SENT # 法币已发送
    - COMPLETED # 完成
    - PAYMENT_FAILED # 付款失败
    - COMPLIANCE_HOLD # 合规审核
    - CANCELLED # 已取消
    - REFUNDED # 已退款
    - TRANSFER_FAILED # 转账失败

VerificationStatus:
  枚举值:
    - PENDING # 待验证
    - VERIFIED # 已验证
    - FAILED # 验证失败
    - EXPIRED # 已过期

VerificationMethod:
  枚举值:
    - MICRO_DEPOSIT # 小额存款验证
    - INSTANT_VERIFICATION # 即时验证 (Plaid等)
    - DOCUMENT_UPLOAD # 文档上传
    - MANUAL_REVIEW # 人工审核

FeeStructure:
  fixedFee: BigDecimal # 固定费用
  percentageFee: BigDecimal # 百分比费用
  minFee: BigDecimal # 最低费用
  maxFee: BigDecimal # 最高费用
  feeType: String # 费用类型

ChannelLimits:
  minAmount: BigDecimal # 单笔最小
  maxAmount: BigDecimal # 单笔最大
  dailyLimit: BigDecimal # 日限额
  monthlyLimit: BigDecimal # 月限额

ProcessingTime:
  minMinutes: Integer # 最快处理时间
  maxMinutes: Integer # 最慢处理时间
  averageMinutes: Integer # 平均处理时间

BankInfo:
  bankName: String
  bankCode: String # 银行代码
  swiftCode: String # SWIFT代码
  country: String
  address: String

RoutingInfo:
  routingNumber: String # 美国路由号
  sortCode: String # 英国排序码
  iban: String # IBAN
  bic: String # BIC

PaymentInstructions:
  bankName: String
  accountNumber: String
  accountName: String
  reference: String # 付款参考号 (重要!)
  amount: BigDecimal
  currency: String
  additionalInfo: String

SettlementInfo:
  settledAt: Timestamp
  settlementBatch: String
  netSettledAmount: BigDecimal
  settlementCurrency: String
```

---

## 领域服务 (Domain Services)

### OnRampService
```yaml
职责: 入金处理
方法:
  - createOnRampOrder(userId, amount, currency, paymentMethod): OnRampOrder
  - generatePaymentInstructions(orderId): PaymentInstructions
  - confirmPayment(orderId, paymentDetails): PaymentConfirmation
  - processOnRamp(orderId): ProcessingResult
  - cancelOnRamp(orderId, reason): CancellationResult

规则:
  - 订单15分钟内未支付自动取消
  - 付款金额需与订单金额匹配
  - 首次入金有额外验证
```

### OffRampService
```yaml
职责: 出金处理
方法:
  - createOffRampOrder(userId, cryptoAmount, asset, bankAccountId): OffRampOrder
  - executeOffRamp(orderId): ExecutionResult
  - trackBankTransfer(orderId): TransferStatus
  - cancelOffRamp(orderId, reason): CancellationResult

规则:
  - 出金前需验证银行账户
  - 大额出金需要额外审批
  - 锁定汇率有效期30分钟
```

### QuoteService
```yaml
职责: 汇率报价
方法:
  - getQuote(channelId, from, to, amount): ExchangeQuote
  - lockQuote(quoteId): LockedQuote
  - refreshQuote(quoteId): ExchangeQuote
  - getBestQuote(from, to, amount): ExchangeQuote

规则:
  - 报价有效期5分钟
  - 锁定报价有效期30分钟
  - 选择最优通道报价
```

### BankAccountService
```yaml
职责: 银行账户管理
方法:
  - addBankAccount(userId, accountDetails): BankAccount
  - verifyAccount(accountId, method): VerificationResult
  - setDefaultAccount(accountId): Result
  - removeAccount(accountId): Result

规则:
  - 账户必须验证后才能出金
  - 账户名需与KYC信息匹配
  - 删除账户保留历史记录
```

### ChannelRoutingService
```yaml
职责: 通道路由选择
方法:
  - selectBestChannel(transactionType, currency, amount): PaymentChannel
  - evaluateChannelHealth(channelId): HealthScore
  - failoverChannel(channelId): PaymentChannel
  - getAvailableChannels(criteria): List<PaymentChannel>

规则:
  - 根据费用、速度、可用性评分
  - 故障通道自动切换
  - 大额交易优先选择稳定通道
```

### ReconciliationService
```yaml
职责: 对账服务
方法:
  - performDailyReconciliation(channelId, date): Reconciliation
  - identifyDiscrepancies(reconciliationId): List<Discrepancy>
  - resolveDiscrepancy(discrepancyId, resolution): ResolutionResult
  - generateReconciliationReport(channelId, period): Report

规则:
  - 每日凌晨自动对账
  - 差异超过阈值触发告警
  - 未解决差异需人工处理
```

---

## 领域事件 (Domain Events)

```yaml
ChannelCreated:
  触发: 支付通道创建
  载荷: channelId, channelType, providerName
  订阅者: 监控服务, 配置服务

ChannelHealthChanged:
  触发: 通道健康状态变化
  载荷: channelId, oldScore, newScore, reason
  订阅者: 路由服务, 告警服务

OnRampOrderCreated:
  触发: 入金订单创建
  载荷: orderId, userId, amount, currency
  订阅者: 合规服务, 通知服务

PaymentReceived:
  触发: 收到付款
  载荷: orderId, receivedAmount, paymentMethod
  订阅者: 处理服务, 对账服务

OnRampCompleted:
  触发: 入金完成
  载荷: orderId, transactionId, cryptoAmount, txHash
  订阅者: 账户服务, 通知服务, 统计服务

OffRampOrderCreated:
  触发: 出金订单创建
  载荷: orderId, userId, cryptoAmount, fiatAmount
  订阅者: 合规服务, 通知服务

CryptoDebited:
  触发: 加密货币已扣除
  载荷: orderId, amount, txHash
  订阅者: 出金处理服务

FiatSent:
  触发: 法币已发送
  载荷: orderId, amount, bankReference
  订阅者: 通知服务, 对账服务

OffRampCompleted:
  触发: 出金完成
  载荷: orderId, transactionId, settledAmount
  订阅者: 账户服务, 通知服务, 统计服务

BankAccountAdded:
  触发: 银行账户添加
  载荷: accountId, userId, bankInfo
  订阅者: 合规服务, 验证服务

BankAccountVerified:
  触发: 银行账户验证完成
  载荷: accountId, verificationMethod
  订阅者: 用户服务, 通知服务

ComplianceHold:
  触发: 合规审核
  载荷: transactionId, holdReason
  订阅者: 合规团队, 通知服务

ReconciliationCompleted:
  触发: 对账完成
  载荷: reconciliationId, channelId, discrepancyCount
  订阅者: 财务服务, 审计服务

DiscrepancyDetected:
  触发: 发现差异
  载荷: reconciliationId, discrepancyType, amount
  订阅者: 告警服务, 财务团队
```

---

## 上下文映射 (Context Mapping)

```
┌─────────────────────────────────────────────────────────────────┐
│                       Bridge Context                            │
│  ┌───────────────┐ ┌───────────────┐ ┌──────────────┐          │
│  │PaymentChannel │ │FiatTransaction│ │ BankAccount  │          │
│  │   (聚合根)    │ │   (聚合根)    │ │  (聚合根)    │          │
│  └───────────────┘ └───────────────┘ └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
          │                    │                    │
          │                    │                    │
          ▼                    ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  External Bank  │  │Stablecoin Context│ │Compliance Context│
│   (银行系统)    │  │  - 稳定币铸造   │  │  - KYC/AML     │
│  - SWIFT/SEPA   │  │  - 稳定币销毁   │  │  - 交易监控    │
│  - ACH/FPS      │  │  - 储备管理     │  │  - 可疑报告    │
└─────────────────┘  └─────────────────┘  └─────────────────┘
          │
          ▼
┌─────────────────┐  ┌─────────────────┐
│Payment Provider │  │ Custody Context │
│  (支付网关)     │  │  - 资产托管     │
│  - Stripe       │  │  - 交易签名     │
│  - Checkout     │  │                 │
└─────────────────┘  └─────────────────┘

集成模式:
- External Bank: Anti-Corruption Layer (防腐层)
- Payment Provider: Anti-Corruption Layer (防腐层)
- Stablecoin: Partnership (双向协作)
- Compliance: Conformist (必须遵守合规)
- Custody: Customer-Supplier (依赖托管服务)
```

---

## 接口契约摘要

### 对外提供的API

```yaml
# 入金
POST /api/v1/bridge/onramp/quote
  - 获取入金报价
  - 请求体: { amount, fromCurrency, toCurrency }

POST /api/v1/bridge/onramp/order
  - 创建入金订单
  - 请求体: { quoteId, paymentMethod }

GET /api/v1/bridge/onramp/order/{orderId}
  - 获取订单状态

GET /api/v1/bridge/onramp/order/{orderId}/instructions
  - 获取支付指引

# 出金
POST /api/v1/bridge/offramp/quote
  - 获取出金报价

POST /api/v1/bridge/offramp/order
  - 创建出金订单
  - 请求体: { quoteId, bankAccountId }

GET /api/v1/bridge/offramp/order/{orderId}
  - 获取订单状态

# 银行账户
POST /api/v1/bridge/bank-accounts
  - 添加银行账户

GET /api/v1/bridge/bank-accounts
  - 获取我的银行账户列表

POST /api/v1/bridge/bank-accounts/{accountId}/verify
  - 验证银行账户

DELETE /api/v1/bridge/bank-accounts/{accountId}
  - 删除银行账户

# 通道
GET /api/v1/bridge/channels
  - 获取可用通道
  - 公开接口

# Webhooks (供外部系统回调)
POST /webhooks/v1/payment/{provider}
  - 支付回调
  - 需要签名验证

# 内部服务
POST /internal/v1/bridge/settle
  - 结算交易
  - 供调度服务调用

GET /internal/v1/bridge/transactions/{txId}/status
  - 获取交易状态
  - 供其他服务调用
```

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| 1.0 | 2025-11-30 | 初始版本 | @领域架构师 |
