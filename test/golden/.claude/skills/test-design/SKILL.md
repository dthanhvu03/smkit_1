---
# GENERATED — DO NOT EDIT. Edit engine/ or kit.config.yaml, then run: kit build
name: "test-design"
description: "Use when a task needs a QA or test gate. Invoke to design test cases and edge cases and to produce the exact commands that prove the behavior works."
license: "Apache-2.0"
compatibility: "Requires repository read access and git."
---

# Test Design skill

Turn a feature into concrete, runnable checks — this is how the evidence gate gets satisfied.

## Workflow
1. Restate the behavior to prove and its acceptance criteria.
2. List happy-path cases, then edge cases (empty, boundary, error, concurrency where relevant).
3. Map each case to a concrete test (existing framework if any) and the command to run it.
4. Run them if possible and record results.

## Output format (required)
```md
## Behavior under test
## Test cases
| # | Case | Type (happy/edge) | How to verify | Command |
|---|---|---|---|---|
## Commands to run
## Results / evidence
## Gaps (untested)
```
Never mark a case passing without the actual result in **Results / evidence**.
