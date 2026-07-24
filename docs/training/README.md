# Training the kit — index

How to make the agent **strong** without bloating always-on context: train **people**, train **project DNA**, then deepen **domain playbooks**.

Default mode is **`strict`**. Prefer progressive disclosure: thin always-on rules, deep skills loaded on demand.

## Start here (pick your hat)

| You are | Read | Time |
|---------|------|------|
| Founder / non-coder | [02-user-playbook.md](02-user-playbook.md) → [founder-curriculum.md](founder-curriculum.md) | 2–3h |
| Kit owner / tech lead | [01-dna-setup.md](01-dna-setup.md) → [03-domain-skill-guide.md](03-domain-skill-guide.md) | days 1–3 |
| Kit maintainer | [maintainer-curriculum.md](maintainer-curriculum.md) | 1–2 days |
| Measuring quality | [04-dogfood-and-measure.md](04-dogfood-and-measure.md) | ongoing |

## 4-week path (kit owner)

| Week | Goal | Doc | Done when |
|------|------|-----|-----------|
| **1 — DNA** | Constitution, decisions, invariants | [01-dna-setup.md](01-dna-setup.md) | New session recalls must-nevers without prompting |
| **2 — Ritual** | Team uses 5 commands | [02-user-playbook.md](02-user-playbook.md) | Non-coder ships one small feature end-to-end |
| **3 — Domain** | One deep domain skill + references | [03-domain-skill-guide.md](03-domain-skill-guide.md) | `/ship` loads that skill and follows its output format |
| **4 — Measure** | Dogfood 10 tasks + KPIs | [04-dogfood-and-measure.md](04-dogfood-and-measure.md) | Checklist filled; red items fixed in DNA/skills |

## Templates (copy into your project)

| Template | Use |
|----------|-----|
| [templates/invariants-starter.yaml](templates/invariants-starter.yaml) | Paste under `kit.config.yaml` → `invariants:` |
| [templates/dogfood-log.md](templates/dogfood-log.md) | Log of 10 dogfood tasks |
| [templates/domain-skill/](templates/domain-skill/) | Scaffold for a new domain skill |
| [templates/kpi-scorecard.md](templates/kpi-scorecard.md) | Week-4 scorecard |
| [examples/inventory-discipline-outline.md](examples/inventory-discipline-outline.md) | Filled outline for an inventory domain |

## Design rules (do not violate while training)

1. **Always-on thin, on-demand deep** — do not paste ERD/BRD into hard-rules.
2. **One skill = one job** — workflow + required output + quality bar.
3. **SoT lives in files** — skills only point (“read `docs/…`”); they do not duplicate.
4. **Dogfood before declare done** — every new skill must survive one real task.
5. **Keep `strict`** — train people to approve gates; do not weaken the default mode.

## Related kit docs

- [enforcement-and-evals.md](../enforcement-and-evals.md) — hard vs soft tiers  
- [ADR-004 roles/rules/skills](../adr/ADR-004-roles-rules-skills-separation.md)  
- [15-skill-references.md](../kit-refactor/15-skill-references.md) — progressive disclosure  
- Example domain pack: [`examples/sixmen-erp/`](../../examples/sixmen-erp/)
