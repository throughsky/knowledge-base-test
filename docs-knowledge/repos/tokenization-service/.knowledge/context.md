# Tokenization Service 上下文

> 最后更新: 2024-01-15
> 此文件由开发者维护，定期聚合到项目知识库

## 仓库概述

存款代币化服务负责将传统银行存款转换为链上代币，实现存款的数字化、可编程化和可组合性，是银行数字化转型的核心基础设施。

## 架构概览

```
┌─────────────────────────────────────────────────────┐
│               Tokenization Service                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │Tokenize API │  │ Redeem API  │  │Interest API │  │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  │
│         │                │                │          │
│  ┌──────▼────────────────▼────────────────▼──────┐  │
│  │              Domain Services                   │  │
│  │  - TokenizationService                        │  │
│  │  - RedemptionService                          │  │
│  │  - InterestService                            │  │
│  │  - ReconciliationService                      │  │
│  └──────────────────────┬────────────────────────┘  │
│                         │                           │
│  ┌──────────────────────▼────────────────────────┐  │
│  │              Bank Gateway                      │  │
│  │  (银行系统对接 - 存款确认/转账执行)           │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
           │              │              │
           ▼              ▼              ▼
    ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
    │ Partner     │ │   Custody   │ │   Lending   │
    │   Banks     │ │  (代币托管) │ │(抵押品接入) │
    └─────────────┘ └─────────────┘ └─────────────┘
```

## 核心领域模型

### 聚合根

```java
// DepositToken - 存款代币
public class DepositToken {
    private TokenId id;
    private String symbol;           // dUSD, dEUR
    private BigDecimal totalSupply;
    private DepositInfo underlyingDeposit;
    private UUID partnerBankId;
    private BigDecimal interestRate;
    private InterestModel interestModel;
    private Address contractAddress;
    private TokenStatus status;
}

// DepositAccount - 存款账户
public class DepositAccount {
    private AccountId id;
    private UserId userId;
    private TokenId tokenId;
    private BigDecimal balance;
    private BigDecimal accruedInterest;
    private AccountStatus status;
}
```

### 关键实体

```java
// TokenizationRequest - 代币化请求
public class TokenizationRequest {
    private RequestId id;
    private BigDecimal depositAmount;
    private BankAccountInfo sourceBankAccount;
    private String bankConfirmationId;
    private TokenizationStatus status;
    // 生命周期: PENDING → DEPOSIT_RECEIVED → BANK_CONFIRMED → MINTING → COMPLETED
}

// RedemptionRequest - 赎回请求
public class RedemptionRequest {
    private RequestId id;
    private BigDecimal tokenAmount;
    private BankAccountInfo destinationAccount;
    private RedemptionStatus status;
    // 生命周期: PENDING → TOKEN_BURNED → PROCESSING → BANK_TRANSFER → SETTLED
}
```

## 存款类型

| 类型 | 说明 | 利率 |
|------|------|------|
| DEMAND | 活期存款 | 浮动 |
| TIME_1M | 1月定期 | 固定 |
| TIME_3M | 3月定期 | 固定 |
| TIME_6M | 6月定期 | 固定 |
| TIME_1Y | 1年定期 | 固定 |

## 利息分发方式

| 方式 | 说明 |
|------|------|
| MINT_TO_HOLDERS | 铸造新代币分发给持有者 |
| REBASE | 调整代币供应量 |
| AIRDROP | 空投奖励代币 |

## 核心不变式

```
代币总供应量 == 托管存款总额

每次供应量变化需银行确认
```

## 外部依赖

| 服务 | 用途 | 接口 |
|------|------|------|
| Partner Banks | 存款确认/转账 | REST |
| Custody Service | 代币托管 | gRPC |
| Compliance Service | KYC验证 | gRPC |

## 发布的领域事件

| 事件 | 触发条件 | 消费者 |
|------|----------|--------|
| TokenizationInitiated | 代币化请求创建 | 银行网关 |
| TokenizationCompleted | 代币化完成 | 账户服务, 统计服务 |
| RedemptionInitiated | 赎回请求创建 | 银行网关 |
| RedemptionSettled | 赎回完成 | 账户服务 |
| InterestDistributed | 利息分发 | 账户服务, 统计服务 |
| InterestRateChanged | 利率变更 | 通知服务 |
| ReconciliationCompleted | 对账完成 | 合规服务 |
| DiscrepancyDetected | 差异检测 | 风控服务, 告警 |

## 配置说明

```yaml
tokenization:
  tokens:
    - symbol: dUSD
      partner-bank: bank-001
      interest-rate: 0.045
      interest-model: COMPOUND_DAILY

  reconciliation:
    schedule: "0 0 * * *"    # 每日凌晨
    discrepancy-threshold: 0.0001  # 0.01%

  redemption:
    settlement-time: T+0     # 工作日当日
    large-amount-threshold: 100000
```

## 已知问题和待办

- [ ] 支持更多银行合作伙伴
- [ ] 实现跨行存款代币化
- [ ] 添加实时利率推送

## 近期变更

### 2024-01-10
- 新增EUR存款代币支持
- 优化对账性能

### 2024-01-05
- 修复利息计算精度问题
- 添加大额赎回审批流程
