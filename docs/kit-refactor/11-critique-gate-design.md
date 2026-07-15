# Pre-build critique gate — phản biện trước khi thực thi (design)

> Ngày: 2026-07-14 · Ref: [ADR-003 guardrail threat model](../adr/ADR-003-guardrail-threat-model.md) · [10 business front-end](10-business-frontend-design.md)
> Trạng thái: **P0 design.** Trụ cột #2 trong [roadmap](../research/2026-07-11-roles-rules-skills-architecture.md).

## Vấn đề đang giải
Nỗi lo cốt lõi của người dùng: *context phình → AI bypass quy tắc, nhảy thẳng vào code theo quán tính.* Mọi cơ chế hiện có (reviewer, evidence-gate) đều chạy **sau** khi đã viết code. Thiếu một **cổng phản biện TRƯỚC khi build** — và quan trọng: nó phải được **hook ép cứng**, vì markdown thì AI được phép lờ.

## Cơ chế (bám đúng hạ tầng hook đã có)
Một PreToolUse hook trên `Write|Edit` — cùng loại với `consistency-guard`, logic thuần nằm trong `_lib.mjs` để test được, hook chỉ là lớp mỏng đọc stdin.

**Luật quyết định (`critiqueGateDecision`, thuần):**
- **Path miễn trừ** (`.kit/`, `docs/`, `*.md`, `dist|build|out`, `.claude|.cursor|…`, `kit.config.yaml`, lockfiles) → luôn cho qua. Tránh tự khoá (ghi token, ghi brief, ghi Decision Log) và tránh phiền khi sửa docs/config.
- **Đã có gate token hợp lệ** → cho qua.
- **`vibe`** → không chặn, chỉ nhắc (tôn trọng "just go").
- **`standard`/`strict`, chưa có token, path không miễn trừ** → **deny**, kèm hướng dẫn chính xác cách qua cổng.

**Gate token:** `.kit/state/gate.json`, do agent ghi sau khi phản biện xong; hợp lệ khi có trường `decision` không rỗng (bằng chứng đã thực sự critique, không phải file rỗng). **session-start xoá token** → mỗi session buộc đúng **một** lần phản biện trước khi chạm code; sau đó edit thông suốt (không phiền từng lần).

## Các lăng kính (tiêu chí phản biện) — skill `pre-build-critique`
1. **Correctness / regression** — cái gì hỏng? edge case? test hiện có?
2. **Bảo mật & an toàn dữ liệu** — bề mặt tấn công mới? secret/PII? thao tác phá huỷ? (đúng phần người dùng nhấn mạnh)
3. **Consistency** — có thêm "cách thứ hai"? phá vỡ Decision Log / invariant?
4. **Đơn giản / cần thật không** — lát cắt nhỏ nhất chưa? có phải scope creep?
5. **Khả nghịch** — undo được không? rủi ro migration/dữ liệu?

Kết: verdict `go | adjust | stop` + ghi token. `/challenge` là cửa vào thủ công; rule `20-critique-gate` (enforce:hook) là policy được hook back.

## Giới hạn thành thật (rủi ro đã cân nhắc)
- **Chỉ ép được trên Claude** (hook chạy qua `.claude/settings.json`). Target khác: guidance như mọi hook — nêu rõ, không giả vờ ép được.
- **Phạm vi session, chưa phải per-task** (P0). Buộc 1 lần/session. Per-task re-critique là P1 (cần phát hiện ranh giới task — khó với hook stateless).
- **Bypass vẫn khả dĩ** (agent có thể tự ghi token mà không critique thật). Ta chỉ biến "bỏ qua" thành **hành vi có chủ đích, thấy được** (token cần `decision` không rỗng), không phải bất khả. Đây đúng là trần enforcement.
- **Fail-OPEN**: mọi lỗi hook → cho qua, không bao giờ brick khả năng edit của người dùng.

## Bằng chứng phải đạt
`npm test` xanh (thêm unit test cho `critiqueGateDecision`/`isGateExempt`) · golden regenerate 1 commit · `doctor` 0 error (rule enforce=hook map đủ, hook file tồn tại) · dogfood: `standard` chặn khi chưa có token, `vibe` không chặn, có token thì qua.
