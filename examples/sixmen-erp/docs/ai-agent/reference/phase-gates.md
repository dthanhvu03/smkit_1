# Phase Gates — SIXMEN ERP

> **Path:** `docs/ai-agent/reference/phase-gates.md`

## Memory (phase context)

- **Canonical:** file này + `docs/erp/core/06_MVP_Phase1.md` + [doc-map.md](doc-map.md) — không suy phase từ conversation memory.
- **GĐ hiện tại:** xác nhận từ task brief; OUT mỗi phase là hard boundary (vd GĐ0 không PO/GRN/LSX).
- **Conflict:** defer `sixmen-governance` SoT table; phase gate không override ERD/data-safety.
- **Stop:** code trước gate bắt buộc (schema, business rule, data delete/purge, prod deploy, permission matrix) → dừng, escalate Human Owner.

## GĐ 00 — Chuẩn bị (không code)

- D01–D23 chốt
- Matrix quyền pilot (QLVH ký)
- Chuẩn SKU/màu/size/kho

**Agent:** chủ yếu `@sixmen-ba`, `@sixmen-it-manager`. Không code ERP.

## GĐ 0 — Core (3 tuần)

| Tuần | Gate |
|------|------|
| 1 | Login, Docker, Filament layout |
| 2 | Shield RBAC, chi nhánh, CTY/HKD, audit |
| 3 | POC + video + UC-00 ký |

**OUT:** PO, GRN, LSX, CRM, HRM, Product, Kho đầy đủ.

## GĐ 1 — SX + Kho (MVP)

- **4 luồng lõi:** Product · Purchase · Production · Inventory — `docs/erp/phases/GD1_Kho_SX/04_Process_Flow.md` §1–§6
- **Chi tiết luồng:** `docs/erp/phases/GD1_Kho_SX/04_*_Flow.md` *(không sửa `Luong` thay thế)*
- 8 bucket vật lý + `pending_docs` flag Phase 1 (ADR-006) — canonical: `docs/erp/phases/GD1_Kho_SX/SRS.md` §2.1
- **GRN Sixmen** từ PO confirmed — biên bản NCC/xưởng đính kèm · **§8.2.2:** QC % → `qc_approved` mới chốt D8
- **LSX:** **§9.2.0** mở LSX = B4D `confirmed` chỉ khi NPL 100% BOM · `planned_finish_at` · `workshop_qc_records`
- Không thay **Nhanh** master đơn/listing; **BS** chỉ in đơn
- RACI stakeholder: `docs/erp/operations/SIXMEN_ERP_Lo_trinh_Van_hanh.md` §2.1b
- Tham chiếu `docs/erp/core/06_MVP_Phase1.md` · `docs/erp/core/04_Architecture.md` §4.6 · `docs/erp/phases/GD1_Kho_SX/Migration_Note_20260613_QC_LeadTime.md` *(chờ Human Owner)*

**Gate 1→2 (staging):** 1 GRN E2E *(qc_pending → qc_approved → confirm)* + 1 LSX *(waiting_npl → confirmed)* + TC-PUR-01 / TC-PROD-03

## GĐ 2+

- Sync sàn, dual-run SOP
- CRM/HRM Lite theo roadmap

## Rule chung mọi phase

- Không scope creep — check task brief IN/OUT
- Permission mọi action
- Human Owner ký trước merge behavior/schema mới
- **No code** trước gate bắt buộc: schema change · business rule change · data deletion/purge · production deploy · permission matrix change
- Schema: canonical `ERD.md` (GĐ0/GĐ1) — không lấy `docs/erp/core/03_SRS.md` §3 DDL cũ override ERD
- Data safety: `sixmen-data-safety.mdc` — no manual DELETE/TRUNCATE/DROP prod

## Rules validation pilot

Chạy **một lần** trước khi dùng agent cho skeleton Laravel thật.

**Task đề xuất:** draft `migration-note` GĐ0 Batch 1 — `branches` · `legal_entities` · `users` extension · `warehouses` · `settings`

**Ràng buộc:**

- Không tạo migration files.
- Không đổi ERD/BRD/SRS.
- Read `docs/ai-agent/reference/shared-memory.md`.
- Read `docs/erp/phases/GD0_Nen_tang/ERD.md` (canonical).
- Không dùng `docs/erp/core/03_SRS.md` §3 DDL nếu lệch ERD.
- Báo files read, assumptions, open questions, Human Owner gates.
- Lưu draft: `artifacts/{Task-ID}/04-migration-note.md` + `00-gate-status.md`. *(Pilot reference: `PILOT-GD0-B1` — validation run 2026-06-17, không cần tạo lại)*.

**Pass criteria:**

- Agent cite `shared-memory.md` và ERD canonical.
- ERD là schema SoT — không dựa conversation memory cho SKU/ERD facts.
- Không đề xuất code trước migration-note / gate.
- Reporting contract đầy đủ (files read / assumptions / verification).

### Kết quả pilot *(2026-06-17)*

| Field | Value |
|-------|-------|
| Status | **PASS** |
| Artifacts | `artifacts/PILOT-GD0-B1/` — `00-gate-status.md`, `01-task-brief.md`, `04-migration-note.md` |
| Agent | Cursor Agent — kit improvement session |
| Ghi chú | Batch 1 draft: branches · legal_entities · users · warehouses · settings. 3 open questions → Human Owner (Vũ/Khanh/QL kho). |

**Next:** Human Owner approve draft migration-note trước khi Backend viết migration PHP trên repo Laravel.
