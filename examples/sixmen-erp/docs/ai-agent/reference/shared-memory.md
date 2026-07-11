# Shared Project Memory — SIXMEN ERP

> **Path:** `docs/ai-agent/reference/shared-memory.md`  
> **Authority:** `.cursor/rules/sixmen-governance.mdc` § Memory conflict priority  
> **Loading:** not auto-loaded — see `docs/ai-agent/02-governance-and-memory.md`  
> **Index:** `AGENTS.md` · [doc-map.md](doc-map.md)  
> Skills/rules **không** copy block này dài — chỉ pointer + domain memory.

---

## 1. Source of truth (canonical)

| Topic | Canonical | Tham khảo (không override) |
|-------|-----------|----------------------------|
| Business / architecture decisions | `docs/erp/core/01_Master_Decisions.md` | `docs/erp/core/02_BRD.md` |
| MVP scope | `docs/erp/core/06_MVP_Phase1.md` | — |
| GĐ0 schema | `docs/erp/phases/GD0_Nen_tang/ERD.md` | `docs/erp/core/03_SRS.md` §3 DDL |
| GĐ0 functional reqs | `docs/erp/phases/GD0_Nen_tang/SRS.md` | — |
| GĐ1 schema | `docs/erp/phases/GD1_Kho_SX/ERD.md` | `docs/erp/core/03_SRS.md` §3 DDL |
| GĐ1 workflow | `docs/erp/phases/GD1_Kho_SX/04_Process_Flow.md` → `docs/erp/phases/GD1_Kho_SX/04_*_Flow.md` → `docs/erp/phases/GD1_Kho_SX/06_Workflow_Status.md` → `docs/erp/phases/GD1_Kho_SX/07_Sequence_Diagram.md` | `docs/erp/flows/SIXMEN_ERP_Luong_hoat_dong_chinh.md` (tổng hợp, không sửa chính) |
| UI | `docs/erp/core/05_Screen_Specs.md` · `docs/erp/ui/walkthrough/*` | — |
| Kiến trúc | `docs/erp/core/04_Architecture.md` | — |
| Permission GĐ1 | `docs/erp/phases/GD1_Kho_SX/09_Permission_Matrix.md` | — |
| Phase / gate | [phase-gates.md](phase-gates.md) · `docs/erp/core/06_MVP_Phase1.md` | — |
| Doc index | [doc-map.md](doc-map.md) | — |

**Non-schema doc priority:** `docs/erp/core/01_Master_Decisions.md` > `docs/erp/core/02_BRD.md` > `docs/erp/core/03_SRS.md` > `docs/erp/core/06_MVP_Phase1.md`

---

## 2. Deprecated (không dùng làm chuẩn)

| Item | Thay bằng / xử lý |
|------|-------------------|
| `docs/erp/core/03_SRS.md` §3 DDL | ERD GĐ0/GĐ1 — SRS chỉ API/overview |
| `variant.code` | `product_variants.sku` |
| Conversation memory | Đọc lại SoT — không override |
| Hard delete movement/audit/core ERP | cancel / reversal / adjustment / exception |
| UI ẩn nút = authorized | Backend Policy → 403 |
| Mọi CRUD service = critical guard | Chỉ 4 service + ADR mới |
| `spatie/laravel-data` cho DTO | Plain PHP class DTO (package **không** cài) |
| `catch (\Throwable)` nuốt lỗi nghiệp vụ | Catch đúng Custom Exception (exception-first) |
| Thư viện Toast ngoài (SweetAlert/Toastr/notyf) | Filament v4 built-in `Notification::make()` |

---

## 3. Business boundaries

| Boundary | Rule ngắn |
|----------|-------------|
| HKD | Bán / vận hành |
| CTY | Sản xuất / mua / pháp nhân vận hành |
| Hàng CTY | Không tự bán được — cần điều kiện HKD nhận/chuyển |
| LSX | Kế hoạch / điều phối SX nội bộ |
| PO | Đơn pháp lý gửi NCC / xưởng — **không** = LSX |
| Nhanh P1 | Hub sàn TMĐT — không = «chỉ bán Nhanh» |

Chi tiết flow: `docs/erp/phases/GD1_Kho_SX/04_*_Flow.md` · `sixmen-flowchart-business.mdc`

---

## 4. Service boundaries (critical single-entry)

| Domain | Service | Cấm |
|--------|---------|-----|
| Tồn TP | `InventoryService` | Direct update `inventory` |
| Tồn NPL | `MaterialInventoryService` | Direct update `material_inventory_balances` |
| Mã chứng từ | `DocumentNumberService` | Manual PO/GRN/ADJ/TRF/LSX/HDNT/BBGN codes |
| COGS | `CogsService` (+ ADR) | Tính rải rác UI/controller |

**Envelope mọi mutation:** FormRequest → Policy → Service → transaction → audit.  
Chi tiết: `sixmen-architecture-envelope.mdc` · `sixmen-laravel-backend.mdc`

---

## 4.1 Service I/O contract & GĐ0 reality (2026-06-23)

- **Write Service success → trả về Eloquent Model** (đã mutate, kèm field tính lại như `available`) — **không** bọc DTO. Read/report service → `Collection`.
- **Input = plain PHP class DTO / command** (constructor promotion + `fromArray()`, `modules/{Module}/Data/`) — **KHÔNG** dùng `spatie/laravel-data` (không cài).
- **Lỗi nghiệp vụ = throw Custom Exception** (exception-first): vd `InsufficientInventoryException` → rollback tx; **không** trả `{success,error}` / null / false. Frontend catch đúng exception → `Notification::make()->danger()`; **cấm** `catch (\Throwable)` nuốt lỗi hệ thống. Map API: 422 (business/validation) · 409 (oversell/idempotency).
- **GĐ0 reality:** phần lớn Domain Service & Custom Exception GĐ1 (`InventoryService`, `MaterialInventoryService`, `CogsService`, `DocumentNumberService`, `InsufficientInventoryException`…) **CHƯA tồn tại trong source** — tên trong `04_Architecture.md` là **spec**. Trước khi gọi/catch: **verify class tồn tại thật** (grep/Read `modules/{Module}/Services|Exceptions`); chưa có → **STOP**, không tự chế class/Service rác.

- **Exception name là canonical-gated:** danh mục tên Custom Exception **chỉ** lấy từ `04_Architecture.md` §4.3/§12 (hiện canonical định nghĩa `InsufficientInventoryException`, `ConfigurationException`). Tên khác xuất hiện trong skill (`DocumentNumberConflictException`, `InvalidWorkflowTransitionException`…) là **ví dụ theo spec — chưa canonical**. FE/BE muốn catch/throw tên mới → Architect thêm vào §4.3 **trước**, không tự chế vào source/SoT.
- **Map HTTP (chuẩn RFC 9110 — chốt 2026-06-23, TASK-GD0-045):** **422** = validation tĩnh (dữ liệu tự sai: qty âm, transition sai → `InvalidWorkflowTransitionException`) · **409** = state-conflict/tranh chấp đồng thời thường dưới `lockForUpdate` (oversell/hết tồn `InsufficientInventoryException`, trùng mã `DocumentNumberConflictException`, idempotency). Canonical: `04_Architecture.md` §4.3 bảng "map Custom Exception → HTTP".

Canonical: `docs/erp/core/04_Architecture.md` §3.3·§4.3·§4.4·§12.2.

---

## 5. Data safety

- Không `DELETE` / `TRUNCATE` / `DROP` production.
- Movement/audit **append-only** — không UPDATE/DELETE sửa lỗi nghiệp vụ.
- Soft delete ≠ purge; MVP không build purge jobs.
- Correction: cancel / reversal / adjustment / exception + audit.

Chi tiết: `sixmen-data-safety.mdc` · ADR-010

---

## 6. DB / reporting boundaries

| User / connection | Role |
|-------------------|------|
| `sixmen_app` | App read/write (primary) |
| `sixmen_report` | Read-only `pgsql_reporting` |
| `sixmen_migration` | DDL deploy only |
| `sixmen_maintenance` | Future purge only |
| `postgres` / admin | **Never** for app |

- Mutation / `FOR UPDATE` / critical services → **primary only**.
- `pgsql_reporting` → report/dashboard/export đã duyệt; fresh data → `force_primary`.

Chi tiết: `sixmen-devops.mdc` · ADR-009

---

## 6.1 Observability pointer

- `request_id` / correlation ID: trace request across app log, exception log and activity log.
- Request timing fields: `duration_ms`, `db_query_count`, `db_time_ms`, `memory_peak_mb`.
- Request timing is technical observability; Activity Log is business audit.

Canonical: `docs/erp/core/04_Architecture.md` §11.2 · `docs/erp/phases/GD0_Nen_tang/07_Sequence_Diagram.md` §0.1

---

## 7. Human Owner & universal gates

Agent **không** tự coi đã duyệt. Dừng khi:

- Đổi schema / migration
- Đổi business rule / state machine
- Xóa / purge / ghi đè dữ liệu thật
- Deploy production / migrate prod
- Đổi permission matrix / data retention
- Task ≥2 module (behavior) không được task yêu cầu
- SoT conflict chưa resolve

RACI: `sixmen-governance.mdc` § Human Owner

---

## 8. Output templates (theo loại thay đổi)

| Loại | Template (runtime path) | Lưu artifact |
|------|-------------------------|--------------|
| Gate tracker | `.cursor/templates/sixmen/gate-status.md` | `artifacts/{Task-ID}/00-gate-status.md` |
| Task mới | `.cursor/templates/sixmen/task-brief.md` | `artifacts/{Task-ID}/01-task-brief.md` |
| Kiến trúc | `.cursor/templates/sixmen/architecture-impact.md` | `…/03-architecture-impact.md` |
| Schema | `.cursor/templates/sixmen/migration-note.md` | `…/04-migration-note.md` |
| Đụng data | `.cursor/templates/sixmen/impact-risk-rollback.md` | `…/05-impact-risk-rollback.md` |
| Test | `.cursor/templates/sixmen/test-plan.md` | `…/06-test-plan.md` |
| PR | `.cursor/templates/sixmen/architecture-compliance-checklist.md` | `…/07-architecture-compliance-checklist.md` |
| Release | `.cursor/templates/sixmen/release-checklist.md` | `…/08-release-checklist.md` |
| Nghiệp vụ | `.cursor/templates/sixmen/acceptance-criteria.md` | `…/02-acceptance-criteria.md` |

**Artifact discipline:** mọi task ERP → folder `artifacts/{Task-ID}/` · review blocker → `artifacts/README.md` · governance § Artifact discipline.

Templates: `.cursor/templates/sixmen/` — gate-status, task-brief, architecture-impact, migration-note, test-plan, compliance-checklist, release-checklist.

---

## 9.1 Windows dev environment (lesson learned 2026-06-17)

Khi setup dev trên Windows — kiểm tra trước khi chạy composer/migrate:

| Item | Windows dev | Production Linux |
|------|-------------|-----------------|
| `SESSION_DRIVER` | `file` | `redis` |
| `CACHE_STORE` | `file` | `redis` |
| `QUEUE_CONNECTION` | `database` | `redis` |
| `REDIS_CLIENT` | `predis` | `phpredis` |
| `ext-pcntl` | ignore (Unix only) | có sẵn |
| `ext-posix` | ignore (Unix only) | có sẵn |
| `ext-redis` | cài riêng hoặc dùng predis | có sẵn |

**Package compat rule:** khi nâng version package (vd: `spatie/laravel-permission`), check xem packages phụ thuộc vào nó (vd: `filament-shield`) có support version mới không trước khi commit vào `composer.json`.

**User model scaffold:** mọi Laravel project có RBAC → thêm `HasRoles` trait ngay khi tạo User model, không đợi seeder lỗi.

**Vendor publish:** packages có migration (spatie/permission, spatie/activitylog, horizon) → chạy `vendor:publish` trước `migrate`.

---

## 9.2 Frontend / notification stack (2026-06-23)

- **Filament v4.11.7** (composer.lock) + Livewire HYBRID — dùng API namespace **v4** (`Filament\Schemas\Schema`, `Filament\Actions\*`, `Filament\Tables\*`), không pattern v2/v3.
- **Notification:** chỉ Filament built-in `Filament\Notifications\Notification::make()`. **Cấm** cài/cấu hình thư viện Toast ngoài (SweetAlert/Toastr/notyf/livewire-toaster) — không có trong `composer.json`/`package.json`.
- **Pest Filament Resource:** HTTP 403 (index/create/edit) + Livewire validation dùng `set('data.{field}', …)` — **không** `fillForm()` trên Schema v4 (false pass). Chi tiết: `sixmen-qa/SKILL.md` § *Filament 4 Pest patterns* · ref `WarehouseTypeRegistryTest`.
- Chi tiết: `.cursor/skills/sixmen-frontend/SKILL.md` § Notification standard · § Mutation data contract · § Domain exception UX · § QA handoff · § ⛔ GĐ0.

---

## 9. Universal stop conditions

| Trigger | Hành động |
|---------|-----------|
| Thiếu SoT + ảnh hưởng schema/data/tiền/tồn/pháp lý/SX | Stop, hỏi — không suy diễn |
| Conversation ≠ SoT | Theo SoT + conflict priority |
| Bypass critical service / audit | Stop |
| Schema change không có migration-note path | Stop |
| Prod deploy không backup / approval | Stop |

Phase-specific OUT: [phase-gates.md](phase-gates.md)

## 10. Phase-readiness lessons (pointer — đọc khi chuyển giai đoạn / phase gate)

Bài học chốt từ audit GĐ0→GĐ1 (GD0-056 re-audit + GD0-057 deep-dive): **[phase-readiness-lessons.md](phase-readiness-lessons.md)** — canonical, per-role.

Tóm tắt luật vàng (chi tiết ở file trên):
- **Orchestrator:** trước task code đầu GĐ(n+1) → deep-dive readiness theo *seam* (đánh số, exception→HTTP, lock ordering, module/migration). Breadth audit KHÔNG thay được.
- **Architect:** shared enum/model thuộc module thấp nhất; exception→HTTP seam + lock-ordering abstraction phải có TRƯỚC khi service nhân lên.
- **Backend:** không field "lưu mà không dùng"; consume `actorId` (queue/system path); 1 renderer dùng chung; chuẩn hoá key nhất quán.
- **Database:** counter có reset_policy phải có period-anchor; ràng buộc nghiệp vụ = backstop cứng; ERD cập nhật sau mọi ALTER.
- **QA:** test backstop đã document (race 23505→422); 403 data-provider mọi resource; seeded super_admin posture.
- **BA/IT-Manager:** phase-close = cross-check MỌI FR-CORE-xx → Resource/Service/seed/test; defer phải HO ký + ghi PROGRESS.

**Vận hành multi-agent (right-sized, chống over):** **[orchestration-ops.md](orchestration-ops.md)** — handoff-trace nhẹ · subagent-death resume (đọc working-tree) · **task tiering** (Tier 0 trivial→no artifact · 1 code thường · 2 nhạy cảm full-chain) · gate-reality (1 người nhiều mũ = checkpoint không phải 4 duyệt độc lập) · eval bounded. Mỗi mục có **trigger nâng cấp** — chưa trigger thì KHÔNG thêm.
