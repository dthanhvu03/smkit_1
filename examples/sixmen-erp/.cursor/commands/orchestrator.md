# Orchestrator — task ERP mới / resume / điều phối (CI-mode)

> **Mục tiêu:** Anh chỉ cần `/orchestrator` (+ mô tả ngắn nếu có) — agent **bắt buộc** chạy ritual dưới đây như pipeline, **không** nhảy thẳng code.

> **Tầng đọc:** `AGENTS.md` (hub kit) → orchestrator SKILL (điều phối task) → `PROGRESS` + gate artifact. Rules `alwaysApply` **không thay** đọc `AGENTS.md` chủ động (skill § Context Preservation).

## Bước 0 — Orient (bắt buộc, chưa làm gì khác)

1. **Read** `AGENTS.md` — hub: routing skill · SoT index · artifact discipline · shared-memory loading rule · Kit Version.
2. **Read** `.cursor/skills/sixmen-orchestrator/SKILL.md` (workflow + Final check + Auto-update + Human-control package).
3. **Read** `artifacts/PROGRESS.md` — task `🔄` đang chạy (resume) hoặc xác định slot task mới.
4. **Resume vs task mới:**
   - **Resume** (`/orchestrator` không mô tả task mới) → bỏ qua tạo folder; đọc `00-gate-status.md` `← CURRENT`.
   - **Task mới** → **Verify Task-ID 3 nguồn** (`ls artifacts/` · `task-log-milestones.md` · brief refs) — **không tự đặt số**.
5. **Read** `artifacts/{Task-ID}/00-gate-status.md` + `01-task-brief.md` → tiếp từ `← CURRENT`.
6. **Read** `docs/ai-agent/reference/shared-memory.md` khi task chạm schema / workflow / data / critical service / permission (trigger `AGENTS.md` § Shared memory loading rule).
7. **Output đầu lượt (blocking):** `AGENTS.md` + files đã đọc · CURRENT step · gate PENDING (nếu có) · role tiếp theo · **chưa code** cho đến khi brief/gate cho phép bước đó.

## Bước 1 — Task mới (nếu không resume)

1. Tạo `artifacts/{Task-ID}/` + `00-gate-status.md` + `01-task-brief.md`
2. Gán Mốc Sheet (cột C) theo `task-log-milestones.md`
3. Route skill đúng vai — **cấm implement** trước brief

## Bước 2 — Trong lượt (theo gate CURRENT)

| Gate step | Agent làm | Artifact |
|-----------|-----------|----------|
| Brief | `@sixmen-it-manager` | `01` · `02` |
| Arch | `@sixmen-architect` | `03` |
| Schema | `@sixmen-database` + HO | `04` |
| Code | `@sixmen-backend` / `@sixmen-frontend` | implement |
| QA | `@sixmen-qa` | `06` · **`07-architecture-compliance-checklist.md`** |
| Review | self-review / adversarial | `07-review-findings` hoặc `09-*` |
| Merge | HO only | bước 7 gate |

**Human Owner PENDING** trên gate đã trigger → **STOP**, không báo "xong".

## Bước 3 — Kết lượt có thay đổi (CI gate — bắt buộc)

> Rule always-on: `.cursor/rules/sixmen-agent-closeout.mdc` — **cùng lượt** với code, không đợi HO nhắc.

Trước khi báo xong / commit / push:

```
[ ] 00-gate-status.md — tick bước xong · dời ← CURRENT · Review readiness sync
[ ] PROGRESS.md — dòng task khớp commit hash + test count
[ ] Code task: 06-test-plan qa_gate PASS + 07-architecture-compliance-checklist tick
[ ] KNOWN-ISSUES — append nếu lỗi >15' hoặc block luồng
[ ] bash .cursor/bootstrap/validate-artifacts.sh -t {Task-ID} -s  → phải PASS
[ ] docker/php artisan test (hoặc --filter scope) nếu đụng code
[ ] ./vendor/bin/pint --dirty + ./vendor/bin/phpstan analyse (pre-push hook chạy cả hai)
```

**Không push** nếu `validate-artifacts` FAIL hoặc `qa_gate` chưa PASS (code task).

## Bước 4 — Đóng task (sau HO merge)

- [ ] `09-handoff-summary.md`
- [ ] PROGRESS → `✅ DONE`
- [ ] gate bước 7 tick · `validate-task-log` nếu ghi Sheet

## Anh chỉ cần gõ

| Ý định | Prompt mẫu |
|--------|------------|
| Resume | `/orchestrator` *(AGENTS.md → PROGRESS → gate `← CURRENT`)* |
| Task mới | `/orchestrator Mở task …` |
| Chỉ status | `/orchestrator Status` |
| Ép QA trước merge | `/orchestrator QA gate TASK-GDx-xxx — chưa push nếu thiếu 07` |

> **Canonical:** `.cursor/commands/orchestrator.md` · Claude mirror: `.claude/commands/orchestrator.md`  
> **Giới hạn:** Lệnh **ép hành vi agent**, không thay GitHub Actions. Human doc: `docs/ai-agent/reference/orchestrator-how-it-works.md`. Hook `pre-push`: Pint + arch-lint + **PHPStan**; `pre-commit` warn artifact — strict mode xem `artifacts/TASK-GD0-061` orchestration-ops.
