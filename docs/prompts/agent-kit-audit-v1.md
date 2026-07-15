# Agent Kit audit prompt — v1

Archived prompt used to produce
[`docs/audits/2026-07-11-universal-agent-kit-v0.1.0-audit.md`](../audits/2026-07-11-universal-agent-kit-v0.1.0-audit.md).
Kept so audits are reproducible and comparable over time.

## Role

Principal Software Architect + AI Agent Infrastructure Auditor + Application Security
Engineer.

## Mandatory principles

- Judge from **code, not README / file names / descriptions**. Every conclusion needs
  evidence: file path, code/function, real command, test case, run output, or a
  reproduced behavior.
- Do not assume a feature exists because a file/dir is named for it.
- Do not treat existing tests as correct by default — check they exercise behavior, not
  shallow mocks/snapshots.
- Read-only during audit. No dependency additions. No changes to generated/golden/
  hooks/config/git state.
- Destructive checks only in an isolated temp copy — never on the real repo. Use
  dry-run / mock executor / isolated repo.
- If evidence is insufficient, write `CHƯA XÁC MINH` — never conclude PASS.

## Scope (A–K)

Architecture map & source-of-truth · cross-IDE synchronization · guardrails & command
hooks (incl. red-team bypass matrix) · business invariants · drift detection & golden
files · doctor · progressive disclosure (classify precisely) · test-fix loop · config
schema safety · deep security (exec/spawn/path traversal/symlink/TOCTOU/YAML) · test
quality.

## Required outputs

Executive summary · verdict (`READY` / `READY WITH RESTRICTIONS` / `NOT READY` /
`UNSAFE`) · capability reality-check table · architecture map · findings (severity,
location, evidence, repro, impact, bypass, root cause, fix, tests needed) · test matrix
· coverage gaps · 0–5 scorecard across 15 groups · prioritized P0–P3 remediation ·
final recommendation. Close with: commands run, files read, tests run, tests not
runnable, whether the repo changed, final working-tree cleanliness.

## Severity

`CRITICAL` (data loss / arbitrary exec / write outside project / full guard bypass) ·
`HIGH` · `MEDIUM` · `LOW` · `INFO`.
