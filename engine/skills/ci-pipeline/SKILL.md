---
name: ci-pipeline
description: Use when adding or changing CI/CD workflows, deploy pipelines, or release automation. Invoke to pin a safe pipeline design: triggers, jobs, secrets handling, caching, required checks, and promote-to-prod rules — before editing workflow YAML. Prevents flaky, secret-leaking, or push-to-prod-without-gate pipelines.
license: Apache-2.0
compatibility: Requires repository read access.
metadata:
  sixmen-version: "1.0.0"
  sixmen-trust-tier: "T0"
  sixmen-owner: platform-team
---

# CI Pipeline skill

Design (or change) continuous integration / delivery **before** rewriting workflow files.
Run when the user asks for GitHub Actions / GitLab CI / similar, or when `/ship` needs a
new check to enforce quality. Reuse the project's existing CI; extend it — don't spawn a
parallel undocumented pipeline.

Work from **[references/ci-guide.md](references/ci-guide.md)**. Keep **`ops-deploy`** for
the human/runbook side of a prod change; this skill owns the **automated** path.

## Workflow
1. **Reuse first.** Inventory existing workflows (`.github/workflows/`, `.gitlab-ci.yml`,
   etc.), required status checks, and secrets already in use. Prefer one pipeline per
   concern (test · build · deploy) over a dozen near-copies.
2. **Triggers & scope.** `pull_request` / `push` / `workflow_dispatch` / tags — path filters
   when monorepo. Never `pull_request_target` + untrusted checkout without a hard reason.
3. **Jobs & evidence.** Lint → test → build (fail fast). Quote what "green" means. Cache
   dependencies safely (lockfile-keyed). Pin actions by SHA or trustworthy version tags
   per house style.
4. **Secrets & permissions.** Least privilege (`permissions:` block). No secrets in
   forks/PRs from untrusted sources. Never echo secrets; mask them.
5. **Deploy jobs.** Separate from PR checks. Prod deploy requires protection rules /
   environment approval / manual gate when the project has approvers. Artifact promotion
   (same digest) over rebuild-on-prod. Wire to **`ops-deploy`** runbook for smoke/rollback
   expectations.
6. **Record.** Note new required checks and secret names (not values) in the Decision Log
   / task so the next change reuses them.

## Output format (required)
```md
## Purpose (what this pipeline proves or ships)
## Existing CI reused / extended
## Triggers & path filters
## Jobs (order · fail-fast · caches)
## Secrets & permissions (names only; least privilege)
## Deploy / promote rules (if any)
## Required checks for merge
## Risks & rollback of the pipeline change itself
```

**Quality bar:** a **prod deploy** job without an approval/environment gate (when
`approvers.prod_deploy` is non-empty) or a workflow that **prints secrets** **fails —
redo**. `vibe` = jobs + triggers + secrets note; `strict` = full permissions, required
checks, and deploy gating.
