# Governance & shared memory

> **Hub runtime (slim):** [`AGENTS.md`](../../AGENTS.md) ~145 dòng — chi tiết governance ở file này.

| Lớp | Vai trò | Vị trí |
|-----|---------|--------|
| **Runtime** | Cursor always-on / glob rules, skills | `.cursor/` + **`AGENTS.md` (hub slim ~145 dòng)** |
| **Human-readable** | Đọc, tra cứu, onboarding | `docs/ai-agent/` *(folder này)* |

Rules **không** thay source of truth nghiệp vụ — chỉ guardrail hành vi agent.

## Conflict priority

Khi mâu thuẫn (cao → thấp):

1. System / platform instruction  
2. SIXMEN governance (`.cursor/rules/sixmen-governance.mdc`)  
3. Source-of-truth document  
4. Phase gate ([reference/phase-gates.md](reference/phase-gates.md))  
5. Skill instruction  
6. Task brief  
7. Conversation memory  
8. Model assumption  

**Conversation memory không override SoT.**

## Shared memory loading rule

`docs/ai-agent/reference/shared-memory.md` **không** tự load vào context.

**Read** file đó khi task đụng:

- ERP schema / ERD / migration  
- business rule / workflow / phase scope  
- critical service boundary  
- data safety / purge / delete / archive  
- permissions / CTY-HKD / warehouse scope  
- reporting connection / read replica  
- skill/rule conflict  

Docs-only nhỏ → chỉ đọc file đích + skill/rule liên quan.

Task high-risk → **báo rõ file đã đọc** trước khi đề xuất thay đổi.

## Always-on rules

| Rule | Mục đích |
|------|----------|
| `hethongtuduy.mdc` | Adaptive depth, đánh giá Mức 2–3 |
| `sixmen-governance.mdc` | SoT, Human Owner, templates |
| `sixmen-data-safety.mdc` | Cấm mất data, append-only |
| `sixmen-architecture-envelope.mdc` | Service boundary, envelope |
| `sixmen-skill-routing.mdc` | Route skill · `/orchestrator` |
| `sixmen-agent-closeout.mdc` | Sync artifact cùng lượt · PHPStan pre-push |
| `sixmen-flowchart-business.mdc` | Ngôn ngữ slide vs kỹ thuật *(glob `04_*_Flow`)* |

Role rules (`sixmen-backend`, `sixmen-qa`, …): `alwaysApply: false` — trigger theo glob.

Catalog đầy đủ: [rules/README.md](rules/README.md)

## Human Owner gates (tóm tắt)

Dừng và hỏi khi: schema/migration · business rule/state machine · xóa/purge data · deploy prod · permission matrix · SoT conflict · ≥2 module không được task yêu cầu.

Chi tiết + RACI: `sixmen-governance.mdc` · [reference/shared-memory.md](reference/shared-memory.md) §7

## Kỷ luật vận hành (artifact)

Một task = một folder `artifacts/{Task-ID}/` — `00-gate-status.md` · `01-task-brief.md` · … Chi tiết: [`artifacts/README.md`](../../artifacts/README.md).

**Thứ tự code:** brief + gate → architecture-impact → migration-note (+HO) → implement → QA gate → HO review.

**Cấm:** implement trước brief · migrate trước migration-note + HO · báo "xong" khi `qa_gate` chưa PASS.

| Việc | Prompt |
|------|--------|
| Task mới / resume | `/orchestrator` hoặc `@sixmen-orchestrator` |
| Brief | `/brief` (Cursor) · `/it-manager` (Claude) |
| QA gate | `/qa-gate` · `@sixmen-qa` |

Task nhỏ docs-only Mức 0: có thể không tạo folder — ghi *"docs-only, no artifact"* trong chat.

### KNOWN-ISSUES (`artifacts/KNOWN-ISSUES.md`)

Ghi khi lỗi >15' hoặc block luồng. Không ghi typo <2'. DevOps: entry `Env: prod` + `OPEN` → block release.

### Doc reference audit

Phase gate / merge cấu trúc lớn → `.cursor/bootstrap/validate-doc-refs.ps1`. Bump Kit Version + `rules-changelog.md` khi đổi kit.

## Cách dùng rules & skills

1. Rules `alwaysApply` + hub = guardrail — **không** thay SoT nghiệp vụ/schema.
2. Schema → ERD GĐ0/GĐ1 canonical; SRS §3 DDL deprecated nếu lệch ERD.
3. Workflow GĐ1: `04_Process_Flow` → `04_*_Flow` → `06_Workflow_Status` → `07_Sequence_Diagram`.
4. Skills: Read đúng vai — không load cả 9 skill mỗi lượt.
5. Critical guards (single-entry): `InventoryService` · `MaterialInventoryService` · `DocumentNumberService` · `CogsService` + Policy/append-only/`pgsql_reporting`.
6. Service CRUD thường không vào critical guards trừ khi ADR xác nhận.
7. Codacy: post-feature gate (`@sixmen-qa`) — không block docs-only.
8. Bắt đầu code: brief + skill + SoT đúng phạm vi — báo file đã đọc.

## Tuân thủ kiến trúc (implement)

1. `@sixmen-orchestrator` + task brief  
2. `architecture-impact.md` trước code (logic/DB/quyền)  
3. `sixmen-architecture-envelope.mdc` always on  
4. Sau feature → `@sixmen-qa` post-feature gate: Pest · `07-architecture-compliance-checklist.md` · Codacy nếu đổi code/deps  
5. CI merge: `docs/erp/core/04_Architecture.md` §13.3  

Permission GĐ1: `docs/erp/phases/GD1_Kho_SX/09_Permission_Matrix.md`

## Quy tắc chung

Human Owner duyệt cuối · Envelope Policy→Service→transaction→audit · Không đổi schema/behavior cũ · Không xóa data thật · Một task không sửa nhiều module nếu brief không yêu cầu · Ưu tiên incremental an toàn.

## Claude Code memory

`~/.claude/.../memory/MEMORY.md` chỉ local — rule cross-agent → **promote** vào SKILL + changelog. Chi tiết: [reference/platform-agent-parity.md](reference/platform-agent-parity.md) § Claude memory.

