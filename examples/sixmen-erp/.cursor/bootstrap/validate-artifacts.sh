#!/bin/bash
# Validate SIXMEN task artifacts before declaring task complete.
# Exit 0 = PASS, Exit 1 = FAIL (blocker)
# Usage: ./validate-artifacts.sh -t TASK-GD0-001 [-s (strict)]
#
# Example:
#   .cursor/bootstrap/validate-artifacts.sh -t TASK-GD0-012
#   .cursor/bootstrap/validate-artifacts.sh -t TASK-GD0-012 -s

TASK_ID=""
STRICT=false
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -t|--task|-TaskId) TASK_ID="$2"; shift 2 ;;
        -s|--strict|-Strict) STRICT=true; shift ;;
        *) echo "Unknown arg: $1"; shift ;;
    esac
done

if [ -z "$TASK_ID" ]; then
    echo "Usage: $0 -t <TaskId> [-s]"
    exit 1
fi

TASK_DIR="$(bash "$REPO_ROOT/.cursor/bootstrap/resolve-artifact-dir.sh" "$TASK_ID" 2>/dev/null || true)"

if [ -z "$TASK_DIR" ] || [ ! -d "$TASK_DIR" ]; then
    echo "ERROR: Artifact folder not found: artifacts/$TASK_ID (also checked artifacts/archive/GD0/)"
    exit 1
fi

failures=()
warnings=()

check_file() {
    local rel="$1" label="$2"
    if [ ! -f "$TASK_DIR/$rel" ]; then
        failures+=("Missing: $label ($rel)")
        return 1
    fi
    return 0
}

# Always required
check_file "00-gate-status.md" "Gate status"
check_file "01-task-brief.md"  "Task brief"

GATE_CONTENT=""
[ -f "$TASK_DIR/00-gate-status.md" ] && GATE_CONTENT=$(cat "$TASK_DIR/00-gate-status.md")

# Detect task type.
# FIX (GD1-019 điểm mù): trước đây chỉ coi là code khi 06/07 ĐÃ tồn tại → task code thiếu
# 06/07 bị xếp nhầm docs-only và không bao giờ bị bắt. Nay ưu tiên đọc marker "Task type"/"Loại"
# trong gate-status; giữ presence-of-06/07 làm fallback.
IS_CODE=false
IS_DOCS=false

if echo "$GATE_CONTENT" | grep -qiE 'task[ ]*type.*\b(code|ui-only|ux-only|frontend|backend)\b|loại:.*\b(ux-only|ui-only|code)\b'; then
    IS_CODE=true
elif [ -f "$TASK_DIR/06-test-plan.md" ] || [ -f "$TASK_DIR/07-architecture-compliance-checklist.md" ]; then
    IS_CODE=true
elif echo "$GATE_CONTENT" | grep -qi 'docs-only'; then
    IS_DOCS=true
else
    IS_DOCS=true
fi

# Right-size waiver: task Tier 0/1 (bằng chứng QA inline trong gate-status) hoặc chưa triển khai
# (backlog/design-first) được phép KHÔNG tách 06/07. Key trên marker ASCII rõ ràng.
WAIVED_0607=false
if echo "$GATE_CONTENT" | grep -qiE 'right-size tier|06/07 waived|qa-artifact:.*waiv|backlog|design-first|design-queued|design backlog|design complete|brief stage|design stage|chưa code|chưa migrate|chưa implement'; then
    WAIVED_0607=true
fi

if $IS_CODE; then
    if [ -f "$TASK_DIR/06-test-plan.md" ] && [ -f "$TASK_DIR/07-architecture-compliance-checklist.md" ]; then
        # Code task đầy đủ artifact QA → đòi qa_gate PASS như cũ.
        if ! echo "$GATE_CONTENT" | grep -qi 'qa_gate.*PASS'; then
            if $STRICT; then
                failures+=("qa_gate not PASS in 00-gate-status.md (code task)")
            else
                warnings+=("qa_gate not PASS - review may be blocked")
            fi
        fi
    elif $WAIVED_0607; then
        warnings+=("code task thiếu 06/07 — WAIVED (Tier 0/1 QA inline hoặc backlog/design). Xác nhận right-size có chủ đích.")
    else
        check_file "06-test-plan.md" "Test plan (code task)"
        check_file "07-architecture-compliance-checklist.md" "Architecture compliance (code task)"
    fi
else
    if ! echo "$GATE_CONTENT" | grep -qi 'qa_gate.*N/A'; then
        warnings+=("docs-only task: consider setting qa_gate: N/A in gate-status")
    fi
fi

if $STRICT && echo "$GATE_CONTENT" | grep -q 'PENDING'; then
    warnings+=("Human Owner gate still PENDING - confirm intentional stop")
fi

echo "=== SIXMEN Artifact Validation ==="
echo "Task ID:  $TASK_ID"
echo "Folder:   $TASK_DIR"
echo "Type:     $(if $IS_CODE; then echo 'code'; else echo 'docs-only'; fi)"
echo ""

if [ ${#warnings[@]} -gt 0 ]; then
    echo "Warnings:"
    for w in "${warnings[@]}"; do echo "  - $w"; done
    echo ""
fi

if [ ${#failures[@]} -gt 0 ]; then
    echo "FAIL (${#failures[@]} blocker(s)):"
    for f in "${failures[@]}"; do echo "  - $f"; done
    exit 1
fi

echo "PASS - artifact structure OK"
exit 0
