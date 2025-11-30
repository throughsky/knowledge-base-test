# Custody Service

> 托管服务 - 负责数字资产安全保管、密钥管理和交易签名

## 快速导航

- 项目架构: 参考 `../../project-web3-financial/ARCHITECTURE.md`
- 服务目录: 参考 `../../project-web3-financial/architecture/service-catalog.md`
- 本仓库上下文: `.knowledge/context.md`

## 核心职责

1. **资产托管**: 数字资产安全保管
2. **密钥管理**: 密钥生成、存储和轮换
3. **多签管理**: 多签钱包和审批流程
4. **交易签名**: 安全签名和广播

## 关键约束

- 私钥永不离开安全边界
- 所有操作需审计追踪
- 多签阈值必须满足
- 冷钱包资产定期盘点

## 技术栈

- Java 17 + Spring Boot 3.x
- PostgreSQL (业务数据)
- HSM (硬件安全模块)
- MPC (多方计算)

## 本地开发

```bash
docker-compose up -d postgres redis
./gradlew bootRun
./gradlew test
```

## 主要入口

| 模块 | 路径 | 说明 |
|------|------|------|
| Vault管理 | `src/main/java/.../vault/` | 保险库 |
| 钱包管理 | `src/main/java/.../wallet/` | 钱包操作 |
| 密钥管理 | `src/main/java/.../key/` | 密钥服务 |
| 签名服务 | `src/main/java/.../signing/` | 交易签名 |
