# RWA Service 上下文

> 最后更新: 2024-01-15
> 此文件由开发者维护，定期聚合到项目知识库

## 仓库概述

RWA服务负责将现实世界资产(Real World Assets)代币化上链，实现资产的数字化确权、分割持有和收益分配。

## 架构概览

```
┌─────────────────────────────────────────────────────┐
│                   API Gateway                        │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│                  RWA Service                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │  Asset API  │  │Offering API │  │Dividend API │  │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  │
│         │                │                │          │
│  ┌──────▼────────────────▼────────────────▼──────┐  │
│  │              Domain Service                    │  │
│  │  - AssetOnboardingService                     │  │
│  │  - TokenizationService                        │  │
│  │  - OfferingService                            │  │
│  │  - DividendService                            │  │
│  └──────────────────────┬────────────────────────┘  │
│                         │                           │
│  ┌──────────────────────▼────────────────────────┐  │
│  │            Infrastructure Layer               │  │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ │  │
│  │  │  DB    │ │ Redis  │ │  MQ    │ │ Web3   │ │  │
│  │  └────────┘ └────────┘ └────────┘ └────────┘ │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
           │              │              │
           ▼              ▼              ▼
    ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
    │ Compliance  │ │  Custody    │ │  External   │
    │  Service    │ │  Service    │ │  Valuator   │
    └─────────────┘ └─────────────┘ └─────────────┘
```

## 核心领域模型

### 聚合根

```java
// RealWorldAsset - 现实资产
public class RealWorldAsset {
    private AssetId id;
    private String name;
    private RWAType type;           // REAL_ESTATE, FIXED_INCOME, EQUITY, COMMODITY
    private LegalEntity legalEntity; // 法律主体(SPV)
    private CustodyInfo custody;     // 托管信息
    private Valuation currentValuation;
    private AssetStatus status;
}

// AssetToken - 资产代币
public class AssetToken {
    private TokenId id;
    private AssetId assetId;
    private String symbol;
    private TokenStandard standard;  // ERC20, ERC1400, ERC3643
    private Address contractAddress;
    private Long totalSupply;
    private TokenStatus status;
}

// InvestorHolding - 投资者持仓
public class InvestorHolding {
    private HoldingId id;
    private InvestorId investorId;
    private TokenId tokenId;
    private Long shares;
    private AccreditationStatus accreditation;
}
```

### 关键实体

```java
// AssetOffering - 资产发行
public class AssetOffering {
    private OfferingId id;
    private AssetId assetId;
    private OfferingType type;       // STO, PRIVATE_PLACEMENT, REG_D, REG_S
    private Money targetAmount;
    private Money raisedAmount;
    private DateRange offeringPeriod;
    private OfferingStatus status;
}

// Subscription - 认购申请
public class Subscription {
    private SubscriptionId id;
    private OfferingId offeringId;
    private InvestorId investorId;
    private Long requestedShares;
    private Long allocatedShares;
    private SubscriptionStatus status;
}

// DividendDistribution - 分红分配
public class DividendDistribution {
    private DistributionId id;
    private AssetId assetId;
    private Money totalAmount;
    private LocalDate recordDate;     // 登记日
    private LocalDate paymentDate;    // 支付日
    private DistributionStatus status;
}

// Valuation - 估值记录
public class Valuation {
    private ValuationId id;
    private AssetId assetId;
    private Money valuedAmount;
    private String valuator;          // 评估机构
    private LocalDate valuationDate;
    private LocalDate expiryDate;     // 有效期(最长90天)
}
```

## 关键业务流程

### 资产代币化流程

```
1. 发行方提交资产入驻申请(资产信息、法律文件)
2. 平台进行初步审核
3. 请求外部估值机构进行资产估值
4. 调用Compliance服务进行法律合规审核
5. 创建SPV(特殊目的载体)
6. 部署代币合约(选择合适的代币标准)
7. 资产状态变更为"已代币化"
8. 发布TokenCreated事件
```

### 投资流程

```
1. 投资者提交认购申请(发行ID、认购金额)
2. 验证投资者合格投资者资格
3. 检查是否在白名单中
4. 冻结认购资金(稳定币)
5. 发行期结束后进行份额分配
6. 调用合约铸造代币给投资者
7. 发布OfferingSettled事件
```

### 分红流程

```
1. 资产管理方宣布分红(总金额、登记日)
2. 快照登记日持仓情况
3. 按持仓比例计算各投资者应得金额
4. 扣除税费(如适用)
5. 分发稳定币到投资者钱包
6. 发布DividendPaid事件
```

## 外部依赖

| 服务 | 用途 | 接口 |
|------|------|------|
| Compliance Service | 投资者认证/法律审核 | gRPC |
| Custody Service | 资产托管/密钥管理 | gRPC |
| Stablecoin Service | 支付结算 | gRPC |
| 外部估值机构 | 资产估值 | REST |
| 法律服务商 | SPV创建 | REST |

## 发布的领域事件

| 事件 | 触发条件 | 消费者 |
|------|----------|--------|
| AssetOnboarded | 资产入驻完成 | 审计服务 |
| TokenCreated | 代币创建成功 | 市场服务, 钱包服务 |
| OfferingCreated | 发行创建 | 市场服务, 通知服务 |
| OfferingSettled | 发行结算完成 | 代币分发, 统计服务 |
| DividendDeclared | 宣布分红 | 账户服务, 通知服务 |
| DividendPaid | 分红支付完成 | 税务服务, 通知服务 |
| ValuationCompleted | 估值完成 | 代币服务, 风控服务 |
| WhitelistUpdated | 白名单更新 | 合规服务 |

## 配置说明

```yaml
# application.yml 关键配置
rwa:
  asset-types:
    - type: REAL_ESTATE
      token-standard: ERC1400
      min-investment: 10000
    - type: FIXED_INCOME
      token-standard: ERC3643
      min-investment: 1000
    - type: EQUITY
      token-standard: ERC1400
      min-investment: 5000

  valuation:
    max-validity-days: 90    # 估值最长有效期
    revaluation-threshold: 0.1  # 10%价值变动触发重估

  offering:
    min-subscription: 1000   # 最低认购金额
    kyc-required: true
    accreditation-required: true

  dividend:
    min-distribution: 100    # 最低分红金额
    withholding-tax-rate: 0.15  # 预扣税率
```

## 白名单管理

RWA代币转让受限，仅白名单地址可持有和交易：

```java
// 白名单检查
public boolean canTransfer(Address from, Address to) {
    return whitelist.contains(from)
        && whitelist.contains(to)
        && !isBlacklisted(from)
        && !isBlacklisted(to);
}
```

## 已知问题和待办

- [ ] 支持二级市场交易
- [ ] 实现自动分红调度
- [ ] 添加资产组合支持
- [ ] 支持跨链资产映射

## 近期变更

### 2024-01-12
- 新增REG_S发行类型支持
- 优化白名单批量导入

### 2024-01-08
- 接入新的估值服务商API
- 修复分红计算精度问题

### 2024-01-03
- 升级ERC3643合约到最新版本
- 添加投资者持仓历史查询
