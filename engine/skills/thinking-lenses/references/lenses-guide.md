# Thinking lenses — systems · critical · quantitative · communication

Loaded by `thinking-lenses`. Keep the block short; depth lives in sibling skills.

## 1. Systems (tư duy hệ thống)
Ask: *What moves when this moves?*
- Stocks/flows lightly: backlog, inventory, money, trust — what accumulates or drains?
- Feedback: does success create more load (viral, queue depth) or dampen it?
- Delayed effects: migrate now → lock pain at peak; flag now → support tickets later
- Actors beyond code: ops, CX, finance, legal, partner APIs
Pair with `impact-map` for file-level blast; this lens insists on **human/system** blast too.

## 2. Critical (tư duy phản biện)
Ask: *Why might the leading idea be wrong?*
- Reframe: symptom vs cause (link `smart-value` / premise challenge)
- Steelman the opposition — then answer; strawmen fail the lens
- Stop conditions: what evidence kills the plan?
Pair with `senior-reasoning` moves 1 and 5; this lens makes them non-skippable in the brief block.

## 3. Quantitative (tư duy số liệu)
Ask: *What number, on what basis, and how do we know later?*
- Prefer order-of-magnitude over fake precision
- Always: estimate **or** measurement plan — “we'll see” without a metric fails
- Good: “p95 checkout 800ms → target <400ms; measure via …”
- Bad: “much faster”, “more users”, unlabelled Impact scores
Pair with `smart-value` and task `estimate:` yaml.

## 4. Communication (tư duy truyền đạt)
Ask: *Who decides, and what must they understand in one breath?*
- Audience: founder (outcome/risk) · eng (design/trade-off) · ops (runbook/rollback)
- So-what: the action or decision, not a status dump
- Plain language first; jargon only for technical audience
Pair with `decision-brief` and `/handoff`.

## Anti-patterns
- Four synonyms of the same engineering note
- Systems lens = only a file list (that's impact-map alone)
- Critical lens = “no risks” with no steelman
- Quantitative lens = numbers with no basis or measurement
- Communication lens = pasting the ERD at the founder

## Typical embed order
`smart-value` (if business) → `deliberate-then-act` → **thinking-lenses** (always on
non-trivial) → `senior-reasoning` (contested) → `decision-brief` / design skills.
