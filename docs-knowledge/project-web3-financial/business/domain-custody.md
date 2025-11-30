# 托管领域模型

## 领域概述

托管领域是Web3金融平台的安全基石，负责数字资产的安全保管、多签管理、密钥托管和交易签名。

## 核心概念

### 聚合根

| 聚合根 | 定义 |
|--------|------|
| **Vault** | 保险库，包含钱包、签名者、策略 |
| **Wallet** | 钱包，包含地址、余额、类型 |
| **Key** | 密钥，包含类型、存储方式、状态 |

### 关键实体

| 实体 | 定义 |
|------|------|
| Signer | 签名者 |
| Policy | 安全策略 |
| Transaction | 待签名交易 |
| SignatureRequest | 签名请求 |

### 值对象

```yaml
VaultType: INSTITUTIONAL | RETAIL | TREASURY
WalletType: HOT | WARM | COLD | MPC
KeyType: ECDSA | EdDSA
StorageType: HSM | MPC | SOFTWARE
PolicyType: WHITELIST | SPENDING_LIMIT | TIME_LOCK | VELOCITY | APPROVAL_WORKFLOW
```

## 核心流程

### 交易签名流程
```
交易发起 → 策略评估 → 审批流程 → MPC/HSM签名 → 交易广播
```

### 多签审批流程
```
发起请求 → 收集签名 → 达到阈值 → 执行交易
```

## 业务规则

1. **私钥安全**: 私钥永不离开安全边界
2. **审计追踪**: 所有操作需审计追踪
3. **多签阈值**: 阈值必须满足 (如 2-of-3)
4. **策略优先**: 安全策略必须通过

## 安全策略类型

| 策略类型 | 说明 | 示例 |
|----------|------|------|
| WHITELIST | 白名单 | 只能转到已知地址 |
| SPENDING_LIMIT | 支出限额 | 单笔≤$10,000 |
| TIME_LOCK | 时间锁 | 大额等待24小时 |
| VELOCITY | 速率限制 | 日限额$100,000 |
| APPROVAL_WORKFLOW | 审批流程 | 2-of-3多签 |

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

## 领域事件

| 事件 | 触发 | 订阅者 |
|------|------|--------|
| VaultCreated | 保险库创建 | 审计服务 |
| WalletCreated | 钱包创建 | 余额监控 |
| TransactionCreated | 交易请求创建 | 策略引擎 |
| SignatureCollected | 签名收集 | 交易服务 |
| TransactionConfirmed | 交易确认 | 余额服务 |
| PolicyViolation | 策略违规 | 风控服务, 告警 |
| VaultFrozen | 保险库冻结 | 所有相关服务 |

## 依赖关系

- **上游**: 无 (核心基础设施)
- **下游**: Stablecoin, RWA, Lending, Staking, Bridge (作为资产托管供应商)
