# Changelog

All notable changes to `@zusem/smkit` are recorded here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versioning follows [Semantic Versioning](https://semver.org/).

## [0.1.7] — 2026-07-17

### Added
- **`smkit uninstall`** — remove the kit from a project, safely. It deletes the generated agent config (identified by the **ownership manifest** + a live rebuild, so a generated file you have **edited** is kept unless you pass `--force`) and the vendored source (`engine/ profiles/ tools/kitgen/ .kit/hooks/` + templates + build manifest + `kit.config.yaml`), and **never** touches your own content — `.kit/constitution.md`, `.kit/decisions.md`, `.kit/tasks/`. Shows the full plan first; `--dry-run` previews without changing anything, `--yes` skips the prompt (required when there is no TTY, so it can't delete unattended). Run it from a fresh package — `npx @zusem/smkit uninstall` — so it isn't deleting the copy it runs from.

## [0.1.6] — 2026-07-17

### Fixed
- **Zero-question install no longer silently drops Claude Code.** `0.1.5` detection would write only the editors it found a marker for — so a project that had a `.cursor/` folder but no `.claude/` got `agents: [cursor, agentsmd]` and generated **no `.claude/commands/`**, leaving Claude Code with no slash commands and no obvious cause. Detection now keeps a **safe baseline that is never omitted** — `claude` (the primary target) + `agentsmd` (the universal standard) — and only *adds* the other editors it detects (`cursor` / `copilot` / `windsurf`). A pure-Cursor project still gets Claude Code config; nothing is left out without asking. `--agents` still overrides for anyone who wants an exact set.

## [0.1.5] — 2026-07-17

### Added
- **`/onboard`** — on first run the agent reads the codebase, drafts the constitution (what you build · who uses it · what it must never do), **confirms it with you**, and reconciles the stack (proposing per-folder `roots` for a monorepo) before real work begins. Turns a silent install into an accurate setup without a cold interview. The command-routing rule nudges to `/onboard` while the constitution is still placeholders.

### Changed
- **`init` asks nothing by default** — a plain `smkit init` now **infers the project instead of interviewing**: it detects the stack(s) (`go.mod` / `package.json`+`next` / `pyproject.toml`), monorepo per-stack roots under `apps|packages|services/*`, the AI tools in use (`.cursor` / `.github` / `.windsurf` / `CLAUDE.md`), and the project name (`package.json`), writes sensible defaults, and leaves the constitution for `/onboard` to fill. Precedence is **flag > detected > default**; `--interview` re-enables the guided Q&A.

### Fixed
- **Test hygiene** — the test suite leaked one `mkdtemp` copy of the whole kit per scratch dir per run, eventually filling the OS temp dir. Every scratch dir now goes through a tracked helper removed on process exit, so repeated `node --test` runs no longer accumulate. Added detection tests (root · monorepo roots · agents · name); 117/117 pass.

## [0.1.4] — 2026-07-16

### Added
- **Multiple stack profiles per project** — a full-stack repo (e.g. a Go backend + a Next.js frontend) can declare several profiles (`profile: [go, nextjs]`). Each profile's conventions are path-scoped to its own files (Go → `**/*.go`, Next.js → `**/*.tsx`), so they compose without collision. `init` accepts a comma-separated answer (`go,nextjs`).
- **Per-stack root folders (monorepo)** — each stack can be scoped to its own subtree via `stack.roots` (`go: apps/api`, `nextjs: apps/web`); its conventions then apply only there (`apps/api/**/*.go`, `apps/web/**/*.tsx`) instead of repo-wide. `init` asks a folder per stack when several are chosen (scripted: `--roots "go=apps/api,nextjs=apps/web"`); blank = repo-wide.

### Changed
- **`init` asks the language first, then runs the whole interview in that language** — Vietnamese prompts included. No more English-only setup for `vi` users.
- **`init` validates the stack answer** against the known profiles: it ignores unknown entries with a note, **de-duplicates** repeated stacks (a repeated profile used to crash the build on an invariant/rule id clash), coerces an unsupported language back to English, and rejects unsafe folder values — instead of writing an invalid config that only fails later at build time.

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

[0.1.7]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.7
[0.1.6]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.6
[0.1.5]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.5
[0.1.4]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.4
[0.1.3]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.3
[0.1.2]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.2
[0.1.1]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.1
