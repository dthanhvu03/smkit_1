# SIXMEN — Danh sách command nhanh

Gõ `/` trong Cursor Chat để chọn command. Mỗi command sẽ bảo agent **Read skill tương ứng** rồi làm việc.

## Workflow chính

| Command | Khi nào dùng |
|---------|--------------|
| `/status` | Xem task đang chạy, bước hiện tại, blocker |
| `/orchestrator` | Task ERP mới hoặc resume — **AGENTS.md →** điều phối đầy đủ (`.cursor/commands/orchestrator.md`) |
| `/brief` | Tạo/cập nhật task brief + gate-status |
| `/qa-gate` | Sau code xong — Pest, checklist, đóng gate |
| `/pre-merge` | Sync main vào feature + gate conflict trước PR |

## Theo vai trò

| Command | Skill |
|---------|-------|
| `/architect` | Kiến trúc, boundary, schema impact |
| `/database` | ERD, migration note |
| `/backend` | Laravel Service, Policy |
| `/frontend` | Filament / Livewire |
| `/devops` | Deploy, release checklist |
| `/ba` | AC, nghiệp vụ |

## Shell (agent chạy giúp)

| Script | Lệnh |
|--------|------|
| Sync main → feature | `bash .cursor/bootstrap/sync-main-into-branch.sh` |
| Pre-merge | `bash .cursor/bootstrap/pre-merge-check.sh -t TASK-ID` |
| Validate artifact | `bash .cursor/bootstrap/validate-artifacts.sh -t TASK-ID -s` |
| Dev cheat-sheet | `docs/ai-agent/reference/dev-commands.md` |

**Task-ID:** đọc từ `artifacts/PROGRESS.md` (icon 🔄) hoặc anh gõ kèm trong prompt.
