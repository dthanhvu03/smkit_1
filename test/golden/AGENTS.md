<!-- GENERATED — DO NOT EDIT. Edit engine/ or kit.config.yaml, then run: kit build -->

# Golden Fixture — agent instructions (AGENTS.md)

Mode: vibe — move fast, talk in plain language, keep the codebase consistent. Guardrails are always on.

Read the Constitution (.kit/constitution.md) and Decision Log (.kit/decisions.md) before coding.

# Hard rules — always apply, every turn

1. **Guardrails never off.** Never run destructive commands (see the blocklist). They are blocked in every mode; you may propose alternatives, never bypass.
2. **Read the project memory before coding.** At session start you are given the Constitution and Decision Log. Follow them. Do not re-decide something already decided there.
3. **Consistency first.** Reuse existing patterns, names, folders, and libraries. Do NOT introduce a second way to do something that already has a way. If you must, STOP and ask in plain language.
4. **Record decisions.** When you make a non-trivial technical choice (a library, a structure, a naming convention), append it to the Decision Log so future sessions stay consistent.
5. **Match the mode.** `vibe` = move fast, minimal ceremony, talk to the user in plain (non-technical) language. `standard` = brief + self-review + tests. `strict` = full gate chain + human approval for schema/prod/data.
6. **Approvals are real.** For anything listed under `approvers` (schema change, prod deploy, data delete), stop and get sign-off unless the approver list is empty (self-approve).

# Evidence gate — don't claim done without proof

- **Never report a task as done, passing, or fixed without evidence.** State what you actually ran and its result.
- If tests exist: run them and quote the outcome (pass/fail counts). If they fail, say so with the output — do not hide it.
- If there are no tests: describe concretely how you verified the behavior (what you ran, what you observed).
- If a step was skipped or is unverified, say that plainly — don't imply it was checked.
- Skills that produce a review/verdict (code-review, test-design) must fill their **Test evidence** section; an empty evidence section means the gate is not satisfied.

# Conventions (generic profile)

- One way to do each thing. Pick a single approach for state, styling, data access, and routing; record it in the Decision Log and reuse it everywhere.
- Small, readable changes. Prefer clarity over cleverness.
- Keep files where similar files already are. Don't invent a new top-level folder without recording why.
- No secrets in code. Use env/config.

## Roles
- **analyst** — Use FIRST when a request is vague, new, or comes from a non-technical person — before any planning, design, or code. Invoke for turning a fuzzy idea into a decision the founder can make. Not for step sequencing (planner) or structural/interface design (architect).
- **architect** — Use when a change affects structure, module boundaries, interfaces, data shape, or library choice. Invoke for system design, tradeoff decisions, and recording them in the Decision Log. Not for step sequencing (that is the planner).
- **devops** — Use for release, build, deploy, backup, and environment or CI tasks. Invoke for shipping, operational safety, and infrastructure changes.
- **implementer** — Use to write or edit code once a plan or decision exists. Invoke for building features, fixing bugs, and wiring things up while following existing patterns. The default worker for changing code.
- **orchestrator** — Use to start, resume, or route a task across roles. Invoke for coordinating a small team (1-3 roles), sequencing gates by mode, and plain-language checkpoints. Does not implement code in strict mode.
- **planner** — Use when a request needs breaking into steps, scope, and a definition of done BEFORE any design or code. Invoke for task decomposition, sequencing, and clarifying intent. Not for structural or interface decisions (that is the architect).
- **qa** — Use when a feature must be validated to actually work. Invoke for running tests, checking acceptance criteria, and reproducing behavior at runtime. Not static diff review (that is the reviewer).
- **reviewer** — Use immediately after code is written or changed, before finishing. Invoke for static review of a diff — correctness bugs, consistency with recorded decisions, style and security smells. Does not run the app (that is qa).

## Skills
- **code-review** — Use when there is a diff or changed code to check before finishing. Invoke for correctness bugs, consistency with recorded decisions, and style or security smells.
- **decision-brief** — Use when a request is vague or new and a build decision has not been made yet. Invoke to turn a fuzzy idea into a founder-ready brief — the real problem, options with trade-offs, rough cost/risk, and the smallest slice worth building.
- **guard-design** — Use when adding or changing hooks/guardrails (guard-shell, consistency-guard, blocklist, path boundaries). Invoke to design the BLOCK/WARN/ALLOW behavior and the bypass tests that prove it.
- **pre-build-critique** — Use BEFORE writing or editing code for a new or non-trivial change. Invoke to challenge the change through fixed lenses — correctness, security & data, consistency, simplicity, reversibility — and record a go/adjust/stop verdict before building.
- **refactor** — Use when changing structure without changing behavior. Invoke to plan a safe refactor with impact analysis and a rollback path before touching code.
- **release-check** — Use before publishing or releasing (npm publish, tag, deploy). Invoke for a pre-release checklist covering version, changelog, tests, and a go/no-go verdict.
- **security-review** — Use when a change touches auth, secrets, shell/command execution, file access, or the guard/hooks. Invoke for a risk assessment with concrete exploit scenarios and fixes.
- **test-design** — Use when a task needs a QA or test gate. Invoke to design test cases and edge cases and to produce the exact commands that prove the behavior works.

## Commands
- `/challenge` — Run the pre-build critique — stress-test the planned change through fixed lenses and record a go/adjust/stop verdict before any code is written.
- `/checkup` — Audit the project against its Constitution and Decision Log, report drift in plain language, and offer to fix it.
- `/decide` — Append a technical decision to the Decision Log so future sessions stay consistent.
- `/discover` — Start here when the idea is still fuzzy. Reframes the request as a problem, weighs options, and produces a founder-ready decision brief BEFORE any planning or code.
- `/review` — Review the current changes for correctness and consistency with the recorded decisions before finishing.
- `/start` — Begin (or resume) work. Reads the project memory, plans the smallest next step, and builds it per the current mode.
