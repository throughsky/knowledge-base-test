# TypeScript 编码规范 (TypeScript Coding Standards)

**版本**: 2.0
**最后更新**: 2025-11-30
**适用版本**: TypeScript 5.0+
**状态**: 已发布

---

## 概述

本文档定义了企业TypeScript项目的编码规范。

<!-- AI-CONTEXT
TypeScript编码规范是L0层强制要求。
AI生成TypeScript/React代码时必须遵循以下规范。
关键检查点：类型安全、命名规范、模块组织、React最佳实践
-->

---

## 1. 类型系统 (Type System)

### 严格模式

```json
// tsconfig.json - 必须开启严格模式
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noImplicitReturns": true,
    "noUncheckedIndexedAccess": true
  }
}
```

### 类型定义

```typescript
// ✅ 优先使用 interface 定义对象类型
interface User {
  id: string;
  name: string;
  email: string;
  role: UserRole;
  createdAt: Date;
}

// ✅ 使用 type 定义联合类型、交叉类型
type UserRole = 'admin' | 'manager' | 'user';
type UserWithOrders = User & { orders: Order[] };

// ✅ 使用 enum 定义有限的常量集合
enum OrderStatus {
  PENDING = 'PENDING',
  CONFIRMED = 'CONFIRMED',
  SHIPPED = 'SHIPPED',
  DELIVERED = 'DELIVERED',
}

// ❌ 避免使用 any
function processData(data: any) { }  // 禁止

// ✅ 使用 unknown 代替 any
function processData(data: unknown) {
  if (typeof data === 'string') {
    // 类型收窄后使用
  }
}
```

### 泛型使用

```typescript
// ✅ 有意义的泛型命名
interface ApiResponse<TData, TError = Error> {
  data: TData | null;
  error: TError | null;
  loading: boolean;
}

// ✅ 泛型约束
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}
```

---

## 2. 命名约定 (Naming Conventions)

| 类型 | 规范 | 示例 |
|------|------|------|
| **变量/函数** | camelCase | `userName`, `getUserById` |
| **类/接口/类型** | PascalCase | `UserService`, `ApiResponse` |
| **常量** | UPPER_SNAKE_CASE | `MAX_RETRIES`, `API_BASE_URL` |
| **枚举值** | UPPER_SNAKE_CASE | `OrderStatus.PENDING` |
| **文件名** | kebab-case | `user-service.ts`, `api-client.ts` |
| **React组件文件** | PascalCase | `UserProfile.tsx`, `OrderList.tsx` |

### 特殊命名

```typescript
// 布尔值
const isLoading = true;
const hasPermission = false;
const canEdit = true;

// 事件处理函数：handle + 事件名
const handleClick = () => { };
const handleSubmit = () => { };

// 异步函数：动词 + 名词
async function fetchUsers() { }
async function createOrder() { }

// React Hooks
const [users, setUsers] = useState<User[]>([]);
const { data, loading } = useQuery();
```

---

## 3. 模块组织 (Module Organization)

### 导入顺序

```typescript
// 1. 外部库
import React, { useState, useEffect } from 'react';
import { useQuery } from '@tanstack/react-query';
import axios from 'axios';

// 2. 内部模块（绝对路径）
import { UserService } from '@/services/user-service';
import { Button } from '@/components/ui/button';

// 3. 相对路径模块
import { UserCard } from './UserCard';
import { useUserContext } from './context';

// 4. 类型导入
import type { User, CreateUserRequest } from '@/types/user';

// 5. 样式
import styles from './UserList.module.css';
```

### 导出规范

```typescript
// ✅ 命名导出（推荐）
export function createUser(data: CreateUserRequest): Promise<User> { }
export const UserService = { createUser, getUser };

// ✅ 类型导出
export type { User, CreateUserRequest };
export interface ApiError { }

// ⚠️ 默认导出仅用于React组件和页面
export default function UserProfile() { }
```

---

## 4. React 规范

### 组件结构

```tsx
import React, { useState, useCallback, useMemo } from 'react';
import type { FC } from 'react';

// 类型定义
interface UserProfileProps {
  userId: string;
  onUpdate?: (user: User) => void;
}

// 组件定义
export const UserProfile: FC<UserProfileProps> = ({ userId, onUpdate }) => {
  // 1. Hooks
  const [isEditing, setIsEditing] = useState(false);
  const { data: user, loading } = useUser(userId);

  // 2. 计算值
  const displayName = useMemo(() =>
    user ? `${user.firstName} ${user.lastName}` : '',
    [user]
  );

  // 3. 事件处理
  const handleEdit = useCallback(() => {
    setIsEditing(true);
  }, []);

  // 4. 早期返回
  if (loading) return <LoadingSpinner />;
  if (!user) return <NotFound />;

  // 5. 渲染
  return (
    <div className="user-profile">
      <h1>{displayName}</h1>
      <button onClick={handleEdit}>Edit</button>
    </div>
  );
};
```

### Hooks 规则

```typescript
// ✅ 自定义Hook以use开头
function useUser(userId: string) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchUser(userId).then(setUser).finally(() => setLoading(false));
  }, [userId]);

  return { user, loading };
}

// ✅ 正确的依赖数组
useEffect(() => {
  fetchData(id);
}, [id]); // 包含所有依赖

// ❌ 错误：缺少依赖
useEffect(() => {
  fetchData(id);
}, []); // 缺少 id
```

---

## 5. 错误处理 (Error Handling)

### 类型安全的错误处理

```typescript
// 定义错误类型
class ApiError extends Error {
  constructor(
    message: string,
    public code: string,
    public status: number
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

// Result 类型模式
type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E };

async function fetchUser(id: string): Promise<Result<User, ApiError>> {
  try {
    const response = await api.get(`/users/${id}`);
    return { success: true, data: response.data };
  } catch (error) {
    return {
      success: false,
      error: new ApiError('Failed to fetch user', 'USER_FETCH_ERROR', 500)
    };
  }
}

// 使用
const result = await fetchUser(id);
if (result.success) {
  console.log(result.data.name);
} else {
  console.error(result.error.code);
}
```

---

## 6. 异步处理 (Async Patterns)

```typescript
// ✅ async/await（推荐）
async function getUsers(): Promise<User[]> {
  const response = await api.get('/users');
  return response.data;
}

// ✅ 并行请求
async function getUserWithOrders(userId: string) {
  const [user, orders] = await Promise.all([
    fetchUser(userId),
    fetchOrders(userId),
  ]);
  return { user, orders };
}

// ✅ 错误处理
async function fetchWithRetry<T>(
  fn: () => Promise<T>,
  retries = 3
): Promise<T> {
  for (let i = 0; i < retries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (i === retries - 1) throw error;
      await delay(Math.pow(2, i) * 1000); // 指数退避
    }
  }
  throw new Error('Unreachable');
}
```

---

## 7. ESLint 配置

```javascript
// .eslintrc.js
module.exports = {
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:@typescript-eslint/recommended-requiring-type-checking',
    'plugin:react/recommended',
    'plugin:react-hooks/recommended',
  ],
  rules: {
    '@typescript-eslint/no-explicit-any': 'error',
    '@typescript-eslint/explicit-function-return-type': 'warn',
    '@typescript-eslint/no-unused-vars': 'error',
    'react-hooks/rules-of-hooks': 'error',
    'react-hooks/exhaustive-deps': 'warn',
  },
};
```

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| 2.0 | 2025-11-30 | 增加React规范、AI上下文 | @架构委员会 |
| 1.0 | 2025-01-01 | 初始版本 | @架构委员会 |
