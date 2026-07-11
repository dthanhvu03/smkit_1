# Example: SIXMEN ERP kit (original)

This folder holds the **original SIXMEN ERP agent kit** — the domain-specific kit this
universal kit was refactored out of. It is kept as a **real-world example** of a `strict`,
regulated-domain configuration (Laravel ERP: inventory, money, COGS, human-owner approval
gates, Vietnamese UX).

It is **not** part of the universal kit runtime. Nothing in `engine/`, `profiles/`,
`.kit/`, or `tools/` depends on it.

## Contents
- `AGENTS.md`, `CLAUDE.md` — the ERP hub + hard rules
- `docs/ai-agent/` — ERP agent department docs
- `.githooks/` — Laravel pre-commit/pre-push (Pint, arch-lint, PHPStan)
- `.cursor/`, `.claude/` — *pending move* (see below)

## Finishing the move

`.cursor/` and `.claude/` are still at the repo root because the editor held a file lock
during the refactor. To relocate them cleanly:

1. Close Cursor / the IDE (so the lock is released).
2. From the repo root run:
   - macOS/Linux: `bash examples/sixmen-erp/finish-move.sh`
   - Windows PowerShell: `pwsh examples/sixmen-erp/finish-move.ps1`

Later, this whole example can become a proper `profiles/laravel-erp/` if you ever want the
universal kit to scaffold ERP-style projects.
