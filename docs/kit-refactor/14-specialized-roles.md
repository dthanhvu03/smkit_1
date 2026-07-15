# Specialized roles — db-admin, git-manager, docs-manager, debugger

> Ngày: 2026-07-14 · Ref: [12 senior rubric](12-senior-rubric-design.md) · so sánh AgentKit.best
> Trạng thái: done. Đóng khoảng cách "bề rộng role" so với các kit thương mại.

## Vấn đề
So với các kit thương mại (AgentKit.best…), mình mạnh về **an toàn/governance/enforcement + đa-IDE + front-end non-tech**, nhưng thiếu **bề rộng role dev chuyên biệt**. 4 vai phổ biến nhất còn thiếu: quản trị DB, quản lý git/PR, đồng bộ docs, và debug root-cause.

## Quyết định kiến trúc: generic engine roles, KHÔNG hardcode SIXMEN
4 role này là **chức năng dev phổ quát** (dự án nào cũng có DB, git, docs, bug) → đặt ở **engine-level**, giữ kit tái dùng được. Kiến thức **riêng SIXMEN** (PHP/MySQL, quy ước ERP, invariant tồn kho/đơn/PO) KHÔNG nhét vào role — nó thuộc về một **profile SIXMEN** (`profiles/<name>/`) hoặc `.kit/constitution.md`. Đây là điểm khác cốt lõi so với kit "đóng gói sẵn cho 1 stack": role senior chung + đặc thù dự án tách riêng.

## 4 role (đều qua rubric senior + governance)
| Role | model | tools | Sở hữu | Tách vai |
|---|---|---|---|---|
| **db-admin** | opus | +Edit/Write/Bash | schema, migration (reversible), index, query perf, toàn vẹn dữ liệu | cấu trúc chung → architect; code dùng data → implementer |
| **git-manager** | haiku | Bash | branch, commit conventional, PR hygiene, không force-push shared | viết code → implementer; review → reviewer |
| **docs-manager** | haiku | +Edit/Write | README/API/setup/usage docs khớp code | lý do quyết định → Decision Log; không sửa code |
| **debugger** | sonnet | Bash | reproduce → isolate → root-cause có bằng chứng | viết fix → implementer; xác nhận chạy → qa |

Mọi thao tác nguy hiểm (DB destructive, force-push) vẫn bị `guard-shell` chặn — role mới không nới guardrail.

## Cách thêm (rẻ nhờ kiến trúc)
Chỉ thả file `engine/roles/<name>.md`; generator tự quét → emit `.claude/agents/*.md` + index AGENTS.md cho 5 IDE, không sửa generator. `doctor` tự áp rubric senior + governance.

## Bước sau (chưa làm)
- **Profile SIXMEN** (php-mysql-erp): conventions PHP/MySQL, invariant nghiệp vụ, approvers. Đây mới là chỗ đặc thù SIXMEN.
- Skill/command đi kèm nếu cần (vd `/migrate`, skill `schema-review`).

## Bằng chứng
`validateRoleGovernance(KIT_ROOT)` = 0 error/0 warning (12 role đều qua rubric) · token-budget test 8→12 role · golden regenerate · doctor 0 error.
