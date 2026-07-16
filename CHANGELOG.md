# Changelog

All notable changes to `@zusem/smkit` are recorded here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versioning follows [Semantic Versioning](https://semver.org/).

## [0.1.4] — 2026-07-16

### Added
- **Multiple stack profiles per project** — a full-stack repo (e.g. a Go backend + a Next.js frontend) can declare several profiles (`profile: [go, nextjs]`). Each profile's conventions are path-scoped to its own files (Go → `**/*.go`, Next.js → `**/*.tsx`), so they compose without collision. `init` accepts a comma-separated answer (`go,nextjs`).
- **Per-stack root folders (monorepo)** — each stack can be scoped to its own subtree via `stack.roots` (`go: apps/api`, `nextjs: apps/web`); its conventions then apply only there (`apps/api/**/*.go`, `apps/web/**/*.tsx`) instead of repo-wide. `init` asks a folder per stack when several are chosen (scripted: `--roots "go=apps/api,nextjs=apps/web"`); blank = repo-wide.

### Changed
- **`init` asks the language first, then runs the whole interview in that language** — Vietnamese prompts included. No more English-only setup for `vi` users.
- **`init` validates the stack answer** against the known profiles and ignores unknown/duplicate entries with a note, instead of writing an invalid config that only fails later at build time.

## [0.1.3] — 2026-07-16

### Added
- **`smkit update`** — refresh a project's self-contained kit source to a new version while **preserving your own content** (`kit.config.yaml`, `.kit/constitution.md`, `.kit/decisions.md`, `.kit/tasks/`, `.gitignore`). It backs up the previous source to `.smkit-backup/`, rebuilds, and reports the version delta. Run `npx @zusem/smkit@latest update` (it must be pulled from a fresh package — a project's own frozen copy has nothing newer). `init` now stamps `.kit/.smkit-version` so updates know the baseline.
- The update is **safe by construction**: it validates the incoming package is complete before touching anything, applies the refresh transactionally and **rolls back from the backup** if any step fails (so a project is never left half-updated or with a deleted directory), and **refuses a silent downgrade** unless `--force`.

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

[0.1.4]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.4
[0.1.3]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.3
[0.1.2]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.2
[0.1.1]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.1
