#!/bin/bash
# KNOWN-ISSUES.md format validator — SIXMEN GD0-010 P1-5
# Validates each registry row for correct column count, ID format, and allowed field values.
# Exit 0 = valid, Exit 1 = format errors found.
#
# Usage:
#   .cursor/bootstrap/validate-known-issues.sh
#   .cursor/bootstrap/validate-known-issues.sh artifacts/KNOWN-ISSUES.md

KNOWN_ISSUES="${1:-artifacts/KNOWN-ISSUES.md}"
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Use absolute path if relative
[[ "$KNOWN_ISSUES" != /* ]] && KNOWN_ISSUES="$REPO_ROOT/$KNOWN_ISSUES"

ALLOWED_ENV="dev-win dev-linux dev-docker staging prod"
ALLOWED_TYPE="ENV CODE CONFIG PLATFORM"
ALLOWED_SEVERITY="P0 P1 P2"
ALLOWED_STATUS="OPEN RESOLVED WONTFIX DEFERRED"
EXPECTED_COLS=11

if [ ! -f "$KNOWN_ISSUES" ]; then
    echo "ERROR: File not found: $KNOWN_ISSUES"
    exit 1
fi

python3 - "$KNOWN_ISSUES" "$ALLOWED_ENV" "$ALLOWED_TYPE" "$ALLOWED_SEVERITY" "$ALLOWED_STATUS" "$EXPECTED_COLS" << 'PYEOF'
import sys, re

path = sys.argv[1]
allowed_env      = sys.argv[2].split()
allowed_type     = sys.argv[3].split()
allowed_severity = sys.argv[4].split()
allowed_status   = sys.argv[5].split()
expected_cols    = int(sys.argv[6])

def split_md_row(line):
    """Split markdown table row, treating content inside backticks as atomic (no | split)."""
    # Mask | inside backtick spans
    masked = []
    in_code = False
    result = []
    for ch in line:
        if ch == '`':
            in_code = not in_code
            masked.append(ch)
        elif ch == '|' and in_code:
            masked.append('\x00')  # placeholder
        else:
            masked.append(ch)
    masked_str = ''.join(masked)
    # Also handle \| (escaped pipe outside backticks)
    masked_str = masked_str.replace('\\|', '\x00')
    parts = masked_str.split('|')
    cols = []
    for p in parts:
        cell = p.replace('\x00', '|').strip()
        if cell:
            cols.append(cell)
    return cols

errors = 0
row_num = 0

with open(path, encoding='utf-8') as f:
    for line in f:
        line = line.rstrip('\n')
        if not re.match(r'^\|\s*ERR-', line):
            continue
        if 'ERR-XXX' in line:
            continue

        row_num += 1
        cols = split_md_row(line)
        col_count = len(cols)

        err_id = cols[0] if cols else ''

        if col_count != expected_cols:
            print(f"WARNING: Row {row_num} ({err_id}): expected {expected_cols} columns, got {col_count}")
            errors += 1
            continue

        date     = cols[1]
        env      = cols[2]
        typ      = cols[3]
        severity = cols[4]
        status   = cols[8]

        if not re.match(r'^ERR-\d{3}$', err_id):
            print(f"WARNING: Row {row_num}: ID '{err_id}' does not match ERR-NNN format")
            errors += 1
        if not re.match(r'^\d{4}-\d{2}-\d{2}$', date):
            print(f"WARNING: Row {row_num} ({err_id}): date '{date}' is not YYYY-MM-DD")
            errors += 1
        if env not in allowed_env:
            print(f"WARNING: Row {row_num} ({err_id}): Env '{env}' not in allowed: {allowed_env}")
            errors += 1
        if typ not in allowed_type:
            print(f"WARNING: Row {row_num} ({err_id}): Type '{typ}' not in allowed: {allowed_type}")
            errors += 1
        if severity not in allowed_severity:
            print(f"WARNING: Row {row_num} ({err_id}): Severity '{severity}' not in allowed: {allowed_severity}")
            errors += 1
        if status not in allowed_status:
            print(f"WARNING: Row {row_num} ({err_id}): Status '{status}' not in allowed: {allowed_status}")
            errors += 1

if row_num == 0:
    print("WARNING: KNOWN-ISSUES: No registry rows found — is the file empty?")

if errors > 0:
    print(f"KNOWN-ISSUES validation FAILED: {errors} error(s) in {row_num} rows")
    sys.exit(1)

print(f"KNOWN-ISSUES validation PASS: {row_num} rows checked, 0 errors")
sys.exit(0)
PYEOF
