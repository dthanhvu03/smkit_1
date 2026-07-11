#!/usr/bin/env bash
# Pre-merge gate — kiểm tra trước khi merge PR vào main.
# Exit 0 = PASS (hoặc PASS với warning), Exit 1 = FAIL blocker
#
# Usage:
#   .cursor/bootstrap/pre-merge-check.sh
#   .cursor/bootstrap/pre-merge-check.sh -b feat/GD0-025-nav-group
#   .cursor/bootstrap/pre-merge-check.sh -t TASK-GD0-027
#   .cursor/bootstrap/pre-merge-check.sh --pr   # tạo PR nếu gh đã login
#
# Ref: sixmen-orchestrator SKILL.md · pre-push gate · validate-artifacts.sh

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT" || exit 1

BRANCH="$(git branch --show-current)"
BASE_REMOTE="github"
BASE_BRANCH="main"
TASK_ID=""
CREATE_PR=false
RUN_PEST=true

while [[ $# -gt 0 ]]; do
    case "$1" in
        -b|--branch) BRANCH="$2"; shift 2 ;;
        -t|--task|-TaskId) TASK_ID="$2"; shift 2 ;;
        --base) BASE_BRANCH="$2"; shift 2 ;;
        --no-pest) RUN_PEST=false; shift ;;
        --pr) CREATE_PR=true; shift ;;
        -h|--help)
            sed -n '2,12p' "$0"
            exit 0
            ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

failures=()
warnings=()

section() { echo ""; echo "━━ $1 ━━"; }

# ── 1. Sync remote ──────────────────────────────────────────────
section "1. Git sync"
if git remote get-url "$BASE_REMOTE" >/dev/null 2>&1; then
    git fetch "$BASE_REMOTE" "$BASE_BRANCH" 2>/dev/null || warnings+=("git fetch $BASE_REMOTE/$BASE_BRANCH thất bại — dùng cache local")
    BASE_REF="$BASE_REMOTE/$BASE_BRANCH"
else
    warnings+=("Remote '$BASE_REMOTE' không có — so sánh với local $BASE_BRANCH")
    BASE_REF="$BASE_BRANCH"
fi

if ! git rev-parse --verify "$BASE_REF" >/dev/null 2>&1; then
    failures+=("Base ref '$BASE_REF' không tồn tại")
fi

if ! git rev-parse --verify "$BRANCH" >/dev/null 2>&1; then
    failures+=("Branch '$BRANCH' không tồn tại")
fi

if [ ${#failures[@]} -eq 0 ]; then
    AHEAD=$(git rev-list --count "$BASE_REF".."$BRANCH" 2>/dev/null || echo "?")
    BEHIND=$(git rev-list --count "$BRANCH".."$BASE_REF" 2>/dev/null || echo "?")
    echo "  Branch:  $BRANCH"
    echo "  Base:    $BASE_REF"
    echo "  Ahead:   $AHEAD commit(s)"
    echo "  Behind:  $BEHIND commit(s)"

    if [ "$BEHIND" != "0" ] && [ "$BEHIND" != "?" ]; then
        failures+=("Branch behind $BASE_BRANCH $BEHIND commit — sync trước PR: bash .cursor/bootstrap/sync-main-into-branch.sh")
    fi

    echo ""
    echo "  Commits ahead of main:"
    git log --oneline "$BASE_REF".."$BRANCH" 2>/dev/null | sed 's/^/    /' || true

    # Commit đã có trên main nhưng vẫn nằm trên branch → lịch sử trùng (ERR-030)
    CHERRY_OUT=$(git cherry "$BASE_REF" "$BRANCH" 2>/dev/null || true)
    if [ -n "$CHERRY_OUT" ]; then
        UPSTREAM=$(printf '%s\n' "$CHERRY_OUT" | grep -c '^-' || true)
        DELTA=$(printf '%s\n' "$CHERRY_OUT" | grep -c '^+' || true)
        echo ""
        echo "  Cherry: $DELTA commit delta · $UPSTREAM patch đã có trên $BASE_BRANCH"
        if [ "${UPSTREAM:-0}" -gt 0 ] && [ "${DELTA:-0}" -gt 0 ]; then
            warnings+=("$UPSTREAM commit trên branch trùng main — PR dễ conflict. Cân nhắc branch mới từ main + cherry-pick $DELTA commit delta (Cách B)")
        fi
    fi

    # Dry-run merge — phát hiện conflict trước khi mở PR (GitHub 'Can't automatically merge')
    MERGE_BASE=$(git merge-base "$BRANCH" "$BASE_REF" 2>/dev/null || true)
    if [ -n "$MERGE_BASE" ]; then
        MT_OUT=$(git merge-tree "$MERGE_BASE" "$BRANCH" "$BASE_REF" 2>/dev/null || true)
        if echo "$MT_OUT" | grep -qE 'changed in both|<<<<<<<'; then
            CONFLICT_FILES=$(echo "$MT_OUT" | awk '/^changed in both/{p=1; next} p && /^  our/{print $3; p=0}' | sort -u)
            echo ""
            echo "  ❌ Merge conflict (dry-run):"
            echo "$CONFLICT_FILES" | sed 's/^/    /'
            failures+=("Merge conflict với $BASE_BRANCH — resolve trước PR (sync-main-into-branch.sh) hoặc branch mới + cherry-pick delta")
        else
            echo ""
            echo "  ✅ Merge dry-run: không conflict"
        fi
    fi

    CORE_FILES=$(git diff --name-only "$BASE_REF".."$BRANCH" 2>/dev/null \
        | grep -v '^lang/vendor/' | grep -v '^lang/vi\.json$' | wc -l)
    VENDOR_LANG=$(git diff --name-only "$BASE_REF".."$BRANCH" 2>/dev/null \
        | grep -c '^lang/vendor/' || true)
    echo ""
    echo "  Diff: $CORE_FILES file core + $VENDOR_LANG file lang/vendor"

    if [ "$VENDOR_LANG" -gt 100 ]; then
        warnings+=("lang/vendor có $VENDOR_LANG file — chỉ cần vi cho prod, cân nhắc prune sau merge")
    fi
fi

# ── 2. Local CI gate ────────────────────────────────────────────
section "2. Local CI gate"

if [ -x vendor/bin/pint ]; then
    _pint_cache="$(mktemp -t pint-premerge.XXXXXX 2>/dev/null || echo /tmp/pint-premerge.cache)"
    if ./vendor/bin/pint --test --cache-file="$_pint_cache" >/dev/null 2>&1; then
        echo "  ✅ Pint"
    else
        echo "  ❌ Pint FAIL → ./vendor/bin/pint"
        failures+=("Pint style chưa sạch")
    fi
    rm -f "$_pint_cache"
else
    warnings+=("vendor/bin/pint không có — chạy composer install")
fi

if [ -f scripts/architecture-lint.sh ]; then
    if bash scripts/architecture-lint.sh >/dev/null 2>&1; then
        echo "  ✅ architecture-lint"
    else
        echo "  ❌ architecture-lint FAIL"
        failures+=("architecture-lint FAIL")
    fi
fi

if $RUN_PEST; then
    if [ -x vendor/bin/pest ] || [ -f vendor/bin/pest ]; then
        if docker compose ps --status running app 2>/dev/null | grep -q app; then
            if docker compose exec -T app php artisan test --compact >/dev/null 2>&1; then
                echo "  ✅ Pest (docker)"
            else
                echo "  ❌ Pest FAIL (docker)"
                failures+=("Pest FAIL — chạy: docker compose exec app php artisan test")
            fi
        elif php artisan test --compact >/dev/null 2>&1; then
            echo "  ✅ Pest (local)"
        else
            echo "  ❌ Pest FAIL (local)"
            failures+=("Pest FAIL — chạy: php artisan test")
        fi
    else
        warnings+=("Pest không có — bỏ qua test")
    fi
else
    echo "  ⏭  Pest skipped (--no-pest)"
fi

# ── 3. Artifact gate (optional) ─────────────────────────────────
if [ -n "$TASK_ID" ]; then
    section "3. Artifact gate ($TASK_ID)"
    if [ -f .cursor/bootstrap/validate-artifacts.sh ]; then
        if bash .cursor/bootstrap/validate-artifacts.sh -t "$TASK_ID" -s >/dev/null 2>&1; then
            echo "  ✅ validate-artifacts -Strict"
        else
            echo "  ❌ validate-artifacts FAIL"
            failures+=("Artifact $TASK_ID chưa đủ gate (chạy: validate-artifacts.sh -t $TASK_ID -s)")
        fi
    fi

    GATE_FILE=""
    if TASK_DIR_RESOLVED="$(bash .cursor/bootstrap/resolve-artifact-dir.sh "$TASK_ID" 2>/dev/null)"; then
        GATE_FILE="$TASK_DIR_RESOLVED/00-gate-status.md"
    fi
    if [ -z "$GATE_FILE" ] || [ ! -f "$GATE_FILE" ]; then
        GATE_FILE="artifacts/$TASK_ID/00-gate-status.md"
    fi
    if [ -f "$GATE_FILE" ]; then
        if grep -qi 'qa_gate.*PASS\|Manual test.*PASS\|7/7 TC' "$GATE_FILE"; then
            echo "  ✅ QA gate trong 00-gate-status.md"
        else
            warnings+=("QA gate chưa PASS trong $GATE_FILE")
        fi
        if grep -q '✅ DONE\|DONE' "$GATE_FILE"; then
            echo "  ✅ Task status DONE"
        else
            warnings+=("Task chưa đánh dấu DONE trong gate-status")
        fi
    fi
fi

# ── 4. GitHub CI + PR (optional) ────────────────────────────────
section "4. GitHub"

GH=""
for candidate in gh "$HOME/.local/bin/gh"; do
    if command -v "$candidate" >/dev/null 2>&1; then
        GH="$candidate"
        break
    fi
done

if [ -n "$GH" ] && $GH auth status >/dev/null 2>&1; then
    echo "  ✅ gh CLI authenticated"
    REMOTE_URL=$(git remote get-url "$BASE_REMOTE" 2>/dev/null || echo "")
    if echo "$REMOTE_URL" | grep -q 'github.com'; then
        REPO=$(echo "$REMOTE_URL" | sed -E 's#.*github\.com[:/]([^/]+/[^/.]+).*#\1#' | sed 's/\.git$//')
        OPEN_PR=$($GH pr list --repo "$REPO" --head "$BRANCH" --state open --json number,url --jq '.[0].url' 2>/dev/null || echo "")
        if [ -n "$OPEN_PR" ] && [ "$OPEN_PR" != "null" ]; then
            echo "  PR mở: $OPEN_PR"
            $GH pr checks "$OPEN_PR" 2>/dev/null | sed 's/^/    /' || warnings+=("Không đọc được PR checks")
        elif $CREATE_PR; then
            echo "  Đang tạo PR..."
            $GH pr create --repo "$REPO" --base "$BASE_BRANCH" --head "$BRANCH" \
                --title "feat: $BRANCH" \
                --body "Auto-created by pre-merge-check.sh — cập nhật mô tả trước khi merge."
            echo "  ✅ PR created"
        else
            warnings+=("Chưa có PR mở — chạy với --pr để tạo")
        fi
    fi
else
    warnings+=("gh chưa login — chạy: gh auth login (hoặc cài ~/.local/bin/gh)")
    REMOTE_URL=$(git remote get-url "$BASE_REMOTE" 2>/dev/null || echo "dthanhvu03/sixmen-erp")
    REPO=$(echo "$REMOTE_URL" | sed -E 's#.*github\.com[:/]([^/]+/[^/.]+).*#\1#' | sed 's/\.git$//')
    echo "  Link tạo PR thủ công:"
    echo "    https://github.com/${REPO}/compare/${BASE_BRANCH}...${BRANCH}?expand=1"
fi

# ── Summary ─────────────────────────────────────────────────────
section "Kết quả"

if [ ${#warnings[@]} -gt 0 ]; then
    echo "  ⚠️  Warnings:"
    for w in "${warnings[@]}"; do echo "    - $w"; done
fi

if [ ${#failures[@]} -gt 0 ]; then
    echo "  ❌ BLOCKERS:"
    for f in "${failures[@]}"; do echo "    - $f"; done
    echo ""
    echo "🛑 Pre-merge FAIL — sửa blocker trước khi merge."
    exit 1
fi

echo "  ✅ Pre-merge PASS — có thể merge khi CI GitHub xanh."
exit 0
