# Test Plan — SIXMEN ERP

| Field | Value |
|-------|-------|
| Task ID | |
| QA | AI QA Tester |
| Ngày | |

## Phạm vi test

| Loại | IN / OUT |
|------|----------|
| Unit (Pest) | |
| Feature | |
| Manual UAT | |

## Test cases

| ID | Mô tả | Steps | Expected | Priority |
|----|-------|-------|----------|----------|
| TC-01 | | | | P0 |

## AC exception coverage *(nếu AC có mutation/fail condition)*

| AC ID | Model impact | Exception / fail condition | Pest case | Pass? |
|-------|--------------|----------------------------|-----------|-------|
| AC-01 | | | | |

## Edge cases

- 
- 

## ERP safety tests *(backend/migration — tick khi đụng critical domain)*

> Critical guards only — không yêu cầu test mọi CRUD service.

- [ ] `migrate:fresh --seed` passes
- [ ] 403 unauthorized · 422 invalid input · 409 conflict nếu AC yêu cầu
- [ ] AC exception/fail condition được cover theo `02-acceptance-criteria.md`
- [ ] Document number concurrency — no duplicate
- [ ] Inventory movement + balance same transaction
- [ ] Material inventory movement + balance (if NPL)
- [ ] CTY vs HKD scope / IDOR · `super_admin` still audited
- [ ] No direct `inventory` / `material_inventory_balances` update outside critical service
- [ ] Movement/audit not UPDATE/DELETE to fix business mistakes
- [ ] No mutation on `pgsql_reporting`
- [ ] Soft delete — no hard delete referenced records

## Regression checklist

- [ ] Login / logout
- [ ] Permission deny đúng role
- [ ] Audit log ghi khi sửa record
- [ ] Không regression module liền kề

## Permission / Security checklist

- [ ] Mọi action có policy / permission
- [ ] Filament Resource: HTTP 403 index + create (+ edit nếu record-rule) — ref `sixmen-qa` § Filament 4 Pest
- [ ] Filament form validation: Livewire unhappy (`set('data.*')`, không `fillForm`)
- [ ] Không IDOR (user A không xem/sửa data user B)
- [ ] FormRequest validate đủ field
- [ ] Không expose sensitive field trong API response

## Post-feature scan *(trước PR / xin review)*

| Lớp | Công cụ | Kết quả | Pass? |
|-----|---------|---------|-------|
| Detect — Codacy | `codacy.mdc` / MCP | | |
| Detect — Trivy *(nếu đổi deps)* | Codacy `tool: trivy` | | |
| Detect — Lint | `pint` · `phpstan` · `pest` | | |
| Verify — Envelope | `architecture-compliance-checklist.md` | | |
| Verify — Architecture tests | `tests/Architecture/` *(nếu có)* | | |

**P0 fail** → block review. Codacy không có → ghi fallback; vẫn bắt checklist + Pest P0.

## Kết quả

| ID | Pass / Fail | Ghi chú |
|----|-------------|---------|
| | | |
