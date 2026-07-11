# Roles, Rules & Skills — architecture research (2026-07-11)

Research + architecture proposal. **No engine refactor in this pass.** Scope: define
Role / Rule / Skill / Command precisely, verify against current vendor + open-standard
docs, compare capabilities, and propose canonical contracts + catalogs for a later
implementation task.

Verification labels used throughout: **verified** (fetched from an official source on
2026-07-11), **partial** (training knowledge to Jan 2026, not re-fetched today, or
source existence confirmed but details not read), **CHƯA XÁC MINH** (not confirmable).

---

## 1. Executive summary

- The current split into `roles / rules / skills / commands` is **conceptually correct
  and matches where the ecosystem landed** — but two things have drifted from the live
  standards and should be corrected in a later pass:
  1. **The kit's `SKILL.md` schema is non-standard.** It uses `id`, `paths`,
     `related_roles`, `related_rules`. The **Agent Skills open standard** (agentskills.io,
     originally Anthropic, now adopted by Claude Code, Codex, Gemini CLI, Cursor, Copilot/
     VS Code, Goose, Roo, Factory, Kiro… — *verified 2026-07-11*) defines skills by
     `name` + `description` (+ optional `license`, `allowed-tools`, `metadata`) and a
     folder that may bundle `scripts/ references/ assets/`. Skills are activated by
     **description-based model decision + manual `/name`**, *not* by `paths`. Path
     activation is a **Rule** concept. The kit conflates the two.
  2. **Command and Skill have converged in Claude Code.** *Verified 2026-07-11:*
     "Custom commands have been merged into skills… `.claude/commands/deploy.md` and
     `.claude/skills/deploy/SKILL.md` both create `/deploy`… if a skill and a command
     share the same name, the skill takes precedence." A Command is still a distinct
     *authoring intent* (manual entrypoint), but on Claude it is a skill with
     `disable-model-invocation: true`.
- **Biggest gap:** the kit treats Roles/Rules/Skills as **content templates only**. It
  emits them, but does not model **capability/permission boundaries** (Role tool
  allow/deny is emitted for Claude but is *pre-approval, not a restriction*), **activation
  semantics per target**, or **trust/provenance for skills**. Hard enforcement still is
  not in the Markdown — correct — but the kit does not yet *declare* which layer enforces
  what, per target.
- **Folder structure: keep all four.** `roles/ rules/ skills/ commands/` map cleanly onto
  the four abstractions. The fix is **schema alignment + capability metadata + doctor
  checks**, not moving files.

## 2. Terminology (verified definitions)

| Abstraction | Answers | Primary activation | Enforcement reality |
|---|---|---|---|
| **Role** (subagent/persona) | *Who does the work?* | model-decision (by `description`) or explicit call | Claude: own context + tool set + permissions (subagent). Elsewhere: mostly none. |
| **Rule** (instruction/policy) | *How must the agent behave?* | always-on / path-glob / model-decision / manual | Guidance unless backed by hook/CI/permission/sandbox. |
| **Skill** (capability package) | *What procedure + resources does it use?* | description model-decision + manual `/name` | Guidance + optional bundled scripts; progressive disclosure. |
| **Command** (entrypoint) | *How does a human start a task?* | manual `/name` | On Claude = a skill with `disable-model-invocation: true`. |

These four are **distinct** and should stay distinct (ADR-004), even though Claude Code
unifies Command+Skill at the file level.

## 3. Role analysis

**Current kit state (inventory 2026-07-11):** 7 roles in `engine/roles/*.md`, one file
each, frontmatter = `{name, description(trigger-style), tools(allowlist), model}`. Bodies
are prose. Emitted only to Claude `.claude/agents/<name>.md`; for cursor/copilot/windsurf/
agentsmd roles appear **only as an index in AGENTS.md** (no real subagent). Models used:
architect/reviewer=opus, implementer/planner/qa=sonnet, devops=haiku, orchestrator=inherit.

**Verified vendor reality:**
- **Claude Code subagents** (*verified 2026-07-11*, code.claude.com/docs/en/sub-agents):
  "each subagent runs in its own context window with a custom system prompt, specific tool
  access, and independent permissions"; Claude auto-delegates by `description`. Fields:
  `name`, `description`, `tools`, `model` (+ others such as skill preload via
  `disable-model-invocation` interplay; full field list *partial*). Background agents and
  agent teams are separate features. **Tool list on a subagent is a real access boundary
  for that subagent** (independent permissions), unlike the top-level `allowed-tools`
  pre-approval semantics.
- **Codex / Copilot / Cursor / Windsurf / Gemini "roles":** subagent/custom-agent support
  varies and is **partial / CHƯA XÁC MINH** for exact schema. Copilot has "custom agents";
  Cursor custom agents/modes exist; none are confirmed to accept the Claude field set.
  Treat Role as **Claude-first, degrade to an AGENTS.md index elsewhere** (current kit
  behavior is actually reasonable).

**Answers to §4.A (verified where marked):**
1. Own context — **Claude: yes** (verified). Others: mostly shared / CHƯA XÁC MINH.
2. Own model — **Claude: yes** (`model:`), incl. `inherit`. Others: partial.
3. Limit tools — **Claude: yes** (verified). 4. Allowlist = restriction? — **Claude
   subagent tools = real restriction** (independent permissions); top-level `allowed-tools`
   elsewhere is pre-approval. Kit currently emits `tools:` → maps to Claude restriction; on
   other targets it is dropped.
5. Permission mode — Claude subagents have independent permissions; kit does **not** model
   a per-role permission mode yet. 6. Memory — CHƯA XÁC MINH per-role; kit none.
7. Isolation (worktree/container) — **Claude background/worktree exists at session level**;
   per-subagent worktree isolation CHƯA XÁC MINH; kit none. 8. Preload skills — **Claude:
   yes** (verified, subagents can preload skills). Kit does not declare this.
9. Self-select vs called — **both** (auto-delegate by description OR explicit). 10. Nested
   subagents — partial. 11. Max turns — CHƯA XÁC MINH (kit none). 12. Output contract —
   kit encodes it as prose in the body, not a machine field. 13. Lifecycle hooks — session
   hooks yes; per-role CHƯA XÁC MINH. 14. Portable across vendors — **No** (Role is the
   least portable abstraction). 15. Dropped on emit — everything except name/description/
   tools/model is dropped today; on non-Claude targets the whole subagent concept is
   dropped to an AGENTS.md bullet.

## 4. Rule analysis

**Current kit state:** `engine/rules/` (hard-rules always/agent-read, consistency-guard
paths/hook+agent-read, evidence-gate always/gate) + `profiles/*/rules/conventions.md`.
Frontmatter = `{id, scope(always|paths), enforce, paths, title}`. `enforce` vocabulary in
use: `agent-read`, `hook`, `gate`, `generator`. Emitted per target with correct scoping:
Claude `.claude/rules/*.md` (`paths:`), Cursor `.mdc` (`globs`+`alwaysApply`), Copilot
`.github/instructions/*.instructions.md` (`applyTo`), Windsurf `.windsurf/rules/*.md`
(`trigger: glob|always_on`), AGENTS.md (always-on rules inlined).

**Verified/known vendor reality:**
- **Cursor rules** (partial, training Jan 2026; skills confirmed 2026-07-11 but rules page
  not re-read): `.cursor/rules/*.mdc` with `description`, `globs`, `alwaysApply`; project
  vs user rules. Activation: always / glob / (agent-requested) / manual.
- **Windsurf rules** (partial): `.windsurf/rules/` with activation modes **`always_on`,
  `manual`, `model_decision`, `glob`**; plus workflows and memories. This is the richest
  native activation model and the kit only uses `glob`/`always_on`.
- **Copilot** (partial): repo-wide `.github/copilot-instructions.md` + path-scoped
  `.github/instructions/*.instructions.md` (`applyTo`) + prompt files. No `model_decision`.
- **Claude `.claude/rules/` with `paths:`** — **CHƯA XÁC MINH** as a *native* auto-load
  mechanism in current docs. Claude's documented memory mechanism is `CLAUDE.md` (+ imports)
  and skills; whether `.claude/rules/*.md` is natively loaded path-scoped needs
  confirmation. **This is the single most important verification gap** because the kit's
  README claims "Claude's native path-scoped `.claude/rules/`". Flag for live check.
- **AGENTS.md** (*verified 2026-07-11*): plain markdown, **no schema**, nested files
  (closest wins, chat overrides). It is guidance only — never enforcement.

**Answers to §4.B (abridged):** loaded = per activation mode; always-on lives in context
every turn (token cost); path/glob supported by Cursor/Copilot/Windsurf/Claude(?);
model-decision supported by Windsurf (`model_decision`) and Cursor(agent-requested),
partial elsewhere; precedence + conflict = **no vendor guarantees a deterministic
cross-rule conflict resolution** → the kit must own precedence at generation time (it now
fails on invariant id conflict — extend to rules). Hard enforcement = **never** from a
rule file alone. Verifying a rule actually loaded = not possible at runtime → argues for
`doctor` static checks. Import/symlink handling = vendor-specific / CHƯA XÁC MINH.

**Enforcement vocabulary to standardize:** `guidance | static-check | hook | ci |
permission | sandbox | unsupported`. The kit's current `enforce` values (`agent-read`,
`hook`, `gate`, `generator`) should map onto this (`agent-read`→`guidance`,
`gate`→`ci`/`static-check`, `hook`→`hook`, `generator`→`static-check`).

## 5. Skill analysis

**Current kit state:** 6 skills in `engine/skills/<id>/SKILL.md`, **SKILL.md only** (no
`scripts/ references/ assets/`). Frontmatter = `{id, name, description, paths,
related_roles, related_rules}`. Emitted to Claude `.claude/skills/<id>/SKILL.md` (with
`name`, `description`, `paths`, `user-invocable`) and to Cursor as **commands**
(`.cursor/commands/<id>.md`).

**Verified Agent Skills open standard** (*agentskills.io, 2026-07-11*):
- A skill = folder with `SKILL.md` (metadata `name` + `description` minimum) + optional
  `scripts/ references/ assets/`.
- **3-stage progressive disclosure:** discovery (name+description only) → activation (full
  SKILL.md) → execution (bundled code/refs on demand).
- Portable across a large client set (Claude Code, Codex, Gemini CLI, Cursor, Copilot/
  VS Code, Goose, OpenCode, Roo, Factory, Kiro, Amp, …). Spec: agentskills.io/specification.

**Verified Claude Code skill frontmatter** (*code.claude.com/docs/en/skills, 2026-07-11*):
`name` (optional; display), `description` (recommended; combined with `when_to_use`
truncated at **1,536 characters** in the listing), `when_to_use`, `disable-model-invocation`
(bool — manual-only; also blocks subagent preload & scheduled-task use),
`user-invocable` (bool — hide from `/` menu), `allowed-tools` (no-ask tools while active),
`disallowed-tools` (removed from pool while active), `effort` (low..max). Discovery levels:
personal `~/.claude/skills/`, project `.claude/skills/`, plugin `<plugin>/skills/`;
precedence **enterprise > personal > project**, skill overrides bundled, plugin namespaced;
nested monorepo skills load on demand; symlinks followed (loaded once).

**Key divergences (kit → standard):**
| Kit field | Standard? | Verdict |
|---|---|---|
| `id` | no | drop; the **directory name** is the identity/command name |
| `name` | yes | keep (display) |
| `description` | yes | keep; enforce ≤~1,536 chars, "use when / not when" |
| `paths` | **no** (skills are not path-scoped) | **remove** — this is a Rule concept |
| `related_roles` / `related_rules` | no | move under `metadata:` (kit-owned), non-standard |
| — | `allowed-tools` | **add** (portable capability declaration) |
| — | `metadata.version` / `license` | **add** (provenance) |

**Answers to §4.C (abridged, verified where marked):** standard fields = name+description
(*verified*); vendor extensions = Claude's `disable-model-invocation/user-invocable/
allowed-tools/disallowed-tools/effort` (*verified*). Metadata always loaded = name+desc
(*verified*). Full body on activation; resources on execution (*verified*). Scripts are
**read or executed depending on the agent + tool permissions** — executing bundled scripts
is a real trust boundary. Implicit invocation = yes (model-decision) unless
`disable-model-invocation`; manual = `/name`. Tool dependency declared via `allowed-tools`;
network/consent/trust = **not in the base standard** → kit-owned metadata needed. `.agents/
skills/` = an emerging cross-tool discovery path (Codex/Gemini) — **partial**. Name clash
handling = per §5 verified precedence (Claude). Registry/plugin distribution = Claude
plugins + marketplaces; validation tooling = agentskills.io references a spec + quickstart
(*partial*). Size limit = description 1,536-char listing cap (*verified*); body size = soft.

## 6. Command / workflow distinction

- **Command** = manual entrypoint (a human types `/name`). Kit `engine/commands/`:
  checkup, decide, review, start.
- *Verified 2026-07-11:* on Claude Code, commands and skills are the **same mechanism**;
  a command is authored intent for *manual* use → equivalent to a skill with
  `disable-model-invocation: true`. Cursor has `.cursor/commands/`. Windsurf has
  **workflows** (`.windsurf/workflows/`) which are closer to commands than to rules.
- **Recommendation:** keep `engine/commands/` as authored *manual entrypoints*, but model
  them as "skills with manual-only invocation" so the Claude emitter can converge them and
  other targets can map them to native commands/workflows. Do **not** merge Command into
  Skill in the *source tree* (different authoring intent and different default invocation),
  but document that they share Claude's runtime.

## 7. Cross-vendor capability matrix

Values: `SUPPORTED` · `PARTIAL` · `UNSUPPORTED` · `VENDOR-SPECIFIC` · `KIT-OWNED` ·
`CHƯA XÁC MINH`. Sources per block below the table.

### Role capabilities
| Capability | Claude | Codex | Copilot | Windsurf/Devin | Cursor | Gemini CLI | Kit canonical |
|---|---|---|---|---|---|---|---|
| Separate context | SUPPORTED | CHƯA XÁC MINH | PARTIAL | CHƯA XÁC MINH | PARTIAL | CHƯA XÁC MINH | KIT-OWNED (emit) |
| Custom prompt | SUPPORTED | PARTIAL | PARTIAL | PARTIAL | PARTIAL | PARTIAL | SUPPORTED |
| Custom model | SUPPORTED | CHƯA XÁC MINH | CHƯA XÁC MINH | CHƯA XÁC MINH | PARTIAL | CHƯA XÁC MINH | KIT-OWNED |
| Tool allowlist (restriction) | SUPPORTED | CHƯA XÁC MINH | CHƯA XÁC MINH | CHƯA XÁC MINH | CHƯA XÁC MINH | CHƯA XÁC MINH | KIT-OWNED (Claude only) |
| Tool denylist | PARTIAL | CHƯA XÁC MINH | CHƯA XÁC MINH | CHƯA XÁC MINH | CHƯA XÁC MINH | CHƯA XÁC MINH | KIT-OWNED |
| Permission mode | SUPPORTED | CHƯA XÁC MINH | CHƯA XÁC MINH | CHƯA XÁC MINH | CHƯA XÁC MINH | CHƯA XÁC MINH | KIT-OWNED |
| Worktree isolation | PARTIAL | CHƯA XÁC MINH | CHƯA XÁC MINH | VENDOR-SPECIFIC | CHƯA XÁC MINH | CHƯA XÁC MINH | UNSUPPORTED |
| Parallel/background | SUPPORTED | PARTIAL | PARTIAL | VENDOR-SPECIFIC | PARTIAL | CHƯA XÁC MINH | UNSUPPORTED |
| Skill preload | SUPPORTED | CHƯA XÁC MINH | CHƯA XÁC MINH | CHƯA XÁC MINH | CHƯA XÁC MINH | CHƯA XÁC MINH | KIT-OWNED (declare) |
| Output schema | UNSUPPORTED (prose) | — | — | — | — | — | KIT-OWNED (contract) |

### Rule capabilities
| Capability | Claude | Codex | Copilot | Windsurf/Devin | Cursor | Gemini CLI | Kit canonical |
|---|---|---|---|---|---|---|---|
| Always-on | SUPPORTED (CLAUDE.md) | SUPPORTED (AGENTS.md) | SUPPORTED | SUPPORTED (`always_on`) | SUPPORTED (`alwaysApply`) | SUPPORTED (GEMINI.md) | SUPPORTED |
| Path/glob scoped | CHƯA XÁC MINH (`.claude/rules`?) | UNSUPPORTED | SUPPORTED (`applyTo`) | SUPPORTED (`glob`) | SUPPORTED (`globs`) | CHƯA XÁC MINH | KIT-OWNED (emit) |
| Model-decision | PARTIAL | CHƯA XÁC MINH | UNSUPPORTED | SUPPORTED (`model_decision`) | PARTIAL | CHƯA XÁC MINH | KIT-OWNED |
| Manual trigger | SUPPORTED | UNSUPPORTED | PARTIAL (prompt files) | SUPPORTED (`manual`) | SUPPORTED | PARTIAL | KIT-OWNED |
| Org/user/project/local scope | PARTIAL | PARTIAL | PARTIAL | PARTIAL | SUPPORTED (user/project) | PARTIAL | KIT-OWNED |
| Precedence guarantee | CHƯA XÁC MINH | AGENTS.md nesting | CHƯA XÁC MINH | CHƯA XÁC MINH | CHƯA XÁC MINH | CHƯA XÁC MINH | **KIT-OWNED (must)** |
| Conflict handling | CHƯA XÁC MINH | closest-wins | CHƯA XÁC MINH | CHƯA XÁC MINH | CHƯA XÁC MINH | CHƯA XÁC MINH | **KIT-OWNED (fail)** |
| Hard enforcement | UNSUPPORTED | UNSUPPORTED | UNSUPPORTED | UNSUPPORTED | UNSUPPORTED | UNSUPPORTED | via hook/CI only |

### Skill capabilities
| Capability | Claude | Codex | Copilot | Windsurf/Devin | Cursor | Gemini CLI | Kit canonical |
|---|---|---|---|---|---|---|---|
| SKILL.md open standard | SUPPORTED | SUPPORTED | SUPPORTED | PARTIAL | SUPPORTED | SUPPORTED | **should adopt** |
| `.agents/skills/` | PARTIAL | PARTIAL | CHƯA XÁC MINH | CHƯA XÁC MINH | CHƯA XÁC MINH | PARTIAL | UNSUPPORTED (today) |
| Implicit invocation | SUPPORTED | SUPPORTED | SUPPORTED | PARTIAL | SUPPORTED | SUPPORTED | KIT-OWNED |
| Manual invocation | SUPPORTED (`/name`) | PARTIAL | PARTIAL | PARTIAL | SUPPORTED | PARTIAL | SUPPORTED |
| Progressive disclosure | SUPPORTED | SUPPORTED | SUPPORTED | PARTIAL | SUPPORTED | SUPPORTED | (single-file today) |
| Scripts / references / assets | SUPPORTED | SUPPORTED | SUPPORTED | PARTIAL | SUPPORTED | SUPPORTED | UNSUPPORTED (SKILL.md only) |
| `allowed-tools` declaration | SUPPORTED | PARTIAL | PARTIAL | CHƯA XÁC MINH | PARTIAL | PARTIAL | **should add** |
| Consent / provenance / version | VENDOR/PARTIAL | CHƯA XÁC MINH | CHƯA XÁC MINH | CHƯA XÁC MINH | CHƯA XÁC MINH | CHƯA XÁC MINH | **KIT-OWNED** |
| Plugin distribution | SUPPORTED (marketplaces) | PARTIAL | PARTIAL | CHƯA XÁC MINH | PARTIAL | PARTIAL | UNSUPPORTED |
| Disable/enable | SUPPORTED (`disableBundledSkills`, overrides) | PARTIAL | PARTIAL | CHƯA XÁC MINH | PARTIAL | PARTIAL | KIT-OWNED |
| Validation / security scan | PARTIAL (spec) | CHƯA XÁC MINH | CHƯA XÁC MINH | CHƯA XÁC MINH | CHƯA XÁC MINH | CHƯA XÁC MINH | **KIT-OWNED (doctor)** |

**Source notes:** Claude Code skills/subagents + "commands merged into skills" + precedence
+ 1,536-char cap = **verified** (code.claude.com/docs/en/skills, /sub-agents, 2026-07-11).
Agent Skills standard + client list (Codex/Gemini/Cursor/Copilot/VS Code support) =
**verified** (agentskills.io, 2026-07-11). AGENTS.md = **verified** (agents.md, 2026-07-11).
Cursor `.mdc` rules, Windsurf activation modes, Copilot `applyTo`, Gemini GEMINI.md =
**partial** (training Jan 2026; skills support confirmed via agentskills.io client URLs but
rule/subagent pages not re-read today). Everything marked CHƯA XÁC MINH needs a live check.

## 8. Discovery, activation & precedence

- **Rules** — activation is declared: `always | path | glob | model-decision | manual`.
  The kit must OWN precedence (vendors don't guarantee it). Proposed rule precedence
  (higher wins): `local > project > profile > engine`, and within a layer, explicit
  `priority` then id; **unresolved same-priority conflict = fail** (mirror the invariant
  conflict rule already shipped).
- **Skills** — discovery = name+description in context; activation = model-decision on
  description OR manual `/name`; execution loads bundled resources. Precedence on name
  clash (Claude, verified): enterprise > personal > project > bundled; kit source has one
  layer today.
- **Roles** — selected by model on `description`, or explicitly. The kit should keep
  descriptions trigger-shaped ("Use when…", "Not for…") — it already does.

## 9. Context & token model (progressive-disclosure budget)

| Layer | Load timing | Target budget |
|---|---|---|
| Role descriptions (catalog) | always (delegation menu) | ≤ ~1 line each, ≤ ~1.5 KB total |
| Rule metadata | always for always-on; else on activation | always-on rules **< 200 lines total** (kit design doc target) |
| Skill catalog (name+desc) | always | ≤ 1,536 chars per skill (Claude cap, verified) |
| Full role prompt | on delegation | unbounded but focused |
| Full rule body | on activation (path/glob) | keep scoped bodies small |
| Full SKILL.md | on activation | soft cap; move detail to `references/` |
| references/ scripts output | on execution | on demand only |

The kit currently makes **3 of 4 engine rules always-on** and marks skills with
`paths: **/*` (which does nothing useful for skills). Aligning skills to
description-activation and keeping only truly-global rules always-on is the main
token win. **Do not claim token savings without measurement** (no measurement tool exists).

## 10. Permission & security model

- **`allowed-tools` is NOT a uniform permission restriction across vendors.** On a Claude
  *subagent* tool access is a real boundary; a top-level skill `allowed-tools` is
  "no-ask while active" (pre-approval), and other vendors may ignore it. The kit must not
  present `allowed-tools` as enforcement — it is a *declaration*; enforcement is the
  Claude permission system / OS sandbox.
- Proposed **effective-permission precedence** (higher wins, restrictive):
  `hard deny > sandbox restriction > managed policy > role deny > skill requested >
  project rule > profile rule > engine default`. A skill may **never** widen beyond its
  Role or policy.

## 11. Supply-chain risks (skills especially)

Skills are executable, model-selected, and shareable → the highest-risk abstraction.

| Risk | Vector | Mitigation the kit can own |
|---|---|---|
| Description poisoning / skill-selection manipulation | crafted `description` pulls the model into a malicious skill | doctor lint: over-broad/over-long descriptions; trust tier gate on implicit invocation |
| Hidden instructions | body text steering the agent | provenance + review status metadata; diff on update |
| Malicious scripts / remote download | `scripts/`, `curl|sh` inside a skill | guard v3 already blocks `curl|sh`; mark `network`/`executable` in metadata; T-tier gates |
| Permission escalation | skill requests tools the role denied | precedence (§10): role/policy deny wins |
| Path traversal / symlink escape | `references/` outside project | ownership-manifest + realpath boundary (already built for generation; extend to skill assets) |
| Update drift / tampered local copy | copied skill diverges from upstream | `content hash` + `source URL` in metadata; doctor drift for skill assets |
| Unsigned / untracked third-party | no provenance | trust tier + signature/hash requirement |

**Proposed trust tiers** (each gates implicit-invocation / script-exec / network / MCP /
shell / file-access / approval / signature / audit):
```
T0 bundled+reviewed     implicit ok, scripts ok (reviewed), audit
T1 org-managed          implicit ok, scripts w/ approval, signed
T2 project-owned+review  implicit ok, scripts w/ approval
T3 third-party pinned    manual-only, scripts require approval + hash pin
T4 untrusted/local       manual-only, no scripts, no network, explicit approval each use
```

## 12. Canonical schemas (proposed — not implemented)

### Role
```yaml
id: security-reviewer
description: "Use when a change touches auth, secrets, shell/exec, or file access. Not for style review."
scope: project
delegation: { mode: model-decision, triggers: [security review, authentication, secrets] }
runtime: { model: inherit, effort: high, maxTurns: 20, background: false, isolation: none }
permissions:
  mode: read-only
  allowTools: [read, search]        # portable INTENT; real restriction only where target supports it
  denyTools: [write, shell, network]
skills: { preload: [security-audit], allow: [dependency-review] }
memory: { scope: none }
output: { format: markdown, requiredSections: [findings, severity, evidence, recommendations] }
targets: { supported: [claude], degrade: { others: "emit as AGENTS.md role index; warn tools/permissions dropped" } }
```
Portable: `id/description/delegation/output`. Claude-mostly: `permissions/isolation/model/
skills.preload/maxTurns`. Kit-enforced-only: `output.requiredSections` (via evidence gate).
Emitter MUST warn when `permissions`/`isolation`/`skills.preload` are dropped for a target.

### Rule
```yaml
id: domain-service-boundary
description: Domain logic must go through domain services
scope: { level: project }
activation: { mode: path, paths: ["src/domain/**"] }
priority: 300
enforcement: { type: guidance, severity: required }   # guidance|static-check|hook|ci|permission|sandbox|unsupported
conflicts: { strategy: fail, with: [] }
lifecycle: { owner: architecture-team, status: active }
```
`enforcement.type` MUST be one of the seven values; Markdown never self-declares hard
enforcement. Doctor cross-checks that `hook`/`ci` types have a real hook/CI backing (the
kit already does this for `enforce=hook`).

### Skill (align to Agent Skills open standard)
```yaml
---
name: security-audit
description: "Audits changes for auth, authz, secrets, injection, unsafe file access, and dependency risk. Use when reviewing security-sensitive code. Do not use for ordinary style review."
license: Proprietary
allowed-tools: Read, Grep, Glob
metadata:                      # kit-owned namespace — keeps SKILL.md portable
  version: "1.0.0"
  owner: platform-team
  provenance: { sourceUrl: "", contentHash: "", reviewStatus: reviewed }
  trustTier: T0
  risk: medium
  network: false
  executableScripts: false
  requestedTools: [Read, Grep, Glob]
  deniedTools: [Write, Bash, Network]
  implicitInvocation: true
  supportedTargets: [claude, cursor, copilot, gemini, codex]
---
```
Folder: `engine/skills/security-audit/{SKILL.md, scripts/, references/, assets/, tests/}`.
Standard fields at top level (`name/description/license/allowed-tools`); **all kit-specific
fields under `metadata:`** so the file stays portable.

### Command
```yaml
id: start
title: Start or continue a task
description: "Begin or resume work; read memory, plan the smallest next step, build per mode."
argument-hint: "[what you want to build]"
invocation: manual            # Claude: emit as skill w/ disable-model-invocation: true
```

## 13. Composition model

```
Command (manual)  ── selects/requests ──▶  Role
Role  ── preloads/invokes ──▶  Skills
Rules  ── apply to ──▶  Role AND Skills (by activation/scope)
Hooks / Policy / Sandbox  ── hard-enforce ──▶  everything
```
Case answers: (1) role preloads many skills = OK (Claude preload). (2) many roles share a
skill = OK (skills are standalone). (3) skill invoked without a role = OK (top-level).
(4) rule applies to role not skill = allowed via `scope`/`activation`. (5) skill requests a
tool the role denied → **role deny wins** (§10). (6) two skills request different tools →
union, still bounded by role/policy. (7) role in worktree, skill references outside →
**boundary check must reject** (realpath). (8) path-rule in subagent context → rule applies
if the subagent touches matching paths (target-dependent; CHƯA XÁC MINH on Claude). (9)
implicit skill but project policy forbids → policy wins (mark `implicitInvocation:false` or
tier gate). (10) target lacks a canonical field → **emitter warns, never silent drop**.

## 14. Mapping into the current repository

1. **Keep the four folders** (`roles/ rules/ skills/ commands/`). Correct separation.
2. **Role = folder or file?** Keep **file-per-role** now; move to folder only if roles gain
   bundled assets (output templates). Not needed yet.
3. **Rule = frontmatter Markdown** — keep; add `activation`+`enforcement.type` fields
   (superset of current `scope`/`enforce`).
4. **Skill → adopt Agent Skills standard** (rename fields, drop `paths`/`id`, move
   `related_*` under `metadata`, allow `scripts/references/assets`). Biggest change.
5. **Profiles** override by ID with the same conflict-fail rule already shipped for
   invariants; profiles may add roles/rules/skills or override by id (explicit `override`).
6. **Registry?** The `engine/targets/*/capabilities.json` (already added) is the registry;
   add a per-abstraction capability map so the emitter/doctor can warn on drop.
7. **Per-abstraction schemaVersion** — yes, add `schemaVersion` to role/rule/skill
   frontmatter for migration safety.
8. **Ownership manifest for supporting files** — extend the existing build manifest to
   track skill `scripts/references/assets` so drift/cleanup covers them.
9. **Emitter degrade** — warn (not silent) when a target lacks a declared capability.
10. **Doctor** — new checks in §16.

## 15. Anti-patterns to reject

- Roles that plan + implement + review + approve their own work ("senior-developer").
- Two roles/skills with different names, same responsibility.
- A role whose `tools` exceed its job (e.g. reviewer with Write/Bash).
- `paths:` on a skill (category error — that's a rule).
- Skill `description` that is long/vague → poisons skill selection and wastes context.
- Rule Markdown claiming to be "enforced"/"blocking" without a hook/CI backing.
- Command duplicated as a separate Skill with the same name on Claude (they collide).
- Copying a third-party skill without provenance/hash (untracked supply chain).

## 16. Doctor & validation requirements (proposed)

- skill `description` too long (> ~1,536 chars) or too vague (no "use when").
- overlapping skill triggers (two skills match the same description space).
- role description missing delegation cue ("Use when…").
- always-on rule body too long (> N lines).
- SKILL.md over recommended size; reference chain too deep.
- duplicate ids / duplicate display names across layers.
- rule/role conflict without resolution → fail.
- tool request incompatible with target (`allowed-tools` a target ignores) → warn.
- unsupported field about to be silently dropped by an emitter → warn.
- skill `enforcement`/trust-tier vs requested `network`/`executableScripts` mismatch.
- skill provenance: missing `contentHash`/`sourceUrl` for T3/T4.

## 17. Test strategy (proposed)

- **Schema tests:** every role/rule/skill validates against its canonical schema; bad
  `enforcement.type` / trust tier fails.
- **Emitter contract tests:** per target, assert dropped-capability warnings fire;
  deterministic output; Unicode/multiline/code-fence/quote fidelity; skill folder
  (scripts/refs/assets) round-trips.
- **Precedence tests:** rule/role id conflict fails; profile override works; layer order.
- **Security tests:** skill referencing outside project rejected; `curl|sh` in a skill
  script flagged; T4 skill cannot declare implicit invocation.
- **Progressive-disclosure tests:** doctor flags long/vague descriptions and overlapping
  triggers.

## 18. Recommended architecture (summary)

Keep the compiler + target-registry + policy + safe-generator + doctor shape. Add:
(a) canonical Role/Rule/Skill/Command schemas with `schemaVersion`; (b) **Agent Skills
standard** for skills incl. `scripts/references/assets` + `metadata` namespace; (c)
capability-aware emitter that **warns on drop**; (d) skill trust tiers + provenance; (e)
doctor checks in §16; (f) extend the ownership manifest to skill supporting files.

## 19. Migration plan (for the later implementation task)

1. Add new fields as **optional/additive** (old frontmatter still parses).
2. Introduce `metadata:` on skills; keep emitting current Claude/Cursor output byte-stable
   until a golden update is intentional.
3. Migrate `id`→directory-name, `paths`(skill)→removed, `related_*`→`metadata`.
4. Add `activation`/`enforcement.type` to rules as a superset of `scope`/`enforce`.
5. Update golden fixtures in one reviewed commit (`UPDATE_GOLDEN=1`).
6. Emitter drop-warnings + doctor checks land last, behind tests.

## 20. P0 / P1 / P2 roadmap

- **P0 (correctness/portability):** align Skill frontmatter to the open standard; remove
  `paths` from skills; add `enforcement.type` vocabulary to rules; emitter drop-warnings.
- **P1 (capability/security):** skill `scripts/references/assets` + manifest tracking;
  trust tiers + provenance/hash; doctor §16 checks; rule precedence/conflict fail.
- **P2 (ergonomics):** `.agents/skills/` discovery; per-abstraction `schemaVersion`
  migration tooling; token measurement for progressive disclosure; profile override UX.

## 21. Open questions

- Does current Claude Code natively auto-load `.claude/rules/*.md` with `paths:`
  frontmatter, or is `CLAUDE.md`/skills the only native path? (**blocks the rule story**)
- Exact Cursor rules `.mdc` field set and activation names in the current version.
- Windsurf `model_decision`/`glob`/`manual`/`always_on` exact frontmatter keys today.
- Copilot custom-agent schema and whether it accepts tool restrictions.
- `.agents/skills/` adoption breadth (Codex/Gemini) and precedence vs vendor paths.
- Gemini CLI custom-agent + skill-consent model.

## 22. Official source list

| Source | Type | Accessed | Status |
|---|---|---|---|
| agents.md | open spec | 2026-07-11 | verified |
| agentskills.io (overview + client list) | open spec | 2026-07-11 | verified |
| agentskills.io/specification | open spec | 2026-07-11 | referenced, not fully read (partial) |
| code.claude.com/docs/en/skills | vendor doc | 2026-07-11 | verified |
| code.claude.com/docs/en/sub-agents | vendor doc | 2026-07-11 | verified (partial read) |
| cursor.com/docs/context/skills | vendor doc | 2026-07-11 | existence verified, not read (partial) |
| docs.github.com/en/copilot/concepts/agents/about-agent-skills | vendor doc | 2026-07-11 | existence verified (partial) |
| developers.openai.com/codex/skills/ | vendor doc | 2026-07-11 | existence verified (partial) |
| geminicli.com/docs/cli/skills/ | vendor doc | 2026-07-11 | existence verified (partial) |
| Cursor rules / Windsurf rules / Copilot instructions / GEMINI.md | vendor docs | — | training Jan 2026, not re-fetched (partial) |

## 23. Academic / research source list

Cited by name; **not re-fetched 2026-07-11** unless noted. Confidence labeled.

- Liu et al., "Lost in the Middle: How Language Models Use Long Contexts" (TACL 2023) —
  position-dependent context degradation → basis for progressive disclosure. *partial.*
- Greshake et al., "Not what you've signed up for: Compromising Real-World LLM-Integrated
  Applications with Indirect Prompt Injection" (ACM AISec 2023) → skill description /
  content poisoning. *partial.*
- OWASP Top 10 for LLM Applications (LLM01 Prompt Injection, LLM05 Supply Chain, LLM07/
  Excessive Agency) → skill supply-chain + capability leakage framing. *partial.*
- Anthropic engineering: "Equipping agents for the real world with Agent Skills" /
  context-engineering posts → progressive disclosure rationale. *partial (official blog,
  exact URL not re-fetched).*

## 24. CHƯA XÁC MINH (must verify before implementing)

- Native path-scoped `.claude/rules/*.md` auto-load on current Claude Code.
- Exact current frontmatter keys/vocab for Cursor `.mdc`, Windsurf rules, Copilot
  `applyTo`, Gemini `GEMINI.md`/custom agents.
- Per-subagent worktree isolation, maxTurns, per-role memory on Claude.
- `.agents/skills/` precedence and which vendors honor it.
- Exact "context rot" primary citation (industry report vs peer-reviewed).
- Any peer-reviewed paper specifically analyzing `SKILL.md` (likely none yet → treat as
  emerging).
