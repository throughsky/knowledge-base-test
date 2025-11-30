# Web3金融术语词典 (Web3 Financial Glossary)

**最后更新**: 2025-11-30
**负责人**: @架构委员会

---

## 概述

本词典统一了Web3金融服务领域的业务和技术术语定义，建立"通用语言"，消除团队间的沟通歧义。

<!-- AI-CONTEXT
Web3金融术语词典是跨团队沟通的基础。
AI在理解业务需求或生成文档时应使用这些标准术语。
涵盖：DeFi术语、区块链术语、合规术语、传统金融术语
-->

---

## 核心DeFi术语

| 术语 | 英文 | 定义 | 使用上下文 |
|------|------|------|------------|
| **稳定币** | Stablecoin | 与法币或资产锚定的加密货币，价格稳定 | 支付、借贷、交易 |
| **铸币** | Mint | 创建新的代币，增加代币供应量 | 稳定币发行 |
| **销毁** | Burn | 永久移除代币，减少代币供应量 | 赎回、通缩 |
| **储备率** | Reserve Ratio | 储备资产价值/代币供应量的比率 | 稳定币管理 |
| **锚定** | Peg | 代币价格与目标价格保持一致 | 稳定币机制 |
| **脱锚** | Depeg | 代币价格偏离目标价格 | 风险监控 |
| **APY** | Annual Percentage Yield | 年化收益率，考虑复利 | 收益展示 |
| **APR** | Annual Percentage Rate | 年化利率，不考虑复利 | 利率计算 |
| **TVL** | Total Value Locked | 锁定总价值，DeFi协议中的资产总量 | 协议规模 |
| **流动性** | Liquidity | 资产可快速买卖而不影响价格的能力 | 市场深度 |
| **滑点** | Slippage | 预期成交价与实际成交价的差异 | 交易执行 |
| **无常损失** | Impermanent Loss | 流动性提供者因价格变化产生的损失 | 流动性挖矿 |

---

## 质押与借贷术语

| 术语 | 英文 | 定义 | 使用上下文 |
|------|------|------|------------|
| **质押** | Staking | 锁定代币以支持网络运行并获得奖励 | 收益、治理 |
| **解质押** | Unstaking | 取回质押的代币 | 资产管理 |
| **冷却期** | Cooldown Period | 解质押后等待提取的时间 | 解质押流程 |
| **流动性质押** | Liquid Staking | 质押后获得可流通的衍生代币 | stETH, rETH |
| **LST** | Liquid Staking Token | 流动性质押代币 | 质押衍生品 |
| **抵押** | Collateral | 借款时提供的担保资产 | 借贷 |
| **抵押率** | Collateral Ratio | 抵押品价值/借款价值的比率 | 风险管理 |
| **LTV** | Loan-to-Value | 借款价值/抵押品价值的比率 | 借贷风险 |
| **清算** | Liquidation | 强制出售抵押品偿还债务 | 风险处置 |
| **清算阈值** | Liquidation Threshold | 触发清算的LTV临界值 | 风险参数 |
| **健康因子** | Health Factor | 衡量仓位安全程度的指标 | 风险监控 |
| **利用率** | Utilization Rate | 借出资金/总存款的比率 | 利率模型 |

---

## RWA与代币化术语

| 术语 | 英文 | 定义 | 使用上下文 |
|------|------|------|------------|
| **RWA** | Real World Assets | 现实世界资产，如房产、债券 | 资产代币化 |
| **代币化** | Tokenization | 将资产权益转化为区块链代币 | 资产数字化 |
| **STO** | Security Token Offering | 证券型代币发行 | 合规发行 |
| **合格投资者** | Accredited Investor | 符合监管要求的投资者 | 合规准入 |
| **白名单** | Whitelist | 被允许参与的地址列表 | 访问控制 |
| **转让限制** | Transfer Restriction | 代币转让的合规限制 | 证券合规 |
| **分红** | Dividend | 向代币持有者分配的收益 | 收益分配 |
| **登记日** | Record Date | 确定分红资格的截止日期 | 分红流程 |
| **估值** | Valuation | 对资产价值的评估 | 资产定价 |
| **托管人** | Custodian | 负责保管资产的机构 | 资产托管 |

---

## 托管与安全术语

| 术语 | 英文 | 定义 | 使用上下文 |
|------|------|------|------------|
| **保险库** | Vault | 安全存储资产的容器 | 资产托管 |
| **多签** | Multi-sig | 需要多个签名才能执行的机制 | 安全控制 |
| **阈值签名** | Threshold Signature | N-of-M签名方案 | 多签 |
| **MPC** | Multi-Party Computation | 多方计算，分布式密钥管理 | 密钥安全 |
| **HSM** | Hardware Security Module | 硬件安全模块 | 密钥存储 |
| **冷钱包** | Cold Wallet | 离线存储的钱包 | 资产安全 |
| **热钱包** | Hot Wallet | 联网的钱包 | 日常操作 |
| **私钥** | Private Key | 控制资产的秘密密钥 | 身份验证 |
| **助记词** | Mnemonic | 派生私钥的词组 | 密钥备份 |
| **策略引擎** | Policy Engine | 执行安全策略的系统 | 访问控制 |

---

## 合规与风控术语

| 术语 | 英文 | 定义 | 使用上下文 |
|------|------|------|------------|
| **KYC** | Know Your Customer | 客户身份验证 | 合规准入 |
| **AML** | Anti-Money Laundering | 反洗钱 | 合规监控 |
| **CFT** | Combating Financing of Terrorism | 反恐融资 | 合规监控 |
| **PEP** | Politically Exposed Person | 政治敏感人物 | 风险分类 |
| **SAR** | Suspicious Activity Report | 可疑活动报告 | 合规报告 |
| **CTR** | Currency Transaction Report | 大额交易报告 | 合规报告 |
| **制裁筛查** | Sanctions Screening | 检查是否在制裁名单 | 合规检查 |
| **OFAC** | Office of Foreign Assets Control | 美国资产控制办公室 | 制裁名单 |
| **EDD** | Enhanced Due Diligence | 增强尽职调查 | 高风险客户 |
| **MLRO** | Money Laundering Reporting Officer | 反洗钱报告官 | 合规角色 |
| **风险评分** | Risk Score | 量化风险的评分 | 风险评估 |
| **交易监控** | Transaction Monitoring | 实时监控交易的合规性 | AML |

---

## 区块链基础术语

| 术语 | 英文 | 定义 | 使用上下文 |
|------|------|------|------------|
| **链上** | On-chain | 记录在区块链上的数据/操作 | 数据存储 |
| **链下** | Off-chain | 不在区块链上的数据/操作 | 扩展方案 |
| **智能合约** | Smart Contract | 自动执行的链上程序 | 业务逻辑 |
| **Gas** | Gas | 执行交易的手续费单位 | 交易成本 |
| **Gas Price** | Gas Price | 每单位Gas的价格 | 费用计算 |
| **Nonce** | Nonce | 交易序号，防止重放 | 交易管理 |
| **区块确认** | Block Confirmation | 交易被打包后的区块数 | 交易终局性 |
| **预言机** | Oracle | 向链上提供链下数据的服务 | 价格喂价 |
| **跨链** | Cross-chain | 不同区块链间的交互 | 互操作性 |
| **L1** | Layer 1 | 基础区块链层 | Ethereum |
| **L2** | Layer 2 | 扩展层解决方案 | Arbitrum, Polygon |

---

## 桥接与支付术语

| 术语 | 英文 | 定义 | 使用上下文 |
|------|------|------|------------|
| **入金** | On-ramp | 法币兑换加密货币 | 资金流入 |
| **出金** | Off-ramp | 加密货币兑换法币 | 资金流出 |
| **支付通道** | Payment Channel | 与外部支付系统的集成 | 支付处理 |
| **汇率锁定** | Rate Lock | 固定汇率的有效期 | 交易执行 |
| **对账** | Reconciliation | 核对账目是否一致 | 财务管理 |
| **SWIFT** | SWIFT | 国际银行转账网络 | 跨境支付 |
| **SEPA** | Single Euro Payments Area | 欧洲统一支付区 | 欧洲转账 |
| **ACH** | Automated Clearing House | 美国自动清算系统 | 美国转账 |
| **FPS** | Faster Payments Service | 英国快速支付 | 英国转账 |

---

## 技术术语

| 术语 | 英文 | 定义 | 使用上下文 |
|------|------|------|------------|
| **聚合根** | Aggregate Root | DDD中保证一致性边界的实体 | 领域建模 |
| **限界上下文** | Bounded Context | 业务领域的边界定义 | 微服务划分 |
| **幂等性** | Idempotency | 多次执行产生相同结果 | API设计 |
| **熔断** | Circuit Breaker | 防止故障扩散的保护机制 | 服务治理 |
| **重放攻击** | Replay Attack | 重复提交已执行的交易 | 安全防护 |
| **防腐层** | Anti-Corruption Layer | 隔离外部系统的适配层 | 集成模式 |

---

## 状态术语

### 交易状态

| 状态 | 英文 | 含义 |
|------|------|------|
| 待处理 | PENDING | 交易已创建，等待处理 |
| 处理中 | PROCESSING | 交易正在处理 |
| 广播中 | BROADCASTING | 交易已广播到区块链 |
| 已确认 | CONFIRMED | 交易已被区块链确认 |
| 失败 | FAILED | 交易执行失败 |
| 已取消 | CANCELLED | 交易已取消 |

### KYC状态

| 状态 | 英文 | 含义 |
|------|------|------|
| 未开始 | NOT_STARTED | 尚未提交KYC |
| 待审核 | PENDING | 提交待审核 |
| 已验证 | VERIFIED | 验证通过 |
| 已拒绝 | REJECTED | 验证被拒绝 |
| 已过期 | EXPIRED | 验证已过期 |

### 仓位状态

| 状态 | 英文 | 含义 |
|------|------|------|
| 活跃 | ACTIVE | 正常运行中 |
| 锁定 | LOCKED | 锁定期内 |
| 冷却中 | COOLDOWN | 冷却期等待 |
| 可提取 | WITHDRAWABLE | 可以提取 |
| 已关闭 | CLOSED | 已完全退出 |

---

## 缩写对照

| 缩写 | 全称 | 含义 |
|------|------|------|
| **DeFi** | Decentralized Finance | 去中心化金融 |
| **TradFi** | Traditional Finance | 传统金融 |
| **CeFi** | Centralized Finance | 中心化金融 |
| **DEX** | Decentralized Exchange | 去中心化交易所 |
| **CEX** | Centralized Exchange | 中心化交易所 |
| **AMM** | Automated Market Maker | 自动做市商 |
| **LP** | Liquidity Provider | 流动性提供者 |
| **DAO** | Decentralized Autonomous Organization | 去中心化自治组织 |
| **NFT** | Non-Fungible Token | 非同质化代币 |
| **ERC** | Ethereum Request for Comments | 以太坊标准提案 |
| **EIP** | Ethereum Improvement Proposal | 以太坊改进提案 |
| **TWAP** | Time-Weighted Average Price | 时间加权平均价格 |
| **VWAP** | Volume-Weighted Average Price | 成交量加权平均价格 |

---

## 词典维护规则

1. **新术语审批**: 新术语需经架构委员会审核
2. **修改流程**: 修改定义需提交PR并获得审批
3. **定期审查**: 每季度审查词典完整性
4. **同步更新**: 代码中的术语需与词典保持一致
5. **多语言支持**: 保持中英文术语对照

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| 1.0 | 2025-11-30 | Web3金融服务术语 | @架构委员会 |
