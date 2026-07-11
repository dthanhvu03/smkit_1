# Skills catalog

> Runtime path: `.cursor/skills/sixmen-{role}/SKILL.md` — gọi bằng `@sixmen-{role}` hoặc **slash command** `/role` (xem bên dưới).

## Slash commands (nhanh hơn @mention)

Gõ `/` trong Cursor Chat → chọn command trong `.cursor/commands/`:

| Command | Tương đương |
|---------|-------------|
| `/help` | Bảng command + script |
| `/status` | Xem task 🔄 + gate hiện tại |
| `/orchestrator` | `@sixmen-orchestrator` — task mới / resume |
| `/brief` | `@sixmen-it-manager` |
| `/qa-gate` | `@sixmen-qa` — post-feature gate |
| `/pre-merge` | Sync main + kiểm tra conflict trước PR |
| `/architect` · `/database` · `/backend` · `/frontend` · `/devops` · `/ba` | Skill cùng tên |

Command = prompt ngắn; agent vẫn **Read** file `SKILL.md` đầy đủ trước khi làm.

## Cursor hooks (chặn lệnh — parity Claude Code)

File `.cursor/hooks.json` — Cursor **không** đọc `.claude/settings.json`.

| Hook | Script | Việc làm |
|------|--------|----------|
| `beforeShellExecution` | `guard-shell-cursor.sh` | Chặn migrate:fresh, rm -rf, push -f… |
| `beforeReadFile` | `guard-read-cursor.sh` | Chặn đọc `.env`, `.pem`, keys |
| `sessionStart` | `claude-session-digest.sh` | Inject context session |

Rules dùng chung: `guard-shell-core.sh` (Claude PreToolUse + Cursor).

**Sau khi sửa hooks:** Reload Cursor (hoặc restart) → tab **Hooks** kiểm tra load OK.

## Git — tránh conflict PR (ERR-030)

| Script | Khi nào |
|--------|---------|
| `bash .cursor/bootstrap/sync-main-into-branch.sh` | Trước push/PR — merge `main` **vào feature branch** |
| `bash .cursor/bootstrap/pre-merge-check.sh -t TASK-ID` | Gate: behind=0, dry-run merge, pint, pest |

PR merged → **branch mới** từ `main` cho task tiếp theo. Chi tiết: `@sixmen-orchestrator` SKILL § Branch lifecycle.

| Skill | Khi gọi | Output chính |
|-------|---------|--------------|
| `sixmen-orchestrator` | Task ERP mới, workflow đầy đủ | Routing, gates, artifacts |
| `sixmen-it-manager` | Task brief, scope IN/OUT | `task-brief.md` |
| `sixmen-architect` | Kiến trúc, DB/API impact | `architecture-impact.md` |
| `sixmen-database` | ERD, migration | `migration-note.md` |
| `sixmen-backend` | Laravel implement | Code + tests |
| `sixmen-frontend` | Filament / Livewire | UI + **QA handoff matrix** (403/422 Filament) |
| `sixmen-qa` | Test, release gate | `test-plan.md` + **Filament 4 Pest** (`set('data.*')`, không `fillForm`) |
| `sixmen-devops` | Deploy, backup | `release-checklist.md` |
| `sixmen-ba` | AC, nghiệp vụ | `acceptance-criteria.md` |

Mỗi skill có § **Memory / Context Contract** — chỉ domain memory; shared → [reference/shared-memory.md](../reference/shared-memory.md).

**Background (business persona):** template [skill-background-template.md](../../.cursor/templates/sixmen/skill-background-template.md) · áp dụng cả 9 skill (v2.3).

Orchestrator reference (đã chuyển sang `docs/ai-agent/reference/`):

- [shared-memory.md](../reference/shared-memory.md)
- [doc-map.md](../reference/doc-map.md)
- [phase-gates.md](../reference/phase-gates.md)
