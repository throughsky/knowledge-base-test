# 合规领域模型

## 领域概述

合规领域是整个Web3金融平台的合规基石，负责反洗钱(AML)、客户尽职调查(KYC)、交易监控和风险控制，拥有平台最高权限。

## 核心概念

### 聚合根

| 聚合根 | 定义 |
|--------|------|
| **CustomerProfile** | 客户合规档案，包含KYC状态、风险评分 |
| **TransactionMonitoring** | 交易监控，包含风险指标、触发规则 |
| **SARReport** | 可疑活动报告，包含嫌疑类型、提交状态 |

### 关键实体

| 实体 | 定义 |
|------|------|
| RiskIndicator | 风险指标 |
| RuleTrigger | 规则触发记录 |
| Alert | 告警记录 |
| SanctionMatch | 制裁匹配记录 |

### 值对象

```yaml
KYCLevel: LEVEL_0 | LEVEL_1 | LEVEL_2 | LEVEL_3 | LEVEL_4 | LEVEL_5
RiskLevel: LOW | MEDIUM | HIGH | VERY_HIGH
KYCStatus: PENDING | APPROVED | REJECTED | EXPIRED
AlertLevel: INFO | WARNING | CRITICAL | BLOCKED
```

## 核心流程

### KYC验证流程
```
信息提交 → 文档验证 → 制裁筛查 → 风险评估 → 通过/拒绝
```

### 交易监控流程
```
交易发起 → 规则评估 → 风险评分 → 告警/放行 → 审核(如需)
```

## 业务规则

1. **合规优先**: 所有可疑活动必须报告
2. **制裁匹配**: 立即冻结账户
3. **大额报告**: 超过阈值自动生成CTR
4. **SAR时限**: 必须在规定时限内提交

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
  conditions:
    - field: "amount_usd"
      operator: ">="
      value: "10000"
  actions:
    - type: "CREATE_CTR"

# 拆分交易检测
structuring_rule:
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
  conditions:
    - field: "counterparty_country"
      operator: "IN"
      value: ["IR", "KP", "SY"]
  actions:
    - type: "BLOCK_TRANSACTION"
    - type: "NOTIFY_MLRO"
```

## 特殊权限

合规服务拥有平台最高权限：
- **可冻结任何账户**
- **可阻止任何交易**
- **有最高数据访问权限**
- **所有业务服务必须遵守合规决定**

## 领域事件

| 事件 | 触发 | 订阅者 |
|------|------|--------|
| KYCVerified | KYC验证通过 | 账户服务, 限额服务 |
| KYCRejected | KYC验证拒绝 | 账户服务 |
| RiskLevelChanged | 风险等级变化 | 监控服务, 限额服务 |
| SanctionMatchFound | 制裁匹配 | 冻结服务, MLRO |
| TransactionFlagged | 交易被标记 | 告警服务 |
| AccountFrozen | 账户冻结 | 所有业务服务 |
| SARFiled | SAR提交 | 审计服务 |

## 依赖关系

- **上游**: 无 (核心基础设施)
- **下游**: 所有业务服务 (作为合规检查供应商)
