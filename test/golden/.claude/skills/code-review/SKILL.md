---
# GENERATED — DO NOT EDIT. Edit engine/ or kit.config.yaml, then run: kit build
name: "code-review"
description: "Use when there is a diff or changed code to check before finishing. Invoke for correctness bugs, consistency with recorded decisions, and style or security smells."
---

# Code Review skill

Review the current changes — read, don't run (leave running to test-design/qa).

## Workflow
1. Identify the changed files (diff / recently edited).
2. Read the Decision Log; check the change stays consistent with it (no parallel pattern, naming, structure).
3. Look for correctness bugs, missing error handling, unsafe edge cases, and secret/security smells.
4. Rank findings by severity, most severe first.

## Output format (required)
```md
## Summary
## Changed files reviewed
## Findings
| Severity | File | Issue | Why it matters | Fix |
|---|---|---|---|---|
## Required fixes
## Optional improvements
## Test evidence
## Verdict (ship / fix first)
```
An empty **Test evidence** section fails the evidence gate.
