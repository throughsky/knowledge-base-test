# RWA领域模型 (Real World Assets Domain Model)

**限界上下文**: RWA Context
**上下文所有者**: 资产代币化团队
**版本**: 1.0
**最后更新**: 2025-11-30

---

## 领域概述

RWA(Real World Assets)领域负责将现实世界资产（房地产、债券、大宗商品、艺术品等）代币化上链，实现资产的数字化确权、分割持有、二级流通和收益分配。本领域连接链下资产与链上金融，是Web3与传统金融融合的核心场景。

<!-- AI-CONTEXT
RWA领域核心职责：
1. 现实资产数字化确权
2. 资产代币发行与管理
3. 资产估值与审计
4. 收益分配与清算
5. 合规报告与监管对接
关键约束：资产必须有合法托管和审计，代币发行需法律合规
-->

---

## 核心概念 (Ubiquitous Language)

### 聚合根 (Aggregate Roots)

#### RealWorldAsset (现实世界资产)
```yaml
定义: 被代币化的链下资产
属性:
  - assetId: UUID
  - assetType: RWAType # 资产类型
  - assetClass: AssetClass # 资产分类
  - name: String
  - description: String
  - legalEntity: LegalEntityInfo # 持有资产的法律实体
  - custodian: CustodianInfo # 托管机构
  - jurisdiction: String # 法律管辖区
  - valuationInfo: ValuationInfo # 估值信息
  - documents: List<LegalDocument> # 法律文档
  - auditHistory: List<AuditRecord> # 审计历史
  - status: AssetStatus
  - createdAt: Timestamp
  - updatedAt: Timestamp

不变式:
  - 必须有有效的法律实体
  - 必须有托管机构
  - 估值不超过90天有效期
```

#### AssetToken (资产代币)
```yaml
定义: 代表RWA权益的链上代币
属性:
  - tokenId: UUID
  - assetId: UUID # 关联的RWA
  - symbol: String
  - name: String
  - tokenType: TokenType # 证券型/实用型
  - tokenStandard: TokenStandard # ERC-20/ERC-1400/ERC-3643
  - totalSupply: BigDecimal
  - circulatingSupply: BigDecimal
  - unitPrice: BigDecimal # 单位价格
  - minInvestment: BigDecimal # 最小投资额
  - maxInvestment: BigDecimal # 最大投资额
  - contractAddress: Address
  - chainId: Integer
  - whitelistEnabled: Boolean # 是否启用白名单
  - transferRestrictions: List<TransferRestriction>
  - dividendInfo: DividendInfo # 分红信息
  - status: TokenStatus
  - createdAt: Timestamp

不变式:
  - totalSupply * unitPrice <= 资产估值
  - 证券型代币必须启用白名单
  - 合规投资者才能持有
```

#### InvestorHolding (投资者持仓)
```yaml
定义: 投资者的资产代币持仓
属性:
  - holdingId: UUID
  - investorId: UUID
  - tokenId: UUID
  - balance: BigDecimal
  - lockedBalance: BigDecimal # 锁定余额
  - averageCost: BigDecimal # 平均成本
  - totalDividendsReceived: BigDecimal
  - accreditationStatus: AccreditationStatus # 合格投资者状态
  - holdingSince: Timestamp
  - lastTransactionAt: Timestamp

不变式:
  - balance >= 0
  - 持仓需满足合格投资者要求
```

### 实体 (Entities)

#### AssetOffering (资产发行)
```yaml
定义: RWA代币发行活动
属性:
  - offeringId: UUID
  - tokenId: UUID
  - offeringType: OfferingType # STO/私募/公募
  - targetAmount: BigDecimal # 目标募集额
  - minAmount: BigDecimal # 最低成功门槛
  - raisedAmount: BigDecimal # 已募集额
  - tokenPrice: BigDecimal # 发行价格
  - startTime: Timestamp
  - endTime: Timestamp
  - eligibleJurisdictions: List<String> # 合规地区
  - investorRequirements: InvestorRequirements
  - subscriptions: List<Subscription>
  - status: OfferingStatus
  - documents: List<OfferingDocument>

生命周期:
  DRAFT → UNDER_REVIEW → APPROVED → OPEN → CLOSED → SETTLED
        → REJECTED | CANCELLED | FAILED
```

#### Subscription (认购)
```yaml
定义: 投资者的认购申请
属性:
  - subscriptionId: UUID
  - offeringId: UUID
  - investorId: UUID
  - requestedAmount: BigDecimal # 申请金额
  - allocatedAmount: BigDecimal # 分配金额
  - tokenAmount: BigDecimal # 获得代币数量
  - paymentMethod: PaymentMethod
  - paymentStatus: PaymentStatus
  - complianceStatus: ComplianceStatus
  - documents: List<SubscriptionDocument>
  - status: SubscriptionStatus
  - createdAt: Timestamp
  - settledAt: Timestamp

生命周期:
  PENDING → COMPLIANCE_CHECK → APPROVED → PAYMENT_PENDING → PAID → SETTLED
          → REJECTED | CANCELLED | REFUNDED
```

#### DividendDistribution (分红分配)
```yaml
定义: 资产收益分配
属性:
  - distributionId: UUID
  - tokenId: UUID
  - recordDate: Timestamp # 登记日
  - paymentDate: Timestamp # 支付日
  - totalAmount: BigDecimal # 总分红金额
  - perTokenAmount: BigDecimal # 每代币分红
  - currency: String # 分红币种
  - eligibleHolders: Integer # 合资格持有人数
  - paidAmount: BigDecimal # 已支付金额
  - status: DistributionStatus
  - taxWithholding: BigDecimal # 预扣税
  - createdAt: Timestamp
```

#### Valuation (估值)
```yaml
定义: 资产估值记录
属性:
  - valuationId: UUID
  - assetId: UUID
  - valuationDate: Timestamp
  - valuationMethod: ValuationMethod
  - valuedAmount: BigDecimal
  - currency: String
  - valuator: ValuatorInfo # 估值机构
  - valuationReport: String # 估值报告链接
  - confidenceLevel: ConfidenceLevel
  - validUntil: Timestamp
  - status: ValuationStatus
```

### 值对象 (Value Objects)

```yaml
RWAType:
  枚举值:
    - REAL_ESTATE # 房地产
    - FIXED_INCOME # 固定收益 (债券)
    - EQUITY # 股权
    - COMMODITY # 大宗商品
    - ART # 艺术品
    - COLLECTIBLE # 收藏品
    - INFRASTRUCTURE # 基础设施
    - PRIVATE_CREDIT # 私募信贷
    - INVOICE # 应收账款

AssetClass:
  枚举值:
    - RESIDENTIAL_RE # 住宅房产
    - COMMERCIAL_RE # 商业房产
    - GOVERNMENT_BOND # 政府债券
    - CORPORATE_BOND # 公司债券
    - PRIVATE_EQUITY # 私募股权
    - PRECIOUS_METAL # 贵金属
    - AGRICULTURAL # 农产品

TokenStandard:
  枚举值:
    - ERC20 # 标准代币
    - ERC1400 # 证券代币
    - ERC3643 # T-REX合规代币
    - ERC4626 # 收益代币

TokenType:
  枚举值:
    - SECURITY # 证券型
    - UTILITY # 实用型
    - HYBRID # 混合型

AccreditationStatus:
  枚举值:
    - NOT_REQUIRED # 无需认证
    - PENDING # 认证中
    - ACCREDITED # 已认证
    - EXPIRED # 已过期
    - REJECTED # 被拒绝

OfferingType:
  枚举值:
    - STO # 证券型代币发行
    - PRIVATE_PLACEMENT # 私募
    - REG_D # Regulation D
    - REG_A # Regulation A+
    - REG_S # Regulation S

ValuationMethod:
  枚举值:
    - MARKET_COMPARABLE # 市场比较法
    - INCOME_APPROACH # 收益法
    - COST_APPROACH # 成本法
    - DCF # 现金流折现
    - NAV # 净资产价值

LegalEntityInfo:
  entityName: String
  entityType: String # SPV, LLC, Trust
  registrationNumber: String
  jurisdiction: String
  incorporationDate: Timestamp

CustodianInfo:
  custodianName: String
  custodianType: String
  licenseNumber: String
  jurisdiction: String
  contactInfo: ContactInfo

TransferRestriction:
  restrictionType: String # LOCKUP, JURISDICTION, ACCREDITATION
  parameters: Map<String, Object>
  effectiveFrom: Timestamp
  effectiveUntil: Timestamp

DividendInfo:
  frequency: String # MONTHLY, QUARTERLY, ANNUAL
  expectedYield: BigDecimal
  lastDistributionDate: Timestamp
  nextDistributionDate: Timestamp
```

---

## 领域服务 (Domain Services)

### AssetOnboardingService
```yaml
职责: 资产入驻和代币化
方法:
  - submitAsset(assetInfo, documents): RealWorldAsset
  - requestValuation(assetId): ValuationRequest
  - createToken(assetId, tokenConfig): AssetToken
  - linkAssetToToken(assetId, tokenId): Linking
  - verifyLegalStructure(assetId): VerificationResult

规则:
  - 资产必须有清晰的法律结构
  - 估值必须由认可机构执行
  - 代币发行需法律审核
```

### OfferingService
```yaml
职责: 发行管理
方法:
  - createOffering(tokenId, offeringConfig): AssetOffering
  - submitForApproval(offeringId): ApprovalRequest
  - openOffering(offeringId): AssetOffering
  - closeOffering(offeringId): AssetOffering
  - settleOffering(offeringId): SettlementResult

规则:
  - 发行需监管审批
  - 达到最低募集额才能结算
  - 未达标需退款
```

### SubscriptionService
```yaml
职责: 认购管理
方法:
  - subscribe(investorId, offeringId, amount): Subscription
  - verifyInvestor(subscriptionId): ComplianceResult
  - processPayment(subscriptionId): PaymentResult
  - allocateTokens(subscriptionId): AllocationResult
  - refundSubscription(subscriptionId): RefundResult

规则:
  - 投资者需通过合规检查
  - 超额认购按比例分配
  - 退款T+3处理
```

### DividendService
```yaml
职责: 分红管理
方法:
  - declareDividend(tokenId, amount, recordDate): DividendDistribution
  - calculateEntitlements(distributionId): List<Entitlement>
  - processDividendPayment(distributionId): PaymentResult
  - handleTaxWithholding(distributionId, jurisdiction): TaxResult

规则:
  - 分红基于登记日持仓
  - 自动处理预扣税
  - 支持多币种分红
```

### ValuationService
```yaml
职责: 估值管理
方法:
  - requestValuation(assetId, method): ValuationRequest
  - submitValuationReport(assetId, report): Valuation
  - schedulePeriodicValuation(assetId, frequency): Schedule
  - triggerRevaluation(assetId, reason): ValuationRequest

规则:
  - 估值有效期最长90天
  - 市场波动超10%触发重估
  - 定期估值 (至少季度)
```

### ComplianceTransferService
```yaml
职责: 合规转让
方法:
  - requestTransfer(from, to, tokenId, amount): TransferRequest
  - checkTransferCompliance(transferId): ComplianceResult
  - executeTransfer(transferId): TransferResult
  - reportTransfer(transferId): ReportResult

规则:
  - 转让双方需在白名单
  - 检查管辖区限制
  - 大额转让需审批
```

---

## 领域事件 (Domain Events)

```yaml
AssetOnboarded:
  触发: 资产入驻完成
  载荷: assetId, assetType, legalEntity, custodian
  订阅者: 合规服务, 估值服务

TokenCreated:
  触发: 资产代币创建
  载荷: tokenId, assetId, symbol, tokenStandard
  订阅者: 市场服务, 钱包服务

OfferingOpened:
  触发: 发行开始
  载荷: offeringId, tokenId, targetAmount, endTime
  订阅者: 通知服务, 市场服务

SubscriptionReceived:
  触发: 收到认购
  载荷: subscriptionId, investorId, amount
  订阅者: 合规服务, 支付服务

OfferingSettled:
  触发: 发行结算
  载荷: offeringId, totalRaised, investorCount
  订阅者: 代币分发服务, 统计服务

DividendDeclared:
  触发: 宣布分红
  载荷: distributionId, tokenId, totalAmount, recordDate
  订阅者: 账户服务, 通知服务

DividendPaid:
  触发: 分红支付
  载荷: distributionId, paidAmount, recipientCount
  订阅者: 统计服务, 税务服务

ValuationCompleted:
  触发: 估值完成
  载荷: valuationId, assetId, valuedAmount, validUntil
  订阅者: 代币服务, 风控服务

TransferCompleted:
  触发: 转让完成
  载荷: tokenId, from, to, amount, txHash
  订阅者: 持仓服务, 合规报告服务

ComplianceAlert:
  触发: 合规告警
  载荷: assetId/tokenId, alertType, severity
  订阅者: 合规团队, 风控服务
```

---

## 上下文映射 (Context Mapping)

```
┌─────────────────────────────────────────────────────────────────┐
│                        RWA Context                              │
│  ┌───────────────┐ ┌──────────────┐ ┌────────────────┐         │
│  │RealWorldAsset │ │  AssetToken  │ │InvestorHolding │         │
│  │   (聚合根)    │ │   (聚合根)   │ │    (聚合根)    │         │
│  └───────────────┘ └──────────────┘ └────────────────┘         │
└─────────────────────────────────────────────────────────────────┘
          │                    │                    │
          │                    │                    │
          ▼                    ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ Custody Context │  │Compliance Context│ │ Stablecoin Ctx  │
│  - 资产托管     │  │  - 投资者认证   │  │  - 支付结算     │
│  - 代币保管     │  │  - 转让审批     │  │  - 分红支付     │
│  - 收益托管     │  │  - 监管报告     │  │                 │
└─────────────────┘  └─────────────────┘  └─────────────────┘
          │
          ▼
┌─────────────────┐  ┌─────────────────┐
│ Lending Context │  │External Valuator│
│  - 抵押借贷     │  │  - 第三方估值   │
│  - RWA抵押品    │  │  - 审计报告     │
└─────────────────┘  └─────────────────┘

集成模式:
- Custody: Customer-Supplier (RWA依赖托管)
- Compliance: Conformist (必须遵守合规规则)
- Stablecoin: Partnership (双向结算)
- Lending: Customer-Supplier (RWA作为抵押品)
- External Valuator: Anti-Corruption Layer (防腐层)
```

---

## 接口契约摘要

### 对外提供的API

```yaml
# 资产管理
POST /api/v1/rwa/assets
  - 提交资产入驻
  - 需要机构认证

GET /api/v1/rwa/assets/{assetId}
  - 获取资产详情

POST /api/v1/rwa/assets/{assetId}/valuation
  - 请求估值

# 代币管理
GET /api/v1/rwa/tokens/{tokenId}
  - 获取代币详情
  - 公开接口

GET /api/v1/rwa/tokens/{tokenId}/holders
  - 获取持有人列表 (脱敏)

# 发行管理
GET /api/v1/rwa/offerings
  - 获取发行列表

POST /api/v1/rwa/offerings/{offeringId}/subscribe
  - 认购
  - 需要投资者认证

# 持仓与分红
GET /api/v1/rwa/holdings
  - 获取我的持仓

GET /api/v1/rwa/dividends
  - 获取分红记录

# 内部服务
GET /internal/v1/rwa/tokens/{tokenId}/eligible-holders
  - 获取合资格持有人
  - 供分红服务调用

POST /internal/v1/rwa/compliance/transfer-check
  - 转让合规检查
  - 供托管服务调用
```

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| 1.0 | 2025-11-30 | 初始版本 | @领域架构师 |
