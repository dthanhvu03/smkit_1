# Deliberation guide — external thinking before action

Loaded by `deliberate-then-act`. This is **protocol thinking** (written scratchpad), not a
vendor's hidden chain-of-thought tokens. It works on every IDE the kit targets.

## Why a scratchpad
Models default to the first plausible answer. Reasoning-quality work needs a pause:
name the goal, surface unknowns, list options, pick with a because, and define when to
**stop** and ask a human. Writing that down is the enforceability layer for soft agents.

## Scratchpad rules
- **Before tools that change the repo** on non-trivial work — not after.
- **≥2 options** — include do-nothing or the cheapest/manual path when relevant.
- **Because** on the pick — assertion without reason fails the skill.
- **Stop-conditions** are concrete (“schema change without HO”, “KPI unknown”, “two
  services both claim ownership”) — not “if unsure”.
- Keep the scratchpad **short** (bullets). Depth belongs in `senior-reasoning`.

## Relationship to other skills
| Skill | Job |
|-------|-----|
| `deliberate-then-act` | Gate: think → then act |
| `thinking-lenses` | Systems · critical · quantitative · communication (required cross-cut) |
| `brainstorm` | Wide diverge when options are missing |
| `smart-value` | Business KPI / value scoring |
| `domain-model` | Entities, states, invariants (one enforcement home) |
| `api-design` | HTTP/RPC contract before handlers |
| `async-workflows` | Queue/worker/outbox/saga (opt-in) |
| `infra-iac` | Terraform/Pulumi/CDK design (opt-in) |
| `senior-reasoning` | Deep senior pass on a contested pick |
| `/challenge` + `pre-build-critique` | Safety lenses + critique gate token |

Typical order for a new feature in `strict`:
`smart-value` (if business) → `deliberate-then-act` + **`thinking-lenses`** →
`senior-reasoning` (if contested) → `domain-model` (if lifecycle) → `api-design` (if API) →
`/challenge` → build.

## Anti-patterns (performative thinking)
- Empty bullets or “looks fine”
- One option only, then “therefore we build it”
- Scratchpad written **after** the code to justify it
- Pasting the whole ERD into the scratchpad (point to SoT instead)

## Model features (optional, Claude)
Protocol thinking is IDE-portable. On Claude Code, pair with strong subagent `model`
(e.g. opus) and `effort: high` on decision roles — that raises *internal* reasoning
budget; this skill still requires the *external* scratchpad so Cursor/Copilot users get
the same discipline.
