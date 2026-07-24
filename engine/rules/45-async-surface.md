---
id: async-surface
scope: paths
enforce: agent-read
paths:
  - "**/workers/**"
  - "**/worker/**"
  - "**/jobs/**"
  - "**/queues/**"
  - "**/queue/**"
  - "**/consumers/**"
  - "**/consumer/**"
  - "**/subscribers/**"
  - "**/outbox/**"
  - "**/saga/**"
  - "**/sagas/**"
  - "**/workflows/**"
  - "**/*Worker.*"
  - "**/*Consumer.*"
  - "**/*Job.*"
  - "**/bull/**"
  - "**/sidekiq/**"
  - "**/celery/**"
title: Async surface — queues, workers, sagas
---

# Async surface — when you touch jobs / queues / workers

Loads on worker/queue/outbox/saga paths. Complements always-on `reliability` with the
**`async-workflows`** contract (opt-in depth — CRUD-only apps rarely hit these paths).

## Before writing
- Run (or confirm) **`async-workflows`**: pattern, message contract, **idempotency**,
  retry/DLQ, compensations if multi-step.
- Reuse the project's broker and job library; a second queue stack is a consistency stop.

## While implementing
- Assume **at-least-once** — handlers idempotent; dedupe keys enforced in DB when money /
  booking / inventory is involved.
- Prefer transactional **outbox** when the same use case writes DB then notifies.
- Never infinite-retry non-transient / non-idempotent payment-like steps.

## Before claiming done
- Evidence: test or manual proof for **duplicate delivery** (and poison→DLQ when relevant).
