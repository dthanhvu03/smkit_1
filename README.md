# Universal Agent Kit

**Guardrails and consistency for AI coding — for everyone, on any stack.** Works with Claude Code and Cursor from a single source. Built for vibe coding: you describe what you want in plain language, the kit keeps the AI safe and consistent for you.

## Why

AI coding agents drift: each session they re-decide structure, invent a second way to do things, and can run dangerous commands. This kit fixes that **without requiring you to know code or architecture**:

- 🛡️ **Guardrails always on** — destructive commands (`rm -rf .`, `git push --force`, `git clean -fdx`, `DROP TABLE`, …) are caught by a `PreToolUse` hook in every mode: the clearly-catastrophic ones are blocked, riskier-but-sometimes-legitimate ones warn, and build/cache dirs stay deletable. This is **defense-in-depth against honest agent mistakes, not a security sandbox** — a determined bypass (env-var indirection, a wrapper script) can still get through, so run untrusted agents inside an OS sandbox. See [`docs/kit-refactor/06-P1-guard-v2-design.md`](docs/kit-refactor/06-P1-guard-v2-design.md) for the exact boundary.
- 🧭 **Stays consistent** — the AI reads your project's **Constitution** and **Decision Log** at the start of every session and must follow them.
- 🎚️ **Three modes** — `vibe` (fast, plain language, minimal ceremony) → `standard` → `strict` (full review + human approval). One setting.
- 🔌 **One source, many tools** — edit once; generate `CLAUDE.md`, `.claude/*`, and `.cursor/rules/*` with no drift.

## Quick start

Get the kit into your project, then run the setup interview.

```bash
# Option A — scaffold into a new folder (no install), then answer a few questions:
npx degit <your-org>/universal-agent-kit my-app
cd my-app
npm run init          # or: node tools/kitgen/init.mjs

# Option B — scripted / CI (no prompts):
node tools/kitgen/init.mjs --name "Barber Booking" --stack nextjs \
  --mode vibe --lang en --agents claude,cursor

# Option C — already have the files? just:
npm run init
```

`init` asks plain-language questions (what are you building? who uses it? what must it
never do?), then writes `kit.config.yaml`, your `.kit/constitution.md` + `.kit/decisions.md`,
and generates the agent config. Open Claude Code or Cursor and start building.

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
CLAUDE.md · .claude/{rules,agents,settings.json} · .cursor/rules/*.mdc
```

- **Rules** map to Claude's native path-scoped `.claude/rules/` and Cursor's `.mdc` — loaded only when relevant, so your context stays lean.
- **Roles** (planner, architect, implementer, reviewer, qa, devops, orchestrator) become subagents.
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

## Modes at a glance

| | vibe | standard | strict |
|---|---|---|---|
| Guardrails | ✅ | ✅ | ✅ |
| Talk in plain language | ✅ | ✅ | technical |
| Brief before coding | — | short | full |
| Review + tests before done | encouraged | ✅ | ✅ + QA gate |
| Human approval (schema/prod/data) | self | if configured | required |

## Languages

Instructions generate in **English by default**; set `language: vi` for Vietnamese. More locales live in `engine/i18n/`.

## Status

Early. See [`docs/kit-refactor/`](docs/kit-refactor/) for the design and progress. Contributions of new profiles (Python, Go, …) and agent targets (Copilot, Windsurf) welcome.
