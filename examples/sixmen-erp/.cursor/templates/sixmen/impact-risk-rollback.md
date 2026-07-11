# Impact / Risk / Rollback — SIXMEN ERP

| Field | Value |
|-------|-------|
| Task ID | |
| Ngày | |
| Ảnh hưởng data | Có / Không |

## Impact

| Hệ thống / Module | Mức độ | Mô tả |
|-------------------|--------|-------|
| | Thấp / TB / Cao | |

## Rủi ro

| Rủi ro | Xác suất | Tác động | Mitigation |
|--------|----------|----------|------------|
| | | | |

## Rollback plan

1. Code: `git revert <commit>` hoặc deploy tag trước
2. DB: `php artisan migrate:rollback --step=N` — **không** manual DELETE/TRUNCATE prod
3. Data correction: cancel / reversal / adjustment / exception — movement/audit **append-only** (`sixmen-data-safety.mdc`)
4. Cache/queue: `php artisan cache:clear` / restart Horizon
5. Thời gian ước tính rollback:

## Observability

| Log / Metric | Mục đích |
|--------------|----------|
| | |

## Human Owner sign-off

- [ ] Đã review impact
- [ ] Đã đồng ý rollback plan
