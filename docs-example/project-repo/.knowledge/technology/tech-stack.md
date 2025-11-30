# 技术栈规范 (Technology Stack Specification)

**版本**: 1.0
**最后更新**: 2025-11-30
**负责人**: @技术负责人

---

## 概述

本文档定义了项目的技术栈选型，所有开发必须遵循此规范。

<!-- AI-CONTEXT
这是项目的技术栈规范，是L2层强制要求。
AI在生成代码时必须使用这里指定的技术和版本。
关键技术：Java 17, Spring Boot 3.2, MyBatis, PostgreSQL, React 18
禁止使用：Maven, JavaScript(无类型), 其他未列出的框架
-->

---

## 后端技术栈

### 核心框架

| 技术 | 版本 | 用途 | 状态 |
|------|------|------|------|
| **Java** | 17 LTS | 开发语言 | 强制 |
| **Spring Boot** | 3.2.x | 应用框架 | 强制 |
| **MyBatis** | 3.5.x | ORM框架 | 强制 |
| **Gradle** | 8.14+ | 构建工具 | 强制 |

### 数据存储

| 技术 | 版本 | 用途 | 状态 |
|------|------|------|------|
| **PostgreSQL** | 15+ | 主数据库 | 强制 |
| **Redis** | 7+ | 缓存/会话 | 强制 |
| **Kafka** | 3.x | 消息队列 | 强制 |
| **Elasticsearch** | 8.x | 搜索引擎 | 可选 |

### 工具库

| 技术 | 用途 | 状态 |
|------|------|------|
| **Lombok** | 代码简化 | 推荐 |
| **MapStruct** | 对象映射 | 推荐 |
| **Springdoc OpenAPI** | API文档 | 强制 |
| **JUnit 5** | 单元测试 | 强制 |
| **Mockito** | Mock框架 | 强制 |

---

## 前端技术栈

### 核心框架

| 技术 | 版本 | 用途 | 状态 |
|------|------|------|------|
| **React** | 18+ | UI框架 | 强制 |
| **TypeScript** | 5.0+ | 开发语言 | 强制 |
| **Next.js** | 14+ | 应用框架 | 推荐 |
| **pnpm** | 8+ | 包管理 | 强制 |

### UI组件

| 技术 | 用途 | 状态 |
|------|------|------|
| **Ant Design** | UI组件库 | 推荐 |
| **TailwindCSS** | CSS框架 | 可选 |

### 状态管理

| 技术 | 用途 | 状态 |
|------|------|------|
| **TanStack Query** | 服务端状态 | 推荐 |
| **Zustand** | 客户端状态 | 推荐 |

---

## 基础设施

### 容器化

| 技术 | 版本 | 用途 |
|------|------|------|
| **Docker** | 24+ | 容器运行时 |
| **Kubernetes** | 1.28+ | 容器编排 |
| **Helm** | 3.x | K8s部署 |

### CI/CD

| 技术 | 用途 |
|------|------|
| **GitHub Actions** | CI/CD流水线 |
| **ArgoCD** | GitOps部署 |

### 可观测性

| 技术 | 用途 |
|------|------|
| **Prometheus** | 指标收集 |
| **Grafana** | 可视化 |
| **Jaeger** | 分布式追踪 |
| **ELK** | 日志聚合 |

---

## 禁止使用的技术

| 技术 | 原因 |
|------|------|
| **Maven** | 统一使用Gradle |
| **JavaScript (无类型)** | 必须使用TypeScript |
| **jQuery** | 使用React组件化 |
| **Moment.js** | 使用date-fns |
| **Java 8/11** | 使用Java 17+ |

---

## Gradle 配置示例

```groovy
// build.gradle.kts
plugins {
    java
    id("org.springframework.boot") version "3.2.0"
    id("io.spring.dependency-management") version "1.1.4"
}

java {
    sourceCompatibility = JavaVersion.VERSION_17
}

dependencies {
    // Spring Boot
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-validation")
    implementation("org.springframework.boot:spring-boot-starter-data-redis")

    // MyBatis
    implementation("org.mybatis.spring.boot:mybatis-spring-boot-starter:3.0.3")

    // Database
    runtimeOnly("org.postgresql:postgresql")

    // Tools
    compileOnly("org.projectlombok:lombok")
    annotationProcessor("org.projectlombok:lombok")

    // API Docs
    implementation("org.springdoc:springdoc-openapi-starter-webmvc-ui:2.3.0")

    // Testing
    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testImplementation("org.mockito:mockito-core")
}
```

---

## package.json 配置示例

```json
{
  "name": "ecommerce-frontend",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "eslint . --ext .ts,.tsx",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "antd": "^5.12.0",
    "@tanstack/react-query": "^5.0.0",
    "zustand": "^4.4.0",
    "axios": "^1.6.0",
    "date-fns": "^2.30.0"
  },
  "devDependencies": {
    "typescript": "^5.3.0",
    "@types/react": "^18.2.0",
    "@types/node": "^20.0.0",
    "eslint": "^8.55.0",
    "eslint-config-next": "^14.0.0"
  },
  "engines": {
    "node": ">=20.0.0"
  },
  "packageManager": "pnpm@8.10.0"
}
```

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| 1.0 | 2025-11-30 | 初始版本 | @技术负责人 |
