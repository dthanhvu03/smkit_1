# Orchestration Ops — vận hành multi-agent (right-sized, chống over)

> **Path:** `docs/ai-agent/reference/orchestration-ops.md` · canonical.
> **Nguồn:** org self-review GD0-061 (đối chiếu best-practice multi-agent 2026) + bài học thực tế session 2026-06-25.
> **Nguyên tắc:** mỗi mục ghi **LÀM gì · KHÔNG làm gì (chống over) · khi nào mới nâng cấp**. Team nhỏ ưu tiên nhẹ; chỉ thêm hạng nặng khi có trigger thật.

---

## 1. Observability agent — handoff trace (nhẹ, KHÔNG telemetry tooling)

**LÀM:** mỗi lần orchestrator route role / spawn subagent → ghi **1 dòng** vào section `## Orchestration trace` của `00-gate-status.md`:
```
[ngày] role/subagent → output (artifact) · spawn N subagent · kết quả (PASS/FAIL/finding) · cost-sense (vd "3 reviewer 1 vòng")
```
Cuối task: 1 dòng tổng "N subagent · M vòng review · lỗi bắt được".

**KHÔNG (chống over):** không OpenTelemetry, không đếm token chính xác, không dashboard. Trace prose trong gate-status đủ cho team nhỏ.

**Nâng cấp khi:** >3 người vận hành agent, **hoặc** chi phí token thành mục ngân sách thật → mới thêm telemetry/trace tool.

---

## 2. Subagent-death resilience (bài học session 2026-06-25: subagent chết ×2 vì session-limit)

**LÀM:**
- Task implement lớn → **chia commit-nhỏ checkpoint** (viết nhóm file → verify → tiếp), KHÔNG dồn 1 subagent làm tất.
- Subagent chết giữa chừng → orchestrator **KHÔNG restart**; thay vào đó **đọc working tree** (`git status -s` + đọc file đã tạo) → tiếp tục từ chỗ dở.
- Ghi sự cố subagent-death vào `KNOWN-ISSUES.md` (đã có ERR-039).

**KHÔNG (chống over):** không dựng framework auto-retry/queue. Resume thủ công bằng đọc working-tree là đủ ở quy mô này.

**Nâng cấp khi:** subagent-death xảy ra thường xuyên gây mất giờ → mới cân checkpoint/resume tự động.

---

## 3. Task tiering — chống over-process (phục vụ trực tiếp "không bị over")

| Tier | Khi nào | Artifact bắt buộc |
|------|---------|-------------------|
| **0 — Trivial** | Fix 1 dòng · typo · docs Mức 0 | KHÔNG artifact — ghi chat *"trivial/docs-only, no artifact"* |
| **1 — Code thường** | 1 module · không schema/tiền/tồn/quyền | `00-gate-status` + `01-task-brief` + QA gate. `03-architecture-impact` **chỉ khi** có rủi ro boundary/logic |
| **2 — Nhạy cảm** | Schema · tiền/tồn · permission · ≥2 module · global behavior | FULL chain: brief → impact → migration-note → implement → QA → review → handoff + **HO gate** |

**Nguyên tắc:** đừng bắt task Tier-0/1 chạy full chain Tier-2. Mức tư duy (0–3) quyết tier: Mức 0–1 → Tier 0–1; Mức 2 → Tier 1; Mức 3 → Tier 2.

---

## 4. Gate reality — separation-of-duties THẬT vs nhãn

**LÀM:** approval matrix (Vũ/Khanh/QLVH/CEO) là **decision-checkpoint** (buộc dừng + suy nghĩ trước khi qua), đúng kể cả khi **1 người đội nhiều mũ**. Nhưng phải **ghi rõ** khi đó:
> *Giai đoạn hiện tại: Vũ (tech) = Khanh (PM) = QLVH = **cùng 1 người (HO)**. "4 gate" = 4 lần checkpoint suy nghĩ, KHÔNG phải 4 người duyệt độc lập.*

**KHÔNG tự ru ngủ** rằng có 4 lớp kiểm soát độc lập khi thực tế 1 người.

**Nâng cấp khi:** có dòng tiền thật / audit ngoài / nhân sự tách vai → mới cần separation-of-duties thật (người duyệt ≠ người làm).

---

## 5. Agent eval / kit-health (BOUNDED — neo "không over")

**Lớp eval HIỆN TẠI (đủ cho quy mô này):**
- **Validation chain** = adversarial review đa-reviewer (đã bắt P0/P1 thật, vd GD0-058 deadlock/NULL-causer).
- **3 validate script** (`validate-artifacts` · `validate-task-log` · `validate-doc-refs`).
- **KNOWN-ISSUES** = drift registry (DEFERRED được gate quét).

**LÀM (nhẹ):** mỗi phase gate → chạy 3 validate script + spot-check 1 task gần nhất `00-gate-status` đủ mục.

**KHÔNG (chống over):** KHÔNG dựng golden-task eval harness / agent regression suite / drift-detector tự động ở giai đoạn này — sẽ là over cho team nhỏ.

**Nâng cấp khi:** quan sát thấy agent **drift** (reviewer bỏ sót lặp lại, orchestrator route sai), **hoặc** team >3 → mới dựng eval harness + golden tasks.

---

## Tự kiểm "có đang over không?"
Trước khi thêm bất kỳ process/tool nào, hỏi: *"Trigger nâng cấp ở mục tương ứng đã xảy ra chưa?"* — Chưa → **đừng thêm**. Đây là cơ chế chống chính việc đọc doc này rồi đi over-engineer.
