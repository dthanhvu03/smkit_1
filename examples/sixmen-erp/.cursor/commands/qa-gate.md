# QA gate — sau implement, trước PR

Read `.cursor/skills/sixmen-qa/SKILL.md`.

Post-feature gate cho task hiện tại:

1. Xác định Task-ID (PROGRESS 🔄 hoặc anh cung cấp)
2. Chạy: Pint · architecture-lint · Pest (docker nếu có)
3. Cập nhật `artifacts/{Task-ID}/06-test-plan.md` + `07-architecture-compliance-checklist.md`
4. Tick `00-gate-status.md` — `qa_gate: PASS` hoặc FAIL
5. Chạy: `bash .cursor/bootstrap/validate-artifacts.sh -t {Task-ID} -s`

P0 fail → **block review**. Báo checklist PASS/FAIL rõ ràng.
