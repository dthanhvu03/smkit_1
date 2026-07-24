# Cách dùng kit — 1 trang (user playbook)

Dành cho founder / người không code. **Không cần nhớ hết lệnh** — nói mục tiêu bằng tiếng thường; agent sẽ đề xuất lệnh và hỏi xác nhận.

Mode mặc định: **`strict`** (gate đầy đủ; schema / prod / data cần người duyệt).

---

## 5 lệnh đủ dùng

| Khi anh muốn… | Lệnh | Anh làm gì |
|---------------|------|------------|
| Lần đầu / AI chưa hiểu dự án | `/onboard` | Đọc draft constitution → sửa → confirm |
| “Có đáng làm không? Làm slice nào?” | Nói ý tưởng → **`smart-value`** rồi `/discover` | Chọn option + slice; ghi câu hỏi chỉ anh trả lời được |
| Làm cả feature A→Z | `/ship` | Duyệt checkpoint; approve schema/prod/data nếu hỏi |
| Xong — xem có an toàn để nhận | `/handoff` | Đọc tiếng thường: làm gì · bằng chứng · rollback · cần duyệt gì |
| Việc nhỏ / sửa tiếp | `/start` | Confirm bước nhỏ rồi để agent làm |

Lệnh khác (`/challenge`, `/task`, `/review`…) — agent tự kéo vào khi cần; anh không phải học trước.

---

## Cách nói chuyện với agent (mẫu)

**Tốt**
- “Mỗi tuần kho mất ~3 giờ đếm lại — muốn giảm còn dưới 1 giờ trong 1 tháng.”
- “Khách bỏ giỏ ở bước thanh toán ~40% — giảm ma sát đăng ký, ưu tiên học nhanh.”
- “Không được xóa dữ liệu tồn trên production.”

**Tránh**
- “Viết giúp cái dashboard đẹp.” (thiếu outcome)
- “Làm hết module kho.” (quá lớn — bắt chia slice)
- “Cứ merge đi.” khi handoff còn gate đỏ

---

## Việc anh **phải** dừng và duyệt

Agent **không** được tự coi là đã duyệt khi:

- Đổi schema / migration  
- Deploy production  
- Xóa / purge / ghi đè dữ liệu thật  
- Đổi rule tiền / tồn / quyền

→ Đọc `/handoff` hoặc migration note → **Approve / Reject / hỏi thêm**.

---

## Checklist trước khi nói “xong”

- [ ] Handoff có **bằng chứng** (test/command), không chỉ “đã xong”
- [ ] Acceptance criteria đã tick đúng phần đạt
- [ ] Biết **rollback** nếu sai
- [ ] Không còn gate đỏ / PENDING approval

---

## Bài tập (Week 2)

1. `/onboard` (nếu constitution còn trống)  
2. Một ý tưởng → `/discover` (có `smart-value`) → chọn slice  
3. `/ship` slice đó (hoặc `/start` nếu rất nhỏ)  
4. Đọc `/handoff` và quyết định approve / chỉnh  

Chi tiết khóa học: [founder-curriculum.md](founder-curriculum.md).
