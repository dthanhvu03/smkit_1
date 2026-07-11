# Architecture Compliance Checklist — SIXMEN ERP

| Field | Value |
|-------|-------|
| PR / Task ID | |
| Phase | GĐ 0 / GĐ 1 / … |
| Module chính | |
| Reviewer | Vũ / QA |

> Dùng **mọi PR** có mutation nghiệp vụ. AI Agent tick trước khi xin review; Human tick trước merge.

---

## 1. Envelope (GĐ0 §0.1 / GĐ1 §0.1)

- [ ] `EnsureBranchScope` (và `legal_entity_id` nếu đụng PO/kho/TT)
- [ ] `authorize()` / Policy trên mọi mutation
- [ ] Logic trong **Service** hoặc **Action** — không Controller/Filament/Blade
- [ ] `DB::transaction` cho write nhiều bước
- [ ] Activity Log cho thay đổi quan trọng
- [ ] Event nếu cross-module (không gọi Service module khác trực tiếp nếu tránh được)

## 1.1 Architecture boundary *(khi có `03-architecture-impact.md`)*

- [ ] Module owner / table owner / writer service đã ghi rõ
- [ ] Cross-module chỉ qua public Service / Event / Contract
- [ ] Transaction / locking / idempotency đã có quyết định nếu đụng tiền/tồn/chứng từ
- [ ] Reporting boundary đúng: mutation/lock/transaction trên `pgsql`, report đã duyệt trên `pgsql_reporting`
- [ ] Risk / rollback / test expectation đã được ghi

## 2. Critical domain guards

> Chỉ **critical single-entry** — không tick service CRUD thông thường. Chi tiết: `sixmen-architecture-envelope.mdc`.

- [ ] Tồn TP: `InventoryService` only — không update `inventory` trực tiếp
- [ ] Tồn NPL: `MaterialInventoryService` only — không update `material_inventory_balances` trực tiếp
- [ ] Mã chứng từ: `DocumentNumberService` only — transaction + `FOR UPDATE`
- [ ] COGS: `CogsService` hoặc costing service đã duyệt (nếu đụng)
- [ ] FormRequest / validated DTO — không `$request->all()` mutation
- [ ] Policy/scope — UI ẩn button không thay backend
- [ ] Movement/audit append-only — không UPDATE/DELETE sửa lỗi (`sixmen-data-safety.mdc`)

## 2.1 Validation & xử lý ngoại lệ *(BẮT BUỘC mọi feature — không chỉ API)*

> Mọi tính năng nhập liệu phải kín 3 tầng. Sai ở đây = data bẩn / 500 trần / mất vết.

- [ ] **Form/input đầy đủ**: required đúng field bắt buộc · format (email/phone/MST…) · range (min/max, ngày từ–đến) · điều kiện (vd lý do hủy khi huỷ) · `minItems` cho repeater bắt buộc có dòng
- [ ] **DB constraint = backstop**: CHECK/unique/FK cho ràng buộc cứng (XOR, qty>0, enum) — không chỉ dựa form
- [ ] **Mutation nghiệp vụ map ngoại lệ sạch**: conflict tồn/lock → **409** (`InsufficientInventory/Material`, `LockConflict`); cấu hình/đầu vào sai → **422** (`ConfigurationException`); **KHÔNG** để rơi xuống DB CHECK ra **500 trần**
- [ ] **What-if vận hành** (task-brief §2b) đã có đường xử: trễ/thiếu/lỗi/từng phần/hủy/hoàn/gấp/trùng/hết hạn/đa chiều/tranh chấp — cái nào áp thì có validation/exception tương ứng
- [ ] **Tầng đúng**: CRUD → inline Filament rules + DB constraint (như User/LegalEntity); validation phức tạp → FormRequest (như DocumentNumberConfig); mutation tồn/tiền → Service + custom exception
- [ ] **Sanitize ký tự ẩn/đặc biệt**: model mới `use App\Models\Concerns\SanitizesInput` (tự xóa zero-width/bidi/control khi lưu, giữ tiếng Việt) — nền dùng chung, không tự lọc rời từng field

## 3. UI (Filament / Livewire)

- [ ] `canCreate` / `canEdit` / `authorize` trên action Livewire
- [ ] Không query DB nặng trong Column/Blade — gọi Service/DTO

## 4. API / mobile-ready (nếu có endpoint)

- [ ] Response envelope §12 (`data`, `meta`, `errors`)
- [ ] Sanctum auth
- [ ] Cùng Service với Filament (không duplicate logic)

## 5. Test & CI

- [ ] Pest: happy path
- [ ] Pest: **403** unauthorized
- [ ] Pest: validation **422** — Filament Livewire (form Create/Edit) **HOẶC** API FormRequest (không chỉ API)
- [ ] Pest: **DB constraint** bị vi phạm → `QueryException` (CHECK/unique) — backstop
- [ ] Pest: ngoại lệ nghiệp vụ (mutation tồn/tiền) ném đúng exception **409/422** (không 500)
- [ ] `pint --test` + `phpstan` + `php artisan test` xanh (khi có repo code)

## 6. Architecture lint (khi có repo — §13.4)

- [ ] Không pattern cấm: `Inventory::query()->update(`, mass `$request->all()` mutation
- [ ] `tests/Architecture/` pass (nếu đã scaffold)

## 7. Governance

- [ ] Không đổi schema (hoặc có `migration-note.md` + duyệt)
- [ ] Không đổi business rule (hoặc Human Owner duyệt)
- [ ] Chỉ 1 module chính (hoặc task đã ghi ≥2 module)

## 9. Doc Reference Integrity *(chỉ khi structural change)*

> Tick khi task có: monorepo merge, rename module/script, xóa file, đổi repo layout, sửa AGENTS.md/SKILL.md.

- [ ] Chạy `.cursor/bootstrap/validate-doc-refs.ps1` — exit 0 hoặc exit 2 (WARN OK, FAIL phải fix)
- [ ] Mọi FAIL (true dead link) đã được fix hoặc ref đã xóa
- [ ] `doc_audit: DONE` ghi vào `00-gate-status.md`

## 8. Database connection (ADR-009)

- [ ] Mutation / `InventoryService` / `MaterialInventoryService` / `DocumentNumberService` / transaction / `FOR UPDATE` → **`pgsql` only**
- [ ] Report query phức tạp → service riêng, mặc định **`pgsql_reporting`**
- [ ] Có `force_primary` khi report cần fresh data sau write
- [ ] **Không** auto read/write split toàn app MVP

---

## Kết luận reviewer

| | |
|---|---|
| **Pass / Fail** | |
| **Ghi chú** | |
