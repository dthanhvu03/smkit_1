---
name: infra-iac
description: Use before adding or changing Infrastructure-as-Code — Terraform, Pulumi, CDK, Crossplane, or cloud module layouts. Invoke to pin providers, state backend, environments, blast radius, IAM least privilege, secrets, and destroy/rollback posture. Opt-in depth for infra repos; app-only projects can ignore it.
license: Apache-2.0
compatibility: Requires repository read access.
metadata:
  sixmen-version: "1.0.0"
  sixmen-trust-tier: "T0"
  sixmen-owner: platform-team
---

# Infra IaC skill

Design **cloud/infra changes as code** before editing modules. Use when touching Terraform,
Pulumi, CDK, Crossplane, or shared infra modules. Skip for app-only deploys already covered
by **`ops-deploy`** / platform UI (Vercel/Fly) with no IaC repo.

Work from **[references/iac-guide.md](references/iac-guide.md)**. Pair with **`ops-deploy`**
for the apply runbook (smoke/rollback) and **`ci-pipeline`** for plan/apply automation.
Never commit cloud secrets; never `apply` to prod without the project's approval path.

## Workflow
1. **Scope & blast radius.** What resources change? Which env (`dev`/`staging`/`prod`)?
   Who can be taken down? Prefer smallest module blast radius.
2. **Reuse house layout.** Match existing backend state, workspace/stack naming, module
   boundaries, and tagging. Do not invent a second state layout.
3. **State & locking.** Remote state + lock (S3+Dynamo, GCS, Terraform Cloud, Pulumi
   backend…). Local state for shared infra is a **no** in `strict`.
4. **IAM & secrets.** Least privilege identities; no long-lived keys in git; prefer OIDC /
  workload identity. Secrets from the project's secret manager — not `*.tfvars` committed.
5. **Plan before apply.** Require a reviewed `plan` (or Pulumi preview) artifact for prod.
   Separate plan/apply roles when the project does so.
6. **Safety rails.** Prevent accidental destroy of stateful stores (lifecycle /
   deletion_protection / prevent_destroy as house style). Document data backup before
   destroy-class changes.
7. **Rollback.** How to revert (prior state/version, apply previous tag, restore).
   Infra rollback ≠ always "terraform destroy". Hand the live apply steps to **`ops-deploy`**.

## Output format (required)
```md
## Change summary (resources · envs · blast radius)
## Layout reused (backend · modules · workspaces/stacks)
## State & locking
## IAM / secrets approach (no secret values)
## Plan / apply / approval path
## Protect stateful resources (yes/how)
## Rollback
## CI hooks (ci-pipeline · ops-deploy) if any
```

**Quality bar:** prod IaC change with **no remote state/lock story**, or **secrets in
repo**, or **no rollback/approval note** when `approvers.prod_deploy` is set, **fails —
redo**. `vibe` = scope + plan/apply + rollback; `strict` = full checklist including IAM
and stateful protection.
