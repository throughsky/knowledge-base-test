# Stablecoin Service

> 稳定币服务 - 负责稳定币的铸造、赎回和储备管理

## 快速导航

- 业务知识: 参考项目知识库 `../project-web3-financial/business/domain-stablecoin.md`
- 架构总览: 参考项目知识库 `../project-web3-financial/ARCHITECTURE.md`
- 本仓库上下文: `.knowledge/context.md`

## 核心职责

1. **稳定币铸造**: 接收法币抵押，铸造等值稳定币
2. **稳定币赎回**: 销毁稳定币，释放法币抵押
3. **储备管理**: 维护储备率 >= 100%
4. **合规集成**: 与合规服务联动进行AML/KYC检查

## 关键约束

- 储备率必须 >= 100%，低于100%时暂停铸造
- 所有铸造/赎回操作需通过合规检查
- 大额交易(>$100k)需人工审批

## 技术栈

- Java 17 + Spring Boot 3.x
- PostgreSQL (业务数据)
- Redis (缓存/限流)
- RabbitMQ (事件发布)
- Web3j (链上交互)

## 本地开发

```bash
# 启动依赖服务
docker-compose up -d postgres redis rabbitmq

# 运行服务
./gradlew bootRun

# 运行测试
./gradlew test
```

## 主要入口

| 模块 | 路径 | 说明 |
|------|------|------|
| API层 | `src/main/java/.../api/` | REST控制器 |
| 领域层 | `src/main/java/.../domain/` | 业务逻辑 |
| 基础设施 | `src/main/java/.../infra/` | 外部集成 |
| 合约交互 | `src/main/java/.../blockchain/` | Web3调用 |
