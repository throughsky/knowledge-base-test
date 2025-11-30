# Tokenization Service

> 存款代币化服务 - 负责将传统银行存款转换为链上代币

## 快速导航

- 项目架构: 参考 `../../project-web3-financial/ARCHITECTURE.md`
- 服务目录: 参考 `../../project-web3-financial/architecture/service-catalog.md`
- 本仓库上下文: `.knowledge/context.md`

## 核心职责

1. **存款代币化**: 银行存款到链上代币的转换
2. **代币赎回**: 代币销毁换回存款
3. **利息分发**: 存款利息自动分发
4. **对账审计**: 确保代币与存款1:1映射

## 关键约束

- 代币总量必须等于托管存款总额
- 所有供应量变化需银行确认
- 利率变更提前24小时公告
- 每日自动对账

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
| 代币化 | `src/main/java/.../tokenization/` | 存款转代币 |
| 赎回模块 | `src/main/java/.../redemption/` | 代币转存款 |
| 利息服务 | `src/main/java/.../interest/` | 利息计算分发 |
| 银行网关 | `src/main/java/.../bank/` | 银行对接 |
