# Bridge Service

> Web2桥接服务 - 连接传统金融系统与区块链网络

## 快速导航

- 项目架构: 参考 `../../project-web3-financial/ARCHITECTURE.md`
- 服务目录: 参考 `../../project-web3-financial/architecture/service-catalog.md`
- 本仓库上下文: `.knowledge/context.md`

## 核心职责

1. **法币出入金**: 处理法币与加密货币的转换
2. **银行账户集成**: 管理用户银行账户绑定与验证
3. **支付通道管理**: 对接多种支付服务商
4. **跨系统对账**: 确保资金流转可追溯

## 关键约束

- 资金流转需全程可追溯
- 所有交易需通过合规检查
- 银行账户必须经过验证才能出金
- 入金订单15分钟未支付自动取消

## 技术栈

- Java 17 + Spring Boot 3.x
- PostgreSQL (业务数据)
- Redis (缓存/限流)
- RabbitMQ (事件发布)

## 本地开发

```bash
docker-compose up -d postgres redis rabbitmq
./gradlew bootRun
./gradlew test
```

## 主要入口

| 模块 | 路径 | 说明 |
|------|------|------|
| API层 | `src/main/java/.../api/` | REST控制器 |
| 领域层 | `src/main/java/.../domain/` | 业务逻辑 |
| 银行网关 | `src/main/java/.../gateway/` | 银行对接 |
| 支付集成 | `src/main/java/.../payment/` | 支付通道 |
