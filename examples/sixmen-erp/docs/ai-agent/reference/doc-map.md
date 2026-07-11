# Doc Map — SIXMEN ERP

> **Path:** `docs/ai-agent/reference/doc-map.md`  
> AI agent kit: [../README.md](../README.md)

| Khi cần | Đọc |
|---------|-----|
| Quyết định tech/nghiệp vụ | `docs/erp/core/01_Master_Decisions.md` |
| Business requirements | `docs/erp/core/02_BRD.md` |
| DB schema **canonical** | GĐ0 `docs/erp/phases/GD0_Nen_tang/ERD.md` · GĐ1 `docs/erp/phases/GD1_Kho_SX/ERD.md` |
| DB/API tổng quan *(không override ERD)* | `docs/erp/core/03_SRS.md` — §3 DDL deprecated nếu lệch ERD |
| Kiến trúc backend | `docs/erp/core/04_Architecture.md` |
| Màn hình UI | `docs/erp/core/05_Screen_Specs.md` |
| Scope Phase 1 | `docs/erp/core/06_MVP_Phase1.md` |
| POC / gate trước code | `docs/erp/core/07_POC_Checklist.md` v2.0 — Gate A (Phase 1) · Gate B (Phase 2) |
| Thuật ngữ / viết tắt | `docs/erp/phases/THUAT_NGU_CHUNG.md` + `00_Chu_giai_thuat_ngu.md` mỗi GĐ |
| Mục lục giai đoạn | `docs/erp/index/SIXMEN_ERP_Giai_doan_0_5.md` |
| Dev prerequisites | `docs/erp/prerequisites/Sixmen_Technical_Prerequisites.md` |
| Dual-run | `docs/erp/operations/09_Dual_Run_SOP.md` |
| Module map BA | `docs/erp/flows/SIXMEN_ERP_Ban_do_Module_BA.md` |
| **AI Agent docs** | `docs/ai-agent/README.md` |
| **Orchestrator** | Cursor ↔ Claude sync | `docs/ai-agent/reference/platform-agent-parity.md` |
| **AGENTS hub extended** | Chi tiết đã tách khỏi hub slim | `docs/ai-agent/02-governance-and-memory.md` |
| **Orchestrator** (`/orchestrator`, resume task) | `docs/ai-agent/reference/orchestrator-how-it-works.md` |
| Câu lệnh dev (Docker/migrate/QA) | `docs/ai-agent/reference/dev-commands.md` |

## Giai đoạn — folder chuẩn

| GĐ | Folder | Cổng vào |
|----|--------|----------|
| GĐ 0 | `docs/erp/phases/GD0_Nen_tang/` | `docs/erp/phases/GD0_Nen_tang.md` |
| **GĐ 1** | `docs/erp/phases/GD1_Kho_SX/` | `docs/erp/phases/GD1_Kho_SX.md` · `docs/erp/phases/GD1_Kho_SX/04_Process_Flow.md` |
| GĐ 1.5 | `docs/erp/phases/GD1_5_Quan_ly_cong_viec/` | `docs/erp/phases/GD1_5_Quan_ly_cong_viec.md` |
| GĐ 1.6 | `docs/erp/phases/GD1_6_Insight_CSKH/` | `docs/erp/phases/GD1_6_Insight_CSKH.md` |
| GĐ 2V | `docs/erp/phases/GD2_Van_hanh_CRM_HRM/` | `docs/erp/phases/GD2_Van_hanh_CRM_HRM.md` |
| GĐ 2 KT | `docs/erp/phases/GD2_Ky_thuat_Sync_san/` | `docs/erp/phases/GD2_Ky_thuat_Sync_san.md` |
| GĐ 3 | `docs/erp/phases/GD3_Hoan_Doi_soat_PnL/` | `docs/erp/phases/GD3_Hoan_Doi_soat_PnL.md` |
| GĐ 4 | `docs/erp/phases/GD4_CSKH_POS_NCC/` | `docs/erp/phases/GD4_CSKH_POS_NCC.md` |
| GĐ 5 | `docs/erp/phases/GD5_HRM_Full/` | `docs/erp/phases/GD5_HRM_Full.md` |

Mỗi GĐ có bộ **7 file chuẩn**: BRD · SRS · ERD · `04_Process_Flow` · `05_User_Flow` · `06_Workflow_Status` · `07_Sequence_Diagram`.

## GĐ 1 — luồng *(quan trọng — đọc theo thứ tự)*

> **Thứ tự canonical:** `docs/erp/phases/GD1_Kho_SX/04_Process_Flow.md` → `docs/erp/phases/GD1_Kho_SX/04_*_Flow.md` → `docs/erp/phases/GD1_Kho_SX/06_Workflow_Status.md` → `docs/erp/phases/GD1_Kho_SX/07_Sequence_Diagram.md`

> **Sửa logic / sơ đồ GĐ 1:** `docs/erp/phases/GD1_Kho_SX/04_*_Flow.md` → sync `SRS` · `ERD` · `06` · `08` · map `Luong` §1–§14.  
> **Không** lấy `docs/erp/flows/SIXMEN_ERP_Luong_hoat_dong_chinh.md` làm file sửa chính — đó là bản tổng hợp 24 luồng theo phase.

| Vai trò | File |
|---------|------|
| Index + E2E | `docs/erp/phases/GD1_Kho_SX/04_Process_Flow.md` |
| Chi tiết domain | `docs/erp/phases/GD1_Kho_SX/04_Product_Flow.md` · `04_Purchase_Flow.md` · `04_Production_Flow.md` · `04_Inventory_Flow.md` · `04_Operations_Flow.md` *(cùng folder GĐ1)* |
| Exception / UC | `docs/erp/phases/GD1_Kho_SX/08_Luong_Chi_tiet_Exception_Risk.md` |
| UI / status | `docs/erp/phases/GD1_Kho_SX/05_User_Flow.md` · `docs/erp/phases/GD1_Kho_SX/06_Workflow_Status.md` |
| Dev | `docs/erp/phases/GD1_Kho_SX/SRS.md` §2.1 *(Inventory canonical)* · `docs/erp/phases/GD1_Kho_SX/ERD.md` · `docs/erp/phases/GD1_Kho_SX/07_Sequence_Diagram.md` |
| Schema draft | `docs/erp/phases/GD1_Kho_SX/Migration_Note_20260613_P01_LSX_Trace_Refs.md` · `Migration_Note_20260613_QC_LeadTime.md` |

**Inventory GĐ1 (ADR-006):** `pending_docs` = BOOLEAN flag — **không** physical bucket · **không** trừ vào `available` vật lý.

**Rule (13/06):** Purchase §8.2 QC/SLA · Production §9.2 NPL gate + lead time + workshop QC · `docs/erp/core/04_Architecture.md` §4.6

## Source of truth — schema & naming

| Topic | Canonical |
|-------|-----------|
| GĐ0 schema | `docs/erp/phases/GD0_Nen_tang/ERD.md` |
| GĐ0 FR / UC-00 | `docs/erp/phases/GD0_Nen_tang/SRS.md` · `BRD.md` §6 |
| GĐ1 schema | `docs/erp/phases/GD1_Kho_SX/ERD.md` |
| SKU field | `product_variants.sku` — `variant.code` **deprecated** |
| Deprecated DDL | `docs/erp/core/03_SRS.md` §3 must not override ERD |

## Memory contract (pointer)

- **Shared memory:** [shared-memory.md](shared-memory.md) — **not auto-loaded**
- **Governance:** `.cursor/rules/sixmen-governance.mdc`
- **Phase:** [phase-gates.md](phase-gates.md) — gồm § Rules validation pilot
- **Rules/skills changelog:** [rules-changelog.md](rules-changelog.md)
- **Skills:** `.cursor/skills/sixmen-*/SKILL.md` — domain memory only
