# 托管钱包领域模型 (Custody Wallet Domain Model)

**限界上下文**: Custody Context
**上下文所有者**: 托管安全团队
**版本**: 1.0
**最后更新**: 2025-11-30

---

## 领域概述

托管钱包领域负责数字资产的安全保管、多签管理、密钥托管和交易签名。本领域是整个Web3金融平台的安全基石，为所有资产操作提供底层安全保障。

<!-- AI-CONTEXT
托管钱包领域核心职责：
1. 数字资产安全托管
2. 多签钱包管理
3. 密钥安全存储与使用
4. 交易签名与广播
5. 资产隔离与权限控制
关键约束：私钥永不离开安全边界，所有操作需审计追踪
-->

---

## 核心概念 (Ubiquitous Language)

### 聚合根 (Aggregate Roots)

#### Vault (保险库)
```yaml
定义: 最高级别的资产隔离单元，包含多个钱包
属性:
  - vaultId: UUID
  - name: String
  - vaultType: VaultType # 保险库类型
  - ownerId: UUID # 所有者 (机构/用户)
  - ownerType: OwnerType
  - securityLevel: SecurityLevel
  - wallets: List<Wallet>
  - policies: List<Policy> # 安全策略
  - signers: List<Signer> # 授权签名人
  - threshold: ThresholdConfig # 多签阈值配置
  - status: VaultStatus
  - totalAssetValue: BigDecimal # 总资产价值 (USD)
  - createdAt: Timestamp
  - updatedAt: Timestamp

不变式:
  - 至少有一个激活的签名人
  - threshold.required <= signers.count
  - 安全策略不能为空
```

#### Wallet (钱包)
```yaml
定义: 特定链上的资产账户
属性:
  - walletId: UUID
  - vaultId: UUID
  - chainId: Integer
  - chainName: String
  - address: Address # 链上地址
  - walletType: WalletType
  - derivationPath: String # HD派生路径
  - keyId: UUID # 关联的密钥ID
  - balance: Map<String, BigDecimal> # 资产余额
  - nonce: BigInteger # 交易计数
  - status: WalletStatus
  - label: String # 用户标签
  - createdAt: Timestamp

不变式:
  - 地址在链上唯一
  - 同一Vault内地址不重复
```

#### Key (密钥)
```yaml
定义: 加密密钥单元
属性:
  - keyId: UUID
  - keyType: KeyType # ECDSA, EdDSA等
  - curve: Curve # secp256k1, ed25519等
  - publicKey: String # 公钥 (可展示)
  - encryptedPrivateKey: EncryptedData # 加密存储的私钥
  - storageType: StorageType # HSM, MPC, Software
  - hsmSlotId: String # HSM槽位 (如适用)
  - mpcKeyShares: List<KeyShare> # MPC密钥分片 (如适用)
  - status: KeyStatus
  - createdAt: Timestamp
  - lastUsedAt: Timestamp
  - expiresAt: Timestamp # 密钥过期时间

不变式:
  - 私钥加密存储
  - MPC密钥分片数量满足阈值要求
```

### 实体 (Entities)

#### Signer (签名人)
```yaml
定义: 授权进行交易签名的用户
属性:
  - signerId: UUID
  - vaultId: UUID
  - userId: UUID
  - role: SignerRole
  - weight: Integer # 签名权重
  - status: SignerStatus
  - mfaEnabled: Boolean
  - mfaType: MfaType
  - lastActiveAt: Timestamp
  - addedAt: Timestamp
  - addedBy: UUID
```

#### TransactionRequest (交易请求)
```yaml
定义: 待签名和广播的交易
属性:
  - txRequestId: UUID
  - vaultId: UUID
  - walletId: UUID
  - txType: TransactionType
  - destination: Address
  - amount: BigDecimal
  - asset: String # 资产标识
  - gasLimit: BigInteger
  - gasPrice: BigInteger
  - data: String # 合约调用数据
  - initiatorId: UUID # 发起人
  - requiredSignatures: Integer
  - collectedSignatures: List<Signature>
  - status: TxRequestStatus
  - rawTransaction: String # 原始交易数据
  - txHash: String # 链上交易哈希
  - broadcastAt: Timestamp
  - confirmedAt: Timestamp
  - createdAt: Timestamp
  - expiresAt: Timestamp

生命周期:
  PENDING → SIGNING → SIGNED → BROADCASTING → CONFIRMED
          → REJECTED | EXPIRED | FAILED
```

#### Policy (安全策略)
```yaml
定义: 钱包操作的安全规则
属性:
  - policyId: UUID
  - vaultId: UUID
  - policyType: PolicyType
  - name: String
  - conditions: List<Condition> # 触发条件
  - actions: List<PolicyAction> # 策略动作
  - priority: Integer
  - status: PolicyStatus
  - createdAt: Timestamp
  - createdBy: UUID
```

### 值对象 (Value Objects)

```yaml
VaultType:
  枚举值:
    - INSTITUTIONAL # 机构保险库
    - RETAIL # 零售用户保险库
    - TREASURY # 资金库
    - RESERVE # 储备金库
    - HOT # 热钱包库
    - COLD # 冷钱包库

SecurityLevel:
  枚举值:
    - STANDARD # 标准安全
    - HIGH # 高安全
    - CRITICAL # 最高安全

WalletType:
  枚举值:
    - HOT # 热钱包 (联网)
    - WARM # 温钱包 (受限联网)
    - COLD # 冷钱包 (离线)
    - MPC # MPC钱包
    - MULTISIG # 多签钱包

KeyType:
  枚举值:
    - ECDSA
    - EDDSA
    - SCHNORR

StorageType:
  枚举值:
    - HSM # 硬件安全模块
    - MPC # 多方计算
    - SOFTWARE # 软件加密
    - HYBRID # 混合模式

ThresholdConfig:
  required: Integer # 所需签名数
  total: Integer # 总签名人数
  timelock: Duration # 时间锁

SignerRole:
  枚举值:
    - ADMIN # 管理员
    - OPERATOR # 操作员
    - VIEWER # 只读
    - SIGNER # 签名人

PolicyType:
  枚举值:
    - WHITELIST # 白名单
    - SPENDING_LIMIT # 支出限额
    - TIME_LOCK # 时间锁
    - VELOCITY # 速率限制
    - GEO_RESTRICTION # 地域限制
    - APPROVAL_WORKFLOW # 审批流程

TransactionType:
  枚举值:
    - TRANSFER # 转账
    - CONTRACT_CALL # 合约调用
    - CONTRACT_DEPLOY # 合约部署
    - APPROVAL # 授权
    - SWAP # 交换
    - STAKE # 质押
    - UNSTAKE # 解质押

TxRequestStatus:
  枚举值:
    - PENDING
    - SIGNING
    - SIGNED
    - BROADCASTING
    - CONFIRMED
    - REJECTED
    - EXPIRED
    - FAILED

EncryptedData:
  ciphertext: String
  algorithm: String
  keyId: String # 加密密钥ID
  iv: String # 初始化向量
```

---

## 领域服务 (Domain Services)

### VaultManagementService
```yaml
职责: 保险库生命周期管理
方法:
  - createVault(owner, vaultType, securityLevel): Vault
  - addSigner(vaultId, userId, role): Signer
  - removeSigner(vaultId, signerId): Result
  - updateThreshold(vaultId, newThreshold): Vault
  - activateVault(vaultId): Vault
  - freezeVault(vaultId, reason): Vault

规则:
  - 创建保险库需要KYC验证
  - 移除签名人不能低于阈值要求
  - 冻结保险库需要多签审批
```

### WalletService
```yaml
职责: 钱包管理
方法:
  - createWallet(vaultId, chainId, walletType): Wallet
  - deriveAddress(vaultId, chainId, index): Address
  - getBalance(walletId): Map<String, BigDecimal>
  - refreshBalance(walletId): Balance
  - labelWallet(walletId, label): Wallet

规则:
  - 钱包创建需保险库授权
  - 地址派生遵循BIP-44标准
  - 定期同步链上余额
```

### KeyManagementService
```yaml
职责: 密钥安全管理
方法:
  - generateKey(keyType, curve, storageType): Key
  - rotateKey(keyId): Key
  - backupKey(keyId): BackupResult
  - recoverKey(backupData): Key
  - destroyKey(keyId): Result

规则:
  - 密钥生成在安全边界内
  - 定期密钥轮换 (每年)
  - 备份需要多方参与
  - 销毁需要审批
```

### TransactionService
```yaml
职责: 交易处理
方法:
  - createTransaction(walletId, destination, amount, asset): TransactionRequest
  - signTransaction(txRequestId, signerId, signature): TransactionRequest
  - broadcastTransaction(txRequestId): BroadcastResult
  - cancelTransaction(txRequestId, reason): TransactionRequest
  - retryTransaction(txRequestId): TransactionRequest

规则:
  - 交易创建需通过策略检查
  - 签名收集达到阈值后广播
  - 广播失败自动重试 (最多3次)
```

### PolicyService
```yaml
职责: 安全策略管理
方法:
  - createPolicy(vaultId, policyType, conditions): Policy
  - evaluatePolicy(vaultId, transaction): PolicyResult
  - updatePolicy(policyId, changes): Policy
  - disablePolicy(policyId): Policy

策略示例:
  - 单笔限额: amount <= 10000 USD
  - 日限额: daily_total <= 100000 USD
  - 白名单: destination IN whitelist
  - 时间锁: wait 24h for amount > 50000 USD
```

---

## 领域事件 (Domain Events)

```yaml
VaultCreated:
  触发: 保险库创建
  载荷: vaultId, ownerId, vaultType, securityLevel
  订阅者: 审计服务, 合规服务

SignerAdded:
  触发: 签名人添加
  载荷: vaultId, signerId, role, addedBy
  订阅者: 审计服务, 通知服务

WalletCreated:
  触发: 钱包创建
  载荷: walletId, vaultId, chainId, address
  订阅者: 余额监控, 地址索引服务

TransactionCreated:
  触发: 交易请求创建
  载荷: txRequestId, vaultId, walletId, destination, amount
  订阅者: 策略引擎, 通知服务, 风控服务

SignatureCollected:
  触发: 签名收集
  载荷: txRequestId, signerId, signatureIndex, totalRequired
  订阅者: 交易服务, 通知服务

TransactionBroadcasted:
  触发: 交易广播
  载荷: txRequestId, txHash, chainId
  订阅者: 交易追踪服务, 统计服务

TransactionConfirmed:
  触发: 交易确认
  载荷: txRequestId, txHash, blockNumber, confirmations
  订阅者: 余额服务, 通知服务, 统计服务

TransactionFailed:
  触发: 交易失败
  载荷: txRequestId, reason, txHash
  订阅者: 告警服务, 通知服务

PolicyViolation:
  触发: 策略违规
  载荷: vaultId, txRequestId, policyId, violationType
  订阅者: 风控服务, 告警服务, 审计服务

KeyRotated:
  触发: 密钥轮换
  载荷: oldKeyId, newKeyId, vaultId
  订阅者: 审计服务, 监控服务

VaultFrozen:
  触发: 保险库冻结
  载荷: vaultId, reason, frozenBy
  订阅者: 所有相关服务, 告警服务
```

---

## 上下文映射 (Context Mapping)

```
┌─────────────────────────────────────────────────────────────────┐
│                      Custody Context                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │    Vault     │  │    Wallet    │  │     Key      │          │
│  │  (聚合根)    │  │  (聚合根)    │  │   (聚合根)   │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
          │                    │                    │
          │ Provides           │ Provides           │ Provides
          ▼                    ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│Stablecoin Context│ │Tokenization Ctx │  │  RWA Context    │
│  - 储备托管     │  │  - 代币托管     │  │  - 资产托管     │
│  - 铸币签名     │  │  - 铸币/赎回    │  │  - 权益代币     │
└─────────────────┘  └─────────────────┘  └─────────────────┘
          │                    │                    │
          ▼                    ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ Staking Context │  │ Lending Context │  │ Bridge Context  │
│  - 质押资产     │  │  - 抵押品托管   │  │  - 跨链资产     │
│  - 奖励分发     │  │  - 清算执行     │  │  - 桥接签名     │
└─────────────────┘  └─────────────────┘  └─────────────────┘
                               │
                               ▼
                    ┌─────────────────┐
                    │Compliance Context│
                    │  - 交易审计     │
                    │  - 冻结执行     │
                    └─────────────────┘

集成模式:
- Custody是核心供应商 (Supplier)
- 其他领域是客户 (Customer)
- Compliance有特殊权限 (Conformist - 可执行冻结)
```

---

## 接口契约摘要

### 对外提供的API

```yaml
# 保险库管理
POST /api/v1/vaults
  - 创建保险库
  - 需要机构认证

GET /api/v1/vaults/{vaultId}
  - 获取保险库详情

POST /api/v1/vaults/{vaultId}/signers
  - 添加签名人

# 钱包管理
POST /api/v1/vaults/{vaultId}/wallets
  - 创建钱包

GET /api/v1/wallets/{walletId}/balance
  - 查询余额

# 交易管理
POST /api/v1/wallets/{walletId}/transactions
  - 创建交易请求

POST /api/v1/transactions/{txId}/sign
  - 提交签名

GET /api/v1/transactions/{txId}
  - 查询交易状态

# 内部服务接口
POST /internal/v1/custody/sign
  - 内部签名请求
  - 供稳定币/代币化服务调用

POST /internal/v1/custody/freeze
  - 冻结账户
  - 仅合规服务可调用

GET /internal/v1/custody/audit-log
  - 获取审计日志
  - 供审计服务调用
```

---

## 安全架构

### 密钥保护层级

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

### MPC架构示例

```yaml
MPC配置:
  threshold: 2/3 # 2-of-3签名
  participants:
    - party_1: 客户端分片
    - party_2: 服务端分片
    - party_3: 备份分片 (离线)

签名流程:
  1. 交易发起 → 客户端分片参与
  2. 策略通过 → 服务端分片参与
  3. MPC协议 → 生成签名
  4. 广播交易 → 无完整私钥暴露
```

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| 1.0 | 2025-11-30 | 初始版本 | @领域架构师 |
