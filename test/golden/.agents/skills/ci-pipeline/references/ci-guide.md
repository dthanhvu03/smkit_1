# CI / CD pipeline reference — safe automation defaults

Loaded by `ci-pipeline`. Adapt to the project's vendor (GitHub Actions, GitLab, etc.);
principles stay the same.

## 1. Pipeline shapes
- **PR / verify:** lint, unit/integration tests, (optionally) build — must be green to merge
- **Release / tag:** build immutable artifact, publish, optionally deploy staging
- **Deploy prod:** manual or environment-protected; never the same unconstrained job as PR
Keep concerns split so a flaky deploy does not block every documentation PR forever —
unless the team explicitly wants a monorepo single pipeline.

## 2. Triggers
- Prefer `pull_request` + `push` to protected branches for verify
- `workflow_dispatch` for deliberate deploys
- Path filters (`paths:`) in monorepos to avoid useless runs
- Treat `pull_request_target` as dangerous (runs in base context with fork code) — avoid
  unless you fully understand the threat model

## 3. Supply chain & actions
- Pin third-party actions to a full commit SHA when the project’s security bar requires it;
  otherwise use a maintained major version tag and review changelogs
- Don't `curl | bash` installers in CI without checksums
- Depend on lockfiles; cache keyed by lockfile hash

## 4. Permissions (GitHub Actions example mindset)
```yaml
permissions:
  contents: read
  # add pull-requests: write / id-token: write only when needed
```
Default to read-only; elevate per job. OIDC to cloud > long-lived access keys when possible.

## 5. Secrets
- Repository/environment secrets — **names** in docs, never values
- PRs from forks: secrets usually unavailable (good) — don't invent workarounds that leak
- Mask + never `echo` into logs; prefer the vendor's secret mechanism

## 6. Deploy automation
- Build artifact once; promote by digest/tag
- Staging auto-deploy from `main` is fine if blast radius is accepted
- Prod: environment protection + required reviewers matching kit `approvers`
- After deploy: smoke job or documented handoff to `ops-deploy` smoke steps

## 7. Required checks
- Name the checks branch protection must require
- `kit-check` / `smkit check` when the repo uses the kit — keep agent config from drifting
- Don't mark a check optional if merge safety depends on it

## 8. Anti-patterns
- `on: push` to main with force-deploy and no tests
- World-writable `permissions: write-all`
- Duplicating five near-identical workflows instead of a reusable workflow / matrix
- Storing production kubeconfig or cloud keys in the repo

## Sources
- GitHub docs — workflow permissions, environments, hardened practices
- SLSA / supply-chain basics — pin artifacts, least privilege
- Kit `release-check` / SRE gradual rollout — promote, don't rebuild differently per env
