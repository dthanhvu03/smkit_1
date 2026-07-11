#!/usr/bin/env bash
# Shared shell-command guard rules — TASK-GD0-016 / TASK-GD0-028.
# Usage: GUARD_CMD='...' bash guard-shell-core.sh
# Exit 0 = allow, exit 2 = block (message on stderr).
set -uo pipefail

cmd="${GUARD_CMD:-}"
[ -z "$cmd" ] && exit 0

guard_block() {
  echo "🛑 GUARD: $1" >&2
  exit 2
}

# Miễn trừ git commit/tag (ERR-021 — free-text trong message ≠ thi hành).
echo "$cmd" | grep -qiE '^[[:space:]]*git[[:space:]]+(commit|tag)\b' && exit 0

# 1. Raw SQL phá data — chỉ khi có execution-context.
if echo "$cmd" | grep -qiE '\b(psql|mysql|mariadb|sqlite3)\b|artisan[[:space:]]+tinker|DB::(statement|raw|unprepared|delete)' \
   && echo "$cmd" | grep -qiE '\b(DROP[[:space:]]+(TABLE|DATABASE|SCHEMA)|TRUNCATE([[:space:]]+TABLE)?|DELETE[[:space:]]+FROM)\b'; then
  guard_block "raw SQL phá data (DROP/TRUNCATE/DELETE FROM). Dùng migration + HO duyệt."
fi

# 2. migrate:fresh / db:wipe
echo "$cmd" | grep -qiE 'artisan[[:space:]]+(migrate:fresh|db:wipe)' \
  && guard_block "migrate:fresh/db:wipe — chạy thủ công, không qua agent."

# 3. migrate khi APP_ENV != local
if echo "$cmd" | grep -qiE 'artisan[[:space:]]+migrate'; then
  env_now="$(grep -E '^APP_ENV=' .env 2>/dev/null | head -1 | cut -d= -f2 | tr -d '[:space:]\"')"
  [ -n "$env_now" ] && [ "$env_now" != "local" ] \
    && guard_block "migrate khi APP_ENV=$env_now (non-local). Cần DevOps + HO."
fi

# 4. rm -rf
echo "$cmd" | grep -qiE '(^|[;&|[:space:]])rm[[:space:]]+(-[a-zA-Z]*[rf][a-zA-Z]*[rf]|-rf|-fr)([[:space:]]|$)' \
  && guard_block "rm -rf — xác nhận thủ công nếu thật sự cần."

# 5. docker compose down -v / --volumes (volume wipe)
if echo "$cmd" | grep -qiE 'docker(-compose| compose)[[:space:]]+down\b' \
   && echo "$cmd" | grep -qiE '(-v\b|--volumes\b)'; then
  guard_block "docker compose down -v/--volumes — xóa volume DB."
fi

# 6. docker volume prune / rm (xóa volume — có thể mất DB dev)
echo "$cmd" | grep -qiE 'docker[[:space:]]+volume[[:space:]]+(prune|rm)\b' \
  && guard_block "docker volume prune/rm — có thể xóa DB dev. Chạy thủ công nếu HO duyệt."

# 7. docker system prune kèm --volumes / -v
if echo "$cmd" | grep -qiE 'docker[[:space:]]+system[[:space:]]+prune\b' \
   && echo "$cmd" | grep -qiE '(--volumes\b|-v\b)'; then
  guard_block "docker system prune --volumes — xóa volume DB."
fi

# 8. chmod -R 777
echo "$cmd" | grep -qiE 'chmod[[:space:]]+(-[a-zA-Z]*R|-R)[[:space:]]+777' \
  && guard_block "chmod -R 777 — không an toàn."

# 9. Đọc .env qua shell
if echo "$cmd" | grep -qiE '\b(cat|head|tail|less|more|nano|vi|vim|strings|xxd|od)\b' \
   && echo "$cmd" | grep -qE '\.env(\.local)?([[:space:]]|$|[;|&>])' \
   && ! echo "$cmd" | grep -qE '\.env\.example'; then
  guard_block "đọc .env/.env.local qua shell — dùng .env.example."
fi

# 10. git push --force
echo "$cmd" | grep -qiE 'git[[:space:]]+push([[:space:]]|.)*(--force|[[:space:]]-f)([[:space:]]|$)' \
  && guard_block "git push --force — không ghi đè lịch sử remote."

# 11. push thẳng main/master
echo "$cmd" | grep -qiE 'git[[:space:]]+push[[:space:]]+[^[:space:]]+[[:space:]]+(main|master)([[:space:]:]|$)' \
  && guard_block "push thẳng main/master — dùng feature branch + PR."

exit 0
