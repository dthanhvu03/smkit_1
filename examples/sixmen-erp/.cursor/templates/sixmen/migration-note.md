# Migration Note — SIXMEN ERP

| Field | Value |
|-------|-------|
| Migration file | `database/migrations/YYYY_MM_DD_HHMMSS_*.php` |
| Task ID | |
| Author | AI Database / Backend |
| Ngày | |
| ERD canonical | GĐ0 / GĐ1 path + section |

> **Scope:** File này chỉ chứa DB-level content (schema, constraints, SQL, rollback).  
> PHP Enum/`$casts`/FormRequest/service code → **không viết ở đây** → thuộc `03-architecture-impact.md`.  
> Human Owner đọc file này để approve schema — không nên đọc PHP application code.

## Mục đích

[Mô tả thay đổi schema]

## Thay đổi chi tiết

### Bảng mới

| Bảng | Cột chính | Index / Constraint |
|------|-----------|-------------------|
| | | |

### Bảng sửa

| Bảng | Thay đổi | Nullable? | Default | Backfill? |
|------|----------|-----------|---------|-----------|
| | | | | |

### Bảng xóa

| Bảng | Lý do | Data migration trước? |
|------|-------|----------------------|
| | | |

## Constraints / indexes / FK

| Bảng | Constraint / index / FK | Mục đích | onDelete / onUpdate | Lock risk |
|------|--------------------------|----------|----------------------|-----------|
| | UNIQUE / CHECK / FK / partial index | | | |

## Scope / tenancy keys

| Entity | branch_id | legal_entity_id | warehouse_id | Ghi chú CTY/HKD |
|--------|-----------|-----------------|--------------|-----------------|
| | Có / Không | Có / Không | Có / Không | |

## Query pattern / index rationale

| Query / màn hình / report | Columns filter/sort | Index đề xuất | Loại index |
|---------------------------|---------------------|---------------|------------|
| | | | B-tree / partial / GIN / GiST |

## Backward compatibility

- Cột/API cũ giữ nguyên: Có / Không
- Alias / adapter cần: 

## Zero-downtime / backfill plan

1. Add nullable/default-safe column or constraint in safe mode:
2. Backfill batch / staging rehearsal:
3. Enforce NOT NULL / CHECK / FK:
4. Cutover / adapter removal:

## Rollback

```bash
php artisan migrate:rollback --step=1
```

Rủi ro rollback: 

Down migration safety:
- [ ] Reversible without data loss
- [ ] Non-reversible — reason + backup/PITR path:
- [ ] Manual rollback SQL/runbook:

## Chạy an toàn

- [ ] Chạy trên staging trước
- [ ] Backup DB trước prod
- [ ] DRY_RUN / copy sheet trước (nếu có data migration)
- [ ] Lock timeout / statement timeout reviewed
- [ ] Large table backfill batch plan reviewed
- [ ] Human Owner đã duyệt

## Dữ liệu seed / master

| Entity | Quy tắc chuẩn hóa |
|--------|-------------------|
| SKU | `product_variants.sku` unique — `variant.code` deprecated |
| Màu / Size | Theo `docs/erp/core/01_Master_Decisions.md` |
| Kho | `warehouse_id`, `legal_entity_id` |
