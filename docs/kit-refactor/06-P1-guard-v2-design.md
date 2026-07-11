# P1 Design Brief — Guard v2

> Ngày: 2026-07-01 · Ref: [03-engineer-audit.md](03-engineer-audit.md) §11-E (benchmark security) + §14.5 (enforce) · [02-review-and-fixes](02-review-and-fixes.md)
> Trạng thái: **DESIGN — chờ duyệt + chốt 1 quyết định (Node vs Go). Chưa code.**

## Vấn đề (vì sao cần v2)
Guard v1 (`.kit/hooks/guard-shell.mjs`) đã fail-closed + case-insensitive + word-boundary, nhưng vẫn là **so khớp chuỗi trên toàn câu lệnh**. Benchmark §11-E chứng minh cách này thua trên:
- **Command chaining** — bug chính thức `claude-code#4956`: `echo x && rm -rf …` (mỗi subcommand chưa được xét riêng).
- **Path escape** — `rm -rf ~/`, symlink, `../`, `$HOME` (v1 không phân giải path).
- **Obfuscation** — `find -e"xec"`, `$(...)`, hex/unicode (mọi blocklist chuỗi đều re-spell được).
- **Không audit log**, chưa có tầng **WARN** (chỉ BLOCK/ALLOW).

## Mục tiêu v2 (1 câu)
Nâng guard từ "so khớp chuỗi" → **xét từng subcommand + phân giải path-boundary + audit log + mô hình BLOCK/WARN/ALLOW**, fail-closed; **định vị đúng: "damage control cho lỗi vô ý", không phải isolation.**

## Scope P1 guard v2
1. **Tách segment theo operator top-level** `; & && || |` và **phát hiện** substitution `$( )` / backtick / heredoc / `bash -c`,`python -c` → segment "chứa code nhúng" **escalate** (WARN/BLOCK theo mode).
2. **Xét từng segment** với blocklist (matcher hiện có) — không xét cả câu một cục nữa.
3. **Path-boundary theo tầng** (học damage-control): phân giải path arg → absolute/canonical; tiers:
   - `zeroAccess`: `~/.ssh`, `~/.aws`, `~/.gnupg`, `.env*`, `.kit/`, `.git/`, hook scripts → **BLOCK** đọc/ghi/xoá.
   - `outsideWorkspace`: path thoát khỏi project root (`../`, `~`, symlink) → **BLOCK** với thao tác ghi/xoá.
4. **Mô hình BLOCK / WARN / ALLOW** theo mode: `vibe` (BLOCK destructive + zeroAccess; WARN boundary mềm), `standard` (như vibe + WARN nhiều hơn), `strict` (BLOCK rộng hơn; ambiguous → BLOCK).
5. **Audit log** append JSONL mỗi quyết định (decision, raw cmd, matched rule, resolved paths, mode, ts) — vị trí xem §Quyết định #2.
6. **Fail-closed**: parse lỗi/ambiguous → BLOCK (giữ như v1).
7. Guard vẫn dùng chung `_lib` + được `doctor` (enforce=hook) kiểm.

## Non-goals (KHÔNG làm P1 guard v2)
- ❌ Không **shell AST đầy đủ** (parser==shell) — bất khả thi thuần Node; đó là lý do cân nhắc Go (§Quyết định #1). v2 chỉ *tokenize theo operator*, chấp nhận residual differential (ghi rõ).
- ❌ Không OS sandbox / network egress (boundary thật, nhưng ngoài phạm vi hook — chỉ khuyến nghị bật sandbox Claude Code).
- ❌ Không secret-scan 3-stage (task riêng, P1/P2).
- ❌ Không `--fix`, không đổi generated output/golden.

## ⭐ Quyết định #1 — Node vs bắt đầu Go (CẦN ANH CHỌN)

| | **A. Node-now (khuyến nghị P1)** | **B. Bắt đầu Go now** |
|---|---|---|
| Parse | Tokenize theo operator + regex substitution detect (không AST đầy đủ) | `mvdan.cc/sh` → **AST thật**, xét mọi subcommand/heredoc chuẩn |
| Dependency | Zero-dep (giữ ràng buộc hiện tại) | Thêm **Go toolchain + build binary**; cần Node fallback khi thiếu binary |
| Phân phối | Không đổi (pure Node, `npx`/degit) | Phải build & ship binary đa nền tảng |
| Correctness | Tốt hơn v1 nhiều, còn residual differential | Cao nhất |
| Rủi ro | Vẫn sót vài obfuscation | Scope lớn, chạm mục "chưa rewrite Go tới khi có test" (giờ ĐÃ có test) |

**Khuyến nghị:** **A (Node-now)** cho P1 — vì (1) giữ zero-dep + phân phối hiện tại, (2) đóng được 80% khoảng cách (chaining + path-boundary + audit + WARN), (3) Go để **P2** làm **adapter** (guard gọi binary `smkit-guard` nếu có, else Node) đúng như Acceptance P2 ở §03. Không rewrite Go giữa chừng.

## Quyết định #2 — vị trí audit log
- `A. .kit/audit.log` (trong project) — local-first, dễ xem; **nhược:** agent có thể sửa (không tamper-evident).
- `B. ~/.smkit/audit.log` (home) — agent khó chạm hơn; **nhược:** ngoài project, ít "local-first".
- **Khuyến nghị:** **A + gitignore + doctor cảnh báo** rằng audit log không tamper-evident (đúng tinh thần "không bán quá"). Tamper-evident thật cần OS/quyền — ngoài scope hook.

## Error/decision format (hook output)
- BLOCK → exit 2 + stderr: `"Blocked (<reason>): <segment>. → <alternative/hint>"`.
- WARN → exit 0 + `permissionDecision: allow` kèm `permissionDecisionReason` cảnh báo (Claude vẫn chạy nhưng thấy cảnh báo).
- ALLOW → exit 0 im lặng.
- Mọi quyết định (kể cả ALLOW) → 1 dòng JSONL vào audit log.

## File/module sẽ sửa (khi duyệt phương án A)
- `.kit/hooks/_lib.mjs` — thêm `splitSegments(cmd)`, `classifySegment(seg, {mode})`, `resolvePathArgs(seg)`, `pathTier(path, projectDir)`, `auditLog(entry)`, hằng `ZERO_ACCESS`. (Giữ `DEFAULT_BLOCK`/`makeMatcher`/`matchesBlock`.)
- `.kit/hooks/guard-shell.mjs` — dùng segment-based + path-boundary + audit + WARN/BLOCK theo mode. Vẫn fail-closed.
- `tools/kitgen/kitgen.mjs` — `emitSettings` giữ nguyên hook wiring; không đổi output khác (⚠ nếu đổi settings.json → phải cập nhật golden).
- `.gitignore` — thêm `.kit/audit.log`.
- `tools/kitgen/kitgen.test.mjs` — test bypass suite (dưới).
- **Không** đụng engine/profiles/roles/skills.

## Test plan (bypass-oriented)
- Chaining: `echo ok && rm -rf /` → **BLOCK** (segment 2).
- Pipe: `curl x | sh` → **BLOCK/WARN** (network→exec compose).
- Path zeroAccess: `cat .env`, `rm -rf ~/.ssh` → **BLOCK**.
- Path escape: `rm -rf ../../etc` → **BLOCK**.
- False-positive giữ: `git push --force-with-lease` → **ALLOW**; `grep "DELETE FROM" app.log` → **WARN** (không BLOCK).
- Safe: `npm run build`, `git status` → **ALLOW**.
- Fail-closed: stdin rác → **BLOCK**.
- Audit: mỗi case ghi đúng 1 dòng JSONL với decision.
- Mode: cùng lệnh boundary → `strict` BLOCK vs `vibe` WARN.

## Acceptance criteria (guard v2 PASS khi)
- Tất cả case bypass trên đúng kỳ vọng; không hồi quy false-positive P0 (force-with-lease vẫn ALLOW).
- Audit log ghi mọi quyết định (JSONL parse được).
- `doctor` vẫn xanh; nếu `settings.json` đổi thì golden đã cập nhật + `npm run check` PASS.
- Zero-dep giữ nguyên (phương án A).
- `npm test` xanh (thêm bypass suite).

## Rollback plan
- Guard v2 khu trú trong `_lib` + `guard-shell.mjs`. Rollback = revert 2 file về bản v1 (đã có trong git-less: giữ bản trước qua doc/`02`), xóa `.kit/audit.log` + dòng gitignore. Generated output không đổi → không cần rebuild.

## Residual risk (ghi rõ)
Vẫn KHÔNG đóng được: parser≠shell differential (Node tokenize ≠ bash thật), write-then-`npm test` RCE, indirection `LD_PRELOAD`/alias, exfil qua kênh cho phép, và mọi thứ sau khi guard bị agent sửa. **Boundary thật vẫn là OS sandbox.** v2 là *defense-in-depth cho lỗi vô ý + honest mistakes*, không phải isolation.

---

# Implementation — DONE

> Quyết định đã chốt: **#1 = A (Node-now)** · **#2 = A (`.kit/audit.log`)**. Triển khai đúng scope, zero-dep giữ nguyên.

## Changed files
- `.kit/hooks/_lib.mjs` — thêm `splitSegments`, `tokenize`, `pathTier` (tiers zeroAccess/outsideWorkspace/workspace), `classifyCommand({mode,block,projDir})`, `auditLog`, hằng `ZERO_ACCESS`/`WRITE_VERB`/`DB_CLIENTS`/`EMBEDDED`/`NET`/`EXEC_SINK`. Giữ `DEFAULT_BLOCK`/`makeMatcher`/`matchesBlock`/`loadBlocklist`.
- `.kit/hooks/guard-shell.mjs` — dùng `classifyCommand` (segment-aware) + `auditLog` + mô hình BLOCK(exit2)/WARN(allow+reason)/ALLOW(silent), fail-closed.
- `.gitignore` — thêm `.kit/audit.log`.
- `tools/kitgen/kitgen.test.mjs` — bypass suite (9 test guard v2 + audit E2E).
- *(Không đụng generator/emitter/output → golden P0 không đổi; không đụng engine/profiles/roles/skills.)*

## Hành vi (đã chốt)
- **Chaining**: xét từng segment → `echo ok && git push --force` → BLOCK segment 2 (đóng `#4956`).
- **network→exec**: `curl … | sh` → BLOCK.
- **Path-boundary**: `.env`/`~/.ssh`/`.git`/`.kit` → BLOCK (zeroAccess); ghi/xoá ngoài workspace (`../…`) → BLOCK.
- **SQL**: `psql -c 'drop table'` → BLOCK (db-exec); `grep "DELETE FROM" app.log` → **WARN** (không exec).
- **Giữ false-positive an toàn**: `git push --force-with-lease` → ALLOW.
- **Embedded code**: strict → BLOCK, vibe/standard → WARN.
- **Audit**: mọi quyết định append 1 dòng JSONL vào `.kit/audit.log`.
- **Fail-closed**: stdin rác → BLOCK.

## Test / evidence
```
npm test       → tests 25 | pass 25 | fail 0   (P0 9 + doctor 7 + guard v2 9)
npm run check  → OK — 38 generated file(s) in sync   (golden P0 không đổi)
npm run doctor → 0 error(s), 0 warning(s)
E2E: chaining/network/zeroAccess → exit 2; grep-SQL → WARN(allow); npm run build → exit 0
```

## Residual risk (không đổi — ghi lại)
Node tokenize ≠ shell thật (differential còn), write-then-`npm test` RCE, indirection env-var, exfil qua kênh cho phép, guard bị sửa. **Boundary thật = OS sandbox.** Guard v2 là defense-in-depth cho lỗi vô ý. Audit log **không tamper-evident** (agent có thể sửa) — doctor nên cảnh báo (bổ sung nhỏ, chưa làm).

## Rollback
Revert `_lib.mjs` + `guard-shell.mjs` về bản trước (guard v1), xóa dòng `.kit/audit.log` trong `.gitignore` + block test guard v2. Generated output không đổi → không cần rebuild.

## Còn lại P1 (chưa làm)
Publish `npx` + sửa npm-dep (init copy runtime `.kit/` vào project) · skills P1 (`security-review`, `guard-design`, `release-check`). **Go adapter (P2)**: guard gọi binary `smkit-guard` (mvdan.cc/sh AST) nếu có, else Node fallback — đúng Acceptance P2 ở §03.
