# Generation lifecycle

The exact stages `build` runs, and the safety property of each. Order is a hard
requirement: **no filesystem mutation happens before validation succeeds.**

```
parse            read kit.config.yaml (strict YAML subset; unsupported syntax → error)
  ↓
validate         shared validator (tools/kitgen/validate.mjs) — READ-ONLY
                 · version/name/mode · profile exists · agents known
                 · outDir boundary (path.relative + realpath, symlink escape)
                 · (roadmap) duplicate IDs, capability support, precedence conflicts
                 ── on ANY error: exit ≠ 0, ZERO filesystem change ──
  ↓
resolve          load engine + profile + project layers; merge rules/invariants by ID
  ↓
build map        engine/emitter.mjs (pure) → Map<relPath, content>  (in memory only)
  ↓
ownership plan   apply.mjs planBuild() — READ-ONLY: classify each path
                 (OWNED / MODIFIED_OWNED / STALE_OWNED / UNOWNED) vs manifest
                 → { deletes[], writes[], skipped[], warnings[] }
  ↓
apply (txn)      applyPlanTransactional(): back up every file to be deleted/overwritten,
                 record new writes, then mutate. On ANY failure → roll back in reverse,
                 rethrow. Previous output left intact.
  ↓
commit manifest  saveManifest() — ONLY after every mutation succeeded
  ↓
(audit)          decisions/warnings to stdout; guard decisions to .kit/audit.log
```

## Invariants of the lifecycle

1. **Validate → then mutate.** Never the reverse.
2. **Plan is read-only.** All decisions are computed before the first write.
3. **Cleanup is manifest-driven.** No directory is blanket-deleted; unowned files are
   never removed.
4. **Manifest commits last.** A failed build never leaves a manifest that claims a
   half-written tree is current.
5. **Boundary-checked paths only.** Every artifact resolves inside the output root;
   `outDir` escaping the project fails in `validate`.

## `check` and `doctor`

- `check` runs `parse → validate → build map` and compares to disk (drift for CI). No
  mutation.
- `doctor` runs `parse → validate → build map` and classifies drift against the
  manifest (missing / modified / stale / unexpected), plus config/paths/hooks/rules/
  skills/roles health. Read-only; `--json` for machines. Never auto-fixes.

## Not implemented (named honestly)

- No staging **directory** with atomic rename — apply uses backup/rollback (ADR-002).
  Not claimed atomic.
- No auto-heal / repair command yet. Rebuild = **regeneration**.
- No runtime progressive-disclosure router — scoping is IDE-native/static.
