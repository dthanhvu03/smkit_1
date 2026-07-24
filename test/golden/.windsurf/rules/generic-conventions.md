---
# GENERATED — DO NOT EDIT. Edit engine/ or kit.config.yaml, then run: kit build
trigger: always_on
---

# Conventions (generic profile)

- One way to do each thing. Pick a single approach for state, styling, data access, routing, and **API error envelopes**; record it in the Decision Log and reuse it everywhere.
- **Naming:** intention-revealing (a reader understands without the body); no cryptic abbreviations. Follow the language's standard casing. Prefer domain glossary terms for business concepts.
- **Layering:** keep transport handlers thin; put business rules in one shared place called from API/UI/jobs — no copy-paste islands.
- Small, readable changes. Prefer clarity over cleverness. Extract on the third near-duplicate.
- Keep files where similar files already are. Don't invent a new top-level folder without recording why.
- No secrets in code. Use env/config.
