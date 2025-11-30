# Custody Service 上下文

> 最后更新: 2024-01-15
> 此文件由开发者维护，定期聚合到项目知识库

## 仓库概述

托管服务是Web3金融平台的安全基石，负责数字资产的安全保管、多签管理、密钥托管和交易签名。

## 架构概览

```
┌─────────────────────────────────────────────────────┐
│                  Custody Service                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │  Vault API  │  │ Wallet API  │  │   Tx API    │  │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  │
│         │                │                │          │
│  ┌──────▼────────────────▼────────────────▼──────┐  │
│  │              Domain Services                   │  │
│  │  - VaultManagementService                     │  │
│  │  - WalletService                              │  │
│  │  - KeyManagementService                       │  │
│  │  - TransactionService                         │  │
│  │  - PolicyService                              │  │
│  └──────────────────────┬────────────────────────┘  │
│                         │                           │
│  ┌──────────────────────▼────────────────────────┐  │
│  │              Secure Enclave                    │  │
│  │  ┌────────┐ ┌────────┐ ┌────────┐            │  │
│  │  │  HSM   │ │  MPC   │ │ Policy │            │  │
│  │  │ Module │ │ Module │ │ Engine │            │  │
│  │  └────────┘ └────────┘ └────────┘            │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
           │
           ▼
    ┌─────────────────────────────────────────────────┐
    │              All Business Services              │
    │  Stablecoin | RWA | Lending | Staking | Bridge │
    └─────────────────────────────────────────────────┘
```

## 核心领域模型

### 聚合根

```java
// Vault - 保险库
public class Vault {
    private VaultId id;
    private VaultType type;          // INSTITUTIONAL, RETAIL, TREASURY
    private SecurityLevel securityLevel;
    private List<Wallet> wallets;
    private List<Signer> signers;
    private ThresholdConfig threshold; // 2-of-3等
    private List<Policy> policies;
}

// Wallet - 钱包
public class Wallet {
    private WalletId id;
    private VaultId vaultId;
    private Integer chainId;
    private Address address;
    private WalletType type;         // HOT, WARM, COLD, MPC
    private Map<String, BigDecimal> balance;
}

// Key - 密钥
public class Key {
    private KeyId id;
    private KeyType type;            // ECDSA, EdDSA
    private StorageType storageType; // HSM, MPC, SOFTWARE
    private EncryptedData encryptedPrivateKey;
    private KeyStatus status;
}
```

### 安全策略类型

| 策略类型 | 说明 | 示例 |
|----------|------|------|
| WHITELIST | 白名单 | 只能转到已知地址 |
| SPENDING_LIMIT | 支出限额 | 单笔≤$10,000 |
| TIME_LOCK | 时间锁 | 大额等待24小时 |
| VELOCITY | 速率限制 | 日限额$100,000 |
| APPROVAL_WORKFLOW | 审批流程 | 2-of-3多签 |

## 密钥保护层级

```
┌────────────────────────────────────────┐
│          Application Layer             │
│  (交易请求、签名收集)                  │
├────────────────────────────────────────┤
│          Policy Engine                 │
│  (策略评估、审批流程)                  │
├────────────────────────────────────────┤
│          Key Management                │
│  (密钥访问控制、使用授权)              │
├────────────────────────────────────────┤
│          Secure Enclave                │
│  (HSM/MPC签名、密钥存储)               │
└────────────────────────────────────────┘
```

## MPC架构

```yaml
MPC配置:
  threshold: 2/3              # 2-of-3签名
  participants:
    - party_1: 客户端分片
    - party_2: 服务端分片
    - party_3: 备份分片(离线)

签名流程:
  1. 交易发起 → 客户端分片参与
  2. 策略通过 → 服务端分片参与
  3. MPC协议 → 生成签名
  4. 广播交易 → 无完整私钥暴露
```

## 发布的领域事件

| 事件 | 触发条件 | 消费者 |
|------|----------|--------|
| VaultCreated | 保险库创建 | 审计服务 |
| WalletCreated | 钱包创建 | 余额监控 |
| TransactionCreated | 交易请求创建 | 策略引擎 |
| SignatureCollected | 签名收集 | 交易服务 |
| TransactionConfirmed | 交易确认 | 余额服务 |
| PolicyViolation | 策略违规 | 风控服务, 告警 |
| VaultFrozen | 保险库冻结 | 所有相关服务 |

## 接口说明

托管服务是核心供应商，为所有业务服务提供：
- 资产托管能力
- 交易签名能力
- 安全策略执行

合规服务拥有特殊权限可执行账户冻结。

## 已知问题和待办

- [ ] 支持更多链(Solana, Cosmos)
- [ ] 实现密钥自动轮换
- [ ] 添加硬件钱包集成

## 近期变更

### 2024-01-10
- 升级HSM固件
- 优化MPC签名性能

### 2024-01-05
- 新增时间锁策略
- 修复多签审批超时问题
