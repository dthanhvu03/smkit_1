# ADR-003 — Guardrail threat model

- **Status:** Accepted (2026-07-11). Guard v3 implemented in `.kit/hooks/_lib.mjs`.
- **Context:** The kit markets "guardrails". We must state precisely what is
  *enforcement* vs *guidance*, and what the guard does and does NOT protect against.

## Decision — the enforcement ladder

| Layer | Mechanism | Nature |
|---|---|---|
| Prompt guidance | rules/roles/skills text, Constitution, Decision Log | **Nondeterministic guidance.** An agent may ignore it. NOT enforcement. |
| Pre-exec command policy | `PreToolUse(Bash)` → `guard-shell.mjs` → `classifyCommand` | **Partial hard enforcement.** Blocks/warns before a shell command runs. |
| Pre-write/path policy | `PreToolUse(Write\|Edit)` → `consistency-guard.mjs`; generator path boundary | Partial. Consistency guard is a **heuristic** (known-lib list), fail-open. |
| Post-batch verification | `doctor` / `check` (drift, ownership) | Read-only detection, run by human/CI. |
| OS/container sandbox | outside the kit | **The real security boundary.** |

## Risk classification (guard v3)

Commands are classified `ALLOW` / `WARN` / `REQUIRE_APPROVAL` / `BLOCK` /
`UNKNOWN_HIGH_RISK`:

- Deleting project root, `.git`, or the whole workspace → **BLOCK**
  (`rm -rf .`, `git clean -fdx`, `git checkout -- .`, `git restore .`,
  `find . -delete`, Windows `Remove-Item -Recurse .`, `del/rmdir /s`).
- Destructive DB/framework wrappers → **BLOCK** (`DROP TABLE`, `prisma migrate reset`,
  `php artisan migrate:fresh/refresh`, …).
- `curl|sh` / `wget|bash` network→exec → **BLOCK**.
- Deleting a whitelisted build/cache dir (`dist`, `node_modules`, `.next`, …) → **ALLOW**.
- Deleting a normal subdir, or discarding one file's changes → **WARN**
  (bounded destruction; blocking all `rm -rf` would break legitimate cleanup).
- Obfuscated/embedded code that can't be analysed but shows execution intent →
  **UNKNOWN_HIGH_RISK** (block in strict; warn otherwise).

## Explicit non-goals / known gaps (do NOT claim otherwise)

The guard is **defense-in-depth against honest agent mistakes, not a sandbox.** It is
string-level operator tokenization, **not a real shell parser.** The following are
**known, unclosed bypasses** and can only be contained by an OS/container sandbox or a
restricted user:

- Env-var / variable indirection: `F=--force; git push $F`, `R=rm; $R -rf /` (F-06).
- Multi-step: `curl … -o a.sh; bash a.sh`.
- Arbitrary code via an interpreter that then does file writes (`node -e`, `python -c`).
- PowerShell `-EncodedCommand` / base64 payloads (treated as high-risk, not decoded).
- Anything after the agent edits the guard itself.
- The same destructive effect achieved via the **Write/Edit** tools if file policy does
  not cover it (the command guard only sees Bash).
- The audit log (`.kit/audit.log`) is **not tamper-evident** (F-12): an agent with
  write access can alter it.

## README rule

The README must NOT use absolute claims ("every dangerous command is blocked", "the AI
cannot bypass the guard", "self-healing", "runtime progressive disclosure", "automatic
test-fix loop") unless the code implements exactly that. See the capability table in
the README.
