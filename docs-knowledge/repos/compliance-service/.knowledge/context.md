# Compliance Service 上下文

> 最后更新: 2024-01-15
> 此文件由开发者维护，定期聚合到项目知识库

## 仓库概述

合规服务是整个Web3金融平台的合规基石，负责反洗钱(AML)、客户尽职调查(KYC)、交易监控和风险控制。

## 架构概览

```
┌─────────────────────────────────────────────────────┐
│                Compliance Service                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │   KYC API   │  │   AML API   │  │ Report API  │  │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  │
│         │                │                │          │
│  ┌──────▼────────────────▼────────────────▼──────┐  │
│  │                Domain Services                 │  │
│  │  - KYCService                                 │  │
│  │  - AMLScreeningService                        │  │
│  │  - TransactionMonitoringService               │  │
│  │  - RiskAssessmentService                      │  │
│  │  - SARReportingService                        │  │
│  └──────────────────────┬────────────────────────┘  │
│                         │                           │
│  ┌──────────────────────▼────────────────────────┐  │
│  │              Rule Engine                       │  │
│  │  (Drools规则引擎 - 合规规则执行)              │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
           │              │              │
           ▼              ▼              ▼
    ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
    │ External    │ │ All Business│ │ Regulatory  │
    │ KYC Provider│ │  Services   │ │   Bodies    │
    │ (Jumio等)   │ │ (被筛查)    │ │ (报告提交)  │
    └─────────────┘ └─────────────┘ └─────────────┘
```

## 核心领域模型

### 聚合根

```java
// CustomerProfile - 客户合规档案
public class CustomerProfile {
    private ProfileId id;
    private CustomerId customerId;
    private KYCStatus kycStatus;
    private KYCLevel kycLevel;          // LEVEL_0 到 LEVEL_5
    private BigDecimal riskScore;        // 0-100
    private RiskLevel riskLevel;         // LOW, MEDIUM, HIGH, VERY_HIGH
    private PEPStatus pepStatus;
    private SanctionStatus sanctionStatus;
    private LocalDateTime nextReviewDate;
}

// TransactionMonitoring - 交易监控
public class TransactionMonitoring {
    private MonitoringId id;
    private TransactionId transactionId;
    private List<RiskIndicator> riskIndicators;
    private List<RuleTrigger> triggeredRules;
    private BigDecimal riskScore;
    private AlertLevel alertLevel;
    private ReviewOutcome reviewOutcome;
}

// SARReport - 可疑活动报告
public class SARReport {
    private ReportId id;
    private CustomerId customerId;
    private SuspicionType suspicionType;
    private FilingStatus filingStatus;
    private String regulatoryBody;
}
```

## KYC等级定义

| 等级 | 验证内容 | 限额 |
|------|----------|------|
| LEVEL_0 | 未验证 | $0 |
| LEVEL_1 | 邮箱+手机 | $1,000/天 |
| LEVEL_2 | 身份证件 | $10,000/天 |
| LEVEL_3 | 地址证明 | $50,000/天 |
| LEVEL_4 | 视频认证 | $100,000/天 |
| LEVEL_5 | 机构尽调 | 无限额 |

## 合规规则示例

```yaml
# 大额交易报告
large_transaction_rule:
  name: "大额交易报告"
  conditions:
    - field: "amount_usd"
      operator: ">="
      value: "10000"
  actions:
    - type: "CREATE_CTR"

# 拆分交易检测
structuring_rule:
  name: "拆分交易检测"
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

# 高风险地区
high_risk_jurisdiction_rule:
  name: "高风险地区交易"
  conditions:
    - field: "counterparty_country"
      operator: "IN"
      value: ["IR", "KP", "SY"]
  actions:
    - type: "BLOCK_TRANSACTION"
    - type: "NOTIFY_MLRO"
```

## 外部依赖

| 服务 | 用途 | 接口 |
|------|------|------|
| Jumio/Onfido | KYC验证 | REST |
| Chainalysis | 链上地址筛查 | REST |
| World-Check | 制裁名单 | REST |

## 发布的领域事件

| 事件 | 触发条件 | 消费者 |
|------|----------|--------|
| KYCVerified | KYC验证通过 | 账户服务, 限额服务 |
| KYCRejected | KYC验证拒绝 | 账户服务 |
| RiskLevelChanged | 风险等级变化 | 监控服务, 限额服务 |
| SanctionMatchFound | 制裁匹配 | 冻结服务, MLRO |
| TransactionFlagged | 交易被标记 | 告警服务 |
| AccountFrozen | 账户冻结 | 所有业务服务 |
| SARFiled | SAR提交 | 审计服务 |

## 特殊权限说明

合规服务拥有平台最高权限：
- 可冻结任何账户
- 可阻止任何交易
- 有最高数据访问权限
- 所有业务服务必须遵守合规决定

## 已知问题和待办

- [ ] 接入更多KYC服务商
- [ ] 实现机器学习风险模型
- [ ] 添加实时交易监控仪表板

## 近期变更

### 2024-01-10
- 新增PEP筛查规则
- 优化制裁名单匹配算法

### 2024-01-05
- 升级Chainalysis API到v3
- 修复SAR报告生成格式问题
