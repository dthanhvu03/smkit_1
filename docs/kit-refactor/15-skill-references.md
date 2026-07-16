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

## Đã nhân rộng (4 skill)
- ✅ `code-review` → `references/review-guide.md` (deep-research; verify chưa hoàn tất do session-limit).
- ✅ `security-review` → `references/security-guide.md` — STRIDE + OWASP Top 10 2021 + CWE Top 25 + ASVS.
- ✅ `test-design` → `references/test-guide.md` — equivalence/boundary/decision-table/state/pairwise/property-based + test pyramid + coverage caveat (ISTQB, Myers, NIST, Hypothesis, Fowler).
- ✅ `refactor` → `references/refactor-guide.md` — "small steps under green tests", characterization tests, smell→refactoring catalog (Fowler, Feathers).

3 cái sau **ground trực tiếp vào nguồn kinh điển có trích URL** (không chạy lại deep-research trong lúc verify-layer kẹt session-limit + để tiết kiệm ~1.7M token). Mỗi reference ghi rõ caveat verify.

## Verify (2026-07-16)
`deep-research` (fan-out 99 agent) **kẹt account session-limit** — resume cũng re-fail, dừng để không phí token. Thay bằng **WebFetch tuần tự tự kiểm** (ít burst → lách được limit): xác nhận **khớp verbatim** với nguồn primary: OWASP Top 10:2021 (owasp.org), SemVer (semver.org), Keep a Changelog (keepachangelog.com), Google eng-practices aspects+Nit (google.github.io), SmartBear/Cisco 200–400 LOC/<500 LOC-h/<60ph, Fowler behavior-preserving+small-steps (refactoring.com). → Provenance note của **code-review, security-review, refactor, release-check** nâng thành **"đã verify against source"**. `test-design`/`guard-design`/`decision-brief` giữ note "chưa fetch-verify riêng" (framework textbook chuẩn: ISTQB/OWASP fail-securely/JTBD…).

Skill T0 nên không cần contentHash; nếu sau này pin T3/T4 thì cập nhật hash sau khi thêm references.
