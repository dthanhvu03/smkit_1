# Dry-run — GĐ0 B1: Filament Shield + Matrix quyền pilot

> Mô phỏng workflow `@sixmen-orchestrator` — **không phải code thật**.  
> Input: *"Implement Filament Shield + matrix quyền pilot CEO / QL kho / KT"*

---

## Tóm tắt orchestrator

| Mục | Giá trị |
|-----|---------|
| Module chính | Core |
| Schema change | Không (dùng bảng Spatie/Shield có sẵn) |
| Gate Human Owner | QLVH ký matrix quyền (B2) |
| Artifact tạo | 7/7 templates |

---

## 1. Task Brief (IT Manager)

| Field | Value |
|-------|-------|
| Task ID | GD0-B1 |
| Ngày | 10/06/2026 |
| Phase | GĐ 0 Core — Tuần 2 |
| Priority | P0 |
| Human Owner | QLVH (matrix), Vũ (tech) |

### Yêu cầu gốc

Cài Filament Shield, tạo roles + permissions pilot: CEO, QL kho, Kế toán (KT). Menu admin khác nhau theo role.

### Scope IN

- Cài `bezhansalleh/filament-shield` + publish config
- Seeder roles: `ceo`, `ql_kho`, `ke_toan`, `super_admin`
- Permissions theo module menu GĐ 0 (Core settings, users, audit)
- Menu Filament ẩn/hiện theo role

### Scope OUT

- Warehouse, Production, Product, CRM, HRM
- PO, GRN, LSX, sync sàn
- Chi nhánh CRUD (task B3 — tách riêng)

### Module ảnh hưởng

| Module | Thay đổi |
|--------|----------|
| Core | RBAC Shield, menu policy |

### Definition of Done

- [ ] Shield cài + `php artisan shield:install` OK
- [ ] 3 user thử: CEO / QL kho / KT — menu khác nhau
- [ ] Permission deny trả 403 khi truy cập trực tiếp URL
- [ ] QLVH xác nhận matrix quyền
- [ ] Video evidence cho UC-00 tiêu chí (b)

### Gate cần duyệt Human Owner

- [ ] Đổi schema — **Không** (package tables)
- [ ] Đổi business rule — **Không**
- [ ] ≥2 module — **Không**
- [x] Matrix quyền pilot — **QLVH ký trước merge**

---

## 2. Acceptance Criteria (BA)

**User story:** Là QLVH, tôi muốn mỗi vai trò pilot chỉ thấy menu phù hợp, để giảm thao tác sai và chuẩn bị GĐ 1.

| # | Given | When | Then |
|---|-------|------|------|
| AC-01 | User role CEO | Đăng nhập admin | Thấy Dashboard + Settings; không thấy User/Permission |
| AC-02 | User role QL kho | Đăng nhập | Menu kho placeholder hoặc ẩn module chưa GĐ 1 |
| AC-03 | User role KT | Đăng nhập | Menu tài chính placeholder; không sửa user |
| AC-04 | User không quyền | Truy cập URL resource | 403 Forbidden |

**Open questions:** Không blocker — matrix chi tiết theo `SRS.md` §4 và `BRD.md` §3.1.

---

## 3. Architecture Impact (Architect)

### Tóm tắt

Dùng Filament Shield trên Spatie Permission — không custom schema. Triển khai seeder + Policy sync, menu visibility qua Shield/Filament native — ít rủi ro nhất.

### Module boundary

| Module | IN / OUT | Lý do |
|--------|----------|-------|
| Core | IN | RBAC thuộc Core |
| Warehouse+ | OUT | GĐ 1 |

### Database impact

| Bảng | Thay đổi | Migration? |
|------|----------|------------|
| `roles`, `permissions`, pivots | Package install | Có — package migration, đã có migration note |

### Phương án triển khai

1. `composer require bezhansalleh/filament-shield`
2. `php artisan shield:install --fresh` (dev only)
3. `RolePermissionSeeder` — idempotent
4. Filament Resource `authorize()` + navigation `->visible()`

### Cần Human Owner duyệt

- [ ] Schema — package only, Vũ acknowledge
- [x] Matrix quyền — **QLVH**

---

## 4. Migration Note (Database)

| Field | Value |
|-------|-------|
| Migration file | `vendor/spatie/laravel-permission/database/migrations/*` + Shield publish |
| Task ID | GD0-B1 |

### Mục đích

Tạo bảng RBAC chuẩn Spatie Permission (roles, permissions, model_has_roles, ...).

### Backward compatibility

- Bảng mới trên DB trống — không ảnh hưởng data nghiệp vụ
- Rollback: `migrate:rollback` xóa bảng RBAC (chỉ dev/staging)

### Chạy an toàn

- [x] Dev/staging trước
- [ ] Backup trước prod (khi có prod)
- [x] QLVH duyệt matrix (không phải schema)

---

## 5. Impact / Risk / Rollback

| Rủi ro | Xác suất | Tác động | Mitigation |
|--------|----------|----------|------------|
| Shield sync ghi đè permission custom | TB | TB | Seeder idempotent; không chạy `--fresh` prod |
| Super admin lockout | Thấp | Cao | Giữ 1 super_admin seed; test login trước |

**Rollback:** `git revert` + `migrate:rollback` (dev); re-seed roles.

---

## 6. Implement notes (Backend + Frontend — tóm tắt)

**Backend:**

- `database/seeders/RolePermissionSeeder.php`
- Policies auto-generated Shield hoặc custom `UserPolicy`

**Frontend:**

- `UserResource`, `RoleResource` — chỉ QLVH/super_admin
- Navigation groups: `visible(fn () => auth()->user()->can('...'))`

---

## 7. Test Plan (QA)

| ID | Mô tả | Expected | Priority |
|----|-------|----------|----------|
| TC-01 | CEO login | Menu không có Users | P0 |
| TC-02 | QL kho login | Menu khác CEO | P0 |
| TC-03 | KT login | Menu khác CEO/QL kho | P0 |
| TC-04 | CEO → `/admin/users` | 403 | P0 |
| TC-05 | Shield permission sync | `php artisan permission:cache-reset` OK | P1 |

### Regression

- [ ] Login/logout vẫn OK (task A5)
- [ ] Không break audit (task B5 — tách)

---

## 8. Release Checklist (DevOps)

| Môi trường | local / staging |
|------------|-----------------|

### Pre-release

- [x] Test plan TC-01–04 pass (local)
- [x] Migration note reviewed
- [ ] Không deploy prod GĐ 0 — chỉ local/staging

### Deploy steps (staging)

1. `composer install`
2. `php artisan migrate`
3. `php artisan db:seed --class=RolePermissionSeeder`
4. `php artisan shield:generate --all` (nếu cần)
5. Smoke: 3 user login

### Human Owner approval (production)

- [ ] N/A — GĐ 0 chưa prod

---

## 9. Gate cuối — chờ Human Owner

| Gate | Trạng thái |
|------|------------|
| QLVH ký matrix quyền pilot | **CHỜ** |
| Khanh + Vũ ký UC-00 | Sau khi B1–B5 xong |

---

## Verify dry-run

| Template | Filled |
|----------|--------|
| task-brief.md | ✅ §1 |
| acceptance-criteria.md | ✅ §2 |
| architecture-impact.md | ✅ §3 |
| migration-note.md | ✅ §4 |
| impact-risk-rollback.md | ✅ §5 |
| test-plan.md | ✅ §7 |
| release-checklist.md | ✅ §8 |

**Kết luận:** Workflow orchestrator produce đủ artifact. Implement thật chờ QLVH ký matrix.
