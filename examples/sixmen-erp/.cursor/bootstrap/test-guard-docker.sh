#!/usr/bin/env bash
# Smoke test guard-shell-core Docker volume rules (TASK-GD0-028 extension).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
CORE="$ROOT/guard-shell-core.sh"

block() {
  local cmd="$1"
  if GUARD_CMD="$cmd" bash "$CORE" >/dev/null 2>&1; then
    echo "FAIL allowed: $cmd" >&2
    return 1
  fi
  echo "BLOCK OK: $cmd"
}

allow() {
  local cmd="$1"
  if ! GUARD_CMD="$cmd" bash "$CORE" >/dev/null 2>&1; then
    echo "FAIL blocked: $cmd" >&2
    return 1
  fi
  echo "ALLOW OK: $cmd"
}

block 'docker volume prune -f'
block 'docker volume rm sixmen_postgres_data'
block 'docker system prune -a -f --volumes'
block 'docker system prune -af -v'
block 'docker compose down -v'
block 'docker-compose down --volumes'

allow 'docker builder prune -af'
allow 'docker system prune -af'
allow 'docker compose exec app php artisan cache:clear'
allow 'docker compose down'

echo "All guard-docker tests passed."
