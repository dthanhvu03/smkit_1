# Senior rubric + role playbooks — the hiring bar (design)

> Ngày: 2026-07-14 · Ref: [research §3 role analysis](../research/2026-07-11-roles-rules-skills-architecture.md) · [ADR-004](../adr/ADR-004-roles-rules-skills-separation.md)
> Trạng thái: **P0 done.** Trụ cột #3.

## Vấn đề
Người dùng ví KIT như công ty: mỗi role/skill phải đạt **chuẩn senior** — "như tuyển nhân viên, phải biết có đáp ứng vị trí không". Nhưng thân các role cũ chỉ 1–3 dòng prose, không trả lời được: nhận task **làm gì đầu tiên**, **xử lý ra sao**, **kiểm chứng thế nào**, **done khi nào**. doctor cũ chỉ kiểm *cấu trúc* (tên, độ dài description, trust tier), không kiểm *độ chín*.

## Hai phần
1. **Rubric doctor (hiring bar)** — biến "đủ tầm senior chưa?" thành tiêu chí kiểm được. Thân một role phải thể hiện 3 chiều (heuristic, đa ngôn ngữ, mức WARN — cùng triết lý với check trigger-weak sẵn có):
   - **First move** — nhận task làm gì đầu tiên.
   - **Boundary / hand-off** — ranh giới & tách vai (không tự plan+code+review công việc của mình — đúng anti-pattern ADR-004 §15).
   - **Verification / done** — kiểm chứng chất lượng / định nghĩa "done".
   Thiếu chiều nào → `ROLE_SENIORITY_INCOMPLETE` (WARN, không chặn build). Logic: `SENIORITY_CUES` + `seniorityGaps()` trong emitter, nối vào `validateRoleGovernance`.
2. **Nâng thân 7 role** (orchestrator/planner/architect/implementer/reviewer/qa/devops) thành playbook senior thật, đạt cả 3 chiều, **giữ nguyên frontmatter** (name/description/tools/model → delegation & quyền không đổi) và giữ tách vai. `analyst` đã đạt sẵn.

## Vì sao WARN chứ không ERROR
Đây là heuristic prose-cue (không phải LLM lúc build) — có thể false-positive. Nó nâng **sàn** (role không có first-move/boundary/done thì chắc chắn chưa senior), không phán tuyệt đối. Test `validateRoleGovernance(KIT_ROOT)` = 0 warning ép chính kit phải đạt bar của mình.

## Giới hạn thành thật
- Cue-based nên nông: đạt cue ≠ nội dung hay. Nó chặn cái *thiếu*, không đảm bảo cái *hay*.
- Chỉ áp cho **role** đợt này. Skill đã có governance cấu trúc (description ≤1024, output-format, trigger, trust tier) — rubric skill riêng để sau nếu cần.

## Bằng chứng
`npm test` 106/106 (thêm test rubric *fires* trên body mỏng + test 8 role shipped = 0 warning) · golden regenerate (7 file `.claude/agents/*.md`, số lượng file không đổi) · `doctor` 0 error/0 warning.
