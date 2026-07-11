# SIXMEN — Always-on parity (Claude Code)

> Mirror rút gọn của 6 rules Cursor `alwaysApply`. **Canonical đầy đủ:** `.cursor/rules/` cùng tên (`.mdc`).

## Skill routing (`sixmen-skill-routing`)

- Task ERP mới / resume: Read `AGENTS.md` → `.cursor/commands/orchestrator.md` → `sixmen-orchestrator/SKILL.md`.
- Skills: `disable-model-invocation` — **Read** `.cursor/skills/sixmen-{role}/SKILL.md` trước implement.
- Artifact trước code: `artifacts/{Task-ID}/` + `00-gate-status.md` + `01-task-brief.md`; schema → `04-migration-note.md` + HO trước DDL.

## Governance (`sixmen-governance`)

- Human Owner (Khanh/Vũ/CEO/QLVH) duyệt cuối — **không** tự coi đã duyệt.
- SoT conflict: Master Decisions > MVP > ERD GĐ0/GĐ1 > workflow GĐ1 > UI. `03_SRS.md` §3 DDL **không** override ERD.
- Mọi task ERP: folder `artifacts/{Task-ID}/`; code task cần `06`/`07` trước review.
- STOP: schema/rule/data/prod/permission chưa có migration-note + HO.

## Data safety (`sixmen-data-safety`)

- **Không** `DELETE` / `TRUNCATE` / `DROP` trên production.
- Movement/audit **append-only** — sửa nghiệp vụ = cancel/reversal/adjustment/exception.
- Không hard delete core ERP; MVP không build purge jobs.
- DB roles: `sixmen_app` / `sixmen_report` (read-only) / `sixmen_migration`.
- Agent shell (`guard-shell-core.sh`): không `docker compose down -v` · `docker volume prune/rm` · `system prune --volumes`.

## Architecture envelope (`sixmen-architecture-envelope`)

Mutation chain:

```
FormRequest → Policy → Domain Service → DB::transaction → audit → Event
```

Critical single-entry (không bypass):

- Tồn TP: `InventoryService` · NPL: `MaterialInventoryService`
- Mã chứng từ: `DocumentNumberService` · COGS: `CogsService`
- Mutation **primary only** — `pgsql_reporting` read-only
- Không logic nghiệp vụ trong Controller/Filament/Livewire/Blade
- **Validation + ngoại lệ BẮT BUỘC mọi feature nhập liệu** (07 §2.1): form đầy đủ (required/format/range/điều kiện/minItems) + DB constraint backstop + mutation tồn/tiền map exception **409/422** (không 500 trần). Tầng: CRUD→inline Filament; phức tạp→FormRequest; mutation→Service+custom exception.

## Agent closeout (`sixmen-agent-closeout`)

Cùng lượt khi sửa code: `00-gate-status.md` · `PROGRESS.md` · `KNOWN-ISSUES` (lỗi >15') · `06`/`07` nếu QA gate · **`09-handoff-summary.md` khi task DONE** (2-view Vận hành+Kỹ thuật; task feature/code, bỏ qua task vặt Mức 0–1). Task **`code` chạm nghiệp vụ/tồn/tiền** (PO/GRN/tồn/giá vốn) → **`business-walkthrough.md` Khanh duyệt TRƯỚC merge** (Human-control package; CRUD/UI thuần thì không bắt). Không hỏi "có ghi không". **Không báo task DONE khi thiếu `09-handoff`; không merge task nghiệp vụ khi thiếu `business-walkthrough`.** Pre-push: Pint + arch-lint + PHPStan.

## Hệ thống tư duy (`hethongtuduy` v4.3 rút gọn)

- Mọi response không trivial → xác định **Mức 0–3** trước trả lời.
- Mức 3: data thật · tiền/tồn · schema/migrate/permission · deploy prod · sign-off.
- Keyword auto Mức 3: `DROP` `DELETE` `TRUNCATE` `migrate` `schema` `permission` `GRANT` `REVOKE`.
- **Task-brief mọi task → § Khung 4 lăng kính** (hệ thống · phản biện+**what-if vận hành** · WBS · rủi ro), scale theo Mức 0–3; Mức 2–3 bắt buộc bảng WBS + rủi ro; task nghiệp vụ/data bắt buộc **checklist what-if** (trễ/thiếu/lỗi/từng phần/hủy/hoàn/gấp/trùng/hết hạn/đa chiều/tranh chấp). Canonical: `sixmen-orchestrator/SKILL.md` + template `task-brief.md`.
- Full: `docs/ai-agent/reference/hethongtuduy-v4.3-full.md`
