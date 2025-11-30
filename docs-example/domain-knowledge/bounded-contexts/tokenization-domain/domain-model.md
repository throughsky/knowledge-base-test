# 存款代币化领域模型 (Deposit Tokenization Domain Model)

**限界上下文**: Tokenization Context
**上下文所有者**: 代币化团队
**版本**: 1.0
**最后更新**: 2025-11-30

---

## 领域概述

存款代币化领域负责将传统银行存款转换为链上代币，实现存款的数字化、可编程化和可组合性。本领域连接传统金融机构与Web3生态，是银行数字化转型的核心基础设施。

<!-- AI-CONTEXT
存款代币化领域核心职责：
1. 银行存款到链上代币的转换
2. 代币与存款的1:1映射管理
3. 收益分发与自动复利
4. 合规报告与审计追踪
关键约束：代币总量必须等于托管存款总额，所有操作需银行确认
-->

---

## 核心概念 (Ubiquitous Language)

### 聚合根 (Aggregate Roots)

#### DepositToken (存款代币)
```yaml
定义: 代表银行存款权益的链上代币
属性:
  - tokenId: UUID # 代币唯一标识
  - symbol: String # 代币符号 (如 dUSD, dEUR)
  - name: String # 代币名称
  - decimals: Integer # 精度
  - totalSupply: BigDecimal # 总发行量
  - underlyingDeposit: DepositInfo # 底层存款信息
  - partnerBankId: UUID # 合作银行ID
  - interestRate: BigDecimal # 当前利率 (年化)
  - interestModel: InterestModel # 利息模型
  - contractAddress: Address # 智能合约地址
  - chainId: Integer
  - status: TokenStatus
  - createdAt: Timestamp
  - updatedAt: Timestamp

不变式:
  - totalSupply == 托管存款总额
  - interestRate >= 0
  - 每次供应量变化需银行确认
```

#### DepositAccount (存款账户)
```yaml
定义: 用户在平台的存款代币化账户
属性:
  - accountId: UUID
  - userId: UUID
  - tokenId: UUID # 关联的存款代币
  - balance: BigDecimal # 代币余额
  - accruedInterest: BigDecimal # 累计利息
  - lastInterestUpdate: Timestamp
  - depositHistory: List<DepositRecord>
  - withdrawalHistory: List<WithdrawalRecord>
  - status: AccountStatus
  - createdAt: Timestamp

不变式:
  - balance >= 0
  - 利息按区块实时累计
```

### 实体 (Entities)

#### TokenizationRequest (代币化请求)
```yaml
定义: 存款代币化申请
属性:
  - requestId: UUID
  - tokenId: UUID
  - userId: UUID
  - depositAmount: BigDecimal # 存款金额
  - sourceBankAccount: BankAccountInfo # 来源银行账户
  - depositReference: String # 存款凭证号
  - tokenAmount: BigDecimal # 待铸造代币数量
  - exchangeRate: BigDecimal # 转换汇率
  - status: TokenizationStatus
  - bankConfirmationId: String # 银行确认号
  - mintTxHash: String
  - createdAt: Timestamp
  - confirmedAt: Timestamp
  - completedAt: Timestamp

生命周期:
  PENDING → DEPOSIT_RECEIVED → BANK_CONFIRMED → MINTING → COMPLETED
         → DEPOSIT_FAILED | REJECTED
```

#### RedemptionRequest (赎回请求)
```yaml
定义: 代币赎回为存款的申请
属性:
  - requestId: UUID
  - tokenId: UUID
  - userId: UUID
  - tokenAmount: BigDecimal # 赎回代币数量
  - withdrawalAmount: BigDecimal # 预计到账金额
  - destinationAccount: BankAccountInfo # 目标银行账户
  - burnTxHash: String # 销毁交易哈希
  - status: RedemptionStatus
  - bankTransferRef: String # 银行转账参考号
  - fees: FeeBreakdown # 费用明细
  - createdAt: Timestamp
  - settledAt: Timestamp

生命周期:
  PENDING → TOKEN_BURNED → PROCESSING → BANK_TRANSFER → SETTLED
         → BURN_FAILED | REJECTED
```

#### InterestDistribution (利息分发)
```yaml
定义: 利息分发记录
属性:
  - distributionId: UUID
  - tokenId: UUID
  - periodStart: Timestamp
  - periodEnd: Timestamp
  - totalInterest: BigDecimal # 总利息
  - distributionMethod: DistributionMethod # 分发方式
  - recipientCount: Integer # 接收人数
  - status: DistributionStatus
  - txHash: String
  - createdAt: Timestamp
```

### 值对象 (Value Objects)

```yaml
DepositInfo:
  bankId: String # 银行ID
  bankName: String # 银行名称
  depositType: DepositType # 存款类型
  currency: String # 币种
  totalAmount: BigDecimal # 总存款额
  custodianAccount: String # 托管账户
  lastVerificationTime: Timestamp

BankAccountInfo:
  bankCode: String # 银行代码
  accountNumber: String # 账号 (脱敏)
  accountName: String # 账户名
  routingNumber: String # 路由号
  swiftCode: String # SWIFT代码 (国际)

FeeBreakdown:
  platformFee: BigDecimal
  bankFee: BigDecimal
  networkFee: BigDecimal
  totalFee: BigDecimal

InterestModel:
  枚举值:
    - SIMPLE # 单利
    - COMPOUND_DAILY # 日复利
    - COMPOUND_CONTINUOUS # 连续复利

DepositType:
  枚举值:
    - DEMAND # 活期
    - TIME_1M # 1月定期
    - TIME_3M # 3月定期
    - TIME_6M # 6月定期
    - TIME_1Y # 1年定期

TokenStatus:
  枚举值:
    - ACTIVE
    - PAUSED
    - SUSPENDED
    - DEPRECATED

TokenizationStatus:
  枚举值:
    - PENDING
    - DEPOSIT_RECEIVED
    - BANK_CONFIRMED
    - MINTING
    - COMPLETED
    - DEPOSIT_FAILED
    - REJECTED

DistributionMethod:
  枚举值:
    - MINT_TO_HOLDERS # 铸造新代币分发
    - REBASE # 调整代币供应量
    - AIRDROP # 空投
```

---

## 领域服务 (Domain Services)

### TokenizationService
```yaml
职责: 处理存款代币化流程
方法:
  - initiateTokenization(userId, depositAmount, bankAccount): TokenizationRequest
  - confirmDeposit(requestId, bankConfirmation): TokenizationRequest
  - executeTokenization(requestId): TransactionResult
  - cancelTokenization(requestId, reason): TokenizationRequest

规则:
  - 必须验证用户KYC状态
  - 存款确认后24小时内完成代币化
  - 汇率锁定有效期为30分钟
```

### RedemptionService
```yaml
职责: 处理代币赎回流程
方法:
  - initiateRedemption(userId, tokenAmount, destinationAccount): RedemptionRequest
  - burnTokens(requestId): TransactionResult
  - processWithdrawal(requestId): RedemptionRequest
  - settleRedemption(requestId, bankRef): RedemptionRequest

规则:
  - 赎回前检查账户状态
  - 大额赎回需要额外审批
  - T+0到账（工作日）
```

### InterestService
```yaml
职责: 利息计算与分发
方法:
  - calculateAccruedInterest(accountId): BigDecimal
  - distributeInterest(tokenId, period): InterestDistribution
  - updateInterestRate(tokenId, newRate, effectiveTime): RateUpdate
  - compoundInterest(accountId): CompoundResult

规则:
  - 利息按区块累计
  - 每日UTC 00:00结算
  - 利率变更提前24小时公告
```

### ReconciliationService
```yaml
职责: 对账与审计
方法:
  - dailyReconciliation(tokenId, date): ReconciliationReport
  - verifyBankBalance(tokenId): VerificationResult
  - generateAuditTrail(tokenId, period): AuditReport
  - detectDiscrepancy(tokenId): List<Discrepancy>

规则:
  - 每日自动对账
  - 差异超过0.01%触发告警
  - 所有操作留存审计日志
```

---

## 领域事件 (Domain Events)

```yaml
DepositTokenCreated:
  触发: 新存款代币创建
  载荷: tokenId, symbol, partnerBankId, interestRate
  订阅者: 合规服务, 银行网关

TokenizationInitiated:
  触发: 代币化请求创建
  载荷: requestId, userId, depositAmount
  订阅者: 银行网关, 风控服务

TokenizationCompleted:
  触发: 代币化完成
  载荷: requestId, tokenAmount, txHash
  订阅者: 账户服务, 通知服务, 统计服务

RedemptionInitiated:
  触发: 赎回请求创建
  载荷: requestId, userId, tokenAmount
  订阅者: 银行网关, 风控服务

RedemptionSettled:
  触发: 赎回完成
  载荷: requestId, withdrawalAmount, bankRef
  订阅者: 账户服务, 通知服务

InterestDistributed:
  触发: 利息分发完成
  载荷: distributionId, tokenId, totalInterest, recipientCount
  订阅者: 账户服务, 统计服务

InterestRateChanged:
  触发: 利率变更
  载荷: tokenId, oldRate, newRate, effectiveTime
  订阅者: 通知服务, 前端服务

ReconciliationCompleted:
  触发: 对账完成
  载荷: tokenId, date, isBalanced, discrepancies
  订阅者: 合规服务, 告警服务

DiscrepancyDetected:
  触发: 检测到差异
  载荷: tokenId, discrepancyType, amount
  订阅者: 风控服务, 告警服务, 运营团队
```

---

## 上下文映射 (Context Mapping)

```
┌─────────────────────────────────────────────────────────────────┐
│                   Tokenization Context                          │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────┐         │
│  │ DepositToken │  │DepositAccount│  │TokenizationReq│         │
│  │  (聚合根)    │  │  (聚合根)    │  │    (实体)     │         │
│  └──────────────┘  └──────────────┘  └───────────────┘         │
└─────────────────────────────────────────────────────────────────┘
          │                    │                    │
          │                    │                    │
          ▼                    ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  Bank Gateway   │  │ Custody Context │  │Compliance Context│
│  (银行网关)     │  │   (托管钱包)    │  │   (AML/风控)    │
│  - 存款确认     │  │  - 资产托管     │  │  - KYC验证      │
│  - 转账执行     │  │  - 多签管理     │  │  - 交易监控     │
│  - 余额查询     │  │  - 密钥管理     │  │  - 报告生成     │
└─────────────────┘  └─────────────────┘  └─────────────────┘
                               │
                               ▼
                    ┌─────────────────┐
                    │ Lending Context │
                    │   (借贷协议)    │
                    │  - 抵押品接入   │
                    │  - 收益组合     │
                    └─────────────────┘

集成模式:
- Bank Gateway: Anti-Corruption Layer (防腐层)
- Custody: Customer-Supplier
- Compliance: Conformist
- Lending: Partnership
```

---

## 接口契约摘要

### 对外提供的API

```yaml
# 代币化操作
POST /api/v1/tokenization/deposit
  - 发起存款代币化
  - 需要KYC认证
  - 请求体: { amount, sourceBankAccount, tokenId }

POST /api/v1/tokenization/redeem
  - 发起代币赎回
  - 需要持币验证
  - 请求体: { tokenAmount, destinationAccount }

GET /api/v1/tokenization/requests/{requestId}
  - 查询请求状态

# 账户操作
GET /api/v1/accounts/{accountId}/balance
  - 查询账户余额与利息

GET /api/v1/accounts/{accountId}/interest/history
  - 查询利息历史

# 代币信息
GET /api/v1/deposit-tokens/{tokenId}
  - 获取代币详情
  - 公开接口

GET /api/v1/deposit-tokens/{tokenId}/rate
  - 获取当前利率
  - 公开接口

# 内部服务
POST /internal/v1/tokenization/bank-confirm
  - 银行确认回调
  - 仅银行网关可调用

GET /internal/v1/deposit-tokens/{tokenId}/supply
  - 获取供应量
  - 供内部服务调用
```

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| 1.0 | 2025-11-30 | 初始版本 | @领域架构师 |
