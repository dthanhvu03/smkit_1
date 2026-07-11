#!/usr/bin/env bash
# Merge remote main vào feature branch hiện tại (sync trước push/PR).
# Khác với `git checkout main && git pull` — lệnh này cập nhật FEATURE branch.
#
# Usage:
#   bash .cursor/bootstrap/sync-main-into-branch.sh
#   bash .cursor/bootstrap/sync-main-into-branch.sh github main
#
# Ref: sixmen-orchestrator SKILL.md § Git sync · ERR-030

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

REMOTE="${1:-github}"
BASE="${2:-main}"
BRANCH="$(git branch --show-current)"

if [ -z "$BRANCH" ] || [ "$BRANCH" = "$BASE" ]; then
    echo "🛑 Chạy trên feature branch (không phải $BASE)." >&2
    exit 1
fi

echo "━━ Sync $REMOTE/$BASE → $BRANCH ━━"
git fetch "$REMOTE" "$BASE"

BEHIND=$(git rev-list --count "$BRANCH".."$REMOTE/$BASE" 2>/dev/null || echo "0")
if [ "$BEHIND" = "0" ]; then
    echo "✅ Đã up-to-date với $REMOTE/$BASE — không cần merge."
    exit 0
fi

echo "  Behind $REMOTE/$BASE: $BEHIND commit(s)"
echo "  Merging..."
if git merge "$REMOTE/$BASE" -m "merge: sync $REMOTE/$BASE into $BRANCH"; then
    echo ""
    echo "✅ Merge xong. Chạy test rồi push:"
    echo "   bash .cursor/bootstrap/pre-merge-check.sh -t {Task-ID}"
    echo "   git push $REMOTE $BRANCH"
else
    echo ""
    echo "🛑 Conflict — resolve file conflict → git add → git commit"
    echo "   Hoặc branch mới từ main + cherry-pick delta (Cách B — xem orchestrator SKILL § Branch lifecycle)"
    exit 1
fi
