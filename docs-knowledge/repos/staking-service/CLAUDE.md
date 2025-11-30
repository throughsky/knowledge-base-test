# Staking Service

> 质押服务 - 负责资产质押、收益计算和奖励分发

## 快速导航

- 项目架构: 参考 `../../project-web3-financial/ARCHITECTURE.md`
- 服务目录: 参考 `../../project-web3-financial/architecture/service-catalog.md`
- 本仓库上下文: `.knowledge/context.md`

## 核心职责

1. **资产质押**: 管理用户质押和解质押
2. **收益计算**: APY计算和维护
3. **奖励分发**: 按份额分发奖励
4. **LST管理**: 流动性质押代币管理

## 关键约束

- 质押资产安全托管
- 收益计算透明可验证
- 解质押需经过冷却期
- LST汇率随奖励积累增长

## 技术栈

- Java 17 + Spring Boot 3.x
- PostgreSQL (业务数据)
- Redis (缓存)
- Web3j (链上交互)

## 本地开发

```bash
docker-compose up -d postgres redis
./gradlew bootRun
./gradlew test
```

## 主要入口

| 模块 | 路径 | 说明 |
|------|------|------|
| 质押池 | `src/main/java/.../pool/` | 池管理 |
| 仓位管理 | `src/main/java/.../position/` | 用户仓位 |
| 奖励服务 | `src/main/java/.../reward/` | 奖励计算分发 |
| LST模块 | `src/main/java/.../lst/` | 流动性代币 |
