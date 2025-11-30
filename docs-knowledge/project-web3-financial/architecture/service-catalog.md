# 服务目录

## 服务拓扑

```
                              ┌─────────────────┐
                              │   API Gateway   │
                              │  (认证/限流/路由) │
                              └────────┬────────┘
                                       │
    ┌──────────────────────────────────┼──────────────────────────────────┐
    │          │          │            │            │          │          │
    ▼          ▼          ▼            ▼            ▼          ▼          ▼
┌────────┐┌────────┐┌──────────┐┌──────────┐┌────────┐┌────────┐┌────────┐
│  User  ││ Bridge ││Stablecoin││   RWA    ││Tokenize││Lending ││Staking │
│Service ││Service ││ Service  ││ Service  ││Service ││Service ││Service │
│(身份)  ││(桥接)  ││ (稳定币) ││ (资产)   ││(存款)  ││ (借贷) ││ (质押) │
└───┬────┘└───┬────┘└────┬─────┘└────┬─────┘└───┬────┘└───┬────┘└───┬────┘
    │         │          │           │          │         │         │
    │         └──────────┴─────┬─────┴──────────┴─────────┴─────────┘
    │                          │
    │  所有服务依赖             │
    └─────────────┐            │
                  ▼            ▼
            ┌───────────────────────┐
            │    Custody Service    │
            │   (托管/密钥/多签)     │
            └───────────┬───────────┘
                        │
            ┌───────────▼───────────┐
            │  Compliance Service   │
            │  (AML/KYC/风控/冻结)   │
            └───────────────────────┘
```

## 服务详情

| 服务 | 仓库 | 职责 | 端口 | 负责人 |
|------|------|------|------|--------|
| stablecoin-service | stablecoin-service | 稳定币铸造/赎回 | 8001 | @稳定币团队 |
| rwa-service | rwa-service | RWA代币化/发行 | 8002 | @RWA团队 |
| custody-service | custody-service | 资产托管/签名 | 8003 | @托管团队 |
| compliance-service | compliance-service | AML/KYC | 8004 | @合规团队 |
| lending-service | lending-service | 借贷协议 | 8005 | @借贷团队 |
| staking-service | staking-service | 质押服务 | 8006 | @质押团队 |
| bridge-service | bridge-service | 法币出入金 | 8007 | @桥接团队 |
| tokenization-service | tokenization-service | 存款代币化 | 8008 | @代币化团队 |
| user-service | user-service | 用户身份/认证 | 8009 | @用户平台团队 |

## 依赖关系

| 服务 | 上游依赖 | 下游消费者 |
|------|----------|-----------|
| stablecoin | custody, compliance | lending, staking, rwa, bridge |
| rwa | custody, compliance, stablecoin | lending |
| custody | - | stablecoin, rwa, lending, staking, bridge |
| compliance | - | 所有业务服务 |
| lending | stablecoin, custody, staking | - |
| staking | stablecoin, custody | lending |
| bridge | stablecoin, compliance, custody | - |
| tokenization | custody, compliance | lending |
| user | - | 所有服务(身份验证) |

## 健康检查

所有服务统一健康检查端点：
- 存活检查: `GET /actuator/health/liveness`
- 就绪检查: `GET /actuator/health/readiness`
