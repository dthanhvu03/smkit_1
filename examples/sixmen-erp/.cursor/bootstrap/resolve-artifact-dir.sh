#!/bin/bash
# Resolve artifacts/{Task-ID} — active root or archive/GD0 (post UC-00).
# Usage: TASK_DIR="$(bash .cursor/bootstrap/resolve-artifact-dir.sh TASK-GD0-001)"

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TASK_ID="${1:-}"

if [ -z "$TASK_ID" ]; then
    exit 1
fi

for candidate in \
    "$REPO_ROOT/artifacts/$TASK_ID" \
    "$REPO_ROOT/artifacts/archive/GD0/$TASK_ID"; do
    if [ -d "$candidate" ]; then
        echo "$candidate"
        exit 0
    fi
done

exit 1
