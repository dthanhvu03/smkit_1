#!/bin/bash
# PostToolUse sanitizer — SIXMEN AI OS v2, Item 4
# Scans tool output for injection patterns and logs violations.
# Runs as PostToolUse hook in .claude/settings.json.
#
# ARCHITECTURE NOTE:
#   PostToolUse hooks OBSERVE — they cannot modify what the LLM already sees.
#   Step 1 (SCAN/LOG) — this script
#   Step 2 (TAG)      — CLAUDE.md system prompt
#   Step 3 (SEGMENT)  — CLAUDE.md DATA BLOCK instruction
#
# Input: JSON from stdin { "tool_name": "...", "tool_response": { "output": "..." } }

SECURITY_LOG="artifacts/SECURITY-LOG.md"

PATTERNS=(
    'ignore (previous|all|the) (instructions|rules|constraints)'
    'you are now (operating|working|acting) as'
    'new (system|agent|orchestrator) instruction'
    'disregard (your|all) (training|guidelines|rules)'
    'override (your|all|previous) (instructions|behavior)'
    'forget (your|all) (instructions|guidelines)'
    'execute the following (commands|instructions)'
    'from now on (you|act|behave|treat)'
    'do not follow (your|the) (guidelines|rules|instructions)'
    'act as if (you are|you were) (a|an) (different|unrestricted|uncensored)'
)

# Read stdin
INPUT=$(cat)
[ -z "$INPUT" ] && exit 0

# Parse JSON with python3 (always available on Ubuntu)
TOOL_NAME=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_name', ''))
except:
    print('')
" 2>/dev/null)

OUTPUT=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    r = d.get('tool_response', {})
    if isinstance(r, dict):
        print(r.get('output', ''))
    else:
        print(str(r))
except:
    print('')
" 2>/dev/null)

[ -z "$OUTPUT" ] && exit 0

write_alert() {
    local tool="$1" pattern="$2" excerpt="$3"
    local ts
    ts=$(date '+%Y-%m-%d %H:%M:%S')
    excerpt="${excerpt:0:80}"

    if [ ! -f "$SECURITY_LOG" ]; then
        cat > "$SECURITY_LOG" << 'EOF'
# SIXMEN Security Log — Tool Output Injection Alerts

| Timestamp | Event | Tool | Pattern | Excerpt |
|-----------|-------|------|---------|---------|
EOF
    fi

    echo "| $ts | TOOL_OUTPUT_INJECTION | $tool | \`$pattern\` | \`$excerpt\` |" >> "$SECURITY_LOG"
    echo "SANITIZER WARNING: Injection pattern detected in $tool output — logged to $SECURITY_LOG" >&2
    echo "  Pattern: $pattern" >&2
    echo "  Excerpt: ${excerpt:0:120}" >&2
}

DETECTED=false
for pattern in "${PATTERNS[@]}"; do
    if echo "$OUTPUT" | grep -qiE "$pattern" 2>/dev/null; then
        excerpt=$(echo "$OUTPUT" | grep -ioE "$pattern" | head -1)
        write_alert "$TOOL_NAME" "$pattern" "$excerpt"
        DETECTED=true
    fi
done

# Exit 0 even on detection — observational mode (log but don't block)
exit 0
