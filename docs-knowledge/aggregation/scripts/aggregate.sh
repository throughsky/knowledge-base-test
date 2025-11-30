#!/bin/bash
# 知识聚合主脚本
# 支持 context.md 和 code-derived 两种知识源的聚合

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
CACHE_DIR="$ROOT_DIR/aggregation/cache"
REPORTS_DIR="$ROOT_DIR/aggregation/reports"
CODE_DERIVED_CACHE="$CACHE_DIR/code-derived"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# 参数解析
MODE="incremental"  # incremental | full
REPOS="all"
DRY_RUN=false
SKIP_CODE_DERIVED=false
COLLECT_ALL_MODULES=false

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --mode <mode>         聚合模式: incremental (默认) | full"
    echo "  --repos <repos>       仓库列表: all (默认) | repo1,repo2"
    echo "  --dry-run             仅预览，不执行实际操作"
    echo "  --skip-code-derived   跳过 code-derived 文档收集"
    echo "  --all-modules         收集所有模块文档 (默认只收集核心文件)"
    echo "  -h, --help            显示帮助信息"
    exit 0
}

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
        --skip-code-derived)
            SKIP_CODE_DERIVED=true
            shift
            ;;
        --all-modules)
            COLLECT_ALL_MODULES=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo ""
echo "========================================"
echo "       知识聚合系统 v2.0"
echo "========================================"
echo ""
log_info "开始知识聚合..."
log_info "模式: $MODE"
log_info "仓库: $REPOS"
log_info "收集 code-derived: $([ "$SKIP_CODE_DERIVED" = true ] && echo '否' || echo '是')"
echo ""

# 确保目录存在
mkdir -p "$CACHE_DIR"
mkdir -p "$REPORTS_DIR"
mkdir -p "$CODE_DERIVED_CACHE"

REPOS_DIR="$ROOT_DIR/repos"

# ============================================
# Step 1: 收集 context.md 变更
# ============================================
log_step "Step 1: 收集 context.md 变更..."

CONTEXT_CHANGES_FILE="$CACHE_DIR/context-changes.json"
echo '{"timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'", "changes": []}' > "$CONTEXT_CHANGES_FILE"

context_changed_count=0

for repo_dir in "$REPOS_DIR"/*/; do
    repo_name=$(basename "$repo_dir")
    context_file="$repo_dir/.knowledge/context.md"

    if [[ -f "$context_file" ]]; then
        log_info "  检查: $repo_name/context.md"

        # 检查是否有变更 (与上次聚合对比)
        cache_file="$CACHE_DIR/context/$repo_name.md"
        mkdir -p "$CACHE_DIR/context"

        if [[ -f "$cache_file" ]]; then
            if ! diff -q "$context_file" "$cache_file" > /dev/null 2>&1; then
                log_info "    ↳ ✓ 检测到变更"
                ((context_changed_count++))
            else
                log_info "    ↳ 无变更"
            fi
        else
            log_info "    ↳ ✓ 新仓库"
            ((context_changed_count++))
        fi

        # 更新缓存
        if [[ "$DRY_RUN" != true ]]; then
            cp "$context_file" "$cache_file"
        fi
    else
        log_warn "  跳过: $repo_name (无 context.md)"
    fi
done

log_info "  共检测到 $context_changed_count 个 context.md 变更"
echo ""

# ============================================
# Step 2: 收集 code-derived 文档
# ============================================
if [[ "$SKIP_CODE_DERIVED" != true ]]; then
    log_step "Step 2: 收集 code-derived 文档..."

    code_derived_count=0

    for repo_dir in "$REPOS_DIR"/*/; do
        repo_name=$(basename "$repo_dir")
        code_derived_dir="$repo_dir/.knowledge/code-derived"

        if [[ -d "$code_derived_dir" ]]; then
            log_info "  收集: $repo_name/code-derived/"

            # 创建仓库缓存目录
            repo_cache_dir="$CODE_DERIVED_CACHE/$repo_name"
            mkdir -p "$repo_cache_dir"

            # 收集核心文件
            for file in "metadata.json" "overview.md" "module_tree.json"; do
                if [[ -f "$code_derived_dir/$file" ]]; then
                    if [[ "$DRY_RUN" != true ]]; then
                        cp "$code_derived_dir/$file" "$repo_cache_dir/"
                    fi
                    log_info "    ↳ $file"
                fi
            done

            # 可选: 收集所有模块文档
            if [[ "$COLLECT_ALL_MODULES" = true ]]; then
                for module_file in "$code_derived_dir"/*.md; do
                    if [[ -f "$module_file" && "$(basename "$module_file")" != "overview.md" ]]; then
                        if [[ "$DRY_RUN" != true ]]; then
                            cp "$module_file" "$repo_cache_dir/"
                        fi
                        log_info "    ↳ $(basename "$module_file")"
                    fi
                done
            fi

            ((code_derived_count++))
        else
            log_warn "  跳过: $repo_name (无 code-derived/)"
        fi
    done

    log_info "  共收集 $code_derived_count 个仓库的 code-derived 文档"
else
    log_info "Step 2: 跳过 code-derived 收集 (--skip-code-derived)"
fi
echo ""

# ============================================
# Step 3: 分析变更影响
# ============================================
log_step "Step 3: 分析变更影响..."

if [[ "$DRY_RUN" == true ]]; then
    log_info "  [DRY RUN] 跳过 AI 分析"
else
    log_info "  准备 AI 分析输入..."

    # 生成分析输入
    ANALYSIS_INPUT="$CACHE_DIR/analysis-input.md"

    cat > "$ANALYSIS_INPUT" << EOF
# 知识聚合分析输入

## 生成时间
$(date -u +%Y-%m-%dT%H:%M:%SZ)

## Context 变更摘要
检测到 $context_changed_count 个仓库的 context.md 变更

## Code-Derived 文档统计
EOF

    # 添加 code-derived 统计
    for repo_cache in "$CODE_DERIVED_CACHE"/*/; do
        if [[ -d "$repo_cache" ]]; then
            repo_name=$(basename "$repo_cache")
            echo "" >> "$ANALYSIS_INPUT"
            echo "### $repo_name" >> "$ANALYSIS_INPUT"

            if [[ -f "$repo_cache/metadata.json" ]]; then
                echo '```json' >> "$ANALYSIS_INPUT"
                cat "$repo_cache/metadata.json" >> "$ANALYSIS_INPUT"
                echo '```' >> "$ANALYSIS_INPUT"
            fi
        fi
    done

    log_info "  分析输入已生成: $ANALYSIS_INPUT"
    log_info "  调用 AI 进行分析... (需要手动执行或通过 CI/CD)"
fi
echo ""

# ============================================
# Step 4: 生成技术洞察
# ============================================
log_step "Step 4: 生成技术洞察..."

INSIGHTS_FILE="$ROOT_DIR/aggregated/technical-insights.md"
mkdir -p "$(dirname "$INSIGHTS_FILE")"

if [[ "$DRY_RUN" == true ]]; then
    log_info "  [DRY RUN] 跳过洞察生成"
else
    # 生成基础洞察框架
    cat > "$INSIGHTS_FILE" << EOF
# 技术洞察报告

**生成时间**: $(date +%Y-%m-%d)
**聚合模式**: $MODE

## 仓库概览

| 仓库 | context.md | code-derived | 组件数 | 模块数 |
|------|------------|--------------|--------|--------|
EOF

    # 从 metadata.json 提取统计信息
    for repo_cache in "$CODE_DERIVED_CACHE"/*/; do
        if [[ -d "$repo_cache" ]]; then
            repo_name=$(basename "$repo_cache")
            has_context="✅"
            has_code_derived="✅"
            components="-"
            modules="-"

            if [[ -f "$repo_cache/metadata.json" ]]; then
                # 提取统计信息 (需要 jq)
                if command -v jq &> /dev/null; then
                    components=$(jq -r '.statistics.total_components // "-"' "$repo_cache/metadata.json")
                    modules=$(jq -r '.files_generated | length' "$repo_cache/metadata.json")
                fi
            fi

            echo "| $repo_name | $has_context | $has_code_derived | $components | $modules |" >> "$INSIGHTS_FILE"
        fi
    done

    cat >> "$INSIGHTS_FILE" << EOF

## 跨仓库依赖分析

(待 AI 分析生成)

## 技术栈汇总

(待 AI 分析生成)

## API 全景

(待 AI 分析生成)

## 架构模式识别

(待 AI 分析生成)

---

> 此报告由知识聚合系统自动生成，完整分析需要 AI 处理
EOF

    log_info "  基础洞察已生成: $INSIGHTS_FILE"
fi
echo ""

# ============================================
# Step 5: 生成聚合报告
# ============================================
log_step "Step 5: 生成聚合报告..."

REPORT_FILE="$REPORTS_DIR/$(date +%Y-%m-%d).md"

cat > "$REPORT_FILE" << EOF
# 知识聚合报告

**日期**: $(date +%Y-%m-%d)
**模式**: $MODE
**Dry Run**: $DRY_RUN

## 执行摘要

- Context 变更数: $context_changed_count
- Code-derived 收集: $([ "$SKIP_CODE_DERIVED" = true ] && echo '跳过' || echo '完成')

## 仓库扫描结果

| 仓库 | context.md | code-derived | 状态 |
|------|------------|--------------|------|
EOF

for repo_dir in "$REPOS_DIR"/*/; do
    repo_name=$(basename "$repo_dir")
    has_context="❌"
    has_code_derived="❌"
    status="⚠️"

    if [[ -f "$repo_dir/.knowledge/context.md" ]]; then
        has_context="✅"
    fi

    if [[ -d "$repo_dir/.knowledge/code-derived" ]]; then
        has_code_derived="✅"
    fi

    if [[ "$has_context" == "✅" ]]; then
        status="✅ 正常"
    fi

    echo "| $repo_name | $has_context | $has_code_derived | $status |" >> "$REPORT_FILE"
done

cat >> "$REPORT_FILE" << EOF

## Code-Derived 详情

EOF

for repo_cache in "$CODE_DERIVED_CACHE"/*/; do
    if [[ -d "$repo_cache" ]]; then
        repo_name=$(basename "$repo_cache")
        echo "### $repo_name" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"

        if [[ -f "$repo_cache/metadata.json" ]]; then
            echo "**生成信息**:" >> "$REPORT_FILE"
            echo '```json' >> "$REPORT_FILE"
            cat "$repo_cache/metadata.json" >> "$REPORT_FILE"
            echo '```' >> "$REPORT_FILE"
        fi

        echo "" >> "$REPORT_FILE"
        echo "**收集的文件**:" >> "$REPORT_FILE"
        for file in "$repo_cache"/*; do
            if [[ -f "$file" ]]; then
                echo "- $(basename "$file")" >> "$REPORT_FILE"
            fi
        done
        echo "" >> "$REPORT_FILE"
    fi
done

cat >> "$REPORT_FILE" << EOF

## 下一步

- [ ] 审核变更建议
- [ ] 运行 AI 分析生成完整洞察
- [ ] 更新项目文档
- [ ] 通知相关团队

---

> 🤖 此报告由知识聚合系统自动生成
EOF

log_info "报告已生成: $REPORT_FILE"
echo ""

# ============================================
# Step 6: 创建 PR (如果有变更)
# ============================================
if [[ "$DRY_RUN" == true ]]; then
    log_step "Step 6: [DRY RUN] 跳过 PR 创建"
else
    log_step "Step 6: 检查是否需要创建 PR..."

    if git diff --quiet 2>/dev/null; then
        log_info "  无变更，跳过 PR 创建"
    else
        log_info "  检测到变更，可创建 PR"
        log_info "  运行: git add . && git commit -m 'docs: 知识库聚合更新'"
    fi
fi
echo ""

echo "========================================"
log_info "聚合完成!"
echo "========================================"
echo ""
echo "输出文件:"
echo "  - 聚合报告: $REPORT_FILE"
echo "  - 技术洞察: $INSIGHTS_FILE"
echo "  - 缓存目录: $CACHE_DIR"
echo ""
