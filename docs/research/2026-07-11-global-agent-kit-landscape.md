# Research — cross-IDE agent-config landscape (2026-07-11)

Design baseline for the kit. These are the conclusions we build on. Items that could
not be confirmed against official vendor documentation are marked **CHƯA XÁC MINH**.

## Conclusions applied as baseline

1. **No complete vendor standard for cross-IDE generation exists.** Each tool ships its
   own instruction format and loading semantics.
2. **Each target needs its own adapter + capability contract.** A shared file copied
   verbatim to every tool loses target-specific semantics (frontmatter, glob keys,
   file locations).
3. **`AGENTS.md` is a high-compatibility interchange format, not a policy engine.** It
   carries instructions many agents read, but enforces nothing.
4. **`kit.config.yaml` remains the machine-readable source of truth.**
5. **`AGENTS.md` is a generated interoperability target**, never a second source (ADR-001).
6. **`CLAUDE.md`, Copilot instructions, Cursor rules, Windsurf rules are native target
   artifacts** with distinct paths/formats.
7. **Prompt instructions are nondeterministic guidance**, not hard enforcement.
8. **Hooks can block actions but have coverage gaps and bypass vectors** (ADR-003).
9. **The real security boundary is an OS/container sandbox or restricted user.**
10. **Progressive disclosure** must be described precisely as one of: IDE-native
    scoped rules · path-based loading · model-decision loading · manual workflow ·
    static segmentation. This kit currently uses **IDE-native scoped rules + static
    segmentation**; only `consistency-guard` is path-scoped, the rest are always-on.
11. **Static scoped rules are NOT a runtime router.** Do not call them one.
12. **Rebuilding output from source is `regeneration`, not `self-healing`.**
13. **Auto-heal must not precede ownership, transaction, and doctor.**
14. **A test-fix loop that lives only in prompts is agent guidance**, not an orchestrator.
15. **Positioning:** the kit is a *canonical config compiler + target adapter registry +
    policy subsystem + safe generator + drift doctor*.

## Target semantics used by the adapters

| Target | Artifact(s) | Scoping key | Confirmed? |
|---|---|---|---|
| Claude Code | `CLAUDE.md`, `.claude/rules/*.md` (`paths:` frontmatter), `.claude/agents/*`, `.claude/skills/*/SKILL.md`, `.claude/settings.json` (hooks/permissions) | `paths:` frontmatter | Path-scoped rules + hooks + skills: **used in-repo**; exact current-version frontmatter keys: **CHƯA XÁC MINH** against live docs |
| Cursor | `.cursor/rules/*.mdc` (`globs`, `alwaysApply`), `.cursor/commands/*` | `globs` + `alwaysApply` | `.mdc` format **CHƯA XÁC MINH** against live docs |
| Copilot | `.github/copilot-instructions.md`, `.github/instructions/*.instructions.md` (`applyTo`) | `applyTo` | `applyTo` format **CHƯA XÁC MINH** |
| Windsurf | `.windsurf/rules/*.md` (`trigger`, `globs`) | `trigger: glob` | Modern trigger frontmatter (not legacy XML) **CHƯA XÁC MINH** |
| AGENTS.md | `AGENTS.md` | none (whole-file) | Interchange format, broad support |

The capability registry (`engine/targets/*/capabilities.json`) encodes these with an
explicit `verification.status`. Where a semantics is unverified, its capability is
`unknown` and the registry `verification.status` is `unverified`, not `verified`.
