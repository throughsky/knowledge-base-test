# dweb-core 模块文档

## 简介

dweb-core模块是DWeb应用的核心模块，负责用户管理和基础服务配置。该模块提供了用户相关的核心业务逻辑，包括用户数据访问、用户服务实现以及基础的数据源和配置管理。

## 核心功能

- **用户管理**：提供用户相关的核心业务逻辑和数据访问
- **数据源配置**：统一的数据源配置管理
- **服务配置**：Feign客户端配置和通用服务配置
- **监控追踪**：集成链路追踪和SQL日志拦截

## 架构设计

### 模块架构图

```mermaid
graph TB
    subgraph "dweb-core模块"
        DwebApp[DwebApp - 主应用类]
        UserController[UserController - 用户控制器]
        UserService[UserService - 用户服务接口]
        UserServiceImpl[UserServiceImpl - 用户服务实现]
        UserMapper[UserMapper - 用户数据访问]
        User[User - 用户实体]
        
        subgraph "配置组件"
            DataSourceAspect[DataSourceAspect - 数据源切面]
            DataSourceConfig[DataSourceConfig - 数据源配置]
            FeignConfig[FeignConfig - Feign配置]
        end
        
        subgraph "监控组件"
            CommonTraceFilter[CommonTraceFilter - 链路追踪过滤器]
            SqlLogInterceptor[SqlLogInterceptor - SQL日志拦截器]
        end
    end
    
    DwebApp --> UserController
    UserController --> UserService
    UserService --> UserServiceImpl
    UserServiceImpl --> UserMapper
    UserMapper --> User
    
    DataSourceConfig --> DataSourceAspect
    DataSourceAspect --> UserMapper
    
    CommonTraceFilter --> UserController
    SqlLogInterceptor --> UserMapper
```

### 组件依赖关系

```mermaid
graph LR
    subgraph "依赖层级"
        UserController --> UserService
        UserService --> UserServiceImpl
        UserServiceImpl --> UserMapper
        UserMapper --> User
        
        UserController -.-> |"使用"| CommonTraceFilter
        UserMapper -.-> |"被监控"| SqlLogInterceptor
        UserMapper -.-> |"被管理"| DataSourceAspect
        
        DataSourceAspect --> DataSourceConfig
        UserController --> FeignConfig
    end
```

## 核心组件详解

### 1. DwebApp - 主应用类

DwebApp是dweb-core模块的启动类，负责初始化Spring Boot应用并加载相关配置。

**主要功能：**
- 启动Spring Boot应用
- 加载数据源配置
- 启用Feign客户端
- 集成链路追踪

### 2. 用户管理组件

#### UserController
用户控制器，提供用户相关的REST API接口。

**主要职责：**
- 处理用户相关的HTTP请求
- 调用用户服务层处理业务逻辑
- 返回标准化的响应结果

#### UserService / UserServiceImpl
用户服务接口及其实现，封装用户相关的业务逻辑。

**主要功能：**
- 用户信息的增删改查
- 用户权限验证
- 用户状态管理

#### UserMapper
用户数据访问对象，负责与数据库交互。

**主要职责：**
- 执行用户相关的SQL操作
- 提供用户数据的持久化接口
- 支持复杂的查询需求

#### User
用户实体类，定义用户数据模型。

**主要属性：**
- 用户基本信息（ID、用户名、邮箱等）
- 用户状态信息
- 用户权限信息

### 3. 配置管理组件

#### DataSourceConfig
数据源配置类，统一管理数据库连接配置。

**配置内容：**
- 数据库连接池配置
- 多数据源配置
- 连接参数配置

#### DataSourceAspect
数据源切面，实现数据源的动态切换和监控。

**主要功能：**
- 动态数据源切换
- 数据源连接监控
- 数据库操作统计

#### FeignConfig
Feign客户端配置，用于微服务间的HTTP调用。

**配置内容：**
- Feign客户端超时配置
- 请求拦截器配置
- 错误处理配置

### 4. 监控追踪组件

#### CommonTraceFilter
通用链路追踪过滤器，记录请求链路信息。

**主要功能：**
- 请求链路追踪
- 性能监控
- 异常记录

#### SqlLogInterceptor
SQL日志拦截器，记录和监控SQL执行情况。

**主要功能：**
- SQL执行时间记录
- SQL语句日志输出
- 慢查询监控

## 数据流图

```mermaid
sequenceDiagram
    participant Client
    participant UserController
    participant CommonTraceFilter
    participant UserService
    participant UserServiceImpl
    participant UserMapper
    participant SqlLogInterceptor
    participant Database
    
    Client->>UserController: HTTP请求
    UserController->>CommonTraceFilter: 开始追踪
    CommonTraceFilter->>UserController: 追踪信息
    UserController->>UserService: 调用服务
    UserService->>UserServiceImpl: 业务处理
    UserServiceImpl->>UserMapper: 数据访问
    UserMapper->>SqlLogInterceptor: SQL拦截
    SqlLogInterceptor->>Database: 执行SQL
    Database-->>SqlLogInterceptor: 返回结果
    SqlLogInterceptor-->>UserMapper: 记录日志
    UserMapper-->>UserServiceImpl: 返回数据
    UserServiceImpl-->>UserService: 处理结果
    UserService-->>UserController: 服务响应
    UserController-->>CommonTraceFilter: 结束追踪
    UserController-->>Client: HTTP响应
```

## 模块集成

### 与common-auth模块集成

```mermaid
graph LR
    subgraph "dweb-core"
        UserController
        UserService
    end
    
    subgraph "common-auth"
        AuthApp[AuthApp]
        JWTUtil[JWTUtil]
        UserService[UserService]
    end
    
    UserController -.-> |"权限验证"| JWTUtil
    UserService -.-> |"用户信息共享"| UserService
```

### 与custodian-core模块集成

```mermaid
graph LR
    subgraph "dweb-core"
        DwebApp
        User
        UserMapper
    end
    
    subgraph "custodian-core"
        CustodianApplication
        UserMapper
        User
        WalletService
    end
    
    DwebApp -.-> |"共享用户数据模型"| User
    UserMapper -.-> |"统一数据访问"| UserMapper
```

## 配置说明

### 数据源配置

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/dweb_core
    username: ${DB_USERNAME:dweb_user}
    password: ${DB_PASSWORD:dweb_password}
    driver-class-name: com.mysql.cj.jdbc.Driver
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
```

### Feign配置

```yaml
feign:
  client:
    config:
      default:
        connectTimeout: 5000
        readTimeout: 10000
        loggerLevel: basic
  hystrix:
    enabled: true
```

### 监控配置

```yaml
logging:
  level:
    com.dweb.core.mapper: DEBUG
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
```

## 部署架构

```mermaid
graph TB
    subgraph "应用层"
        DwebCore[Dweb-Core服务]
        CommonAuth[Common-Auth服务]
        CustodianCore[Custodian-Core服务]
    end
    
    subgraph "数据层"
        DB1[(用户数据库)]
        DB2[(权限数据库)]
        DB3[(托管数据库)]
    end
    
    subgraph "监控层"
        Tracing[链路追踪]
        Logging[日志收集]
        Metrics[指标监控]
    end
    
    DwebCore --> DB1
    DwebCore --> CommonAuth
    CommonAuth --> DB2
    CustodianCore --> DB3
    
    DwebCore --> Tracing
    DwebCore --> Logging
    DwebCore --> Metrics
```

## 最佳实践

### 1. 用户管理最佳实践

- **数据一致性**：使用事务确保用户数据操作的一致性
- **缓存策略**：对频繁查询的用户信息进行合理缓存
- **分页处理**：用户列表查询必须支持分页，避免大数据量查询

### 2. 监控配置最佳实践

- **链路追踪**：为所有用户相关操作添加追踪标识
- **日志级别**：生产环境使用适当的日志级别，避免过度日志输出
- **性能监控**：监控关键用户操作的响应时间

### 3. 安全配置最佳实践

- **数据加密**：敏感用户信息需要加密存储
- **访问控制**：用户数据访问需要权限验证
- **SQL注入**：使用参数化查询防止SQL注入攻击

## 相关文档

- [common-auth模块文档](common-auth.md) - 认证授权相关功能
- [custodian-core模块文档](custodian-core.md) - 数字资产托管核心功能
- [wecommon模块文档](wecommon.md) - 通用工具类和常量定义

## 总结

dweb-core模块作为DWeb应用的核心模块，提供了用户管理和基础服务配置的核心功能。通过合理的设计和配置，确保了系统的可扩展性、可维护性和高性能。模块与其他核心模块紧密集成，共同构建了完整的DWeb应用生态系统。