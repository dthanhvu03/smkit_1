# P0 Implementation — DONE (accepted)

> Ngày: 2026-07-01 · Ref: [03-engineer-audit.md](03-engineer-audit.md) §12 (Decision) + Acceptance + §13 (Mapping) + §14 (Skills/Rules gap)
> Trạng thái: **P0 accepted.** Không triển khai Go/Studio/DevOps/dependency mới. `enforce:` mới là nhãn — việc đọc/kiểm thuộc `doctor` (P1).

## Scope P0 (đã làm)

1. Emit **AGENTS.md** (base cross-agent) từ cùng nguồn.
2. Viết lại 7 role description theo format **"Use when… / Invoke for…"** + **model-tier** + **tool allowlist**.
3. Tách ranh giới **planner↔architect** và **reviewer↔qa** (trigger disjoint).
4. Thêm **`engine/skills/`** với 3 skill: `code-review`, `refactor`, `test-design` (model-invocable → `.claude/skills/*/SKILL.md`).
5. Thêm rule **`15-evidence-gate.md`** + nhãn **`enforce:`** cho mọi rule.
6. **Golden-file tests** (node:test, zero-dep) + `npm test`.

## Changed files

**Mới**
- `engine/rules/15-evidence-gate.md` (`enforce: gate`)
- `engine/skills/code-review/SKILL.md`, `engine/skills/refactor/SKILL.md`, `engine/skills/test-design/SKILL.md`
- `tools/kitgen/kitgen.test.mjs`
- `test/fixture/kit.config.yaml`
- `test/golden/**` (38 file snapshot)

**Sửa**
- `tools/kitgen/kitgen.mjs` — `collectSkills`, `emitAgentsMd`, `emitClaudeSkill`, helper `y()` quote YAML-safe cho description, wire `agentsmd` + skills vào `buildOutputs` (Claude native + Cursor command fallback)
- `kit.config.yaml` — thêm target `agentsmd`
- `engine/roles/*.md` (cả 7) — description trigger + `model` (architect/reviewer=opus · planner/implementer/qa=sonnet · devops=haiku · orchestrator=inherit) + `tools` allowlist (planner/architect/reviewer/orchestrator read-only; implementer=+Edit/Write/Bash; qa/devops=+Bash)
- `engine/rules/00-hard-rules.md`, `engine/rules/10-consistency.md` — thêm `enforce:`
- `profiles/{generic,nextjs,python,go}/rules/conventions.md` — thêm `enforce: agent-read`
- `.kit/hooks/_lib.mjs` — export `DEFAULT_BLOCK` / `makeMatcher` / `matchesBlock` / `loadBlocklist` (guard testable)
- `.kit/hooks/guard-shell.mjs` — dùng `_lib`
- `package.json` — script `test`

## Generated outputs (38 file)

Thêm mới so với trước P0:
- **`AGENTS.md`** — mode + hard-rules + evidence-gate + conventions inline + index Roles/Skills/Commands (đóng gap cross-agent §11.4).
- **`.claude/skills/{code-review,refactor,test-design}/SKILL.md`** — model-invocable (`description`+`paths`).
- `.claude/rules/evidence-gate.md`, `.windsurf/rules/evidence-gate.md`, `.cursor/rules/evidence-gate.mdc`.
- `.cursor/commands/{code-review,refactor,test-design}.md` — fallback cho Cursor (không có model-invoke).

Target đầy đủ: `AGENTS.md` · `CLAUDE.md` · `.claude/{rules,agents,commands,skills,settings.json}` · `.cursor/{rules,commands}` · `.github/copilot-instructions.md` + `.github/instructions/*` · `.windsurf/rules/*`.

## Test / golden evidence

```
npm run build → Built 38 file(s) → dist/
npm run check → OK — 38 generated file(s) in sync (dist/)
npm test      → tests 9 | pass 9 | fail 0
```

Test bao phủ:
- **yaml parser** — `#` trong chuỗi quote giữ nguyên; decode escape `\"`; list; inline `[]`.
- **guard matcher** — `git push --force-with-lease` **ALLOW**; `--force` / lowercase `drop table` / whitespace thừa **BLOCK**; boundary (`warm -rfoo` không dính `rm -rf`).
- **golden snapshot** — so khớp **toàn bộ 38 output** với `test/golden/` (regen: `UPDATE_GOLDEN=1 node --test "tools/kitgen/*.test.mjs"`).
- **AGENTS.md** — có `Hard rules` + `## Roles` + `## Skills`.

Guard E2E (ngoài test): `git push --force-with-lease` → exit 0; `sudo rm -rf /` → exit 2.

## Acceptance criteria — PASS

| Tiêu chí P0 | Kết quả |
|---|---|
| `npm run build` sinh đủ target (gồm **AGENTS.md**) | ✅ 38 file |
| `npm run check` phát hiện drift đúng | ✅ in-sync, exit 1 khi lệch |
| Role không trùng trách nhiệm | ✅ planner(decompose/before-design) ≠ architect(structure); reviewer(static) ≠ qa(runtime) |
| Context always-on không tăng > 20% | ✅ chỉ +1 rule ngắn (`evidence-gate`, ~7 dòng) |
| Không thêm dependency runtime | ✅ dùng `node:test` built-in, zero-dep giữ nguyên |
| ≤ 3 skill P0 | ✅ đúng 3 |

## Risks

- **Model-tier** giả định quyền truy cập opus/haiku; thiếu tier thì Claude Code fallback (không vỡ). Nên cho override qua config ở phase sau.
- **`enforce:`** hiện là metadata source-only (chưa emit, chưa kiểm tự động) — giá trị hiện thực khi `doctor` (P1) đọc.
- **Golden brittle** với thay đổi output có chủ đích → phải chạy `UPDATE_GOLDEN=1` để cập nhật (đã ghi trong test header).
- **Skill `paths: ["**/*"]`** rộng → `description` là cửa gate chính; chấp nhận ở P0.

## Rollback plan (repo không git)

- Tắt AGENTS.md: bỏ `agentsmd` khỏi `agents:` trong `kit.config.yaml` → `npm run build`.
- Tắt skills: xóa `engine/skills/` → build lại (generator tự bỏ).
- Hoàn role: mỗi role là file độc lập; khôi phục frontmatter cũ (tools `Read, Grep, Glob` + `model: inherit`).
- Guard: `_lib` chỉ *thêm* export (API cũ `loadConfig`/`projectDir` giữ nguyên); revert `guard-shell.mjs` về bản inline nếu cần.
- Test/golden là phụ trợ: xóa `test/` + script `test` không ảnh hưởng runtime.

## Explicitly NOT done (ngoài P0)

Go core · Next.js Studio · Docker/K8s/Terraform/CI · `doctor` command · **guard v2** (AST + path-boundary + audit log + BLOCK/WARN/ALLOW) · secret-scan hook · spec-driven change-folder · publish `npx` + npm-dep runtime copy · progressive-disclosure skills · security/guard/release/spec skills. Việc **đọc/kiểm `enforce:`** thuộc `doctor` (P1).

## Next recommended phase: P1

Theo §12 (gate sang P1 đã đạt: `check` PASS · test emitter/golden có · ≥3 scenario guard test) và §13:
1. **`doctor` command** — kiểm node/version, config hợp lệ, invariant path tồn tại, hook cài đúng, **đọc & kiểm nhãn `enforce:`** (rule loại `hook`/`generator` phải có cơ chế thật), drift → fix hint.
2. **Guard v2** — AST + allowlist-by-default + path-boundary theo tầng + audit log + BLOCK/WARN/ALLOW (ưu tiên port Go vì `mvdan.cc/sh`).
3. **Publish `npx` + sửa npm-dep** (init copy runtime `.kit/` vào project).
4. Skills P1: `security-review`, `guard-design`, `release-check`.

*(P1 KHÔNG triển khai trong lượt này.)*
