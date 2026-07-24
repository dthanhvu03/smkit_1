# Maintainer curriculum (1–2 days)

Audience: people who change `engine/`, profiles, hooks, or publish the kit.  
Prereq: Node ≥ 18, repo checkout, can run `npm test`.

## Day 1 morning — Architecture map (2–3h)

Read in order:

1. [README.md](../../README.md) — product promise  
2. [ADR-004](../adr/ADR-004-roles-rules-skills-separation.md) — roles ≠ skills ≠ rules  
3. [enforcement-and-evals.md](../enforcement-and-evals.md) — hard vs soft  
4. [15-skill-references.md](../kit-refactor/15-skill-references.md) — progressive disclosure  
5. [target-capability-matrix.md](../architecture/target-capability-matrix.md) — per-IDE limits  

**Exercise:** draw the flow `kit.config.yaml` → `emitter` → Claude / Cursor / AGENTS.md on one page.

**Pass:** explain why Cursor lacks hard `PreToolUse` hooks and what that means for training users.

## Day 1 afternoon — Hands-on generator (2–3h)

```bash
npm test
npm run doctor
npm run check
node tools/kitgen/kitgen.mjs build --force
```

Exercises:

1. Add a throwaway invariant → see emitted `.mdc` / rules → remove it.  
2. Open one shipped skill (`engine/skills/smart-value/`) — note Workflow / Output / quality bar / `references/`.  
3. Run `npm run integrity` only when hooks intentionally change.

**Pass:** `doctor` 0 errors on a clean tree; know when to `UPDATE_GOLDEN=1 npm test`.

## Day 2 morning — Author a domain skill (2–3h)

Follow [03-domain-skill-guide.md](03-domain-skill-guide.md) + [templates/domain-skill/](templates/domain-skill/).

Checklist before merge:

- [ ] `skill.kit.yaml` valid (governance)  
- [ ] Description has trigger cues  
- [ ] Routing row added  
- [ ] Golden updated if in kit repo  
- [ ] One dogfood task logged  

**Pass:** doctor clean; skill appears under `.claude/skills/` and `.agents/skills/` after build.

## Day 2 afternoon — Ops & release (2h)

- `smkit update` / `uninstall` threat model (user content preserved)  
- Team section in README (LF, kit-check CI, decisions per file)  
- Threat model [ADR-003](../adr/ADR-003-guardrail-threat-model.md) — what to say to customers  
- Changelog discipline (Unreleased → version)

**Pass:** can write release notes that separate hard guarantees from soft coaching.

## Ongoing

- Every soft-rule gap that hurts production → invariant or hook design note, not a longer always-on paragraph.  
- Re-run Week 4 KPIs monthly on at least one customer project.
