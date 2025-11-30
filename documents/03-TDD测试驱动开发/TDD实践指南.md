---
title: TDD 测试驱动开发实践指南
created: 2024-01-01
updated: 2024-01-01
version: 1.0
status: 已发布
tags: [TDD, 测试驱动, 实践指南]
---

# TDD 测试驱动开发实践指南

> 测试驱动开发的完整工作流程和最佳实践

## 1. TDD 核心理念

### 1.1 什么是 TDD

**测试驱动开发 (Test-Driven Development)** 是一种开发方法论，遵循**红灯-绿灯-重构**的循环：

1. **红灯**: 编写一个失败的测试
2. **绿灯**: 编写最简单的代码让测试通过
3. **重构**: 优化代码结构，保持测试通过

### 1.2 TDD 的好处

- ✅ **更好的设计**: 测试驱动出更好的代码结构
- ✅ **更高的质量**: 天然具有高测试覆盖率
- ✅ **更好的文档**: 测试本身就是使用文档
- ✅ **更少的 Bug**: 提前发现问题
- ✅ **信心重构**: 可以放心重构，测试会保护你

---

## 2. TDD 工作流程

### 2.1 三定律

1. **定律一**: 在编写失败测试之前，不要写任何产品代码
2. **定律二**: 只编写刚好失败的测试，编译失败也算失败
3. **定律三**: 只编写刚好通过测试的产品代码

### 2.2 开发循环

```
┌──────────────────────┐
│  1. 编写测试 (Red)   │
└──────────┬───────────┘
           │
┌──────────▼───────────┐
│ 2. 运行测试 (失败)    │
└──────────┬───────────┘
           │
┌──────────▼───────────┐
│ 3. 编写实现 (Green)  │
└──────────┬───────────┘
           │
┌──────────▼───────────┐
│ 4. 运行测试 (通过)    │
└──────────┬───────────┘
           │
┌──────────▼───────────┐
│  5. 重构 (Refactor)  │
└──────────┬───────────┘
           │
┌──────────▼───────────┐
│ 6. 重复循环          │
└──────────┬───────────┘
           │
           └─→ 回到步骤 1
```

---

## 3. 测试金字塔

### 3.1 分层结构

```
        测试数量
            ↑
    E2E测试   |  少量 (10%)
            ↓
  集成测试    |  中等 (30%)
            ↓
  单元测试    |  大量 (60%)
            ↓
```

### 3.2 各层职责

| 层级 | 测试内容 | 运行速度 | 维护成本 | 工具示例 |
|------|----------|----------|----------|----------|
| **单元测试** | 单个函数/类 | ⭐⭐⭐⭐⭐ | 低 | Jest, JUnit |
| **集成测试** | 模块间协作 | ⭐⭐⭐⭐ | 中等 | Supertest |
| **E2E 测试** | 完整用户流程 | ⭐⭐ | 高 | Cypress, Selenium |

---

## 4. 单元测试最佳实践

### 4.1 FIRST 原则

- **F**ast: 测试要快速
- **I**ndependent: 测试之间独立
- **R**epeatable: 可重复运行
- **S**elf-validating: 自我验证
- **T**imely: 及时编写

### 4.2 AAA 模式

```typescript
it('should calculate total price correctly', () => {
  // Arrange (准备)
  const cart = new ShoppingCart();
  cart.addItem({ price: 10, quantity: 2 });
  cart.addItem({ price: 20, quantity: 1 });

  // Act (执行)
  const total = cart.calculateTotal();

  // Assert (断言)
  expect(total).toBe(40);
});
```

### 4.3 测试命名规范

```typescript
// 推荐: 描述性命名
describe('ShoppingCart', () => {
  describe('calculateTotal', () => {
    it('should return 0 for empty cart', () => {
      // ...
    });

    it('should calculate total with multiple items', () => {
      // ...
    });

    it('should apply discount when available', () => {
      // ...
    });
  });
});
```

### 4.4 避免测试坏味道

❌ **过度测试**
```typescript
// 测试私有方法 (应该通过公有方法测试)
it('should update internal state', () => {
  expect((component as any).internalState).toBe('updated');
});
```

❌ **测试含混**
```typescript
// 测试多个行为
it('should create and update user', () => {
  // 创建
  // 更新
  // 验证
});
```

✅ **测试单一行为**
```typescript
it('should create user successfully', () => { /* ... */ });
it('should update user profile', () => { /* ... */ });
```

---

## 5. Mock 和 Stub

### 5.1 何时使用 Mock

- 外部服务调用 (数据库、API)
- 当前时间、随机数
- 文件系统操作
- 副作用操作

### 5.2 使用示例

```typescript
// 不使用 Mock (慢, 不稳定)
it('should save user to database', async () => {
  const userRepository = new UserRepository();
  const user = new User('test@example.com');

  await userRepository.save(user);

  const savedUser = await userRepository.findByEmail('test@example.com');
  expect(savedUser.email).toBe('test@example.com');
});

// 使用 Mock (快, 稳定)
it('should save user', async () => {
  const mockRepository = {
    save: jest.fn(),
    findByEmail: jest.fn().mockResolvedValue(
      new User('test@example.com')
    )
  };

  const userService = new UserService(mockRepository);

  await userService.createUser('test@example.com');

  expect(mockRepository.save).toHaveBeenCalledWith(
    expect.objectContaining({ email: 'test@example.com' })
  );
});
```

### 5.3 Mock 最佳实践

✅ **推荐**
```typescript
// 使用 jest mock
jest.mock('./email-service');

it('should send welcome email', () => {
  const emailService = new EmailService();
  emailService.send = jest.fn();

  userService.createUser('test@example.com');

  expect(emailService.send).toHaveBeenCalledWith(
    'test@example.com',
    'Welcome!'
  );
});
```

❌ **避免**
```typescript
// 过度 Mock
it('should work', () => {
  const mockA = jest.fn();
  const mockB = jest.fn();
  const mockC = jest.fn();
  // ... 大量 mock
});
```

---

## 6. TDD 实践示例

### 6.1 示例: 购物车功能

#### 步骤 1: 编写失败的测试

```typescript
// shopping-cart.test.ts
import { ShoppingCart } from './shopping-cart';

describe('ShoppingCart', () => {
  it('should create an empty cart', () => {
    const cart = new ShoppingCart();
    expect(cart.items.length).toBe(0);
    expect(cart.totalPrice).toBe(0);
  });
});
```

运行测试: **RED** ❌

#### 步骤 2: 编写最简单的实现

```typescript
// shopping-cart.ts
export class ShoppingCart {
  items: any[] = [];
  totalPrice: number = 0;
}
```

运行测试: **GREEN** ✅

#### 步骤 3: 添加更多测试

```typescript
// shopping-cart.test.ts
it('should add an item to the cart', () => {
  const cart = new ShoppingCart();

  cart.addItem({ id: 1, name: 'Apple', price: 10, quantity: 2 });

  expect(cart.items.length).toBe(1);
});
```

运行测试: **RED** ❌

#### 步骤 4: 实现 addItem 方法

```typescript
// shopping-cart.ts
export class ShoppingCart {
  items: any[] = [];
  totalPrice: number = 0;

  addItem(item: any): void {
    this.items.push(item);
    this.totalPrice += item.price * item.quantity;
  }
}
```

运行测试: **GREEN** ✅

#### 步骤 5: 重构

```typescript
// Extract interface
interface CartItem {
  id: number;
  name: string;
  price: number;
  quantity: number;
}

export class ShoppingCart {
  items: CartItem[] = [];
  totalPrice: number = 0;

  addItem(item: CartItem): void {
    this.items.push(item);
    this.recalculateTotal();
  }

  private recalculateTotal(): void {
    this.totalPrice = this.items.reduce(
      (total, item) => total + item.price * item.quantity,
      0
    );
  }
}
```

运行测试: **GREEN** ✅

---

## 7. 在项目中实施 TDD

### 7.1 项目结构

```
src/
├── feature/
│   ├── feature.service.ts
│   ├── feature.service.test.ts      # 单元测试
│   └── feature.controller.test.ts    # 集成测试
└── e2e/
    └── feature.e2e.test.ts           # E2E 测试
```

### 7.2 开发流程

```
1. 从用户故事开始
   ↓
2. 编写失败的 E2E 测试
   ↓
3. 编写失败的集成测试
   ↓
4. TDD 循环 (单元测试 → 实现 → 重构)
   ↓
5. 运行集成测试
   ↓
6. 运行 E2E 测试
   ↓
7. Code Review 和合并
```

### 7.3 团队实践

#### Daily TDD

- 每天开始工作前运行所有测试 ✅
- 提交代码前确保所有测试通过 ✅
- 修复失败的测试优先于新功能 ✅

#### 测试覆盖率门禁

```json
{
  "coverageThreshold": {
    "global": {
      "branches": 80,
      "functions": 80,
      "lines": 80,
      "statements": 80
    }
  }
}
```

---

## 8. 常见挑战和解决方案

### 8.1 "测试代码太多"

**问题**: 测试代码量超过产品代码

**解决方案**:
- 这是正常的, 测试代码是资产不是负担
- 关注测试的价值, 不是数量
- 使用测试生成工具辅助 (AI 生成测试)

### 8.2 "开始很慢"

**问题**: TDD 初期开发速度变慢

**解决方案**:
- 坚持练习, 熟练后速度会提升
- 从简单功能开始
- 使用快捷键和代码模板

### 8.3 "遗留代码"

**问题**: 已有代码没有测试

**解决方案**:
- 对新代码使用 TDD
- 为关键路径代码补充测试
- 重构时添加测试
- Michael Feathers 的《修改代码的艺术》

### 8.4 "与 AI 协作"

**问题**: 如何让 AI 帮助 TDD

**解决方案**:
```typescript
// 1. 先写测试
describe('Feature', () => {
  it('should do something', () => {
    // TODO
  });
});

// 2. 让 AI 根据测试生成实现
// Prompt: "Please implement the minimum code to make this test pass"

// 3. 运行测试

// 4. 让 AI 帮助重构
// Prompt: "Please refactor this code while keeping the test passing"
```

---

## 9. 工具和资源

### 9.1 测试框架

| 语言 | 单元测试 | 集成测试 | E2E 测试 |
|------|----------|----------|----------|
| JavaScript/TypeScript | Jest | Supertest | Cypress |
| Java | JUnit | MockMvc | Selenium |
| Python | pytest | pytest-django | Playwright |

### 9.2 测试工具

- **测试覆盖率**: Istanbul, JaCoCo
- **Mock 框架**: Sinon, Mockito
- **测试数据**: Faker, Factory Bot

### 9.3 学习资源

- **书籍**:
  - 《Test-Driven Development: By Example》 - Kent Beck
  - 《Growing Object-Oriented Software, Guided by Tests》 - Freeman & Pryce
  - 《单元测试的艺术》

- **在线资源**:
  - Jest 官方文档
  - TDD Kata 练习

---

## 10. 度量与改进

### 10.1 关键指标

| 指标 | 目标 | 测量方法 |
|------|------|----------|
| 测试覆盖率 | ≥ 80% | CI 自动统计 |
| 测试通过率 | 100% | CI 检查 |
| 测试执行时间 | < 5 分钟 | CI 报告 |
| 缺陷逃逸率 | < 5% | 生产问题统计 |

### 10.2 回顾和改进

- **每周**: 检查测试覆盖率趋势
- **每月**: 回顾测试策略有效性
- **每季度**: 调整测试标准和工具

---

## 附录

### A. 相关文档
- [SDD 软件设计规范](../02-SDD软件设计规范/SDD规范模板.md)
- [开发章程](../01-开发章程/开发章程.md)
- [测试策略](../01-开发章程/测试策略.md)

### B. 快速参考卡

```
TDD 记住:
✓ 先写测试
✓ 测试要失败 (红)
✓ 写最小实现 (绿)
✓ 重构代码
✓ 重复循环
```
