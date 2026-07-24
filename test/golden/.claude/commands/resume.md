---
# GENERATED — DO NOT EDIT. Edit engine/ or kit.config.yaml, then run: kit build
description: "Pick up work in a new chat/session without drifting — re-read Constitution, decisions, domain brief, active task, and latest handoff, then restate where you are and the next slice only."
argument-hint: "[optional task id]"
---

# /resume

**Re-ground this session before doing anything else.** Chat memory is not the source of truth — `.kit/` files are. Use this at the start of a new conversation when continuing a feature, or whenever the agent might invent a new direction.

1. **Load SoT (mandatory, in order).** Read and obey:
   - `.kit/constitution.md`
   - `.kit/decisions.md` and any `.kit/decisions/*.md`
   - `.kit/domain-brief.md` if filled (do **not** re-research unless triggers fire)
   - **Active task:** id from `.kit/state/current-task`, or the `$ARGUMENTS` id, or the newest `.kit/tasks/*.md` with Status `in-progress` — then read `.kit/tasks/<id>.md` fully
   - Latest handoff if present: `.kit/tasks/<id>-handoff.md` (or the newest `*-handoff.md`)
2. **Restate in plain language (required output before tools that change the repo):**
   - What the product is (one line from constitution)
   - Active task title + Status + **In** / **Out**
   - Which gates are already green vs still open
   - Next **smallest** slice from the task Plan (or from handoff “your decision needed”)
   - Anything that would expand **Out** or contradict a Decision → list as a question; **do not code it**
3. **Confirm with the user** in one short block: “Continuing TASK-\<id\>: … Next slice: … OK?”
4. **Only after confirm** (or explicit “continue”): proceed with `/start` / `/ship` triage for that slice — still run `deliberate-then-act` + `/challenge` when the mode requires it for new code. Do **not** open a second parallel task for the same work.
5. If there is **no** task and no handoff: say so, offer `/onboard` (if constitution is placeholders) or `/task` / `/discover` — do not invent scope.

Scale: `vibe` = short restatement + next step; `standard`/`strict` = full restatement including gates and Out-of-scope. **Fail closed:** if SoT files conflict with the user’s casual ask, stop and confirm — never silently widen scope.
