# ADR-002 — Safe generation & ownership

- **Status:** Accepted (2026-07-11). Implemented by P0.1–P0.3.
- **Context:** The pre-hardening generator ran `rmSync(recursive)` over the directories
  it "owned" and wrote without validating config or bounding `outDir` — it could delete
  user files (F-04), write outside the project (F-02), and leave partial output on a
  bad config (F-03).

## Decision

1. **Validate before any filesystem mutation.** A shared validator
   (`tools/kitgen/validate.mjs`) runs in `build`, `check`, and `doctor` *before* any
   `mkdir`/`rm`/`write`/manifest/staging. An invalid config or an out-of-project
   `outDir` exits non-zero and changes nothing on disk. (Closes F-02, F-03.)
2. **The ownership manifest is the ONLY basis for cleanup.**
   `.kit/build-manifest.json` records exactly which files the kit wrote and their
   content hash. Cleanup deletes only files listed there.
3. **Never blanket-delete a directory.** The old `rmSync('.claude/rules', {recursive})`
   is gone. (Closes F-04.)
4. **Never overwrite an unowned file.** A file not in the manifest at a generated path
   is protected; a manifest-tracked file that was hand-edited is protected. Both
   require explicit `--force`. First build with no manifest ("migration") adopts an
   existing generated path only when it does not clash; otherwise it warns.
5. **Generation is transactional (best-effort).** The plan is built fully in memory,
   then applied through a backup/rollback journal: every file to be deleted or
   overwritten is backed up and every new write recorded; on any failure the journal
   is undone in reverse and the error rethrown, leaving previous output intact.
   The **manifest is committed only after all mutations succeed.** (Mitigates F-03.)
6. **`outDir: "."` (in-place) is only sanctioned now that ownership + transaction
   exist.** Before P0.2/P0.3 it was unsafe.

## Ownership states (target model)

| State | Meaning | Default action |
|---|---|---|
| `UNOWNED` | not in manifest | never delete; protect on write |
| `OWNED` | in manifest, hash matches | free to overwrite |
| `MODIFIED_OWNED` | in manifest, hash differs | protect unless `--force` |
| `STALE_OWNED` | in manifest, not in new outputs | delete only if hash still matches |
| `UNOWNED_CONFLICT` | migration: existing file differs from expected | keep + report |

## Not atomic

This is **best-effort backup/rollback, not a kernel-atomic directory swap.**
Directory-rename atomicity and file locking differ on Windows; we do not claim
"atomic". The guarantee is: *a failed build does not advertise a half-written tree as
current, and the previous output survives.*

## Consequences

- Corrupt/unreadable manifest → treated as "no ownership" (fail-closed for deletion:
  nothing is deleted).
- The generated banner (`GENERATED — DO NOT EDIT`) stays for humans but is **not**
  proof of ownership — the manifest is.
- A dedicated repair/regenerate command (future) must preview a diff and respect the
  manifest. It is called **regeneration**, never "self-heal".
