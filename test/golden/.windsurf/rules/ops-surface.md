---
# GENERATED — DO NOT EDIT. Edit engine/ or kit.config.yaml, then run: kit build
trigger: glob
globs: .github/workflows/**,.gitlab-ci.yml,**/Dockerfile*,**/docker-compose*.yml,**/docker-compose*.yaml,**/Makefile,**/deploy/**,**/deployments/**,**/k8s/**,**/kubernetes/**,**/helm/**,**/terraform/**,**/infra/**,**/*.tf,**/Procfile,**/fly.toml,**/render.yaml,**/vercel.json,**/netlify.toml
---

# Ops surface — when you touch pipelines or deploy config

Loads on CI workflow, container, IaC, and deploy-manifest edits. Complements
`ci-pipeline` (design the automation) and `ops-deploy` (runbook for a live change).

## Before editing
- Changing workflows / pipeline YAML → run (or confirm) **`ci-pipeline`** — triggers,
  secrets, permissions, deploy gates.
- Changing how prod/staging is released or adding a one-off prod step → **`ops-deploy`**
  runbook (rollback + smoke) and **`release-check`** when cutting a version.
- Terraform / Pulumi / CDK modules or state layout → **`infra-iac`** (this rule’s sibling
  **`iac-surface`** also loads on those paths).
- Schema in the same change → **db-admin** + evidence-gate migration note.

## While implementing
- Reuse existing workflows and secrets; do not add a second prod deploy path without a
  Decision Log entry.
- Least-privilege permissions; no secrets in logs or committed files.
- Prod deploy stays behind approval / environment protection when approvers exist.

## Before claiming done
- Quote CI dry evidence when possible (`act`, pipeline lint, or a PR check run).
- For a real env change: smoke + rollback named (ops-deploy output) — evidence gate applies.
