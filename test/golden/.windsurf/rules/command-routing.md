---
# GENERATED — DO NOT EDIT. Edit engine/ or kit.config.yaml, then run: kit build
trigger: always_on
---

# Routing — propose the fitting command, don't make the user memorize

The user talks in plain language and should never have to know which slash command to use. When they describe a goal **without** naming a command, silently classify the intent, then **propose the fitting command in one plain sentence and confirm** before running it. Say what the command does in the user's terms, not jargon. If they already typed a command, respect it.

Intent → command:

| What the user is really asking for | Propose | 
|---|---|
| First use / the constitution is still placeholders | `/onboard` — read the project & fill setup |
| Deliver a whole feature (idea → shipped) | `/ship` — the full A→Z run |
| A small next step, or continue mid-feature | `/start` — or **`/resume`** first if this is a **new chat/session** |
| New chat / "continue where we left" / pick up mid-feature / afraid of losing context | **`/resume`** — re-read SoT + active task + handoff, restate, then continue |
| Build or change a screen / component / styling (UI) | `/start` — routes to the **frontend** role (ui-design → ui-review) |
| Add/change an API / endpoint / route / handler / RPC | **api-design** skill (contract first), then `/start` or `/ship` → **implementer** |
| Deploy / release to staging or prod / rollback / "ship it live" | **ops-deploy** (+ **release-check**), then **devops** — never skip rollback/smoke |
| Add or change CI/CD / GitHub Actions / deploy pipeline | **ci-pipeline** skill, then **devops** (ops-surface paths) |
| Queue / worker / job / outbox / saga / webhook consumer | **async-workflows** skill, then `/start` or `/ship` → **implementer** (async-surface) |
| Terraform / Pulumi / CDK / infra modules / cloud IaC | **infra-iac** skill, then **devops** (+ **ops-deploy** when applying live) |
| Stuck / need many ideas / no obvious approach yet | **brainstorm** skill (diverge wide), then `/discover` to decide |
| Grow revenue / cut cost / ops pain / prioritize backlog / "is this worth doing?" | **smart-value** skill, then `/discover` |
| App direction clear but no/stale domain brief · "research the market/competitors" · one-way-door needs domain facts | **domain-research** skill (write `.kit/domain-brief.md`) — not every casual reply |
| Non-trivial decision / about to design or code / "think first" | **deliberate-then-act** skill (scratchpad), then `senior-reasoning` if contested |
| "Should we build this? what are the options?" (vague / new) | `/discover` |
| "Is this change safe?" before coding | `/challenge` |
| Prepare/track a piece of work (scope, plan, impact) | `/task` |
| A contested or non-trivial choice between roles | `/roundtable` |
| Look at a diff / code without building | `/review` |
| Check the project for inconsistency / drift | `/checkup` |
| Record a decision that was made | `/decide` |
| Something broke / a bug shipped — learn from it | `/postmortem` |
| Hand finished work back to the owner to review / approve | `/handoff` |
| Just a question or explanation | no command — answer directly |

Rules of thumb:
- **Onboard first if the project is unset.** If `.kit/constitution.md` still holds placeholders (`<describe…>`), the kit was installed zero-question — offer `/onboard` before real work so the AI understands the project.
- **Don't over-serve.** A one-line fix or a plain question does not need `/ship`; offer the lightest path that fits. Reserve the heavy pipeline (and its gates) for real deliveries so the gates keep their meaning.
- **When in doubt, offer two.** e.g. *"Sounds like a whole feature — run `/ship`? Or just a quick fix with `/start`?"* Let the user pick.
- **Scale to the mode.** In `vibe`, keep the suggestion to a few words and move; in `standard`/`strict`, name the command and the gates it will run.
- `/ship` is the safe default front door: if the user reaches for it for something small, it right-sizes itself (see the triage in `/ship`).
