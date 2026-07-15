---
name: release-check
description: Use before publishing or releasing (npm publish, tag, deploy). Invoke for a pre-release checklist covering version, changelog, tests, and a go/no-go verdict.
license: Proprietary
compatibility: Requires repository read access and git.
metadata:
  sixmen-version: "1.0.0"
  sixmen-trust-tier: "T0"
  sixmen-owner: platform-team
---

# Release Check skill

Gate a release: nothing ships without evidence.

## Workflow
1. Confirm build/test/lint are green (run them; quote results — evidence gate).
2. Check version bump + changelog entry match what changed.
3. Confirm no secrets, no debug/temp files, no destructive migration without a plan.
4. Confirm the generated config is in sync (`smkit check`) and `smkit doctor` is clean.
5. Give an explicit go / no-go.

## Output format (required)
```md
## Checklist
| Item | Status | Evidence |
|---|---|---|
## Version + changelog
## Test / build evidence
## Risks / blockers
## Verdict (go / no-go)
```
No-go if any checklist item lacks evidence.
