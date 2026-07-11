#!/bin/bash
# Memory entry validator — SIXMEN AI OS v2, Item 1
# Validates that memory entries are declarative (facts only, no instructions).
#
# Usage:
#   ./validate-memory-entry.sh -f /path/to/memory_file.md   # validate single file
#   ./validate-memory-entry.sh --all                         # validate all memory files

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MEMORY_DIR="$HOME/.claude/projects/-home-$(whoami)-sixmen-erp/memory"
SCHEMA_FILE="$REPO_ROOT/.cursor/schemas/memory-entry.schema.yaml"

FILE=""
ALL=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|-MemoryFile) FILE="$2"; shift 2 ;;
        --all|-All) ALL=true; shift ;;
        *) shift ;;
    esac
done

INJECTION_PATTERNS=(
    'always do'
    'never do'
    'ignore (previous|all|the) (instructions|rules)'
    'override'
    'bypass'
    'disregard'
    'forget your (instructions|guidelines)'
    'you must'
    'you shall'
    'from now on'
    'henceforth'
    'new (system|agent) instruction'
    'updated rule'
    'execute the following'
)

test_memory_file() {
    local filepath="$1"
    local content
    content=$(cat "$filepath" 2>/dev/null)

    if [ -z "$content" ]; then
        echo "SKIP: $filepath (unreadable or empty)"
        return 0
    fi

    local ok=true

    # Check required frontmatter
    if ! echo "$content" | grep -qE '\bname:\s*\S+'; then
        echo "SCHEMA FAIL [$filepath]: missing 'name:' in frontmatter"
        ok=false
    fi
    if ! echo "$content" | grep -qE '\bdescription:\s*\S+'; then
        echo "SCHEMA FAIL [$filepath]: missing 'description:' in frontmatter"
        ok=false
    fi
    if ! echo "$content" | grep -qE '\btype:\s*(user|feedback|project|reference)'; then
        echo "SCHEMA FAIL [$filepath]: 'type:' must be one of: user, feedback, project, reference"
        ok=false
    fi

    # Injection scan
    for pattern in "${INJECTION_PATTERNS[@]}"; do
        if echo "$content" | grep -qiE "$pattern"; then
            local match
            match=$(echo "$content" | grep -ioE "$pattern" | head -1)
            echo "INJECTION DETECTED [$filepath]: pattern '$pattern' matched '$match'"
            echo "  Memory must be declarative facts only. Move instructions to SKILL.md."
            ok=false
        fi
    done

    $ok && return 0 || return 1
}

if [ -z "$FILE" ] && ! $ALL; then
    echo "Usage: $0 -f <path> or --all"
    exit 0
fi

passed=0
failed=0

if $ALL; then
    if [ ! -d "$MEMORY_DIR" ]; then
        echo "ERROR: Memory directory not found: $MEMORY_DIR"
        exit 1
    fi
    while IFS= read -r -d '' f; do
        [[ "$(basename "$f")" == "MEMORY.md" ]] && continue
        if test_memory_file "$f"; then
            passed=$((passed + 1))
        else
            failed=$((failed + 1))
        fi
    done < <(find "$MEMORY_DIR" -name "*.md" -print0)
else
    if test_memory_file "$FILE"; then
        passed=$((passed + 1))
    else
        failed=$((failed + 1))
    fi
fi

echo ""
echo "Memory validation: $passed PASS, $failed FAIL"
[ "$failed" -gt 0 ] && exit 1 || exit 0
