# Doc Audit Process — SIXMEN ERP

> **Mục đích (TASK-GD0-008):** chặn doc drift (reference tới file đã xóa/đổi tên) trước khi gây nhầm lẫn cho agent/người. Trigger có hệ thống thay vì "tình cờ đọc".
>
> **Trạng thái:** Draft — **chờ Vũ duyệt ownership map + cadence** (HO gate).

## 1. Quan hệ với cơ chế đã có (KHÔNG duplicate)

| Đã có | Ở đâu | Vai trò |
|-------|-------|---------|
| **Structural Change Protocol** (khi nào audit) | `AGENTS.md §6` | Trigger: mỗi phase-gate + mỗi structural merge |
| **`validate-doc-refs.sh`** (công cụ quét dead-link) | `.cursor/bootstrap/validate-doc-refs.sh` | Chạy tự động phát hiện ref hỏng |
| File này | đây | **Bổ sung:** ownership map + per-doc checklist + cadence tổng hợp |

→ Process = Trigger (§6) + Tool (`validate-doc-refs.sh`) + **Owner + Checklist (file này)**.

## 2. Ownership map *(PROPOSED — Vũ confirm)*

Mỗi doc chính có **1 owner** chịu trách nhiệm verify khi có trigger.

| Doc | Owner đề xuất | Ghi chú |
|-----|:---:|---------|
| `AGENTS.md` · `CLAUDE.md` | **Vũ** | Hub điều phối + LUẬT CỨNG |
| `.cursor/rules/*.mdc` · `.cursor/skills/*/SKILL.md` | **Vũ** | Guardrail runtime |
| `docs/ai-agent/reference/*` (shared-memory, task-log-milestones, phase-gates, doc-map) | **Vũ** *(orchestrator maintain)* | Agent cập nhật, Vũ review |
| `docs/erp/core/01_Master_Decisions.md` · `04_Architecture.md` | **Vũ** | ADR/kiến trúc |
| `docs/erp/core/02_BRD · 03_SRS · 06_MVP` · `phases/*/BRD,SRS` | **Khanh (PM)** | Nghiệp vụ |
| `docs/erp/phases/*/ERD.md` | **Vũ** | Schema canonical |
| `artifacts/KNOWN-ISSUES.md` · `PROGRESS.md` | **Agent maintain · Vũ review** | Cập nhật mỗi lượt |

## 3. Cadence

| Khi nào | Hành động |
|---------|-----------|
| **Mỗi phase-gate** (GĐ0→1...) | Chạy `validate-doc-refs.sh` + checklist §4 cho doc của phase đó (AGENTS.md §6.A) |
| **Mỗi structural merge** (rename/xóa script, đổi layout) | Checklist §6.B trong AGENTS.md |
| **Khi đóng task đụng doc** | Owner verify ref doc mình sở hữu còn valid |
| **Onboard agent mới** | Đọc doc-map + chạy `validate-doc-refs.sh` 1 lần |

## 4. Per-doc audit checklist *(verify nhanh, không cần tool)*

Với mỗi doc khi trigger:
- [ ] Mọi đường dẫn file/`@ref` trong doc còn tồn tại? *(`validate-doc-refs.sh` tự bắt dead-link)*
- [ ] Tên file/script nhắc tới còn đúng? *(vd: `.ps1` → `.sh` sau GD0-012)*
- [ ] Số phiên bản / Kit Version khớp `rules-changelog.md`?
- [ ] Pointer sang doc khác đúng path (không trỏ file đã move)?
- [ ] Nội dung không mâu thuẫn ERD/Master Decisions canonical?

## 5. Last-verified header *(áp sau khi Vũ confirm owner)*

Mỗi doc chính thêm 1 dòng header: `> Owner: <tên> · Last-verified: YYYY-MM-DD` — cập nhật khi owner audit. *(Áp dụng sau khi mục §2 được duyệt — tránh gán owner khi chưa chốt.)*

## OUT (theo brief GD0-008)
- Không build tool scan tự động mới (đã có `validate-doc-refs.sh`).
- Không doc-health dashboard. Không restructure thư mục docs.
