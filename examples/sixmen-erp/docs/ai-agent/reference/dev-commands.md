# Dev Commands — SIXMEN ERP

> **Path:** `docs/ai-agent/reference/dev-commands.md`
> Cheat-sheet câu lệnh dev hằng ngày. Chạy ở root repo `/home/zusem/sixmen-erp`.
> Quy ước: artisan/PHP qua container `app`; DB qua container `postgres`.

## Thông số môi trường

| Thành phần | Giá trị |
|------------|---------|
| Container app (PHP-FPM) | `sixmen_app` |
| Container DB | `sixmen_postgres` |
| Container khác | `sixmen_nginx` · `sixmen_redis` · `sixmen_horizon` · `sixmen_reverb` |
| DB name / user | `sixmen_erp` / `sixmen_app` |
| Web URL | http://localhost:8000 |
| Reverb (websocket) | cổng 8080 |

---

## 1. Khởi động / tắt hệ thống (Docker)

```bash
docker compose up -d           # Bật toàn bộ stack
docker compose ps              # Xem container đang chạy / health
docker compose stop            # Tắt (giữ container + data)
docker compose down            # Tắt + xóa container (data DB vẫn ở volume)
docker compose restart app     # Restart riêng 1 service
docker compose logs -f app     # Log realtime 1 service
```

## 2. Database (migrate / seed)

```bash
docker compose exec app php artisan migrate --seed     # Migrate pending + seed — AN TOÀN, hằng ngày
docker compose exec app php artisan migrate            # Chỉ migrate
docker compose exec app php artisan migrate:status     # Migration nào đã/chưa chạy
docker compose exec app php artisan db:seed            # Chỉ seed
docker compose exec app php artisan migrate:rollback   # Lùi batch gần nhất

# ⚠️ DEV ONLY — drop sạch toàn bộ bảng rồi dựng lại:
docker compose exec app php artisan migrate:fresh --seed
```

> ⚠️ **LUẬT CỨNG #6 / data-safety:** `migrate:fresh` xóa toàn bộ data. **KHÔNG** chạy trên staging/prod khi chưa có Human Owner duyệt + backup.

## 3. Vào shell / truy vấn DB trực tiếp

```bash
docker compose exec app bash                                   # Shell container app
docker compose exec app php artisan tinker                     # REPL Laravel
docker compose exec postgres psql -U sixmen_app -d sixmen_erp  # psql trực tiếp
# Trong psql: \dt = list bảng · \d ten_bang = mô tả · \q = thoát
```

## 4. Cache / config (sau khi đổi .env, route, config)

```bash
docker compose exec app php artisan optimize:clear   # Xóa sạch mọi cache
docker compose exec app php artisan config:clear
docker compose exec app php artisan route:clear
docker compose exec app php artisan view:clear
```

## 5. Filament / Permission (Shield)

```bash
docker compose exec app php artisan make:filament-user        # Tạo user admin panel
docker compose exec app php artisan shield:generate --all     # Sinh permission mọi Resource
docker compose exec app php artisan shield:super-admin        # Gán super-admin cho 1 user
```

## 6. QA Gate (bắt buộc trước PR — `@sixmen-qa`)

```bash
docker compose exec app ./vendor/bin/pint              # Format code (Pint)
docker compose exec app ./vendor/bin/pint --test       # Chỉ kiểm tra
docker compose exec app ./vendor/bin/phpstan analyse   # Static analysis
docker compose exec app ./vendor/bin/pest              # Chạy test
docker compose exec app ./vendor/bin/pest --filter=TenTest   # Chạy 1 test
```

## 7. Queue / Horizon / Log

```bash
docker compose logs -f horizon                       # Log job queue
docker compose exec app php artisan horizon:status
docker compose exec app php artisan queue:retry all   # Retry job failed
docker compose exec app php artisan pail              # Tail log realtime
```

## 8. Frontend assets (Vite / Tailwind)

```bash
docker compose exec app yarn install   # Cài deps JS
docker compose exec app yarn dev       # Dev mode (watch)
docker compose exec app yarn build     # Build production assets
```
