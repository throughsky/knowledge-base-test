# 合规领域模型 (Compliance Domain Model)

**限界上下文**: Compliance Context
**上下文所有者**: 合规与风控团队
**版本**: 1.0
**最后更新**: 2025-11-30

---

## 领域概述

合规领域负责反洗钱(AML)、客户尽职调查(KYC)、交易监控、风险控制和监管报告。本领域是整个Web3金融平台的合规基石，确保所有业务活动符合全球监管要求。

<!-- AI-CONTEXT
合规领域核心职责：
1. KYC身份验证与尽职调查
2. AML反洗钱交易监控
3. 制裁名单筛查
4. 风险评分与控制
5. 监管报告生成
关键约束：合规优先于业务，所有可疑活动必须报告
-->

---

## 核心概念 (Ubiquitous Language)

### 聚合根 (Aggregate Roots)

#### CustomerProfile (客户档案)
```yaml
定义: 客户的合规档案
属性:
  - profileId: UUID
  - customerId: UUID # 关联的用户ID
  - customerType: CustomerType # 个人/机构
  - kycStatus: KYCStatus # KYC状态
  - kycLevel: KYCLevel # KYC等级
  - riskScore: BigDecimal # 风险评分 (0-100)
  - riskLevel: RiskLevel # 风险等级
  - personalInfo: PersonalInfo # 个人信息 (加密)
  - identityDocuments: List<IdentityDocument> # 身份文件
  - addressInfo: AddressInfo # 地址信息
  - sourceOfFunds: SourceOfFunds # 资金来源
  - pepStatus: PEPStatus # 政治敏感人物状态
  - sanctionStatus: SanctionStatus # 制裁状态
  - kycVerifications: List<KYCVerification> # 验证历史
  - eddRequired: Boolean # 是否需要增强尽调
  - eddRecords: List<EDDRecord> # 增强尽调记录
  - jurisdiction: String # 管辖区
  - onboardingDate: Timestamp
  - lastReviewDate: Timestamp
  - nextReviewDate: Timestamp
  - status: ProfileStatus
  - createdAt: Timestamp
  - updatedAt: Timestamp

不变式:
  - 风险评分必须基于最新数据
  - 高风险客户必须进行EDD
  - 定期复审间隔不超过规定期限
```

#### TransactionMonitoring (交易监控)
```yaml
定义: 交易监控记录
属性:
  - monitoringId: UUID
  - transactionId: UUID # 被监控的交易
  - transactionType: String # 交易类型
  - customerId: UUID
  - amount: BigDecimal
  - currency: String
  - counterparty: CounterpartyInfo
  - riskIndicators: List<RiskIndicator> # 风险指标
  - rulesTriggerred: List<RuleTrigger> # 触发的规则
  - riskScore: BigDecimal # 交易风险评分
  - alertLevel: AlertLevel # 告警级别
  - status: MonitoringStatus
  - reviewerId: UUID # 审核人
  - reviewOutcome: ReviewOutcome
  - reviewNotes: String
  - createdAt: Timestamp
  - reviewedAt: Timestamp

不变式:
  - 高风险交易必须人工审核
  - 审核结果必须有理由说明
```

#### SARReport (可疑活动报告)
```yaml
定义: 可疑活动报告
属性:
  - reportId: UUID
  - reportType: SARType # 报告类型
  - customerId: UUID # 涉及的客户
  - relatedTransactions: List<UUID> # 关联交易
  - suspicionType: SuspicionType # 可疑类型
  - suspicionDescription: String # 可疑描述
  - indicatorsIdentified: List<String> # 识别的指标
  - narrativeSummary: String # 叙述性总结
  - reportingOfficer: UUID # 报告人
  - supervisorApproval: UUID # 主管审批
  - filingStatus: FilingStatus # 提交状态
  - regulatoryBody: String # 监管机构
  - referenceNumber: String # 监管参考号
  - filedAt: Timestamp
  - createdAt: Timestamp

不变式:
  - 必须在规定时限内提交
  - 必须有主管审批
```

### 实体 (Entities)

#### KYCVerification (KYC验证)
```yaml
定义: 单次KYC验证
属性:
  - verificationId: UUID
  - profileId: UUID
  - verificationType: VerificationType
  - verificationMethod: VerificationMethod
  - provider: String # 验证服务商
  - providerReference: String
  - documentType: DocumentType
  - documentNumber: String # (加密)
  - documentCountry: String
  - verificationResult: VerificationResult
  - confidenceScore: BigDecimal
  - failureReasons: List<String>
  - rawResponse: String # 原始响应 (加密)
  - expiresAt: Timestamp # 验证有效期
  - createdAt: Timestamp
```

#### RiskAssessment (风险评估)
```yaml
定义: 客户风险评估
属性:
  - assessmentId: UUID
  - profileId: UUID
  - assessmentType: AssessmentType
  - assessmentDate: Timestamp
  - riskFactors: List<RiskFactor>
  - previousScore: BigDecimal
  - newScore: BigDecimal
  - previousLevel: RiskLevel
  - newLevel: RiskLevel
  - assessedBy: String # 系统/人工
  - assessorId: UUID # 评估人 (如人工)
  - rationale: String # 评估理由
  - recommendations: List<String>
```

#### SanctionScreening (制裁筛查)
```yaml
定义: 制裁名单筛查记录
属性:
  - screeningId: UUID
  - profileId: UUID
  - screeningType: ScreeningType
  - screeningDate: Timestamp
  - listsChecked: List<String> # 筛查的名单
  - matches: List<SanctionMatch> # 匹配结果
  - matchStatus: MatchStatus
  - falsePositive: Boolean # 误报
  - reviewerId: UUID
  - reviewNotes: String
  - createdAt: Timestamp
```

#### ComplianceRule (合规规则)
```yaml
定义: 合规监控规则
属性:
  - ruleId: UUID
  - ruleName: String
  - ruleType: RuleType
  - ruleCategory: RuleCategory
  - description: String
  - conditions: List<RuleCondition> # 触发条件
  - actions: List<RuleAction> # 触发动作
  - severity: Severity
  - enabled: Boolean
  - jurisdiction: String # 适用管辖区
  - effectiveFrom: Timestamp
  - effectiveUntil: Timestamp
  - createdBy: UUID
  - createdAt: Timestamp
```

#### Alert (合规告警)
```yaml
定义: 合规告警
属性:
  - alertId: UUID
  - alertType: AlertType
  - severity: Severity
  - customerId: UUID
  - triggeredBy: String # 触发源
  - ruleId: UUID # 触发规则
  - description: String
  - evidence: List<Evidence>
  - status: AlertStatus
  - assignedTo: UUID # 分配给
  - priority: Priority
  - dueDate: Timestamp
  - resolution: Resolution
  - resolvedAt: Timestamp
  - createdAt: Timestamp
```

### 值对象 (Value Objects)

```yaml
CustomerType:
  枚举值:
    - INDIVIDUAL # 个人
    - CORPORATE # 企业
    - INSTITUTION # 机构

KYCStatus:
  枚举值:
    - NOT_STARTED # 未开始
    - PENDING # 待审核
    - VERIFIED # 已验证
    - REJECTED # 已拒绝
    - EXPIRED # 已过期
    - UNDER_REVIEW # 审核中

KYCLevel:
  枚举值:
    - LEVEL_0 # 未验证
    - LEVEL_1 # 基础验证 (邮箱+手机)
    - LEVEL_2 # 身份验证 (证件)
    - LEVEL_3 # 地址验证 (地址证明)
    - LEVEL_4 # 增强验证 (视频认证)
    - LEVEL_5 # 机构验证 (企业尽调)

RiskLevel:
  枚举值:
    - LOW # 低风险
    - MEDIUM # 中风险
    - HIGH # 高风险
    - VERY_HIGH # 极高风险
    - PROHIBITED # 禁止

AlertLevel:
  枚举值:
    - INFO # 信息
    - LOW # 低
    - MEDIUM # 中
    - HIGH # 高
    - CRITICAL # 严重

VerificationType:
  枚举值:
    - IDENTITY # 身份验证
    - DOCUMENT # 文档验证
    - ADDRESS # 地址验证
    - LIVENESS # 活体检测
    - BIOMETRIC # 生物识别
    - AML_SCREENING # AML筛查
    - PEP_SCREENING # PEP筛查
    - ADVERSE_MEDIA # 负面媒体

DocumentType:
  枚举值:
    - PASSPORT # 护照
    - NATIONAL_ID # 身份证
    - DRIVERS_LICENSE # 驾照
    - UTILITY_BILL # 水电账单
    - BANK_STATEMENT # 银行对账单
    - TAX_DOCUMENT # 税务文件
    - COMPANY_REGISTRY # 公司注册文件

SuspicionType:
  枚举值:
    - MONEY_LAUNDERING # 洗钱
    - TERRORIST_FINANCING # 恐怖融资
    - FRAUD # 欺诈
    - SANCTIONS_EVASION # 制裁规避
    - TAX_EVASION # 逃税
    - STRUCTURING # 拆分交易
    - UNUSUAL_PATTERN # 异常模式

RuleCategory:
  枚举值:
    - THRESHOLD # 阈值规则
    - VELOCITY # 速率规则
    - PATTERN # 模式规则
    - BEHAVIORAL # 行为规则
    - GEOGRAPHIC # 地理规则
    - COUNTERPARTY # 对手方规则

PersonalInfo:
  firstName: String
  lastName: String
  dateOfBirth: Date
  nationality: String
  countryOfResidence: String
  email: String
  phone: String

CounterpartyInfo:
  address: String # 链上地址或账户
  name: String # 如已知
  type: String # 钱包类型
  riskLabel: String # 风险标签

RiskIndicator:
  indicatorType: String
  indicatorValue: String
  weight: BigDecimal
  description: String

RuleCondition:
  field: String
  operator: String
  value: String
  logicalOperator: String # AND/OR

Evidence:
  evidenceType: String
  description: String
  reference: String
  timestamp: Timestamp
```

---

## 领域服务 (Domain Services)

### KYCService
```yaml
职责: KYC验证管理
方法:
  - initiateKYC(customerId, level): KYCProcess
  - submitDocument(processId, document): SubmissionResult
  - verifyIdentity(processId): VerificationResult
  - verifyAddress(processId): VerificationResult
  - performLivenessCheck(processId): LivenessResult
  - approveKYC(processId, approverId): ApprovalResult
  - rejectKYC(processId, reason): RejectionResult
  - scheduleReview(profileId): ReviewSchedule

规则:
  - 验证顺序: 身份→活体→地址
  - 失败3次需人工审核
  - KYC有效期根据风险等级
```

### AMLScreeningService
```yaml
职责: AML筛查
方法:
  - screenCustomer(customerId): ScreeningResult
  - screenTransaction(transactionId): ScreeningResult
  - checkSanctionsList(entity): SanctionResult
  - checkPEPStatus(customerId): PEPResult
  - checkAdverseMedia(customerId): MediaResult
  - resolveMatch(matchId, resolution): ResolutionResult

规则:
  - 每笔交易实时筛查
  - 客户定期全量筛查
  - 制裁匹配立即冻结
```

### TransactionMonitoringService
```yaml
职责: 交易监控
方法:
  - monitorTransaction(transaction): MonitoringResult
  - evaluateRules(transactionId): List<RuleTrigger>
  - calculateTransactionRisk(transactionId): RiskScore
  - createAlert(monitoringId, alertType): Alert
  - reviewTransaction(monitoringId, outcome, notes): ReviewResult

规则:
  - 实时监控所有交易
  - 规则引擎自动评估
  - 高风险自动创建告警
```

### RiskAssessmentService
```yaml
职责: 风险评估
方法:
  - assessCustomerRisk(customerId): RiskAssessment
  - calculateRiskScore(factors): BigDecimal
  - updateRiskLevel(customerId, newLevel): Result
  - performPeriodicReview(customerId): ReviewResult
  - identifyHighRiskIndicators(customerId): List<RiskIndicator>

规则:
  - 综合评估多维度风险
  - 风险等级变更需审批
  - 高风险客户增加监控
```

### SARReportingService
```yaml
职责: 可疑活动报告
方法:
  - createSAR(customerId, suspicionType): SARReport
  - addEvidence(reportId, evidence): Result
  - submitForApproval(reportId): ApprovalRequest
  - approveAndFile(reportId, approverId): FilingResult
  - trackFilingStatus(reportId): FilingStatus

规则:
  - SAR必须在发现后规定时间内提交
  - 需要MLRO审批
  - 保密原则 (不告知客户)
```

### AlertManagementService
```yaml
职责: 告警管理
方法:
  - createAlert(alertType, customerId, details): Alert
  - assignAlert(alertId, userId): AssignmentResult
  - investigateAlert(alertId): InvestigationResult
  - escalateAlert(alertId, reason): EscalationResult
  - resolveAlert(alertId, resolution): ResolutionResult
  - getAlertQueue(userId): List<Alert>

规则:
  - 告警按优先级分配
  - SLA时限内处理
  - 升级机制确保处理
```

### ComplianceReportingService
```yaml
职责: 合规报告
方法:
  - generateCTR(threshold, period): CTRReport # 大额交易报告
  - generateSTR(period): STRReport # 可疑交易报告
  - generateRegulatoryReport(reportType, period): Report
  - submitToRegulator(reportId): SubmissionResult
  - getReportingMetrics(period): Metrics

规则:
  - 定期生成监管报告
  - 格式符合当地要求
  - 按时提交监管机构
```

---

## 领域事件 (Domain Events)

```yaml
KYCInitiated:
  触发: KYC流程开始
  载荷: profileId, customerId, kycLevel
  订阅者: 验证服务, 通知服务

KYCVerified:
  触发: KYC验证通过
  载荷: profileId, kycLevel, verificationDate
  订阅者: 账户服务, 限额服务, 通知服务

KYCRejected:
  触发: KYC验证拒绝
  载荷: profileId, reason, rejectedAt
  订阅者: 账户服务, 通知服务

RiskLevelChanged:
  触发: 风险等级变化
  载荷: profileId, oldLevel, newLevel, reason
  订阅者: 监控服务, 限额服务, 通知服务

SanctionMatchFound:
  触发: 发现制裁匹配
  载荷: profileId, matchDetails, severity
  订阅者: 冻结服务, 告警服务, MLRO

TransactionFlagged:
  触发: 交易被标记
  载荷: transactionId, customerId, flagReason, riskScore
  订阅者: 告警服务, 审核队列

AlertCreated:
  触发: 告警创建
  载荷: alertId, alertType, severity, customerId
  订阅者: 告警分配服务, 通知服务

AlertResolved:
  触发: 告警解决
  载荷: alertId, resolution, resolvedBy
  订阅者: 统计服务, 审计服务

SARFiled:
  触发: SAR提交
  载荷: reportId, customerId, filedAt
  订阅者: 审计服务, MLRO

AccountFrozen:
  触发: 账户冻结
  载荷: customerId, reason, frozenBy
  订阅者: 所有业务服务, 通知服务

ComplianceReviewScheduled:
  触发: 定期审核安排
  载荷: profileId, reviewType, scheduledDate
  订阅者: 审核队列, 通知服务

RegulatoryReportSubmitted:
  触发: 监管报告提交
  载荷: reportId, reportType, submittedTo
  订阅者: 审计服务
```

---

## 上下文映射 (Context Mapping)

```
┌─────────────────────────────────────────────────────────────────┐
│                     Compliance Context                          │
│  ┌───────────────┐ ┌────────────────┐ ┌──────────────┐         │
│  │CustomerProfile│ │TxnMonitoring  │ │  SARReport   │         │
│  │   (聚合根)    │ │   (聚合根)     │ │  (聚合根)    │         │
│  └───────────────┘ └────────────────┘ └──────────────┘         │
└─────────────────────────────────────────────────────────────────┘
          │                    │                    │
          │ Enforces           │ Monitors           │ Reports
          ▼                    ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ All Business    │  │   Regulatory    │  │  External KYC   │
│   Contexts      │  │    Bodies       │  │   Providers     │
│ - 稳定币        │  │  - FinCEN       │  │  - Jumio        │
│ - 代币化        │  │  - FCA          │  │  - Onfido       │
│ - 托管          │  │  - MAS          │  │  - Chainalysis  │
│ - RWA           │  │  - ...          │  │  - Elliptic     │
│ - Staking       │  │                 │  │                 │
│ - Lending       │  │                 │  │                 │
│ - Bridge        │  │                 │  │                 │
└─────────────────┘  └─────────────────┘  └─────────────────┘

集成模式:
- Business Contexts: Conformist (必须遵守合规)
- Regulatory Bodies: Open Host Service (标准接口)
- External Providers: Anti-Corruption Layer (防腐层)

特殊权限:
- 合规可冻结任何账户
- 合规可阻止任何交易
- 合规有最高数据访问权限
```

---

## 合规规则示例

```yaml
# 阈值规则
large_transaction_rule:
  name: "大额交易报告"
  category: THRESHOLD
  conditions:
    - field: "amount_usd"
      operator: ">="
      value: "10000"
  actions:
    - type: "CREATE_CTR"
    - type: "NOTIFY_COMPLIANCE"

# 速率规则
velocity_rule:
  name: "高频交易检测"
  category: VELOCITY
  conditions:
    - field: "transaction_count_24h"
      operator: ">="
      value: "50"
  actions:
    - type: "CREATE_ALERT"
      severity: "MEDIUM"
    - type: "FLAG_FOR_REVIEW"

# 模式规则
structuring_rule:
  name: "拆分交易检测"
  category: PATTERN
  conditions:
    - field: "amount_usd"
      operator: "BETWEEN"
      value: "9000,9999"
    - field: "transaction_count_24h"
      operator: ">="
      value: "3"
  actions:
    - type: "CREATE_ALERT"
      severity: "HIGH"
    - type: "FLAG_FOR_SAR_REVIEW"

# 地理规则
high_risk_jurisdiction_rule:
  name: "高风险地区交易"
  category: GEOGRAPHIC
  conditions:
    - field: "counterparty_country"
      operator: "IN"
      value: ["IR", "KP", "SY", "CU"]
  actions:
    - type: "BLOCK_TRANSACTION"
    - type: "CREATE_ALERT"
      severity: "CRITICAL"
    - type: "NOTIFY_MLRO"
```

---

## 接口契约摘要

### 对外提供的API

```yaml
# KYC
POST /api/v1/compliance/kyc/initiate
  - 发起KYC
  - 请求体: { level }

POST /api/v1/compliance/kyc/documents
  - 上传文档

GET /api/v1/compliance/kyc/status
  - 获取KYC状态

# 用户查询
GET /api/v1/compliance/profile
  - 获取我的合规档案

GET /api/v1/compliance/limits
  - 获取我的交易限额

# 内部服务接口 (其他领域调用)
POST /internal/v1/compliance/screen/customer
  - 筛查客户
  - 供注册服务调用

POST /internal/v1/compliance/screen/transaction
  - 筛查交易
  - 供所有交易服务调用

GET /internal/v1/compliance/customer/{customerId}/status
  - 获取客户合规状态

GET /internal/v1/compliance/customer/{customerId}/limits
  - 获取客户限额

POST /internal/v1/compliance/freeze
  - 冻结账户
  - 需要MLRO权限

POST /internal/v1/compliance/unfreeze
  - 解冻账户
  - 需要MLRO权限

# 管理接口 (合规团队使用)
GET /admin/v1/compliance/alerts
  - 获取告警列表

POST /admin/v1/compliance/alerts/{alertId}/resolve
  - 解决告警

GET /admin/v1/compliance/sar
  - 获取SAR列表

POST /admin/v1/compliance/sar/{reportId}/approve
  - 审批SAR

GET /admin/v1/compliance/reports
  - 获取监管报告
```

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| 1.0 | 2025-11-30 | 初始版本 | @领域架构师 |
