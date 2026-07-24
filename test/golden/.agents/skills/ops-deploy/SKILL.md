---
# GENERATED — DO NOT EDIT. Edit engine/ or kit.config.yaml, then run: kit build
name: "ops-deploy"
description: "Use before deploying or changing a running environment — after release-check (or with it), before touching prod/staging. Invoke to pin the deploy plan: target env, artifact/version, migrate order, smoke checks, observability, rollback, and required approvals. Turns \"just deploy\" into a reversible ops runbook the agent must follow."
license: "Apache-2.0"
compatibility: "Requires repository read access."
metadata:
  sixmen-version: "1.0.0"
  sixmen-trust-tier: "T0"
  sixmen-owner: "platform-team"
---

# Ops Deploy skill

The bridge from "tests are green" to **a safe change in a real environment**. Run it before
devops executes deploy/migrate/config changes on staging or production. Most prod incidents
are an undeclared migration order, a missing smoke check, or no rollback — name those here.

Work from **[references/ops-guide.md](references/ops-guide.md)**. Pair with **`release-check`**
(SemVer · changelog · go/no-go) and **`db-admin`** when schema moves. Prefer the project's
existing deploy path (script, CI job, platform) — invent a second pipeline only after the
architect records it.

## Workflow
1. **Target & blast radius.** Name env (`dev` · `staging` · `prod`), what changes (app ·
   config · schema · infra), and who/what is affected. Confirm `prod_deploy` /
   `schema_change` approvers from kit.config — stop if sign-off is required and missing.
2. **Artifact & config.** Exact version/commit/image digest; config/secrets source (never
   paste secrets into chat or commit them). Confirm the artifact matches what release-check
   approved.
3. **Ordered steps.** Write the runbook: backup (if data) → migrate (expand-first if
   needed) → deploy app → smoke → observe. Never migrate-destructive before a backup +
   down-path. Say what runs where (CI job vs manual).
4. **Smoke & health.** Concrete checks after deploy (health/ready URL, one critical user
   path, error rate). Define **abort criteria** (e.g. 5xx spike, migrate fail).
5. **Rollback.** Exact reverse steps (redeploy previous artifact, migrate down / forward-fix,
   restore backup if needed) with an owner and time box. A deploy with "we'll figure rollback
   later" **fails this skill**.
6. **Observability.** What to watch for N minutes (logs, metrics, alerts). Link to existing
   dashboards if the project has them; otherwise name the minimum signals.

## Output format (required)
```md
## Target (env · what changes · blast radius)
## Approvals (prod_deploy / schema_change — required? obtained?)
## Artifact (version / commit / image)
## Runbook (ordered steps)
## Smoke & abort criteria
## Rollback (exact steps)
## Watch window (signals · duration)
## Go / no-go (ops)
```

**Quality bar:** missing **rollback steps** or deploying **prod** without addressing
approvers (when configured) **fails — redo**. `vibe` = target + steps + rollback + smoke;
`strict` = full table including watch window and abort criteria. Dry-run / staging first
when the change touches data or is a first-time path.
