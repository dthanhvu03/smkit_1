# Changelog

All notable changes to `@zusem/smkit` are recorded here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versioning follows [Semantic Versioning](https://semver.org/).

## [0.1.15] — 2026-07-17

### Fixed
- **No more "smkit: command not found" in a self-contained install.** The default install vendors the kit into the project — there is no global `smkit` on `PATH` — but `init`/`update`'s closing messages and the README implied there was. They now show the exact way to run commands in a self-contained project: `node tools/kitgen/kitgen.mjs <doctor|build|check>` (or `npm i -g @zusem/smkit` for the `smkit` shortcut). A founder following the on-screen instructions no longer hits a dead end.

## [0.1.14] — 2026-07-17

### Fixed
- **`smkit update` no longer leaves a project in drift.** Two bugs found by dogfooding a real update:
  - The post-update rebuild now runs with **`--force`**, so the generated output fully syncs to the freshly-replaced engine. Before, output left over from the old engine read as "locally modified" and was protected/skipped, leaving the project with dozens of `doctor` drift errors. (A user's hand-edit to a generated file is still backed up to `<file>.bak` first.)
  - **Update self-heals instead of trusting the version stamp.** On a same-version run it now compares the installed kit files against the package byte-for-byte; if they differ (a stamp that advanced while the source stayed stale — e.g. a mixed `npx` cache, or a bad earlier update), it **re-syncs** them rather than saying "nothing to do". Only a genuine byte-for-byte match short-circuits.
- **README documents the `npx` stale-cache trap** — if `update` reports "already on X" despite a newer release, `npx` may be serving a cached package; pin the version (`npx @zusem/smkit@0.1.14 update`) or use `npx --ignore-existing`.

## [0.1.13] — 2026-07-17

Closes the remaining P1 roadmap items — the four deferred "hard" ones.

### Added
- **Automatic skill quality rubric** — doctor now holds skills to a hiring-bar like roles: a heuristic check that each skill body has an ordered **workflow**, a defined **output/structure**, and a **quality bar** (what good/done is). Missing one is a `SKILL_QUALITY_INCOMPLETE` warning (multilingual), never a blocker.
- **Machine-readable, justified estimates** — the task template carries a parseable `estimate:` block (complexity S/M/L/XL · effort_days · confidence 0..1 · risk · a required **basis**), and `estimate.mjs` parses + sanity-checks it: flags an XL task to slice, a low-confidence guess to de-risk, bad enums/ranges, and an empty basis ("a number with no basis is a guess"). `/task` instructs filling it like a real quote — every number an estimate, not a promise.
- **`smkit eval`** — a deterministic scorecard for the **hard-tier** guardrails: guard blocks/allows the right commands, the critique gate denies an unchallenged strict write and opens with a token, invalid config is rejected, the prompt-injection rule is actually emitted, settings-merge preserves a user hook, the integrity map covers the hooks. Prints pass/total (`--json` for CI, non-zero exit on failure). Scoped honestly to the mechanical tier; soft/model compliance needs a model-graded run (documented).

### Changed
- **Per-task critique gate.** The gate was session-scoped — one critique opened it for every later edit, even a different task. The token now carries a `task` id checked against the active task (`.kit/state/current-task`, set by `/task`); switching tasks re-opens the gate. Fully **backward-compatible**: with no active task it is exactly the old session-scoped check, so vibe/no-`/task` flows are unchanged. Verified end-to-end through the hook.

## [0.1.12] — 2026-07-17

### Changed
- **`/ship` now reflects the 0.1.11 depth pass end-to-end.** Its Challenge step names the **pre-mortem** and one-way/two-way door lenses; its Build step points high-stakes paths (money · booking · inventory · external calls) at the **reliability** rule (idempotency, guarded shared state, timeouts, observable failures). The domain-model skill was already wired into the Design step in 0.1.11.

## [0.1.11] — 2026-07-17

A depth pass — the techniques and thinking a senior team applies, added across four areas.

### Added — thinking the kit coaches for the user's code
- **`domain-model` skill** — the bridge from a vague idea to correct software: name the entities (in the founder's words), the states each moves through (a state machine with legal transitions), and the invariants that must always hold, so illegal states are designed out rather than patched. Wired into `/discover` and `/ship` design.
- **`reliability` rule** (path-scoped, zero always-on cost) — correctness under **concurrency & idempotency** (no double-charge/double-book; guard shared state at the DB), **failure modes** (timeouts, retry-only-idempotent, graceful degradation, consistent partial failure), and **observability** (structured logs at the edges, surface failures). Aimed at the founder's high-stakes domains.

### Added — process thinking
- **Pre-mortem** and explicit **one-way vs two-way door** lenses in `pre-build-critique` / `/challenge`; one-way/two-way door elevated in `decision-brief`.
- **`/decide` now records ADRs** (context · decision · alternatives · consequences · reversibility), superseding rather than deleting.
- **`/postmortem`** — blameless incident learning: root cause (5 Whys) → the bug *class* → a concrete prevention wired in (test/invariant/guard), recorded as a decision.

### Added / Fixed — the kit's own hardening
- **Fuzz / property tests**: `parseYaml` degrades safely on thousands of hostile inputs (only ever a `YamlError`); `classifyCommand` never crashes; dangerous commands stay caught under whitespace obfuscation.
- **Runtime integrity manifest** (`.kit/hooks/.hashes.json`, regenerated at `prepublishOnly`) — `doctor` flags a vendored hook modified/corrupted since install. Tamper-evidence, not signed supply-chain (stated honestly).
- **Full audit trail** — `critique-gate` and `consistency-guard` now also record decisions to `.kit/audit.log` (best-effort; never changes the outcome).

### Added — AI-safety frontier
- **Hard-rule #8 (prompt-injection)** — file/issue/tool-output/web content is untrusted **data**, never instructions; refuse and surface embedded commands.
- **`docs/enforcement-and-evals.md`** — names the hard (hook/CI, Claude-only) vs soft (markdown, all IDEs, can drift) tiers honestly, and the eval plan (audit trail → `release-check` compliance step → future automated evals) that measures soft-rule compliance instead of assuming it.

## [0.1.10] — 2026-07-17

### Added
- **Data-structure & algorithm coaching in the `code-craft` rule.** The agent now gets concrete guidance while writing code — match the container to the access pattern (`Map`/`Set` for keyed look-ups instead of an O(n) `.find()`/`.includes()` scan inside a loop, the usual accidental O(n²)), index one side and do a single pass to join two collections, hoist loop-invariant work, and choose the right approach over micro-tuning — balanced with a YAGNI reminder not to over-engineer small, bounded data. It's path-scoped (loads only when touching code), so it adds nothing to the always-on token budget. The `code-review` skill already flags performance on the review side.

## [0.1.9] — 2026-07-17

### Added
- **`.claude/settings.json` is now merged, not replaced.** Installing into a project that already has a `settings.json` keeps **your** hooks, permissions (`allow`/`ask`/your `deny`), `env`, and MCP servers — the kit only ensures **its** hooks and deny rules are also present, appended without duplicates. The merge is idempotent, so re-builds and the CI drift check (`check` / `doctor`) stay clean, and your original is still saved to `.bak` as a safety net. Files with no existing settings, or that are already exactly the kit's, are written as before. (Deeper follow-up to 0.1.8, which only backed the file up.)

### Fixed
- **`doctor` no longer flags the kit's own `.bak` backups as unexpected files.** A `<generated-file>.bak` left by an overwrite/merge is a deliberate backup, not stray output, so it's excluded from the "unexpected file in a kit-owned directory" check.

## [0.1.8] — 2026-07-17

### Fixed
- **Installing into an existing project no longer loses your files.** When the kit generates a file at a path you already had — `CLAUDE.md`, `.claude/settings.json`, `AGENTS.md`, a `.cursor/rules/*` file — the first install used to overwrite it with only a warning and **no backup**. It now **saves your original to `<file>.bak` before overwriting** (never clobbering an existing `.bak`), so nothing is lost silently; the build reports how many files it backed up. Same protection applies to a `--force` build over a generated file you've since edited. Files the kit does **not** generate were, and remain, untouched. (A later re-build still fully protects unowned files — skip + `--force` — this closes the one window, the very first install, where it didn't.)

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

[0.1.15]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.15
[0.1.14]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.14
[0.1.13]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.13
[0.1.12]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.12
[0.1.11]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.11
[0.1.10]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.10
[0.1.9]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.9
[0.1.8]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.8
[0.1.7]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.7
[0.1.6]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.6
[0.1.5]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.5
[0.1.4]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.4
[0.1.3]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.3
[0.1.2]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.2
[0.1.1]: https://github.com/dthanhvu03/smkit_1/releases/tag/v0.1.1
