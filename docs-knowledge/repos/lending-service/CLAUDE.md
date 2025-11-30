# Lending Service

> 借贷服务 - 负责去中心化借贷协议，包括抵押、借款和清算

## 快速导航

- 项目架构: 参考 `../../project-web3-financial/ARCHITECTURE.md`
- 服务目录: 参考 `../../project-web3-financial/architecture/service-catalog.md`
- 本仓库上下文: `.knowledge/context.md`

## 核心职责

1. **抵押品管理**: 存入和管理抵押资产
2. **借款发放**: 基于抵押发放借款
3. **利率计算**: 动态利率模型
4. **清算执行**: 健康因子低于1时执行清算

## 关键约束

- 健康因子必须 >= 1，否则可被清算
- 抵押率必须满足安全阈值
- 清算单次最多50%债务
- 利率根据利用率动态调整

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
| 存款模块 | `src/main/java/.../deposit/` | 存款操作 |
| 借款模块 | `src/main/java/.../borrow/` | 借款操作 |
| 清算模块 | `src/main/java/.../liquidation/` | 清算逻辑 |
| 预言机 | `src/main/java/.../oracle/` | 价格服务 |
