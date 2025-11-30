#!/bin/bash
# 知识聚合主脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
CACHE_DIR="$ROOT_DIR/aggregation/cache"
REPORTS_DIR="$ROOT_DIR/aggregation/reports"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 参数解析
MODE="incremental"  # incremental | full
REPOS="all"
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --mode)
            MODE="$2"
            shift 2
            ;;
        --repos)
            REPOS="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

log_info "开始知识聚合..."
log_info "模式: $MODE"
log_info "仓库: $REPOS"

# 确保目录存在
mkdir -p "$CACHE_DIR"
mkdir -p "$REPORTS_DIR"

# Step 1: 收集各仓库 context.md
log_info "Step 1: 收集仓库知识..."

REPOS_DIR="$ROOT_DIR/repos"
CHANGES_FILE="$CACHE_DIR/changes.json"

echo '{"changes": []}' > "$CHANGES_FILE"

for repo_dir in "$REPOS_DIR"/*/; do
    repo_name=$(basename "$repo_dir")
    context_file="$repo_dir/.knowledge/context.md"

    if [[ -f "$context_file" ]]; then
        log_info "  收集: $repo_name"

        # 检查是否有变更 (与上次聚合对比)
        cache_file="$CACHE_DIR/$repo_name.md"

        if [[ -f "$cache_file" ]]; then
            if ! diff -q "$context_file" "$cache_file" > /dev/null 2>&1; then
                log_info "    ↳ 检测到变更"
                # 这里可以调用 AI 分析变更
            fi
        else
            log_info "    ↳ 新仓库"
        fi

        # 更新缓存
        cp "$context_file" "$cache_file"
    else
        log_warn "  跳过: $repo_name (无 context.md)"
    fi
done

# Step 2: 分析变更影响
log_info "Step 2: 分析变更影响..."

# 这里调用 AI 进行分析
# 实际实现可以使用 Claude API 或其他方式

if [[ "$DRY_RUN" == true ]]; then
    log_info "  [DRY RUN] 跳过 AI 分析"
else
    log_info "  调用 AI 分析变更..."
    # claude-code 或 API 调用
    # 输出到 $REPORTS_DIR/$(date +%Y-%m-%d).md
fi

# Step 3: 生成报告
log_info "Step 3: 生成聚合报告..."

REPORT_FILE="$REPORTS_DIR/$(date +%Y-%m-%d).md"

cat > "$REPORT_FILE" << EOF
# 知识聚合报告

**日期**: $(date +%Y-%m-%d)
**模式**: $MODE

## 扫描仓库

| 仓库 | 状态 | 变更 |
|------|------|------|
EOF

for repo_dir in "$REPOS_DIR"/*/; do
    repo_name=$(basename "$repo_dir")
    if [[ -f "$repo_dir/.knowledge/context.md" ]]; then
        echo "| $repo_name | ✅ | - |" >> "$REPORT_FILE"
    else
        echo "| $repo_name | ⚠️ 无context.md | - |" >> "$REPORT_FILE"
    fi
done

cat >> "$REPORT_FILE" << EOF

## 建议更新

(AI 分析结果将在此处)

## 下一步

- [ ] 审核变更建议
- [ ] 更新项目文档
- [ ] 通知相关团队
EOF

log_info "报告已生成: $REPORT_FILE"

# Step 4: 创建 PR (如果有变更)
if [[ "$DRY_RUN" == true ]]; then
    log_info "Step 4: [DRY RUN] 跳过 PR 创建"
else
    log_info "Step 4: 检查是否需要创建 PR..."
    # git diff --quiet || (创建 PR 逻辑)
fi

log_info "聚合完成!"
