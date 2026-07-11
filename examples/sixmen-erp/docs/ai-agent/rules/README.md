# Rules catalog

> Runtime path: `.cursor/rules/` — Cursor đọc trực tiếp; **không** di chuyển ra khỏi `.cursor/`.

## Always on

| File | Mục đích |
|------|----------|
| `hethongtuduy.mdc` | Framework tư duy adaptive depth v4.3 |
| `sixmen-governance.mdc` | SoT, Human Owner, conflict priority, loading rule |
| `sixmen-data-safety.mdc` | Cấm mất data, append-only, DB users |
| `sixmen-architecture-envelope.mdc` | Critical guards, mutation envelope |
| `sixmen-flowchart-business.mdc` | Flowchart business language, PO/LSX deps |

## Theo glob (role)

| File | Trigger | Vai trò |
|------|---------|---------|
| `sixmen-laravel-backend.mdc` | `app/**/*.php`, `routes/**` | Backend patterns |
| `sixmen-frontend-hybrid.mdc` | `app/Filament/**`, `app/Livewire/**` | Filament + Livewire |
| `sixmen-database.mdc` | `database/**`, `**/ERD.md` | Schema, migration |
| `sixmen-qa.mdc` | `tests/**` | Pest, safety matrix |
| `sixmen-devops.mdc` | `docker-compose*`, `.github/**` | Deploy, env |
| `codacy.mdc` | manual / sau code edit | Static analysis — không block docs |

## Đọc thêm

- [02-governance-and-memory.md](../02-governance-and-memory.md)
- [reference/shared-memory.md](../reference/shared-memory.md)
