# Refactor Design — từ SIXMEN ERP kit → Universal Agent Kit (vibe-code first)

> Trạng thái: **DRAFT để Human Owner duyệt** · Ngày: 2026-07-01
> Quyết định đã chốt: (1) `AGENTS.md` canonical + generator · (2) EN mặc định + VI locale · (3) làm design doc trước
> Phạm vi: thiết kế lại kit để **bất kỳ ai / bất kỳ stack nào** dùng được, tối ưu cho **vibe coding**, giữ ERP như một profile.

---

## 1. Mục tiêu & nguyên tắc

**Mục tiêu**
1. Một người lạ, stack bất kỳ, `init` xong là chạy được trong vài phút.
2. Vibe coder không bị ceremony cản đường — nhưng vẫn được **guardrail an toàn** (không xoá data, không phá prod).
3. Khi dự án cần kỷ luật (fintech/ERP) → bật `strict` là có ngay hành vi ERP hiện tại, **không mất gì**.
4. Hết drift đa nền tảng: sửa 1 nơi, sinh ra tất cả.

**Nguyên tắc thiết kế**
- **Tách Engine ↔ Domain.** Engine không biết Laravel/ERP là gì.
- **Progressive disclosure.** Mặc định nhẹ; ceremony chỉ xuất hiện khi rủi ro cao hoặc mode cao.
- **Config-driven, không hardcode.** Stack, ngôn ngữ, mode, approver, invariants → khai báo trong 1 file.
- **Single source → generate.** `AGENTS.md` (+ engine fragments) là nguồn; các file agent-specific được sinh ra, không sửa tay.
- **Token-lean.** Phần luôn-nạp ép < 200 dòng; chi tiết load theo trigger.

---

## 2. Kiến trúc 3 lớp

```
┌─────────────────────────────────────────────────────────┐
│ CONFIG   kit.config.yaml   (mỗi project 1 file)          │
│   stack · language · mode · approvers · invariants       │
└───────────────┬─────────────────────────────────────────┘
                │ đọc bởi
┌───────────────▼─────────────────────────────────────────┐
│ ENGINE   (universal, stack-agnostic — KHÔNG biết ERP)    │
│   roles/        planner·architect·implementer·reviewer·qa │
│   thinking/     risk tier 0–3 (generic)                   │
│   guardrails/   destructive-op guard                      │
│   orchestrator/ điều phối + closeout                      │
│   i18n/         en/ (default) · vi/                        │
└───────────────┬─────────────────────────────────────────┘
                │ cắm thêm
┌───────────────▼─────────────────────────────────────────┐
│ PROFILES  (stack pack — pluggable)                       │
│   generic/      web-app / CLI mặc định                    │
│   laravel-erp/  ← nội dung SIXMEN hiện tại đóng gói lại    │
│   nextjs/  python/  go/  …                                │
└───────────────┬─────────────────────────────────────────┘
                │ generator sinh ra
┌───────────────▼─────────────────────────────────────────┐
│ GENERATED  (đừng sửa tay — dán marker "DO NOT EDIT")     │
│   CLAUDE.md · .cursor/rules/*.mdc                         │
│   .github/copilot-instructions.md · .windsurfrules · …    │
└─────────────────────────────────────────────────────────┘
```

---

## 3. `kit.config.yaml` — trái tim của bản refactor

```yaml
# kit.config.yaml
version: 2

project:
  name: "My App"
  language: en            # en | vi   (default en)

mode: vibe                # vibe | standard | strict

stack:
  profile: nextjs         # generic | nextjs | laravel-erp | python | ...
  test:  "npm test"       # profile cung cấp default, project override
  lint:  "npm run lint"
  build: "npm run build"

agents:                   # sinh file cho agent nào
  - claude                # → CLAUDE.md
  - cursor                # → .cursor/rules/*.mdc
  - copilot               # → .github/copilot-instructions.md
  # - windsurf, codex, gemini ...

# Ai phải duyệt các hành động rủi ro. vibe mode: để trống = tự-duyệt.
approvers:
  schema_change: []       # [] = không cần ai; ["@khanh"] = phải hỏi
  prod_deploy: []
  data_delete: []

# "Đường không được bypass" — thay cho tồn/tiền/COGS hardcode.
# Engine đọc để cảnh báo khi diff chạm vào.
invariants:
  - path: "src/payments/**"
    rule: "Mọi thay đổi tiền phải qua PaymentService + có test"
  - path: "**/migrations/**"
    rule: "Đổi schema cần migration note + approver schema_change"

guardrails:
  block:                  # thao tác cấm cứng (mặc định của engine + project thêm)
    - "rm -rf /"
    - "git push --force"
    - "DROP TABLE"        # ở prod
  allow_extra: []         # project nới thêm nếu cần
```

Ý tưởng: **toàn bộ tính "ERP-riêng" biến thành dữ liệu trong file này**, không còn nằm trong rule cứng.

---

## 4. Ba mode — cái gì bật/tắt

| Khả năng | `vibe` (default) | `standard` | `strict` (=ERP hiện tại) |
|---|:---:|:---:|:---:|
| Guardrail thao tác nguy hiểm | ✅ | ✅ | ✅ |
| Cảnh báo khi chạm `invariants` | ✅ (warn) | ✅ (warn) | ✅ (**block** tới khi approve) |
| Bắt viết task-brief trước code | ❌ | ngắn | ✅ đầy đủ (4 lăng kính) |
| Artifact folder `artifacts/{Task-ID}` | ❌ | tuỳ chọn | ✅ bắt buộc |
| Self-review / adversarial review | khuyến khích | ✅ | ✅ + reviewer riêng |
| Chạy test trước khi báo "xong" | nếu có test | ✅ | ✅ + QA gate 07 |
| Human approver cho schema/prod/data | tự-duyệt | hỏi nếu cấu hình | ✅ **STOP tới khi duyệt** |
| Closeout ghi lại đã làm | 1 dòng | tóm tắt | full handoff 09 |
| Thinking level ép trước trả lời | chỉ khi rủi ro cao | ✅ | ✅ mọi task |

> Vibe coder sống ở cột 1: **tốc độ + an toàn tối thiểu**. ERP sống ở cột 3. Cùng engine.

---

## 5. Generator — `AGENTS.md` → mọi thứ

**Cơ chế:** engine + profile cung cấp các **fragment** có marker; generator ghép theo `kit.config` rồi ghi ra từng target với cùng nội dung, khác định dạng/frontmatter.

```
kit build            # đọc kit.config.yaml → sinh generated files
kit build --check    # CI: fail nếu generated khác với source (chống sửa tay)
```

- Mỗi file sinh ra mở đầu bằng:
  `<!-- GENERATED FROM AGENTS.md + kit.config — DO NOT EDIT. Run: kit build -->`
- **Cursor** `.mdc`: generator tự thêm YAML frontmatter (`alwaysApply`, `globs`) theo loại rule.
- **Copilot** `.github/copilot-instructions.md`: gộp phần always-on.
- **Claude** `CLAUDE.md`: giữ import `@AGENTS.md`; chỉ phần luật-cứng tối thiểu.
- **i18n:** generator chọn `i18n/{language}/` → cùng structure, khác chuỗi.

Kết quả: hết mirror chép tay; thêm agent mới = thêm 1 "emitter", không đụng nội dung.

---

## 6. Bảng generalize (đổi tên / trừu tượng hoá)

| ERP hiện tại | Universal engine | Ghi chú |
|---|---|---|
| `sixmen-orchestrator` … `sixmen-qa` | `roles/{planner,architect,implementer,reviewer,qa,devops}` | bỏ tiền tố brand |
| `Human Owner (Khanh/Vũ/CEO)` | `approvers.*` trong config | vibe = rỗng = tự duyệt |
| `InventoryService/MaterialInventoryService/CogsService` (tồn/tiền) | `invariants[]` (path + rule) | project tự khai |
| `DocumentNumberService` | invariant tuỳ dự án | không hardcode |
| Mutation chain Laravel (FormRequest→Policy→Service→tx→audit) | về profile `laravel-erp`; engine chỉ giữ "mutation qua 1 cửa + audit" | stack-specific |
| `artifacts/{Task-ID}/00..09` | task log **tuỳ mode** | ẩn ở vibe |
| `docs/erp/*`, ERD GĐ0/GĐ1 | profile `laravel-erp/docs-map` | domain content |
| `hethongtuduy` (Mức 0–3) | `thinking/risk-tier` (0–3) | giữ ý tưởng, đổi tên trung tính |
| PostgreSQL roles `sixmen_app/report/migration` | profile guardrail example | ví dụ, không bắt buộc |
| Tiếng Việt inline | `i18n/vi/` | EN thành default |
| guard-shell (Docker volume…) | `guardrails/` generic + `allow_extra` | giữ, tổng quát hoá |

---

## 7. Roles generic (đổi từ 9 sixmen-role)

| Role | Trách nhiệm | Thay cho |
|---|---|---|
| `orchestrator` | điều phối, route, closeout | sixmen-orchestrator |
| `planner` | brief, scope, DoD | it-manager + ba |
| `architect` | boundary, impact | architect |
| `implementer` | viết code theo envelope | backend + frontend |
| `reviewer` | review / adversarial | (self-review) |
| `qa` | test, gate | qa |
| `devops` | deploy, backup, guardrail vận hành | devops |

> 9 role ERP gộp còn ~7 role phổ quát; profile có thể *thêm* role riêng (vd `dba` cho laravel-erp).

---

## 8. Guardrails (giữ điểm mạnh, generic hoá)

- Danh sách **block mặc định** trong engine: `rm -rf`, `git push --force`, `git reset --hard` trên nhánh chính, `DROP/TRUNCATE/DELETE` không WHERE, xoá volume, prod deploy không confirm.
- Project **nới** qua `guardrails.allow_extra`.
- Cơ chế thực thi: hook `PreToolUse` (Claude) / shell wrapper (Cursor) — port từ `guard-shell-core.sh` hiện có (đã tốt).
- **Đây là thứ khiến vibe coding an toàn mà không phiền** → ưu tiên giữ chất lượng.

---

## 9. i18n

```
engine/i18n/
  en/   ← default, dịch toàn bộ chuỗi hiện tại sang EN
  vi/   ← giữ nguyên tiếng Việt hiện có
```
- Generator đọc `project.language`.
- Nội dung song song 1-1; tránh song ngữ inline (đắt token).

---

## 10. ERP thành 1 profile — di trú thế nào

`profiles/laravel-erp/` gói lại (gần như bê nguyên):
- Mutation chain + critical services (thành invariants mặc định của profile)
- Doc map `docs/erp/*`, ERD, phase gates
- Rule Laravel/Filament/Pest/PHPStan
- Mã chứng từ, tồn/tiền/COGS
- `mode: strict` mặc định cho profile này

→ SIXMEN chạy y hệt hôm nay, chỉ khác nó là **1 profile** thay vì toàn bộ kit. **Không phá cái đang chạy.**

---

## 11. Trải nghiệm khởi tạo (quan trọng cho vibe)

```
$ kit init
? Project name:            My App
? Language:                (en) / vi
? Stack profile:           generic / nextjs / laravel-erp / python
? Strictness:              (vibe) / standard / strict
? Agents to generate for:  [x] claude [x] cursor [ ] copilot ...
→ writes kit.config.yaml + runs `kit build`
→ ready. Mở agent bất kỳ, nó đã có guardrail + orchestrator.
```
Học mô hình `specify` CLI (GitHub spec-kit) — bootstrap 1 lệnh.

---

## 12. Roadmap thực thi (sau khi duyệt doc này)

| Phase | Sản phẩm | DoD |
|---|---|---|
| **P0 – Skeleton** | `engine/` rỗng có cấu trúc + `kit.config.yaml` schema + `profiles/generic` | init tay chạy được ở vibe |
| **P1 – Generator PoC** | `kit build` sinh CLAUDE.md + .cursor từ source; `--check` cho CI | 1 nguồn → 2 target khớp |
| **P2 – Generalize engine** | đổi tên roles, thinking-tier, guardrails generic, 3 mode | vibe/standard/strict chuyển được bằng config |
| **P3 – i18n** | tách `i18n/en` + `i18n/vi` | build EN & VI đều ra đúng |
| **P4 – ERP → profile** | đóng gói `laravel-erp` từ nội dung hiện tại | SIXMEN chạy như cũ qua profile |
| **P5 – Multi-agent + init CLI** | thêm copilot/windsurf emitter + `kit init` | init 1 lệnh, 3+ agent |
| **P6 – Docs + ví dụ** | README EN, quickstart, 1 demo task mỗi mode | người lạ dùng được không cần hỏi |

---

## 13. Rủi ro & what-if

| Tình huống | Rủi ro | Giảm thiểu |
|---|---|---|
| Người sửa tay file generated | drift ngầm | header "DO NOT EDIT" + `kit build --check` trong CI |
| Vibe mode quá lỏng → mất data | guardrail bị tắt nhầm | block list **không tắt được** ở mọi mode; chỉ nới, không bỏ |
| Config sai (invariant path lệch) | cảnh báo vô dụng | `kit validate` kiểm path tồn tại |
| ERP di trú làm hỏng hành vi cũ | regress SIXMEN | P4 giữ profile = snapshot nội dung hiện tại, test trước/sau |
| Token luôn-nạp vẫn nặng | chậm/đắt | ép < 200 dòng, đo bằng `kit build --report-tokens` |
| Quá nhiều mode gây rối | người dùng bối rối | default `vibe`, tài liệu chỉ 1 câu/ mode |

---

## 14. Câu hỏi mở cho Human Owner (không chặn P0)

1. Ngôn ngữ generator/CLI: viết bằng gì? (đề xuất: **Node** vì đa số vibe stack có sẵn; hoặc **Python** như spec-kit). 
2. Tên brand kit universal? (vd `agentkit`, `vibekit`) — ảnh hưởng lệnh `kit`.
3. Có publish npm/pip để `npx`/`uvx` chạy trực tiếp không, hay chỉ template repo?

---

---

## 15. Nhất quán cho người KHÔNG biết code (bài toán quan trọng nhất)

**Vấn đề:** người không biết code không điền nổi `kit.config`/`invariants`, không đọc được code để sửa sai, và mỗi session agent "khởi động lại tư duy" → codebase thành chắp vá. Vibe mode "nhẹ ceremony" của §4 **chưa giải được** — với nhóm này, nhẹ ceremony = agent càng tự do = càng rời rạc.

**Nguyên lý:** chuyển việc-giữ-nhất-quán từ **người → hệ thống**. Người chỉ làm ở tầng *ý định*; agent + engine giữ nhất quán. Vibe mode ≠ "không quy trình" mà là **"quy trình vô hình với người dùng"**. Hai cần gạt:
- **(A) Giảm bậc tự do của agent** — opinionated, 1-cách-duy-nhất; rời rạc đến từ *quyết-định-lại*, bỏ nó đi.
- **(B) Trí nhớ quyết định bền, agent BẮT BUỘC tuân mỗi phiên.**

### 6 cơ chế (bổ sung vào `engine/`)

| # | Cơ chế | Nội dung | Chủ thể |
|---|---|---|---|
| 1 | **Constitution** | init → agent phỏng vấn bằng lời thường (làm gì / ai dùng / tuyệt đối cấm gì) → tự sinh `kit.config` + nguyên tắc bất biến. Người **không đụng YAML**. Đổi constitution cần confirm rõ ràng. | agent hỏi |
| 2 | **Decision Log** (append-only) | mọi lựa chọn kỹ thuật (lib, cấu trúc, naming, pattern) ghi vào `decisions.md` (plain + structured). **Mỗi phiên đọc trước khi code, phải tuân.** Generalize `shared-memory.md`+orient của ERP. | agent tự ghi |
| 3 | **Opinionated defaults** | profile vibe khoá 1 router / 1 styling / 1 data layer / 1 quy ước folder. Agent không tự chế mỗi phiên. | profile |
| 4 | **Consistency Guard** | trước khi viết code mới, checklist: đã có sẵn chưa? có đẻ *cách thứ 2* cho cùng việc không? Nếu có pattern song song → STOP, giải thích tiếng người, hỏi. Phần đo được → lint (2 state lib / 2 hệ CSS). | engine + lint |
| 5 | **Checkpoint tiếng người** | sau mỗi mốc: tóm tắt phi kỹ thuật + cái gì đổi + yes/no/đổi. Người không đọc code. | agent |
| 6 | **`/checkup`** | audit dự án so với constitution + decision-log → báo drift bằng lời thường + đề nghị fix. Vì người dùng không tự thấy drift. | agent theo lệnh |

### Bật theo mode

| Cơ chế | vibe | standard | strict |
|---|:--:|:--:|:--:|
| Constitution + Decision Log | ✅ (agent tự) | ✅ | ✅ (= artifact chain) |
| Opinionated defaults | ✅ khoá chặt | ✅ | nới (dev tự quyết) |
| Consistency Guard | ✅ | ✅ | ✅ |
| Checkpoint tiếng người | ✅ | tóm tắt | kỹ thuật |
| `/checkup` | ✅ | ✅ | = validate-artifacts |

> Với người không biết code, nhất quán KHÔNG đến từ "làm kit dễ hơn", mà từ (A) bớt tự do của agent + (B) ép agent tuân trí nhớ quyết định. ERP kit đã có mầm (orient bắt buộc, shared-memory, artifact chain); phần này chỉ generalize + bật mặc định ở vibe.

---

---

## 16. Nền tảng kỹ thuật Claude Code + mapping generator

> Tổng hợp từ docs chính thức (memory · settings · hooks · skills · sub-agents · commands). Nguồn ở cuối §.

### 16.1 Phát hiện đổi hướng thiết kế

1. **`.claude/rules/` là NATIVE + path-scoped** — Claude tự quét, mỗi file có frontmatter `paths: ["src/**/*.ts"]` → **chỉ nạp khi đọc file khớp**; rule không có `paths` → nạp mọi lượt. Đây là tương đương 1-1 của Cursor `.mdc` (`alwaysApply` / `globs`).
   - **Sửa kit hiện tại:** bỏ `@.claude/rules/...` (đang nạp cứng mọi lượt, tốn token) → dùng rule native path-scoped → tự đạt best-practice <200 dòng luôn-nạp.
2. **Hooks = động cơ guardrail + consistency.** `PreToolUse` chặn được (exit 2 / `permissionDecision:deny`); `SessionStart` trả `additionalContext` để **bơm Decision Log + Constitution mỗi phiên**.
3. **Skill token model:** chỉ *description* nằm sẵn context; *full* nạp khi invoke → progressive disclosure đúng như §15.

### 16.2 Mapping cơ chế engine → primitive Claude → primitive khác

| Cơ chế engine | Claude Code | Cursor | Copilot |
|---|---|---|---|
| Luật cứng luôn-nạp (tối thiểu) | `CLAUDE.md` (project) | `.mdc alwaysApply:true` | `copilot-instructions.md` |
| Rule bật theo file | `.claude/rules/*.md` + `paths:` (native) | `.mdc` + `globs:` | (gộp, không path-scope) |
| Role/subagent | `.claude/agents/*.md` frontmatter `name/description/tools/model` | skill `@role` | — |
| Skill người+AI gọi | `.claude/skills/<n>/SKILL.md` | `.cursor/skills` | — |
| Lệnh chỉ-người-gọi | SKILL `disable-model-invocation:true` | command manual | — |
| **Destructive-op guard** | hook `PreToolUse` (exit 2 / deny) + `permissions.deny[]` | shell guard wrapper | — |
| **Consistency Guard** | hook `PreToolUse` trên Write/Edit | (thủ công) | — |
| **Bơm Constitution+DecisionLog mỗi phiên** | hook `SessionStart` → `additionalContext` | rule alwaysApply nhỏ | — |
| Closeout/verify | hook `Stop` (block nếu thiếu) | — | — |

### 16.3 Ràng buộc kỹ thuật generator PHẢI tuân

- **CLAUDE.md:** 5 tầng (managed > user > project > local > subdir), tất cả *concat* không override; `@import` **tối đa 4 hop**, resolve theo *file chứa* (không theo cwd); backtick `` `@x` `` = literal.
- **settings.json precedence:** managed > CLI > local > project > user; **`permissions` merge across scopes** (allow/deny/ask cộng dồn), các key khác override.
- **Hook output:** exit `0` = xử lý JSON stdout; exit `2` = block (stderr hiện ra); khác = lỗi non-blocking. Chỉ `PreToolUse` + `WorktreeCreate` *fail-closed*, còn lại fail-open. Chuỗi hook cap 10.000 ký tự.
- **PreToolUse block:** `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"..."}}` — hoặc đơn giản exit 2.
- **SessionStart inject:** `{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"<decision-log tóm tắt>"}}`.
- **Subagent frontmatter:** `name`(bắt buộc, lowercase-hyphen), `description`(bắt buộc, ≤1536 ký tự gộp `when_to_use`), `tools`(allowlist, thiếu=inherit), `model`(sonnet/opus/haiku/inherit), `isolation: worktree` cho agent sửa file song song.
- **Skill frontmatter:** `description`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `paths`, `argument-hint`, `arguments`; substitution `$ARGUMENTS/$N/$name`, `${CLAUDE_PROJECT_DIR}`, `!\`cmd\`` chạy preprocessing trước khi Claude thấy.
- **Marker:** mọi file generated mở đầu `<!-- GENERATED — DO NOT EDIT. Run: kit build -->`; `kit build --check` so sánh trong CI.

### 16.4 Cách 6 cơ chế §15 hiện thực bằng Claude primitive

| §15 | Hiện thực |
|---|---|
| 1 Constitution | `kit init` phỏng vấn → ghi `.kit/constitution.md` + `kit.config.yaml`; SessionStart hook bơm tóm tắt |
| 2 Decision Log | append `.kit/decisions.md`; SessionStart `additionalContext` nạp mỗi phiên; PostToolUse ghi khi có quyết định mới |
| 3 Opinionated defaults | profile = bộ `.claude/rules` + subagents khoá 1-cách-làm |
| 4 Consistency Guard | PreToolUse trên Write/Edit gọi script check pattern trùng → deny + lý do tiếng người |
| 5 Checkpoint tiếng người | role `orchestrator` + Stop hook nhắc tóm tắt phi kỹ thuật |
| 6 `/checkup` | skill `user-invocable`, audit repo vs constitution+decisions |

**Nguồn:** [memory](https://code.claude.com/docs/en/memory.md) · [settings](https://code.claude.com/docs/en/settings.md) · [hooks](https://code.claude.com/docs/en/hooks.md) · [skills](https://code.claude.com/docs/en/skills.md) · [sub-agents](https://code.claude.com/docs/en/sub-agents.md) · [commands](https://code.claude.com/docs/en/commands.md)

---

*Duyệt doc này → em bắt đầu P0 (skeleton) + P1 (generator PoC) như đã chốt ở lựa chọn "làm design trước".*
