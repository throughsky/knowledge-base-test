# Code-Derived Knowledge Integration Example

本文档展示如何将现有的 `codewiki/` 目录内容集成到五层知识架构中。

## 1. 现有 codewiki 结构映射

### 1.1 原始结构 → L3.5 结构

```
原始 codewiki/                    →    .knowledge/code-derived/
├── overview.md                   →    overview/repository-overview.md
├── metadata.json                 →    metadata.json
├── module_tree.json              →    overview/module-tree.json
├── custodian-core.md             →    modules/custodian-core/module-doc.md
├── custodian-network.md          →    modules/custodian-network/module-doc.md
└── ...                           →    modules/{module}/module-doc.md
```

### 1.2 字段映射

| codewiki 字段 | L3.5 对应位置 | 用途 |
|--------------|--------------|------|
| `metadata.total_components` | `metadata.json` | 统计信息 |
| `metadata.leaf_nodes` | `metadata.json` | 最小单元计数 |
| `module_tree.children` | `overview/module-tree.json` | 模块层级 |
| 各模块 `.md` 文件 | `modules/{name}/module-doc.md` | 模块文档 |

## 2. 集成脚本示例

### 2.1 迁移脚本 (migrate-codewiki.sh)

```bash
#!/bin/bash
# 将现有 codewiki 迁移到 L3.5 结构

CODEWIKI_DIR="./codewiki"
TARGET_DIR="./.knowledge/code-derived"

# 创建目录结构
mkdir -p "$TARGET_DIR/overview"
mkdir -p "$TARGET_DIR/modules"
mkdir -p "$TARGET_DIR/cross-cutting"
mkdir -p "$TARGET_DIR/ai-index"

# 迁移概览文档
if [ -f "$CODEWIKI_DIR/overview.md" ]; then
    cp "$CODEWIKI_DIR/overview.md" "$TARGET_DIR/overview/repository-overview.md"
    echo "✅ Migrated overview.md"
fi

# 迁移元数据
if [ -f "$CODEWIKI_DIR/metadata.json" ]; then
    cp "$CODEWIKI_DIR/metadata.json" "$TARGET_DIR/metadata.json"
    echo "✅ Migrated metadata.json"
fi

# 迁移模块树
if [ -f "$CODEWIKI_DIR/module_tree.json" ]; then
    cp "$CODEWIKI_DIR/module_tree.json" "$TARGET_DIR/overview/module-tree.json"
    echo "✅ Migrated module_tree.json"
fi

# 迁移各模块文档
for md_file in "$CODEWIKI_DIR"/*.md; do
    filename=$(basename "$md_file")
    if [ "$filename" != "overview.md" ]; then
        module_name="${filename%.md}"
        mkdir -p "$TARGET_DIR/modules/$module_name"
        cp "$md_file" "$TARGET_DIR/modules/$module_name/module-doc.md"
        echo "✅ Migrated $filename → modules/$module_name/module-doc.md"
    fi
done

echo "🎉 Migration complete!"
```

### 2.2 增量更新脚本 (update-code-derived.sh)

```bash
#!/bin/bash
# 增量更新代码衍生知识

# 获取变更的文件
CHANGED_FILES=$(git diff --name-only HEAD~1)

# 识别影响的模块
affected_modules=""
for file in $CHANGED_FILES; do
    # 从文件路径提取模块名
    module=$(echo "$file" | cut -d'/' -f2)
    if [ -n "$module" ]; then
        affected_modules="$affected_modules $module"
    fi
done

# 去重
affected_modules=$(echo "$affected_modules" | tr ' ' '\n' | sort -u)

# 重新生成受影响模块的文档
for module in $affected_modules; do
    echo "🔄 Regenerating docs for module: $module"
    # 调用 AI 生成工具
    # codewiki-gen --module "$module" --output ".knowledge/code-derived/modules/$module"
done

# 更新元数据
echo "📊 Updating metadata..."
# update-metadata.sh

echo "✅ Incremental update complete!"
```

## 3. AI 上下文聚合示例

### 3.1 生成 ai-context.md 的关键内容

从 L3.5 提取的内容应包含：

```markdown
## 代码实际架构 (L3.5)

### 仓库概览
[从 overview/repository-overview.md 提取]

### 核心模块
| 模块 | 职责 | 组件数 |
|------|------|--------|
| custodian-core | 核心托管逻辑 | 156 |
| custodian-network | 网络通信 | 89 |

### 关键入口点
- HTTP API: /api/v1/...
- gRPC: custodian.proto

### 数据流概览
[从 cross-cutting/data-flow.md 提取关键路径]
```

### 3.2 与 L3 规范对比

```markdown
## 规范符合性分析

### ✅ 符合的规范
- 分层架构: Controller → Service → Repository ✓
- 命名约定: UpperCamelCase 类名 ✓

### ⚠️ 偏差发现
| 规范要求 | 实际情况 | 位置 | 优先级 |
|----------|----------|------|--------|
| 禁止硬编码配置 | 发现3处硬编码 | config.ts:45, db.ts:12 | 高 |
| 使用结构化日志 | 部分使用 console.log | auth.ts:78 | 中 |

### 💡 改进建议
1. 将硬编码配置迁移到环境变量
2. 统一使用 Logger 模块
```

## 4. CI/CD 集成

### 4.1 GitHub Actions 示例

```yaml
# .github/workflows/update-code-derived.yml
name: Update Code-Derived Knowledge

on:
  push:
    branches: [main, develop]
    paths:
      - 'src/**'
      - 'lib/**'

jobs:
  update-docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 2  # 需要比较前一个 commit

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install codewiki generator
        run: npm install -g codewiki-gen

      - name: Generate incremental updates
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
        run: |
          ./scripts/update-code-derived.sh

      - name: Commit updates
        uses: stefanzweifel/git-auto-commit-action@v5
        with:
          commit_message: "docs(code-derived): auto-update from code changes"
          file_pattern: ".knowledge/code-derived/**"
```

### 4.2 定期全量更新

```yaml
# .github/workflows/full-codewiki-update.yml
name: Full Code-Derived Knowledge Update

on:
  schedule:
    - cron: '0 2 * * 0'  # 每周日凌晨2点
  workflow_dispatch:      # 手动触发

jobs:
  full-update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Full regeneration
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
        run: |
          codewiki-gen --full --output .knowledge/code-derived

      - name: Compliance check
        run: |
          # 与 L3 规范对比
          compliance-checker \
            --spec .knowledge/implementation/coding/coding-conventions.md \
            --actual .knowledge/code-derived/overview/repository-overview.md \
            --output .knowledge/code-derived/compliance-report.md

      - name: Commit updates
        uses: stefanzweifel/git-auto-commit-action@v5
        with:
          commit_message: "docs(code-derived): weekly full update"
```

## 5. 查询接口设计

### 5.1 AI 查询提示 (query-hints.md)

```markdown
# AI 查询提示

## 快速定位

### 按功能查询
- "认证相关代码" → 查看 modules/auth/module-doc.md
- "数据库操作" → 查看 modules/db/module-doc.md
- "API 端点列表" → 查看 cross-cutting/api-summary.md

### 按问题类型
- "性能问题" → 查看各模块的 complexity 指标
- "安全审计" → 查看 cross-cutting/security-patterns.md
- "依赖分析" → 查看 overview/module-tree.json

### 按代码位置
- 使用 `{file}:{line}` 格式引用具体代码
- 模块文档中的组件表包含位置信息

## 推荐查询顺序
1. 先查 overview/repository-overview.md 了解整体
2. 根据需要深入 modules/{name}/module-doc.md
3. 跨模块问题查看 cross-cutting/ 下的文档
```

## 6. 最佳实践

### 6.1 保持同步
- 每次代码 PR 后自动触发增量更新
- 定期（每周）全量重新生成，校正漂移
- 使用 git hash 标记生成时的代码版本

### 6.2 质量控制
- AI 生成的文档需要人工抽检
- 关键模块的文档变更需要 review
- 建立准确性反馈机制

### 6.3 集成优先级
- 先迁移 overview 和核心模块
- 逐步扩展到所有模块
- 最后建立 AI 索引和查询接口

---

**参考**: 详见主设计文档 [五层知识架构设计方案](../../../five-layer-knowledge-design.md) 第 4.6 节
