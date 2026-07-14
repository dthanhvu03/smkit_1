# Business front-end — vague request → decision brief (design)

> Ngày: 2026-07-14 · Ref: [ADR-004](../adr/ADR-004-roles-rules-skills-separation.md) · research [roles-rules-skills-architecture](../research/2026-07-11-roles-rules-skills-architecture.md) §13 composition
> Trạng thái: **P0 design.** Đối tượng: founder non-tech, yêu cầu mơ hồ.

## Vấn đề đang giải
KIT hiện tại nhảy thẳng từ "câu người dùng" → plan → code (`/start`). Với một founder non-tech nói mơ hồ, bước quý nhất bị thiếu: **biến câu mơ hồ thành thông tin đáng tiền để họ QUYẾT ĐỊNH trước khi bỏ tiền code**. Không có vai trò phân tích business, không có brief quyết định, không estimate, không "viết docs làm rõ task".

## Nguyên tắc thiết kế (và giới hạn thành thật)
1. **KIT chỉ sinh file tĩnh; hành vi do AI đích chạy.** File markdown là *hướng dẫn*, không ép được. Chỉ hook/CI mới ép cứng. → Business front-end là **guidance mạnh + output-contract có evidence-gate**, không phải cổng cứng (đúng bản chất: đây là bước tư duy, không phải bước chặn lệnh nguy hiểm).
2. **Ceremony phải scale theo `mode`** để không tự làm phình context: `vibe` = brief 3–5 câu inline; `standard` = brief đầy đủ; `strict` = brief đầy đủ + cần founder ký duyệt trước khi build.
3. **Tách vai đúng ADR-004** (không có siêu-role tự làm hết): Business discovery là vai *riêng*, khác planner (chia bước) và architect (cấu trúc).

## Ba mảnh, compose theo §13
```
/discover (command, manual)  ──▶  analyst (role, WHO)  ──▶  decision-brief (skill, PROCEDURE + output)
```
- **Role `analyst`** — Business Analyst/Product. Read-only (Read/Grep/Glob), model=opus (việc phán đoán cao). Playbook cấp senior: nhận yêu cầu mơ hồ thì làm gì đầu tiên, tra vấn qua lăng kính nào, khi nào DỪNG hỏi founder bằng ngôn ngữ thường, bàn giao cho planner/architect.
- **Skill `decision-brief`** (T0, read-only, implicit+manual) — chốt **Output format bắt buộc**: Vấn đề thật · Người dùng & job-to-be-done · Phương án (2–3) + trade-off · Effort/chi phí/rủi ro (ước lượng thô, có nhãn "ước lượng") · Lát cắt nhỏ nhất để học · Câu hỏi cần founder quyết · Khuyến nghị + tiêu chí "done". Evidence-gate áp dụng (mục trống = chưa đạt).
- **Command `/discover [ý tưởng]`** — cửa vào: chạy analyst → sinh decision-brief → checkpoint với founder bằng ngôn ngữ thường *trước khi* build.

## Nối vào luồng hiện có
- `orchestrator`: yêu cầu mơ hồ/mới → chặng đầu là analyst discovery, không nhảy thẳng vào code.
- `/start`: thêm bước discovery scale theo mode (vibe gọn / standard-strict đầy đủ). **Không đụng hard-rules** (giữ always-on context nhẹ — kỷ luật token).

## Không làm ở P0 (để P1+)
- Estimate có cấu trúc/máy đọc được (giờ chỉ là ước lượng thô trong brief).
- Vòng lặp "phòng ban trao đổi liên tục" (analyst↔planner↔architect hội tụ) — trụ cột riêng.
- Cổng phản biện đa-lăng-kính *có hook chặn* trước khi build — trụ cột riêng.
- Rubric doctor kiểm tra "role đủ tầm senior chưa" — trụ cột riêng.

## Bằng chứng phải đạt trước khi coi là xong
`npm test` xanh · `doctor` 0 error trên repo · `check` in-sync · golden regenerate trong đúng 1 commit có review · role/skill mới qua governance (trigger cue, độ dài description, trust tier).
