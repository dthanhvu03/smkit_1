# ADR-004 — Roles, Rules, Skills & Commands are four distinct abstractions

- **Status:** Accepted (2026-07-11). Design-only; implementation deferred to a later task.
- **Context:** Research in
  [`docs/research/2026-07-11-roles-rules-skills-architecture.md`](../research/2026-07-11-roles-rules-skills-architecture.md)
  verified the current abstractions against live standards (agents.md, agentskills.io,
  code.claude.com — all fetched 2026-07-11). Two drifts were found: the kit's `SKILL.md`
  schema is non-standard, and Command/Skill have converged in Claude Code.

## Decision

1. **Role, Rule, Skill and Command are four different abstractions** and stay separate in
   the source tree (`engine/roles`, `engine/rules`, `engine/skills`, `engine/commands`).
   - Role = *who does the work* (persona/subagent: prompt + model + tool/permission
     boundary + optional isolation).
   - Rule = *how the agent must behave* (policy with an activation mode + enforcement type).
   - Skill = *what procedure + resources to use* (capability package, progressive
     disclosure).
   - Command = *how a human starts a task* (manual entrypoint).
2. **Skills follow the Agent Skills open standard** (agentskills.io) whenever possible:
   top-level `name` + `description` (+ optional `license`, `allowed-tools`), a folder that
   may bundle `scripts/ references/ assets/`, and description-based (model) + manual
   activation. **All kit-specific fields live under a `metadata:` namespace** to preserve
   portability. The non-standard `id`, `paths`, `related_roles`, `related_rules` fields are
   removed or moved under `metadata`. **`paths` is never used on a skill** — path scoping
   is a Rule concept.
3. **Rules must declare `activation` and `enforcement.type`.** `enforcement.type ∈
   {guidance, static-check, hook, ci, permission, sandbox, unsupported}`. A Rule expressed
   in Markdown is `guidance` by default and **must not claim to be hard-enforced**; when
   it is `hook`/`ci`/`permission`, doctor verifies a real backing exists.
4. **Roles must declare their capability & permission boundary** (`permissions.allow/deny`,
   `runtime.model/isolation`, `skills.preload`). These are *declared intent*; they are a
   real restriction only on targets that support it (Claude subagents). `allowed-tools` is
   **not** a uniform cross-vendor permission — it is a declaration, not enforcement.
5. **Command is a manual entrypoint.** On Claude Code (where custom commands have merged
   into skills) a Command emits as a skill with `disable-model-invocation: true`; on other
   targets it maps to the native command/workflow. Source stays separate from Skill.
6. **Hard enforcement never lives in Markdown.** Enforcement is hooks / CI / the vendor
   permission system / the OS sandbox (see ADR-003).
7. **Unsupported target capability is a warning or error, never a silent drop.** When an
   emitter cannot represent a declared Role/Rule/Skill capability for a target, it must
   emit a warning (and doctor must be able to report it), so capability loss is visible.

## Consequences

- The kit becomes portable at the skill layer (works across the ~40 Agent-Skills clients)
  instead of Claude/Cursor-only.
- A single source can honestly say, per target, which capabilities survive and which
  degrade — no silent loss.
- Migration is additive (new fields optional first); golden fixtures update in one
  reviewed commit. See the research doc §19 and the P0/P1/P2 roadmap §20.

## Open verification (blockers flagged, not resolved here)

- Native path-scoped `.claude/rules/*.md` auto-load on current Claude Code (**CHƯA XÁC
  MINH** — the rule-emission story for Claude depends on it).
- Exact current frontmatter for Cursor `.mdc`, Windsurf activation modes, Copilot
  `applyTo`, Gemini `GEMINI.md`.
