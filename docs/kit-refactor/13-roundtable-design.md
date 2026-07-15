# Bounded roundtable — phòng ban trao đổi tới khi hội tụ (design)

> Ngày: 2026-07-14 · Ref: [research §13 composition](../research/2026-07-11-roles-rules-skills-architecture.md) · [12 senior rubric](12-senior-rubric-design.md)
> Trạng thái: **P0 done.** Trụ cột #4 (cuối).

## Vấn đề
Người dùng muốn các "phòng ban" **trao đổi liên tục** để ra output đúng tiêu chí, thay vì orchestrator dispatch một chiều rồi thôi.

## Căng thẳng phải quản (quan trọng nhất ở trụ cột này)
"Trao đổi liên tục" **không giới hạn** = tự bơm phồng context = gây lại đúng bệnh bypass mà #2 vừa trị. Nên "cho chuẩn" ở đây = **có kỷ luật**, không phải càng nhiều vòng càng tốt:
- **Bounded**: cap số vòng theo mode — `vibe` bỏ qua (một lượt), `standard` ≤2 vòng, `strict` ≤3 vòng.
- **Converge-or-escalate**: hết cap mà chưa đồng thuận → orchestrator quyết hoặc **leo thang cho founder** bằng ngôn ngữ thường; KHÔNG lặp vô hạn.
- **Kết luận cô đọng**: mỗi role đóng góp **một dòng/vòng**, không phải transcript.
- **Tiêu chí trước**: không có acceptance criteria thì không họp — đi định nghĩa tiêu chí đã.

## Giới hạn thành thật
- **Không có hook ép cứng** cho #4 (khác #2). Việc lặp là hành vi runtime do AI chạy; kit chỉ *author protocol* (guidance). Không giả vờ có cổng chặn. Giá trị = protocol có kỷ luật + tách vai, được ghi vào Decision Log.
- Vì là guidance, tôi **không thêm always-on rule** cho nó (tránh phình context — đúng kỷ luật token). Protocol nằm trong skill + orchestrator.

## Ba mảnh
- **Skill `cross-review`** (T0) — protocol hội tụ có giới hạn: set tiêu chí → vòng (propose/challenge/revise, mỗi role một dòng) → converge hoặc escalate (cap theo mode) → ghi Decision Log. Output bắt buộc: acceptance criteria · round log · converged decision (hoặc escalation) · open items.
- **Command `/roundtable`** — cửa vào thủ công cho founder ("để đội hash ra quyết định rồi mới làm").
- **orchestrator** — thêm một dòng: thay đổi non-trivial/gây tranh cãi → chạy bounded roundtable với stop-conditions, không dispatch một chiều.

## Bằng chứng phải đạt
`npm test` xanh (skill 8→9) · golden regenerate 1 commit · `doctor` 0 error/0 warning · skill mới qua governance (trigger cue, ≤1024, output-format).
