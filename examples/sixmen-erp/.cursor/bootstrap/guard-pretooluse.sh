#!/usr/bin/env bash
# PreToolUse(Bash) guard — Claude Code. TASK-GD0-016 · core rules TASK-GD0-028.
# stdin: {tool_input:{command}}. exit 2 = CHẶN.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT" || exit 0

input="$(cat)"
cmd="$(printf '%s' "$input" | python3 -c "import sys,json
try:
    print(json.load(sys.stdin).get('tool_input',{}).get('command',''))
except Exception:
    print('')" 2>/dev/null)"
[ -z "$cmd" ] && exit 0

export GUARD_CMD="$cmd"
exec bash "$(dirname "$0")/guard-shell-core.sh"
