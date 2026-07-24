---
name: DOMAIN_ID
description: Use when CHANGING_OR_ASKING_ABOUT_DOMAIN — invoke to apply this project's domain discipline (invariants, service boundaries, legal state transitions) before coding. Replace DOMAIN_ID and this sentence with real trigger cues in plain language (and Vietnamese if users speak VI).
license: Apache-2.0
compatibility: Requires repository read access.
metadata:
  sixmen-version: "1.0.0"
  sixmen-trust-tier: "T0"
  sixmen-owner: platform-team
---

# DOMAIN_ID skill

> Rename folder + `name` + `skill.kit.yaml` `id` to the same slug (e.g. `inventory-discipline`).
> Replace every `DOMAIN_*` / `SOT_*` placeholder. Delete this callout when done.

Coach the agent on **this project's** domain rules. Do not invent schema. **Read** the source-of-truth files first; then produce the output below. Coding roles implement; this skill does not write production code.

## Source of truth (read before acting)
- Entities / ERD: `SOT_ERD_PATH`
- Workflow / states: `SOT_WORKFLOW_PATH`
- Architecture / service envelope: `SOT_ARCH_PATH`
- Permission / policy (if any): `SOT_PERM_PATH`

## Workflow
1. **Confirm touchpoints** — which paths, tables, or APIs this change hits; stop if out of scope.
2. **Restate invariants** — quote the must-always / must-never lines that apply (from SoT + kit invariants).
3. **State machine** — list legal transitions for affected entities; name illegal ones this change must not enable.
4. **Service boundary** — name the single-entry service(s) allowed to mutate; forbid bypass patterns.
5. **Tests & gates** — required tests (happy + deny/403/422 as relevant); Human Owner gates (schema / data / prod).
6. **Hand off** — implementer / db-admin / frontend with a one-line brief each; reviewer uses the checklist in Output.

## Output format (required)
```md
## Touchpoints (paths · tables · APIs)
## Invariants that apply (quoted)
## Legal vs illegal transitions
## Service boundary (allowed · forbidden)
## Tests required
## Human Owner gates (or N/A)
## Hand-off notes
```

**Quality bar:** missing SoT read (or “SoT path not found” without stopping), or missing **Service boundary**, **fails this skill — redo**. Always deliver the full output (kit default is `strict`).

## References
Deep rules and anti-patterns: [references/domain-guide.md](references/domain-guide.md).
