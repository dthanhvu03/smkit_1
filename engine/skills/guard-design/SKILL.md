---
name: guard-design
description: Use when adding or changing hooks/guardrails (guard-shell, consistency-guard, blocklist, path boundaries). Invoke to design the BLOCK/WARN/ALLOW behavior and the bypass tests that prove it.
license: Proprietary
compatibility: Requires repository read access and git.
metadata:
  sixmen-version: "1.0.0"
  sixmen-trust-tier: "T0"
  sixmen-owner: platform-team
---

# Guard Design skill

Design a guardrail so it fails safe and is provably hard to bypass.

## Workflow
1. State what the guard must stop and in which mode(s).
2. Decide the **BLOCK / WARN / ALLOW** outcome for each case; default to fail-closed on ambiguity.
3. Enumerate **bypass attempts** (chaining `&&`/`|`, quoting, case, whitespace, `$()`, path escape, obfuscation) and confirm each is handled or explicitly out of scope.
4. Write tests for every case; note residual risk that only an OS sandbox can close.

## Output format (required)
```md
## What it must stop (+ mode)
## Decision table
| Case | Input | Decision | Reason |
|---|---|---|---|
## Bypass attempts covered
## Residual risk (needs sandbox)
## Tests to add
## Rollback
```
Never claim a string/AST guard is isolation.
