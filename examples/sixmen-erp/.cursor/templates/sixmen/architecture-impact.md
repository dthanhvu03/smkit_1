# Architecture Impact — SIXMEN ERP

| Field | Value |
|-------|-------|
| Task ID | |
| Architect | AI Solution Architect |
| Ngày | |

## Tóm tắt

[1–2 câu: thay đổi gì, tại sao cách này ít rủi ro]

## Module boundary

| Module | IN / OUT | Lý do |
|--------|----------|-------|
| | | |

## Bounded context / ownership

| Thành phần | Owner | Public interface | Consumer |
|------------|-------|------------------|----------|
| Bảng / Entity | | Service / Event / Contract | |

> Cross-module chỉ qua public Service/Event/Contract đã nêu ở đây; không query/update thẳng bảng nội bộ module khác.

## Database impact

> Schema canonical: GĐ0 `docs/erp/phases/GD0_Nen_tang/ERD.md` · GĐ1 `docs/erp/phases/GD1_Kho_SX/ERD.md` — `docs/erp/core/03_SRS.md` §3 DDL deprecated nếu lệch ERD.

| Bảng / Entity | Thay đổi | Migration? |
|---------------|----------|------------|
| | | |

## API impact

| Endpoint / Contract | Breaking? | Ghi chú |
|---------------------|-----------|---------|
| | | |

## Service / transaction / reporting

| Mục | Quyết định |
|-----|------------|
| Service write chính | |
| Input contract | Plain PHP DTO / command |
| Success return | Eloquent Model / Collection / other |
| Domain exception | 422 / 409 mapping |
| Transaction scope | |
| Locking / constraint / idempotency | |
| Reporting connection | `pgsql` / `pgsql_reporting` / `force_primary` |

## Permission / scope

| Scope | Cần xử lý? | Ghi chú |
|-------|------------|---------|
| RBAC / permission | | |
| CTY/HKD | | |
| Branch | | |
| Legal entity | | |
| Warehouse | | |

## Phương án triển khai (ít rủi ro)

1. 
2. 

## Risk / rollback / test expectation

| Mục | Nội dung |
|-----|----------|
| Rủi ro chính | |
| Rollback / fallback | |
| Backend tests expected | Happy path · 403 · 422/409 nếu API/domain conflict |
| QA focus | |

## Phương án loại bỏ

| Phương án | Lý do không chọn |
|-----------|------------------|
| | |

## Phụ thuộc

- 

## Cần Human Owner duyệt

- [ ] Schema change
- [ ] API contract change
- [ ] State machine / business rule change
- [ ] Cross-module / ownership change
