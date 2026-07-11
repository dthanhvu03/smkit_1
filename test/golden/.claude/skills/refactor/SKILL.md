---
# GENERATED — DO NOT EDIT. Edit engine/ or kit.config.yaml, then run: kit build
name: "Refactor"
description: "Use when changing structure without changing behavior. Invoke to plan a safe refactor with impact analysis and a rollback path before touching code."
paths:
  - "**/*"
---

# Refactor skill

Change shape, not behavior. Plan before editing.

## Workflow
1. State the behavior that must stay identical (the invariant).
2. Map impact: which files/callers/tests are affected.
3. Propose the smallest safe steps; note anything that touches a kit.config invariant.
4. Define how to verify behavior is unchanged (tests to run) and how to roll back.

## Output format (required)
```md
## Goal (what improves)
## Behavior kept identical
## Impact (files / callers / tests)
## Steps (smallest safe order)
## Verification (tests to run)
## Rollback plan
```
Do not start editing until the plan is confirmed in standard/strict mode.
