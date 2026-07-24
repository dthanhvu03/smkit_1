---
# GENERATED — DO NOT EDIT. Edit engine/ or kit.config.yaml, then run: kit build
name: "async-workflows"
description: "Use before building queues, background jobs, workers, webhooks-with-retry, outbox, or multi-step sagas — after domain-model when the workflow has business states. Invoke to pin message contracts, idempotency, retry/poison policy, ordering, and compensation. Opt-in depth for distributed/async work; skip for simple request/response CRUD."
license: "Apache-2.0"
compatibility: "Requires repository read access."
metadata:
  sixmen-version: "1.0.0"
  sixmen-trust-tier: "T0"
  sixmen-owner: "platform-team"
---

# Async Workflows skill

Design **reliable async work** before coding workers. Use when the feature needs a queue,
cron/job, webhook consumer, transactional outbox, or a multi-step saga across services.
Plain CRUD request/response does **not** need this skill — keep the core kit lean.

Work from **[references/async-guide.md](references/async-guide.md)**. Pair with
**`reliability`** (idempotency · races), **`domain-model`** (legal transitions), and
**`api-design`** when an HTTP API enqueues work. Reuse the project's existing broker
(Redis/SQS/Rabbit/…); do not add a second queue stack without an architect Decision Log entry.

## Workflow
1. **Trigger & outcome.** What starts the work (command, event, schedule, webhook)? What
   "done" means in business terms? List steps if more than one side effect.
2. **Pattern pick (name it).** Choose the smallest fit: fire-and-forget job · outbox +
   worker · pub/sub · **saga** (orchestration or choreography) with compensations. Say why
   not the simpler option.
3. **Message contract.** Payload fields, versioning, correlation/causation ids, and who
   produces/consumes. Keep payloads small; store fat data by reference when needed.
4. **Delivery & idempotency.** At-least-once is the default assumption — consumer **must**
   be idempotent (dedupe key / unique constraint). Define retry, backoff, max attempts,
   and **poison / DLQ** behavior. Never retry non-idempotent money steps blindly.
5. **Ordering & concurrency.** Per-key ordering needed? Competing consumers OK? Timeouts
   and visibility timeouts matched to max runtime.
6. **Failure & compensation.** For sagas: each step's success event and compensating
   action if a later step fails. Partial success must leave an explainable business state
   (domain-model invariants still hold).
7. **Observability.** Log/metric on enqueue, start, success, fail, DLQ — with correlation
   id. Alert on DLQ depth / age for money or booking paths.

## Output format (required)
```md
## Trigger → business outcome
## Pattern (job · outbox · pub/sub · saga) + why
## Messages (producers · consumers · schema/version)
## Idempotency & dedupe keys
## Retry / backoff / DLQ
## Ordering & concurrency
## Compensations (if saga)
## Observability & alerts
## Tests (at least: happy · duplicate delivery · poison)
```

**Quality bar:** an async money/booking/inventory path with **no idempotency/dedupe plan**,
or a multi-step flow with **no compensation/failure story**, **fails — redo**. `vibe` =
pattern + idempotency + retry/DLQ; `strict` = full contract + compensations + test plan.
