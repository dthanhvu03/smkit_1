---
name: smart-value
description: Use when a business request needs measurable value before building — revenue, cost save, risk, ops speed, or backlog priority. Invoke to pin a KPI/proxy outcome, find the root cause (not the symptom), score options with Impact×Effort and Cost of Delay (including do-nothing and no-code workarounds), and pick the smallest slice that captures value. The business lens before decision-brief / domain-model.
license: Apache-2.0
compatibility: Requires repository read access.
metadata:
  sixmen-version: "1.0.0"
  sixmen-trust-tier: "T0"
  sixmen-owner: platform-team
---

# Smart Value skill

Protect the business from paying to build the wrong thing — or the right thing in the wrong
order. Use this when the ask is framed as a business need (grow revenue, cut cost, fix ops
pain, prioritize a backlog) and **value is not yet pinned to a measurable outcome**. Technical
depth stays with `senior-reasoning`; founder packaging stays with `decision-brief`. This skill
answers: *what business number moves, why, and which option is worth doing first?*

Work from **[references/value-guide.md](references/value-guide.md)** — outcome-before-solution,
root-cause discipline, value levers, Impact×Effort, Cost of Delay, and estimate honesty.
If domain/market context would change the scores and `.kit/domain-brief.md` is missing or
stale, run **`domain-research`** first — then score; do not invent market facts.

## Workflow
1. **Outcome before solution.** Restate success as a change in a number (or honest proxy) for
   a named audience in a time window: "X moves from A→B for Y people in Z weeks." If you have
   no measurement yet, **flag it as an estimate** and name how you'd measure it — never present
   a guess as a fact.
2. **Root cause, not symptom.** Separate what hurts today from what causes it (up to five Whys,
   or a one-level MECE issue tree). Go deeper only when a different cause would change the
   solution. One sharp cause sentence is enough to proceed.
3. **Name the value lever(s).** Pick one or two primary levers: revenue · cost · risk/compliance ·
   ops speed · customer experience. Secondary levers are optional context — don't dilute focus.
4. **Options scored — always include non-build paths.** At least **three** options, and the set
   **must** include **do nothing** and a **no-code / process workaround**. Score each with
   Impact (1–5) × Effort (1–5) plus a one-line Cost of Delay note. Every score needs a **basis**
   (what you're counting on); a number with no basis fails this skill.
5. **Smallest value slice.** The smallest move that still captures most of the value *or*
   learns the riskiest assumption. Isolate the one or two questions only the founder / human
   owner can answer. Hand off — do not start design/code here.

## Output format (required)
```md
## Business outcome (KPI / proxy + time window)
## Root cause (symptom → cause; one sentence)
## Value lever(s)
## Options scored
| Option | Value type | Impact 1-5 | Effort 1-5 | CoD note | Why (basis) |
|---|---|---|---|---|---|
## Smallest value slice
## Assumptions · unknowns · confidence
## Recommendation + what would raise confidence
## Hand off → (decision-brief · /discover · domain-model)
```

**Quality bar:** missing a KPI/proxy (even an estimate with a measurement plan), or missing a
**do-nothing** option in the scored table, **fails this skill — redo it**. Always deliver the
**full** table and confidence block (kit default is `strict`) — do not compress to a vibe-lite
summary.
