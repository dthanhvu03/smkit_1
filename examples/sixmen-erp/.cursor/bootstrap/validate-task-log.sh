#!/bin/bash
# Validate Task_Log_ERPSIXMEN.csv before paste to Sheet.
# Exit 0 = PASS, Exit 1 = FAIL, Exit 2 = PASS with warnings
#
# Usage: .cursor/bootstrap/validate-task-log.sh [path/to/csv]

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CSV_PATH="${1:-$REPO_ROOT/docs/erp/sheets/data/Task_Log_ERPSIXMEN.csv}"

if [ ! -f "$CSV_PATH" ]; then
    echo "ERROR: CSV not found: $CSV_PATH"
    exit 1
fi

python3 - "$CSV_PATH" << 'PYEOF'
import sys, csv, re

csv_path = sys.argv[1]
PROJECT_CODE = "PRJ-202606-ERPSIXMEN"
TASK_ID_PATTERN = re.compile(r'^TASK-ERPSIXMEN-\d{3}$')
DISCOURGED_TERMS = ['deploy', 'CRUD', '403', 'POC', 'UC-00', 'seed', 'nạp']
TEMPLATE_LABELS = ['Hiện trạng', 'Ảnh hưởng', 'Cần làm']

failures = []
warnings = []
seen_ids = {}

with open(csv_path, encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row_num, row in enumerate(reader, start=2):
        tid = (row.get('Task_ID') or '').strip()
        if not tid:
            continue

        line_id = f"Task_ID={tid} (row {row_num})"

        if tid in seen_ids:
            failures.append(f"{line_id} - duplicate Task_ID (first at row {seen_ids[tid]})")
        else:
            seen_ids[tid] = row_num

        if not TASK_ID_PATTERN.match(tid):
            failures.append(f"{line_id} - Task_ID must match TASK-ERPSIXMEN-NNN")

        project = (row.get('Project') or '').strip()
        if project != PROJECT_CODE:
            failures.append(f"{line_id} - project code must be {PROJECT_CODE}")

        milestone = (row.get('Milestone') or '').strip()
        if not milestone.startswith('M-ERP-'):
            failures.append(f"{line_id} - milestone must start with M-ERP-")

        desc = row.get('Description') or ''
        for label in TEMPLATE_LABELS:
            if label in desc:
                warnings.append(f"{line_id} - Description uses template label: {label}")
                break

        for term in DISCOURGED_TERMS:
            if term in desc:
                warnings.append(f"{line_id} - Description contains discouraged term: {term}")

        expected = row.get('ExpectedResult') or ''
        if '(1)' not in expected:
            warnings.append(f"{line_id} - ExpectedResult should use 5-step checklist with (1)")

print(f"=== Task_Log Validation ===")
print(f"File: {csv_path}")
print(f"Rows: {len(seen_ids)}")
print()

if warnings:
    print(f"Warnings ({len(warnings)}):")
    for w in warnings:
        print(f"  - {w}")
    print()

if failures:
    print(f"FAIL ({len(failures)}):")
    for ff in failures:
        print(f"  - {ff}")
    sys.exit(1)

print("PASS - Task_Log structure OK")
sys.exit(2 if warnings else 0)
PYEOF
