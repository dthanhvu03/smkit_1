# Changelog

All notable changes to `@zusem/smkit` are recorded here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versioning follows [Semantic Versioning](https://semver.org/).

## [0.1.2] — 2026-07-16

### Added
- **`/ship` triage (step 0)** — `/ship` is now safe to reach for in any situation; it right-sizes itself (whole feature → full run · small step → `/start` path · question → answer/`/review` · emergency → hotfix flow) instead of forcing a full delivery onto small work.
- **Command routing rule** (`05-command-routing`, always-on) — the agent proposes the fitting command from a plain-language goal, so the user never has to memorize which command to use.
- **`/task`** + `.kit/task.template.md` — a prepared, traceable work record (scope · acceptance · impact map · plan · tests · PR) with a **Gate status** checklist that blocks shipping on a red or skipped gate.
- **`/handoff`** + `.kit/handoff.template.md` — a plain-language human-control package (what was delivered · proof · impact & rollback · what to approve) so a non-technical owner stays in control.
- **`git-workflow` skill** (+ reference guide) and integration into `/ship` — branching model, Conventional Commits, PR discipline (small · reviewed · squash), SemVer release tag, and the hotfix flow (off `main`, merged back into both `main` and `dev`).
- **`impact-map` skill** — map every caller, job, event, and test a change touches before editing; wired into `/ship` design and the architect role.
- **`code-craft` rule** — naming, design patterns, and OOP guidance, plus per-stack casing conventions.
- **Risk-required artifacts** (evidence-gate) — turns "should" into "must": schema change → migration note + rollback; money/auth/PII → business walkthrough + a second review; destructive op → a written reversible step.
- `init` now generates a `.gitignore` that keeps secrets, dependencies, build output, and kit runtime state out of git.
- Skill `references/` guides enriched and verified against source for code-review, security-review, test-design, refactor, guard-design, release-check, and decision-brief.

### Changed
- Roles deepened into senior playbooks, each linked to its verified skill reference.
- README and `kit.config.yaml` synced to the current command/skill/profile set.

## [0.1.1]

- Initial published baseline: zero-dependency multi-IDE generator (Claude, Cursor, Copilot, Windsurf, AGENTS.md), guard hooks, modes, roles/skills/rules, and the `/ship` A→Z command.

[0.1.2]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.2
[0.1.1]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.1
