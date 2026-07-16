# Release readiness reference — versioning, changelog, safe rollout

Loaded on demand by the `release-check` skill (progressive disclosure). Compiled from the
sources listed at the end.

## 1. The gate: nothing ships without evidence
Every checklist item needs a real result attached (build/test/lint output, a diff, a
command run). "Looks fine" is not evidence. A single un-evidenced item ⇒ **no-go**.

## 2. Versioning — Semantic Versioning (SemVer)
`MAJOR.MINOR.PATCH`:
- **MAJOR** — incompatible/breaking API change.
- **MINOR** — backward-compatible new functionality.
- **PATCH** — backward-compatible bug fix.
Confirm the bump matches what actually changed (a breaking change with only a PATCH bump
is a release bug). Pre-1.0.0 (`0.y.z`) — anything may change; communicate that.

## 3. Changelog — human-readable, per release
Keep a curated `CHANGELOG.md` (Keep a Changelog format): an entry per version grouped as
**Added / Changed / Deprecated / Removed / Fixed / Security**, newest first, dated.
Conventional Commits can drive it, but the changelog is written for humans, not a raw git
log. Confirm the entry exists and matches the diff.

## 4. Safe rollout (Google SRE release engineering)
- **Reversible & backed up** — can you roll back fast? Is there a backup/migration-down?
- **Gradual rollout / canary** — release to a small slice first where possible; watch,
  then widen. Avoid big-bang deploys.
- **Hermetic, reproducible build** — the artifact is built from a known, pinned source;
  the same inputs produce the same output.
- **Data/schema migrations** — never a destructive migration without a rollback plan and
  the schema_change approver's sign-off.

## 5. Pre-release checklist (adapt to the project)
- [ ] build / test / lint green — output quoted.
- [ ] version bumped per SemVer; changelog entry matches the diff.
- [ ] no secrets, no debug/temp files, no `.env` committed.
- [ ] generated config in sync (`smkit check`) and `smkit doctor` clean.
- [ ] dependencies vetted/pinned; no new critical CVE.
- [ ] rollback path known; destructive migration has a plan + approval.
- [ ] smoke test of the critical path after deploy.
- [ ] explicit **go / no-go** with the risks named.

---

## Sources
- Semantic Versioning 2.0.0. https://semver.org/
- Keep a Changelog. https://keepachangelog.com/
- Conventional Commits. https://www.conventionalcommits.org/
- Google SRE Book — Ch. 8, Release Engineering (hermetic builds, gradual rollout).
  https://sre.google/sre-book/release-engineering/

> Provenance note: compiled from the authoritative sources above. An automated adversarial
> cross-check was not completed this session (API session limit) — these are standard,
> well-established practices; verify against the linked sources if precision matters.
