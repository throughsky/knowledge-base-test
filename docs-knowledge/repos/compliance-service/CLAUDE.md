# Compliance Service

> 合规服务 - 负责AML/KYC、交易监控和风险控制

## 快速导航

- 项目架构: 参考 `../../project-web3-financial/ARCHITECTURE.md`
- 服务目录: 参考 `../../project-web3-financial/architecture/service-catalog.md`
- 本仓库上下文: `.knowledge/context.md`

## 核心职责

1. **KYC验证**: 客户身份验证与尽职调查
2. **AML筛查**: 反洗钱交易监控
3. **风险评估**: 客户和交易风险评分
4. **合规报告**: SAR报告和监管报告生成

## 关键约束

- 合规优先于业务，所有可疑活动必须报告
- 高风险客户必须进行增强尽职调查(EDD)
- 制裁名单匹配立即冻结账户
- SAR必须在规定时限内提交

## 技术栈

- Java 17 + Spring Boot 3.x
- PostgreSQL (业务数据)
- Redis (缓存)
- Elasticsearch (日志分析)

## 本地开发

```bash
docker-compose up -d postgres redis elasticsearch
./gradlew bootRun
./gradlew test
```

## 主要入口

| 模块 | 路径 | 说明 |
|------|------|------|
| KYC模块 | `src/main/java/.../kyc/` | 身份验证 |
| AML模块 | `src/main/java/.../aml/` | 反洗钱 |
| 规则引擎 | `src/main/java/.../rules/` | 合规规则 |
| 报告模块 | `src/main/java/.../reporting/` | 监管报告 |
