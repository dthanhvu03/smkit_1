# P1 Skills + Close — DONE

> Ngày: 2026-07-01 · Ref: [03 §14](03-engineer-audit.md) · [05 doctor](05-P1-doctor-design.md) · [06 guard v2](06-P1-guard-v2-design.md) · [07 distribution](07-P1-distribution-design.md)
> Trạng thái: **P1 hoàn tất.** Không Go/Studio/DevOps/dependency mới.

## Skills P1 (bước 3/3)
Thêm 3 skill (định dạng như P0: frontmatter `id/name/description/paths/related_*` + body Workflow + **Output format**):

| Skill | Dùng khi | Role | Output |
|---|---|---|---|
| `security-review` | đụng auth/secret/shell/file/guard | reviewer | Attack surface · Risks(table) · Guardrail gaps · Verdict |
| `guard-design` | thêm/sửa hooks/guardrails | architect/reviewer | Decision table BLOCK/WARN/ALLOW · Bypass covered · Residual risk · Tests · Rollback |
| `release-check` | trước publish/release | devops/qa | Checklist · Version+changelog · Evidence · Go/No-go |

**Changed files:** `engine/skills/{security-review,guard-design,release-check}/SKILL.md` (mới) · `test/golden/**` (regenerated 38→**44**). Không đụng generator/roles/rules/hooks.

## P1 — tổng kết (4 mảng)
| Mảng | Trạng thái | Doc |
|---|---|---|
| `doctor` command | ✅ | [05](05-P1-doctor-design.md) |
| Guard v2 (segment + path-boundary + audit + BLOCK/WARN/ALLOW) | ✅ | [06](06-P1-guard-v2-design.md) |
| Distribution (self-contained + `smkit` CLI) | ✅ | [07](07-P1-distribution-design.md) |
| Skills P1 (3 skill) | ✅ | (this) |

## Evidence (cuối P1)
```
npm run build  → Built 44 file(s) → dist/
npm run check  → OK — 44 generated file(s) in sync
npm run doctor → 0 error(s), 0 warning(s)
npm test       → tests 28 | pass 28 | fail 0
```
Kit giờ có: 7 roles · 4 commands · **6 skills** (3 P0 + 3 P1) · 3 rules (+enforce) · 4 profiles · guard v2 · doctor · 5 output targets (AGENTS.md/CLAUDE/Cursor/Copilot/Windsurf) · self-contained `smkit` install.

## Follow-up — invariants → per-IDE rules (post-P1)
Từ đối chiếu spec Anthropic/Cursor/Windsurf (Windsurf verify: dùng `trigger:` frontmatter, **không** XML — XML là `.windsurfrules` legacy):
- kitgen giờ map `kit.config.invariants[]` (`{path, rule}`) → **cursor** `.cursor/rules/invariant-N-<slug>.mdc` (`globs`+`alwaysApply:false`+`description`) và **windsurf** `.windsurf/rules/invariant-N-<slug>.md` (`trigger: glob`+`globs`).
- **Trơ khi `invariants: []`** → golden/dist không đổi (44 in-sync); chỉ sinh khi khai báo invariant.
- Test mới khẳng định windsurf ra `trigger: glob`, **không** `<rule>` XML.
- Test: `npm test` → 29 pass.

## Consolidation — 1 transformer layer (single source of truth)
Gộp về một mối theo Hướng 2 (refactor):
- **`engine/emitter.mjs`** giờ là **transformer layer duy nhất** — 1 class/IDE (`AgentsMd/Claude/Cursor/Copilot/Windsurf Emitter`) sau `EMITTERS` registry + `buildOutputs()` (pure, trả `Map<path,content>`) + `collect*`/`loadStrings`/`denyFromGuardrails` (export cho doctor). Port **byte-identical** từ kitgen.
- **`tools/kitgen/kitgen.mjs`** thành **orchestrator**: đọc config, gọi `buildOutputs`, ghi đĩa, `check`/`doctor`. Bỏ toàn bộ emit inline.
- **Golden byte-exact là trọng tài**: refactor xong `npm test` **29 pass**, `check` **44 in-sync**, `doctor` 0 error → output không đổi 1 byte.
- Hết "2 nơi làm cùng việc" → đúng nguyên tắc consistency (tránh AI drift khi bảo trì kit). Thêm IDE mới = 1 class + 1 dòng registry.

## Ngoài P1 (để P2 / thủ công)
- `npm publish` thật (thủ công của HO).
- **Go adapter** guard (mvdan.cc/sh AST, Node fallback) — P2.
- Next.js Studio · Docker/CI · tiered spec-driven · progressive-disclosure skills — P2.
- Audit log tamper-evident · `doctor --fix/--strict/--quiet` — enhancement.
