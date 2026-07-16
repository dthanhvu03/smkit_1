# Universal Agent Kit

**Guardrails and consistency for AI coding — for everyone, on any stack.** Works with Claude Code, Cursor, GitHub Copilot, Windsurf, and the open **AGENTS.md** standard (Codex, Gemini CLI, and any AGENTS.md-aware tool) — all from a single source. Built for vibe coding: you describe what you want in plain language, the kit keeps the AI safe and consistent for you.

## Why

AI coding agents drift: each session they re-decide structure, invent a second way to do things, and can run dangerous commands. This kit fixes that **without requiring you to know code or architecture**:

- 🛡️ **Guardrails always on** — destructive commands (`rm -rf .`, `git push --force`, `git clean -fdx`, `DROP TABLE`, …) are caught by a `PreToolUse` hook in every mode: the clearly-catastrophic ones are blocked, riskier-but-sometimes-legitimate ones warn, and build/cache dirs stay deletable. This is **defense-in-depth against honest agent mistakes, not a security sandbox** — a determined bypass (env-var indirection, a wrapper script) can still get through, so run untrusted agents inside an OS sandbox. See [`docs/kit-refactor/06-P1-guard-v2-design.md`](docs/kit-refactor/06-P1-guard-v2-design.md) for the exact boundary.
- 🧭 **Stays consistent** — the AI reads your project's **Constitution** and **Decision Log** at the start of every session and must follow them.
- 🎚️ **Three modes** — `vibe` (fast, plain language, minimal ceremony) → `standard` → `strict` (full review + human approval). One setting.
- 🔌 **One source, many tools** — edit once; generate `CLAUDE.md`/`.claude/*`, `.cursor/rules/*`, `.github/*` (Copilot), `.windsurf/rules/*`, and `AGENTS.md` + `.agents/skills/*` (Codex/Gemini) with no drift.

## Quick start

**One command** — run it inside your project (new or existing) and answer a few questions:

```bash
npx @zusem/smkit init
```

That's it: no install, no clone. Other ways if you prefer:

```bash
# Scripted / CI (no prompts):
npx @zusem/smkit init --name "Barber Booking" --stack generic \
  --mode vibe --lang en --agents claude,cursor,copilot,windsurf,agentsmd

# Or install the CLI globally:
npm i -g @zusem/smkit
smkit init

# Or from source (no npm): download the repo ZIP or clone, then:
node tools/kitgen/init.mjs
```

`init` asks plain-language questions (what are you building? who uses it? what must it
never do?), then writes `kit.config.yaml`, your `.kit/constitution.md` + `.kit/decisions.md`,
and generates the agent config. Open your AI tool — Claude Code, Cursor, Copilot, Windsurf, or a Codex/Gemini CLI reading `AGENTS.md` — and start building.

> Requires Node ≥ 18. No dependencies to install — the generator is pure Node.

## How it works

```
kit.config.yaml        ← the one file that describes your project
engine/                ← universal rules, roles, and text (stack-agnostic)
profiles/<stack>/      ← opinionated defaults per stack (generic, nextjs, …)
.kit/                  ← your Constitution, Decision Log, and guard hooks
tools/kitgen/          ← the generator (zero-dependency Node)
        │
        ▼  node tools/kitgen/kitgen.mjs build
CLAUDE.md · .claude/{rules,agents,commands,skills,settings.json} · .cursor/{rules,commands}
.github/copilot-instructions.md + instructions/* · .windsurf/rules/* · AGENTS.md · .agents/skills/*
```

- **Rules** map to each tool's native mechanism — Claude's path-scoped `.claude/rules/`, Cursor `.mdc`, Copilot `applyTo`, Windsurf `trigger` — loaded only when relevant, so your context stays lean.
- **Roles** — 12 senior playbooks (analyst, planner, architect, implementer, reviewer, qa, devops, orchestrator, db-admin, git-manager, docs-manager, debugger) become real subagents on Claude and a role index in `AGENTS.md` elsewhere.
- **Guardrails** run as a `PreToolUse` hook; the **Constitution + Decision Log** are injected by a `SessionStart` hook.
- **Generation is safe by construction:** the config is validated before any file is touched (a bad config or an out-of-project `outDir` writes nothing), the generator only deletes/overwrites files it recorded in `.kit/build-manifest.json` (your own files are never blown away), and a mid-build failure rolls back to the previous output.

## Commands

One CLI (`smkit`) or the equivalent npm scripts:

```bash
smkit init      # npm run init   — set up / re-run the interview (copies the kit into your project)
smkit build     # npm run build  — regenerate agent config from the source
smkit check     # npm run check  — CI: fail if generated files are out of sync
smkit doctor    # npm run doctor — health-check the kit + generated output (with fix hints)
```

`smkit init` installs a **self-contained** copy (`engine/ profiles/ tools/ .kit/`) into your
project, so hooks and the generator run without any `node_modules` dependency and you can edit
rules/profiles in place.

### Inside your AI tool

The generated config adds slash commands you run *while building* — the workflow, from a fuzzy idea to shipped code:

```
/ship        deliver a whole feature A→Z — discovery → build → review → deploy, in one orchestrated run
/discover    fuzzy idea → a founder-ready decision (problem, options, smallest slice)
/challenge   stress-test a change through 5 lenses before coding (a hook enforces this in standard/strict)
/task        open a work record — scope, acceptance, impact map, plan — before building; traceable & resumable
/roundtable  when it's non-trivial or contested, the roles converge on a decision (bounded — no endless debate)
/start       plan the smallest next step and build it, per mode
/review      static review of the diff · /checkup consistency audit · /decide record a decision
```

## Modes at a glance

| | vibe | standard | strict |
|---|---|---|---|
| Guardrails | ✅ | ✅ | ✅ |
| Talk in plain language | ✅ | ✅ | technical |
| Brief before coding | — | short | full |
| Review + tests before done | encouraged | ✅ | ✅ + QA gate |
| Human approval (schema/prod/data) | self | if configured | required |

## Capabilities & what they actually mean

Honest table — what is *enforcement* vs *guidance*, and the limits. Full detail in
[`docs/adr/`](docs/adr/) and the [capability matrix](docs/architecture/target-capability-matrix.md).

| Capability | Type | Enforcement | Limitation |
|---|---|---|---|
| Scoped rules | IDE-native | Vendor-dependent | Static/path-scoped, **not** a runtime router |
| Command guard | Execution hook (`PreToolUse`) | Partial hard enforcement | **Not** a sandbox; env-var/indirection bypass remains |
| Invariants | Guidance / (future) static-check | Per-invariant `enforcement` field | `guidance` ones are advisory — an agent can ignore them |
| Drift | Kit-owned doctor | Read-only detection | No auto-fix by default |
| Regeneration | Kit-owned, manifest-controlled | Deterministic rebuild | Rebuild from source — **not** "self-healing" |
| Safe generation | Kit-owned | Validate → ownership → transaction | Best-effort rollback, not kernel-atomic (see ADR-002) |

### Threat model (see [ADR-003](docs/adr/ADR-003-guardrail-threat-model.md))

The guard **protects against honest agent mistakes** and blocks the obviously
catastrophic (`rm -rf .`, `git clean -fdx`, `DROP TABLE`, `curl|sh`, Windows recursive
deletes, destructive migrations). It does **not**:

- defend against adversarial code running under the same OS user;
- replace a container, VM, or restricted user;
- guarantee protection against every shell obfuscation (variable indirection,
  multi-step download-then-run, encoded payloads);
- cover effects achieved via file writes if a file policy doesn't cover them (the
  command guard only sees the Bash tool).

**Run untrusted or high-autonomy agents inside an OS/container sandbox.** The guard is
defense-in-depth, not the boundary.

## Languages

Instructions generate in **English by default**; set `language: vi` for Vietnamese. More locales live in `engine/i18n/`.

## Status

Early. See [`docs/kit-refactor/`](docs/kit-refactor/) for the design and progress. Contributions of new profiles (Python, Go, …) and agent targets (Copilot, Windsurf) welcome.
