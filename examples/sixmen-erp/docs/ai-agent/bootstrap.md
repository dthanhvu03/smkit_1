# Bootstrap AI Kit → Repo Code Laravel

> Script: [`.cursor/bootstrap/sync-to-code-repo.ps1`](../../.cursor/bootstrap/sync-to-code-repo.ps1)

Copy phòng ban AI Agent từ repo tài liệu sang repo Laravel riêng.

## Bước 1 — Chuẩn bị repo code

```bash
cd C:\path\to\sixmen-erp
git status
```

## Bước 2 — Chạy sync (Windows)

Từ root repo tài liệu:

```powershell
.\.cursor\bootstrap\sync-to-code-repo.ps1 -TargetPath "C:\path\to\sixmen-erp"
```

### Copy mặc định

| Nguồn | Ghi chú |
|-------|---------|
| `.cursor/rules/sixmen-*.mdc` | Governance + role rules |
| `.cursor/rules/hethongtuduy.mdc` | Framework tư duy |
| `.cursor/skills/sixmen-*` | 9 skills |
| `.cursor/templates/sixmen/` | Templates |
| `AGENTS.md` | Hub runtime |
| `CLAUDE.md` | Claude Code → `AGENTS.md` |
| `docs/ai-agent/reference/` | Shared memory, doc-map, phase-gates |

### Không copy mặc định

| File | Lý do |
|------|-------|
| `codacy.mdc` | Dùng `-Force` nếu cần |
| `sixmen-flowchart-business.mdc` | Chủ yếu repo docs |

## Bước 3 — Link tài liệu ERP

**Submodule** hoặc **symlink** toàn repo docs vào `docs/sixmen` trên repo code — agent đọc BRD/ERD khi implement.

## Bước 4 — Verify

1. `@sixmen-orchestrator Implement login GĐ0`
2. Rules always-on: governance, data-safety, architecture-envelope, hethongtuduy
3. Mở `app/**/*.php` → trigger backend/qa rules

Chi tiết gốc: [`.cursor/bootstrap/README.md`](../../.cursor/bootstrap/README.md)
