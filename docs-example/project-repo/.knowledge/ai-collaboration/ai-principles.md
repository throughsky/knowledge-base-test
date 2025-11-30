# AI 协作原则 (AI Collaboration Principles)

**版本**: 1.0
**最后更新**: 2025-11-30

---

## 概述

本文档定义了与AI编码助手协作的原则和最佳实践，帮助团队高效利用AI提升开发效率。

---

## 核心原则

### 原则一：清晰性 (Clarity)

**描述**: 明确表达意图和需求，避免模糊的描述。

**实践**:
```markdown
❌ 模糊: "写一个用户服务"
✅ 清晰: "实现一个UserService，包含以下方法：
   - createUser(CreateUserRequest): 创建用户，验证邮箱唯一性
   - getUserById(String): 根据ID查询用户
   - updateUser(String, UpdateUserRequest): 更新用户信息"
```

### 原则二：上下文 (Context)

**描述**: 提供充分的背景信息，包括技术栈、规范、约束。

**实践**:
```markdown
请为项目生成代码，上下文信息：
- 技术栈: Java 17 + Spring Boot 3.2 + MyBatis
- 编码规范: 参见 coding-conventions.md
- 数据库: PostgreSQL 15
- 现有代码结构: Controller -> Service -> Repository
```

### 原则三：结构化 (Structure)

**描述**: 使用明确的格式组织需求和指令。

**实践**:
```markdown
## 需求
创建订单功能

## 输入
- CreateOrderRequest (userId, items, address)

## 输出
- OrderResponse (id, status, totalAmount)

## 业务规则
1. 检查库存充足
2. 计算订单金额
3. 创建订单记录

## 异常处理
- 库存不足: 抛出 StockInsufficientException
```

### 原则四：分步 (Step-by-Step)

**描述**: 复杂任务分解为多个步骤，逐步完成。

**实践**:
```markdown
Step 1: 先设计数据模型
Step 2: 实现Repository层
Step 3: 实现Service层业务逻辑
Step 4: 实现Controller层API
Step 5: 编写单元测试
```

### 原则五：示例 (Example)

**描述**: 提供期望输出的示例，指导AI生成格式。

**实践**:
```markdown
请生成类似以下风格的代码：

```java
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;

    @Override
    @Transactional
    public User createUser(CreateUserRequest request) {
        // 业务逻辑
    }
}
```

---

## 协作模式

### 模式一：代码生成

**场景**: 根据设计文档生成代码

**流程**:
1. 准备SDD文档
2. 提供上下文（技术栈、规范）
3. 请求AI生成代码
4. Review生成的代码
5. 调整和完善

### 模式二：代码审查

**场景**: 让AI帮助Review代码

**Prompt示例**:
```markdown
请审查以下代码，关注：
1. 是否符合编码规范
2. 是否有潜在的Bug
3. 是否有性能问题
4. 是否有安全漏洞

[粘贴代码]
```

### 模式三：问题诊断

**场景**: 让AI帮助分析和解决问题

**Prompt示例**:
```markdown
问题描述: 用户注册时偶发性报错

错误日志:
[粘贴日志]

相关代码:
[粘贴代码]

请分析可能的原因并给出解决方案。
```

### 模式四：重构建议

**场景**: 让AI提供重构建议

**Prompt示例**:
```markdown
以下代码需要重构：
1. 降低圈复杂度
2. 提高可测试性
3. 应用合适的设计模式

[粘贴代码]

请给出重构方案和示例代码。
```

---

## 质量门禁

### AI生成代码的检查清单

- [ ] 符合项目编码规范
- [ ] 遵循分层架构
- [ ] 异常处理完善
- [ ] 日志记录合理
- [ ] 无硬编码配置
- [ ] 无安全漏洞
- [ ] 包含必要注释
- [ ] 有对应测试用例

### 禁止事项

| 禁止 | 原因 |
|------|------|
| 直接使用未Review的AI代码 | 可能存在问题 |
| 让AI访问生产环境 | 安全风险 |
| 向AI暴露敏感信息 | 数据泄露风险 |
| 完全依赖AI决策 | AI可能出错 |

---

## 效率指标

### 跟踪指标

| 指标 | 定义 | 目标 |
|------|------|------|
| AI代码采纳率 | 最终使用的AI生成代码比例 | ≥ 60% |
| 修改比例 | AI代码需要修改的比例 | ≤ 30% |
| 生成速度 | 从需求到代码的时间 | 提升 50% |

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| 1.0 | 2025-11-30 | 初始版本 | @技术负责人 |
