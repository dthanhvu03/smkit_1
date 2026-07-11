# Code review → fixes (self-review of the universal kit)

> Ngày: 2026-07-01 · Scope: `tools/kitgen/*.mjs` + `.kit/hooks/*.mjs` (665 dòng logic)
> Quy trình: `/code-review` high-effort — 8 finder angle (song song) → dedup → verify → 10 finding → fix hết → test lại.
> Trạng thái: **đã fix cả 10 + verify bằng test**. Chưa push (không phải git repo).

## Bối cảnh

Sau khi dựng kit (P0–P1 + commands + 4 target + profiles), chạy self-review. Nhiều finder độc lập **hội tụ** vào cùng nhóm lỗi an toàn (guardrail) và triển khai (ROOT), cho thấy đó là lỗi thật, không phải nhiễu.

## 10 finding → fix → bằng chứng

| # | File | Vấn đề | Fix | Verify |
|---|------|--------|-----|--------|
| 1 | `.kit/hooks/guard-shell.mjs` | Import tĩnh `../../tools/kitgen/yaml.mjs`; thiếu → hook crash → Claude coi là non-blocking → **guard tắt âm thầm** | `DEFAULT_BLOCK` nhúng sẵn (luôn áp); parser nạp qua **dynamic import**, lỗi thì fallback defaults (fail-**closed**) | guard vẫn chặn khi config/parser hỏng |
| 2 | `guard-shell.mjs` | `...(g.allow_extra ? [] : [])` = [] cả 2 nhánh + đọc key ma `extra_block` → `allow_extra` không bao giờ nạp | merge đúng `[...block, ...allow_extra]`, hợp nhất với DEFAULT_BLOCK | `flyctl destroy` ở allow_extra → exit 2 |
| 3 | `kitgen.mjs`, `init.mjs` | `ROOT` = thư mục cài, không phải project → chạy như npm dep sẽ đọc/ghi `node_modules` | Tách **KIT_DIR** (nguồn) vs **PROJECT_DIR** (`CLAUDE_PROJECT_DIR`/cwd); config+output theo PROJECT_DIR | init ghi `.claude/` đúng vào project scratch |
| 4 | `kitgen.mjs` `denyFromGuardrails` | Chỉ sinh deny cho `rm/git/docker/chmod`; SQL + entry tự thêm bị bỏ; guard lại case-sensitive → lowercase SQL lọt cả 2 lớp | Sinh deny cho **mọi** entry dạng lệnh; guard match **case-insensitive** | `psql -c 'drop table'` → exit 2 |
| 5 | `yaml.mjs` `stripComment` | Cắt tại ` #` đầu tiên bất kể quote → hỏng value chứa ` #` | `stripComment` **quote-aware**; `scalar` decode escape `\"` `\n` | `name: "My App #1"` giữ nguyên |
| 6 | `init.mjs` | Nội suy name thô vào YAML → `"`/newline làm hỏng/inject config | `JSON.stringify(name)` → chuỗi YAML hợp lệ | `My "Cool" App` parse ra đúng |
| 7 | `guard-shell.mjs` | Substring match → `git push --force-with-lease` (an toàn) bị chặn nhầm | Match theo **word-boundary** `(?![\w-])` + whitespace-flexible | force-with-lease allow; `--force` block |
| 8 | `init.mjs` | `nonInteractive` chỉ theo `--name` → CI/pipe không name treo ở readline | Bật khi có **bất kỳ flag** hoặc **không phải TTY** | pipe không flag → dùng default, không treo |
| 9 | `init.mjs` | `exit(r.status \|\| 0)` → báo success khi build fail spawn (status null) | Xử lý `r.error`/`status===null` → exit 1 | code path đúng |
| 10 | `guard-shell.mjs` | Parse stdin lỗi → `cmd=""` → cho qua (fail-open) | stdin non-empty parse lỗi → **block exit 2** | input rác → exit 2 |

## Dọn nợ kỹ thuật kèm theo

- **`.kit/hooks/_lib.mjs`** (mới): gộp `projectDir` + `loadConfig()` — hết 3 bản copy-paste `projectDir`, một đường parse config duy nhất.
- **consistency-guard**: precompile regex + `CAT_OF` map ở module scope (trước đó compile ~40 regex mỗi lần gọi trên hot-path Write/Edit).
- **init**: `mkdirSync` project dir + `.kit/` trước khi ghi (init vào thư mục mới trước đây crash ENOENT — phát hiện lúc test).

## Bài học rút ra (đưa vào kit)

1. **Guardrail phải fail-closed + tự chứa.** Một security hook không được phụ thuộc import có thể vắng; phải có default nhúng.
2. **Hai lớp phòng thủ đừng chung điểm mù.** Deny-list và hook từng bổ sung nhau trên giấy nhưng thực tế cùng bỏ sót lowercase SQL / entry tự thêm.
3. **Tách "nguồn kit" khỏi "project đích".** Lẫn hai cái là lỗi triển khai kinh điển khi phát hành dưới dạng dependency.
4. **Nội suy dữ liệu người dùng vào cấu hình phải escape.** `JSON.stringify` cho chuỗi YAML double-quoted.

## Còn lại (không chặn)

- Cảnh báo linter style (`String.raw`, cognitive-complexity, `parseInt`) — không ảnh hưởng hành vi.
- Hỗ trợ **npm-dependency đầy đủ** (init copy `.kit/` + `tools/kitgen/yaml.mjs` vào project) — hiện kit theo mô hình copy-in/degit; npm dep chỉ chạy generator, chưa cài runtime hooks. Ghi nhận cho phase phân phối.
- `CATEGORIES` của consistency-guard là danh sách tĩnh (JS/Python) — heuristic, sẽ mở rộng/khai báo qua config sau.
