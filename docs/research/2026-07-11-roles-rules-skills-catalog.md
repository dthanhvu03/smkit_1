# Recommended Role / Rule / Skill catalogs (2026-07-11)

Decisions only — **not implemented in this pass.** Classification vocabulary:
`CORE` (every project) · `PROFILE` (stack-provided) · `PROJECT` (project-specific) ·
`OPTIONAL` · `EXPERIMENTAL` · `REJECT`. "Decision" = keep / merge / defer / reject with
reason. The kit today ships 7 roles, 4 commands, ~4 engine rules, 6 skills; these tables
are the target set to grow toward, deliberately, not all at once.

Design rule applied: **one responsibility per role**; a role never plans + implements +
reviews + approves its own work; tools never exceed the job.

---

## 1. Recommended Role Catalog

| ID | Purpose | Classification | Trigger | Permission/Risk | Targets | Decision |
|---|---|---|---|---|---|---|
| planner | Decompose into steps + DoD before design/code | CORE | "break this down", new task | read-only | claude(sub); others=index | keep (exists) |
| planner-architect / architect | Structure, boundaries, interfaces, library choice | CORE | design/tradeoff | read-only | claude; others=index | keep (exists as `architect`) |
| implementer / implementation-agent | Write/edit code to a plan | CORE | build/fix once plan exists | write+shell | claude; others=index | keep (exists) |
| code-reviewer / reviewer | Static diff review | CORE | after code change | read-only | claude; others=index | keep (exists as `reviewer`) |
| test-engineer / qa | Validate behavior at runtime | CORE | "does it work", tests | read+shell | claude; others=index | keep (exists as `qa`) |
| debugger | Reproduce + isolate a failure | OPTIONAL | failing test/stack trace | read+shell | claude | defer (overlaps qa; add when evidence) |
| security-reviewer | Auth/secret/exec/file-access risk review | PROFILE(strict) | security-sensitive diff | read-only | claude | add (P1); today a *skill* |
| codebase-explorer / researcher | Map unknown code / gather context | OPTIONAL | onboarding, "how does X work" | read-only | claude(sub ideal) | add as OPTIONAL (great subagent fit) |
| documentation-maintainer | Keep docs/ADRs in sync | OPTIONAL | docs drift | write(docs) | claude | defer |
| coordinator / orchestrator | Route a small task across roles | CORE(standard+) | multi-role task | read-only | claude | keep (exists as `orchestrator`) |
| devops / ci-release-engineer | Release/build/deploy/CI | PROFILE | ship/deploy | shell+approval | claude | keep (exists as `devops`); split release vs infra later |
| database-migration-reviewer | Review destructive/irreversible migrations | PROFILE(db) | migration files | read-only | claude | add as PROFILE (high value, bounded) |
| api-contract-reviewer | Backward-compat of public APIs | PROFILE(api) | route/contract change | read-only | claude | add as PROFILE |
| frontend-reviewer | UI component conventions | PROFILE(frontend) | component change | read-only | claude | PROFILE (nextjs) |
| accessibility-reviewer | a11y checks | PROFILE(frontend)/OPTIONAL | UI change | read-only | claude | OPTIONAL |
| performance-reviewer | Hot-path/perf review | OPTIONAL | perf-critical code | read-only | claude | OPTIONAL |
| dependency-maintainer | Vet/upgrade deps | OPTIONAL | dep bump | read+shell(approval) | claude | OPTIONAL (pairs with supply-chain guard) |
| infrastructure-reviewer | IaC review | PROFILE(infra) | terraform/pulumi/k8s | read-only | claude | PROFILE |
| data-privacy-reviewer | PII/data-handling review | PROFILE(strict) | PII paths | read-only | claude | PROFILE(strict) |
| browser-agent | Drive a browser | EXPERIMENTAL | e2e/UI automation | shell+network | claude(vendor) | EXPERIMENTAL (out of scope) |
| "senior-developer" (not in list) | — | REJECT | — | — | — | **REJECT**: does everything, no single responsibility |

**Rejections/merges:** `researcher` ≈ `codebase-explorer` (keep one, name
`codebase-explorer`); `planner-architect` split into existing `planner`+`architect`;
`implementation-agent`=`implementer`; `code-reviewer`=`reviewer`; `test-engineer`=`qa`;
`coordinator`=`orchestrator`. Any "senior/fullstack/general" mega-role → REJECT.

## 2. Recommended Rule Catalog

Enforcement type ∈ `guidance | static-check | hook | ci | permission | sandbox |
unsupported`. "Belongs in" flags when a candidate is really a Skill/Hook/CI, not a Rule.

### Global (always-on unless noted)
| ID | Classification | Activation | Enforcement | Decision |
|---|---|---|---|---|
| source-of-truth-and-precedence | CORE | always | guidance | keep (in hard-rules) |
| task-scope-discipline | CORE | always | guidance | add |
| evidence-before-claim | CORE | always | ci/static-check | keep (evidence-gate) |
| safe-filesystem-operations | CORE | always | **hook** (not rule) | keep as guard v3 hook; rule = pointer only |
| git-safety | CORE | always | **hook** | guard hook; rule = pointer |
| secret-and-privacy | CORE | always | guidance + permission(deny .env) | keep (settings deny + rule) |
| dependency-and-supply-chain | CORE | always | hook(warn) + guidance | keep (guard v3 + consistency-guard) |
| generated-file-ownership | CORE | always | static-check(manifest) | add (doctor/manifest already enforce) |
| testing-and-verification | CORE | always | ci/guidance | keep |
| error-handling-and-observability | STANDARD | always | guidance | add |
| documentation-and-adr | STANDARD | always | guidance | add |
| final-reporting | CORE | always | guidance | keep (in hard-rules/roles) |
| consistency-first (2nd-lib) | CORE | path | hook(warn) | keep (consistency-guard) |

### Scoped / profile
| ID | Classification | Activation | Enforcement | Decision |
|---|---|---|---|---|
| architecture-boundaries | PROFILE | path | guidance/static-check | add (as invariant) |
| api-contracts | PROFILE(api) | path (`**/route.ts`,…) | guidance | exists (nextjs invariant) |
| database-and-migrations | PROFILE(db) | path (`**/migrations/**`) | guidance + role gate | add |
| authentication-and-authorization | PROFILE(strict) | path | guidance | add |
| frontend-components | PROFILE(frontend) | path | guidance | exists (nextjs conventions) |
| accessibility | OPTIONAL | path | guidance | OPTIONAL |
| test-code | CORE | path (`**/*.test.*`) | guidance | add |
| ci-cd | PROFILE | path (`.github/**`) | ci | add |
| deployment | PROFILE | manual/path | ci/approval | add |
| infrastructure-as-code | PROFILE(infra) | path | guidance/ci | add |
| performance-critical-code | OPTIONAL | path/manual | guidance | OPTIONAL |
| payment-and-financial-logic | PROJECT/strict | path (`src/payments/**`) | guidance + required test invariant | add (the canonical invariant example) |
| personally-identifiable-information | PROFILE(strict) | path | guidance/permission | add |
| monorepo-package-boundaries | PROFILE(monorepo) | path | guidance | add |
| language-specific-style | PROFILE | path/glob | guidance | exists (go/python/nextjs conventions) |
| framework-specific-conventions | PROFILE | path | guidance | exists |

**"Belongs elsewhere" flags:** `safe-filesystem-operations`, `git-safety`,
`dependency-and-supply-chain` are **hooks**, not guidance rules — the rule file should only
*point at* the hook, never claim to enforce. `evidence-before-claim`, `ci-cd`, `deployment`
are **ci/static-check**. This mapping is the whole point of the `enforcement.type` field.

## 3. Recommended Skill Catalog

Side-effecting skills (deploy/publish/migrate/rollback/secret/notify) → **manual +
approval + preflight + verification + rollback, no implicit invocation** (marked ⚠).

### Universal engineering skills
| ID | Classification | Invocation | Risk/Tier | Decision |
|---|---|---|---|---|
| onboard-codebase | OPTIONAL | implicit/manual | T0 read | add |
| research-official-docs | OPTIONAL | implicit | T0 read+net | add (net → mark) |
| plan-task | CORE | implicit/manual | T0 read | add (pairs w/ planner) |
| implement-feature | OPTIONAL | manual | T0 write | defer (role does this) |
| fix-bug | OPTIONAL | manual | T0 write | defer |
| debug-test-failure | OPTIONAL | implicit | T0 read+shell | add |
| write-tests | CORE | implicit/manual | T0 | keep (test-design) |
| run-quality-gates | CORE | manual | T0 shell | add |
| review-code | CORE | implicit | T0 read | keep (code-review) |
| security-audit | PROFILE(strict) | implicit | T0 read | keep (security-review) → rename to standard |
| safe-refactor | CORE | manual | T0 | keep (refactor) |
| update-dependencies | OPTIONAL ⚠ | manual+approval | T0 shell+net | add (⚠ side effects) |
| change-api-contract | PROFILE(api) | manual | T0 | add |
| create-database-migration | PROFILE(db) ⚠ | manual+approval | T0 | add (⚠) |
| diagnose-ci-failure | OPTIONAL | implicit | T0 read | add |
| release-preflight | CORE ⚠ | manual | T0 | keep (release-check) |
| deploy | PROFILE ⚠ | manual+approval | T1 shell+net | add (⚠ preflight+rollback) |
| rollback-release | PROFILE ⚠ | manual+approval | T1 | add (⚠) |
| sync-documentation | OPTIONAL | implicit/manual | T0 write(docs) | add |
| write-adr | OPTIONAL | manual | T0 | add |
| guard-design | CORE | manual/implicit | T0 | keep (exists) |

### Agent-Kit maintenance skills
| ID | Classification | Invocation | Risk/Tier | Decision |
|---|---|---|---|---|
| audit-agent-kit | OPTIONAL | manual | T0 read | add (this repo's own audits) |
| validate-kit-config | CORE | manual/implicit | T0 | add (wraps validator) |
| build-target-artifacts | CORE | manual | T0 | add (wraps build) |
| verify-deterministic-output | OPTIONAL | manual | T0 | add |
| detect-generated-drift | CORE | manual | T0 | add (wraps doctor drift) |
| repair-owned-output | OPTIONAL ⚠ | manual+approval | T0 | add (regeneration, NOT self-heal) |
| create-role / create-rule / create-skill | OPTIONAL | manual | T0 | add (scaffolding) |
| add-target-adapter | EXPERIMENTAL | manual | T0 | defer (out of scope) |
| verify-target-capabilities | OPTIONAL | manual | T0 | add (uses registry) |
| test-emitter-contract | OPTIONAL | manual | T0 | add |
| red-team-command-guard | OPTIONAL | manual | T0 | add (guard bypass suite) |
| audit-skill-supply-chain | OPTIONAL | manual | T0 | add (trust tiers) |
| migrate-kit-schema | OPTIONAL ⚠ | manual+approval | T0 | add |
| create-profile / validate-profile-inheritance | OPTIONAL | manual | T0 | add |

**Standard-alignment note:** every skill above adopts the Agent Skills open-standard
frontmatter (`name`, `description`, `allowed-tools`) with kit-specific fields under
`metadata:` (trust tier, provenance, network, executableScripts, supportedTargets).

## 4. Presets

| Preset | Roles | Rules | Skills |
|---|---|---|---|
| **minimal** | orchestrator, implementer, reviewer | hard-rules, consistency-guard, evidence-gate, generated-file-ownership | plan-task, review-code, write-tests, safe-refactor |
| **standard** | + planner, architect, qa, devops | + task-scope-discipline, testing-and-verification, error-handling, documentation-and-adr, language/framework conventions | + run-quality-gates, debug-test-failure, release-preflight, security-audit, guard-design |
| **strict** | + security-reviewer, database-migration-reviewer, api-contract-reviewer, data-privacy-reviewer | + auth-and-authz, database-and-migrations, PII, payment-and-financial-logic, ci-cd, deployment | + create-database-migration ⚠, deploy ⚠, rollback-release ⚠, audit-skill-supply-chain |

`minimal` ⊂ `standard` ⊂ `strict`. Side-effecting skills (⚠) appear only in `strict` and
always as manual + approval. Presets map to the existing `mode: vibe|standard|strict`
knob but are an independent selection axis (a `vibe` project can opt into `standard`
catalog).
