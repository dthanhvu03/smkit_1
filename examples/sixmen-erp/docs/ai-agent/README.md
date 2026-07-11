# SIXMEN — Phòng ban AI Agent (tài liệu)

> **Hub runtime (slim ~145 dòng):** [`AGENTS.md`](../../AGENTS.md) — chi tiết governance: [02-governance-and-memory.md](02-governance-and-memory.md).  
> Folder này gom tài liệu **đọc cho người** — rules/skills runtime: `.cursor/` · Claude mirror: `.claude/`.

## Bắt đầu nhanh

| Bạn là | Đọc |
|--------|-----|
| Human Owner / PM | [01-overview.md](01-overview.md) → [reference/phase-gates.md](reference/phase-gates.md) |
| Dev / Agent task ERP | [02-governance-and-memory.md](02-governance-and-memory.md) → [reference/platform-agent-parity.md](reference/platform-agent-parity.md) *(Cursor + Claude song song)* → [reference/orchestrator-how-it-works.md](reference/orchestrator-how-it-works.md) |
| Tìm tài liệu nghiệp vụ | [reference/doc-map.md](reference/doc-map.md) · [**ERP hub**](../erp/README.md) |
| Validate kit local | [bootstrap.md](bootstrap.md) — `init-kit.ps1` |
| Agent task metrics | [reference/agent-task-metrics.csv](reference/agent-task-metrics.csv) |

## Cấu trúc

```
docs/ai-agent/
├── README.md                 ← Bạn đang ở đây
├── 01-overview.md            ← 8 vai trò, org chart, ví dụ workflow
├── 02-governance-and-memory.md
├── reference/
│   ├── orchestrator-how-it-works.md  ← /orchestrator + AGENTS hub (Human + Agent)
│   ├── platform-agent-parity.md    ← Cursor ↔ Claude đồng bộ
│   ├── shared-memory.md      ← Memory dùng chung (canonical)
│   ├── doc-map.md            ← Index tài liệu ERP
│   └── phase-gates.md        ← Cổng từng giai đoạn
├── rules/README.md           ← Catalog rules (.cursor/rules)
├── skills/README.md          ← Catalog skills (.cursor/skills)
├── templates/README.md       ← Catalog templates (.cursor/templates)
├── bootstrap.md              ← Sync sang repo code
└── examples/
    └── dry-run/              ← Mô phỏng orchestrator

.cursor/                      ← Runtime Cursor (không di chuyển)
├── rules/*.mdc
├── skills/sixmen-*/SKILL.md
└── templates/sixmen/*.md
```

## Quy ước đường dẫn

| Loại | Path |
|------|------|
| Shared memory | `docs/ai-agent/reference/shared-memory.md` |
| Governance rule | `.cursor/rules/sixmen-governance.mdc` |
| Skill | `.cursor/skills/sixmen-{role}/SKILL.md` |
| Template | `.cursor/templates/sixmen/{name}.md` |

## Liên kết ERP chính

- **Cổng ERP:** [`docs/erp/README.md`](../erp/README.md)
- Master Decisions: [`docs/erp/core/01_Master_Decisions.md`](../erp/core/01_Master_Decisions.md)
- Repo tổng: [`README.md`](../../README.md)
