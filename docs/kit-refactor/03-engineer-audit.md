# Engineer Audit — SM Kit (vibe coding kit)

> Ngày: 2026-07-01 · Người audit: Staff-level review · Scope: toàn bộ source hiện tại (730 dòng code + markdown/yaml)
> Phương pháp: đọc thật từng file (không audit bằng cảm giác) + benchmark 20+ repo GitHub qua web research.
> Nguồn liên quan: [00-refactor-design](00-refactor-design.md) · [01-P0-P1-status](01-P0-P1-status.md) · [02-review-and-fixes](02-review-and-fixes.md)

## Inventory (cây thư mục thật)

```
kit.config.yaml · package.json · README.md · .gitignore
engine/  rules/(2)  roles/(7)  commands/(4)  i18n/{en,vi}
profiles/  generic · nextjs · python · go   (mỗi cái profile.yaml + rules/conventions.md)
.kit/  constitution.template.md · decisions.template.md · hooks/{_lib,guard-shell,session-start,consistency-guard}.mjs
tools/kitgen/  yaml.mjs(105) · kitgen.mjs(253) · init.mjs(169)
docs/kit-refactor/  00,01,02 (+ this 03)
examples/sixmen-erp/   ← kit ERP cũ (đã tách)
dist/                  ← generated output (gitignored)
```
Code thực thi: **730 dòng** (3 file kitgen 527 + 4 hook 203). Phần còn lại là markdown/yaml (rules/roles/commands/profiles/i18n).
Lưu ý: không có `roles/`/`rules/` ở top-level như prompt giả định — chúng nằm dưới `engine/`.

---

# 1. Audit tổng quan

## 1.1 Repo hiện tại là gì?

**Phân loại: HYBRID — chính xác là "single-source cross-agent generator + agent operating kit + Claude-hook guard kit", ở giai đoạn early prototype.**

| Nhóm ứng viên | Có phải không? | Dẫn chứng |
|---|---|---|
| Prompt pack | ❌ Không | Có generator thật (`tools/kitgen`), hook thực thi (`.kit/hooks/*.mjs`), không phải chỉ text |
| Agent rules kit | ✅ Một phần | `engine/rules`, `profiles/*/rules` → `.claude/rules` + `.cursor/rules` |
| Claude Code hook kit | ✅ Một phần | `.kit/hooks/{guard-shell,session-start,consistency-guard}.mjs` + `emitSettings` sinh `hooks` |
| CLI generator kit | ✅ Lõi | `kitgen.mjs build/check` + `init.mjs` — 1 nguồn → 4 target |
| Multi-agent operating kit | ✅ Một phần | 7 roles + 4 commands + orchestrator, nhưng chưa có workflow enforce |
| Full product platform | ❌ Chưa | Không có Go core, không Next.js Studio, không UI, không CI/DevOps |
| Hybrid / chưa rõ ranh giới | ✅ Đúng nhất | Kết hợp 4 nhóm trên, ranh giới source/runtime chưa sạch (§2.1) |

→ Đúng "họ hàng" với **ruler / block-ai-rules** (one-source→many-agents) cộng lớp vibe/mode + guard. **Chưa** ở tầm spec-kit/OpenSpec (chưa có spec-driven workflow) và chưa phải platform.

## 1.2 Thành phần hiện có

| Nhóm | File/folder | Mục đích | Đánh giá |
|---|---|---|---|
| Rules | `engine/rules/{00-hard,10-consistency}`, `profiles/*/rules/conventions.md` | Luật always-on + path-scoped | ✅ Tốt: đã tách always vs paths, map đúng sang `.mdc` glob |
| Roles | `engine/roles/*.md` (7) | Subagent định nghĩa | 🟡 Đủ số lượng chuẩn nhưng description chưa tối ưu routing (§11) |
| Commands | `engine/commands/{start,checkup,decide,review}.md` | Slash command người dùng | ✅ Nhỏ gọn, đúng hướng |
| Hooks | `.kit/hooks/*.mjs` (4) | Guard + session-start + consistency + _lib | 🟠 Chạy được, fail-closed, nhưng match kiểu regex/substring (điểm yếu bảo mật lớn) |
| Profiles | `profiles/{generic,nextjs,python,go}` | Opinionated stack defaults | 🟡 Mỏng: chỉ rules, chưa có commands/settings riêng theo stack |
| Generator | `tools/kitgen/{yaml,kitgen,init}.mjs` | 1 nguồn → 4 target + init | ✅ Điểm mạnh nhất: có `build`+`check`, zero-dep, đã test |
| Config | `kit.config.yaml` | SoT: mode/stack/agents/guardrails/approvers | ✅ Sạch, khai báo tốt |
| Docs | `docs/kit-refactor/00–03` | Thiết kế + status + review | 🟡 Tốt cho dev, chưa có user docs/site |
| DevOps | — | — | ❌ Không có Docker/CI/Actions |
| Tests | — | — | ❌ Không có test tự động (chỉ manual + `check` drift) |
| Build/Release | `package.json` bin/files | npx/degit | 🟠 Chưa publish; mô hình npm-dep còn lỗi (review #3) |

## 1.3 Độ trưởng thành (0–5)

| Mảng | Điểm | Lý do (dẫn chứng) |
|---|---:|---|
| Cấu trúc repo | 4 | Phân tầng sạch engine/profiles/.kit/tools/docs; trừ ranh giới source/runtime của `.kit/` (§2.1) |
| Khả năng cài đặt | 2 | `init` chạy được qua copy/degit + node; chưa publish npm; npm-dep model đọc/ghi sai (`review #3` đã fix một phần) |
| Chạy thực tế | 3 | generator + 4 hook đã verify chạy; nhưng chỉ "sinh config", không có app/binary |
| Guardrails | 2 | Chặn được lỗi vô ý + fail-closed; nhưng **regex/substring — SOTA nói kiểu này bị bypass được** (§11 nhóm E); không path-boundary, không audit log, không AST |
| Consistency rules | 3 | `consistency-guard` có logic phát hiện dependency trùng thật + rule; nhưng `CATEGORIES` tĩnh/hẹp |
| Profile system | 3 | 4 profile opinionated, hoạt động; nhưng chỉ đóng góp rules |
| Cross-agent export | 4 | Claude+Cursor+Copilot+Windsurf từ 1 nguồn, đúng ngữ nghĩa activation; **hơn ruler** (không concat mù). Thiếu **AGENTS.md** (gap) |
| DevOps | 0 | Không Docker/CI/GH Actions |
| Test coverage | 1 | Không test tự động; `check` chỉ là drift-check |
| Maintainability | 4 | Nhỏ, zero-dep, có docs review; còn ít nợ cleanup đã ghi nhận |
| Product readiness | 1 | Prototype sớm: không UI, chưa phân phối, chưa CI |

**Tổng quan:** lõi generator + cross-agent export **khá** (3.5–4/5); guardrails/tests/devops/distribution **yếu** (0–2/5). Đây là prototype tốt, chưa phải sản phẩm.

---

# 2. Audit kiến trúc

## 2.1 Ranh giới source-kit vs runtime vs generated

| Thư mục | Vai trò hiện tại | Vấn đề |
|---|---|---|
| `engine/` | **Source** (markdown rules/roles/commands/i18n) | Tên "engine" gây hiểu nhầm — nó là **dữ liệu**, không phải engine logic. Engine thật là `tools/kitgen`. Nên đổi tên `content/` hoặc `sources/`. |
| `tools/kitgen/` | **Engine thật** (generator) | Đặt sai chỗ về mặt ngữ nghĩa (là "tools" nhưng lại là lõi). Không phải prototype — đã test, chạy thật. |
| `.kit/` | **LẪN 3 vai** | ⚠️ Chứa: (a) template *source* (`*.template.md`), (b) *runtime code* (`hooks/*.mjs` — chạy trong project người dùng), (c) *user data* lúc chạy (`constitution.md`, `decisions.md`). Ba trách nhiệm khác nhau trong một thư mục. |
| `profiles/` | Source | Sạch |
| `dist/` | **Generated** | Đã `.gitignore` (đúng). Nhưng đây là repo dev nên `outDir: dist`; trong project thật `outDir: .` → file generated nằm cạnh source. |
| `docs/` | Reference | Sạch |
| `examples/sixmen-erp/` | Reference (kit cũ) | Sạch (đã tách) |

**Kết luận ranh giới:** chỗ lẫn duy nhất đáng sửa là **`.kit/`**. Đề xuất tách:
- `.kit/hooks/` (runtime code) → nên là artifact được **cài** vào project (hoặc đóng vào binary), không phải source lẫn với template.
- `*.template.md` → về `engine/templates/` (source).
- `constitution.md`/`decisions.md` (user data) → do `init` sinh, không commit vào kit.

## 2.2 Phù hợp mục tiêu Go + Next.js?

| Câu hỏi | Trả lời |
|---|---|
| Có Go core chưa? | ❌ Chưa. Lõi hiện là Node/MJS (`tools/kitgen`). |
| Có Next.js Studio chưa? | ❌ Chưa. Không có UI. |
| Node/MJS nên đóng vai gì? | **Reference implementation** hiện tại — nơi chốt hành vi + test trước khi port. |

**Khuyến nghị: refactor dần, KHÔNG rewrite ngay.** Lý do có dẫn chứng benchmark:

- **Go core rất hợp cho 3 thứ:** (1) **guard** — Go có `mvdan.cc/sh` parse shell thành **AST thật**, đúng thứ §11-E nói là cần để thay regex/substring (đang là điểm yếu bảo mật lớn nhất); (2) **single static binary** → phân phối `curl|sh`/brew, không cần Node, và hook chạy nhanh (<10ms) — SOTA nói guard nên sub-10ms; (3) **doctor/generator** gộp 1 binary.
- **Next.js Studio = P2+, không phải lõi.** Dashboard/preview/docs là lớp "nice-to-have", làm sau khi core ổn. Đừng để UI kéo scope prototype.

```txt
Giữ:      kit.config.yaml, engine/* (rules/roles/commands/i18n), profiles/*, mô hình mode + generate + check
Bỏ:       (không bỏ gì ngay) — nhưng ngừng mở rộng Node trước khi có test
Tách:     .kit/ → templates(source) / hooks(runtime artifact) / user-data(sinh bởi init)
Viết mới: (Go, khi sẵn sàng) core CLI = generator + guard(AST) + doctor thành 1 binary; AGENTS.md emitter; test suite
Di chuyển: tools/kitgen = "engine thật" → coi như reference impl; đổi tên engine/ → content|sources/
```
Trình tự đúng: **(1) thêm test cho Node hiện tại → (2) chốt spec hành vi → (3) port core sang Go (guard trước, vì lợi ích bảo mật rõ nhất) → (4) Studio Next.js sau.** Rewrite sớm khi hành vi chưa có test = rủi ro regress.

---

# 11. Benchmark GitHub

## 11.2 Bảng benchmark (số sao ~ tháng 7/2026, xấp xỉ)

### Nhóm A/D — Instruction standard + Cursor export
| Repo | Sao | Loại | Học | Bỏ |
|---|---:|---|---|---|
| [agentsmd/agents.md](https://github.com/agentsmd/agents.md) | ~30k | Chuẩn mở | Emit **AGENTS.md** làm output chung (Codex/Copilot/Cursor/Claude đều đọc); nested-file scope | Đừng nhét mọi thứ vào 1 file phẳng |
| [intellectronica/ruler](https://github.com/intellectronica/ruler) | ~2.8k | one-source→many-agents CLI | `ruler.toml` chọn agent + output path; `.bak` backup; MCP propagation; precedence rõ | **Concat mù** → phá glob của Cursor (SM Kit đã tránh) |
| [block/ai-rules](https://github.com/block/ai-rules) | ~0.1k | one-source→many CLI | Lệnh **`status`** phát hiện drift; gen chọn lọc `--agents` | (còn non) |
| [sanjeed5/awesome-cursor-rules-mdc](https://github.com/sanjeed5/awesome-cursor-rules-mdc) | ~3.6k | `.mdc` generated + scanner | **glob-scoped per-library**; scanner cài đúng rule; cap 500 dòng | Rule LLM-gen chất lượng dao động |
| [PatrickJS/awesome-cursorrules](https://github.com/PatrickJS/awesome-cursorrules) | ~40k | Catalog | Taxonomy; bài học `.mdc + frontmatter > .cursorrules đơn file | Là catalog, không phải tool |

### Nhóm B — Claude kits / spec-driven
| Repo | Sao | Học | Bỏ |
|---|---:|---|---|
| [github/spec-kit](https://github.com/github/spec-kit) | rất lớn | `constitution` governance; gate `specify→clarify→plan→tasks→implement`; folder-per-feature | Ceremony nặng cho task nhỏ; buộc Python/uv |
| [Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec) | ~59k | change-as-folder + archive; profile mở rộng command minimal→full; "fluid not waterfall" | Gate lỏng có thể lọt spec thiếu |
| [gotalab/cc-sdd](https://github.com/gotalab/cc-sdd) | ~3-4k | **progressive-disclosure skills**; implementer tươi mỗi task + reviewer độc lập; EARS + human gate | Naming Kiro dễ rối |
| [buildermethods/agent-os](https://github.com/buildermethods/agent-os) | ~4-5k | **standards-injection** (học convention repo 1 lần, inject theo ngữ cảnh); profile+config.yml | Ecosystem nhỏ |
| [davila7/claude-code-templates](https://github.com/davila7/claude-code-templates) | ~28k | cài **từng component** (`--agent one`); catalog web | Cài tất = bloat |
| [SuperClaude_Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework) | ~23k | namespacing `/sc:`; "modes" nhẹ | **30 lệnh + 20 agent mặc định = bloat** |
| [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | ~40k | freshness badges làm tín hiệu tin cậy | Là link-list, không phải method |

### Nhóm C — Subagents/roles
| Repo | Sao | Học | Bỏ |
|---|---:|---|---|
| [wshobson/agents](https://github.com/wshobson/agents) | ~38k | **model-tiering** (Opus arch/security, Sonnet docs/test, Haiku ops); plugin-scoped install | Coi số agent là feature |
| [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) | ~23k | **công thức description** "Use when… Invoke for…"; taxonomy chống trùng | Load cả 154 agent |
| [lst97/claude-code-sub-agents](https://github.com/lst97/claude-code-sub-agents) | ~1.6k | orchestrator lắp **team 1–3**; bảng routing scenario→agent | Trung tâm hoá quá mức |
| [0xfurai/claude-code-subagents](https://github.com/0xfurai/claude-code-subagents) | ~1k | template body nhất quán | Sprawl per-language |

### Nhóm E — Guardrails/security (quan trọng nhất cho SM Kit)
| Nguồn | Kỹ thuật | Học |
|---|---|---|
| [Anthropic hooks/permission/sandboxing](https://code.claude.com/docs/en/sandboxing) + [engineering](https://www.anthropic.com/engineering/claude-code-sandboxing) | PreToolUse deny; bubblewrap/seatbelt OS sandbox | **"Contain, don't just detect"** — boundary thật là OS sandbox |
| [claude-code #4956](https://github.com/anthropics/claude-code/issues/4956) | prefix-match bypass (`echo x && rm -rf`) | Bằng chứng chính thức: substring/prefix rule thất bại khi chain |
| [disler/claude-code-damage-control](https://github.com/disler/claude-code-damage-control) | path tiers `zeroAccess/readOnly/noDelete` | **Path-boundary theo tầng** đáng copy |
| [nah guard (Show HN)](https://news.ycombinator.com/item?id=47343927) | **intent classification** + phân tích từng stage pipe + fail-closed + audit log | Mô hình khái niệm tốt nhất: phân loại theo ý định + allowlist-by-default |
| [dcg gist](https://gist.github.com/nazt/3168a892d54e50612d3232ec523b68dc) | **tree-sitter AST** cho heredoc/`python -c` + tách data/code span | AST cho interpreter nhúng |
| [GitGuardian ggshield hook](https://www.helpnetsecurity.com/2026/04/15/product-showcase-gitguardian-ggshield-ai-hook/) | scan secret 3 stage (pre-prompt/pre-tool/post-tool) | Scan **pre-prompt** cũng quan trọng như pre-exec |
| [LlamaFirewall](https://arxiv.org/abs/2505.03574) | layered PromptGuard+AlignmentCheck+CodeShield | Guard = defense-in-depth nhiều lớp |
| [command-line obfuscation](https://www.wietzebeukema.nl/blog/bypassing-detections-with-command-line-obfuscation) | `find -e"xec"`, `$()`, hex/unicode | Mọi chuỗi blocklist đều re-spell được → allowlist thắng |

**Sự cố thật (Docker blog):** Claude Code xoá `~/` trên Mac & `/bin /etc` trên WSL2 (12/2025); Replit xoá prod DB (7/2025); s1ngularity npm scan `~/.aws ~/.ssh .env` rò 1000+ token với `--dangerously-skip-permissions`.

## 11.3 Bộ lọc (chỉ vào P0/P1 nếu qua)

| Ý tưởng | Giải vấn đề thật? | Nặng hơn? | AI dễ hiểu hơn? | Enforce được (hook/CLI/test)? | Local-first? | Đa agent? | Tránh bloat? | → Verdict |
|---|---|---|---|---|---|---|---|---|
| Emit **AGENTS.md** làm base | Codex/nhiều agent đang đọc AGENTS.md mà SM Kit chưa emit | Không | Có | Có (emitter + check) | Có | Có | Có | **P0** |
| **Trigger-style role desc + model-tier + tool allowlist** | Routing sai + tốn token | Không | Rất | Có (test routing) | Có | Có | Có | **P0** |
| Lệnh **`doctor`** (health + drift + fix hint) | Người dùng không biết vì sao hỏng | Nhẹ | Có | Có | Có | Có | Có | **P1** |
| **Guard AST + path-boundary + audit log + allowlist** | Guard hiện bypass được (bằng chứng #4956) | Vừa | — | Có (test bypass) | Có | Có | Có | **P1** (Go) |
| **Tiered spec gate** (change-as-folder, chỉ standard/strict) | Task lớn thiếu spec | Vừa | Có | Có | Có | Có | Có nếu chỉ bật ở mode cao | **P1/P2** |
| Progressive-disclosure skills | Context bloat | Nhẹ | Có | Một phần | Có | Claude-centric | Có | **P2** |
| 30+ commands/personas | (không) | Rất | Không | — | — | — | Không | **REJECT** |
| Per-language agent sprawl | (không) | Có | Không (routing collision) | — | — | — | Không | **REJECT** |
| Buộc Python/uv toolchain | (không) | Có | — | — | — | — | — | **REJECT** |

## 11.4 So sánh năng lực SM Kit vs ngoài

| Capability | Repo ngoài làm tốt | SM Kit hiện có | Gap | Ưu tiên |
|---|---|---|---|---|
| AGENTS.md standard | agents.md, ruler | ❌ không emit | **Cao** | P0 |
| CLAUDE.md | ruler, block-ai-rules | ✅ có | — | — |
| Cursor rules export | sanjeed5, ruler | ✅ glob-scoped (tốt) | thấp | — |
| Codex/Copilot export | ruler | Copilot ✅; Codex qua AGENTS.md ❌ | trung (buộc P0 trên) | P0 |
| Skills system | cc-sdd (progressive) | commands only, không progressive | trung | P2 |
| Subagents/roles | VoltAgent, wshobson | ✅ 7 role (số lượng chuẩn) nhưng desc/tier chưa tối ưu | trung | P0/P1 |
| Slash commands | SuperClaude, spec-kit | ✅ 4 | thấp | — |
| Hooks | damage-control, Anthropic | ✅ 3 hook | thấp (cơ chế) | — |
| Guardrails | nah, dcg, Anthropic sandbox | 🟠 regex/substring, fail-closed | **Cao** | P1 |
| Installer | ruler, davila7 | 🟠 init; chưa npx-publish | trung | P1 |
| Doctor command | block-ai-rules `status` | ❌ chỉ `check` | trung | P1 |
| Spec-driven workflow | spec-kit, OpenSpec, cc-sdd | ❌ chưa có artifact | trung | P1/P2 |
| Evidence gate | cc-sdd (test+review) | 🟠 role nói chạy test, chưa enforce | trung | P1 |
| Audit log | nah | ❌ không | **Cao** (đi kèm guard) | P1 |
| Profile system | agent-os, OpenSpec | ✅ 4 profile (mỏng) | thấp | P2 |
| Documentation | spec-kit, awesome-* | 🟡 dev docs, no site | thấp | P2 |
| Security | Anthropic sandbox | 🟠 chỉ hook, không sandbox | **Cao** (giới hạn bản chất) | ghi rõ |

## 11.5 Kết luận benchmark

```txt
Top 5 SM Kit nên copy/học:
1. Emit AGENTS.md làm output chung (base), rồi mới layer CLAUDE.md/.cursor/copilot/windsurf — chuẩn cross-agent 2026 (agents.md, ruler).
2. Description role kiểu trigger "Use when… Invoke for…" + model-tiering + tool allowlist read-only (VoltAgent, wshobson) — đòn bẩy routing lớn nhất, rẻ.
3. Guard nâng cấp: parse AST (Go: mvdan.cc/sh) + allowlist-by-default + path-boundary theo tầng + audit log + fail-closed (nah, dcg, damage-control, Anthropic).
4. Lệnh `doctor`/`status`: health-check + drift + gợi ý fix bằng tiếng người (block-ai-rules) — mở rộng từ `check` sẵn có.
5. Tiered spec gate: change-as-folder + archive, CHỈ bật ở standard/strict (spec-kit/OpenSpec/cc-sdd) — giữ vibe nhẹ cho task nhỏ.

Top 5 KHÔNG nên copy:
1. Bloat 30+ commands/personas mặc định (SuperClaude) — choice paralysis + context rot.
2. Sprawl subagent theo từng ngôn ngữ/framework (VoltAgent 154, 0xfurai 100+) — routing collision.
3. Buộc toolchain lạ (Python/uv của spec-kit) cho nhóm dùng JS/vibe.
4. Concat mù mọi .md vào 1 blob cho mọi agent (ruler) — phá glob-scoping của Cursor.
5. Bán guard regex như "security" hoặc dựa vào nó thay vì OS sandbox — SOTA nói guard chỉ chặn ~95% lỗi vô ý.

Điểm khác biệt nên GIỮ của SM Kit:
1. Vibe-first với "ceremony vô hình": constitution + decision-log tự bơm qua SessionStart — nhắm người không biết code (không kit nào ở trên tập trung nhóm này).
2. Mode tiering vibe/standard/strict bằng MỘT knob config — nới/siết cùng một engine.
3. Generator zero-dep + glob-scoped output + `check` drift + safe-write — đã hơn ruler ở khoản Cursor scoping ngay từ đầu.
```

## Ưu tiên hành động (rút ra từ audit)

**P0 (rẻ, giá trị cao, không đổi kiến trúc):**
1. Emit `AGENTS.md` (+ `.codex`/generic) từ cùng nguồn → đóng gap cross-agent lớn nhất.
2. Viết lại 7 role description theo công thức trigger + thêm model-tier + siết tool allowlist (reviewer/planner/architect read-only).
3. Sửa 2 overlap routing: planner↔architect, reviewer↔qa (ranh giới rõ trong description).

**P1 (cần công + có thể là Go):**
4. `doctor` command (mở rộng `check`: kiểm node, config hợp lệ, invariant path tồn tại, hook cài đúng, drift → fix hint).
5. Guard v2: AST + allowlist-by-default + path-boundary + audit log (ưu tiên port sang Go vì `mvdan.cc/sh`).
6. Test suite tự động (unit cho yaml/kitgen/guard; golden-file cho generated; bypass-test cho guard).
7. Publish `npx` thật + sửa mô hình npm-dep (init copy runtime `.kit/` vào project).

**P2:**
8. Tiered spec-driven (change-as-folder) ở standard/strict; progressive-disclosure skills; Next.js Studio.

---

# 12. Decision sau audit (chốt — agent phải tuân)

> Đây là ranh giới thực thi. Agent đọc audit này **không được** tự ý nhảy sang Go/Studio/DevOps.

### Làm ngay (P0)
- Emit **AGENTS.md** từ cùng nguồn hiện tại (thêm target vào generator).
- Sửa 7 role description theo format trigger: **"Use when… / Invoke for…"**.
- Thêm **model-tier** + **tool allowlist** cho role (reviewer/planner/architect read-only).
- Làm rõ ranh giới **planner ↔ architect** và **reviewer ↔ qa** (mỗi role một trigger disjoint).
- Giữ **Node/MJS làm reference implementation** (không đổi runtime).
- Thêm **golden-file test** cho output generated.
- Thêm **`engine/skills/` (3 skill: code-review, refactor, test-design)** — emit `.claude/skills/*/SKILL.md` model-invocable (§14.3).
- Thêm nhãn **`enforce:` cho mọi rule** + rule `15-evidence-gate.md` (§14.5).

### KHÔNG làm ở P0
- ❌ Chưa viết **Go core**.
- ❌ Chưa tạo **Next.js Studio**.
- ❌ Chưa thêm **Docker / K8s / Terraform**.
- ❌ Chưa mở rộng quá 7 role / 4 command / **3 skill** (không 12 skill, không 12 file rule rỗng — §14).
- ❌ Chưa dựng cơ chế trigger song song (`triggers.yaml`) — dùng `paths`/`description` native.
- ❌ Chưa biến kit thành awesome-list / catalog.

### Điều kiện để sang P1 (gate)
- `kitgen check` PASS.
- Có test cho emitter (mỗi target một golden output).
- Golden output đủ 5 target: **CLAUDE.md, AGENTS.md, .cursor/rules, .github/copilot-instructions + instructions, .windsurf/rules**.
- ≥ 3 scenario test cho `guard-shell` (block thật / allow thật / bypass thử).

---

# Acceptance criteria (gate đo được từng phase)

### P0 PASS khi:
- `npm run build` sinh đủ (outDir):
  - `CLAUDE.md`
  - **`AGENTS.md`** (mới)
  - `.claude/{rules,agents,commands,settings.json}`
  - `.cursor/rules/*.mdc` + `.cursor/commands/*.md`
  - `.github/copilot-instructions.md` + `.github/instructions/*.instructions.md`
  - `.windsurf/rules/*.md`
- `npm run check` phát hiện drift đúng (exit 1 khi lệch).
- Role description **không trùng trách nhiệm** (planner≠architect, reviewer≠qa) — kiểm bằng mắt + 1 test routing tối thiểu.
- Context always-on **không tăng > 20%** so với hiện tại (đo bằng số dòng always-scope + CLAUDE.md).
- **Không thêm dependency runtime mới** nếu chưa có lý do (giữ zero-dep).

### P1 PASS khi:
- Có lệnh **`doctor`** (kiểm node/version, config hợp lệ, invariant path tồn tại, hook cài đúng, drift → fix hint).
- Guard có **audit log** (append-only, ngoài vùng agent ghi được).
- Guard có mô hình **BLOCK / WARN / ALLOW** (không chỉ block/allow).
- Có test **destructive command** + test **path boundary**.
- README quickstart chạy được **dưới 5 phút** (init → build → mở agent).

### P2 PASS khi:
- Go guard v2 chạy được **như adapter** (cùng I/O hook contract).
- Node guard cũ **vẫn fallback được** (không mất an toàn khi thiếu Go binary).
- Có **benchmark tốc độ** guard (mục tiêu <10ms/lệnh cho case thường).
- **Không phá** output hiện tại (golden test P0 vẫn pass).

---

# 13. Mapping benchmark → file/module SM Kit

| Pattern học từ ngoài | Áp vào đâu | File/folder cần sửa | Phase |
|---|---|---|---|
| AGENTS.md standard (agents.md/ruler) | Base output cross-agent | `tools/kitgen/kitgen.mjs` (`emitAgentsMd` + buildOutputs), dùng `engine/rules`+`roles` | **P0** |
| Role trigger description + model-tier + tool allowlist (VoltAgent/wshobson) | Routing subagent | `engine/roles/*.md` (frontmatter + body) | **P0** |
| Golden-file test (block/ai-rules status làm nền) | Chống regress generator | `tools/kitgen/__tests__` (mới) + `test/golden/` | **P0** |
| Doctor/status command (block/ai-rules) | Health check + drift + fix hint | `tools/kitgen/kitgen.mjs` (thêm mode `doctor`) hoặc `cmd/smkit` (Go, sau) | **P1** |
| Guard AST + path-boundary tiers + audit log + allowlist (nah/dcg/damage-control/Anthropic) | Guard v2 | `.kit/hooks/guard-shell.mjs` (Node trước) → port `mvdan.cc/sh` (Go sau) | **P1** |
| Secret scan 3-stage (ggshield) | Bảo vệ secret | hook mới `.kit/hooks/secret-scan.mjs` + `emitSettings` | **P1/P2** |
| Spec-driven change-as-folder + archive (spec-kit/OpenSpec/cc-sdd) | Workflow standard/strict | `engine/commands/*` + `docs/specs/` (chỉ bật ở mode cao) | **P2** |
| Progressive-disclosure skills (cc-sdd) | Giảm context bloat | `engine/skills/` hoặc `profiles/*` (load-on-demand) | **P2** |
| Standards-injection (agent-os) | Học convention repo | mở rộng `.kit/decisions.md` + SessionStart hook | **P2** |
| OS sandbox positioning (Anthropic) | Định vị bảo mật đúng | `README.md` + `docs` (khuyến nghị bật sandbox) | **P0 (doc)** |

> **Nguyên tắc khi agent triển khai:** stars chỉ là tín hiệu tham khảo — **không** được dùng số sao làm lý do đưa một ý tưởng vào kit. Mọi ý tưởng phải qua bộ lọc §11.3 (giải vấn đề thật · enforce được · không phình context · đa-agent · local-first).

---

# 14. Audit gap: Skills Layer & Rules Taxonomy

> Bổ sung sau khi soi lại: audit trước có rules/roles/commands/hooks/profiles nhưng **thiếu 2 mảng**: (a) skills như một layer, (b) taxonomy rule + **loại enforce của từng rule**.

## 14.1 Skills hiện có chưa? — CHƯA (đang lẫn với commands)

Inventory không có `engine/skills/`. Hiện chỉ có 4 file `engine/commands/` (start/checkup/decide/review) — **user-invoked, nhẹ, không có workflow/checklist/output riêng**. Đó chưa phải skill.

| Thành phần | Mục đích | SM Kit hiện tại |
|---|---|---|
| Rule | Luật nền, luôn đúng, ngắn | ✅ 2 file |
| Role/Subagent | Ai xử lý việc gì | ✅ 7 |
| Command | Người dùng gọi workflow nào | ✅ 4 (nhẹ) |
| Hook | Máy tự enforce/chặn/lọc | ✅ 3 |
| Profile | Stack đang dùng | ✅ 4 |
| **Skill** | **Quy trình chuyên môn kích hoạt theo ngữ cảnh** | ❌ **chưa có** |

**⚠️ Chỉnh sửa kỹ sư (bắt buộc):** trong Claude Code, **skill và command là cùng primitive `SKILL.md`** (khác ở `disable-model-invocation` + `user-invocable`). Vì vậy:
- Skill = **command có `description`+`paths` để model tự kích hoạt** (không `disable-model-invocation`).
- **KHÔNG** dựng cơ chế trigger song song (`triggers.yaml` riêng) khi `paths`/`description` native đã đủ — tránh trùng với `engine/commands` và tránh bloat.
- Generator mở rộng emit `.claude/skills/<id>/SKILL.md` (Claude) + `.cursor/commands` (Cursor không có model-invoke → skill xuống command).

## 14.2 Cấu trúc skills đề xuất (lean — KHÔNG 12 cái)

```txt
engine/skills/
  code-review/   SKILL.md   (+ checklist.md, output.md nếu dài)
  refactor/      SKILL.md
  test-design/   SKILL.md
```
Schema tối thiểu (frontmatter SKILL.md — dùng field native Claude, không đẻ thêm):
```yaml
id: code-review
name: Code Review
description: "Use when there is a diff/changed code. Invoke for correctness + consistency review."   # -> model auto-invoke
paths: ["**/*"]            # -> khi nào tự kích hoạt (native Claude/Cursor glob)
user_invocable: true       # cũng gõ được /code-review
related_roles: [reviewer]
related_rules: [consistency-guard, evidence-gate]
# body: workflow + checks + output_format (checklist + bảng findings)
```

## 14.3 Skills tối thiểu P0/P1 (KHÔNG hơn)

| Skill | Dùng khi | Role chính | Output bắt buộc | Phase |
|---|---|---|---|---|
| `code-review` | Sau khi có diff/thay đổi | reviewer | findings + severity + file/action | **P0** |
| `refactor` | Đổi cấu trúc, giữ behavior | architect/reviewer | plan + impact + rollback | **P0** |
| `test-design` | Task cần QA/test gate | qa | test cases + edge cases + commands | **P0** |
| `security-review` | Đụng auth/shell/file/secret | reviewer | risk table + fix | P1 |
| `guard-design` | Sửa hooks/guardrails | architect | BLOCK/WARN/ALLOW + bypass tests | P1 |
| `release-check` | Trước publish/release | devops/qa | checklist + version + changelog | P1 |
| `spec-design` | Task lớn cần spec | planner/architect | spec/change-folder/tasks | P2 |

> Dừng ở đây. Thêm nữa = rơi vào bẫy SuperClaude (§11.5 "không copy #1").

## 14.4 Rules taxonomy — hiện mỏng (2 file), nhưng ĐỪNG tạo 12 file rỗng

Namespace **mục tiêu** (chỉ tạo file khi có nội dung thật + enforce được, không scaffold rỗng):
```txt
engine/rules/
  00-hard-rules.md        ✅ có
  10-consistency.md       ✅ có
  15-evidence-gate.md     ← P0/P1 (đi cùng skills)
  20-security.md          ← P1
  25-file-safety.md       ← P1
  30-dependency-policy.md ← P1 (đã có mầm trong consistency-guard)
  35-testing.md · 40-git · 45-devops · 50-docs · 60-scope  ← P2 khi cần
```

## 14.5 ⭐ Điểm quan trọng nhất: mỗi rule phải biết LOẠI ENFORCE của nó

Đây là insight giá trị nhất của gap này. Đề xuất **frontmatter `enforce:`** trên mỗi rule để phân biệt "để AI đọc" vs "hook chặn" vs "gate kiểm":

| Rule | Loại enforce | Cơ chế trong SM Kit |
|---|---|---|
| Không tự rewrite toàn bộ / giữ scope | `agent-read` | markdown rule (AI hiểu) |
| Không chạy destructive command | `hook` | `guard-shell.mjs` (đã có) |
| Không thêm dependency khi chưa có lý do | `hook` + `agent-read` | `consistency-guard.mjs` (đã có mầm) |
| Không nói "done" khi chưa có evidence | `gate` | output-gate của skill/command (chưa có) |
| Không sửa schema khi task UI | `agent-read` + checklist | reviewer skill |
| Không ghi đè file người dùng | `generator` | safe-write trong kitgen (đã có `.bak`) |
| Không log secrets | `hook` + `agent-read` | secret-scan hook (P1) |
| Không tạo test giả | `gate` + `agent-read` | test-design/qa skill |

→ Thêm `enforce: agent-read | hook | gate | generator` vào frontmatter rule; `doctor` (P1) kiểm mỗi rule `hook`/`generator` có cơ chế thật, không chỉ là chữ.

## 14.6 Kích hoạt skill — dùng native, không đẻ cơ chế mới

- Claude: `description` (model tự quyết) + `paths` (glob) trong SKILL.md — **native**.
- Cursor: skill → `.cursor/commands` (không có model-invoke; hạ xuống command thủ công).
- Không cần `triggers.yaml` riêng; nếu muốn liệt kê từ khoá thì nhét vào `description` ("Use when review/diff/PR…").

## 14.7 Output format chuẩn cho skill (bắt buộc — chống "AI viết tự do")

Mỗi skill P0 phải kèm template output. Ví dụ `code-review`:
```md
## Summary · ## Changed files · ## Findings
| Severity | File | Issue | Why it matters | Fix |
## Required fixes · ## Test evidence · ## Verdict
```
`security-review` (P1): `## Attack surface · ## Risks(table) · ## Guardrail gaps · ## Verdict`.
Đây chính là "evidence gate" §14.5 hiện thực bằng format.

## 14.8 Benchmark skills (bổ sung)

| Repo | Học về skills | Áp dụng SM Kit |
|---|---|---|
| cc-sdd | progressive-disclosure (load khi cần) | skill chỉ vào context khi `paths`/`description` khớp |
| alirezarezvani/claude-skills | skill có trigger + workflow riêng | mỗi skill = SKILL.md có checklist+output |
| SuperClaude | nhiều skill dễ phình | học namespacing, **không** copy số lượng |
| agent-os | standards-injection | skill đọc convention theo profile |
| VoltAgent subagents | `use_when` rõ | skill/role phải có "Use when…" |

## 14.9 Kết luận bắt buộc

```txt
Skills hiện tại:  CHƯA CÓ layer riêng — đang lẫn/nhẹ trong engine/commands.
Rules hiện tại:   THIẾU taxonomy + THIẾU nhãn enforce (agent-read/hook/gate/generator).

Cần thêm NGAY P0:
1. engine/skills/ với 3 skill: code-review, refactor, test-design (emit .claude/skills/*/SKILL.md, model-invocable).
2. Nhãn `enforce:` cho mọi rule + rule mới 15-evidence-gate.md.
3. Output-format template cho 3 skill (evidence gate hiện thực bằng format).

KHÔNG nên thêm lúc này:
1. 12 skill / 12 file rule rỗng (bloat — vi phạm §11.5).
2. Cơ chế trigger song song (triggers.yaml) khi paths/description native đã đủ.
3. security/guard/release/spec skills — để P1/P2, không dồn vào P0.
```

---

## Giới hạn bản chất (ghi rõ, đừng bán quá)
Hook PreToolUse là kiểm tra *cố vấn* trên text lệnh — **không phải isolation**. Không thể đóng hết: parser≠shell differential, write-then-`npm test` RCE, indirection env-var, exfil qua kênh được phép, và mọi thứ sau khi guard bị sửa. **Boundary thật = OS sandbox** (bubblewrap/seatbelt/microVM) + egress allowlist + không mount credential + human-in-loop cho thao tác không hồi phục. SM Kit nên định vị guard là **"damage control cho lỗi vô ý"**, không phải lá chắn bảo mật, và khuyến nghị người dùng bật sandbox của Claude Code.
