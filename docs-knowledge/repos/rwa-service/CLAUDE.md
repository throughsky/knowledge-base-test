# RWA Service

> Real World Assets 服务 - 负责现实资产代币化和发行管理

## 快速导航

- 业务知识: 参考项目知识库 `../project-web3-financial/business/domain-rwa.md`
- 架构总览: 参考项目知识库 `../project-web3-financial/ARCHITECTURE.md`
- 本仓库上下文: `.knowledge/context.md`

## 核心职责

1. **资产入驻**: 接收现实资产登记，完成法律审核和估值
2. **代币化**: 创建代表资产权益的链上代币
3. **发行管理**: 管理STO/私募发行流程
4. **收益分配**: 处理资产收益的分红分配

## 关键约束

- 所有投资者必须通过合格投资者认证
- 资产估值有效期最长90天
- 代币转让双方必须在白名单中
- 发行需获得监管审批

## 技术栈

- Java 17 + Spring Boot 3.x
- PostgreSQL (业务数据)
- Redis (缓存/限流)
- RabbitMQ (事件发布)
- Web3j (链上交互)
- ERC1400/ERC3643 (证券型代币标准)

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

## 支持的资产类型

| 类型 | 说明 | 代币标准 |
|------|------|----------|
| REAL_ESTATE | 房地产 | ERC1400 |
| FIXED_INCOME | 固定收益(债券) | ERC3643 |
| EQUITY | 股权 | ERC1400 |
| COMMODITY | 大宗商品 | ERC20 |
