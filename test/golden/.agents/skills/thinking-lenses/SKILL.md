---
# GENERATED — DO NOT EDIT. Edit engine/ or kit.config.yaml, then run: kit build
name: "thinking-lenses"
description: "Use on every non-trivial decision, discovery, or design — invoke to force four thinking lenses before recommending or coding: systems (feedback & blast radius), critical (steelman & premise), quantitative (numbers + how to measure), and communication (audience & so-what). The unified checklist that stops one-sided reasoning."
license: "Apache-2.0"
compatibility: "Requires repository read access."
metadata:
  sixmen-version: "1.0.0"
  sixmen-trust-tier: "T0"
  sixmen-owner: "platform-team"
---

# Thinking Lenses skill

Four lenses, one short block. Senior work fails when the agent is strong on craft but weak
on systems, critique, numbers, or explaining to a human. This skill does **not** replace
`senior-reasoning`, `smart-value`, or `decision-brief` — it is the **mandatory cross-cut**
they (and `/ship` Design) must include.

Work from **[references/lenses-guide.md](references/lenses-guide.md)**.

## When to run
- Non-trivial `/discover`, `/ship` Design, `/challenge`, `/roundtable`, or any recommendation
  that commits scope, structure, money, or prod risk
- Skip only: pure explanation, one-line typo with no behavior change, or when this turn
  already contains a complete **Thinking lenses** block for the **same** decision

## The four lenses (all required)
1. **Systems** — What else moves when this moves? Feedback loops, delayed effects, other
   teams/jobs/CX/ops — not only files. Who feels pain if this is wrong?
2. **Critical** — Challenge the premise; strongest case *against* the leading option
   (steelman) + honest answer. What would make us stop?
3. **Quantitative** — At least one number or explicit estimate (size, time, cost, rate,
   Impact×Effort) with **basis**, plus **how we will measure** success (or “estimate —
   measurement plan: …”). Never launder a guess as fact.
4. **Communication** — Who must understand this (founder / eng / ops)? One plain **so-what**
   sentence they can act on; jargon only if the audience is technical.

## Workflow
1. If `smart-value` / `senior-reasoning` / `decision-brief` / `deliberate-then-act` is
   already running, **embed** the lenses block in their output — do not duplicate essays.
2. Fill all four lines with real content (see quality bar).
3. Hand off: deeper systems map → `impact-map`; deeper critique → finish `senior-reasoning`;
   KPI scoring → `smart-value`; founder packaging → `decision-brief` / `/handoff`.

## Output format (required)
```md
## Thinking lenses
- **Systems:** <feedback / blast beyond the diff / who else feels this>
- **Critical:** <premise check · steelman against leading option · answer>
- **Quantitative:** <number or estimate + basis · how we measure>
- **Communication:** <audience · one so-what sentence>
```

**Quality bar:** missing any lens, or a lens that is empty / “N/A” / “looks fine” without a
precise why, **fails — redo**. `vibe` = four tight bullets; `strict` = same four with
because/so-what on Critical and a real measurement plan on Quantitative.
