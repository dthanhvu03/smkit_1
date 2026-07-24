# Async workflows reference — queues, outbox, saga, poison

Loaded by `async-workflows`. Opt-in depth; not every app needs a broker.

## 1. When you actually need async
- Work is slow, bursty, or calls flaky externals
- You must acknowledge HTTP fast then finish later
- Multiple systems must react to one business event
If a single DB transaction in the request finishes the job safely — **don't** introduce a
queue for fashion.

## 2. Delivery semantics
| Claim | Reality for most brokers |
|---|---|
| At-most-once | Can lose messages — rarely OK for money |
| At-least-once | Duplicates happen — **design for it** |
| Exactly-once | End-to-end myth unless you control the whole path |

**Idempotent consumer** + dedupe store/unique constraint is the practical exactly-once.

## 3. Transactional outbox (recommended for "DB then notify")
1. In the same DB transaction: write business rows + outbox row
2. Relay publishes outbox to the broker
3. Worker processes; marks done
Avoid "commit DB then publish" without outbox — crash between the two loses or doubles work.

## 4. Saga shapes
- **Orchestration** — one coordinator calls steps; easier to see; single point to watch
- **Choreography** — each service reacts to events; looser coupling; harder to trace
Every step needs: success path, timeout, and **compensation** (or an explicit "manual
repair" queue with owner). Compensations are business undos, not distributed transactions.

## 5. Retry & poison
- Retry transient errors with exponential backoff + jitter
- Cap attempts; then **DLQ** / poison table with alert
- Do not infinite-retry validation errors (fix the message, fix producer)
- Visibility timeout ≥ worst-case handler time (or heartbeat extend)

## 6. Ordering
- Global order across partitions is expensive — rarely required
- Per-aggregate key ordering (same booking id → same partition/shard) is the usual need
- Handlers must still tolerate duplicates even with ordering

## 7. Testing (minimum)
- Happy path once
- **Duplicate delivery** of the same message (idempotency)
- Handler crash mid-way + redelivery
- Poison / bad payload → DLQ, not silent loop
- Saga: fail step N and assert compensations / terminal state

## 8. Anti-patterns
- Shared mutable "processing" flag without unique constraint
- Huge payloads in the queue (put blob in object store; message carries pointer)
- Catch-all `retry forever` on payment capture
- Saga with no owner dashboard for stuck instances

## Sources
- Enterprise Integration Patterns — messaging basics
- Microservices patterns — transactional outbox, saga
- Broker docs (SQS/Rabbit/Kafka) — at-least-once + visibility timeout realities
