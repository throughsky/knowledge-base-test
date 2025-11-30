# 稳定币领域模型 (Stablecoin Domain Model)

**限界上下文**: Stablecoin Context
**上下文所有者**: 稳定币团队
**版本**: 1.0
**最后更新**: 2025-11-30

---

## 领域概述

稳定币领域负责管理与法币或其他资产锚定的数字货币的发行、流通、赎回和储备管理。本领域是整个Web3金融服务平台的核心基础设施，为其他领域（如Lending、Staking、RWA）提供稳定的价值媒介。

<!-- AI-CONTEXT
稳定币领域核心职责：
1. 稳定币铸造与销毁
2. 储备金管理与审计
3. 锚定机制维护
4. 跨链桥接支持
关键约束：储备率必须≥100%，所有操作需合规审计
-->

---

## 核心概念 (Ubiquitous Language)

### 聚合根 (Aggregate Roots)

#### Stablecoin (稳定币)
```yaml
定义: 与法币或资产锚定的数字代币
属性:
  - stablecoinId: UUID # 稳定币唯一标识
  - symbol: String # 代币符号 (如 USDC, USDT)
  - name: String # 代币名称
  - decimals: Integer # 精度 (通常为6或18)
  - totalSupply: BigDecimal # 总发行量
  - pegType: PegType # 锚定类型
  - pegAsset: String # 锚定资产 (如 USD, EUR)
  - contractAddress: Address # 智能合约地址
  - chainId: Integer # 链ID
  - status: StablecoinStatus # 状态
  - reserveRatio: BigDecimal # 储备率
  - createdAt: Timestamp
  - updatedAt: Timestamp

不变式:
  - reserveRatio >= 1.0 # 储备率必须≥100%
  - totalSupply >= 0
  - status变更需经过合规审批
```

#### Reserve (储备金)
```yaml
定义: 支撑稳定币价值的底层资产池
属性:
  - reserveId: UUID
  - stablecoinId: UUID # 关联的稳定币
  - assetType: ReserveAssetType # 资产类型
  - totalValue: BigDecimal # 总价值 (USD计价)
  - lastAuditTime: Timestamp # 最后审计时间
  - auditorId: String # 审计机构ID
  - proofOfReserve: String # 储备证明链接
  - assets: List<ReserveAsset> # 资产明细

不变式:
  - totalValue >= 关联稳定币的totalSupply
  - 审计间隔不超过30天
```

### 实体 (Entities)

#### MintRequest (铸币请求)
```yaml
定义: 稳定币铸造申请
属性:
  - requestId: UUID
  - stablecoinId: UUID
  - requesterId: UUID # 请求方
  - amount: BigDecimal # 铸造数量
  - collateralType: CollateralType # 抵押类型
  - collateralAmount: BigDecimal # 抵押金额
  - collateralTxHash: String # 抵押交易哈希
  - status: MintStatus
  - mintTxHash: String # 铸造交易哈希
  - createdAt: Timestamp
  - processedAt: Timestamp
  - expiresAt: Timestamp

生命周期: PENDING → COLLATERAL_VERIFIED → APPROVED → MINTED | REJECTED | EXPIRED
```

#### RedemptionRequest (赎回请求)
```yaml
定义: 稳定币赎回申请
属性:
  - requestId: UUID
  - stablecoinId: UUID
  - requesterId: UUID
  - amount: BigDecimal # 赎回数量
  - burnTxHash: String # 销毁交易哈希
  - redemptionType: RedemptionType # 赎回类型 (法币/加密资产)
  - destinationAccount: String # 目标账户
  - status: RedemptionStatus
  - feeAmount: BigDecimal # 手续费
  - settledAmount: BigDecimal # 实际到账金额
  - createdAt: Timestamp
  - settledAt: Timestamp

生命周期: PENDING → BURN_CONFIRMED → PROCESSING → SETTLED | REJECTED
```

#### ReserveAsset (储备资产)
```yaml
定义: 单项储备资产
属性:
  - assetId: UUID
  - reserveId: UUID
  - assetType: ReserveAssetType
  - assetName: String
  - quantity: BigDecimal
  - unitPrice: BigDecimal
  - totalValue: BigDecimal
  - custodian: String # 托管方
  - lastValuationTime: Timestamp
```

### 值对象 (Value Objects)

```yaml
PegType:
  枚举值:
    - FIAT_BACKED # 法币支撑
    - CRYPTO_BACKED # 加密资产支撑
    - ALGORITHMIC # 算法稳定
    - HYBRID # 混合模式

StablecoinStatus:
  枚举值:
    - ACTIVE # 活跃
    - PAUSED # 暂停
    - DEPRECATED # 已废弃

ReserveAssetType:
  枚举值:
    - CASH # 现金
    - BANK_DEPOSIT # 银行存款
    - TREASURY_BILL # 国债
    - MONEY_MARKET_FUND # 货币基金
    - CORPORATE_BOND # 公司债券
    - CRYPTO_ASSET # 加密资产

MintStatus:
  枚举值:
    - PENDING
    - COLLATERAL_VERIFIED
    - APPROVED
    - MINTED
    - REJECTED
    - EXPIRED

RedemptionStatus:
  枚举值:
    - PENDING
    - BURN_CONFIRMED
    - PROCESSING
    - SETTLED
    - REJECTED

CollateralType:
  枚举值:
    - FIAT_WIRE # 法币电汇
    - CRYPTO # 加密资产抵押
    - CREDIT_LINE # 信用额度
```

---

## 领域服务 (Domain Services)

### StablecoinMintingService
```yaml
职责: 处理稳定币铸造逻辑
方法:
  - createMintRequest(stablecoinId, amount, collateral): MintRequest
  - verifyCollateral(requestId): Boolean
  - approveMint(requestId, approverId): MintRequest
  - executeMint(requestId): TransactionResult
  - rejectMint(requestId, reason): MintRequest

规则:
  - 抵押金额必须覆盖铸造金额 + 手续费
  - 铸造前必须通过AML检查
  - 大额铸造需要多签审批
```

### StablecoinRedemptionService
```yaml
职责: 处理稳定币赎回逻辑
方法:
  - createRedemptionRequest(stablecoinId, amount, destination): RedemptionRequest
  - confirmBurn(requestId, txHash): RedemptionRequest
  - processRedemption(requestId): RedemptionRequest
  - settleRedemption(requestId): RedemptionResult

规则:
  - 赎回前稳定币必须已销毁
  - 赎回金额需扣除手续费
  - 法币赎回需经过合规审查
```

### ReserveManagementService
```yaml
职责: 储备金管理
方法:
  - allocateReserve(reserveId, assetAllocation): Reserve
  - rebalanceReserve(reserveId): RebalanceResult
  - calculateReserveRatio(stablecoinId): BigDecimal
  - triggerAudit(reserveId): AuditRequest
  - publishProofOfReserve(reserveId): ProofOfReserve

规则:
  - 储备率低于105%触发预警
  - 储备率低于100%触发紧急处理
  - 每日自动计算并发布储备率
```

### PegMaintenanceService
```yaml
职责: 维护价格锚定
方法:
  - monitorPegDeviation(stablecoinId): PegStatus
  - triggerStabilization(stablecoinId, direction): StabilizationAction
  - adjustMintFee(stablecoinId, newFee): FeeAdjustment
  - adjustRedemptionFee(stablecoinId, newFee): FeeAdjustment

规则:
  - 价格偏离超过0.5%触发预警
  - 价格偏离超过1%触发自动稳定机制
  - 价格偏离超过2%触发紧急干预
```

---

## 领域事件 (Domain Events)

```yaml
StablecoinCreated:
  触发: 新稳定币创建
  载荷: stablecoinId, symbol, pegType, pegAsset, contractAddress
  订阅者: 合规服务, 监控服务

MintRequestCreated:
  触发: 铸币请求提交
  载荷: requestId, stablecoinId, amount, requesterId
  订阅者: 合规服务, 风控服务

MintCompleted:
  触发: 铸币完成
  载荷: requestId, stablecoinId, amount, txHash, newTotalSupply
  订阅者: 储备服务, 统计服务, 通知服务

RedemptionRequested:
  触发: 赎回请求提交
  载荷: requestId, stablecoinId, amount, requesterId
  订阅者: 合规服务, 风控服务

RedemptionSettled:
  触发: 赎回完成
  载荷: requestId, settledAmount, settlementMethod
  订阅者: 储备服务, 统计服务, 通知服务

ReserveRatioChanged:
  触发: 储备率变化
  载荷: stablecoinId, oldRatio, newRatio, timestamp
  订阅者: 风控服务, 监控服务

PegDeviationDetected:
  触发: 价格偏离检测
  载荷: stablecoinId, deviation, direction, timestamp
  订阅者: 稳定机制服务, 告警服务

ProofOfReservePublished:
  触发: 储备证明发布
  载荷: reserveId, proofHash, totalValue, timestamp
  订阅者: 合规服务, 公告服务
```

---

## 上下文映射 (Context Mapping)

```
┌─────────────────────────────────────────────────────────────────┐
│                     Stablecoin Context                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Stablecoin  │  │   Reserve    │  │ MintRequest  │          │
│  │  (聚合根)    │  │  (聚合根)    │  │   (实体)     │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
          │                    │                    │
          │ U/D                │ U/D                │ U/D
          ▼                    ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ Custody Context │  │Compliance Context│ │  Bridge Context │
│  (托管钱包)     │  │   (AML/风控)     │  │  (跨链桥接)    │
│  - 资产托管     │  │  - 交易审查      │  │  - 跨链转移    │
│  - 多签管理     │  │  - 身份验证      │  │  - 流动性管理  │
└─────────────────┘  └─────────────────┘  └─────────────────┘
          │                                         │
          │ U/D                                     │ U/D
          ▼                                         ▼
┌─────────────────┐                      ┌─────────────────┐
│ Lending Context │                      │ Staking Context │
│   (借贷协议)    │                      │   (质押服务)   │
│  - 抵押借贷     │                      │  - 质押挖矿    │
│  - 利率模型     │                      │  - 收益分发    │
└─────────────────┘                      └─────────────────┘

U/D = Upstream/Downstream (上游/下游)
```

### 关系说明

| 上游上下文 | 下游上下文 | 关系类型 | 说明 |
|-----------|-----------|---------|------|
| Stablecoin | Custody | Customer-Supplier | 稳定币依赖托管服务管理储备 |
| Stablecoin | Compliance | Conformist | 稳定币必须遵守合规服务规则 |
| Stablecoin | Bridge | Partnership | 双向协作支持跨链 |
| Stablecoin | Lending | Customer-Supplier | 借贷协议使用稳定币作为计价单位 |
| Stablecoin | Staking | Customer-Supplier | 质押服务使用稳定币作为奖励 |

---

## 接口契约摘要

### 对外提供的API

```yaml
# 铸币相关
POST /api/v1/stablecoins/{id}/mint
  - 创建铸币请求
  - 需要KYC验证
  - 需要抵押证明

POST /api/v1/stablecoins/{id}/redeem
  - 创建赎回请求
  - 需要持币证明

GET /api/v1/stablecoins/{id}/reserve
  - 获取储备信息
  - 公开接口

GET /api/v1/stablecoins/{id}/proof-of-reserve
  - 获取储备证明
  - 公开接口

# 内部服务接口
GET /internal/v1/stablecoins/{id}/supply
  - 获取当前供应量
  - 供内部服务调用

POST /internal/v1/stablecoins/{id}/freeze
  - 冻结稳定币 (合规需求)
  - 仅合规服务可调用
```

### 依赖的外部服务

```yaml
Custody Service:
  - 托管账户管理
  - 资产转移执行

Compliance Service:
  - KYC/AML验证
  - 交易监控

Bridge Service:
  - 跨链铸造
  - 跨链销毁

Oracle Service:
  - 资产价格获取
  - 汇率查询
```

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| 1.0 | 2025-11-30 | 初始版本 | @领域架构师 |
