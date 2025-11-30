# Web3金融服务平台 - 项目知识库 (L1)

**项目名称**: Web3 Financial Services Platform
**版本**: 1.0
**维护者**: 项目架构师
**仓库数量**: 8个核心仓库

---

## 项目概述

Web3金融服务平台是一个企业级区块链金融基础设施，提供稳定币发行、RWA代币化、借贷、质押等核心金融服务。

## 快速导航

| 文档 | 用途 |
|------|------|
| [业务知识](./BUSINESS.md) | 业务领域入口 |
| [架构知识](./ARCHITECTURE.md) | 技术架构入口 |
| [business/](./business/) | 领域模型、术语、流程 |
| [architecture/](./architecture/) | 服务目录、数据流、ADR |
| [aggregated/](./aggregated/) | AI聚合的仓库信息 |

## 仓库列表

| 仓库 | 职责 | 技术栈 |
|------|------|--------|
| stablecoin-service | 稳定币发行与管理 | Java/Spring |
| rwa-service | RWA资产代币化 | Java/Spring |
| custody-service | 托管钱包服务 | Go |
| compliance-service | AML/KYC合规 | Java/Spring |
| lending-service | 借贷协议 | Java/Spring |
| staking-service | 质押服务 | Java/Spring |
| bridge-service | 跨链桥接 | Rust |
| contracts | 智能合约 | Solidity |

## 继承关系

```yaml
# 继承企业规范
enterprise:
  source: "../enterprise-standards"
  inherits:
    - constitution/architecture-principles.md
    - standards/coding-standards.md
    - standards/api-design.md
    - technology-radar/radar.md
```

## AI上下文

```
<!-- AI-CONTEXT
项目类型: Web3金融服务平台
核心领域: 稳定币、RWA、借贷、质押
技术栈: Java 17 + Spring Boot 3.x + Solidity
架构: 微服务 + 事件驱动
关键约束: 金融合规、链上安全、高可用
-->
```
