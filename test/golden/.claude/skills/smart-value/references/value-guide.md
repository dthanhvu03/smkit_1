# Business value reference — outcome, cause, and what to build first

Loaded on demand by the `smart-value` skill (progressive disclosure). Compiled from the
frameworks listed at the end. Written so a non-technical founder can follow the numbers.

## 1. Outcome before solution
A request usually names a *feature* ("add a dashboard", "automate approvals"). Restate
**success as a measurable change**: who benefits, which KPI or honest proxy moves, from what
baseline to what target, in what time window. If the baseline is unknown, say so and propose
how to measure — never launder a guess as a fact.

Examples of acceptable outcomes:
- Revenue / conversion: "checkout completion 42% → 50% in 6 weeks"
- Cost: "warehouse recount hours 12h/week → ≤4h/week"
- Risk: "zero unlogged stock adjustments after go-live"
- Ops speed: "PO approval median 2 days → same day"
- Experience: "support tickets about X down 30% in 30 days" (proxy OK if labelled)

## 2. Root cause — symptom vs cause
Pain is not always the place to build. Use **up to five Whys**, or a **one-level MECE**
split (e.g. demand · process · tools · people · data), and stop when a different cause would
not change the fix. Record one sentence: *symptom → cause*.

## 3. Value levers (pick 1–2 primary)
| Lever | Typical signal |
|---|---|
| Revenue | conversion, AOV, retention, new paid users |
| Cost | hours, rework, tooling spend, scrap / waste |
| Risk / compliance | error rate, audit gaps, legal exposure |
| Ops speed | cycle time, queue depth, handoff count |
| Customer experience | NPS/CSAT, tickets, time-to-resolution |

Secondary levers are fine as context; scoring should weight the primary ones.

## 4. Impact × Effort and Cost of Delay
Score each option **Impact 1–5** (size of outcome move) and **Effort 1–5** (time/cost/risk
to deliver). Prefer high impact / low effort first. Add a one-line **Cost of Delay**: what is
lost each week this stays undone (missed revenue, ongoing burn, compounding risk).

**Every score needs a basis** — the assumption or rough count behind the number. "Impact 4
because ~200 orders/week × 5% lift ≈ 10 orders" beats "Impact 4, feels big."

## 5. Non-build options are first-class
The option set is incomplete without:
- **Do nothing** — keep current process; state the CoD of that choice.
- **No-code / process workaround** — spreadsheet, checklist, manual role, existing tool —
  often the fastest way to learn whether software is worth it.

## 6. Smallest value slice
Build (or trial) the **minimum** that either (a) captures most of the valued outcome, or
(b) falsifies the riskiest assumption with real users/ops. Hand the packaged decision to
`decision-brief` / `/discover`; hand domain shape to `domain-model` only after value is clear.

## 7. Estimates are not promises
Label every figure an **estimate**. State confidence (low / med / high) and what evidence
would raise it (a week of logs, a pilot, a count from the founder).

---

## Sources
- Donald Reinertsen — *The Principles of Product Development Flow* (Cost of Delay).
- ICE / RICE-style prioritization (Impact · Confidence · Effort; Reach · Impact · Confidence · Effort) — used here in a simplified Impact×Effort form with an explicit basis.
- Taiichi Ohno / Toyota — Five Whys (root-cause discipline).
- MECE issue trees — common strategy / ops problem structuring (mutually exclusive, collectively exhaustive at one level).
- Clayton Christensen — Jobs to be Done (complements `decision-brief`; who hires the outcome).

> Provenance note: compiled from established product and ops frameworks. Prefer real
> baselines from the founder or system data over invented precision.
