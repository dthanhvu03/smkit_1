# Enforcement tiers & evals

Two honest truths shape everything the kit can promise.

## 1. Two enforcement tiers

The kit produces both **mechanically enforced** guarantees and **guidance the model is asked to follow**. Knowing which is which is the difference between "the AI *cannot*" and "the AI *should*".

### Hard (mechanically enforced — the AI cannot bypass)
- **Shell blocklist** — `guard-shell.mjs` blocks destructive commands in every mode. A hook; runs on Claude Code.
- **Critique gate** — `critique-gate.mjs` blocks the first code write of a session in `standard`/`strict` until a critique is recorded. A hook; Claude Code.
- **Consistency guard** — `consistency-guard.mjs` blocks/warns a second library for an existing job. A hook; Claude Code.
- **Generated-config integrity** — `check` / `doctor` fail CI on drift; `doctor` fails on a modified hook (integrity manifest). The generator refuses invalid config, id conflicts, and unsafe roots.

> The hooks are enforced **only where a hook runtime exists** — today that is Claude Code (via `settings.json`). On Cursor / Copilot / Windsurf the same rules ship as **guidance**.

### Soft (guidance — the model reads and should follow, but can drift)
- Every `engine/rules/*` rule body, every `engine/skills/*` skill, every `engine/commands/*` command, on **every** target. These shape behavior; they don't mechanically prevent a violation.
- Markdown scales across all IDEs but cannot *guarantee* compliance. As context grows, a model is more likely to drift from a soft rule — the exact failure the critique gate (hard) exists to catch.

**Design principle:** if a rule must never be bypassed, it needs a **hook or a generator/CI check** — not just a paragraph. Put safety-critical invariants behind a hard tier; use soft rules for judgment and craft.

## 2. Evals — measuring soft-rule compliance

Because soft rules can drift, "does the kit actually work?" is an **empirical** question, not a matter of faith. The plan, in increasing depth:

1. **Audit trail (shipped).** Every guard decision is appended to `.kit/audit.log` (`guard-shell`, `critique-gate`, `consistency-guard`). This is the raw signal: what was blocked, warned, allowed, and when.
2. **Compliance checklist (shipped).** Before a release, `release-check` verifies the guardrails were actually followed for the change: a critique gate token existed before code, the evidence gate is satisfied (tests run + quoted), invariants weren't violated, and decisions were logged. A red item is a process miss to fix, not a rubber stamp.
3. **Automated evals (future).** A harness that replays representative tasks and scores whether the agent followed the guardrails — e.g. did it run `/challenge` before coding, did generated code respect the invariants, did it refuse an injected instruction (hard-rule 8). This turns "the kit helps" from a claim into a number, and closes the enforcement-ceiling gap for the soft tier.

Until (3) exists, treat the soft tier as *coaching with an audit trail*, and reserve hard guarantees for what a hook or CI check actually enforces. Say so plainly to users — over-claiming enforcement is itself a failure mode.
