---
name: deliberate-then-act
description: Use before any non-trivial decision, design, or first code write — invoke to think in a structured scratchpad first (goal, unknowns, options, pick, stop-conditions), then act. The kit's external "model thinking" protocol — forces deliberation like a reasoning model instead of jumping to an answer. Pair with senior-reasoning for depth on the chosen path.
license: Apache-2.0
compatibility: Requires repository read access.
metadata:
  sixmen-version: "1.0.0"
  sixmen-trust-tier: "T0"
  sixmen-owner: platform-team
---

# Deliberate-then-act skill

Modern reasoning models separate **thinking** from **answering**. This skill forces the same
discipline in the open: complete a short scratchpad **before** writing code, opening a PR, or
recommending a design. It does not replace `senior-reasoning` (depth on a contested choice) or
`smart-value` (business outcome) — it is the gate that stops the agent from skipping thought.

Work from **[references/deliberation-guide.md](references/deliberation-guide.md)** — when to
deliberate, scratchpad rules, and anti-patterns (performative thinking).

## When to run
- Non-trivial design or implementation about to start
- Contested choice, high blast radius, money/auth/inventory/data
- Before the first code write in `standard` / `strict` (alongside `/challenge`)
- Skip only for: pure explanation, a one-line typo/fix with no behavior change, or when a
  full `senior-reasoning` output was **just** produced in this turn for the same decision

## Workflow
1. **Pause** — do not call write/edit tools yet.
2. **Fill the scratchpad** (Output format below) — private deliberation the user can still see;
   keep it tight, not an essay.
3. **Act only on the pick** — implement or recommend the chosen option; if stop-conditions
   fire, stop and ask the founder instead of pushing through.
4. **Escalate depth** — if the pick is contested or high-stakes, run **`senior-reasoning`**
   next (or confirm its output already exists this turn). Business-outcome asks: ensure
   **`smart-value`** already ran or KPI is agreed. One-way-door / unfamiliar domain with a
   missing or stale brief: run **`domain-research`** before locking the pick.

## Output format (required)
```md
## Scratchpad
- Goal (1 sentence):
- Unknowns / missing info:
- Options (≥2, including do-nothing or cheapest):
- Pick + because:
- Stop-conditions (when I must ask the founder / HO):
- Next skill / command:
```

**Quality bar:** acting (code write, “ship it”, or a single-path recommendation) **without**
this scratchpad on a non-trivial task **fails this skill — redo with the scratchpad first**.
In `strict` (kit default) the full scratchpad is mandatory; never compress it away. A
scratchpad of empty bullets or “N/A” everywhere also fails — fill real content or state a
precise skip reason from “When to run”.
