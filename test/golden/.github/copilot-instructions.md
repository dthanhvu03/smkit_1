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
7. **Secrets stay out of chat and code.** Never paste real secrets, `.env` files, tokens, production data, or customer info into the prompt (use placeholders), and never commit them. If a secret is exposed, tell the user to **rotate** it — deleting the text is not enough.

# Routing — propose the fitting command, don't make the user memorize

The user talks in plain language and should never have to know which slash command to use. When they describe a goal **without** naming a command, silently classify the intent, then **propose the fitting command in one plain sentence and confirm** before running it. Say what the command does in the user's terms, not jargon. If they already typed a command, respect it.

Intent → command:

| What the user is really asking for | Propose | 
|---|---|
| Deliver a whole feature (idea → shipped) | `/ship` — the full A→Z run |
| A small next step, or continue mid-feature | `/start` |
| "Should we build this? what are the options?" (vague / new) | `/discover` |
| "Is this change safe?" before coding | `/challenge` |
| Prepare/track a piece of work (scope, plan, impact) | `/task` |
| A contested or non-trivial choice between roles | `/roundtable` |
| Look at a diff / code without building | `/review` |
| Check the project for inconsistency / drift | `/checkup` |
| Record a decision that was made | `/decide` |
| Hand finished work back to the owner to review / approve | `/handoff` |
| Just a question or explanation | no command — answer directly |

Rules of thumb:
- **Don't over-serve.** A one-line fix or a plain question does not need `/ship`; offer the lightest path that fits. Reserve the heavy pipeline (and its gates) for real deliveries so the gates keep their meaning.
- **When in doubt, offer two.** e.g. *"Sounds like a whole feature — run `/ship`? Or just a quick fix with `/start`?"* Let the user pick.
- **Scale to the mode.** In `vibe`, keep the suggestion to a few words and move; in `standard`/`strict`, name the command and the gates it will run.
- `/ship` is the safe default front door: if the user reaches for it for something small, it right-sizes itself (see the triage in `/ship`).

# Evidence gate — don't claim done without proof

- **Never report a task as done, passing, or fixed without evidence.** State what you actually ran and its result.
- If tests exist: run them and quote the outcome (pass/fail counts). If they fail, say so with the output — do not hide it.
- If there are no tests: describe concretely how you verified the behavior (what you ran, what you observed).
- If a step was skipped or is unverified, say that plainly — don't imply it was checked.
- Skills that produce a review/verdict (code-review, test-design) must fill their **Test evidence** section; an empty evidence section means the gate is not satisfied.

# Conventions (generic profile)

- One way to do each thing. Pick a single approach for state, styling, data access, and routing; record it in the Decision Log and reuse it everywhere.
- **Naming:** intention-revealing (a reader understands without the body); no cryptic abbreviations. Follow the language's standard casing.
- Small, readable changes. Prefer clarity over cleverness.
- Keep files where similar files already are. Don't invent a new top-level folder without recording why.
- No secrets in code. Use env/config.
