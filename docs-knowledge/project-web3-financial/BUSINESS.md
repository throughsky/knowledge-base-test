# 业务知识入口

## 业务领域全景

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           Web3 金融服务平台                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │    用户     │  │   法币桥接   │  │   稳定币    │  │    RWA      │    │
│  │   (User)    │  │  (Bridge)   │  │(Stablecoin) │  │  (资产)     │    │
│  │  身份/认证  │  │  出入金     │  │  铸造/赎回  │  │  代币化     │    │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │
│                                                                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │  存款代币化  │  │    借贷     │  │    质押     │  │    托管     │    │
│  │(Tokenization)│ │  (Lending)  │  │  (Staking)  │  │  (Custody)  │    │
│  │  银行存款   │  │  抵押/清算  │  │  LST/奖励   │  │  密钥/签名  │    │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                        合规 (Compliance)                         │   │
│  │              KYC/AML | 交易监控 | 风险控制 | 监管报告             │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 核心业务领域

### 1. 用户 (User)

平台所有用户的身份、认证、授权管理。

| 项目 | 说明 |
|------|------|
| **核心流程** | 注册 → 激活 → 登录 → 操作 → 登出 |
| **关键能力** | JWT认证、RBAC权限、MFA多因素 |
| **KYC等级** | L0(未验证) → L1(邮箱) → L2(证件) → L3(地址) → L4(视频) |

→ 详见 [business/domain-user.md](./business/domain-user.md)

---

### 2. 法币桥接 (Bridge)

连接传统金融(Web2)与区块链(Web3)的桥梁。

| 项目 | 说明 |
|------|------|
| **核心流程** | 入金: 法币→稳定币 / 出金: 稳定币→法币 |
| **关键约束** | 银行账户需验证、大额需审批、15分钟支付超时 |
| **支付通道** | SWIFT、SEPA、ACH、银行卡 |

→ 详见 [business/domain-bridge.md](./business/domain-bridge.md)

---

### 3. 稳定币 (Stablecoin)

与法币锚定的数字货币，是整个平台的价值媒介。

| 项目 | 说明 |
|------|------|
| **核心流程** | 铸造 → 流通 → 赎回 |
| **关键约束** | 储备率 >= 100%，低于100%暂停铸造 |
| **聚合根** | Stablecoin(配置)、Reserve(储备) |

→ 详见 [business/domain-stablecoin.md](./business/domain-stablecoin.md)

---

### 4. RWA (Real World Assets)

现实资产代币化，连接链下资产与链上金融。

| 项目 | 说明 |
|------|------|
| **核心流程** | 资产入驻 → 估值 → 代币化 → 发行 → 分红 |
| **关键约束** | 合规托管、估值有效期90天、白名单转让 |
| **资产类型** | 房地产、固定收益、股权、大宗商品 |

→ 详见 [business/domain-rwa.md](./business/domain-rwa.md)

---

### 5. 存款代币化 (Tokenization)

将传统银行存款转换为链上可编程代币。

| 项目 | 说明 |
|------|------|
| **核心流程** | 银行存款 → 确认 → 铸币 → 利息分发 → 赎回 |
| **关键约束** | 代币总量 = 托管存款，银行确认后才能铸币 |
| **利息模式** | 单利、日复利、连续复利 |

→ 详见 [business/domain-tokenization.md](./business/domain-tokenization.md)

---

### 6. 借贷 (Lending)

基于抵押的链上借贷协议。

| 项目 | 说明 |
|------|------|
| **核心流程** | 存款 → 启用抵押 → 借款 → 还款/清算 |
| **关键约束** | 健康因子 >= 1，否则可被清算 |
| **利率模型** | 基于利用率的拐点模型(Compound风格) |

→ 详见 [business/domain-lending.md](./business/domain-lending.md)

---

### 7. 质押 (Staking)

代币质押获取被动收益。

| 项目 | 说明 |
|------|------|
| **核心流程** | 质押 → 锁定 → 奖励累积 → 领取/复投 → 解质押 |
| **关键约束** | 锁定期内不可解押、冷却期后可提取 |
| **LST机制** | 流动性质押代币，汇率随奖励增长 |

→ 详见 [business/domain-staking.md](./business/domain-staking.md)

---

### 8. 托管 (Custody)

数字资产安全保管和密钥管理。

| 项目 | 说明 |
|------|------|
| **核心能力** | 资产托管、多签管理、交易签名 |
| **关键约束** | 私钥永不离开安全边界、所有操作可审计 |
| **安全架构** | HSM硬件模块 + MPC多方计算 |

→ 详见 [business/domain-custody.md](./business/domain-custody.md)

---

### 9. 合规 (Compliance)

全平台合规基石，拥有最高权限。

| 项目 | 说明 |
|------|------|
| **核心能力** | KYC验证、AML筛查、交易监控、SAR报告 |
| **特殊权限** | 可冻结任何账户、可阻止任何交易 |
| **规则类型** | 阈值规则、速率规则、模式规则、地理规则 |

→ 详见 [business/domain-compliance.md](./business/domain-compliance.md)

---

## 跨领域业务流程

### 稳定币铸造流程 (跨5个服务)

```
User → Bridge → Compliance → Custody → Stablecoin → Blockchain
 │        │          │           │           │           │
 │  发起入金   合规检查    资产托管    铸造代币    链上确认
 │        │          │           │           │           │
 └────────┴──────────┴───────────┴───────────┴───────────┘
```

### RWA投资流程 (跨6个服务)

```
User → Compliance → RWA → Stablecoin → Custody → Blockchain
 │          │         │        │           │          │
认购申请  投资者认证  份额分配  支付锁定   代币铸造   链上登记
```

### 借贷清算流程 (跨4个服务)

```
Oracle → Lending → Custody → Stablecoin
   │         │         │          │
价格更新  触发清算  资产划转   债务偿还
```

---

## 术语词典

→ 详见 [business/glossary.md](./business/glossary.md)

## 领域事件全景

| 领域 | 关键事件 | 影响范围 |
|------|----------|----------|
| User | UserRegistered, UserLoggedIn | 合规、通知、审计 |
| Bridge | OnRampCompleted, OffRampCompleted | 账户、统计、对账 |
| Stablecoin | MintCompleted, RedemptionCompleted | 储备、统计 |
| RWA | OfferingSettled, DividendPaid | 代币分发、税务 |
| Lending | LiquidationExecuted, HealthFactorAlert | 通知、风控 |
| Staking | RewardsDistributed, LSTMinted | 用户、代币 |
| Compliance | AccountFrozen, SARFiled | 所有业务服务 |

→ 详见 [architecture/data-flow.md](./architecture/data-flow.md)
