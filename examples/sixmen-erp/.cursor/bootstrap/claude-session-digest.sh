#!/usr/bin/env bash
# SessionStart hook — bơm context ĐỘNG (task 🔄 trong PROGRESS.md).
# Dual output: Claude (hookSpecificOutput) + Cursor (additional_context). TASK-GD0-015 · kit v2.27.
# Ref: code.claude.com/docs/en/hooks · cursor.com/docs/hooks § sessionStart
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)" 2>/dev/null || exit 0
cd "$ROOT" 2>/dev/null || exit 0

tasks=""
if [ -f artifacts/PROGRESS.md ]; then
  tasks="$(grep -E '🔄' artifacts/PROGRESS.md 2>/dev/null | sed 's/|/ /g; s/  */ /g' | head -6)"
fi

python3 - "$tasks" <<'PY'
import json, sys

tasks = (sys.argv[1].strip() if len(sys.argv) > 1 else "")
ctx = "=== SIXMEN — Task đang chạy (auto, động) ===\n"
ctx += tasks if tasks else "(không có task IN-PROGRESS trong PROGRESS.md)"
ctx += "\n(Luật/routing tĩnh: CLAUDE.md § LUẬT CỨNG + @AGENTS.md / Cursor rules alwaysApply.)"

# Một JSON cho cả hai nền tảng — mỗi runtime đọc field của mình.
print(
    json.dumps(
        {
            "additional_context": ctx,
            "hookSpecificOutput": {
                "hookEventName": "SessionStart",
                "additionalContext": ctx,
            },
        },
        ensure_ascii=False,
    )
)
PY
exit 0
