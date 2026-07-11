<!-- GENERATED — DO NOT EDIT. Edit engine/ or kit.config.yaml, then run: kit build -->

# Golden Fixture — Copilot instructions

Project agent instructions. Core rules live in .claude/rules/ (auto-loaded). Roles live in .claude/agents/.

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
