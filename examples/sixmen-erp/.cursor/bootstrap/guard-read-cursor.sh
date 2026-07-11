#!/usr/bin/env bash
# Cursor beforeReadFile guard — chặn đọc secret (.env, keys). TASK-GD0-028.
set -uo pipefail

input="$(cat)"
parsed="$(printf '%s' "$input" | python3 -c "import sys,json,os
try:
    d=json.load(sys.stdin)
    p=d.get('file_path','') or d.get('path','') or ''
    print(p)
    print(os.path.basename(p) if p else '')
except Exception:
    print('')
    print('')" 2>/dev/null)"

full_path="$(printf '%s\n' "$parsed" | sed -n '1p')"
path="$(printf '%s\n' "$parsed" | sed -n '2p')"

[ -z "$path" ] && [ -z "$full_path" ] && exit 0

block_msg=""

case "$path" in
  .env|.env.local) block_msg="Không đọc .env/.env.local qua agent." ;;
esac

if [ -z "$block_msg" ] && echo "$full_path" | grep -qE '/\.env(\.local)?$'; then
  block_msg="Không đọc .env/.env.local qua agent."
fi

if [ -z "$block_msg" ] && echo "$full_path" | grep -qE '\.(pem|key)$|/id_rsa(\.pub)?$'; then
  block_msg="Không đọc file key/cert qua agent."
fi

echo "$full_path" | grep -qE '\.env\.example$' && block_msg=""

if [ -n "$block_msg" ]; then
  if command -v jq >/dev/null 2>&1; then
    jq -n --arg m "$block_msg" '{"permission":"deny","user_message":$m,"agent_message":$m}'
  else
    python3 -c "import json,sys; print(json.dumps({'permission':'deny','user_message':sys.argv[1],'agent_message':sys.argv[1]}))" "$block_msg"
  fi
  exit 2
fi

echo '{"permission":"allow"}'
exit 0
