# Week 3 — Domain skill guide

Goal: one **deep, on-demand** skill for your hottest business domain — without bloating always-on rules.

Universal kit skills (`smart-value`, `domain-model`, `senior-reasoning`, …) stay stack-agnostic. **Your** inventory / booking / pricing rules live in a **domain skill** (or a pack like [`examples/sixmen-erp`](../../examples/sixmen-erp/)).

## When you need a domain skill

- The same business mistakes repeat (wrong service boundary, illegal state, skipped audit).
- Constitution alone is too soft; reviewers keep re-explaining the same rules.
- `/ship` Design would benefit from “read this playbook before coding”.

You do **not** need a domain skill for every CRUD screen.

## Steps

1. **Pick one pain domain** (e.g. inventory, payments, booking). Only one in Week 3.
2. **Copy the scaffold** from [templates/domain-skill/](templates/domain-skill/) into `engine/skills/<id>/` (or your project’s vendored `engine/skills/` after init).
3. **Fill SoT pointers** — real paths to ERD / BRD / architecture docs. Do not paste the whole ERD into `SKILL.md`.
4. **Write workflow + required output + quality bar** (doctor checks these).
5. **Add `references/<domain>-guide.md`** — deep rules, examples, anti-patterns.
6. **Wire routing** (minimal):
   - `engine/rules/05-command-routing.md` — one row: intent → this skill then `/start` or `/ship`
   - `engine/roles/orchestrator.md` or `analyst.md` — when to invoke
   - Optionally `/ship` Design — “if touching \<domain\>, run \<skill\>”
7. **Rebuild** — `smkit build` · `doctor` · regenerate golden if you are in the kit repo (`UPDATE_GOLDEN=1 npm test`).
8. **Dogfood** — one real task must produce the skill’s output format before you call it done.

## Quality bar (same as shipped skills)

| Must have | Fail if |
|-----------|---------|
| Ordered **Workflow** | Only prose dump |
| **Output format** with named sections | Free-form chat only |
| **Quality bar** (“missing X = redo”) | No fail condition |
| Trigger cues in `description` | Doctor WARN: no trigger |
| `references/` for depth | Everything crammed into always-on |

## Outline — first domain skill (fill blanks)

```text
id:          <domain>-discipline          e.g. inventory-discipline
when:        Touching <paths> or asking to change <business concept>
first move:  Read SoT files listed below; restate invariants in one sentence
never:       Bypass <CriticalService>; hard-delete <append-only tables>; …
output:      Invariants touched · Legal transitions · Service boundary · Tests required · HO gates
hand-off:    implementer / db-admin / frontend as needed; reviewer checks this skill’s checklist
```

Scaffold files already use this outline — edit the placeholders.

## Anti-patterns

| Don’t | Do |
|-------|-----|
| Paste full ERD into hard-rules | Pointer + Read on demand |
| 10 domain skills in week 1 | One skill, one dogfood |
| Always-apply domain rule for whole repo | Path-scoped invariant + skill on trigger |
| Skill that plans + codes + reviews | Skill coaches; roles stay separated (ADR-004) |

## After Week 3

→ [04-dogfood-and-measure.md](04-dogfood-and-measure.md)
