---
name: brainstorm
description: Use when the path isn't obvious and you need MANY options before choosing — a vague idea, a design with no clear approach, a bug with no obvious cause. Invoke to diverge WIDE first (generate lots, defer judgment, use fixed idea-generation techniques), then cluster and hand the best few to a convergent step (/discover, senior-reasoning). The kit's divergent half — it makes options, it doesn't pick them.
license: Apache-2.0
compatibility: Requires repository read access.
metadata:
  sixmen-version: "1.0.0"
  sixmen-trust-tier: "T0"
  sixmen-owner: platform-team
---

# Brainstorm skill

Generate options before narrowing them. The kit is strong at *choosing between options*
(`/discover`, `/roundtable`, `senior-reasoning`) — but that only works if there are good
options to choose from, and good options come from generating **many** first. Use this at a
genuinely open moment: a fuzzy idea, a design with no obvious approach, a stuck bug. The one
rule that makes brainstorming work: **diverge first, judge later — never at the same time.**

## Rules of divergence (while generating, do NOT evaluate)
- **Quantity first.** Aim for a target count (`vibe`: 5–6 · `standard`/`strict`: 10–15). A weak
  idea often sparks a strong one — kill nothing yet.
- **No "but that won't work."** Defer every objection to the converge step; judging mid-flow
  collapses the space before it opens.
- **Wide, not deep.** One line per idea. Breadth over polish.

## Techniques — use several, not just the first that comes to mind
1. **How-might-we** — restate the problem as an open "how might we …?" and answer it many ways.
2. **First principles** — strip to the fundamental need; what approaches fall out if you ignore
   how it's "normally done"?
3. **Inversion** — how would you make this *worse* or impossible? Invert each into a fix.
4. **Analogy / steal** — how do other domains or well-known products solve this *shape* of
   problem? Borrow shamelessly.
5. **Extremes** — the $10 / one-hour version, and the unlimited-budget version. The right answer
   often hides between them.
6. **Combine & remix** — mash two weak ideas into a stronger third.
7. **Constraint flip** — drop a constraint you assumed fixed, or add a brutal one ("ship today").

## Then converge — hand off, don't decide here
- **Cluster** the raw ideas into themes; name each cluster.
- **Pick the 2–4 most promising** on a quick gut cut (valuable × feasible × novel) — not a full
  analysis.
- **Hand off** those few to `senior-reasoning` / `/discover` / `decision-brief` for the real,
  quantified decision. Brainstorm produces candidates; it does **not** choose the winner.

## Output format (required)
```md
## The open question (one sentence — the "how might we …")
## Raw ideas (wide — hit the count for the mode; no judgment)
- …
## Clusters (themes)
## The 2–4 worth taking forward (+ one line why each earns the cut)
## Handed to → (/discover · senior-reasoning · decision-brief)
```
A brainstorm that produced only 2–3 ideas, or that judged while generating, **failed the diverge
step — go wider and rerun.** Scale to the mode: `vibe` = 5–6 raw ideas + the top 1–2; `standard` /
`strict` = the full wide set, clustered, with the shortlist handed off.
