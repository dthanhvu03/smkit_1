# ADR-001 — Canonical source of truth & data flow

- **Status:** Accepted (2026-07-11)
- **Context:** Hardening phase P0. The kit generates config for 5 agent targets; we
  must guarantee a single source of truth and a one-way data flow so generated
  artifacts can never silently become a second source.

## Decision

1. **`kit.config.yaml` is the structured source of truth.** It is the only
   machine-readable input that describes a project (name, mode, stack, agents,
   outDir, approvers, invariants, guardrails).
2. **`engine/` and `profiles/` are the content source.** Rules, roles, commands,
   skills, i18n strings (engine, stack-agnostic) and per-stack defaults/rules/
   invariants (profiles). They are edited by hand; they are inputs, never outputs.
3. **Data flow is strictly one-way:** `kit.config.yaml + engine/ + profiles/`
   → `engine/emitter.mjs` (pure) → `outDir/` artifacts. Generated files are **never**
   read back into or written back to the source. There is no round-trip.
4. **`AGENTS.md` is a generated interoperability artifact**, not a source of truth.
   It is emitted like any other target output. Nothing parses `AGENTS.md` to
   reconstruct config. Editing `AGENTS.md` by hand has no effect on generation and
   will be reported as a drift/ownership conflict, not adopted.
5. **There are never two sources of truth.** `CLAUDE.md`, Copilot instructions,
   Cursor `.mdc`, Windsurf rules and `AGENTS.md` are all downstream native target
   artifacts.

## Precedence (resolution order)

When the same setting is provided at multiple layers, later layers win **only where
the schema explicitly allows an override**:

1. **engine defaults** (`engine/`, i18n `en` fallback)
2. **profile** (`profiles/<stack>/profile.yaml` + its rules/invariants)
3. **project config** (`kit.config.yaml`)
4. **local project override** — *not currently supported*; if added it sits above
   project config and must be an explicit, documented mechanism.

- Invariants merge across layers by **ID** (see [ADR-002] and the invariant model).
- A **conflict that is not an explicit, schema-sanctioned override must FAIL**, never
  silently pick a winner. Example: two invariants with the same ID where the project
  layer does not declare an override → validation error, no output.

## Consequences

- The generator is a pure compiler: same inputs → same bytes (golden-tested).
- Adding a target = adding an emitter/adapter; it cannot introduce a new source.
- Because `AGENTS.md` is generated, a future "import `@AGENTS.md`" strategy for a
  target (e.g. Claude) is a *rendering choice of that adapter*, not a source change.

[ADR-002]: ADR-002-safe-generation-and-ownership.md
