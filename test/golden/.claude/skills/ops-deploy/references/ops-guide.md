# Ops deploy reference — environments, migrate order, smoke, rollback

Loaded by `ops-deploy`. Complements `release-check` (version/changelog gate) with the
**how we change a live system** playbook.

## 1. Environments
- Prefer **promote** the same artifact: build once → staging → prod (digest/tag immutable).
- Never "build on the prod box from whatever is on main right now" if the project already
  has CI artifacts.
- Config differs per env; **code** should not. Secrets via the project's secret store /
  env injection — never in git.

## 2. Change types (pick one primary)
| Type | Typical risk | Notes |
|---|---|---|
| App-only | Medium | Rollback = prior image/tag |
| Config / feature flag | Low–High | Flags beat emergency redeploys when possible |
| Schema migrate | High | db-admin + expand/contract; approver |
| Infra (DNS, LB, storage) | High | smallest step; documented reverse |

## 3. Migration order (expand / contract)
When schema and app must both change:
1. **Expand** schema (additive, compatible with old app) → deploy
2. Deploy app that uses new shape
3. **Contract** later (drop old columns) in a separate change
Never drop/rename a hot column in the same deploy as the app that still needs it unless
the project already uses a proven zero-downtime tool and the runbook says so.

## 4. Backup & data
- Before destructive or hard-to-reverse data work: backup (or snapshot) + known restore
  command. "We have automated backups" is not enough — name **how to restore this**.
- Prefer forward-fix over down-migrate when down is unsafe; still document it.

## 5. Smoke checklist (minimum)
- Health/readiness returns OK
- One authenticated critical path (login, create order, … — whatever the product is)
- No error storm in the first watch window
Customize to the constitution's critical path; don't invent a dashboard the project lacks —
say how you will verify manually if needed.

## 6. Rollback patterns
- **App:** redeploy previous immutable artifact; confirm health
- **Migrate:** down migration **or** forward-fix script; never leave half-applied money state
- **Config:** revert flag/config revision
- **Failed mid-runbook:** stop; do not "finish the remaining steps" blindly

## 7. Abort criteria (examples — adapt)
- Migrate command non-zero exit
- Ready probe failing > N minutes
- Error rate or latency beyond project SLO (or rough threshold if none recorded)
Write numbers the on-call can use; "if it looks bad" fails the skill.

## 8. Anti-patterns
- SSH snowflake changes with no record
- Prod deploy from a dirty local working tree
- Skipping staging on first-time migrate path in `strict`
- Pasting `.env` / keys into the task file or chat

## Sources
- Google SRE — Release Engineering (gradual rollout, hermetic builds).
- Expand/contract migrations — common zero-downtime practice.
- Twelve-Factor — config in the environment; logs as event streams.
