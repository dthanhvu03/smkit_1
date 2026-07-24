# API design reference — contracts, HTTP, layering, anti-patterns

Loaded on demand by the `api-design` skill. Distilled for agents shipping real APIs without
inventing a second house style every sprint.

## 1. Resource & URL design
- Prefer **nouns** for collections and items: `/bookings`, `/bookings/{id}`.
- Nest only when the child has no independent identity worth addressing alone, and keep
  nesting shallow (≤2). Deep trees become uncacheable and hard to authorize.
- Query params for **filter / sort / page** — not for mutating state.
- Stick to the project's casing (`kebab-case` paths vs camelCase JSON fields as already
  decided). One way per thing.
- GraphQL / tRPC / gRPC: apply the same *contract* ideas (authz, errors, idempotency,
  layering) even if paths differ — map to the project's existing procedure style.

## 2. HTTP method semantics (REST-ish)
| Method | Safe? | Idempotent? | Typical use |
|---|---|---|---|
| GET | yes | yes | Read |
| HEAD | yes | yes | Metadata |
| PUT | no | yes | Replace / upsert whole resource |
| DELETE | no | yes | Remove (repeat = still gone) |
| POST | no | **no** (unless designed) | Create / non-idempotent action |
| PATCH | no | often no | Partial update |

- Do **not** overload GET to mutate. Do **not** use POST for everything "because simpler"
  when the project already uses REST verbs correctly.
- For non-idempotent POST that clients may retry (payments, bookings), require an
  **Idempotency-Key** (or natural unique constraint) — see the reliability rule.

## 3. Status codes — use the project's map; don't invent per route
Common defaults when the project has none recorded yet:
- `200` / `201` / `204` for success (create → `201` + Location when that is house style)
- `400` validation / malformed · `401` unauthenticated · `403` authenticated but forbidden
- `404` unknown resource (or hide existence when security requires it — record which)
- `409` conflict (unique, version, illegal state transition)
- `422` semantic validation if the project distinguishes it from `400`
- `429` rate limit · `5xx` unexpected — never leak stack traces to clients

## 4. Error envelope — one shape forever
Pick (or reuse) a single JSON error shape, e.g.:
```json
{ "error": { "code": "BOOKING_FULL", "message": "…", "details": [] } }
```
- Stable **machine codes** for clients; human `message` may localize later.
- Map domain invariant failures to the same envelope (illegal transition → `409` + code).
- Never return a different ad-hoc `{ "msg": "fail" }` from one handler.

## 5. Authn / authz (OWASP A01 first)
- Every mutating and sensitive read names **who** may call it and on **which** object.
- Authorize on the **server** using the resource id from the path/body after load —
  never trust a client-supplied "ownerId" alone (IDOR).
- Deny by default. List endpoints that are intentionally public.

## 6. Lists — pagination, filter, sort
- Cursor or offset — **one** house style. Document default page size and max.
- Stable sort key (tie-break with id) so pages do not skip/duplicate under writes.
- Filter fields are an allow-list; reject unknown query keys in `strict` if that is house
  style.

## 7. Layering — where logic lives
```
Transport (HTTP/RPC handler)  → parse, authn context, status mapping
Application / use-case        → orchestration, transactions
Domain                        → invariants, state transitions (domain-model)
Persistence                   → queries/commands; no business rules if avoidable
```
- **Fat handler / god service** that re-implements rules already in another route = DRY
  failure — extract once, call from both.
- DTOs at the boundary ≠ DB rows. Map explicitly; do not serialize internal entities by
  accident (password hashes, soft-delete flags, PII extras).

## 8. Compatibility & versioning
- Additive fields are usually safe; renaming/removing/changing meaning is **breaking**.
- Prefer expand-contract: add new → migrate callers → remove old.
- Public APIs: version in path (`/v1`) or header — follow what the Decision Log already
  chose; don't add `/v2` for a single field tweak.

## 9. Observability at the edge
- Structured logs: method, path template, status, latency, request id — **no** secrets/PII.
- Failed authz and invariant violations should be visible to operators (reliability rule).

## 10. Anti-patterns (fail the skill if you ship these knowingly)
- Copy-paste validation/authz across three handlers instead of shared middleware/helper
- Different error JSON per route
- Business rules only in the SQL string or only in the UI
- Breaking JSON field with no migration note
- "Success: false" with HTTP 200 for errors (unless that is an explicit legacy contract)

## Sources
- HTTP Semantics (RFC 9110) — method safety/idempotency.
- OWASP API Security Top 10 — broken object-level auth (API1), excessive data exposure.
- Microsoft REST API Guidelines / Google AIP — practical resource & error patterns
  (adapt to house style; do not cargo-cult whole guides).

> Provenance: concepts verified against RFC 9110 method properties and OWASP API Security
> themes (2026-07). Project Decision Log always wins over this reference when they conflict.
