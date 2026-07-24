---
# GENERATED — DO NOT EDIT. Edit engine/ or kit.config.yaml, then run: kit build
trigger: glob
globs: **/api/**,**/apis/**,**/routes/**,**/route.ts,**/route.js,**/controllers/**,**/handlers/**,**/endpoints/**,**/*Handler.*,**/*Controller.*,**/*.controller.*,**/*.handler.*,**/graphql/**,**/trpc/**
---

# API surface — when you touch HTTP/RPC routes

Loads when you edit route/handler/controller files. Complements `api-design` (pin the
contract first) and `reliability` (retries, races, money).

## Before writing or expanding an endpoint
- Run (or confirm this turn has) the **`api-design`** skill output — resources, status
  codes, **error envelope**, **authz**, idempotency for writes. "I'll figure errors later"
  is not allowed on a new mutating route.
- **Reuse** the project's existing middleware, error helper, auth guard, and pagination
  helpers. A second error shape or second HTTP client is a consistency stop.

## While implementing
- **Handlers stay thin** — parse → authorize → call application/domain → map to HTTP.
  Domain rules (state transitions, money, booking) live in one place; do not paste them
  into every route.
- Validate at the boundary; return the **standard error envelope** on failure.
- Do not leak internal/DB fields in JSON unless that is the recorded public contract.
- Match method semantics (no mutating GET; POST retries need idempotency when money /
  bookings / external side effects are involved).

## Before claiming done
- Self-check against the `api-design` table: every new/changed row has authz + errors.
- Quote test or manual evidence for happy path **and** at least one authz/validation
  failure (evidence gate).
