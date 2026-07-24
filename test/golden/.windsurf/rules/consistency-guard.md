---
# GENERATED — DO NOT EDIT. Edit engine/ or kit.config.yaml, then run: kit build
trigger: glob
globs: src/**,app/**,lib/**,components/**,**/*.ts,**/*.tsx,**/*.js,**/*.jsx,**/*.py,**/*.php
---

# Before writing or editing code, self-check

- **Does this already exist?** Search for an existing component/util/service/helper/middleware doing this before creating a new one. Prefer extend-in-place over a sibling copy.
- **Am I following the established pattern?** Same folder layout, naming convention, error/API envelope, and libraries recorded in the Decision Log.
- **Am I adding a second way?** If this introduces a parallel approach (a 2nd state library, a 2nd styling system, a 2nd HTTP client, a 2nd error JSON shape, a 2nd folder convention, a 2nd copy of the same business rule) — STOP. Explain the conflict to the user in plain language and ask before proceeding.
- **Am I scattering or duplicating?** If the same logic already lives elsewhere (or this is the third near-copy), extract/reuse or run the **`refactor`** skill — do not leave islands that will drift. Domain rules belong in one module called from UI/API/jobs, not three paraphrases.
- **After a non-trivial choice**, append it to the Decision Log with a one-line plain-language reason.
