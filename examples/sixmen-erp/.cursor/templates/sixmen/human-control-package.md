# Template — Human-control package (HO 2026-06-26)

> Mục tiêu: human kiểm soát **code · nghiệp vụ · business flow** mà KHÔNG đọc code.
> Áp cho task `code` chạm nghiệp vụ/tồn/tiền. Pilot: `artifacts/TASK-GD1-003/`.
> Nguyên tắc: CI xanh = code làm đúng test; **walkthrough + demo = test làm đúng nghiệp vụ** (chỉ human đóng được mắt xích này).

---

## 1. `business-walkthrough.md` (Khanh-facing — duyệt TRƯỚC merge)

```markdown
# Business Walkthrough — <Tên tính năng> (TASK-...)
> Dành cho <chủ nghiệp vụ> duyệt. Tiếng Việt + số cụ thể — không cần đọc code.

## 1. Chức năng này làm gì (1 câu)
## 2. Đơn vị / dữ liệu chính
## 3. Luồng chuẩn — bảng ví dụ SỐ CỤ THỂ (trước → thao tác → sau)
## 4. Quy tắc nghiệp vụ R1..Rn — cột "Đúng thực tế? ☐" để chủ nghiệp vụ tick
## 5. Chưa làm giai đoạn này (cố ý)
## 6. Cách tự kiểm chứng (1 lệnh test / demo)
## Ký duyệt: [ ] <Tên> xác nhận R1..Rn — ngày ____ · Sai/bổ sung: ____
```

## 2. `demo-<feature>.php` (chạy in số, tự rollback — "thấy nó chạy")

- Wrap `DB::beginTransaction()` … `finally { DB::rollBack(); }` → KHÔNG bẩn data.
- Tự dựng fixture + bật module cần thiết (dọn cache ở `finally`).
- `echo` trace số sau mỗi bước + chứng minh các rule chặn (R1/R2…).
- Chạy: `docker compose exec -T app php artisan tinker --execute="require base_path('artifacts/<TASK>/demo-<feature>.php');"`

## 3. Traceability matrix (trong `09-handoff-summary.md`)

| Rule (walkthrough) | AC | Test xanh | Code (file/method) |
|--------------------|----|-----------|--------------------|
| R1 … | AC-x | TC-… | … |

## 4. `09-handoff-summary.md` — 2-view (Markdown, KHÔNG HTML — tốn 4–5× token)

```markdown
# Handoff Summary — TASK-...
## Vận hành: Bài toán · Đã giao · Sau deploy
## Kỹ thuật: bảng path · PR/Pest/PHPStan · Demo command · Traceability · Independent review · Follow-up
```

## 5. Independent review (pre-merge — CHỈ code tiền/tồn/đồng-thời)

Lượt rà adversarial riêng (không phải lượt viết code) → ghi checklist ✅/⚠️ trong `09`:
guard âm trước DB CHECK · write ngoài/trong TX đúng · không che lỗi (SQLSTATE mapping) · lock/concurrency · residual cho HO.

---

**Gate:** Khanh duyệt `business-walkthrough` (R1..Rn) **trước khi xin merge** — ngang Vũ duyệt schema.
