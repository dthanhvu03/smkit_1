# Infrastructure as Code reference — state, IAM, blast radius

Loaded by `infra-iac`. Opt-in for infra-heavy repos; complements `ops-deploy` (how we
apply safely) and `ci-pipeline` (plan/apply in CI).

## 1. Core principles
- **Desired state in git** — reviews happen on PRs, not click-ops (except break-glass)
- **Small blast radius** — modules/stacks per domain or env; avoid one mega-state
- **Immutable promotion** — same module version → staging → prod where possible
- **Least privilege** — identities for plan vs apply vs runtime separated when feasible

## 2. State
- Remote backend with **locking** to prevent concurrent corrupt applies
- State contains sensitive attrs — restrict who can read backends
- Never hand-edit state for routine changes; use import/move when required and record it

## 3. Environments
- Workspaces / stacks / separate state per env — pick the house pattern and stick to it
- Prod credentials only in protected CI environments or human-approved apply
- `terraform destroy` / stack rm on prod is exceptional — require explicit runbook

## 4. Modules
- Pin module versions; don't chase `main` of a shared module in prod
- Inputs validated; outputs documented; no hidden global side effects
- Tagging standard (owner, env, service) for cost and incident response

## 5. IAM & secrets
- Prefer short-lived creds (OIDC) over static access keys
- Secrets in Secret Manager / SSM / vault — referenced by ARN/name, not inlined
- Guard against committing `terraform.tfvars` with secrets (gitignore + scanning)

## 6. Stateful safety
- Databases, buckets with data, queues with backlog: enable deletion protection /
  `prevent_destroy` per house style
- Before destroy-class changes: backup + restore test note in the task
- Expand/contract for breaking resource replacements (create new → migrate → delete old)

## 7. Plan / apply discipline
- PR shows plan output (or policy check) for review
- Apply only from approved pipeline or break-glass with audit
- Drift: scheduled plan or vendor drift detection — don't ignore forever

## 8. Anti-patterns
- Local state for team infra
- `*` IAM policies "to make it work"
- Applying unreviewed local changes to prod
- Mixing app release and large network redesign in one PR without separate risk notes

## Sources
- Terraform / Pulumi best-practice guides (remote state, workspaces/stacks)
- CIS / cloud well-architected — least privilege, logging
- Kit `ops-deploy` — apply is still a deploy with smoke/rollback
