# P0 + P1 — Skeleton + Generator PoC (DONE)

> Ngày: 2026-07-01 · Ref thiết kế: [00-refactor-design.md](00-refactor-design.md)
> Trạng thái: **chạy được**. Single source → multi-target generation + guardrail hooks đã verify.

## Đã dựng

```
kit.config.yaml              # single source (mode/stack/agents/guardrails/approvers/invariants)
engine/
  rules/00-hard-rules.md     # scope: always  (luật cứng, tối thiểu)
  rules/10-consistency.md    # scope: paths   (chỉ nạp khi đọc file code)
  roles/*.md                 # 7 role → subagent (orchestrator/planner/architect/implementer/reviewer/qa/devops)
  i18n/{en,vi}/strings.yaml  # EN default + VI locale
profiles/generic/            # profile mặc định (profile.yaml + rules/conventions.md)
.kit/
  constitution.template.md   # §15 cơ chế 1
  decisions.template.md      # §15 cơ chế 2
  hooks/guard-shell.mjs      # PreToolUse(Bash) — chặn lệnh nguy hiểm mọi mode (exit 2)
  hooks/session-start.mjs    # SessionStart — bơm Constitution+Decision Log vào context
  hooks/consistency-guard.mjs# PreToolUse(Write|Edit) — nhắc consistency
tools/kitgen/
  yaml.mjs                   # YAML subset parser (zero-dep)
  kitgen.mjs                 # generator: build | check
dist/                        # OUTPUT (không đụng CLAUDE.md/.claude ERP hiện có)
```

## Lệnh

```
node tools/kitgen/kitgen.mjs build    # sinh file vào dist/
node tools/kitgen/kitgen.mjs check    # CI: exit 1 nếu dist lệch source
```

## Đã verify (bằng chứng)

| Kiểm chứng | Kết quả |
|---|---|
| 1 nguồn → 2 nền tảng | `kit.config.yaml` → 15 file: CLAUDE.md + `.claude/{rules,agents,settings.json}` + `.cursor/rules/*.mdc` |
| Rule always vs path-scoped | hard-rules = always (no `paths`); consistency = `.claude/rules paths:` ↔ Cursor `globs:` + `alwaysApply:false` |
| Guardrail chặn thật | `git push --force` → exit 2 + message; `npm test` → exit 0 |
| SessionStart bơm memory | trả `additionalContext` (Constitution + Decision Log) |
| Drift detection | đổi config → `check` exit 1, liệt kê 15 file lệch |
| i18n | `language: vi` → banner + note ra tiếng Việt; `en` mặc định |
| An toàn | output vào `dist/`; không ghi đè kit ERP hiện có |

## Chưa làm (phase sau — xem roadmap §12)

- **P2** generalize sâu (3 mode nới/siết đầy đủ; Consistency Guard bản có logic phát hiện pattern trùng thật).
- **P3** dịch toàn bộ chuỗi engine sang EN + hoàn thiện VI locale.
- **P4** đóng gói `profiles/laravel-erp` từ nội dung SIXMEN hiện tại (giữ hành vi cũ).
- **P5** thêm emitter `copilot`/`windsurf` + `kit init` (phỏng vấn → sinh config + constitution).
- **P6** README EN + demo mỗi mode.

## Cập nhật (universal-ready pass)

- **Tách brand:** ERP cũ → `examples/sixmen-erp/` (AGENTS.md, CLAUDE.md, docs/ai-agent, .githooks). `.cursor`/`.claude` còn ở root vì IDE lock → chạy `examples/sixmen-erp/finish-move.{sh,ps1}` sau khi đóng IDE.
- **Phân phối:** `package.json` (bin `kit`/`kitgen`, scripts init/build/check, zero-dep, node≥18) + `.gitignore` + README 3 cách cài (`npx degit` / scripted / npm).
- **#3 deny tốt hơn:** generator emit `Bash(cmd:*)` (colon prefix-match), gộp `rm -rf`, + deny secrets (`.env`, `*.key`, `*.pem`, `id_rsa`).
- **#4 targets:** thêm emitter **Copilot** (`.github/copilot-instructions.md` always + `.github/instructions/*.instructions.md` `applyTo` path-scoped) và **Windsurf** (`.windsurf/rules/*.md` với `trigger: always_on|glob`). Tổng 4 nền tảng, 20 file.
- **#4 profiles:** thêm `nextjs`, `python`, `go` (opinionated 1-cách-làm). Verify cả 4 profile parse + build đúng.
- **#2 Consistency Guard có logic thật:** hook phát hiện "cách thứ 2" theo category (state/styling/http/orm/router/data-fetching/test/py-lint) đối chiếu `package.json`. vibe→cảnh báo, strict→**deny**, tái dùng lib có sẵn→cho qua. Đã test 3 case.

## Ghi chú kỹ thuật

- Generator zero-dependency (chỉ Node core). YAML parser tự viết cho subset của kit — không cần `npm install`.
- Hooks viết bằng Node (`.mjs`) để chạy cả Windows/macOS/Linux (Claude Code hook gọi `node ...`).
- `dist/` nên cho vào `.gitignore` khi outDir=dist; khi dùng thật đổi `outDir: .` để ghi vào vị trí chuẩn.
