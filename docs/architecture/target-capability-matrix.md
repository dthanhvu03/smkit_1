# Target capability matrix

Human-readable view of `engine/targets/*/capabilities.json` (the machine-readable
source). Values: `supported` · `partial` · `unsupported` · `unknown` · `kit-owned` ·
`import` · `native`. Distinguishes **vendor-native** features from **kit-provided**
ones and from **unverified** ones.

| Capability | claude | cursor | copilot | windsurf | agentsmd | Notes |
|---|---|---|---|---|---|---|
| globalInstructions | native | native | native | native | native | whole-file base instructions |
| pathScopedRules | supported | supported | supported | supported | unsupported | AGENTS.md is whole-file only |
| skills | supported | partial | unsupported | unsupported | unsupported | Cursor: exposed as commands (no model-invoked skills) |
| commands | supported | supported | unsupported | unsupported | unsupported | slash-commands |
| hooks | supported | unsupported | unsupported | unsupported | unsupported | Claude `settings.json` PreToolUse/SessionStart |
| hardBlock (command guard) | partial | unsupported | unsupported | unsupported | unsupported | kit hook, Claude-only wiring; **not a sandbox** |
| agentsMd | import | unknown | unknown | unknown | native | Claude import behavior **CHƯA XÁC MINH** |
| runtimeRouter | unsupported | unsupported | unsupported | unsupported | unsupported | kit has NO runtime router |
| progressiveDisclosure | pathScoped | globScoped | pathScoped | globScoped | none | static/IDE-native, not runtime |
| transactionalGeneration | kit-owned | kit-owned | kit-owned | kit-owned | kit-owned | P0.4 |
| driftDetection | kit-owned | kit-owned | kit-owned | kit-owned | kit-owned | doctor |
| ownershipManifest | kit-owned | kit-owned | kit-owned | kit-owned | kit-owned | P0.3 |

## Reading rules

- **native / supported** = vendor feature the adapter targets.
- **kit-owned** = provided by this kit's engine, not the vendor.
- **import** = the target can reference another artifact (e.g. `AGENTS.md`) rather than
  duplicate it — subject to verification.
- **partial** = works for the common case with documented gaps (e.g. command guard).
- **unknown / CHƯA XÁC MINH** = not confirmed against official docs; must not be relied
  on. `doctor` should warn if config requires a capability a target marks
  `unsupported`.

Provenance/verification lives per-target in `verification` inside each
`capabilities.json`.
