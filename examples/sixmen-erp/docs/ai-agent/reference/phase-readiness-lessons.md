# Phase-Readiness Lessons — bài học chốt từ audit GĐ0→GĐ1

> **Path:** `docs/ai-agent/reference/phase-readiness-lessons.md`
> **Nguồn:** re-audit GD0-056 + deep-dive GĐ1-readiness GD0-057 (2026-06-24). Canonical — skill chỉ pointer, không copy dài (anti-bloat).
> **Mục đích:** agent **mọi nền tảng** (Cursor/Codex/Claude) không lặp lại các miss đã xảy ra ở GĐ0 và không sót khi chuyển giai đoạn.

## 0. Luật vàng — Phase-transition deep-dive (orchestrator)

**Trước khi mở task code đầu tiên của GĐ(n+1)**, chạy **deep-dive readiness** trên các *contract* mà GĐ(n+1) sẽ dựng lên: đánh số chứng từ, exception→HTTP seam, lock ordering, module/migration composition. Audit "breadth 7 phòng ban" **không** thay được deep-dive theo seam — GD0-046 closure audit PASS nhưng vẫn sót 4 BLOCKER-GĐ1 + 3 gap nghiệp vụ. Phân loại finding: **BLOCKER** (buộc đổi schema/contract giữa phase sau) vs **FIX-NOW** (rẻ giờ, đắt sau) vs **OK**.

## 1. Architect

- **Shared enum/model thuộc module THẤP NHẤT cần nó.** `warehouses`/`fit_types` là master-data Core (GĐ0) → enum `WarehouseType`/`FitType` phải ở `modules/Core/Enums/`, KHÔNG ở module GĐ1. Core import module GĐ1 = upward dep, GĐ0 không boot độc lập. **Grep cross-phase import trước mỗi phase gate** (`grep -rn "use Modules\\\\{PhaseSau}" modules/Core app/`).
- **Đặt file: cross-cutting → `app/`; domain-riêng → `modules/{M}/` (chốt GD0-058).** Quy tắc 1 câu: *"dùng chung/giống nhau ở MỌI module → `app/`; gắn riêng 1 module → module đó."*
  - `app/` (Exceptions / Support / Support/Locking / Support/Concerns) = hạ tầng cross-cutting KHÔNG gắn bảng cụ thể: `DomainException` base, `ConfigurationException` (generic), `SystemActor`, `AcquiresOrderedLocks`/`LockResource`, `HasBranchScope`.
  - `modules/{M}/Exceptions|Support|Enums` = gắn domain/bảng của module: `InsufficientInventoryException`→`modules/Warehouse/Exceptions`, `DocumentNumberScopeKey`/`AuditLogPresenter`→`modules/Core/Support` (helper domain Core), enum gắn bảng → module sở hữu bảng (xem gạch đầu dòng trên).
  - Phân biệt với rule trên: enum/model **gắn BẢNG** → module sở hữu bảng (thấp nhất); infra **KHÔNG gắn bảng**, generic cross-module → `app/`. Seeder/migration domain vẫn ở `modules/{M}/` (memory module-scoped-seeders).
- **Exception→HTTP seam phải tồn tại TRƯỚC khi service nhân lên.** Đừng để mỗi service tự `try/catch` map status (23505→422 copy-paste). 1 `bootstrap/app.php` `render()` closure + `DomainException` base (`httpStatus()`+`problemDetails()` RFC 7807). Service chỉ `throw`.
- **Lock ordering = abstraction ép được, KHÔNG phải convention.** ADR-011 Kho→Công nợ→Giá vốn: 1 trait/helper là lối DUY NHẤT được `lockForUpdate`, backed bởi test. Không có nó → mỗi service tự chế = bề mặt deadlock.
- **Migration cross-module:** đừng dựa số `_0000NN` đặt tay. Reserve **band/module** (Core 0001–0099, Product 0100–0199…) hoặc bắt cross-module-FK migration timestamp strictly-later than referent.

## 2. Backend

- **Không để field config "lưu nhưng không dùng".** `year_format`/`separator` lưu+validate nhưng renderer bỏ qua → bẫy logic. Wire vào hành vi hoặc drop. **1 renderer thuần dùng chung** cho preview + generation (chống drift "preview hiện X, sinh ra Y").
- **Consume `actorId` — đừng dựa `auth()` ngầm.** Path queue/system (số chứng từ tự sinh, movement) không có `auth()` → causer NULL trên đúng record tiền/tồn cần truy vết. `activity()->causedBy($actorId ?? systemUser())`.
- **Chuẩn hoá key nhất quán mọi nhánh.** scope_key lowercase legal_entity/branch nhưng quên warehouse → key lệch case, unique sai. Cấm fallback `'unknown'` (đã `exists` ở validator thì throw).
- **SYNC-TX vs afterCommit (ADR-013/014):** tiền/tồn "mất là hỏng" → `event()` SYNC trong locked TX; notification lose-able → `dispatch()->afterCommit()`. Lập 1 ví dụ mẫu trước khi GĐ1 viết instance đầu.
- **`DocumentNumberConfig` không phải bằng chứng pattern cho inventory** — COLD entity, chưa stress-test concurrency. Xem khung 5 tầng + phổ COLD↔HOT trong skill.

## 3. Database

- **Counter có reset_policy PHẢI có period-anchor.** `next_number`+`reset_policy` mà thiếu `period_key`/`last_reset_at` → monthly/yearly reset bất khả thi (không biết kỳ hiện tại). Thiết kế cột kỳ ngay từ đầu.
- **Ràng buộc nghiệp vụ phải có backstop cứng, không advisory.** `reset_policy`↔token kỳ trong pattern: validator cứng (MONTHLY⇒{MM}/{YYYYMM}), không chỉ hint → tránh mã trùng silent.
- **ERD là SoT — cập nhật sau MỌI ALTER.** GĐ0 ERD drift (`must_change_password`, `attribute_changes`, cột GĐ1) = điểm mù audit. Cột GĐ1 vào ERD GĐ1, không phải ERD GĐ0.
- **migrate:fresh replay:** column-default-to-row-id chỉ OK nếu row insert trong **cùng** migration (không tham chiếu row của seeder). `down()` phải đối xứng (kể cả khôi phục unique cũ).

## 4. QA

- **Test cái backstop đã document, không chỉ happy path.** DB unique-race 23505→422 (`mapUniqueScopeViolation`) phải có test ép `QueryException`. Backstop không test = không tồn tại khi cần.
- **Filament 4 Resource:** HTTP 403 (index/create/edit) **và** Livewire validation unhappy — dùng `set('data.*')`, **không** `fillForm()` (Schema v4 không hydrate → false pass). Ref TASK-GD1-009 `WarehouseTypeRegistryTest`.
- **403 coverage qua data-provider lặp MỌI resource**, không lấy mẫu 4/10. Security header assert đủ (CSP+HSTS), không 2/6.
- **Seeded super_admin posture phải test:** không default password yếu (`changeme`), có guard prod. Tài khoản quyền cao nhất là target #1.
- **EnvelopeComplianceTest lint:** không query trong `DB::transaction` trừ locked write + movement insert; `lockForUpdate` chỉ qua trait sanctioned.

## 5. BA / IT Manager — phase-close completeness gate

- **Trước khi tuyên bố phase DONE: cross-check MỌI FR-CORE-xx → có Resource/Service/seed/test thực tế.** GĐ0 đóng UC-00 PASS nhưng **Settings (FR-CORE-06c/d/e)** chỉ có bảng (không model/Resource/seed), **LegalEntityResource (FR-CORE-05b)** không tồn tại, **color-code 3-ký-tự (FR-CORE-MD-05)** không enforce — closure audit không bắt vì không có FR-completeness checklist.
- Mọi feature defer phải **HO ký + ghi PROGRESS**, không "ngầm thiếu".
- Phân biệt **load-bearing** (module-flag Settings gate GĐ1) vs **cosmetic** (UI rule) khi quyết defer.

---

**Liên kết:** chi tiết bằng chứng `artifacts/TASK-GD0-056/02-audit-findings.md` + `artifacts/TASK-GD0-057/03-deepdive-gd1-readiness.md`. ADR liên quan: ADR-011 (lock ordering) · ADR-013/014 (side-effect) — `docs/erp/core/01_Master_Decisions.md §5`.
