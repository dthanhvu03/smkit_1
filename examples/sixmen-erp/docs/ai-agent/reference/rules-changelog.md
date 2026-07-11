# Rules / Skills Changelog

> **Path:** `docs/ai-agent/reference/rules-changelog.md`

## Backlog — kit-quality (deferred, low-priority — không block)

> Làm **khi lần sau đụng các file đó** (opportunistic), gom **1 bump version** cho cả pass. Không tạo artifact task / KNOWN-ISSUES (không phải lỗi).

- **De-bloat skill dài** — `sixmen-orchestrator` (559 dòng), `sixmen-devops` (332), `sixmen-frontend` (301). Đẩy phần **prose persona** dài về `docs/ai-agent/` (đọc-cho-người), giữ SKILL phần **guardrail kiểm-được** (anti-bloat rule).

## v2.43 — 2026-06-29 (Audit bảo mật/clean toàn route + security-lint — HO yêu cầu)

> Nguồn: HO — "phát triển để không mắc lỗi sơ đẳng + bảo mật + code sạch".

- **Audit toàn route:** không `$guarded`/`$request->all()`/debug sót · mọi Resource có Policy · không lộ password/secret · Pint 322 PASS — codebase sạch/an toàn.
- **`scripts/architecture-lint.sh`** — thêm SECURITY/CLEAN guard: cấm `$guarded` (mass-assignment) · `$request->all()` · debug `dd/dump/ray/var_dump/print_r`. Pre-push tự chặn lỗi sơ đẳng.
- **N+1 (ERR-053) RESOLVED:** `getEloquentQuery()->with()` 7 Resource (Warehouse/Category/ProductVariant/Product/PurchaseOrder/ActivityLog/User).

## v2.42 — 2026-06-29 (Preset SixmenForms::code() cho field mã — HO duyệt)

> Nguồn: HO — mã (code) cũng nên dùng preset như text/textarea/date.

- **`SixmenForms::code()`** — maxLength + bỏ MỌI khoảng trắng/xuống dòng + HOA (mặc định; `upper:false` cho mã chữ thường). Gom logic strtoupper rải rác.
- Convert 13 field mã (code/short_code/style_key) sang `code()`; bỏ `strtoupper` dehydrate thừa. PO `code` (số tự sinh, read-only) giữ TextInput.
- **lint guard**: cấm `TextInput::make('code'/'short_code'/'style_key')` trần (trừ PurchaseOrderResource).
- TC-FORM-CODE-01 + convention `sixmen-vietnamese-ux`.

## v2.41 — 2026-06-29 (Lint chặn DatePicker/Textarea trần — ép preset, hết "phải nhắc")

> Nguồn: HO — em vi phạm convention vừa lập (thêm maxLength trần thay vì SixmenForms::textarea). Theo triết lý "kiểm-được-bằng-script → hook ép, đừng dựa vào nhớ".

- **`scripts/architecture-lint.sh`** — chặn `DatePicker::make(` / `Textarea::make(` trong `app/Filament/Resources` → fail (phải dùng `SixmenForms::date()/textarea()`). Pre-push tự bắt.
- Convert nốt 8 textarea danh mục (address/description) sang `SixmenForms::textarea()`.

## v2.40 — 2026-06-29 (Bỏ message validation mặc định mơ hồ — HO yêu cầu)

> Nguồn: HO — message "Định dạng không hợp lệ" / "Tối thiểu 1 phần tử" không cho biết sai gì.

- Thêm `validationMessages` rõ + ví dụ cho **5 field regex**: Supplier short_code/phone · WarehouseType code · Color code/hex. Repeater PO minItems (đã làm vòng trước).
- **`sixmen-vietnamese-ux.mdc`** — nguyên tắc #6 + checklist: field regex/format/min-items BẮT BUỘC `validationMessages` rõ, cấm generic.

## v2.39 — 2026-06-29 (Preset text/textarea dùng lâu dài — HO chọn hướng bền)

> Nguồn: HO — xử các lỗ input còn lại theo hướng dùng lâu dài (preset), không vá lẻ.

- **`SixmenForms::text()`** — TextInput preset: maxLength mặc định + gộp `\r\n\t` dán bậy → 1 space + trim (chống control char ô 1-dòng).
- **`SixmenForms::textarea()`** — Textarea preset: maxLength + gộp ≥3 dòng trống → 1 (chống "enter liên tục").
- Áp PO (contract_no/note/payment_terms/tech_requirement/delay/cancel_reason) + Supplier (name/đại diện/address); `order_date` thêm `maxDate(today)` (không đặt hàng tương lai).
- `sixmen-vietnamese-ux.mdc`: convention dùng `SixmenForms::text/textarea`. Test TC-FORM-TEXT-01.

## v2.38 — 2026-06-29 (Sanitize ký tự ẩn/đặc biệt toàn hệ — HO test bắt)

> Nguồn: HO test — SĐT "99999..." + ký tự ẩn (zero-width/bidi/control) lọt vào text/textarea.

- **`app/Support/InputSanitizer.php`** — `clean()`: xóa control C0/C1 (trừ \t\n\r) · zero-width · bidi override (Trojan Source CVE-2021-42574) · BOM; trim. GIỮ tiếng Việt + xuống dòng.
- **`app/Models/Concerns/SanitizesInput.php`** — trait hook `saving`, áp **26 model toàn hệ** (phủ Filament/API/seeder; bỏ qua cast json/encrypted).
- **SupplierResource** — siết regex SĐT (bắt đầu 0/+84, độ dài có hạn).
- 07-checklist §2.1: model mới bắt buộc `use SanitizesInput`.
- Test: InputSanitizerTest (3) + SanitizesInputTest end-to-end.

## v2.37 — 2026-06-29 (Validation + ngoại lệ BẮT BUỘC mọi feature — HO yêu cầu)

> Nguồn: HO — validation + xử lý ngoại lệ phải là yêu cầu cứng cho mọi tính năng sau, không tùy hứng.

- **`.cursor/templates/sixmen/architecture-compliance-checklist.md`** — § 2.1 "Validation & xử lý ngoại lệ" (3 tầng: form đầy đủ · DB constraint backstop · mutation map 409/422 không 500) + §5 test siết: 422 Filament/API + QueryException CHECK + exception nghiệp vụ.
- **`.cursor/rules/sixmen-agent-closeout.mdc`** — mục 4 QA: feature nhập liệu bắt buộc kín validation/ngoại lệ (07 §2.1).
- **`.claude/rules/sixmen-always-on-parity.md`** — architecture-envelope thêm dòng validation/exception bắt buộc + tầng (CRUD inline / phức tạp FormRequest / mutation Service+exception).

## v2.36 — 2026-06-29 (Ép 09-handoff vào closeout always-on — HO bắt drift)

> Nguồn: HO phát hiện task GĐ1 thiếu `09-handoff-summary.md`. Convention có trong SKILL nhưng mirror Claude (closeout) bỏ sót → agent phía Claude drift. Vá để ép mọi lượt.

- **`.cursor/rules/sixmen-agent-closeout.mdc`** — thêm mục 5 (`09-handoff` khi DONE) + mục 6 (`business-walkthrough` Khanh duyệt cho task nghiệp vụ/tồn/tiền) + "không báo DONE khi thiếu handoff / không merge task nghiệp vụ khi thiếu walkthrough".
- **`.claude/rules/sixmen-always-on-parity.md`** — mirror closeout thêm 09-handoff + business-walkthrough.
- Backfill: `TASK-GD1-013/014/015/09-handoff-summary.md` + `TASK-GD1-004/business-walkthrough.md` (PO — R1..R9 cho Khanh duyệt).
- Lý do drift: Human-control package + handoff có trong SKILL nhưng closeout always-on (mirror Claude) bỏ sót → agent Claude không thấy mỗi lượt.

## v2.35 — 2026-06-29 (Date picker chuẩn hệ thống — HO yêu cầu)

> Nguồn: HO — date input thống nhất toàn hệ, không mỗi form một kiểu.

- **`app/Filament/Support/SixmenForms.php`** — `date()`: preset DatePicker (native(false) lịch dropdown · dd/mm/yyyy · locale vi · T2 đầu tuần · closeOnDateSelection).
- **`.cursor/rules/sixmen-vietnamese-ux.mdc`** — § "Ô chọn ngày" BẮT BUỘC dùng `SixmenForms::date()`, cấm `DatePicker::make()` trần + checklist trước commit.
- Đã chuyển: PurchaseOrderResource (3 ô) + ActivityLogResource (filter from/until). Form sau dùng helper.

## v2.34 — 2026-06-29 (Checklist What-if vận hành — HO yêu cầu)

> Nguồn: HO — khung 4 lăng kính chưa đảm bảo "nhìn thấy tình huống thực tế ngoài happy-path" (trễ/gấp/từng phần/hủy…). Thêm checklist bắt buộc để không phụ thuộc agent "chợt nghĩ ra".

- **`.cursor/templates/sixmen/task-brief.md`** — § 2b "Tình huống vận hành thực tế (what-if)": bảng 12 tình huống (trễ · thiếu/dư · lỗi · từng phần · hủy · sửa sau duyệt · hoàn · gấp · trùng · hết hạn · đa chiều · tranh chấp quyền) — bắt buộc task nghiệp vụ/data.
- **`.cursor/skills/sixmen-orchestrator/SKILL.md`** — lăng kính 2 đổi thành "Phản biện + What-if vận hành" kèm checklist.
- Kit Version: Skills v1.17→v1.18 · Templates v1.8→v1.9 · kit v1.2.1→v1.2.2.

## v2.33 — 2026-06-29 (Khung 4 lăng kính trong task-brief — HO yêu cầu)

> Nguồn: HO — mọi task phải có tư duy hệ thống + phản biện + WBS + quản trị rủi ro, không riêng 1 task. Áp tự động qua brief, scale theo Mức 0–3 (chống cả làm ẩu lẫn vẽ việc).

- **`.cursor/templates/sixmen/task-brief.md`** — thêm § "Phân tích 4 lăng kính" (Mức tư duy + Hệ thống · Phản biện · WBS · Rủi ro); bảng WBS + Rủi ro bắt buộc ở Mức 2–3.
- **`.cursor/skills/sixmen-orchestrator/SKILL.md`** — § "Khung 4 lăng kính" (cạnh hethongtuduy) + tiêu chí brief (bước 1) yêu cầu 4 lăng kính; STOP nếu thiếu ở task Mức 2–3.
- Kit Version AGENTS.md: Skills v1.16→v1.17 · Templates v1.7→v1.8 · kit v1.2.0→v1.2.1.

## v2.32 — 2026-06-27 (Docker volume guard — guard-shell-core #6–7)

> Nguồn: HO — chặn agent chạy lệnh xóa volume Docker (cache/prune nguy hiểm).

- **`guard-shell-core.sh`** — chặn: `docker volume prune/rm` · `system prune --volumes/-v` · cải thiện `compose down -v` (hỗ trợ `docker-compose`).
- **`.claude/settings.json`** — deny `volume prune/rm` · ask `system prune` (không `--volumes` vẫn hỏi HO).
- **`.claude/rules/sixmen-always-on-parity.md`** — pointer data-safety Docker.

## v2.31 — 2026-06-27 (Kit sync audit post-slim — drift fixes)

> Nguồn: HO rà soát sau slim + parity pass.

- **`AGENTS.md`** — số dòng ~145 (sửa ~180 drift).
- **`02-governance-and-memory.md`** — always-on rules đủ 6 + skill-routing/closeout.
- **`PROGRESS.md`** · **`task-log-milestones.md`** · **`TASK-GD0-015/00-gate-status`** — C slim = DONE.
- **`platform-agent-parity.md`** · **`orchestrator-how-it-works.md`** — pointer hub extended.

## v2.30 — 2026-06-27 (Slim AGENTS.md hub — TASK-GD0-015-C — AGENTS hub v2.0)

> Nguồn: HO — ~379 dòng → ~145 dòng hub; chi tiết chuyển `02-governance-and-memory.md`.

- **`AGENTS.md`** — hub mỏng: routing · orientation · SoT index · kỷ luật tóm · kit version rút gọn.
- **`02-governance-and-memory.md`** — nhận: kỷ luật artifact · KNOWN-ISSUES · rules/skills 8 mục · tuân thủ kiến trúc · Claude memory promote.
- **Không đổi** rules `.mdc` · skills · workflow ERP.

## v2.29 — 2026-06-27 (gỡ invalid frontmatter rules — AGENTS v1.1.26)

> Nguồn: HO — defer cosmetic: `disable-model-invocation` chỉ thuộc Skill, không phải Rule `.mdc`.

- **`.cursor/rules/*.mdc`** (11 file) — xóa dòng `disable-model-invocation: true` (không đổi `alwaysApply`/globs).
- **`hethongtuduy-v4.3-full.md`** — xóa cùng field thừa trong frontmatter docs.
- **Giữ nguyên** 9× `SKILL.md` — skill vẫn disable auto-invoke.

## v2.28 — 2026-06-27 (Claude `.claude/rules` parity + command mirrors — AGENTS v1.1.25)

> Nguồn: HO — dùng Cursor + Claude Code song song; triển khai defer mục 2 (Claude guards) + mirror commands.

- **`.claude/rules/sixmen-always-on-parity.md`** — mirror 6 rules Cursor `alwaysApply`; canonical vẫn `.cursor/rules/*.mdc`.
- **`CLAUDE.md`** — `@import` parity trước `@AGENTS.md`.
- **`.claude/commands/*`** (9) — thin wrapper → canonical `.cursor/commands/` + SKILL.
- **`platform-agent-parity.md`** — bảng map slash commands · sync discipline · hooks.

## v2.27 — 2026-06-27 (Cursor + Claude platform parity — AGENTS v1.1.24)

> Nguồn: HO `/orchestrator` — đọc docs Cursor/Claude; đóng gap sessionStart JSON, drift `.claude/commands`, bảng auto-load.

- **`claude-session-digest.sh`** — dual output: Cursor `additional_context` + Claude `hookSpecificOutput` (cùng script).
- **`.claude/commands/orchestrator.md`** — AGENTS-first; pointer ritual canonical `.cursor/commands/orchestrator.md`.
- **`orchestrator-how-it-works.md`** — bảng tự nạp theo nền tảng.
- **`AGENTS.md`** — sửa bảng đa nền tảng (skills không auto body).

## v2.26 — 2026-06-26 (Orchestrator kit linkage — AGENTS ↔ command ↔ routing — AGENTS.md v1.1.23)

> Nguồn: HO — đóng gap drift: Orientation thiếu AGENTS-first · § điều phối chỉ @mention · skill-routing không `/orchestrator`.

- **`AGENTS.md`** — Orientation + § Cách điều phối: **`/orchestrator`** cạnh `@sixmen-orchestrator` · AGENTS-first.
- **`.cursor/rules/sixmen-skill-routing.mdc`** — § Orchestrator: Cursor `/orchestrator` + Read `AGENTS.md` trước.
- **`.cursor/rules/sixmen-agent-closeout.mdc`** — pointer orient Bước 0.
- **`docs/ai-agent/reference/orchestrator-how-it-works.md`** (MỚI) — 1 trang Human+Agent, link full chain.
- **`help.md`** · **`docs/ai-agent/README.md`** · **`doc-map.md`** — pointer orchestrator doc.

## v2.25 — 2026-06-26 (`/orchestrator` Bước 0 + AGENTS.md hub — AGENTS.md v1.1.22)

> Nguồn: HO — hai agent giải thích `/orchestrator` không nhắc `AGENTS.md`; command thiếu tầng hub so với skill § Context Preservation.

- **`.cursor/commands/orchestrator.md`** — Bước 0: **`Read AGENTS.md` trước SKILL** · phân biệt resume vs task mới · trigger `shared-memory.md` · blocking output liệt kê AGENTS.
- **`sixmen-orchestrator/SKILL.md`** — pointer command mirror thứ tự đọc.
- **`AGENTS.md`** — Kit v1.1.22.

## v2.24 — 2026-06-26 (Human-control package — HO oversight, pilot GD1-003 — Skills v1.16 · Templates v1.7 · AGENTS.md v1.1.21)

> Nguồn: HO hỏi "code nhanh vậy human kiểm soát code/nghiệp vụ/flow kiểu gì?". HO chọn **gói đầy đủ** + **Khanh duyệt walkthrough mỗi feature**. Mục tiêu: human kiểm soát mà KHÔNG đọc code.

- **`sixmen-orchestrator/SKILL.md` § Human-control package** — 5 deliverable + gate mới: Khanh duyệt `business-walkthrough` (R1..Rn) TRƯỚC merge (ngang Vũ duyệt schema). Nguyên tắc: CI xanh = code đúng test; walkthrough+demo = test đúng nghiệp vụ.
- **`.cursor/templates/sixmen/human-control-package.md`** (MỚI) — skeleton: business-walkthrough (số cụ thể + R-table ký) · demo `.php` (rollback, in số) · traceability matrix (rule→AC→test→file) · 09-handoff 2-view · independent-review (code tiền/tồn/đồng-thời).
- **Pilot `artifacts/TASK-GD1-003/`** — `business-walkthrough.md` (Khanh ký R1–R6) · `demo-material-inventory.php` (chạy in số, verify) · `09-handoff-summary.md` (traceability + independent-review).
- **`AGENTS.md`** — Kit v1.1.21 · Skills v1.16 · Templates v1.7.

## v2.23 — 2026-06-26 (Backend concurrency/integrity guardrails — GD1-002 review lần 2 — Skills v1.15 — AGENTS.md v1.1.20)

> Nguồn: HO chỉ đạo review lần 2 InventoryService trước merge → 3 lỗi tiềm ẩn (ERR-044/045/046) fix + promote.

- **`.cursor/skills/sixmen-backend/SKILL.md` § Guardrails** — thêm 3 rule kiểm-được:
  - **ERR-045** KHÔNG `firstOrCreate`/INSERT-có-unique trong `DB::transaction` (Postgres abort cả TX khi race → 500). Resolve row idempotent TRƯỚC transaction.
  - **ERR-044** Field tính-được có DB CHECK → guard trong Service TRƯỚC `save()` (throw 409/422), không để rơi xuống CHECK → 500.
  - **ERR-046** Validate ràng buộc CHÉO giữa field (vd `type×direction`), không chỉ từng field rời; bỏ giá trị footgun chưa định nghĩa.
- KNOWN-ISSUES ERR-044/045/046 → RESOLVED. Verify: Pest 227 PASS · PHPStan 0 · arch-lint PASS.

## v2.22 — 2026-06-25 (Agent closeout + PHPStan pre-push — ERR-042 lesson — AGENTS.md v1.1.19)

> Nguồn: HO feedback — agent không tự sync artifact / PHPStan đến khi nhắc. Docs + hook.

- **`.cursor/rules/sixmen-agent-closeout.mdc`** (MỚI, `alwaysApply: true`) — checklist cùng lượt: gate-status · PROGRESS · KNOWN-ISSUES · không kết response trước sync.
- **`.githooks/pre-push`** — thêm **PHPStan L5** (= CI job `phpstan`); ERR-042 gap local vs CI.
- **`sixmen-orchestrator/SKILL.md`** — § Auto-update: luật cứng cùng lượt với push, pointer closeout rule.
- **`AGENTS.md`** — bump Kit Version `v1.1.19`.

## v2.21 — 2026-06-25 (Filament 4 Pest patterns — TASK-GD1-009 — AGENTS.md v1.1.18)

> Nguồn: QA gap GD1-009 — `fillForm()` false pass trên Filament 4 Schema; bổ sung unhappy HTTP 403 + Livewire 422. Docs/skill-only.

- **`sixmen-frontend/SKILL.md`** — § *QA handoff — Filament Resource* (matrix 403/422/policy/bulk) + § *Filament 4 Pest* (pointer QA); Final checklist + record-level 403.
- **`sixmen-qa/SKILL.md`** — § *Filament 4 Pest patterns* (canonical): `setCurrentPanel`, HTTP 403 table, Livewire `set('data.*')`, cấm `fillForm`, DB backstop, ID pattern; Final checklist Filament rows.
- **`shared-memory.md §9.2`** · **`phase-readiness-lessons.md §4`** · **`test-plan.md` template** — pointer/checklist Filament unhappy.
- **Reference test:** `tests/Feature/Core/WarehouseTypeRegistryTest.php`.
- **`AGENTS.md`** — bump Kit Version `v1.1.18` (Skills v1.14).

## v2.20 — 2026-06-25 (Orchestration ops — fill gap best-practice 2026, right-sized — GD0-061 — AGENTS.md v1.1.17)

> Nguồn: org self-review (đối chiếu multi-agent 2026) + bài học session. Docs/governance-only. Nguyên tắc: mỗi cải tiến có **trigger nâng cấp** để chống over.

- **`docs/ai-agent/reference/orchestration-ops.md`** (MỚI, canonical) — 5 mục right-sized: (1) observability handoff-trace nhẹ (KHÔNG telemetry tool); (2) subagent-death resume bằng đọc working-tree (bài học session, ERR-039); (3) **task tiering 0/1/2** chống over-process; (4) gate-reality (1 người nhiều mũ = checkpoint, không phải 4 duyệt độc lập); (5) agent-eval bounded (validation-chain + validate-scripts + KNOWN-ISSUES = đủ; defer golden-task harness).
- **`shared-memory.md §10`** — pointer orchestration-ops.
- **`KNOWN-ISSUES.md` ERR-039** — subagent out-session (RESOLVED, workaround thể chế hoá).
- **`AGENTS.md`** — bump Kit Version `v1.1.17`.

## v2.19 — 2026-06-25 (Quy tắc đặt file cross-cutting vs domain — GD0-058 — AGENTS.md v1.1.16)

> Nguồn: self-review GD0-058 + HO chốt placement `ConfigurationException`. Docs-only.

- **`phase-readiness-lessons.md §1`** — thêm quy tắc đặt file: *"dùng chung mọi module → `app/`; riêng 1 module → `modules/{M}/`."* `app/` (Exceptions/Support/Locking/Concerns) = infra cross-cutting KHÔNG gắn bảng (DomainException base, ConfigurationException, SystemActor, AcquiresOrderedLocks, HasBranchScope); `modules/{M}/` = domain-riêng (InsufficientInventory→Warehouse, DocumentNumberScopeKey→Core). Phân biệt với rule cũ (enum/model gắn BẢNG → module sở hữu bảng).
- **`AGENTS.md`** — bump Kit Version `v1.1.16` (Skills v1.13).

## v2.18 — 2026-06-24 (Phase-readiness lessons từ re-audit GĐ0→GĐ1 — AGENTS.md v1.1.15)

> Nguồn: re-audit GD0-056 + deep-dive GĐ1-readiness GD0-057. Mục đích: agent mọi nền tảng không lặp các miss GĐ0 + không sót khi chuyển giai đoạn. Docs/skill-only; KHÔNG đụng code.

- **`docs/ai-agent/reference/phase-readiness-lessons.md`** (MỚI, canonical) — luật vàng phase-transition deep-dive + bài học per-role §1–5: Architect (shared enum ở module thấp nhất · exception→HTTP seam · lock-ordering abstraction · migration band) · Backend (không field lưu-mà-không-dùng · consume actorId · renderer chung · key nhất quán · SYNC-TX vs afterCommit) · Database (period-anchor cho reset counter · backstop cứng · ERD-sau-ALTER) · QA (test backstop documented · 403 data-provider · header đủ · super_admin posture) · BA/IT-Manager (phase-close FR-completeness cross-check).
- **`shared-memory.md` §10** — pointer + tóm tắt luật vàng (skill auto-đọc khi phase gate).
- **6 SKILL.md** (architect/backend/database/qa/ba/it-manager) — thêm 1 dòng pointer §-tương-ứng vào Final checklist (anti-bloat: pointer, không copy dài).
- **`AGENTS.md`** — bump Kit Version `v1.1.15` (Skills v1.12).
- Bối cảnh: deep-dive phát hiện 4 BLOCKER-GĐ1 (period_key · reset↔pattern validator · exception→HTTP seam rỗng · không lock-ordering abstraction) mà closure audit GD0-046 breadth không bắt → remediation TASK-GD0-057/058/059 (chờ HO chốt structure + schema gate).

## v2.17 — 2026-06-24 (Khung 5 tầng + phổ COLD↔HOT vào backend skill; reconcile audit GD0-051 — AGENTS.md v1.1.14)

> Nguồn: Execution Brief "Core Write-Path Architecture" §A — drop khung framing vào skill (entity sau tự định vị tầng) + formalize/reconcile audit write-path GĐ0. Docs-only; KHÔNG đụng code. ADR-013/014 đã có (v2.16) nên chỉ bổ sung phần còn thiếu.

- **`sixmen-backend/SKILL.md`** — thêm § **Khung 5 tầng + phổ COLD↔HOT + side-effect (ADR-013/014)**: 5 tầng (Entry→Service→Domain→Persistence→Infra) + 4 nguyên tắc bất biến (Service≠guarantee; invariant phải có backstop DB; "mọi mutation qua Service" = kỷ luật KHÔNG phải invariant; side-effect afterCommit vs Outbox) + bảng phổ COLD/HOT chọn độ trang bị theo rủi ro. Cảnh báo pilot `DocumentNumberConfig` không phải bằng chứng pattern cho inventory.
- **`artifacts/archive/GD0/TASK-GD0-051/`** — reconcile audit theo HO brief §C: **User Minor→Major** (đã loại trừ privilege-escalation, GAP-1); thêm §8 GAP verification (GAP-1 mass-assignment · GAP-2 activitylog 10/10 + treo `.env` runtime); 2 mục out-of-scope theo dõi riêng; ghi chú `DB::transaction` = scaffold cố ý. Thêm `01-task-brief.md` (kỷ luật artifact). Cập nhật `00-gate-status.md` + `PROGRESS.md`.
- **`AGENTS.md`** — bump Kit Version `v1.1.14` (Skills v1.11).

## v2.16 — 2026-06-24 (PayloadValidator + Service + DB backstop — ADR-013/014 — AGENTS.md v1.1.13)

> Nguồn: TASK-GD0-050 Phase-1 refactor (HO 2026-06-24) — hạ bridge `FormRequest::validatePayload()` xuống legacy; chuẩn mới = PayloadValidator (shape) + Service (orchestration, **không** guarantee) + DB constraint (backstop). Chỉ refactor `DocumentNumberConfig`; không big-bang.

- **`01_Master_Decisions.md`** — thêm **ADR-013** (Validation layering: PayloadValidator + Service + DB backstop; Service = orchestration convention, không phải guarantee; FormRequest bridge = legacy/transition) + **ADR-014** (Transactional Outbox cross-cutting — `afterCommit` chỉ cho side-effect mất được, outbox cho side-effect mất-là-hỏng; relay polling-first; idempotency; numbering gap-free + inventory concurrency = định hướng GĐ1, chưa Phase 1; quan hệ ADR-011).
- **`sixmen-backend/SKILL.md`** — thêm § **PayloadValidator + Service + DB backstop (CANONICAL)**; § cũ đổi tên **Filament v4 ↔ FormRequest bridge (LEGACY)** + cảnh báo migrate; Workflow bước 3 trỏ pattern mới.
- **`sixmen-frontend/SKILL.md`** — bullet Create/Edit: delegate Service kèm `auth()->id()`; pointer § canonical mới.
- **Code (reference impl):** `Modules\Core\Validators\DocumentNumberConfigValidator` (mới) · `DocumentNumberConfigService` refactor (`$actorId`, validate trước TX, wrap format-pattern → `ValidationException`) · FormRequest Store/Update → HTTP skeleton delegate Validator · xóa trait `Concerns\DocumentNumberConfigRules`. DB backstop = partial-unique index sẵn có, **không** migration mới.
- **`artifacts/archive/GD0/TASK-GD0-050/03-architecture-impact.md` + `00-gate-status.md`** — section refactor + concurrency guardrail (ADR-014).
- **`AGENTS.md`** — bump Kit Version `v1.1.13` (Skills v1.10).

## v2.15 — 2026-06-23 (Filament v4 ↔ FormRequest bridge — AGENTS.md v1.1.12)

> Nguồn: TASK-GD0-050 Deep Tech Review — FormRequest envelope đúng lý thuyết nhưng Filament v4 không auto-kích hoạt như Controller.

- **`sixmen-backend/SKILL.md`** — thêm § **Filament v4 ↔ FormRequest bridge**: luồng `handleRecordCreation/Update` → Service → `validatePayload()` static; checklist 8 mục; cấm `Resource/Concerns/` validation; reference `DocumentNumberConfigService`.
- **`sixmen-frontend/SKILL.md`** — bullet Create/Edit delegate Service; pointer backend § bridge.
- **`artifacts/archive/GD0/TASK-GD0-050/03-architecture-impact.md`** — section bridge + TC-DOCNO-14..17.
- **`AGENTS.md`** — bump Kit Version `v1.1.12`.

## v2.14 — 2026-06-23 (Chốt chuẩn map Custom Exception → HTTP, RFC 9110 — AGENTS.md v1.1.11)

> Nguồn: HO chỉ đạo sau audit AI kit (TASK-GD0-045) — resolve SoT conflict 422 vs 409 cho `InsufficientInventoryException`.

- **SoT conflict resolved:** canonical `04_Architecture.md` §849 trước map `InsufficientInventoryException → 422`, lệch skills (409). Đối chiếu RFC 9110 + pseudocode §4.4 (throw dưới `lockForUpdate()` = state-conflict/oversell) → chốt **409 Conflict**. Sửa §849 + thêm bảng **"map Custom Exception → HTTP"** §4.3: 422 = validation tĩnh · 409 = state-conflict/tranh chấp đồng thời.
- **`shared-memory.md §4.1`** — chốt decision rule 422/409 (canonical, ref §4.3); siết **exception-name canonical-gated**: chỉ `InsufficientInventoryException`/`ConfigurationException` là canonical, tên khác (`DocumentNumberConflictException`…) là spec — Architect thêm vào §4.3 trước, không tự chế.
- **`sixmen-backend/SKILL.md`** — mục 4 thêm cảnh báo mã HTTP theo canonical; thêm **mục 4b — Handler ownership** (`app/Exceptions/Handler.php::render()` map exception → §12 envelope cho API path; Livewire catch tại action). Đóng GAP-2 audit.
- **OQ-2 còn mở:** canonical hoá `DocumentNumberConflictException`/`InvalidWorkflowTransitionException`/`BranchScopeViolationException` vào §4.3 → chờ Architect/Vũ khi GĐ1 implement.
- **Backlog cập nhật:** mục "Dedup 422/409 mapping" đã xử lý (canonical hoá §4.3 + gated pointer) → gỡ khỏi backlog.
- **`AGENTS.md`** — bump Kit Version `v1.1.11`.

## v2.13 — 2026-06-23 (Orchestrator artifact-flow discipline — AGENTS.md v1.1.10)

> Nguồn: HO yêu cầu hoàn thiện `sixmen-orchestrator` theo vai trò “Tổng tư lệnh / Trưởng ca” điều phối AI Agent SIXMEN ERP 2026.

- **`sixmen-orchestrator/SKILL.md`** — cập nhật persona “tổng tư lệnh / trưởng ca”: không trực tiếp code/schema/AC thay role chuyên môn; trách nhiệm tối cao là artifact flow, deterministic routing, Human Owner gate, handoff và process discipline.
- Bổ sung **Master Conductor Mindset**: deterministic routing theo artifact, zero-tolerance process discipline, state/shared-memory management, freeze & escalate khi SoT/gate conflict.
- Bổ sung **Artifact Flow deterministic chain**: IT Manager → BA → Architect → Database → Backend/Frontend → QA → DevOps; mỗi bước có artifact bắt buộc, điều kiện mở bước tiếp, và STOP condition.
- Bổ sung approval matrix + freeze/escalate protocol: schema/architecture→Vũ; business/scope→Khanh; permission→QLVH; prod→Vũ+Khanh; strategic→CEO; gate chưa rõ thì ghi `00-gate-status.md` và không route implement.
- **`AGENTS.md`** — bump Kit Version `v1.1.10`; Skills `v1.7`; Templates giữ `v1.6`.

## v2.12 — 2026-06-23 (Database ERD/migration safety — AGENTS.md v1.1.9)

> Nguồn: HO yêu cầu hoàn thiện `sixmen-database` theo vai trò Database Engineer là “Người Bảo Vệ Long Mạch Dữ Liệu”.

- **`sixmen-database/SKILL.md`** — cập nhật persona và guardrail: ERD canonical over DDL/code, append-only data invariants, defensive schema design, PostgreSQL 16 index/constraint notes, scope-aware schema, zero-downtime migration.
- Làm rõ defensive DB layer: FK phải có index + explicit `onDelete`/`onUpdate`; cân nhắc UNIQUE/CHECK/partial index; scope keys CTY/HKD/branch/warehouse; không phó mặc invariant ổn định cho Laravel validation.
- Làm rõ migration safety: nullable/default → backfill → NOT NULL; drop/rename prod phải có backup/data migration/rollback/approval; `down()` reversible hoặc ghi non-reversible + backup/PITR path; không `dropIfExists()` vô trách nhiệm cho dữ liệu thật.
- **`migration-note.md` template** — thêm ERD canonical ref, constraints/index/FK plan, scope/tenancy keys, query/index rationale, zero-downtime/backfill plan, down safety, lock timeout/batch backfill checklist.
- **`AGENTS.md`** — bump Kit Version `v1.1.9`; Skills `v1.6`, Templates `v1.6`.

## v2.11 — 2026-06-23 (IT Manager scope/DoD discipline — AGENTS.md v1.1.8)

> Nguồn: HO yêu cầu hoàn thiện `sixmen-it-manager` theo vai trò IT Manager / PO là “người định hình và kiểm soát biên giới dự án”.

- **`sixmen-it-manager/SKILL.md`** — cập nhật persona PO: kiểm scope creep, phase gate, 1 module chính/task, RACI/Human Owner gates, measurable DoD trước khi dev mở IDE.
- Bổ sung rule scope boundary: tách task nếu ≥2 module chưa brief; không mở task mốc sau khi gate mốc trước chưa PASS; dependency chưa DONE phải ghi rõ, không implement trên giả định ngầm.
- Bổ sung measurable DoD: pass/fail rõ, có evidence/owner; cấm “dễ dùng”, “chạy mượt”, “ổn định” nếu không có cách đo.
- **`task-brief.md` template** — thêm `Module chính`, bảng Module IN/OUT, DoD table với Evidence/Owner, gate table có Owner/Status/Evidence.
- **`gate-status.md` template** — review readiness kiểm DoD đo được + evidence/owner, IN/OUT và module chính.
- **`AGENTS.md`** — bump Kit Version `v1.1.8`; Skills `v1.5`, Templates `v1.5`.

## v2.10 — 2026-06-23 (DevOps release safety — AGENTS.md v1.1.7)

> Nguồn: HO yêu cầu hoàn thiện `sixmen-devops` theo vai trò DevOps / Release Engineer là “Kỹ sư Bảo hiểm Hệ thống”.

- **`sixmen-devops/SKILL.md`** — cập nhật persona và guardrail release: least-privilege DB, technical observability, immutable/container deployment, Horizon/queue lifecycle, PITR/rollback discipline, CI/CD gates.
- Làm rõ ranh giới DB users: `sixmen_app`, `sixmen_report`, `sixmen_migration`, `sixmen_maintenance`; app/queue/scheduler tuyệt đối không dùng `postgres`/superuser; mutation/lock/transaction không chạy trên `pgsql_reporting`.
- Làm rõ observability: request timing (`request_id`, `duration_ms`, `db_query_count`, `db_time_ms`, `memory_peak_mb`) khác Activity Log; monitor 5xx, failed jobs, slow queries/N+1 suspect sau deploy.
- **`release-checklist.md` template** — thêm commit SHA/image tag, CI gates, backup path/PITR point, lock timeout review, safe Horizon reload (`horizon:terminate`), failed-job check, request timing, rollback command.
- **`AGENTS.md`** — bump Kit Version `v1.1.7`; Skills `v1.4`, Templates `v1.4`.

## v2.9 — 2026-06-23 (BA AC exception-first — AGENTS.md v1.1.6)

> Nguồn: HO yêu cầu chuẩn hóa BA như “kiến trúc sư quy trình nghiệp vụ”, nối AC với contract exception-first của Architect/Backend/Frontend/QA.

- **`sixmen-ba/SKILL.md`** — cập nhật persona BA: AC phải đo được, không mơ hồ, không invent business rule/exception từ chat; mutation AC phải nêu model/chứng từ/movement/audit impact và Custom Exception/fail condition khi vi phạm nghiệp vụ.
- **AC format** — cột `Then` đổi thành `Then (Kết quả / Exception throw nếu fail)`; thêm rule HTTP mapping 422 (input/business validation) · 409 (conflict/tranh chấp/trùng/hết kho) khi có API/domain conflict.
- **`acceptance-criteria.md` template** — thêm hướng dẫn AC đo được và bảng `Mutation / Exception mapping` để BA ghi rõ model impact + exception/fail condition cho Dev/QA.
- **`sixmen-qa/SKILL.md` + `test-plan.md` template** — thêm checklist cover AC exception/fail condition bằng Pest 422/409 hoặc ghi rõ gap.
- **`AGENTS.md`** — bump Kit Version `v1.1.6`; Skills `v1.3`, Templates `v1.3`.

## v2.8 — 2026-06-23 (Architect boundary hardening — AGENTS.md v1.1.5)

> Nguồn: HO yêu cầu củng cố background/guardrail `sixmen-architect` theo vai trò Solution Architect là “người gác đền” hệ thống.

- **`sixmen-architect/SKILL.md`** — thêm các section ngắn: Bounded context & module ownership; Data governance & transaction design; Zero-trust scope architecture; Evolutionary change; Architecture artifact quality.
- Làm rõ kiến trúc module: mỗi module phải có owner bảng/service/event; cross-module chỉ qua public Service/Event/Contract, không query/update thẳng bảng nội bộ module khác.
- Làm rõ data/reporting boundary: movement/ledger/audit append-only; balance là snapshot/derived; mutation/transaction/`lockForUpdate()` chạy primary `pgsql`; `pgsql_reporting` chỉ report/dashboard/export đã duyệt, fresh read dùng `force_primary`; không gọi `sharedLock()` là optimistic locking.
- Bổ sung checklist kiến trúc: transaction/locking/idempotency/reporting, RBAC + CTY/HKD/branch/legal_entity/warehouse scope, risk/rollback/test expectation, Human Owner gate khi schema/API/rule/state-machine/≥2 module.
- **Templates** — cập nhật `.cursor/templates/sixmen/architecture-impact.md` và `architecture-compliance-checklist.md` để có chỗ ghi owner/public interface, transaction/locking/idempotency, reporting connection, scope, risk/rollback/test expectation.
- **`AGENTS.md`** — bump Kit Version `v1.1.5`; Skills `v1.2`, Templates `v1.2`.

## v2.7 — 2026-06-23 (Frontend contract hardening — AGENTS.md v1.1.4)

> Nguồn: review hiện trạng codebase (notification + service contract) theo yêu cầu HO 2026-06-23. Verify thực tế: Filament **v4.11.7** (composer.lock), `spatie/laravel-data` **không** cài, **không** thư viện Toast ngoài.

- **`sixmen-frontend/SKILL.md`** — thêm 5 guardrail: (1) **⛔ GĐ0 STOP** nếu Service/Custom Exception GĐ1 chưa tồn tại thật trong source (verify grep/Read, cấm tự chế class/Service rác); (2) **Notification thuần Filament v4.11.7** — ép `Notification::make()`, cấm cài Toast ngoài; (3) **Data contract** — form state → plain PHP DTO (cấm `spatie/laravel-data`), Write Service trả Eloquent Model trực tiếp; (4) **Exception-first** — catch đúng Custom Exception (`InsufficientInventoryException`, đồng bộ tên với `04_Architecture.md` §4.3 thay `InsufficientStockException`), cấm `catch (\Throwable)`; (5) verify mọi `$var` mẫu đã nằm trong code fence/inline-code → không escape (escape `\$` sẽ hỏng PHP). Sync vào Stop conditions + Final checklist.
- **`shared-memory.md`** — canonical home: §2 Deprecated +3 dòng (spatie/laravel-data · catch Throwable · Toast ngoài); **§4.1 Service I/O contract & GĐ0 reality** (return Model · plain DTO · exception-first · GĐ1 service/exception chưa code); **§9.2 Frontend/notification stack** (Filament v4.11.7 · notification built-in only).
- **`sixmen-backend/SKILL.md`** — thêm § **Service I/O contract** 5 điểm đánh số: (1) success → Eloquent Model trực tiếp; (2) lỗi nghiệp vụ → throw Custom Exception, cấm `['success'=>false]`/`false`/`null`; (3) input → plain PHP DTO/command (cấm `spatie/laravel-data` + `$request->all()`); (4) **HTTP mapping 422** (input/logic) · **409** (tranh chấp/trùng/hết kho); (5) **⛔ GĐ0 boundary** — Core Service GĐ1 chưa code → **(a)** thiết kế mới theo `03-architecture-impact.md` (+ migration-note nếu schema) **hoặc (b) STOP escalate**, không tự chế Service rác.
- **`sixmen-architect/SKILL.md`** § Layer backend — thêm dòng I/O contract khi thiết kế Service mới (return Model · plain DTO · throw Custom Exception · HTTP 422/409 · GĐ0 chốt tên đúng spec) → khớp nhánh (a) khi backend escalate.
- **`sixmen-qa/SKILL.md`** — Final checklist +2 dòng kiểm (service contract + notification Filament built-in).
- **Anti-bloat:** chi tiết domain ở frontend/backend/architect SKILL; fact canonical ở shared-memory §4.1/§9.2; qa chỉ pointer. *(Đã cân nhắc tách persona doc `docs/ai-agent/personas/` — HO quyết giữ trực tiếp trong SKILL, không tạo file rời.)*
- **Fix factual (review sweep):** `AGENTS.md` § Cấu trúc phòng ban sửa "Filament 3" → "**Filament 4**" cho khớp fact Filament v4.11.7 (không bump version — correction). Dead-link check (bash, do WSL thiếu `pwsh`) trên file kit vừa sửa: PASS, 0 dead-file.

## v2.6 — 2026-06-19 (Comment convention — AGENTS.md v1.1.3)

- **`sixmen-laravel-backend.mdc` § Comment convention:** Thêm quy cách comment dựa trên đồng thuận thế giới (Clean Code · Software Engineering at Google · PSR-5/Laravel). Nguyên tắc: code nói WHAT, comment nói WHY; inline ≤2 dòng; lý do dài → 1 dòng + ref `ERR-xxx` (không copy vào code, chi tiết sống ở KNOWN-ISSUES); bỏ PHPDoc khi type hint đã đủ; cấm comment "what" lặp lại code + commented-out code. Promote từ feedback Human Owner (over-commenting GD0-005/ERR-018).
- **Áp dụng ngay:** trim block comment dài trong `bootstrap/app.php`, `AdminPanelProvider.php`, `MasterDataResourceTest.php` về 1 dòng + ref.

## v2.5 — 2026-06-18 (Session orientation — AGENTS.md v1.1.2)

- **AGENTS.md v1.1.2:** Thêm block `Orientation` vào § Prompt khởi động — agent mới đọc `artifacts/PROGRESS.md` → tìm task 🔄 → đọc `00-gate-status.md` → tiếp từ `← CURRENT`. Đóng gap "agent biết role routing nhưng không biết đang làm task nào".
- **AGENTS.md § Claude Code memory:** Thêm pointer "Feedback rules đã promote" → chỉ thẳng orchestrator SKILL.md § Auto-update. Agent đọc AGENTS.md biết chính xác đọc file nào để tìm feedback rules.
- **orchestrator SKILL.md § Auto-update:** Thêm item 4 — bump Kit Version phải kèm `rules-changelog.md` entry cùng lượt. Promote từ Claude memory `feedback_kit_version_changelog`.

## v2.4 — 2026-06-18 (Multi-agent rule visibility)

- **AGENTS.md v1.1.1:** Thêm note `Claude Code memory` vào § Claude Code — ghi rõ path memory directory + quy tắc promote rule sang SKILL.md.
- **Quy tắc promote:** Rule trong Claude memory có giá trị cross-agent → phải ghi vào SKILL.md trong cùng lượt response khi phát hiện. Codex/Cursor không đọc được Claude memory.
- **SKILL.md (9 file):** Thêm `> Bước 0 — mọi session: Đọc AGENTS.md` vào preamble mỗi skill.
- **SKILL.md devops + orchestrator:** Thêm § KNOWN-ISSUES append (khi fix lỗi >15 phút).
- **KNOWN-ISSUES.md:** Bổ sung ERR-004 (linux-headers) + ERR-005 (apk update pattern) — lifecycle Closed.

## v2.3 — 2026-06-17 (Skill Background — business persona)

- **Template:** `.cursor/templates/sixmen/skill-background-template.md` — 5 block (Vai trò · Vì sao · Cách làm việc · Bối cảnh · Ranh giới).
- **Mẫu pilot:** `.cursor/skills/sixmen-backend/SKILL.md` § Background rewritten; frontmatter `description` trigger keywords.
- **Rollout v2.3:** cả 9 skill — business persona 5 block (Vai trò · Vì sao · Cách làm · Bối cảnh · Ranh giới).

## v2.2 — 2026-06-17 (Kit v1.1.0)

- **Validation pilot PASS:** `artifacts/PILOT-GD0-B1/` — migration-note dry-run GĐ0 Batch 1.
- **Context efficiency:** `hethongtuduy.mdc` rút gọn always-on (~65 dòng); full → `hethongtuduy-v4.3-full.md`.
- **flowchart-business:** `alwaysApply: false` + glob `04_*_Flow.md`.
- **New:** `sixmen-skill-routing.mdc` always-on — route Read skill + validate scripts.
- **Scripts:** `validate-artifacts.ps1`, `validate-task-log.ps1`, `init-kit.ps1`.
- **CI:** `.github/workflows/` validate pipeline *(planned — chưa tạo)*.
- **Examples:** `artifacts/EXAMPLE-TASK/` gold standard.
- **AGENTS.md:** compressed SoT index (15 pointers) + validate script refs.
- **Role globs:** backend + `database/**`, `tests/**`; qa + migrations/seeders.
- **Metrics template:** `agent-task-metrics.csv`.
- **Non-Cursor:** `docs/PROMPT-BOOTSTRAP.md`.
- **Always-on count:** 5 files *(was 5; ~650+ lines → ~350 lines est.)*.

## v2.1.1 — 2026-06-16

- Sync GĐ0 docs sau SRS gap pass: `05_User_Flow`, `BRD`, `04/06/07`, `ERD` §6–§7, UI walkthrough FR refs.
- Bỏ placeholder Kho/TC khỏi `05_User_Flow` — align `FR-CORE-UI-01c`.

## v2.1 — 2026-06-16

- Added role-specific **Background** to 9 skills.
- Confirmed **shared-memory loading rule** in `AGENTS.md` + `sixmen-governance.mdc`.
- Added **rules/skills anti-bloat rule** in `AGENTS.md` + governance pointer.
- Added **Reporting contract** (files read / assumptions / final verification) to 9 skills.
- Added **Rules validation pilot** in `phase-gates.md`.
- Kept shared facts in `docs/ai-agent/reference/shared-memory.md`.
- Kept governance / envelope / data-safety as always-on guardrails.
- Artifact discipline (`artifacts/{Task-ID}/`) — from v2.0 strict ops pass.

## v2.0 — prior

- Shared memory refactor: skills domain-only + pointer.
- Memory / Context Contract on 9 skills + 11 rules.
- `sixmen-data-safety.mdc` · `sixmen-architecture-envelope.mdc` always-on.
- Post-feature QA gate · Codacy in detect layer.
