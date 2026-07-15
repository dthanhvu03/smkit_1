---
# GENERATED — DO NOT EDIT. Edit engine/ or kit.config.yaml, then run: kit build
name: "security-review"
description: "Use when a change touches auth, secrets, shell/command execution, file access, or the guard/hooks. Invoke for a risk assessment with concrete exploit scenarios and fixes."
license: "Proprietary"
compatibility: "Requires repository read access and git."
---

# Security Review skill

Assess the security impact of a change. Be concrete about how it could be abused.

## Workflow
1. Map the **attack surface** the change adds or widens (inputs, commands run, files/paths read or written, network calls, secrets in scope).
2. For each risk, write a concrete **exploit scenario** (inputs/state → bad outcome), not a vague concern.
3. Check the guardrails: does the guard/hook actually block this, or is it only a markdown rule? Note gaps.
4. Recommend fixes and the tests that would prove them.

## Output format (required)
```md
## Attack surface
## Risks
| Severity | Risk | Evidence (file:line) | Exploit scenario | Fix |
|---|---|---|---|---|
## Guardrail gaps
## Recommended tests
## Verdict (safe to ship / fix first)
```
Position the guard honestly: hooks are damage-control, not isolation — the real boundary is the OS sandbox.
