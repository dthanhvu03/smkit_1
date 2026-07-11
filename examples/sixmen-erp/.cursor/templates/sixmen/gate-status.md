# Gate Status — SIXMEN ERP

| Field | Value |
|-------|-------|
| Task ID | |
| Artifact folder | `artifacts/{Task-ID}/` |
| Phase | GĐ 0 / GĐ 1 / … |
| Task type | `code` / `docs-only` |
| Cập nhật lần cuối | |

> Agent **cập nhật file này** sau mỗi bước. Human Owner đọc file này để biết task đang ở đâu.

---

## Current Step

- [ ] 0. Read scope
- [ ] 1. IT Manager — task-brief ← CURRENT
- [ ] 2. BA — acceptance-criteria
- [ ] 3. Architect → GATE
- [ ] 4. Database → GATE
- [ ] 5. Backend / Frontend — implement
- [ ] 6. QA → qa_gate
- [ ] 7. DevOps → GATE (nếu deploy)

**Cập nhật:** Tick `[x]` khi xong bước, dời `← CURRENT` sang bước tiếp.

---

## Workflow steps (chi tiết)

| Bước | Artifact | Status | Ghi chú |
|------|----------|--------|---------|
| 0 | `00-gate-status.md` | `NOT_STARTED` / `IN_PROGRESS` / `DONE` | File này |
| 1 | `01-task-brief.md` | | |
| 2 | `02-acceptance-criteria.md` | `N/A` / … | Nếu feature nghiệp vụ |
| 3 | `03-architecture-impact.md` | `N/A` / `PENDING_HO` / `APPROVED` | Trước code nếu logic/DB/quyền |
| 4 | `04-migration-note.md` | `N/A` / `PENDING_HO` / `APPROVED` | Trước DDL nếu schema |
| 5 | Implement | | Backend / Frontend — list PR hoặc file chính |
| 6 | `05-impact-risk-rollback.md` | `N/A` / `DONE` | Nếu đụng data |
| 7 | `06-test-plan.md` | `N/A` / `FAIL` / `PASS` | Post-feature gate |
| 8 | `07-architecture-compliance-checklist.md` | `N/A` / `FAIL` / `PASS` | Trước review/PR |
| 9 | `08-release-checklist.md` | `N/A` / … | Nếu deploy |

**Status values:** `NOT_STARTED` · `IN_PROGRESS` · `DONE` · `PASS` · `FAIL` · `N/A` · `PENDING_HO` · `APPROVED` · `BLOCKED`

---

## Human Owner gates *(từ task-brief)*

| Gate | Owner | Status | Ngày / evidence |
|------|-------|--------|-----------------|
| Đổi schema | Vũ | `N/A` / `PENDING` / `APPROVED` | |
| Đổi business rule | Khanh + QLVH | | |
| ≥2 module | Vũ | | |
| Permission matrix | QLVH | | |
| Data delete/purge | Human Owner | | |
| Production deploy | Vũ + Khanh | | |

---

## QA post-feature gate *(code task)*

| Kiểm tra | Kết quả | Ghi chú |
|----------|---------|---------|
| Codacy / lint | `PASS` / `FAIL` / `SKIP` | Lý do nếu SKIP |
| Pest / tests | | |
| Compliance checklist | | |
| **qa_gate tổng** | `NOT_RUN` / `PASS` / `FAIL` | **FAIL → không xin review** |

---

## Review readiness

- [ ] `01-task-brief.md` hoàn chỉnh
- [ ] DoD trong brief đo được + có evidence/owner
- [ ] IN/OUT + module chính rõ; nếu ≥2 module thì gate đã đánh dấu
- [ ] Artifacts bắt buộc theo task type đã có
- [ ] `qa_gate: PASS` *(hoặc N/A docs-only)*
- [ ] Không còn Human Owner gate `PENDING` *(trừ khi chủ đích dừng chờ duyệt)*
- [ ] **Sẵn sàng xin review Human Owner**

**Agent stop:** nếu bất kỳ mục trên chưa đạt — **không** tuyên bố task hoàn thành.
