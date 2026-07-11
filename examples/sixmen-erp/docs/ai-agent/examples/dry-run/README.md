# README — Dry-run examples

> Thư mục mẫu cho orchestrator workflow.

| Folder | Mô tả |
|--------|-------|
| [`../../artifacts/EXAMPLE-TASK/`](../../artifacts/EXAMPLE-TASK/) | Gold standard docs-only task |
| [`../../artifacts/PILOT-GD0-B1/`](../../artifacts/PILOT-GD0-B1/) | Rules validation pilot — migration-note dry-run |

## Chạy validate

```powershell
.\.cursor\bootstrap\validate-artifacts.ps1 -TaskId EXAMPLE-TASK
.\.cursor\bootstrap\validate-artifacts.ps1 -TaskId PILOT-GD0-B1 -Strict
```
