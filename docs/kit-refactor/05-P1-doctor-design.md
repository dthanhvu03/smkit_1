# P1 Design Brief — `doctor` command

> Ngày: 2026-07-01 · Ref: [03-engineer-audit.md](03-engineer-audit.md) §13 (mapping) · [04-P0-implementation.md](04-P0-implementation.md)
> Trạng thái: **DESIGN — chờ duyệt. Chưa code.** Không guard v2, không Go, không Studio, không DevOps, không dependency mới.

## Mục tiêu 1 câu
`doctor` kiểm tra sức khỏe repo kit + generated output và báo **bằng lời dễ hiểu + fix hint**, dùng để chạy trước khi commit/CI và khi người dùng thấy "hỏng mà không biết vì sao".

## Scope P1 (doctor)
- Thêm **mode `doctor`** vào generator hiện có: `node tools/kitgen/kitgen.mjs doctor` + script `npm run doctor`.
- Zero-dependency (chỉ Node core + `yaml.mjs` sẵn có). Không đổi runtime, không sửa guard/skill/rule.
- Chạy 8 nhóm check (dưới), in báo cáo gom nhóm + summary, trả exit code theo policy.
- **Đọc & kiểm nhãn `enforce:`** (nhãn P0 mới) — biến nhãn thành thứ enforce được.

## Non-goals (KHÔNG làm trong P1-doctor)
- ❌ Không sửa/nâng cấp guard (guard v2 là task P1 riêng, sau).
- ❌ Không tự động **fix** (chỉ báo + gợi ý; `--fix` để phase sau).
- ❌ Không viết Go / Studio / Docker / CI.
- ❌ Không thêm frontmatter mới bắt buộc (dùng `enforce:` đã có + bảng kỳ vọng built-in).
- ❌ Không đổi format output generated (không đụng golden P0).

## Checklist doctor sẽ chạy

| # | Nhóm | Kiểm | Severity nếu fail |
|---|------|------|-------------------|
| 1 | **Node** | `process.version` ≥ 18 (khớp `engines`) | ERROR |
| 2 | **Config** | `kit.config.yaml` tồn tại + parse được; `version`, `project.name`, `mode ∈ {vibe,standard,strict}`, `stack.profile` trỏ tới `profiles/<p>/profile.yaml` tồn tại, `agents` non-empty ⊆ {agentsmd,claude,cursor,copilot,windsurf}, `outDir` là string | ERROR (thiếu/không parse) · WARN (agent target lạ) |
| 3 | **Path invariant** | tồn tại: `engine/rules`, `engine/roles`, `engine/commands`, `engine/skills`, `profiles`, `.kit/hooks` | ERROR (thiếu thư mục) |
| 4 | **Drift** | `buildOutputs` vs outDir (giống `check`) nhưng thông điệp dễ hiểu + "chạy `npm run build`" | ERROR nếu lệch |
| 5 | **Hook invariant** | tồn tại: `.kit/hooks/guard-shell.mjs`, `session-start.mjs`, `consistency-guard.mjs`, `_lib.mjs`; settings sinh ra tham chiếu đúng các hook | ERROR (thiếu file) · WARN (settings trỏ hook không tồn tại) |
| 6 | **`enforce:` metadata** | mỗi rule (engine + profile) có `enforce`; kiểm theo bảng kỳ vọng: `agent-read`→chỉ cần markdown (OK); `hook`→có hook liên quan trong `.kit/hooks` (rule id đã biết map tới hook cụ thể); `generator`→`tools/kitgen/kitgen.mjs` tồn tại; `gate`→có ≥1 skill có mục "Output format" | ERROR (enforce khai báo nhưng thiếu cơ chế) · WARN (rule thiếu nhãn `enforce`) |
| 7 | **Skills P0** | tồn tại `code-review`, `refactor`, `test-design`; mỗi SKILL.md có `description`, `paths`, và body chứa mục "Output format" | ERROR (thiếu skill) · WARN (thiếu field/mục) |
| 8 | **Role metadata** | mỗi role: `description` chứa "Use when" hoặc "Invoke for"; có `model`; có `tools` | WARN (mỗi role thiếu → routing kém, không chặn build) |

**Bảng kỳ vọng `enforce:` (built-in trong doctor — không cần frontmatter mới):**
```
enforce      cơ chế phải tồn tại
---------    -----------------------------------------
agent-read   (none — chỉ cần rule là markdown hợp lệ)
hook         .kit/hooks/<map[rule.id]>.mjs   (vd consistency-guard -> consistency-guard.mjs)
             hoặc tối thiểu .kit/hooks không rỗng nếu rule.id chưa map
generator    tools/kitgen/kitgen.mjs tồn tại (safe-write/emit)
gate         ≥1 file engine/skills/*/SKILL.md có mục "Output format" / evidence
```
> Ghi chú: đây là kiểm theo *convention*. Nếu sau này muốn chặt hơn, thêm field `enforced_by: <path>` vào rule (P1.1) — **không** thuộc lượt này.

## Error / Warn / Info format

Dòng phẳng, gom theo nhóm, có prefix + fix hint:
```
SM Kit doctor — <project name> (mode=<mode>, profile=<profile>)

Node
  ✔ node v24.15.0 (>= 18)
Config
  ✖ [ERROR] mode "vibee" không hợp lệ → dùng một trong: vibe | standard | strict
Paths
  ✔ engine/rules, engine/roles, engine/commands, engine/skills, profiles, .kit/hooks
Generated output
  ✖ [ERROR] dist/ lệch nguồn (3 file) → chạy: npm run build
Hooks
  ✔ guard-shell, session-start, consistency-guard, _lib
Rules (enforce)
  ⚠ [WARN] rule "docs" thiếu nhãn enforce
  ✖ [ERROR] rule "consistency-guard" enforce=hook nhưng thiếu .kit/hooks/consistency-guard.mjs
Skills
  ✔ code-review, refactor, test-design
Roles
  ⚠ [WARN] role "devops" description thiếu "Use when/Invoke for"

Summary: 2 error(s), 2 warning(s), 0 info.
```
- `✔` INFO/OK (im lặng bớt được với `--quiet`, để phase sau).
- `⚠ [WARN]` — không chặn (chất lượng/routing).
- `✖ [ERROR]` — chặn (sai cấu trúc/cấu hình/drift).
- Mỗi ERROR/WARN kèm **fix hint** ("→ chạy…/→ dùng…/→ thêm…").

## Exit code policy
- `0` — không có ERROR (WARN/INFO vẫn 0). Dùng được trong CI như health-gate mềm.
- `1` — có ≥1 ERROR.
- Không dùng exit 2 (dành cho hook). `--strict` (phase sau) có thể nâng WARN thành lỗi — **không** thuộc lượt này.

## File / module sẽ sửa (khi được duyệt)
- `tools/kitgen/kitgen.mjs` — thêm `runDoctor()` + nhánh `mode === "doctor"` trong `main()`. Tái dùng `buildOutputs`, `parseYaml`, `parseFrontmatter`, `collect*`, `KIT_DIR/PROJECT_DIR`. Ước tính ~120–150 dòng, không đổi emitter/output.
- `package.json` — thêm script `"doctor": "node tools/kitgen/kitgen.mjs doctor"`.
- `tools/kitgen/kitgen.test.mjs` — thêm test cho doctor (dưới).
- **Không** đụng `.kit/hooks/*`, `engine/*`, `profiles/*`, golden P0.

## Test plan
- **doctor-happy**: repo/fixture hợp lệ → exit 0, summary "0 error".
- **doctor-bad-mode**: config `mode: nope` → exit 1, có ERROR mode.
- **doctor-missing-dir**: xóa (trong temp) `engine/skills` → exit 1, ERROR path.
- **doctor-drift**: sửa 1 generated file trong temp outDir → exit 1, ERROR drift.
- **doctor-enforce-gap**: rule enforce=hook nhưng hook thiếu (temp) → exit 1, ERROR enforce.
- **doctor-role-warn**: role thiếu "Use when" → WARN, vẫn exit 0.
- Tất cả chạy qua `spawnSync` trên temp fixture (giống golden test), zero-dep `node:test`.

## Acceptance criteria (P1-doctor PASS khi)
- `npm run doctor` chạy trên repo hiện tại → **exit 0** (repo đang khỏe).
- Bịa từng lỗi (mode sai / thiếu dir / drift / enforce-gap) → **exit 1** + đúng thông điệp + fix hint.
- Role/skill thiếu field → **WARN**, không chặn.
- Doctor **không** thay đổi output generated (golden P0 vẫn pass).
- Không thêm dependency; `npm test` vẫn xanh (thêm test doctor).

## Rollback plan
- Doctor là **mode cộng thêm**, thuần đọc (không ghi). Gỡ = xóa nhánh `doctor` trong `main()` + `runDoctor()` + script `doctor` → mọi thứ khác nguyên vẹn.
- Không đụng file runtime/nguồn nên không có state để hoàn.

## Sau khi duyệt
Chỉ code đúng scope trên (doctor read-only + test). **Không** kèm guard v2 / npx-publish / skills P1 — các thứ đó là task P1 riêng, đề xuất theo thứ tự ở `04 §Next`.

---

# Implementation — DONE (approved & shipped)

> Trạng thái: **APPROVED + triển khai xong.** Đúng scope read-only; không guard v2 / Go / Studio / DevOps / npx / dependency mới.
> 4 điều chỉnh khi duyệt đều đã áp + có test riêng.

## Changed files
- `tools/kitgen/kitgen.mjs` — `runDoctor()` (read-only) + hằng `KNOWN_AGENTS` / `HOOK_MAP` / `OUTPUT_SECTION` + nhánh `mode === "doctor"` trong `main()`. Không đổi emitter/output.
- `package.json` — script `"doctor": "node tools/kitgen/kitgen.mjs doctor"`.
- `tools/kitgen/kitgen.test.mjs` — 7 test doctor + helper `copyKit`/`runKit`/`editFile` (+ import `rmSync`).
- *(Không sửa `.kit/hooks`, `engine/*`, `profiles/*`, golden — role/skill/rule chỉ mutate trong bản copy tạm lúc test.)*

## 4 điều chỉnh khi duyệt → đã áp
1. **Unknown agent target = ERROR** (không phải WARN). → test `unknown agent → exit 1`.
2. **Drift message dùng `outDir` thực tế**, không hardcode `dist`. → test `drift → "out/ lệch nguồn"`.
3. **enforce=hook không fallback**: rule id chưa có trong `HOOK_MAP` → **WARN "chưa có mapping hook"** (không coi là OK). → test `enforce=hook gap → exit 1`.
4. **Skill output-format check case-insensitive**, chấp nhận `Output format` | `Required output` | `Final output`. → hằng `OUTPUT_SECTION`.

## Test / evidence
```
npm run doctor → all ✔, Summary: 0 error(s), 0 warning(s), exit 0
npm run build  → Built 38 file(s) → dist/
npm run check  → OK — 38 generated file(s) in sync
npm test       → tests 16 | pass 16 | fail 0   (9 P0 + 7 doctor)
```
Test doctor: healthy→exit0 · invalid mode→exit1 · unknown agent→exit1 · missing skill→exit1 · enforce=hook gap→exit1 · role thiếu trigger→WARN/exit0 · drift→exit1.

## Ghi chú kỹ thuật
- Doctor đọc **KIT_DIR** cho paths/hooks/rules/skills/roles (đúng mô hình copy-in KIT==project). Chạy dạng npm-dep (KIT≠project) sẽ cần tách nguồn — để P1 npx-publish.
- `HOOK_MAP` hiện chỉ `consistency-guard`; thêm rule `enforce=hook` mới mà quên map → WARN (không âm thầm pass).
- Chưa có `--fix` / `--quiet` / `--strict` (đúng non-goals) — để phase sau.

## Rollback
Mode cộng thêm, thuần đọc. Gỡ = xóa `runDoctor()` + hằng + nhánh `doctor` + script + block test doctor. Không có state để hoàn.

## Còn lại của P1 (chưa làm — task riêng)
Guard v2 (AST + path-boundary + audit log + BLOCK/WARN/ALLOW) · publish `npx` + sửa npm-dep (init copy runtime `.kit/` vào project) · skills P1 (`security-review`, `guard-design`, `release-check`). Thứ tự đề xuất: **guard v2 → npx/npm-dep → skills P1**.
