# Stablecoin Service 上下文

> 最后更新: 2024-01-15
> 此文件由开发者维护，定期聚合到项目知识库

## 仓库概述

稳定币服务是Web3金融平台的核心服务之一，负责法币锚定稳定币的全生命周期管理。

## 架构概览

```
┌─────────────────────────────────────────────────────┐
│                   API Gateway                        │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│              Stablecoin Service                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │  Mint API   │  │ Redeem API  │  │ Reserve API │  │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  │
│         │                │                │          │
│  ┌──────▼────────────────▼────────────────▼──────┐  │
│  │              Domain Service                    │  │
│  │  - MintService                                │  │
│  │  - RedemptionService                          │  │
│  │  - ReserveService                             │  │
│  └──────────────────────┬────────────────────────┘  │
│                         │                           │
│  ┌──────────────────────▼────────────────────────┐  │
│  │            Infrastructure Layer               │  │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ │  │
│  │  │  DB    │ │ Redis  │ │  MQ    │ │ Web3   │ │  │
│  │  └────────┘ └────────┘ └────────┘ └────────┘ │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
           │                              │
           ▼                              ▼
    ┌─────────────┐                ┌─────────────┐
    │ Compliance  │                │  Custody    │
    │  Service    │                │  Service    │
    └─────────────┘                └─────────────┘
```

## 核心领域模型

### 聚合根

```java
// Stablecoin - 稳定币配置
public class Stablecoin {
    private StablecoinId id;
    private String symbol;          // e.g., "USDC", "USDT"
    private Currency pegCurrency;   // 锚定法币
    private Address contractAddress;
    private StablecoinStatus status;
    private ReservePolicy reservePolicy;
}

// Reserve - 储备金
public class Reserve {
    private ReserveId id;
    private StablecoinId stablecoinId;
    private Money totalReserve;      // 总储备
    private Money totalCirculating;  // 流通量
    private Ratio reserveRatio;      // 储备率
}
```

### 关键实体

```java
// MintRequest - 铸造请求
public class MintRequest {
    private MintRequestId id;
    private UserId userId;
    private StablecoinId stablecoinId;
    private Money amount;
    private MintStatus status;
    private ComplianceResult complianceResult;
    private TransactionHash txHash;
}

// RedemptionRequest - 赎回请求
public class RedemptionRequest {
    private RedemptionRequestId id;
    private UserId userId;
    private Money amount;
    private BankAccount targetAccount;
    private RedemptionStatus status;
}
```

## 关键业务流程

### 铸造流程

```
1. 用户提交铸造请求(金额、钱包地址)
2. 调用Compliance服务进行AML检查
3. 验证用户已完成KYC
4. 确认法币到账(对接银行/支付)
5. 调用智能合约铸造代币
6. 更新储备金记录
7. 发布MintCompleted事件
```

### 赎回流程

```
1. 用户提交赎回请求(代币数量、银行账户)
2. 验证用户持有足够代币
3. 冻结用户代币
4. 调用智能合约销毁代币
5. 发起法币转账
6. 更新储备金记录
7. 发布RedemptionCompleted事件
```

## 外部依赖

| 服务 | 用途 | 接口 |
|------|------|------|
| Compliance Service | AML/KYC检查 | gRPC |
| Custody Service | 密钥托管/签名 | gRPC |
| 银行网关 | 法币进出 | REST |
| Ethereum节点 | 链上交互 | JSON-RPC |

## 发布的领域事件

| 事件 | 触发条件 | 消费者 |
|------|----------|--------|
| MintRequested | 铸造请求创建 | 审计服务 |
| MintCompleted | 铸造成功 | 储备服务, 统计服务 |
| MintFailed | 铸造失败 | 通知服务 |
| RedemptionRequested | 赎回请求创建 | 审计服务 |
| RedemptionCompleted | 赎回成功 | 储备服务, 统计服务 |
| ReserveRatioAlert | 储备率异常 | 风控服务, 运维 |

## 配置说明

```yaml
# application.yml 关键配置
stablecoin:
  supported:
    - symbol: USDC
      contract: "0x..."
      peg-currency: USD
      min-mint: 100
      max-mint: 1000000

  reserve:
    min-ratio: 1.0        # 最低储备率
    alert-threshold: 1.05 # 预警阈值

  compliance:
    large-amount-threshold: 100000  # 大额交易阈值
    require-manual-review: true
```

## 已知问题和待办

- [ ] 支持多链部署(当前仅Ethereum)
- [ ] 实现储备金自动再平衡
- [ ] 添加实时储备证明(Proof of Reserve)

## 近期变更

### 2024-01-10
- 新增大额交易人工审批流程
- 优化储备率计算逻辑

### 2024-01-05
- 接入新的合规服务v2接口
- 修复赎回超时问题
