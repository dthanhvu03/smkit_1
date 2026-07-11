# Task_Log — Chọn mốc dự án (Sheet v3)

> **Canonical CSV:** `docs/erp/sheets/data/Task_Log_ERPSIXMEN.csv`  
> **Milestone CSV:** `docs/erp/sheets/data/Project_Milestone_ERPSIXMEN.csv`  
> **Paste guide:** `docs/erp/sheets/Sheet_v3_Paste_Guide_ERPSIXMEN.md`

Orchestrator / IT Manager **bắt buộc** gán đúng cột **C — Chọn mốc dự án** khi tạo hoặc cập nhật task trên Sheet.

> **Granularity policy (chốt TASK-GD0-047):** CSV `Task_Log_ERPSIXMEN.csv` ghi ở **mức mốc PM/vận hành** (M-ERP-xx) cho người không-IT, **KHÔNG** map 1-1 với mỗi `artifacts/TASK-GDx-NNN/` kỹ thuật. Một mốc Sheet (vd `M-ERP-00`) gom nhiều task kỹ thuật (GD0-001…047). **Nguồn sự thật per-task = `artifacts/PROGRESS.md`** (cập nhật mọi task); CSV chỉ sync khi có mốc/checklist vận hành mới cần PM tick. Vì vậy CSV dừng ở 14 dòng gốc là **đúng chủ đích**, không phải drift.

---

## Cột bắt buộc khi thêm task

| Cột | Giá trị cố định / quy tắc |
|-----|---------------------------|
| B — Mã dự án | `PRJ-202606-ERPSIXMEN` |
| C — Chọn mốc dự án | `{Mã mốc} · Giai đoạn X: {mô tả}` — vd `M-ERP-00 · Giai đoạn 0: Đăng nhập & phân quyền (chưa có số hàng trong kho)` |
| A — Task_ID | `TASK-ERPSIXMEN-NNN` — tăng số tiếp theo trong CSV repo |
| I — Owner | 1 người — Dev task GĐ0 → **Vũ** |
| F — Mô tả | **3 câu liền** (thiếu gì → hệ quả → cần gì) — không nhãn *Hiện trạng/Ảnh hưởng/Cần làm*; self-check: *QL kho đọc không cần hỏi lại* |
| M — Kết quả mong muốn | **Checklist đóng task (5 bước):** `(1) … · (2) … · (3) … · (4) … · (5) Drive + người xác nhận` — xem `Task_Log_ERPSIXMEN.csv` |

### Bảng thay từ (cột F/E)

| Tránh | Dùng |
|-------|------|
| địa chỉ web, deploy, URL | link mở trên Chrome/Edge |
| pilot | nhóm thử, hoặc liệt kê vai trò |
| pháp nhân | công ty (CTY) và hộ kinh doanh (HKD) |
| tồn kho / kho nền | số hàng trong kho / danh sách kho (chưa có số hàng) |
| menu | danh sách chức năng bên trái (menu) |
| dữ liệu nền | danh mục màu, size, đơn vị |
| nạp, seed, CRUD, 403, POC | nhập sẵn, tạo/sửa, báo không có quyền… |

Chi tiết: `sixmen-orchestrator` SKILL § *Task_Log — ngôn ngữ*.

---

## Bảng mốc — chọn theo phạm vi task

| Giá trị cột C | Mã gốc | Khi nào chọn |
|---------------|--------|--------------|
| **M-ERP-00 · Giai đoạn 0: Đăng nhập & phân quyền (chưa có số hàng trong kho)** | M-ERP-00 | Đăng nhập · quyền · nhật ký · CTY/HKD · chi nhánh · danh sách kho (chưa số hàng) · danh mục màu/size · quy tắc số chứng từ |
| **M-ERP-01 · Giai đoạn 1: Mã hàng, tồn, mua hàng, sản xuất** | M-ERP-01 | Mã hàng · tồn · đặt hàng NCC · nhập kho · lệnh SX · chuyển công ty↔HKD · chạy song song BigSeller |
| **M-ERP-01a · Giai đoạn 1 phụ: Khớp hồ sơ trước thanh toán** | M-ERP-01a | Rà PO·phiếu nhập·VAT·biên bản trước khi chi tiền |
| **M-ERP-2V · Giai đoạn 2V: Khách hàng, nhân sự, sản phẩm mới** | M-ERP-2V | CRM/HRM/R&D · bộ sưu tập (chưa đồng bộ sàn) |
| **M-ERP-TECH2 · Giai đoạn 2: Đồng bộ Shopee và tồn sàn** | M-ERP-TECH2 | Kéo đơn · giữ/đẩy tồn sàn · tắt BigSeller khi pilot ổn |
| **M-ERP-3 · Giai đoạn 3: Hoàn hàng, đối soát tiền, lãi lỗ** | M-ERP-3 | Hàng hoàn · đối chiếu tiền sàn · báo cáo lãi lỗ · KPI kho |
| **M-ERP-4 · Giai đoạn 4: Chăm sóc khách và thanh toán NCC** | M-ERP-4 | CRM đầy đủ · lệnh TT NCC · hỗ trợ AI (nếu duyệt) |
| **M-ERP-5 · Giai đoạn 5: Chấm công, lương, đánh giá nhân viên** | M-ERP-5 | HRM Full |
| **M-ERP-1.5 · Giai đoạn 1.5: Quản lý công việc trong ERP** | M-ERP-1.5 | Module PM — cuối lộ trình |
| **M-ERP-1.6 · Giai đoạn 1.6: Phân tích bán hàng và CSKH nhẹ** | M-ERP-1.6 | Insight · CSKH · review xấu — kết thúc dự án |

Mô tả đầy đủ từng mốc: cột **Giai đoạn & Tên mốc** trong `Project_Milestone_ERPSIXMEN.csv`.

---

## Quy tắc routing (Orchestrator)

1. **1 task = 1 mốc chính** — nếu đụng 2 giai đoạn, tách 2 task hoặc chọn mốc **sớm hơn** và ghi dependency trong mô tả.
2. **Dev build GĐ0** → cột C = `M-ERP-00 · Giai đoạn 0: Đăng nhập & phân quyền (chưa có số hàng trong kho)` (`001`–`014`).
3. **Không ghi Task_Log** cho: PM ký ma trận quyền · nghiệm thu giai đoạn 0 · CEO sign-off.
4. **Gate chưa pass** → không mở task mốc sau.
5. **Evidence:** GĐ0 → `Drive Giai đoạn 0/Dev`.

---

## Map phase tài liệu ↔ mốc Sheet

| Phase docs | Mốc Sheet |
|------------|-----------|
| GĐ0 `docs/erp/phases/GD0_Nen_tang/` | M-ERP-00 |
| GĐ1 `docs/erp/phases/GD1_Kho_SX/` | M-ERP-01 (+ M-ERP-01a nếu B5) |
| GĐ2V `GD2_Van_hanh_CRM_HRM/` | M-ERP-2V |
| GĐ2KT `GD2_Ky_thuat_Sync_san/` | M-ERP-TECH2 |
| GĐ3 → GĐ5, GĐ1.5, GĐ1.6 | M-ERP-3 → M-ERP-5, M-ERP-1.5, M-ERP-1.6 |

---

## Đồng bộ repo ↔ Sheet

1. Đọc Task_ID cuối trong `Task_Log_ERPSIXMEN.csv`.
2. Thêm dòng — cột C đúng nhãn bảng trên.
3. Paste Milestone (②) trước Task_Log (③) nếu dropdown chưa có nhãn mới.
4. Ghi **Mốc Sheet** vào `artifacts/{Task-ID}/01-task-brief.md`.

*Cập nhật: 16/06/2026 — ngôn ngữ phi kỹ thuật; self-check QL kho; nhãn mốc GĐ0 đổi «chưa có số hàng trong kho»*

---

## Task đã tạo brief (IT Manager log)

| Task ID | Tên ngắn | Mốc Sheet | Ngày tạo brief | Trạng thái |
|---------|----------|-----------|----------------|------------|
| TASK-GD0-003 | RolePermissionSeeder — 4 roles GĐ0 | M-ERP-00 | 2026-06-19 | **DONE 2026-06-19** — Pest 4/4 (11 assertions) · migrate:fresh --seed PASS · admin@sixmen.test super_admin ✅ |
| TASK-GD0-001 | Laravel 12 + Filament 4 + Shield + Spatie bootstrap | M-ERP-00 | 2026-06-17 | **DONE 2026-06-18** — ST-01–ST-09 PASS, Docker local dev verified (ERR-004–006 resolved) |
| TASK-GD0-002 | Migration GĐ0 — branches, warehouses, master data, scope tables | M-ERP-00 | 2026-06-18 | **DONE 2026-06-18** — migrate:fresh 20/20 · Pest 11/11 (41 assertions) · 3 Core Models · QA gate ✅ |
| TASK-GD0-006 | Security hardening — headers, rate limit, Reverb, HTTPS | M-ERP-00 | 2026-06-17 | **DONE 2026-06-19** — Pest 5/5 (18 assertions) · SecurityHeaders · ForceHttps · RateLimiter (5/min POST) · Reverb origin lock · AdminPanelProvider middleware |
| TASK-GD0-004 | Filament Resources: User, Branch, Warehouse | M-ERP-00 | 2026-06-19 | **DONE 2026-06-19** — Pest 5/5 (9 assertions) · 3 Resources + 9 Pages · Shield 48 perms · EnsureUserIsActive · ActivityLog ✅ |
| TASK-GD0-007 | KNOWN-ISSUES registry — file tập trung lỗi kỹ thuật | M-ERP-00 | 2026-06-18 | DONE (2026-06-20, HO approved) — registry ERR-001→024 + lifecycle rules + README mục KNOWN-ISSUES. Vũ duyệt format |
| TASK-GD0-008 | Doc audit process — ownership map, cadence, drift checklist | M-ERP-00 | 2026-06-18 | DONE (2026-06-20, HO approved) — `docs/ai-agent/reference/doc-audit-process.md`: ownership map + cadence + per-doc checklist, reference Structural Change Protocol §6 + validate-doc-refs.sh. Vũ confirm owner map. Follow-up (không chặn): áp header owner/last-verified ở gate kế |
| TASK-GD0-009 | CI/CD GitHub Actions (pint + phpstan + pest) + Git convention | M-ERP-00 | 2026-06-18 | DONE — main ✅ PostgreSQL ✅ Conventional Commits ✅ · chờ push |
| TASK-GD0-010 | AI Agent + Infrastructure Security Remediation (Audit 2026-06-19) | M-ERP-00 | 2026-06-19 | IN_PROGRESS — Brief tạo xong · Nhóm A (quick wins) sẵn sàng route DevOps · Nhóm D PENDING_HO (Vũ quyết định P0-1 cơ chế approval) |
| TASK-GD0-013 | Schema-type conformance (timestamptz+jsonb) + architecture lint (Audit Nhóm B B1/B2/B3) | M-ERP-00 | 2026-06-20 | B1+B2 DONE (HO approved) — 20 migration → tz/jsonb · architecture-lint.sh + CI · Postgres verified · Pest 42/42 · ERR-019/020 · B3 DONE 2026-06-20 (Event Map §6 nhãn SYNC/ASYNC sau khi B4/ADR-011 chốt qua GD0-021) |
| TASK-GD0-014 | Claude compliance enforcement — SessionStart digest + CLAUDE.md LUẬT CỨNG + pre-commit | M-ERP-00 | 2026-06-20 | DONE — khắc phục Claude Code không tự đọc AGENTS.md; hook inject digest + 6 luật cứng inline + pre-commit advisory |
| TASK-GD0-015 | Áp chuẩn Anthropic — @AGENTS.md import + SessionStart hook JSON additionalContext | M-ERP-00 | 2026-06-20 | DONE — A+B 2026-06-20; **C slim hub** 2026-06-27 (rules v2.30, hub ~145 dòng) |
| TASK-GD0-016 | AI Agent guardrails P0 — permissions deny/ask/allow + PreToolUse destructive guard | M-ERP-00 | 2026-06-20 | DONE (HO approved) — settings.json 12 deny/10 ask/12 allow + guard-pretooluse.sh. QA 6/6 chặn + 6/6 cho qua · ERR-021/023. P1/P2 DEFER |
| TASK-GD0-017 | Consolidate migration alters — gộp 2 alter 2026_06_19 vào migration gốc | M-ERP-00 | 2026-06-20 | DONE (HO approved) — 3 alter→1 (branch_id FK ordering phải giữ); is_active→000003, attribute_changes→create_activity_log; xóa 2 file + rename 000003. Schema cuối bất biến · Pest 42/42 (RefreshDatabase) · pint · lint PASS |
| TASK-GD0-018 | GĐ0 quality cleanup — ERR-017 (ActivityLog) + ERR-013 (UserPolicy IDOR branch-scope) | M-ERP-00 | 2026-06-20 | DONE — ERR-017 RESOLVED (non-bug: attribute_changes là cột chuẩn Spatie v5, diff capture đủ); ERR-013 RESOLVED (HO rule A): UserPolicy branch-scope guard (super_admin bypass, role khác same-branch) · Pest TC-IDOR-06/07/08 · 44 pass · PHPStan 0 · pint · lint |
| TASK-GD0-019 | Super-admin seeder từ config/.env + guard seeder mồ côi (ERR-024) | M-ERP-00 | 2026-06-20 | DONE (HO approved) — SuperAdminSeeder mồ côi → wire vào DatabaseSeeder; config/sixmen.php (email/password từ env, admin@sixmen.vn); .env.example SUPER_ADMIN_*; email_verified. Guard: architecture-lint orphan-seeder check + Pest TC-S03 (config email + verified). Pest 42 · PHPStan 0 · lint PASS |
| TASK-GD0-020 | ERR-023 follow-up — pre-push hook fresh pint cache | M-ERP-00 | 2026-06-20 | DONE — `.githooks/pre-push` dùng `pint --test --cache-file=$(mktemp)` (fresh mỗi lần) → re-eval như CI checkout sạch, hết blind-spot cache đã gây ERR-023. Hook test PASS |
| TASK-GD0-021 | ADR B4 (Outbox Phase-1 accepted-risk) + B5 (RLS vs app-layer branch scope) — Audit Nhóm B | M-ERP-00 | 2026-06-20 | DONE (HO approved) — **B4=Option A** (SYNC-TX tiền/tồn nội bộ + async best-effort sàn + Strict Lock Ordering Kho→Công nợ→Giá vốn + no-heavy-TX + `inventory_sync_logs` TTL 7d; Outbox→Phase 2) + **B5=Option C** (app-layer scope GĐ1 + RLS Phase 2; anti-bypass raw SQL + implicit-JOIN cross-branch test + reporting view scoped + Cross-Entity Document liên thông CTY/HKD). Promoted Master Decisions §5 ADR-011/012 + Event Map §6 nhãn SYNC/ASYNC → unblock B3 (GD0-013). Follow-up GĐ1: lint listener rule + DoD branch-scope + thiết kế chi tiết cross-entity |
| TASK-GD0-022 | Fix ERR-025 — Shield permissions seeding (super_admin thấy đủ Resource) | M-ERP-00 | 2026-06-20 | DONE (HO approved Option A) — `RolePermissionSeeder` chạy `shield:generate --all --option=permissions --panel=admin` (chỉ permission, giữ UserPolicy branch-scope GD0-018) + `super_admin` syncPermissions(all). permissions 0→108 · super_admin can ViewAny:* TRUE · 8 Resource hiện nav. Pest 46 (TC-S05 permissions>0 + TC-S06 super_admin all) · PHPStan 0 · pint · architecture-lint PASS. Matrix các vai khác (ceo/ql_kho/ke_toan) để GĐ1 |
| TASK-GD0-023 | Fix ERR-026 — thêm PHP ext-intl vào Docker image | M-ERP-00 | 2026-06-20 | DONE — `docker/Dockerfile` +`icu-dev` (apk) +`intl` (docker-php-ext-install); Filament v4 `Illuminate\Support\Number::format()` cần ext-intl, thiếu → mọi list page Internal Server Error. Rebuild `app` image + restart. Verified: `php -m` có intl · Number::format=1,234.5 · Pest 48 (guard `extension_loaded('intl')` + smoke) · pint · architecture-lint PASS |
| TASK-GD0-024 | Fix ERR-027 — cô lập database test (test không wipe DB dev) | M-ERP-00 | 2026-06-20 | DONE (HO approved Option A) — `php artisan test` (RefreshDatabase) wipe DB dev vì chạy chung database; root cause sâu: docker-compose set `DB_DATABASE` vào `$_SERVER` mà Laravel `env()` đọc `$_SERVER` trước `$_ENV` → phpunit `<env force>` thua. Fix: DB `sixmen_erp_test` riêng + `tests/bootstrap.php` ép `$_SERVER[DB_DATABASE]` + init.sql idempotent + Guard Unit test DB≠dev. Verified dev DB giữ nguyên sau full test · Pest 47 · pint · lint PASS |
| TASK-GD0-025 | Gom navigation group sidebar — 📦 Danh mục + ⚙️ Hệ thống | M-ERP-00 | 2026-06-22 | DONE (HO approved scope + renumber) — root cause: 8 Resource thiếu `navigationGroup` → menu phẳng. Fix: Brand/Category/Color/Size/Unit→"Danh mục"; User/Branch/Warehouse→"Hệ thống"; Shield Vai trò `->navigationGroup('Hệ thống')`; AdminPanelProvider `navigationGroups` collapsible KHÔNG icon group (ERR-029: Filament v4 cấm group-icon khi item có icon). UI-only. Research-backed (Hick's Law ≤5/nhóm, §NAVIGATION). Pest TC-NAV-01/02/03 + smoke TC-PANEL-01 render /admin · phpstan · pint · lint PASS. Renumber GD0-024→025 do PR #21 chiếm 024 (test-iso) |
| TASK-GD0-026 | Seed master data GĐ0 (reference + demo org) + dọn seeder vào module | M-ERP-00 | 2026-06-22 | DONE (HO approved) — 7 bảng trống + chưa có seeder MD. Tạo `MasterDataSeeder` (màu/size/đơn vị + brand/category mẫu; wire DatabaseSeeder) + `DemoOrgSeeder` (CTY/HKD/chi nhánh/kho placeholder gắn nhãn DEMO; KHÔNG wire — tránh demo lọt prod). 8 bảng có data, idempotent updateOrCreate. **Boundary cleanup (HO bắt):** seeder domain phải nằm trong module — chuyển cả 4 (RolePermission/SuperAdmin/MasterData/DemoOrg) vào `modules/Core/Seeders/`, `database/seeders/` chỉ còn `DatabaseSeeder`. Pest 59 · pint · phpstan No errors. ⚠️ Org DEMO → thay data thật (tên+MST) trước UC-00 prod |
| TASK-GD0-030 | Mật khẩu tạm + ép đổi mật khẩu lần đầu | M-ERP-00 | 2026-06-22 | DONE (HO approved, GĐ0 fresh). Thiếu phần checklist TASK-ERPSIXMEN-005 (mật khẩu tạm + đổi lần đầu) — UserResource cũ chỉ nhập tay. Fix: migration additive `users.must_change_password`; CreateUser tự sinh mật khẩu tạm (Str::password readable) + Filament Notification persistent (KHÔNG alert theo HO) + cờ bật; middleware `EnsurePasswordChanged` ép redirect /admin/change-password (cho phép trang đổi+logout+livewire); page `ChangePassword` (form mật khẩu mới + xác nhận) đổi→tắt cờ→notify; EditUser reset password→bật cờ lại. super_admin cũ default false (không bị khóa). Pest 7 TC (TC-PWD-01..07 gồm 2 HTTP integration) · full 66 · pint · phpstan No errors · arch-lint PASS |
| TASK-GD0-031 | Chuyển + tách migration Permission (Spatie) vào Core, 1-bảng/file | M-ERP-00 | 2026-06-22 | DONE (HO approved). `database/migrations/create_permission_tables` (Spatie vendor: 5 bảng/1 file ở app-level) phạm 2 nguyên tắc: module boundary (RBAC = Core domain, seeder đã ở Core) + 1-bảng/1-file. Tách thành 5 migration trong `modules/Core/database/migrations/` (permissions·roles·model_has_permissions·model_has_roles·role_has_permissions), giữ thứ tự FK qua timestamp 124813→124817 + logic config-driven (table_names/teams) nguyên vẹn → tương đương 100% bản gốc. `database/migrations/` chỉ còn Laravel default (users/cache/jobs). Verify: RBAC seeder 108 permissions + super_admin đủ quyền (test DB rebuild) · full Pest 66 · pint · phpstan No errors · arch-lint PASS. Trade-off: lệch convention single-file Spatie — đổi lấy nhất quán nguyên tắc SIXMEN |
| TASK-GD1-007 | Thiết kế Master Data GĐ1 (UoM + Color/Size/Fit/Category + Org) | M-ERP-01 | 2026-06-22 | DESIGN BACKLOG (mở rộng từ UoM-only). 03-architecture-impact DRAFT lưu xong: gap analysis (color_family/pantone, size_dimension, fit, UoM conversion) + reconcile đa pháp nhân + schema + thuật toán SKU matrix. **5 quyết định HO:** (1) 1 branch SIXMEN + 2 pháp nhân CTY/Khanh·HKD/Khang (branch≠legal_entity); (2) KHÔNG multi-tenant, cô lập legal_entity app-scope ADR-012; (3) đa-brand không build sẵn — để ngỏ products.brand_id; (4) Fit ở Style products.fit_type_id; (5) đại diện text-only trên legal_entities (không FK users). Implement GATED sau UC-00+GĐ1; feed GD1-001; schema GĐ0 đụng → migration additive mới + Vũ duyệt |
| TASK-GD0-037 | Breach-check mật khẩu (Password::uncompromised, NIST 800-63B Rev.4) | M-ERP-00 | 2026-06-23 | DONE local (HO approved policy: giữ min 8 + breach-check online) — review GD0-036 lộ gap: validation chỉ minLength(8)+confirmed → bỏ sót mật khẩu đã lộ. Rev.4 (2025) bỏ ép composition, bắt buộc đối chiếu rò rỉ. Diagnostic: container→api.pwnedpasswords.com HTTP 200 0.24s. Fix: `Password::defaults(min(8)->uncompromised())` tập trung ở AppServiceProvider; ChangePassword + UserResource(edit) dùng `Password::default()`; KHÔNG áp cho mật khẩu tạm auto-sinh. Fail-open khi API lỗi (không block). k-anonymity (5 ký tự đầu SHA-1). Pest TC-PWD-08..11 (Http::fake) + fix TC-PWD-05 flaky mạng; full 70 passed · phpstan No errors · pint PASS. **Phương án dự phòng offline (HO duyệt mở rộng 2026-06-23, defense-in-depth):** `resources/security/weak-passwords.txt` (10k SecLists MIT) + Rule `NotWeakPassword` (offline, không gọi mạng) + config `sixmen.password.check_online` (env, default true) → air-gapped đặt false bỏ HIBP chỉ dùng offline list, tránh timeout. Giải fail-open: prod chặn outbound vẫn chặn baseline. Pest TC-PWD-12..15 (TC-14 assertNothingSent khi air-gapped · TC-15 assertSentCount khi online); full 75 passed · phpstan No errors · pint PASS. DevOps prod outbound không còn block release |
| TASK-GD0-046 | Phase 0 Closure Audit (cross-check 7 phòng ban) | M-ERP-00 | 2026-06-24 | DONE — audit_complete PASS (7/7, KHÔNG P0); 11 P1 + 10 P2. Remediation → GD0-047. **squash-merged PR #40** (`a91f9ba`). Còn UC-00 sign-off (Vũ) phase gate riêng |
| TASK-GD0-047 | Phase 0 P1 Remediation (đóng 11 P1 từ GD0-046) | M-ERP-00 | 2026-06-24 | DONE — 11/11 P1 (length→ERD · LegalEntity · .env PASSWORD_CHECK_ONLINE · doc-refs 0 FAIL · test 403 · release-checklist · sync PROGRESS/CSV) · Pest 83 · **squash-merged PR #40** (`a91f9ba`). ⚠️ nhánh `feat/GD0-046-047` stale 8-behind không-B5 — KHÔNG re-merge (ERR-030) |
| TASK-GD0-050 | MD-07 Cấu hình mã chứng từ + preview (ERPSIXMEN-008) | M-ERP-00 | 2026-06-24 | DONE — **merged PR #47 → main** (squash `dc1b79a`). Document number config + preview qua envelope ADR-013 (PayloadValidator + Service + DB partial-unique backstop). QA TC-DOCNO-01..17 + TC-403-04/05 · phpstan 0 (ERR-034 fix) · pre-merge PASS. Follow-up: HO DoD-05 (Khanh screenshot) · dev migrate:fresh |
| TASK-GD0-051 | Audit write-path lõi + fix B3/B4/B5 | M-ERP-00 | 2026-06-24 | DONE — audit Critical 0 · Major 1 (User) **đã fix** qua `UserService`+`UserValidator` (B3) · scope_key single-source + duplicate 422 (B4) · B5 CHECK merged PR #47. **squash-merged PR #60** (`24308b6`). Pest 129 · phpstan 0 · TC-USER-SVC + TC-DOCNO-18/19. Out-of-scope backlog: B6 Category cycle · B1/B2 GĐ1 |
| TASK-GD0-052 | Units — cột `symbol` (ký hiệu hiển thị gọn) | M-ERP-00 | 2026-06-24 | DONE — merged PR #50 · migration additive nullable · Pest TC-UNIT-SYM-01/02 |
| TASK-GD0-054 | Màn Nhật ký audit — FR-CORE-07b (đóng ERPSIXMEN-009) | M-ERP-00 | 2026-06-24 | DONE — PR #52/#53 + #54 |
| TASK-GD0-055 | ERPSIXMEN-014 — scope quên MK: admin cấp lại (không email) | M-ERP-00 | 2026-06-24 | DONE — HO UAT PASS · PR #57/#58 · Pest LoginTest 3/3 |
| **UC-00** | **Phase gate — nghiệm thu GĐ0** | M-ERP-00 | 2026-06-24 | **PASS** — HO xác nhận GĐ0 hoàn thành · GĐ1 unlocked · `artifacts/archive/GD0/UC-00/00-gate-status.md` · kickoff TASK-GD1-001 |
| TASK-GD1-001 | Migration GĐ1 Wave 1 (ERD §18 bước 1–6 + master ALTER) | M-ERP-01 | 2026-06-24 | **KICKOFF** — artifacts `TASK-GD1-001/` · feed GD1-007 · migration-note PENDING Vũ · **chưa DDL** |
| TASK-GD1-002 | InventoryService single-entry + inventory/inventory_movements + ERR-038/043 | M-ERP-01 | 2026-06-26 | DONE — pushed `feat/GD1-002-inventory-service` (chờ HO PR) · Pest 224 PASS · NOWAIT 55P03→409 `LockConflictException` (§4.3 canonical) · ERR-038 D1/D2/D3 closed |
| TASK-GD1-003 | MaterialInventoryService (tồn NPL hot-path) — implement | M-ERP-01 | 2026-06-26 | DONE — pushed `feat/GD1-003-material-inventory` (chờ HO PR) · GATE Vũ+Khanh PASS (bcmath·exception §4.3·hardening·available formula) · Pest 237 PASS · `InsufficientMaterialException` canonical 409 · hardening migration gốc (CHECK non-negative + created_by NOT NULL) · reuse infra GD1-002 (acquireBatch/LockConflict/3 guardrail) |
| TASK-GD1-011 | Sửa SKU có kiểm soát + chuyển tồn (D6 A+ Phần 2) | M-ERP-01 | 2026-06-27 | BACKLOG — admin sửa chuỗi SKU + chuyển tồn cũ→mới (avg_cost·đa kho·CTY/HKD·chặn chứng từ mở) + chặn xóa biến thể có tồn. Đụng InventoryService/CogsService → gate Vũ. ADR candidate SKU auto-derive vs free-text |
| TASK-GD1-012 | Sinh mã vạch (EAN-13 nội bộ) + in tem | M-ERP-01 | 2026-06-27 | BACKLOG — HO chốt EAN-13 nội bộ (prefix 20–29 + counter + check digit), action "Sinh mã vạch" per-variant on-demand (giống Nhanh), cho nhập tay UPC/EAN + in tem. Research `TASK-GD1-010/research-barcode-va-gia.md` |
| TASK-GD1-013 | Bật CRUD Pháp nhân (LegalEntity) | M-ERP-01 | 2026-06-27 | DONE-local — ERR-051: read-only→CRUD. Form + Create/Edit pages + Edit/Delete + LegalEntityPolicy create/update/delete (Shield) + delete-guard `isReferenced()` (FK 7 bảng) + nút Tạo. Hard-delete (no SoftDeletes). Pest **263** (LE 6/6) · Pint · PHPStan. Còn browser-verify + commit |
| TASK-GD1-014 | Sidebar domain-driven 5 nhóm | M-ERP-01 | 2026-06-27 | REVIEW-READY — tách "Hệ thống"→Kho/Tổ chức/Quản trị; 8 Resource + AdminPanelProvider + Shield→Quản trị; fix trùng navigationSort. Pest **270** (TC-NAV 17) · ERR-054 |
| TASK-GD1-015 | Phân biệt hệ size (màn Hệ size + gán size) | M-ERP-01 | 2026-06-27 | DONE-local — ERR-055: SizeDimensionResource (CRUD+policy) + SizeResource (Select hệ required·cột·filter·unique scoped) + MasterDataSeeder size quần NUM-PANT; dọn "29" lạc ALPHA. Không schema. Pest **275** (SD 5/5) · Pint · PHPStan. Reseed dev. Còn browser-verify + commit |
| TASK-GD1-004a | Purchase schema + PO (suppliers/workshops/PO) | M-ERP-01 | 2026-06-27 | DONE-local — migrate 4 bảng + module Purchasing + SupplierResource (CRUD NCC) + PurchaseOrderResource (header code-auto + Repeater items + 3 Pages + Policy). Pest **285** (PO-SCH 5/5 + PO-UI 3/3)·Pint·PHPStan. ERR-056 fixed. Còn browser-verify + PR. 004b (GRN/QC/tồn/Cogs) sau. |
| TASK-GD1-016 | Hồ sơ & đính kèm NCC (MST + hợp đồng + attachment dùng chung) | M-ERP-01 | 2026-06-29 | BACKLOG — HO phát hiện form NCC thiếu chỗ lưu hợp đồng/hồ sơ pháp lý + gap MST (tax_code). Đề xuất: field MST+đại diện · `attachments` polymorphic (tái dùng GRN/PO) · `supplier_documents` (loại + ngày hết hạn). Đụng schema + scope → gate Khanh+Vũ. |
| TASK-GD1-018 | Hardening UX + Validation + Bảo mật toàn route (nền dùng chung) | M-ERP-01 | 2026-06-29 | DONE-local — preset `SixmenForms` (date/today/text/textarea/code) mọi route + trait `SanitizesInput` 26 model (zero-width/bidi/control) + validation kín (minItems/range/regex message) + **lint guard UX+SEC** (cấm trần · $guarded · $request->all · debug) + audit bảo mật sạch + N+1 fix (ERR-053). Không schema. Pest **304** · Pint · PHPStan · arch-lint · pre-push PASS. 4 lăng kính + ma trận route + 09-handoff. Còn browser-verify + PR (nhánh `feat/GD1-004a-hardening`). |
| TASK-GD1-010 | Mã hàng + biến thể CRUD + Matrix Entry SKU (Color×Size) | M-ERP-01 | 2026-06-26 | **MERGED PR #81** (2026-06-27) — D1–D6 APPROVED (D1 freeze·D2 `products.size_dimension_id` có sẵn·D3 trước GD1-004·D4 permission·**D5 SKU=D01 `SX{Cat}{Code}-Màu-Size`**·**D6=A+ Phần 1 khóa field mã khi đã có biến thể**). Backend `ProductVariantGeneratorService` + Frontend (2 Resource·matrix action·2 Policy·nav·lock mã). Pest **257** · Pint · PHPStan. D6 Phần 2 → GD1-011, barcode → GD1-012. Còn: Khanh walkthrough + browser-verify. `artifacts/TASK-GD1-010/` |
