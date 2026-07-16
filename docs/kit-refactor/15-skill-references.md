# Enriching skills with research-backed `references/` (code-review pilot)

> Ngày: 2026-07-15 · Ref: [12 senior rubric](12-senior-rubric-design.md) · Agent Skills open standard (scripts/references/assets)
> Trạng thái: pilot xong cho `code-review`.

## Vấn đề
Chất lượng code cuối phụ thuộc **AI nền + người kiểm** — hai thứ ta không đổi được. Thứ **ta kiểm soát** là **chất lượng chỉ dẫn** trong roles/rules/skills. Skill hiện tại đúng *khung* (Workflow + Output format) nhưng **nông chuyên môn**: nói "security smells", "edge cases" mà chưa có taxonomy/checklist/rubric cụ thể.

## Cách làm — progressive disclosure, không phình context
Agent Skills standard hỗ trợ `skills/<id>/references/*.md`, nạp **theo nhu cầu lúc thực thi**. Kit đã emit sẵn supporting files sang `.claude/skills/<id>/references/` và `.agents/skills/<id>/references/`. Nên:
- **SKILL.md**: giữ gọn (luôn tải) — workflow + trỏ tới reference.
- **`references/`**: nội dung sâu, **có trích nguồn** — chỉ tốn token khi skill thực thi.

## Pilot: `code-review`
- Chạy skill **deep-research** (fan-out nhiều nguồn → fetch → verify → tổng hợp) trên "senior code review best practices".
- Chưng cất thành `engine/skills/code-review/references/review-guide.md`: (1) thứ tự ưu tiên soát (Google: design > functionality > complexity > tests …); (2) **defect taxonomy** (logic/boundary/null/interface/concurrency/resource/perf/security); (3) **security checklist theo OWASP Top 10 2021** (A01 access-control trước); (4) **substance-over-style** (không block vì style — linter sở hữu); (5) **rubric severity** blocker/major/minor/nit; (6) giới hạn hiệu quả (SmartBear/Cisco: 200–400 LOC, <60ph, <300–500 LOC/h).
- Siết `SKILL.md`: workflow trỏ tới reference, ép severity ∈ {blocker,major,minor,nit}, thêm "review theo chunk cho diff lớn".

## Trung thực về nguồn
Các con số/thứ hạng đến từ nguồn **uy tín** (Google eng-practices, OWASP, SmartBear/Cisco). Lớp **verify đối kháng tự động của deep-research KHÔNG hoàn tất** (chạm API session-limit) — nên reference **ghi rõ caveat** + liệt kê URL để kiểm lại. Đây là dữ liệu well-established, không bịa; nhưng không giả vờ đã verify xong.

## Bằng chứng
Reference emit sang `.claude/` + `.agents/` (progressive disclosure) · golden regenerate · `doctor` 0 error/0 warning · 106/106 test.

## Bước sau (nếu nhân rộng)
Cùng cách cho `security-review` (OWASP sâu + threat modeling), `test-design` (boundary-value/equivalence/property-based), `refactor` (catalog Fowler + characterization test). Mỗi cái: deep-research → `references/` có nguồn → siết SKILL.md. Nếu là skill T3/T4 thì nhớ cập nhật contentHash (T0 không cần).
