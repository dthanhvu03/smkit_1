---
id: ship
title: Deliver a feature end to end
description: Take a request from idea to shipped — discovery, critique, design, build, review, QA, and deploy — running the whole team pipeline and pausing only where you must decide. For a whole feature; use /start for a small next step.
argument-hint: "[the feature you want delivered]"
---

# /ship

Run the full delivery pipeline for one feature, coordinating the team (the orchestrator role). This is the single A→Z entrypoint: it sequences every stage and gate, and pauses for you (the founder) only at real decision points. Respect every gate; scale the ceremony to the mode.

1. **Frame** — read `.kit/constitution.md` and `.kit/decisions.md`; restate the request as a problem in one plain sentence and confirm. For anything non-trivial, **open a task** now (`/task` → `.kit/tasks/<id>.md`); the stages below fill it in (scope, impact, plan) so the work is traceable and resumable.
2. **Discover** — if the idea is vague or new, run `/discover` (analyst → decision brief); record the **scope** and **acceptance criteria** in the task. Present it and get a go / adjust / stop decision before building. ⟵ *your decision*
3. **Challenge** — run `/challenge` (pre-build critique: correctness · security & data · consistency · simplicity · reversibility) and record the verdict. In `standard`/`strict` a hook blocks code until this is done.
4. **Design** — planner breaks it into the smallest useful slices with a definition of done; architect fixes structure and records decisions. For a change touching shared data or behavior, run the **impact-map** skill first — map every caller, job, event, and test it touches before editing — and record it in the task. If a choice is contested, run `/roundtable` (bounded — converge or escalate, never loop forever).
5. **Build** — start on a `feature/*` branch (**git-workflow** skill — never on `main`/`dev`); implementer writes each slice following existing patterns, committing small, atomic Conventional Commits as it goes. Pull in specialists as needed: db-admin (schema/migrations), debugger (failures), git-manager (branches/commits/PR), docs-manager (docs ↔ code).
6. **Verify** — reviewer reads the diff (correctness + consistency); qa runs the tests and confirms behavior. Nothing is "done" without evidence (the evidence gate).
7. **Ship** — open a small, described **pull request** (git-workflow: reviewed, squash-merged — no self-merge, no merge on red tests); if the change touches schema / prod / data, get the approver's sign-off; tag the release (SemVer, via **release-check**); then devops deploys with a reversible, backed-up step. An emergency production fix uses the hotfix flow (branch off `main`, merge back into BOTH `main` and `dev`). ⟵ *your decision (strict)*
8. **Close** — append the decisions made to `.kit/decisions.md` and give a plain-language summary of what was delivered.

Scale to the mode: `vibe` = move fast, compress the checkpoints, talk plainly; `standard` = brief + review + tests at each stage; `strict` = full gate chain + human approval for schema/prod/data.

If any stage says stop — a critique verdict of *stop/adjust*, failing tests at the evidence gate, a missing approval, a blocked command — **stop and tell the founder in plain language**. Never push past a gate to "finish" the pipeline.
