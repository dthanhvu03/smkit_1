# Phòng ban AI Agent — SIXMEN ERP

> Human Owner duyệt cuối. Agent điều phối theo vai trò — không tự ý đổi behavior/schema/business rule.  
> **Hub mỏng** (~145 dòng) — chi tiết: [`docs/ai-agent/README.md`](docs/ai-agent/README.md) · [`02-governance-and-memory.md`](docs/ai-agent/02-governance-and-memory.md) · [`01-overview.md`](docs/ai-agent/01-overview.md)

## Đa nền tảng (Cursor · Claude · Codex)

| Nền tảng | Hub | Guards | Skills | Bắt đầu |
|----------|-----|--------|--------|---------|
| **Cursor** | Auto `AGENTS.md` | `.cursor/rules/*.mdc` alwaysApply | `/sixmen-*` hoặc `@` | `/orchestrator` |
| **Claude Code** | `CLAUDE.md` → `@AGENTS.md` + `@.claude/rules/` | import parity | Read `.cursor/skills/` | `/orchestrator` |
| **Codex / Chat** | Read thủ công | Read `.mdc` thủ công | Read SKILL | prompt § dưới |

Map đầy đủ: [`docs/ai-agent/reference/platform-agent-parity.md`](docs/ai-agent/reference/platform-agent-parity.md)

### Cấu trúc kit

```
AGENTS.md (hub) · CLAUDE.md · artifacts/PROGRESS.md
.cursor/rules · commands · skills · templates
.claude/rules · commands  ← mirror → .cursor/
docs/ai-agent/            ← đọc cho người + deep dive
```

### Prompt khởi động (không phải Cursor)

```
Đọc AGENTS.md · rules: hethongtuduy, governance, data-safety, architecture-envelope
shared-memory.md (khi trigger schema/workflow/data)
Read .cursor/skills/sixmen-{role}/SKILL.md
```

### Orientation (session mới / resume)

```
0. AGENTS.md (hub)
1. /orchestrator → .cursor/commands/orchestrator.md + sixmen-orchestrator SKILL
2. artifacts/PROGRESS.md → task 🔄
3. artifacts/{Task-ID}/00-gate-status.md ← CURRENT
4. shared-memory.md (khi trigger)
```

Human: [`orchestrator-how-it-works.md`](docs/ai-agent/reference/orchestrator-how-it-works.md)

### Claude Code

[`CLAUDE.md`](./CLAUDE.md) — LUẬT CỨNG + `@.claude/rules/sixmen-always-on-parity.md` + `@AGENTS.md`. Memory local → promote vào SKILL (xem `02-governance-and-memory.md`).

Monorepo: Laravel (`app/`, `modules/`) + ERP docs (`docs/erp/`) + AI kit (`.cursor/`).

---

## Skills — routing nhanh

| Skill | Khi gọi |
|-------|---------|
| `sixmen-orchestrator` | Task ERP mới / resume / multi-role |
| `sixmen-it-manager` | Brief, DoD, scope |
| `sixmen-architect` | Boundary, DB/API impact |
| `sixmen-database` | ERD, migration note |
| `sixmen-backend` | Service, Policy, Laravel |
| `sixmen-frontend` | Filament / Livewire |
| `sixmen-qa` | Pest, post-feature gate, 07 checklist |
| `sixmen-devops` | Deploy, backup |
| `sixmen-ba` | AC, walkthrough |

8 vai trò + org chart: [`01-overview.md`](docs/ai-agent/01-overview.md) · catalog: [`skills/README.md`](docs/ai-agent/skills/README.md)

**Always-on rules:** `hethongtuduy` · `sixmen-governance` · `sixmen-data-safety` · `sixmen-architecture-envelope` · `sixmen-skill-routing` · `sixmen-agent-closeout`

---

## Source of truth index *(pointer — không copy ERD vào chat)*

| # | Topic | Path |
|---|-------|------|
| 1 | Quyết định / ADR | `docs/erp/core/01_Master_Decisions.md` |
| 2 | MVP GĐ1 | `docs/erp/core/06_MVP_Phase1.md` |
| 3 | Kiến trúc §3.13 | `docs/erp/core/04_Architecture.md` |
| 4 | Schema GĐ0 | `docs/erp/phases/GD0_Nen_tang/ERD.md` |
| 5 | Schema GĐ1 | `docs/erp/phases/GD1_Kho_SX/ERD.md` |
| 6 | Workflow GĐ1 | `docs/erp/phases/GD1_Kho_SX/04_Process_Flow.md` → `04_*_Flow` → `06_Workflow_Status` → `07_Sequence_Diagram` |
| 7 | UI | `docs/erp/core/05_Screen_Specs.md` |
| 8 | Permission GĐ1 | `docs/erp/phases/GD1_Kho_SX/09_Permission_Matrix.md` |
| 9 | Shared memory | `docs/ai-agent/reference/shared-memory.md` |
| 10 | Phase gates | `docs/ai-agent/reference/phase-gates.md` |
| 11 | Doc map | `docs/ai-agent/reference/doc-map.md` |
| 12 | **Deprecated** | `03_SRS.md` §3 DDL không override ERD · `variant.code` → `product_variants.sku` |

Conflict priority · artifact chain · KNOWN-ISSUES · implement envelope: [`02-governance-and-memory.md`](docs/ai-agent/02-governance-and-memory.md)

---

## Shared memory — khi nào Read

`shared-memory.md` **không** tự load. Read khi đụng: schema/ERD/migration · workflow/phase · critical service · data safety/purge · permission/CTY-HKD/kho · reporting replica · skill/rule conflict.

Docs-only nhỏ → chỉ file đích + skill/rule. High-risk → báo file đã đọc.

---

## Kỷ luật vận hành (tóm)

- Một task = `artifacts/{Task-ID}/` + `00-gate-status.md` + `01-task-brief.md`
- Code: brief → arch-impact → migration-note (+HO) → implement → QA → review
- **`/orchestrator`** resume · **`/orchestrator Mở task …`** task mới
- Closeout cùng lượt: gate-status · PROGRESS · KNOWN-ISSUES · validate-artifacts · Pest/PHPStan

Chi tiết: `02-governance-and-memory.md` · `sixmen-agent-closeout.mdc` · orchestrator SKILL § Auto-update

**Validate:** `.cursor/bootstrap/validate-artifacts.sh` · `validate-task-log.sh` · `validate-doc-refs.ps1`

---

## Quy tắc chung

Envelope Policy → Service → transaction → audit. Critical guards: `InventoryService` · `MaterialInventoryService` · `DocumentNumberService` · `CogsService`. Không bypass · không DELETE prod · không migrate không HO.

---

## Tài liệu theo phase

| Phase | Cổng vào |
|-------|----------|
| Index GĐ | `docs/erp/index/SIXMEN_ERP_Giai_doan_0_5.md` |
| Mỗi GĐ | 7 file: BRD · SRS · ERD · 04–07 trong `docs/erp/phases/` |

---

## Kit Version

**v1.2.2** — 2026-06-29 *(Khung 4 lăng kính + checklist What-if vận hành — HO yêu cầu)*

| Component | Version |
|-----------|---------|
| AGENTS hub | **v2.0 slim** — ~145 dòng; extended → `docs/ai-agent/02-governance-and-memory.md` |
| Claude parity | v1.0 — `.claude/rules/` + `platform-agent-parity.md` |
| Orchestrator `/` | v1.4 |
| Skills (9) | v1.18 — orchestrator § Khung 4 lăng kính + checklist What-if vận hành (trễ/thiếu/lỗi/từng phần/hủy/hoàn/gấp/trùng/hết hạn/đa chiều/tranh chấp) |
| Templates | v1.9 — task-brief § 2b Tình huống vận hành thực tế (what-if, bắt buộc task nghiệp vụ/data) |
| Rules always-on | v1.2 — guard-shell Docker volume prune/rm/system-prune-volumes |
| Hệ thống tư duy | v4.3 |

Changelog: [`docs/ai-agent/reference/rules-changelog.md`](docs/ai-agent/reference/rules-changelog.md)
