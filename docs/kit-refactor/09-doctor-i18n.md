# Doctor i18n — DONE

> Ngày: 2026-07-14 · Ref: [05 doctor](05-P1-doctor-design.md)
> Trạng thái: **Hoàn tất.** Không thêm dependency/feature mới — hardening theo yêu cầu "chuẩn chỉnh, zero bug nhỏ" cho end-user kit.

## Vấn đề
`doctor` in cứng tiếng Việt cho MỌI project, kể cả khi `kit.config.yaml` khai `project.language: en`. Phát hiện trong lúc audit đối kháng (adversarial audit) toàn bộ kit trước khi coi là production-ready.

## Thiết kế
- **Catalog** `engine/i18n/{en,vi}/doctor.yaml` — 83 message, key = CODE ổn định (cùng code doctor/`--json` đã dùng), template kiểu `{placeholder}`. `vi` là bản chép nguyên văn (byte-for-byte) từ string cũ để mặc định không đổi 1 ký tự.
- **`loadDoctorStrings(kitDir, lang="vi")`** (emitter.mjs) — cache theo `lang`, fallback **về `vi`** (không phải `en`) nếu thiếu file — giữ đúng audience mặc định gốc của kit.
- **`fmt(strings, code, params)`** — thay `{key}` bằng `params[key]`; dùng `k in params` (không phải `!== undefined`) để giữ đúng hành vi coercion `undefined` → chuỗi `"undefined"` như template literal gốc.
- **`lang` là optional param mặc định `"vi"`** xuyên suốt `validateConfig`/`validateSkillGovernance`/`validateRoleGovernance`/`validateRuleGovernance`/`collectInvariants` → 100% test cũ gọi trực tiếp (không qua CLI) không đổi hành vi.
- **`kitgen.mjs`**: `langOf(cfg) = cfg?.project?.language === "en" ? "en" : "vi"`. Message trước khi parse được config (Node version, file thiếu, parse lỗi) luôn dùng `vi` mặc định vì chưa có cfg để đọc. Sau khi parse xong, toàn bộ `runDoctor` + `main`/`build` dùng `lang` thật.
- **Bỏ check trigger-cue cũ của Roles** (chỉ nhận `/use when|invoke for/i`, không nhận tiếng Việt) — đã có `ROLE_DESCRIPTION_TRIGGER_WEAK` (governance, đa ngôn ngữ, heuristic tốt hơn) thay thế.
- **Đi kèm (fix luôn vì đang sửa mọi dòng)**: mọi `err/warn/ok` trong `runDoctor` giờ đều mang `code` — trước đây một số message (`NODE_TOO_OLD`, `HOOKS_MISSING_FILE`, `SKILLS_P0_*`, `ROLES_*`, v.v.) có `code: null` trong `--json`, phá vỡ hợp đồng machine-readable (F-11) khi client match theo code thay vì text dịch.

## Phạm vi cố ý bỏ qua (residual gap)
8 code cảnh báo từ `collectBuildWarnings` (schema/migration/target-capability, vd. `SKILL_NAME_MISMATCH`, `SKILL_PATHS_TRIVIAL_DROPPED`...) đã có entry trong catalog nhưng **chưa** route qua `fmt()` — kiến trúc khác (structured warning object từ nhiều nguồn), rủi ro regression cao hơn so với lợi ích trong đợt này. Method: `.message` build sẵn trong emitter.mjs, không đổi.

## Evidence
```
npm test        → tests 101 | pass 101 | fail 0
node kitgen.mjs check  → OK — 50 generated file(s) in sync (dist/)   ← output không đổi 1 byte
node kitgen.mjs doctor (language: en, repo thật) → toàn bộ message tiếng Anh, 0 error/0 warning
node kitgen.mjs doctor (language: vi, bản dogfood cô lập) → "[CONFIG_VALID] kit.config.yaml hợp lệ"
```

## Test
Sửa 7 assertion CLI-level (`runKit(...).stdout`) khớp fixture `test/fixture/kit.config.yaml` (`language: en`) từ prose tiếng Việt cứng sang match theo `[CODE]` — vừa hết phụ thuộc ngôn ngữ vừa bền hơn khi câu chữ đổi. Assertion gọi hàm trực tiếp (không qua CLI, không truyền `lang`) giữ nguyên vì mặc định vẫn là `vi`.
