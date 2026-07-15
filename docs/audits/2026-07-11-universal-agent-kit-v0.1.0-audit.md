# Audit — Universal Agent Kit v0.1.0 (2026-07-11)

Principal-architect / security audit of the kit as (a) a config compiler and (b) a
safety layer. Read-only evidence: file paths, code, reproduced commands, tests. All
destructive experiments were run in isolated temp copies; the working repository was
not modified during the audit.

## Verdict (at audit time, pre-hardening)

- As a **config compiler**: sound — deterministic output, pure emitter registry,
  golden snapshot tests, zero-dependency.
- As a **safety layer**: NOT ready. `rm -rf .` and friends passed the guard;
  `outDir` could escape the project; a bad config produced partial output; `build`
  deleted user files in owned dirs.
- Overall: **NOT READY for production**; `READY WITH RESTRICTIONS` only for
  scaffolding with `outDir: dist` inside an OS sandbox, guard not trusted as a
  security boundary.

## Findings & status (updated by the hardening phase)

| ID | Severity | Summary | Status |
|---|---|---|---|
| F-01 | CRITICAL | Guard allows workspace-internal destruction (`rm -rf .`, `git clean -fdx`, `git checkout -- .`, `git restore .`, `find -delete`) | **Fixed** — guard v3 (P0.5), tests + hook E2E |
| F-02 | CRITICAL | `outDir` path traversal writes/deletes outside project | **Fixed** — path boundary via `path.relative` + realpath (P0.2) |
| F-03 | HIGH | Build doesn't validate config; no transaction/rollback | **Fixed** — validate-before-write (P0.1) + transactional apply (P0.4) |
| F-04 | HIGH | Build deletes user files in `.claude/.cursor/.github/.windsurf` | **Fixed** — ownership manifest (P0.3) |
| F-05 | MEDIUM | Guard ignores PowerShell/CMD destructive commands | **Fixed** — Windows verbs in guard v3 |
| F-06 | MEDIUM | Guard bypass via env-var/indirection/pipe/multi-step | **Partial (by design)** — documented in ADR-003; supply-chain + encoded-cmd added; true fix = OS sandbox |
| F-07 | MEDIUM | Profile-level invariants never merged/emitted | **Fixed** — invariant merge with IDs + enforcement |
| F-08 | MEDIUM | Doctor doesn't detect stale/unexpected files | **Fixed** — drift classification |
| F-09 | MEDIUM | Destructive DB wrappers (Prisma/Artisan) not blocked | **Fixed** — guard v3 |
| F-10 | LOW | YAML parser accepts malformed config, returns wrong data silently | **Mitigated** — validator rejects bad config before write; strict-subset rejection for unsupported syntax |
| F-11 | LOW | Doctor has no JSON output | **Fixed** — `doctor --json` |
| F-12 | INFO | Audit log not tamper-evident; consistency guard heuristic | **Documented** — ADR-003; not code-closable without a trusted store |

## Key reproductions (audit-time)

- `echo '{"tool_input":{"command":"rm -rf ."}}' | node .kit/hooks/guard-shell.mjs` → exit 0 (allowed). *Now exit 2.*
- `outDir: ../../ESCAPE` → wrote files outside project. *Now exit 1, nothing written.*
- Malformed config → `build` exit 0, `mode=undefined`, 23 files. *Now exit 1, 0 files.*
- User file in `dist/.claude/rules/` → deleted by next `build`. *Now survives.*

Full scoring, architecture map and remediation plan are preserved in the conversation
that produced this audit; this file is the durable record of findings and their
disposition. The audit prompt is archived at
[`docs/prompts/agent-kit-audit-v1.md`](../prompts/agent-kit-audit-v1.md).
