#!/usr/bin/env bash
# Cursor beforeShellExecution guard — TASK-GD0-028.
# stdin: {"command":"...", "hook_event_name":"beforeShellExecution", ...}
# Block: JSON permission deny (jq) hoặc exit 2.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT" || exit 0

input="$(cat)"
cmd="$(printf '%s' "$input" | python3 -c "import sys,json
try:
    print(json.load(sys.stdin).get('command',''))
except Exception:
    print('')" 2>/dev/null)"

[ -z "$cmd" ] && exit 0

stderr_file="$(mktemp)"
if ! GUARD_CMD="$cmd" bash "$(dirname "$0")/guard-shell-core.sh" 2>"$stderr_file"; then
  msg="$(cat "$stderr_file" | head -1 | sed 's/^🛑 GUARD: //')"
  rm -f "$stderr_file"
  if command -v jq >/dev/null 2>&1; then
    jq -n --arg m "$msg" '{
      "permission": "deny",
      "user_message": $m,
      "agent_message": $m
    }'
  else
    python3 -c "import json,sys; print(json.dumps({'permission':'deny','user_message':sys.argv[1],'agent_message':sys.argv[1]}))" "$msg"
  fi
  exit 2
fi
rm -f "$stderr_file"
echo '{"permission":"allow"}'
exit 0
