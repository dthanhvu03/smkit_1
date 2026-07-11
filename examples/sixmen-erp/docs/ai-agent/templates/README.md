# Templates catalog

> Runtime path: `.cursor/templates/sixmen/` — agent điền khi làm task.

| Template | Khi dùng | Lưu artifact |
|----------|----------|--------------|
| `gate-status.md` | Mọi task — bước 0 | `artifacts/{Task-ID}/00-gate-status.md` |
| `task-brief.md` | Task mới | `…/01-task-brief.md` |
| `architecture-impact.md` | Trước implement logic/DB/quyền | `…/03-architecture-impact.md` |
| `migration-note.md` | Trước DDL | `…/04-migration-note.md` |
| `impact-risk-rollback.md` | Mutation đụng data | `…/05-impact-risk-rollback.md` |
| `test-plan.md` | Post-feature gate | `…/06-test-plan.md` |
| `release-checklist.md` | Deploy | `…/08-release-checklist.md` |
| `acceptance-criteria.md` | Feature nghiệp vụ | `…/02-acceptance-criteria.md` |
| `architecture-compliance-checklist.md` | Trước PR/review | `…/07-architecture-compliance-checklist.md` |
| `architecture-tests-skeleton.md` | Scaffold Pest (repo code) | `tests/Architecture/` |
| `skill-background-template.md` | Viết § Background skill (business persona) | Trong `.cursor/skills/sixmen-{role}/SKILL.md` |

Quy tắc folder: [`artifacts/README.md`](../../artifacts/README.md)
