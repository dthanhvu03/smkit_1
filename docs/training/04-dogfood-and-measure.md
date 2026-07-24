# Week 4 — Dogfood & measure

Goal: prove the kit+DNA+domain skill work on **real tasks**, then fix gaps. Training without measurement is theater.

## How to dogfood

1. Copy [templates/dogfood-log.md](templates/dogfood-log.md) to `.kit/training/dogfood-log.md` (or keep under `docs/` in your company repo).
2. Run **10 tasks** (mix: 2 tiny, 5 normal, 3 business/domain). Prefer real work over toys.
3. For each task, tick the checklist row **before** calling it done.
4. After 10, fill [templates/kpi-scorecard.md](templates/kpi-scorecard.md).
5. Fix the top red themes in constitution / invariants / skills — not by “reminding the model”.

## Per-task checklist (copy into each log row)

- [ ] Constitution / decisions considered (or N/A documented)
- [ ] Business ask → `smart-value` or already-agreed KPI
- [ ] Vague idea → `/discover` / decision-brief before code
- [ ] Non-trivial → `/challenge` (critique) before first code write
- [ ] Domain touch → domain skill output present
- [ ] Evidence gate: tests **named** + command output (or honest “not run”)
- [ ] `/handoff` readable by a non-coder
- [ ] Schema/prod/data → human approval recorded (or N/A)

## Target KPIs (after 10 tasks)

| KPI | Target |
|-----|--------|
| Tasks with AC / scope before code | ≥ 90% |
| Business tasks with smart-value or explicit KPI | ≥ 80% |
| Handoffs approvable without extra live explanation | ≥ 70% |
| Domain skill invoked when path matched | ≥ 80% of domain tasks |
| Must-never violations caught (audit / review) | trending down |

⚠ These are **targets**, not promises. Baseline = first 10 tasks; compare the next 10 after fixes.

## Audit signals

- `.kit/audit.log` — guard / critique decisions  
- `smkit doctor` / `smkit check` — config drift  
- Red handoff gates — process miss, not “almost done”

## Cadence after Week 4

- Monthly: 5 dogfood samples + update scorecard  
- Each new domain skill: ≥1 dogfood task before merge to main kit  
- Soft-rule drift → consider invariant or hook, not a longer always-on essay

## Related

- [enforcement-and-evals.md](../enforcement-and-evals.md)  
- Back to index: [README.md](README.md)
