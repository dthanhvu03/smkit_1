# Release Checklist — SIXMEN ERP

| Field | Value |
|-------|-------|
| Task ID | |
| Môi trường | local / staging / production |
| DevOps | AI DevOps |
| Ngày | |
| Commit SHA / image tag | |

## Pre-release

- [ ] Test plan pass
- [ ] CI gates pass: Pint · PHPStan · Pest · architecture-lint
- [ ] Migration note đã review
- [ ] Impact/risk/rollback đã ký Human Owner (nếu đụng data)
- [ ] `.env` staging/prod đúng (DB, Redis, queue)
- [ ] `composer install --no-dev` (prod)
- [ ] `php artisan config:cache` / `route:cache` (prod)

## Migration safety

- [ ] Backup DB trước migrate prod
- [ ] Backup path / object key: 
- [ ] PITR point / restore command documented
- [ ] Chạy migrate staging trước
- [ ] `php artisan migrate --pretend` (nếu hỗ trợ)
- [ ] Rollback script đã test trên staging
- [ ] App DB user **không** phải superuser (`sixmen_app`)
- [ ] Lock risk reviewed (`lock_timeout`, `statement_timeout`, batch size nếu cần)

## DB users & reporting

- [ ] `sixmen_app` / `sixmen_report` / `sixmen_migration` / `sixmen_maintenance` đúng vai trò
- [ ] `DB_REPORT_CONNECTION=pgsql_reporting` (MVP có thể trỏ primary host)
- [ ] App / queue / scheduler không dùng `postgres` hoặc DB owner
- [ ] Mutation / transaction / `FOR UPDATE` không chạy trên `pgsql_reporting`

## Queue / Cache / Log

- [ ] Horizon / queue worker chạy
- [ ] `php artisan horizon:terminate` hoặc worker reload an toàn sau deploy
- [ ] Failed jobs = 0 hoặc đã có triage
- [ ] Redis kết nối OK
- [ ] Log channel ghi đủ (activity, error)
- [ ] Request timing log có `request_id`, `duration_ms`, `db_query_count`, `db_time_ms`, `memory_peak_mb`

## Deploy steps

1. 
2. 
3. 

## Post-release verify

- [ ] Health check / login OK
- [ ] Smoke test feature chính
- [ ] Không spike error log 15 phút đầu
- [ ] Horizon/queue healthy sau deploy
- [ ] Không spike 5xx / slow query / failed jobs trong 15 phút đầu

## Rollback (nếu fail)

1. 
2. Code rollback command / image tag: 
3. DB restore / PITR command (nếu cần): 
4. Human Owner thông báo: 

## Human Owner approval (production)

- [ ] Đã duyệt deploy production
