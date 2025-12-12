# Java开发规范总览 - AI编码约束

> 本文档为AI编码工具提供Java开发规范的全局约束指导

## 规范优先级

| 级别 | 标识 | 含义 | AI行为 |
|------|------|------|--------|
| 🔴 强制 | `[MUST]` | 违反将导致严重问题 | 必须遵守，不可妥协 |
| 🟡 推荐 | `[SHOULD]` | 最佳实践 | 默认遵守，特殊情况可调整 |
| 🟢 建议 | `[MAY]` | 可选优化 | 视情况采用 |

## 规范分类索引

### 第一阶段：项目启动·基础共识
| 规范 | 文件 | 核心关注点 |
|------|------|------------|
| 基础编码规范 | `02-coding-basics.md` | 命名、注释、语法、参数校验 |
| 接口设计规范 | `05-api-design.md` | RESTful、请求响应、文档、版本控制 |

### 第二阶段：架构设计·核心底座
| 规范 | 文件 | 核心关注点 |
|------|------|------------|
| 数据库交互规范 | `03-database.md` | 连接池、SQL安全、索引、事务、MyBatis |
| 缓存规范 | `04-cache.md` | 选型、穿透/击穿/雪崩、一致性、Redis |
| 微服务治理规范 | `06-microservice.md` | 注册发现、远程调用、流量治理、配置管理 |

### 第三阶段：编码实现·核心功能
| 规范 | 文件 | 核心关注点 |
|------|------|------------|
| 并发编程规范 | `07-concurrency.md` | 线程池、锁、线程安全、并发工具 |
| 安全规范 | `08-security.md` | 输入输出安全、权限控制、数据加密 |

### 第四阶段：质量校验·上线前准备
| 规范 | 文件 | 核心关注点 |
|------|------|------------|
| 测试规范 | `09-testing.md` | 单元测试、集成测试、性能测试、CI/CD |

### 第五阶段：部署上线·交付生产
| 规范 | 文件 | 核心关注点 |
|------|------|------------|
| 部署运维规范 | `10-deployment.md` | 环境隔离、容器化、CI/CD、监控告警 |

### 第六阶段：长期运维·持续治理
| 规范 | 文件 | 核心关注点 |
|------|------|------------|
| 数据治理规范 | `11-data-governance.md` | 数据标准、质量、分库分表、生命周期 |
| 合规性规范 | `12-compliance.md` | 数据隐私、等保2.0、GDPR |
| 团队协作规范 | `13-team-collaboration.md` | 分支管理、代码评审、变更管理 |

## AI编码核心原则

### 1. 安全优先原则
```yaml
priorities:
  - SQL注入防护 > 功能实现
  - 密码加密存储 > 快速开发
  - 敏感数据脱敏 > 日志完整性
```

### 2. 性能意识原则
```yaml
checks:
  - 索引是否合理设计
  - 是否存在N+1查询
  - 缓存策略是否正确
  - 线程池参数是否合理
```

### 3. 可维护性原则
```yaml
requirements:
  - 命名见名知意
  - 关键逻辑有注释
  - 代码结构清晰
  - 异常处理完善
```

## AI代码生成检查清单

### 生成代码前检查
- [ ] 是否理解业务需求
- [ ] 是否了解现有代码风格
- [ ] 是否确认技术栈版本

### 生成代码时检查
- [ ] 命名是否符合规范
- [ ] 是否处理了异常情况
- [ ] 是否考虑了线程安全
- [ ] SQL是否使用参数化查询
- [ ] 敏感数据是否加密/脱敏

### 生成代码后检查
- [ ] 是否需要添加单元测试
- [ ] 是否需要更新API文档
- [ ] 是否需要数据库脚本

## 快速参考：禁止行为

```java
// ❌ 禁止：使用Executors创建线程池
ExecutorService executor = Executors.newFixedThreadPool(10);

// ❌ 禁止：SQL拼接
String sql = "SELECT * FROM user WHERE id = " + userId;

// ❌ 禁止：吞掉异常
try { ... } catch (Exception e) { }

// ❌ 禁止：明文存储密码
user.setPassword(rawPassword);

// ❌ 禁止：无限制查询
List<Order> orders = orderMapper.selectAll();

// ❌ 禁止：缓存无过期时间
redisTemplate.opsForValue().set(key, value);
```

## 快速参考：推荐做法

```java
// ✅ 推荐：手动创建线程池
new ThreadPoolExecutor(coreSize, maxSize, keepAlive,
    TimeUnit.SECONDS, new ArrayBlockingQueue<>(100));

// ✅ 推荐：MyBatis参数化查询
@Select("SELECT * FROM user WHERE id = #{userId}")
User selectById(@Param("userId") Long userId);

// ✅ 推荐：异常记录并处理
catch (Exception e) {
    log.error("操作失败, userId={}", userId, e);
    throw new BusinessException("操作失败");
}

// ✅ 推荐：密码BCrypt加密
user.setPassword(BCrypt.hashpw(rawPassword, BCrypt.gensalt()));

// ✅ 推荐：分页查询
PageHelper.startPage(pageNum, pageSize);
List<Order> orders = orderMapper.selectByUserId(userId);

// ✅ 推荐：设置缓存过期时间
redisTemplate.opsForValue().set(key, value, 30, TimeUnit.MINUTES);
```
