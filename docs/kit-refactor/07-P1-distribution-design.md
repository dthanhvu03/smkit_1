# P1 Design Brief — Distribution (npx / npm-dep fix)

> Ngày: 2026-07-01 · Ref: [03-engineer-audit.md](03-engineer-audit.md) §11.4/§13 · [02-review-and-fixes](02-review-and-fixes.md) #3 · [06](06-P1-guard-v2-design.md)
> Trạng thái: **DESIGN — chờ duyệt + chốt 2 quyết định. Chưa code.**

## Vấn đề (vì sao cần bước này)
1. **Hook không self-contained.** `.kit/hooks/_lib.mjs` `import "../../tools/kitgen/yaml.mjs"`. Claude gọi hook qua `${CLAUDE_PROJECT_DIR}/.kit/hooks/…` → nếu project có `.kit/` nhưng **không có `tools/`** (mô hình npm-dep), import chết → guard fail (đã né bằng dynamic-import fallback, nhưng vẫn mất tính năng config).
2. **`init` chưa scaffold runtime vào project.** Hiện `init` ghi `kit.config.yaml` + constitution/decisions, nhưng **không copy `.kit/hooks`** vào một project trống → mô hình degit thì có sẵn, mô hình npm thì thiếu.
3. **Chưa publishable gọn.** `bin` hiện là `kit`/`kitgen` rời; chưa có 1 lệnh `smkit` + chưa xác định cái gì nằm ở project vs ở package.

> Lưu ý: P0 đã tách `KIT_DIR` (nguồn) vs `PROJECT_DIR` (config/output) → **generator đã ghi đúng vào project**. Việc còn lại chỉ là **runtime hooks** + **trải nghiệm cài**.

## Mục tiêu (1 câu)
Một người lạ chạy **một lệnh** để có kit chạy được trong project của họ (hooks + config + generated), hết lỗi "hook trỏ tới file không tồn tại".

## Scope bước này
1. **Làm `.kit/` self-contained** — hooks không còn `import ../../tools`. Vendor một `.kit/hooks/yaml.mjs` (copy từ `tools/kitgen/yaml.mjs`, cùng nguồn, generator đảm bảo đồng bộ) → `.kit/` chỉ cần chính nó để chạy.
2. **`init` scaffold runtime** — copy `.kit/hooks/*` + `.kit/*.template.md` từ `KIT_DIR` vào `PROJECT_DIR` (idempotent, không đè user data), rồi build.
3. **CLI gọn** — xem Quyết định #2.
4. **Publishable** — `package.json` `files` gồm đủ nguồn; README ghi `npx`. *(Không chạy `npm publish` trong môi trường này — xem Non-goals.)*

## Non-goals
- ❌ **Không thực sự `npm publish`** (không có registry/auth ở đây) — chỉ làm *publishable* + tài liệu. Publish là bước thủ công của anh.
- ❌ Không Go adapter (P2), không Studio, không CI.
- ❌ Không đổi format generated output (golden P0 giữ nguyên).
- ❌ Không thêm dependency runtime.

## ⭐ Quyết định #1 — Nguồn kit nằm ở đâu trong project người dùng?

| | **A. Self-contained copy (khuyến nghị)** | **B. Linked (nguồn ở package)** |
|---|---|---|
| Cài | copy `engine/ profiles/ tools/ .kit/` + config vào project | chỉ `.kit/` + config + generated vào project; `engine/profiles/tools` ở `node_modules` |
| Sau cài | project **tự chạy** (`npm run build`), không phụ thuộc package | cần `npx smkit build` (đọc nguồn từ package) |
| Sửa rule/profile | sửa trực tiếp trong project (hackable — hợp vibe) | phải sửa trong node_modules hoặc override (khó) |
| Cập nhật kit | re-run init / degit | `npm update` |
| Project "sạch" | nặng hơn (mang cả nguồn) | gọn (chỉ .kit + generated) |

**Khuyến nghị: A** — self-contained đúng tinh thần local-first + cho người dùng *sửa rule/profile ngay trong project*; không lệ thuộc node_modules lúc chạy hook. (B để dành nếu sau này muốn "consume-only".)

## ⭐ Quyết định #2 — CLI

| | **A. Một `smkit <cmd>` (khuyến nghị)** | **B. Giữ `kit` + `kitgen` rời** |
|---|---|---|
| Lệnh | `smkit init/build/check/doctor` | `kit` (init), `kitgen build/check/doctor` |
| npx | `npx smkit init` gọn | `npx <pkg> ...` lệch tên |
| Thay đổi | thêm 1 dispatcher mỏng | không đổi |

**Khuyến nghị: A** — 1 tên `smkit` dễ nhớ, `bin: { "smkit": "tools/kitgen/cli.mjs" }`, dispatcher gọi init/build/check/doctor. Giữ `npm run *` như cũ.

## Core technical fix — `.kit` self-contained
- Thêm `.kit/hooks/yaml.mjs` (bản sao `tools/kitgen/yaml.mjs`). `_lib.mjs` import `./yaml.mjs` thay vì `../../tools/kitgen/yaml.mjs`.
- **Chống drift**: `kitgen build` (hoặc `doctor`) kiểm `.kit/hooks/yaml.mjs` == `tools/kitgen/yaml.mjs`; lệch → cảnh báo. (Hoặc coi `.kit/hooks/yaml.mjs` là *generated* từ nguồn — generator copy khi build. → chọn cách generator-copy để 1 nguồn thật.)
- → **`tools/kitgen/yaml.mjs` là nguồn; `.kit/hooks/yaml.mjs` là bản build**. `doctor` thêm 1 check "hook yaml đồng bộ".

## init scaffolding (mô hình A)
`smkit init` trong project trống:
1. Copy `engine/ profiles/ tools/ .kit/hooks/` + `.kit/*.template.md` từ KIT_DIR → PROJECT_DIR (idempotent; không đè `kit.config.yaml`/`constitution.md`/`decisions.md` nếu đã có — dùng `.bak` như hiện tại).
2. Phỏng vấn → ghi `kit.config.yaml` + constitution + decisions (như hiện tại).
3. `build`.
> Trong repo dev (KIT_DIR==PROJECT_DIR) copy là no-op an toàn (đích trùng nguồn → bỏ qua).

## File / module sẽ sửa (khi duyệt A + A)
- `.kit/hooks/_lib.mjs` — import `./yaml.mjs`.
- `tools/kitgen/kitgen.mjs` — build copy `tools/kitgen/yaml.mjs` → `.kit/hooks/yaml.mjs` (như một output nguồn-runtime); `doctor` thêm check đồng bộ.
- `tools/kitgen/cli.mjs` (mới) — dispatcher `smkit <cmd>`.
- `tools/kitgen/init.mjs` — thêm bước copy runtime (`engine/profiles/tools/.kit/hooks`) vào PROJECT_DIR khi khác KIT_DIR.
- `package.json` — `bin: { smkit }`, cập nhật `files`, `scripts` giữ.
- `README.md` — quickstart `npx`.
- `tools/kitgen/kitgen.test.mjs` — test: init vào project trống (temp) → có `.kit/hooks` + chạy được; hook yaml đồng bộ; doctor bắt lệch.
- **Không** đụng engine/profiles/roles/skills/emitter output (⚠ nếu `.kit/hooks/yaml.mjs` tính là generated → **không** vào golden P0 vì nó nằm ngoài outDir; xác nhận khi code).

## Test plan
- **init-empty-project**: init vào temp trống → tồn tại `.kit/hooks/{guard-shell,_lib,yaml}.mjs` + `kit.config.yaml` + generated; `node .kit/hooks/guard-shell.mjs` chạy (block 1 lệnh) **không cần** `tools/` cạnh `.kit`.
- **hook-self-contained**: xóa `tools/` trong temp project sau init → guard vẫn chạy (import `./yaml.mjs`).
- **yaml-sync**: sửa `.kit/hooks/yaml.mjs` lệch → `doctor` ERROR "hook yaml lệch nguồn".
- **cli-dispatch**: `smkit build/check/doctor` tương đương lệnh cũ.
- Golden P0 vẫn pass; `npm test` xanh.

## Acceptance criteria
- Init vào project trống (không có `tools/` cạnh `.kit`) → guard hook chạy được (self-contained).
- `smkit init/build/check/doctor` hoạt động; `npm run *` giữ nguyên.
- `doctor` phát hiện `.kit/hooks/yaml.mjs` lệch nguồn.
- Golden P0 không đổi; zero-dep giữ nguyên; `npm test` xanh.
- README có 1-lệnh quickstart; `package.json` publishable (files đủ) — *không* publish thật.

## Rollback
- Revert import `_lib` về `../../tools/kitgen/yaml.mjs`, xóa `.kit/hooks/yaml.mjs` + copy-step + `cli.mjs` + `bin.smkit`. init trở lại chỉ-ghi-config. Generated output không đổi.

## Residual / để sau
- `npm publish` thật (thủ công). · Go adapter (P2). · Mô hình B "consume-only" (nếu cần). · Auto-update kit trong project (re-init).

---

# Implementation — DONE

> Chốt: **#1 = A (self-contained copy)** · **#2 = A (single `smkit` CLI)**. Zero-dep giữ nguyên; golden P0 không đổi.

## Changed files
- `.kit/hooks/yaml.mjs` (mới) — bản vendored byte-identical của `tools/kitgen/yaml.mjs` → `.kit/` self-contained.
- `.kit/hooks/_lib.mjs` — `loadConfig` import `./yaml.mjs` (hết reach `../../tools`).
- `tools/kitgen/cli.mjs` (mới) — dispatcher `smkit <init|build|check|doctor>`.
- `tools/kitgen/kitgen.mjs` — `doctor` thêm check **yaml-sync** (`.kit/hooks/yaml.mjs` == `tools/kitgen/yaml.mjs`) + require `yaml.mjs`.
- `tools/kitgen/init.mjs` — bước copy self-contained (`engine/profiles/tools/.kit`) vào PROJECT_DIR khi ≠ KIT_DIR, idempotent (không clobber).
- `package.json` — `bin: { smkit }` (bỏ `kit`/`kitgen`).
- `README.md` — commands theo `smkit` + ghi self-contained.
- `tools/kitgen/kitgen.test.mjs` — 3 test dist.

## Hành vi
- `smkit init` vào project trống → copy runtime + nguồn + sinh config; project **tự chạy**, không cần node_modules.
- Hook self-contained: xóa `tools/` khỏi project → guard vẫn chạy (import `./yaml.mjs`).
- `doctor` bắt vendored yaml lệch nguồn (ERROR + hint `cp`).
- `smkit build/check/doctor` == lệnh cũ; `smkit` không tham số → usage.

## Test / evidence
```
npm test  → tests 28 | pass 28 | fail 0   (P0 9 + doctor 7 + guard v2 9 + dist 3)
npm check → OK — 38 file in sync (golden P0 không đổi)
npm doctor → 0 error, 0 warning
E2E: init project trống → self-contained; xóa tools/ → hook vẫn block; yaml drift → doctor ERROR
```

## Non-goals đã giữ
Không chạy `npm publish` (không có registry ở đây) — chỉ *publishable* + README. Không Go/Studio/CI.

## Rollback
Revert `_lib` import về `../../tools/kitgen/yaml.mjs`, xóa `.kit/hooks/yaml.mjs` + `cli.mjs` + init copy-step + doctor yaml-check; `package.json` bin về `kit`/`kitgen`. Output không đổi.

## Còn lại P1
Skills P1 (`security-review`, `guard-design`, `release-check`) — bước cuối của P1. Publish npm thật = thao tác thủ công của HO. Go adapter = P2.
