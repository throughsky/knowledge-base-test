# 企业技术宪法 (L0)

**版本**: 1.0
**维护者**: 架构委员会
**更新频率**: 季度评审

---

## 概述

本仓库包含企业级强制规范，所有项目和仓库必须遵循。

## 目录结构

```
enterprise-standards/
├── README.md                    # 本文件
├── constitution/                # 技术宪法
│   └── architecture-principles.md
├── standards/                   # 编码规范
│   ├── coding-standards.md
│   └── api-design.md
└── technology-radar/            # 技术雷达
    └── radar.md
```

## 核心原则

1. **12-Factor App** - 云原生应用标准
2. **领域驱动设计** - 业务与技术对齐
3. **API优先** - 契约先于实现
4. **可观测性设计** - 日志/指标/追踪三支柱
5. **安全内建** - 安全融入设计

## 合规要求

- 所有项目必须在 `CLAUDE.md` 中声明继承本规范
- 架构评审时检查合规性
- 例外需申请并记录

## AI上下文

```
<!-- AI-CONTEXT
这是L0层企业宪法，所有项目必须遵循。
检查要点：硬编码配置、无状态进程、结构化日志、API契约
-->
```
