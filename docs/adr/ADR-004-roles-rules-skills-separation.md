# ADR-004 — Roles, Rules, Skills & Commands are four distinct abstractions

- **Status:** Accepted (2026-07-11). **Skill layer implemented and hardened** (two-layer
  `SKILL.md` + `skill.kit.yaml`, standard-compliant emitter, backward-compat migration,
  drop-warnings, spec-accurate description limits, multilingual trigger heuristic,
  cryptographically-verified content pinning for high-risk trust tiers, per-target
  capability warnings for invocation control and Claude's `paths` overlay — see
  `engine/emitter.mjs`, the 6 migrated `engine/skills/*`, and 73 passing tests). Role and
  Rule schema changes remain design-only / deferred.
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
2. **Skills use a TWO-LAYER schema: portable `SKILL.md` + kit sidecar `skill.kit.yaml`.**
   - `SKILL.md` follows the Agent Skills open standard **strictly** (agentskills.io/
     specification, *verified 2026-07-11*): required `name` + `description`; optional
     `license`, `compatibility`, `allowed-tools` (experimental, vendor-dependent); and
     **`metadata` is a string→string map ONLY** — no nested objects/arrays/booleans. A
     skill is a folder that may bundle `scripts/ references/ assets/`. `name` MUST equal
     the directory name.
   - All complex kit governance (trust tier, provenance/hash, invocation policy,
     requested/denied/pre-approved tools, network/executable flags, supported targets)
     lives in a **sidecar `skill.kit.yaml`** with its own `schemaVersion`, validated
     strictly by the kit and **never emitted into `SKILL.md`**.
   - The non-standard `id`, `related_roles`, `related_rules` fields are removed from
     `SKILL.md` (`id`→directory name, `related_*`→sidecar). Putting nested governance
     structures under `metadata:` would violate the spec and is explicitly rejected.
   - **`paths` is NOT part of the Agent Skills open standard** (activation there is
     description-based) — the **canonical/portable Skill contract never depends on
     `paths`**. However, Claude Code **verified 2026-07-11** supports `paths` as a
     documented **vendor-specific extension**: "Glob patterns that limit when this skill
     is activated… Claude loads the skill automatically only when working with files
     matching the patterns. Uses the same format as path-specific rules"
     (code.claude.com/docs/en/skills). The kit models this as a **target overlay**: a
     skill's portable `SKILL.md` never carries `paths`, but its `skill.kit.yaml` sidecar
     may declare `activation.claude.paths` — a Claude-only activation gate that the
     Claude emitter re-adds as `paths:` frontmatter. Other targets get no equivalent
     (warned, not silently dropped, if declared and the target's capability is
     unconfirmed). A trivial "matches everything" pattern (`**/*`, `**`, `*`) is a no-op
     and is not carried into the overlay at all.
3. **Rules must declare `activation` and `enforcement.type`.** `enforcement.type ∈
   {guidance, static-check, hook, ci, permission, sandbox, unsupported}`. A Rule expressed
   in Markdown is `guidance` by default and **must not claim to be hard-enforced**; when
   it is `hook`/`ci`/`permission`, doctor verifies a real backing exists.
4. **Roles must declare their capability & permission boundary** (`permissions.allow/deny`,
   `runtime.model/isolation`, `skills.preload`). These are *declared intent*; they are a
   real restriction only on targets that support it (Claude subagents).
   **`allowed-tools` is a vendor-dependent pre-approval hint, NOT a uniform deny boundary.**
   On Claude a skill's `allowed-tools` lets those tools run without asking but does **not**
   remove other tools from the pool (`disallowed-tools` + permission settings/hooks/sandbox
   are the real deny layers); GitHub Copilot similarly uses it to skip confirmation and
   warns that pre-approving `shell`/`bash` lets a malicious skill run arbitrary commands.
   Therefore the canonical permission model splits `requestedTools` / `deniedTools` /
   `preApprovedTools`, and an adapter never auto-promotes `requestedTools` to
   `allowed-tools`, and never pre-approves a dangerous tool just because a skill asks.
5. **Command is a manual entrypoint.** On Claude Code (where custom commands have merged
   into skills) a Command emits as a skill with `disable-model-invocation: true`; on other
   targets it maps to the native command/workflow. Source stays separate from Skill.
6. **Hard enforcement never lives in Markdown.** Enforcement is hooks / CI / the vendor
   permission system / the OS sandbox (see ADR-003).
7. **Unsupported target capability is a warning or error, never a silent drop.** When an
   emitter cannot represent a declared Role/Rule/Skill capability for a target, it must
   emit a warning (and doctor must be able to report it), so capability loss is visible.

## Consequences

- The kit becomes portable at the skill layer (works across the many AI agents and coding
  clients that have adopted Agent Skills) instead of Claude/Cursor-only.
- A single source can honestly say, per target, which capabilities survive and which
  degrade — no silent loss.
- Migration is additive (new fields optional first); golden fixtures update in one
  reviewed commit. See the research doc §19 and the P0/P1/P2 roadmap §20.

## Verification status (updated 2026-07-11 from official docs)

- **VERIFIED — Claude Code native path-scoped rules:** `.claude/rules/**/*.md` with YAML
  frontmatter `paths:`; a rule without `paths` loads globally, a rule with `paths` loads
  only when Claude works on a matching file. Rules are context guidance, not hard
  enforcement. (code.claude.com/docs/en/memory) → **no longer a blocker for the P0 task.**
- **VERIFIED — Claude Skills / command compatibility / manual-only:**
  `.claude/commands/*.md` and `.claude/skills/*/SKILL.md` both create `/name` (skill wins
  on clash); `disable-model-invocation: true` = manual-only workflow. (code.claude.com/
  docs/en/skills)
- **VERIFIED — GitHub Copilot Agent Skills** across cloud agent, code review, Copilot CLI,
  Copilot app, and agent mode; project skills at `.github/skills`, `.claude/skills`, or
  `.agents/skills`. (docs.github.com)
- **VERIFIED — Windsurf/Devin Skills**: `.windsurf/skills/` plus `.agents/skills/`
  discovery; automatic + manual `@skill-name`. Windsurf keeps Skills, Rules and Workflows
  as three separate runtime concepts (docs.windsurf.com) → the kit keeps `commands/`
  separate.
- **PARTIAL — Cursor Agent Skills**: an official "Agent Skills" doc exists
  (cursor.com/docs/context/skills); exact folder/precedence/extension semantics
  **CHƯA XÁC MINH ĐỦ** — do not hard-code Cursor-specific skill semantics beyond what the
  repo already verifies.
- Remaining **CHƯA XÁC MINH**: exact current Cursor `.mdc` rule field set; Gemini
  `GEMINI.md`/custom-agent + skill-consent specifics.
