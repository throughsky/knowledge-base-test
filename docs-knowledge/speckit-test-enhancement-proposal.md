# SpecKit 测试环节增强专项方案

**版本**: 1.0
**创建日期**: 2025-12-01
**状态**: 草案

---

## 1. 背景与动机

### 1.1 核心洞察

基于 `test-origin-design.md` 和 `openai-native-team.md` 两份文档的分析：

| 来源 | 核心观点 |
|------|----------|
| test-origin-design.md | "测试本质上是输入-输出验证，非常适合 LLM 的逻辑推理能力" |
| openai-native-team.md | "测试作为应用程序功能真理来源的功能变得越来越重要...定义高质量测试往往是允许智能体构建功能的第一步" |

**关键结论**：在 AI 原生开发中，**测试前置**（Test-First）不再只是 TDD 的最佳实践，而是 **AI 智能体能够有效工作的前提条件**。

### 1.2 当前 SpecKit 测试能力分析

| 命令 | 当前测试相关能力 | 问题 |
|------|-----------------|------|
| `/speckit.specify` | Success Criteria（成功标准） | ❌ 过于抽象，不可直接执行 |
| `/speckit.plan` | 无显式测试规划 | ❌ 缺失测试策略 |
| `/speckit.tasks` | 可选生成测试任务 | ⚠️ 测试是"可选"而非"必须" |
| `/speckit.checklist` | 需求质量检查 | ⚠️ 不生成可执行测试 |
| `/speckit.implement` | 实现阶段可能写测试 | ❌ 测试后置，违背 TDD |

### 1.3 核心问题

当前 SpecKit 流程：

```
Spec → Plan → Tasks → Implement (含测试)
```

测试被嵌入在 Implement 阶段，这与 AI 原生开发的"测试先行"理念冲突。

### 1.4 目标流程

```
Spec (含验收场景) → Plan (含测试策略) → Test (测试先行) → Tasks → Implement (测试驱动)
```

---

## 2. AI 测试能力全景

基于 `test-origin-design.md` 的能力分析：

### 2.1 集成测试能力

| 能力 | 描述 | SpecKit 集成点 |
|------|------|----------------|
| 智能挡板 | AI 读取 OpenAPI 定义，自动生成 Mock Server | `/speckit.test` |
| 链路编排 | 读取时序图，自动生成 API 链式调用脚本 | `/speckit.test` |
| 数据生成 | 理解 Schema 和业务规则，生成测试数据 | `/speckit.test` |
| 契约测试 | 对比定义与实际流量，检测不一致 | `/speckit.test` |

### 2.2 通用测试能力

| 能力 | 描述 | SpecKit 集成点 |
|------|------|----------------|
| 单元测试生成 | 读取函数代码，生成高覆盖率测试 | `/speckit.testgen` |
| UI 自动化自愈 | 视觉识别 + 脚本自动修正 | 未来扩展 |
| 探索性测试 | AI Agent 模拟用户随机操作 | 未来扩展 |
| 根因分析 | 收集日志/Commit，分析失败原因 | `/speckit.implement` |

### 2.3 推荐落地方案对照

| 方案 | 适用场景 | SpecKit 对应 |
|------|----------|-------------|
| 方案一：基于 Spec 的自动化集成测试 | 后端微服务、API 优先 | `/speckit.test`（推荐首选） |
| 方案二：流量录制与回放 | 重构项目、不想写用例 | 未来扩展 |
| 方案三：全能型 QA Agent | AI 小组化终极目标 | `/speckit.implement` 增强 |

---

## 3. 增强方案总览

### 3.1 方案矩阵

| 方案 | 类型 | 复杂度 | 价值 | 推荐度 |
|------|------|--------|------|--------|
| 方案一 | 现有命令增强 | 低 | 中 | ⭐⭐⭐ |
| 方案二 | 新增测试命令 | 中 | 高 | ⭐⭐⭐⭐⭐ |
| 方案三 | 测试智能体集成 | 高 | 极高 | ⭐⭐⭐⭐ |

### 3.2 实施路径建议

```
阶段一（1-2周）：方案一 - 现有命令增强
    ↓
阶段二（2-3周）：方案二 - 新增测试命令
    ↓
阶段三（持续）：方案三 - 测试智能体集成
```

---

## 4. 方案一：现有命令增强（轻量级）

### 4.1 `/speckit.specify` 增强 - 测试场景规范化

#### 4.1.1 增强目标

在 spec.md 中强制要求定义可执行的验收测试场景，使需求可直接转化为测试代码。

#### 4.1.2 修改内容

**修改位置**：`User Scenarios & Testing` 章节

**新增必须项**：

```markdown
## User Scenarios & Testing（增强）

### Acceptance Test Scenarios（新增必须项）

每个用户场景必须包含可执行的验收测试定义：

| 场景ID | 场景名称 | 前置条件 | 操作步骤 | 预期结果 | 验证方式 |
|--------|----------|----------|----------|----------|----------|
| AT-001 | 用户成功充值 | 用户已登录,余额=100 | POST /deposit {amount:50} | 余额=150 | API响应+DB查询 |
| AT-002 | 充值金额非法 | 用户已登录 | POST /deposit {amount:-10} | 400错误 | API响应码 |
| AT-003 | 未登录充值 | 用户未登录 | POST /deposit {amount:50} | 401错误 | API响应码 |

**格式要求**：
- **场景ID**：AT-XXX 格式，便于追踪
- **前置条件**：必须可程序化设置（如 SQL 插入、API 调用）
- **操作步骤**：必须包含具体 API 或 UI 操作
- **预期结果**：必须可量化验证
- **验证方式**：说明如何验证结果（API 响应、DB 查询、UI 状态等）

**覆盖要求**：
- 每个功能需求至少 1 个正向场景 + 1 个异常场景
- P1 优先级需求必须覆盖边界条件
- 涉及状态变更的需求必须验证状态一致性
```

#### 4.1.3 质量检查增强

在 `/speckit.specify` 的质量验证步骤中新增：

```markdown
## Specification Quality Validation（增强）

### 测试场景质量检查

- [ ] 每个功能需求都有对应的验收测试场景
- [ ] 正向场景和异常场景比例合理（建议 1:1 到 1:2）
- [ ] 前置条件可程序化设置
- [ ] 预期结果可量化验证
- [ ] 高优先级需求覆盖边界条件
- [ ] 场景ID全局唯一且有意义
```

---

### 4.2 `/speckit.plan` 增强 - 测试策略规划

#### 4.2.1 增强目标

在 plan.md 中强制包含测试策略，明确测试金字塔、数据策略、Mock 策略。

#### 4.2.2 修改内容

**新增必须章节**：

```markdown
## Test Strategy（新增必须章节）

### 1. 测试金字塔规划

| 层级 | 类型 | 覆盖范围 | 工具 | 数量预估 | 执行时机 |
|------|------|----------|------|----------|----------|
| L1 | 单元测试 | Service层业务逻辑 | JUnit 5 + Mockito | 15-20 | 每次提交 |
| L2 | 集成测试 | API端点+数据库 | Testcontainers | 8-10 | 每次PR |
| L3 | 契约测试 | API契约一致性 | OpenAPI Validator | 5 | 每次PR |
| L4 | E2E测试 | 核心用户流程 | Playwright | 3-5 | 每日/发布前 |

### 2. 测试数据策略

| 数据类型 | 来源 | 生成方式 | 存储位置 |
|----------|------|----------|----------|
| 种子数据 | data-model.md | SQL脚本生成 | tests/fixtures/seed.sql |
| 边界数据 | 业务规则 | AI生成 | tests/fixtures/boundary.sql |
| Mock数据 | contracts/ | 基于Schema生成 | tests/mocks/ |

### 3. Mock策略

| 外部依赖 | Mock方式 | 工具 | 配置位置 |
|----------|----------|------|----------|
| BitGo API | WireMock | wiremock-standalone | tests/mocks/bitgo/ |
| 支付网关 | Mock Server | mockserver | tests/mocks/payment/ |
| 区块链节点 | Hardhat Fork | hardhat | hardhat.config.ts |

### 4. 测试优先级映射

基于 spec.md 中的用户故事优先级：

| 故事优先级 | 测试覆盖要求 | 测试类型 |
|------------|--------------|----------|
| P1 | 100% 场景覆盖 | 单元+集成+E2E |
| P2 | 核心路径覆盖 | 单元+集成 |
| P3 | 基础覆盖 | 单元 |

### 5. 测试环境要求

| 环境 | 用途 | 数据库 | 外部依赖 |
|------|------|--------|----------|
| 单元测试 | 隔离测试 | H2内存 | 全Mock |
| 集成测试 | API测试 | Testcontainers | 部分Mock |
| E2E测试 | 全链路 | 测试环境DB | 测试环境 |
```

#### 4.2.3 架构合规检查增强

在 Phase 0.5 架构合规检查中新增测试相关检查：

```markdown
### 测试策略合规检查

| 检查项 | 要求 | 检查结果 |
|--------|------|----------|
| 测试金字塔定义 | 必须定义 L1-L4 各层 | ✅/❌ |
| 测试数据策略 | 必须说明数据来源和生成方式 | ✅/❌ |
| Mock策略 | 所有外部依赖必须有Mock方案 | ✅/❌ |
| 优先级映射 | P1需求必须100%覆盖 | ✅/❌ |
```

---

### 4.3 `/speckit.tasks` 增强 - 测试任务前置

#### 4.3.1 增强目标

将测试任务从"可选"变为"必须"，并调整为测试先行的任务顺序。

#### 4.3.2 修改内容

**修改 Phase 结构**：

```markdown
### Phase Structure（修改）

- **Phase 1**: Setup（项目初始化）
  - 项目结构创建
  - 依赖配置

- **Phase 2**: Test Infrastructure（测试基础设施）⬅️ 新增必须阶段
  - 测试框架配置
  - Mock Server 搭建
  - 测试数据生成脚本
  - 测试工具类

- **Phase 3**: Contract Tests（契约测试）⬅️ 前置
  - 基于 contracts/ 生成 API 契约测试
  - 测试必须先 FAIL（红灯状态）

- **Phase 4+**: User Story Phases
  - 每个故事内部顺序：
    1. Acceptance Tests（验收测试）- 必须先 FAIL
    2. Unit Tests（单元测试）- 必须先 FAIL
    3. Implementation（实现代码）
    4. Verify Tests Pass（验证测试通过）

- **Final Phase**: Integration & Polish
  - E2E 测试
  - 性能测试（如需要）
  - 文档更新
```

**修改任务格式**：

```markdown
### Task Format（增强）

测试任务必须标注测试类型和预期状态：

- [ ] T005 [P] [US1] [TEST:Contract] Create deposit API contract test - tests/contracts/deposit.test.ts
- [ ] T006 [US1] [TEST:Unit] Create DepositService unit tests - tests/unit/deposit-service.test.ts
- [ ] T007 [US1] [IMPL] Implement DepositService - src/services/deposit-service.ts
- [ ] T008 [US1] [VERIFY] Verify all US1 tests pass

**标签说明**：
- [TEST:Contract] - 契约测试
- [TEST:Unit] - 单元测试
- [TEST:Integration] - 集成测试
- [TEST:E2E] - 端到端测试
- [IMPL] - 实现代码
- [VERIFY] - 验证测试通过
```

---

### 4.4 方案一实施清单

| 序号 | 任务 | 修改文件 | 工作量 |
|------|------|----------|--------|
| 1.1 | 增强验收测试场景格式 | speckit.specify.md | 0.5天 |
| 1.2 | 增强质量检查项 | speckit.specify.md | 0.5天 |
| 1.3 | 新增测试策略章节 | speckit.plan.md | 1天 |
| 1.4 | 增强架构合规检查 | speckit.plan.md | 0.5天 |
| 1.5 | 修改 Phase 结构 | speckit.tasks.md | 0.5天 |
| 1.6 | 增强任务格式 | speckit.tasks.md | 0.5天 |
| **总计** | | | **3.5天** |

---

## 5. 方案二：新增测试命令（推荐）

### 5.1 新增 `/speckit.test` 命令

#### 5.1.1 命令定位

基于 Spec 的自动化测试生成，对应 `test-origin-design.md` 的"方案一：基于 Spec 的自动化集成测试"。

**核心理念**：文档即测试（Docs as Tests）

#### 5.1.2 命令规范

```markdown
---
description: Generate executable tests from spec and contracts before implementation
handoffs:
  - label: Generate Tasks
    agent: speckit.tasks
    prompt: Generate implementation tasks based on tests
    send: true
  - label: Analyze Consistency
    agent: speckit.analyze
    prompt: Check test coverage against spec
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

### 1. Setup

Run `.specify/scripts/bash/check-prerequisites.sh --json --require-plan` from repo root.
Parse JSON for FEATURE_DIR, SPEC_FILE, PLAN_FILE, CONTRACTS_DIR, DATA_MODEL.

### 2. Load Context

**Required**:
- spec.md: Acceptance Test Scenarios
- plan.md: Test Strategy
- contracts/: API definitions (OpenAPI/GraphQL)

**Optional**:
- data-model.md: Entity definitions
- .knowledge/code-derived/: Existing test patterns

### 3. Knowledge Base Integration

如果知识库存在，加载测试相关知识：

a) **企业测试规范**（如存在）：
   - 读取 `enterprise-standards/standards/testing-standards.md`
   - 提取测试命名规范、覆盖率要求、工具约定

b) **仓库测试模式**（如存在）：
   - 读取 `.knowledge/code-derived/` 中的测试相关文档
   - 识别现有测试文件结构和风格
   - 复用现有测试工具类

### 4. Generate Test Structure

创建测试目录结构：

```
FEATURE_DIR/tests/
├── contracts/              # 契约测试
│   └── api.contract.test.ts
├── scenarios/              # 场景测试（基于 Acceptance Test Scenarios）
│   ├── AT-001.test.ts
│   ├── AT-002.test.ts
│   └── ...
├── unit/                   # 单元测试桩
│   └── .gitkeep
├── fixtures/               # 测试数据
│   ├── seed.sql
│   └── mocks/
│       └── {service}.mock.json
└── README.md               # 测试说明文档
```

### 5. Generate Contract Tests

基于 contracts/ 目录中的 API 定义：

a) **解析 OpenAPI/GraphQL Schema**

b) **为每个端点生成契约测试**：
   - Schema 验证测试（响应结构是否符合定义）
   - 必填字段测试（缺少必填字段是否返回 400）
   - 类型验证测试（字段类型是否正确）
   - 枚举值测试（枚举字段是否只接受定义的值）

c) **测试代码模板**：

```typescript
// contracts/deposit.contract.test.ts
import { OpenAPIValidator } from '@/test-utils';
import depositSchema from '@contracts/deposit.openapi.yaml';

describe('Deposit API Contract', () => {
  const validator = new OpenAPIValidator(depositSchema);

  describe('POST /api/v1/deposit', () => {
    it('should accept valid deposit request', async () => {
      const request = {
        amount: 100,
        currency: 'USD',
        userId: 'user-123'
      };
      expect(validator.validateRequest(request)).toBeValid();
    });

    it('should reject request missing required field: amount', async () => {
      const request = {
        currency: 'USD',
        userId: 'user-123'
      };
      expect(validator.validateRequest(request)).toHaveError('amount is required');
    });

    it('should reject invalid amount type', async () => {
      const request = {
        amount: 'not-a-number',
        currency: 'USD',
        userId: 'user-123'
      };
      expect(validator.validateRequest(request)).toHaveError('amount must be number');
    });
  });
});
```

### 6. Generate Scenario Tests

基于 spec.md 中的 Acceptance Test Scenarios：

a) **解析验收场景表格**

b) **为每个场景生成独立测试文件**：
   - 前置条件设置（Arrange）
   - 操作执行（Act）
   - 结果验证（Assert）
   - 清理（Cleanup）

c) **处理上下文传递**：
   - 识别场景间的依赖关系
   - 自动处理 Token/Session 传递
   - 自动处理 ID 引用传递

d) **测试代码模板**：

```typescript
// scenarios/AT-001.test.ts
/**
 * Acceptance Test: AT-001
 * 场景名称: 用户成功充值
 * 前置条件: 用户已登录,余额=100
 * 操作步骤: POST /deposit {amount:50}
 * 预期结果: 余额=150
 */

import { TestContext, setupUser, cleanupUser } from '@/test-utils';

describe('AT-001: 用户成功充值', () => {
  let ctx: TestContext;

  beforeEach(async () => {
    // Arrange: 设置前置条件
    ctx = await setupUser({
      balance: 100,
      status: 'active'
    });
  });

  afterEach(async () => {
    // Cleanup: 清理测试数据
    await cleanupUser(ctx.userId);
  });

  it('should increase balance after deposit', async () => {
    // Act: 执行操作
    const response = await ctx.api.post('/deposit', {
      amount: 50
    });

    // Assert: 验证结果
    expect(response.status).toBe(200);
    expect(response.body.newBalance).toBe(150);

    // 额外验证: DB 状态
    const dbBalance = await ctx.db.getUserBalance(ctx.userId);
    expect(dbBalance).toBe(150);
  });
});
```

### 7. Generate Test Fixtures

a) **生成种子数据** (seed.sql)：
   - 基于 data-model.md 生成表结构对应的测试数据
   - 覆盖各种状态和边界条件
   - 数据间保持引用完整性

b) **生成 Mock 配置**：
   - 基于 plan.md 中的 Mock 策略
   - 为每个外部依赖生成默认 Mock 响应
   - 包含正常响应和异常响应

c) **Mock 配置模板**：

```json
// fixtures/mocks/bitgo.mock.json
{
  "service": "BitGo API",
  "baseUrl": "https://api.bitgo.com",
  "endpoints": [
    {
      "method": "POST",
      "path": "/v2/wallet/*/tx/build",
      "responses": {
        "success": {
          "status": 200,
          "body": { "txHex": "0x...", "fee": 1000 }
        },
        "insufficient_funds": {
          "status": 400,
          "body": { "error": "Insufficient funds" }
        },
        "service_unavailable": {
          "status": 503,
          "body": { "error": "Service temporarily unavailable" }
        }
      }
    }
  ]
}
```

### 8. Generate Test Documentation

生成 tests/README.md：

```markdown
# Feature Tests: [Feature Name]

## 测试概览

| 类型 | 数量 | 状态 |
|------|------|------|
| 契约测试 | X | 🔴 待实现 |
| 场景测试 | Y | 🔴 待实现 |
| 单元测试 | - | ⏳ 实现时生成 |

## 运行测试

```bash
# 运行所有测试
npm test

# 运行契约测试
npm run test:contract

# 运行特定场景
npm run test:scenario -- --grep "AT-001"
```

## 测试数据

- 种子数据: `fixtures/seed.sql`
- Mock 配置: `fixtures/mocks/`

## 场景覆盖

| 场景ID | 名称 | 优先级 | 状态 |
|--------|------|--------|------|
| AT-001 | 用户成功充值 | P1 | 🔴 |
| AT-002 | 充值金额非法 | P1 | 🔴 |
```

### 9. Validate Tests

a) **语法验证**：
   - 确保生成的测试代码语法正确
   - 确保导入路径正确

b) **执行验证**：
   - 运行生成的测试
   - 确认测试状态为 **FAIL**（红灯）
   - 如果测试 PASS，发出警告："测试在实现前通过，可能测试无效"

c) **覆盖验证**：
   - 检查每个 Acceptance Test Scenario 都有对应测试
   - 检查每个 API 端点都有契约测试
   - 输出覆盖率报告

### 10. Output Report

```markdown
## Test Generation Report

**生成时间**: [YYYY-MM-DD HH:MM]
**功能**: [Feature Name]

### 生成统计

| 类型 | 生成数量 | 文件 |
|------|----------|------|
| 契约测试 | X | tests/contracts/*.test.ts |
| 场景测试 | Y | tests/scenarios/AT-*.test.ts |
| 种子数据 | 1 | tests/fixtures/seed.sql |
| Mock配置 | Z | tests/fixtures/mocks/*.json |

### 测试状态

- ✅ 语法验证通过
- ✅ 所有测试为 FAIL 状态（红灯）
- ✅ 场景覆盖率: 100%
- ✅ 端点覆盖率: 100%

### 下一步

1. 运行 `/speckit.tasks` 生成实现任务
2. 按 TDD 流程实现功能
3. 确保所有测试变为 PASS（绿灯）
```

## Key Rules

- **测试必须先失败**：生成的测试在实现前必须是红灯状态
- **一个场景一个文件**：便于追踪和维护
- **测试独立性**：每个测试可独立运行，不依赖执行顺序
- **数据隔离**：测试间不共享状态，使用 beforeEach/afterEach 管理
- **幂等性**：测试可重复运行，结果一致
```

---

### 5.2 新增 `/speckit.testgen` 命令

#### 5.2.1 命令定位

为已实现的代码生成测试用例（后置补测试场景），用于遗留代码或快速迭代场景。

#### 5.2.2 命令规范

```markdown
---
description: Generate tests for existing code implementation
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

### 1. Input Analysis

解析用户输入，确定测试生成范围：

- 目标文件或目录路径
- 测试类型（unit/integration/all）
- 覆盖率目标

### 2. Load Context

**Required**:
- 目标代码文件

**Optional**:
- spec.md: 用于对齐业务意图
- contracts/: 用于验证 API 一致性
- .knowledge/code-derived/: 现有测试模式

### 3. Code Analysis

分析目标代码：

a) **结构分析**：
   - 识别类/函数/方法
   - 识别公共 API
   - 识别依赖关系

b) **逻辑分析**：
   - 识别分支条件
   - 识别边界条件
   - 识别异常路径

c) **复杂度评估**：
   - 圈复杂度计算
   - 测试用例数量预估

### 4. Generate Unit Tests

为每个公共方法生成测试：

a) **正向测试**：
   - 典型输入 → 预期输出
   - 基于方法签名和文档推断

b) **异常测试**：
   - null/undefined 输入
   - 类型错误输入
   - 边界值输入

c) **边界测试**：
   - 空集合
   - 单元素集合
   - 大数据量
   - 数值边界（0, -1, MAX_INT）

### 5. Spec Alignment Check

如果 spec.md 存在：

a) **对齐检查**：
   - 检查实现是否覆盖所有需求
   - 检查是否有未在 spec 中定义的行为

b) **补充建议**：
   - 如果发现未覆盖的需求，建议补充测试
   - 如果发现未定义的行为，建议更新 spec

### 6. Output

生成测试文件到对应位置：

```
src/services/deposit-service.ts
  → tests/unit/deposit-service.test.ts

src/controllers/deposit-controller.ts
  → tests/unit/deposit-controller.test.ts
```

### 7. Coverage Report

```markdown
## Test Generation Report

**目标**: [文件/目录路径]
**生成时间**: [YYYY-MM-DD HH:MM]

### 生成统计

| 文件 | 方法数 | 测试用例数 | 预估覆盖率 |
|------|--------|------------|------------|
| deposit-service.ts | 5 | 15 | 85% |
| deposit-controller.ts | 3 | 9 | 80% |

### Spec 对齐

| 需求ID | 需求描述 | 覆盖状态 |
|--------|----------|----------|
| FR-001 | 用户充值 | ✅ 已覆盖 |
| FR-002 | 余额查询 | ⚠️ 部分覆盖 |

### 建议

1. 补充 FR-002 的边界测试
2. 考虑添加并发测试
```

## Key Rules

- **不修改现有代码**：只生成测试，不修改实现
- **保持测试风格一致**：参考现有测试的命名和结构
- **标注生成来源**：在测试文件头部注明是自动生成
- **运行验证**：生成后运行测试，确保语法正确
```

---

### 5.3 与 `/speckit.test` 的区别

| 维度 | /speckit.test | /speckit.testgen |
|------|---------------|------------------|
| **时机** | 实现前（TDD） | 实现后（补测试） |
| **输入** | Spec + Contracts | 代码 + Spec（可选） |
| **目的** | 定义行为期望 | 验证现有实现 |
| **测试初始状态** | FAIL（红灯） | PASS（绿灯） |
| **适用场景** | 新功能开发 | 遗留代码、快速迭代 |
| **质量** | 高（基于规范） | 中（基于实现） |

---

### 5.4 方案二实施清单

| 序号 | 任务 | 产出 | 工作量 |
|------|------|------|--------|
| 2.1 | 设计 /speckit.test 命令规范 | speckit.test.md | 1天 |
| 2.2 | 实现契约测试生成 | 契约测试模板 | 1.5天 |
| 2.3 | 实现场景测试生成 | 场景测试模板 | 1.5天 |
| 2.4 | 实现测试数据生成 | fixtures 生成逻辑 | 1天 |
| 2.5 | 实现测试验证逻辑 | 红灯状态检查 | 0.5天 |
| 2.6 | 设计 /speckit.testgen 命令规范 | speckit.testgen.md | 0.5天 |
| 2.7 | 实现代码分析逻辑 | 代码解析器 | 1天 |
| 2.8 | 实现测试生成逻辑 | 测试生成器 | 1天 |
| **总计** | | | **8天** |

---

## 6. 方案三：测试智能体集成（高级）

### 6.1 设计理念

基于 `openai-native-team.md` 的"全能型 QA Agent"理念，将测试深度集成到实现流程中。

**核心思想**：
- 测试不是独立阶段，而是贯穿整个实现过程
- AI 智能体能够自主运行测试、分析失败、建议修复
- 测试反馈驱动实现迭代

### 6.2 `/speckit.implement` 增强 - 测试驱动实现循环

#### 6.2.1 修改内容

在 `/speckit.implement` 中新增测试驱动循环：

```markdown
## Test-Driven Implementation Loop（新增）

### 1. 任务执行前检查

对于每个功能实现任务：

```text
BEFORE executing implementation task:
    1. Check if corresponding test exists
    2. IF test not exists:
        - Generate test using /speckit.test logic
        - Verify test is in FAIL state
    3. IF test exists but PASS:
        - WARNING: "Test passes before implementation, may be invalid"
        - Require manual confirmation to proceed
    4. Record initial test state
```

### 2. 测试驱动实现流程

```text
FOR each implementation task:

    Phase 1: Red (确保红灯)
    -------------------------
    - Run related tests
    - Verify FAIL state
    - IF PASS: Stop and investigate

    Phase 2: Green (实现功能)
    -------------------------
    - Implement the code
    - Run tests after each significant change
    - Continue until all tests PASS

    Phase 3: Refactor (重构优化)
    -------------------------
    - IF tests PASS:
        - Review code quality
        - Refactor if needed
        - Verify tests still PASS

    Phase 4: Verify (最终验证)
    -------------------------
    - Run full test suite
    - Check coverage metrics
    - Mark task complete only if all pass
```

### 3. 测试失败处理

当测试持续失败时：

```text
IF test fails after implementation:

    1. Analyze failure
       - Parse error message
       - Identify failing assertion
       - Trace to code location

    2. Categorize failure
       a) Implementation bug → Fix code
       b) Test bug → Fix test (require justification)
       c) Spec ambiguity → Trigger /speckit.clarify
       d) Missing dependency → Add to tasks

    3. Record decision
       - Document why test was modified (if applicable)
       - Link to clarification (if triggered)

    4. Retry
       - Re-run test
       - Repeat until pass or escalate
```

### 4. 测试覆盖率门禁

```text
BEFORE marking task complete:

    1. Run coverage analysis
    2. Check against plan.md thresholds:
       - P1 requirements: 100% coverage
       - P2 requirements: 80% coverage
       - P3 requirements: 60% coverage

    3. IF coverage insufficient:
       - Generate additional tests
       - Re-run implementation loop

    4. IF coverage met:
       - Mark task complete
       - Update tasks.md
```
```

#### 6.2.2 测试反馈集成

```markdown
## Test Feedback Integration（新增）

### 1. 实时测试反馈

在实现过程中持续运行测试：

```text
ON code change:
    1. Identify affected tests (impact analysis)
    2. Run affected tests only (fast feedback)
    3. Display results inline:
       - ✅ TestName: PASS
       - ❌ TestName: FAIL - Expected X, got Y
    4. IF any FAIL:
       - Pause implementation
       - Analyze and fix before continuing
```

### 2. 智能测试选择

基于代码变更自动选择测试：

```text
GIVEN code change in file F:

    1. Direct tests: Tests that import F
    2. Indirect tests: Tests that import modules depending on F
    3. Integration tests: Tests covering the API that uses F

    Priority:
    - Always run: Direct tests
    - Run if time permits: Indirect tests
    - Run on PR: All tests
```

### 3. 失败根因分析

当测试失败时，自动分析根因：

```text
ON test failure:

    1. Collect context:
       - Error message
       - Stack trace
       - Recent code changes (git diff)
       - Related test history

    2. Analyze with AI:
       - Compare expected vs actual
       - Identify likely root cause
       - Suggest fix

    3. Present to user:
       "Test AT-001 failed: Expected balance=150, got balance=100

        Likely cause: DepositService.deposit() not updating balance

        Suggested fix:
        ```java
        // In DepositService.java line 45
        user.setBalance(user.getBalance() + amount);
        // Missing: userRepository.save(user);
        ```

        Apply fix? [Y/n]"
```
```

### 6.3 测试影响分析

#### 6.3.1 代码变更测试映射

```markdown
## Change Impact Analysis（新增）

### 1. 构建依赖图

在项目初始化时构建：

```text
dependency_graph = {
    "src/services/deposit-service.ts": {
        "depends_on": ["src/repositories/user-repository.ts"],
        "depended_by": ["src/controllers/deposit-controller.ts"],
        "tests": [
            "tests/unit/deposit-service.test.ts",
            "tests/scenarios/AT-001.test.ts"
        ]
    },
    ...
}
```

### 2. 变更影响计算

```text
GIVEN changed_files:

    affected_tests = []

    FOR each file in changed_files:
        # 直接相关测试
        affected_tests += dependency_graph[file].tests

        # 间接相关测试（依赖此文件的模块的测试）
        FOR each dependent in dependency_graph[file].depended_by:
            affected_tests += dependency_graph[dependent].tests

    RETURN deduplicate(affected_tests)
```

### 3. 测试优先级排序

```text
GIVEN affected_tests:

    priority_1 = []  # 必须运行
    priority_2 = []  # 推荐运行
    priority_3 = []  # 可选运行

    FOR each test in affected_tests:
        IF test is unit test for changed file:
            priority_1.append(test)
        ELIF test is integration test:
            priority_2.append(test)
        ELSE:
            priority_3.append(test)

    RETURN {
        "must_run": priority_1,
        "should_run": priority_2,
        "may_run": priority_3
    }
```

### 4. 缺失测试检测

```text
ON code change:

    FOR each changed_file:
        IF dependency_graph[changed_file].tests is empty:
            WARNING: "File {changed_file} has no associated tests"
            SUGGEST: "Run /speckit.testgen {changed_file} to generate tests"
```
```

### 6.4 方案三实施清单

| 序号 | 任务 | 产出 | 工作量 |
|------|------|------|--------|
| 3.1 | 设计测试驱动实现循环 | 流程规范 | 1天 |
| 3.2 | 实现测试前置检查 | 检查逻辑 | 1天 |
| 3.3 | 实现测试反馈集成 | 反馈机制 | 1.5天 |
| 3.4 | 实现失败根因分析 | 分析逻辑 | 2天 |
| 3.5 | 实现依赖图构建 | 依赖分析器 | 1.5天 |
| 3.6 | 实现影响分析 | 影响计算器 | 1天 |
| 3.7 | 实现缺失测试检测 | 检测逻辑 | 0.5天 |
| 3.8 | 集成测试与文档 | 测试用例 | 1.5天 |
| **总计** | | | **10天** |

---

## 7. 知识库集成

### 7.1 测试相关知识库内容

```yaml
L0_企业级:
  enterprise-standards/standards/testing-standards.md:
    内容:
      - 测试命名规范
      - 覆盖率要求
      - 测试工具标准
      - 测试数据规范
    应用: 所有测试命令

L1_项目级:
  architecture/test-infrastructure.md:
    内容:
      - 项目测试框架配置
      - CI/CD 测试流程
      - 测试环境配置
    应用: /speckit.test, /speckit.implement

  standards/test-patterns.md:
    内容:
      - 项目测试模式
      - Mock 策略
      - 测试数据管理
    应用: 所有测试命令

L2_仓库级:
  .knowledge/code-derived/overview.md:
    内容:
      - 模块依赖关系
    应用: 测试影响分析

  .knowledge/code-derived/{module}.md:
    内容:
      - 模块测试模式
      - 现有测试示例
    应用: /speckit.test, /speckit.testgen
```

### 7.2 知识库加载逻辑

```markdown
## 测试命令知识库加载

### /speckit.test 知识库加载

1. **加载企业测试规范**（如存在）：
   - 提取测试命名规范
   - 提取覆盖率要求
   - 提取测试工具约定

2. **加载仓库测试模式**（如存在）：
   - 识别现有测试文件结构
   - 识别测试工具类
   - 复用现有 Mock 配置

3. **应用规范**：
   - 生成的测试遵循企业命名规范
   - 生成的测试使用项目测试框架
   - 生成的测试复用现有工具类

### /speckit.testgen 知识库加载

1. **加载现有测试模式**：
   - 分析现有测试文件结构
   - 提取测试风格（describe/it vs test）
   - 提取断言风格（expect vs assert）

2. **保持一致性**：
   - 生成的测试与现有测试风格一致
   - 使用相同的测试工具和断言库
```

---

## 8. 实施路线图

### 8.1 总体时间线

```
Week 1-2: 方案一（现有命令增强）
    ├── /speckit.specify 增强
    ├── /speckit.plan 增强
    └── /speckit.tasks 增强

Week 3-4: 方案二（新增测试命令）
    ├── /speckit.test 命令
    └── /speckit.testgen 命令

Week 5-6: 方案三（测试智能体集成）
    ├── /speckit.implement 增强
    ├── 测试反馈集成
    └── 影响分析

Week 7: 集成测试与文档
    ├── 端到端测试
    ├── 文档完善
    └── 团队培训
```

### 8.2 里程碑

| 里程碑 | 时间 | 交付物 | 验收标准 |
|--------|------|--------|----------|
| M1 | Week 2 | 现有命令增强 | spec/plan/tasks 包含测试相关内容 |
| M2 | Week 4 | 测试生成命令 | 能从 spec 生成可执行测试 |
| M3 | Week 6 | 测试智能体 | 实现过程中自动运行测试 |
| M4 | Week 7 | 完整方案 | 端到端测试通过，文档完善 |

### 8.3 依赖关系

```
方案一 → 方案二 → 方案三
  │         │         │
  └─────────┴─────────┴── 可独立交付，但后续方案依赖前序方案
```

---

## 9. 风险与缓解

| 风险 | 影响 | 概率 | 缓解措施 |
|------|------|------|----------|
| 测试生成质量不高 | 测试无效 | 中 | 强制红灯验证，人工审查机制 |
| 测试执行时间长 | 开发效率下降 | 中 | 智能测试选择，并行执行 |
| 测试维护成本高 | 长期负担 | 中 | 自动更新机制，测试与 spec 联动 |
| 团队不适应 TDD | 推行困难 | 高 | 渐进式推行，提供 testgen 作为过渡 |

---

## 10. 成功指标

| 指标 | 基线 | 目标 | 测量方式 |
|------|------|------|----------|
| 测试覆盖率 | 40% | 80% | 代码覆盖率工具 |
| 缺陷逃逸率 | 15% | 5% | 生产环境缺陷/总缺陷 |
| 测试编写时间 | 30% 开发时间 | 10% 开发时间 | 时间统计 |
| 回归测试时间 | 2小时 | 30分钟 | CI 流水线 |
| 测试先行率 | 10% | 70% | 测试创建时间 vs 代码创建时间 |

---

## 附录 A：测试类型定义

| 类型 | 范围 | 依赖 | 执行时间 | 示例 |
|------|------|------|----------|------|
| 单元测试 | 单个函数/方法 | Mock 所有依赖 | <100ms | 业务逻辑验证 |
| 集成测试 | 多个组件 | 真实 DB，Mock 外部 | <5s | API + DB |
| 契约测试 | API 接口 | 无 | <1s | Schema 验证 |
| E2E 测试 | 全链路 | 测试环境 | <30s | 用户流程 |

---

## 附录 B：测试命名规范

```
单元测试: {ClassName}.{methodName}.{scenario}.test.ts
  示例: DepositService.deposit.validAmount.test.ts

场景测试: AT-{XXX}.{scenarioName}.test.ts
  示例: AT-001.userSuccessDeposit.test.ts

契约测试: {endpoint}.contract.test.ts
  示例: deposit.contract.test.ts
```

---

## 附录 C：测试数据规范

```sql
-- 测试数据命名规范
-- 前缀: test_
-- 格式: test_{entity}_{scenario}_{sequence}

INSERT INTO users (id, name, balance) VALUES
  ('test_user_normal_001', 'Normal User', 100),
  ('test_user_vip_001', 'VIP User', 10000),
  ('test_user_zero_001', 'Zero Balance User', 0),
  ('test_user_negative_001', 'Negative Balance User', -100);
```

---

**文档结束**
