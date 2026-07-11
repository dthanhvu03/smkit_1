#!/bin/bash
# Local kit health check — run after kit changes or before sync to Laravel repo.
# Usage: .cursor/bootstrap/init-kit.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT" || exit 1

echo "=== SIXMEN Kit Init / Health Check ==="
echo "Root: $REPO_ROOT"
echo ""

exit_code=0

# Cài git hooks dùng chung (.githooks) — pre-push chạy Pint + architecture-lint.
# Git không share .git/hooks; core.hooksPath mới share được qua repo.
if [ -d "$REPO_ROOT/.githooks" ]; then
    chmod +x "$REPO_ROOT/.githooks/"* 2>/dev/null
    current_hp="$(git -C "$REPO_ROOT" config core.hooksPath 2>/dev/null)"
    if [ "$current_hp" != ".githooks" ]; then
        git -C "$REPO_ROOT" config core.hooksPath .githooks
        echo "Git hooks: core.hooksPath → .githooks (pre-push gate đã bật)"
    else
        echo "Git hooks: core.hooksPath đã = .githooks ✓"
    fi
    echo ""
fi

for task_id in EXAMPLE-TASK PILOT-GD0-B1; do
    echo "--- validate-artifacts: $task_id ---"
    bash "$SCRIPT_DIR/validate-artifacts.sh" -t "$task_id"
    rc=$?
    [ $rc -ne 0 ] && exit_code=1
    echo ""
done

echo "--- validate-task-log ---"
bash "$SCRIPT_DIR/validate-task-log.sh"
rc=$?
[ $rc -gt 1 ] && exit_code=1
echo ""

# Always-on rules line count
echo "Always-on rules:"
always_on_count=0
always_on_lines=0
always_on_names=()
while IFS= read -r -d '' f; do
    if grep -q 'alwaysApply:[[:space:]]*true' "$f" 2>/dev/null; then
        always_on_count=$((always_on_count + 1))
        lines=$(wc -l < "$f")
        always_on_lines=$((always_on_lines + lines))
        always_on_names+=("$(basename "$f")")
    fi
done < <(find "$REPO_ROOT/.cursor/rules" -name "*.mdc" -print0 2>/dev/null)

echo "  $always_on_count files, ~$always_on_lines lines total"
echo "  ${always_on_names[*]}"
echo ""

if [ $exit_code -eq 0 ]; then
    echo "Kit health: PASS"
else
    echo "Kit health: FAIL"
fi

exit $exit_code
