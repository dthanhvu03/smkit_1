<!-- GENERATED — DO NOT EDIT. Edit engine/ or kit.config.yaml, then run: kit build -->

# /start

> Use `/start` for the **smallest next step**. To deliver a **whole feature** A→Z (discovery → build → review → deploy) in one orchestrated run, use `/ship` instead. If this is a **new chat** continuing unfinished work, run **`/resume` first** so scope comes from `.kit/` files, not invented chat memory.

0. **Session check** — if `.kit/state/current-task` points at an open task (or an `in-progress` task exists) and the user is continuing that work, treat **`/resume`** as already done only when this turn already restated In/Out + next slice; otherwise run `/resume` (or perform its steps inline) **before** planning new scope.
1. Read `.kit/constitution.md` and `.kit/decisions.md`. Obey them. If an active task file exists, obey its **In/Out** — do not expand Out silently.
2. If the user gave a request, restate it in one plain sentence and confirm. If not, ask what they want to build.
   - If the idea is **vague or a brand-new feature**, run discovery first (`/discover`, the analyst role): produce a decision brief and confirm the real problem before building. Scale to the mode — `vibe`: a 3–5 sentence brief inline; `standard`/`strict`: the full brief (strict also records sign-off).
3. Plan the **smallest useful next step** (not the whole thing). For a non-trivial piece of work, open a task first (`/task` → `.kit/tasks/<id>.md`) so its scope, impact, and plan are written down and resumable; a one-line fix doesn't need one. **Continuing** an existing task → update that file; do not open a duplicate task for the same feature.
   - Before writing code for a new/non-trivial change, run **`deliberate-then-act`** (scratchpad), then **challenge it** (`/challenge`, the pre-build-critique skill): correctness · security & data · consistency · simplicity · reversibility → a go/adjust/stop verdict. In `standard`/`strict` a hook blocks the first code write until critique is recorded; in `vibe` it only reminds.
   - If the step adds or changes an **API / endpoint / handler**, run **`api-design`** first (contract, error envelope, authz) before implementer codes.
   - Queue / worker / saga → **`async-workflows`** first. Terraform/Pulumi/CDK → **`infra-iac`** (devops).
   - UI screens/components → **frontend** (ui-design → ui-review), not a blind implementer dump.
4. Build it following the current mode:
   - `vibe`: just do it, reuse existing patterns, talk in plain language.
   - `standard`: short brief → build → self-review → run tests.
   - `strict`: full gate chain; get approver sign-off for schema/prod/data.
5. When a non-trivial decision is made, append it to `.kit/decisions.md`.
6. Finish with a plain-language summary of what changed and ask what's next. Keep the task Status current so the **next** session's SessionStart / `/resume` stays accurate.
