<!-- GENERATED — DO NOT EDIT. Edit engine/ or kit.config.yaml, then run: kit build -->

# API Design skill

The bridge from "we need an endpoint" to a **contract** callers and code must satisfy.
Run it after the problem (and domain model, when there is a lifecycle) is clear, and
**before** the implementer opens handlers. Most API debt is an undocumented error shape,
missing authz, a fat controller, or a breaking change nobody named — design those out here.

Work from **[references/api-guide.md](references/api-guide.md)** — resource naming, HTTP
semantics, errors, versioning, layering, and anti-patterns. Reuse the project's existing
envelope, middleware, and folder layout from the Decision Log; invent a second style only
after the architect records it.

## Workflow
1. **Reuse first.** Search for an existing route group, handler pattern, error helper,
   auth middleware, and client SDK doing this job. Extend them — a parallel HTTP client,
   error shape, or "controller style" is a consistency bug.
2. **Resources & operations.** Name resources in the project's ubiquitous language
   (`Booking`, not `tbl_bk`). Map each operation to a method + path with **HTTP semantics**
   (safe/idempotent where the verb implies it). Prefer nouns for collections/items; avoid
   RPC-in-URL (`/doConfirm`) unless the codebase already uses that style.
3. **Contract per endpoint.** For each operation declare: request (path/query/body fields +
   validation), response success shape + **status codes**, **error envelope** (same shape
   project-wide), authn required?, **authz rule** (who may act on *this* object — no IDOR),
   idempotency for writes that can retry, pagination/filter/sort for lists.
4. **Layer ownership.** Keep handlers thin (parse → authorize → call application/domain →
   map errors). Business rules live in domain/service — **not** copy-pasted across routes.
   Persistence stays behind a repository/query boundary the project already uses. Do not
   leak DB column names or ORM entities in the public JSON unless that *is* the recorded
   contract.
5. **Compatibility.** Say whether this is additive, a soft deprecation, or a **breaking**
   change (status/field/meaning). Public/external APIs are one-way doors — note versioning
   or an adapter if callers exist. Update OpenAPI / route types if the project has them.
6. **Confirm & record.** Present the contract in plain language; record new conventions
   (error codes, pagination keys) in the task / Decision Log so the next endpoint reuses them.

## Output format (required)
```md
## Purpose (one line, founder's / caller's words)
## Reuse (existing routes · middleware · error helpers · clients)
## Endpoints
| Method | Path | Authz | Success | Errors | Idempotent? | Notes |
|---|---|---|---|---|---|---|
## Request / response shapes (fields + validation)
## Error envelope (project standard; new codes flagged)
## Layering (handler → service/domain → persistence)
## Compatibility (additive · deprecate · breaking + migration)
## Tests to prove the contract (at least: happy · 401/403 · validation · key domain rule)
```

**Quality bar:** a mutating endpoint with **no authz rule**, or a contract with **no error
envelope** (or "TBD"), **fails this skill — redo it**. Pure internal refactors with no new
surface may skip with one line: "no API surface change." Scale: `vibe` = table + error
envelope + authz; `strict` = full shapes, compatibility, and test plan.
