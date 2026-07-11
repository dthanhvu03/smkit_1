#!/bin/bash
# HMAC integrity verifier for task-state.json — SIXMEN AI OS v2, Item 2
# Usage:
#   ./verify-task-state.sh -t TASK-GD0-011 --sign    : sign after creating/updating task-state.json
#   ./verify-task-state.sh -t TASK-GD0-011 --verify  : verify before trusting task-state.json
#   ./verify-task-state.sh --sign-all                 : sign all existing task-state.json
# Setup: add TASK_STATE_HMAC_KEY=<32-char-random> to .env

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ENV_FILE="$REPO_ROOT/.env"
TASK_ID=""
MODE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -t|--task|-TaskId) TASK_ID="$2"; shift 2 ;;
        --sign|-Sign) MODE="sign"; shift ;;
        --verify|-Verify) MODE="verify"; shift ;;
        --sign-all|-SignAll) MODE="sign-all"; shift ;;
        *) shift ;;
    esac
done

get_hmac_key() {
    if [ ! -f "$ENV_FILE" ]; then
        echo "WARNING: VERIFY-STATE: .env not found - integrity check skipped" >&2
        echo ""
        return
    fi
    grep -E '^TASK_STATE_HMAC_KEY=' "$ENV_FILE" | cut -d'=' -f2- | tr -d '\r\n'
}

get_file_hmac() {
    local file="$1" key="$2"
    # HMAC-SHA256 using openssl
    echo -n "$(cat "$file")" | openssl dgst -sha256 -hmac "$key" 2>/dev/null | awk '{print $2}'
}

resolve_task_artifact_dir() {
    local id="$1"
    if [ -d "$REPO_ROOT/artifacts/$id" ]; then
        echo "$REPO_ROOT/artifacts/$id"
    elif [ -d "$REPO_ROOT/artifacts/archive/GD0/$id" ]; then
        echo "$REPO_ROOT/artifacts/archive/GD0/$id"
    fi
}

do_sign() {
    local id="$1"
    local task_base
    task_base="$(resolve_task_artifact_dir "$id")"
    local state_file="$task_base/task-state.json"
    local sig_file="$task_base/task-state.sig"

    if [ ! -f "$state_file" ]; then
        echo "WARNING: SIGN: $state_file not found - skipping" >&2
        return
    fi

    local key
    key=$(get_hmac_key)
    [ -z "$key" ] && return

    local hash
    hash=$(get_file_hmac "$state_file" "$key")
    echo -n "$hash" > "$sig_file"
    echo "SIGNED: $id => ${hash:0:16}..."
}

do_verify() {
    local id="$1"
    local task_base
    task_base="$(resolve_task_artifact_dir "$id")"
    local state_file="$task_base/task-state.json"
    local sig_file="$task_base/task-state.sig"

    if [ ! -f "$state_file" ]; then
        echo "WARNING: VERIFY: $state_file not found - skipping" >&2
        return 0
    fi

    local key
    key=$(get_hmac_key)
    [ -z "$key" ] && return 0

    local current_hash
    current_hash=$(get_file_hmac "$state_file" "$key")

    if [ ! -f "$sig_file" ]; then
        echo "WARNING: VERIFY: No .sig for $id - first run, signing now" >&2
        echo -n "$current_hash" > "$sig_file"
        return 0
    fi

    local expected_hash
    expected_hash=$(cat "$sig_file" | tr -d '\r\n')

    if [ "$current_hash" != "$expected_hash" ]; then
        echo "INTEGRITY FAIL: artifacts/$id/task-state.json was modified outside agent flow!" >&2
        echo "  Expected : ${expected_hash:0:16}..." >&2
        echo "  Got      : ${current_hash:0:16}..." >&2
        echo "  Action   : review changes, then re-sign with --sign if intentional." >&2
        return 1
    fi

    echo "INTEGRITY OK: $id"
    return 0
}

# Main
if [ "$MODE" = "sign-all" ]; then
    for d in "$REPO_ROOT/artifacts"/TASK-*/ "$REPO_ROOT/artifacts/archive/GD0"/TASK-*/; do
        [ -d "$d" ] || continue
        id=$(basename "$d")
        do_sign "$id"
    done
    exit 0
fi

if [ -z "$TASK_ID" ]; then
    echo "Usage: $0 -t <TaskId> [--sign|--verify] or --sign-all"
    exit 0
fi

case "$MODE" in
    sign)   do_sign "$TASK_ID" ;;
    verify) do_verify "$TASK_ID"; exit $? ;;
    *)      echo "Usage: $0 -t <TaskId> [--sign|--verify] or --sign-all" ;;
esac
