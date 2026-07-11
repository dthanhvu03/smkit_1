#!/bin/bash
# Git-gate commit — SIXMEN AI OS v2, Item 3
# Creates an immutable git checkpoint after each Human Owner gate approval.
#
# Usage:
#   .cursor/bootstrap/git-gate-commit.sh -t TASK-GD0-011 -g schema_gate -a "Vu"
#   .cursor/bootstrap/git-gate-commit.sh -t TASK-GD0-010 -g qa_gate -a "QA-auto"

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TASK_ID="" GATE_NAME="" APPROVED_BY="" NOTE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -t|-TaskId)    TASK_ID="$2";    shift 2 ;;
        -g|-GateName)  GATE_NAME="$2";  shift 2 ;;
        -a|-ApprovedBy) APPROVED_BY="$2"; shift 2 ;;
        -n|-Note)      NOTE="$2";       shift 2 ;;
        *) shift ;;
    esac
done

if [ -z "$TASK_ID" ] || [ -z "$GATE_NAME" ] || [ -z "$APPROVED_BY" ]; then
    echo "Usage: $0 -t <TaskId> -g <GateName> -a <ApprovedBy> [-n <Note>]"
    exit 1
fi

TASK_DIR="$(bash "$REPO_ROOT/.cursor/bootstrap/resolve-artifact-dir.sh" "$TASK_ID" 2>/dev/null || true)"

if [ -z "$TASK_DIR" ] || [ ! -d "$TASK_DIR" ]; then
    echo "ERROR: GIT-GATE: Task directory not found: artifacts/$TASK_ID"
    exit 1
fi

cd "$REPO_ROOT" || exit 1

# Stage required files
for f in "$TASK_DIR/00-gate-status.md" "$TASK_DIR/01-task-brief.md"; do
    [ -f "$f" ] && git add "$f" 2>/dev/null
done

# Stage optional files if they exist
for f in \
    "$TASK_DIR/task-state.json" \
    "$TASK_DIR/task-state.sig" \
    "$TASK_DIR/06-test-plan.md" \
    "$TASK_DIR/07-architecture-compliance-checklist.md"; do
    [ -f "$f" ] && git add "$f" 2>/dev/null
done

# Stage PROGRESS.md if it changed
[ -f "artifacts/PROGRESS.md" ] && git add "artifacts/PROGRESS.md" 2>/dev/null

# Re-sign task-state.json before committing
VERIFY_SCRIPT="$(dirname "$0")/verify-task-state.sh"
if [ -f "$VERIFY_SCRIPT" ]; then
    bash "$VERIFY_SCRIPT" -t "$TASK_ID" --sign 2>/dev/null
    [ -f "$TASK_DIR/task-state.sig" ] && git add "$TASK_DIR/task-state.sig" 2>/dev/null
fi

# Build commit message
DATE=$(date '+%Y-%m-%d %H:%M')
NOTE_STR=""
[ -n "$NOTE" ] && NOTE_STR=" — $NOTE"
COMMIT_MSG="gate: $TASK_ID/$GATE_NAME approved by $APPROVED_BY [$DATE]$NOTE_STR"

git commit -m "$COMMIT_MSG"

if [ $? -eq 0 ]; then
    echo "GIT-GATE: Committed checkpoint for $TASK_ID/$GATE_NAME"
    echo "  Approved by: $APPROVED_BY"
    echo "  Message: $COMMIT_MSG"
else
    echo "WARNING: GIT-GATE: Nothing staged for $TASK_ID/$GATE_NAME (no changes detected)"
fi
