# Overview — 8 vai trò AI Agent

> Human Owner duyệt cuối. Agent điều phối theo vai trò — không tự ý đổi behavior/schema/business rule.

## Sơ đồ tổ chức

```
Human Owner (Khanh / QLVH / Vũ / CEO)
        │
        ▼
@sixmen-orchestrator
        │
   ┌────┴────┬─────────┬──────────┬─────┬────────┬────┐
   ▼         ▼         ▼          ▼     ▼        ▼    ▼
IT Mgr   Architect  Database  Backend  Frontend  QA  DevOps
   │         │                              BA (song song)
   └─────────┴──────────────────────────────────┘
```

## Vai trò

| # | Vai trò | Skill | Output chính |
|---|---------|-------|--------------|
| 1 | IT Manager / PO | `@sixmen-it-manager` | Task brief, DoD |
| 2 | Solution Architect | `@sixmen-architect` | Architecture impact |
| 3 | Backend Engineer | `@sixmen-backend` | Laravel code |
| 4 | Frontend Engineer | `@sixmen-frontend` | Filament + Livewire |
| 5 | Database Engineer | `@sixmen-database` | Migration note, ERD |
| 6 | QA Tester | `@sixmen-qa` | Test plan, Pest |
| 7 | DevOps | `@sixmen-devops` | Release checklist |
| 8 | BA / Docs | `@sixmen-ba` | Acceptance criteria |

Chi tiết từng skill: [skills/README.md](skills/README.md)

## Ma trận duyệt (Human Owner)

| Gate | Ai duyệt |
|------|----------|
| Đổi schema / migration | Vũ (+ QLVH nếu ảnh hưởng quyền) |
| Matrix quyền pilot | QLVH |
| Scope / DoD / nghiệm thu | Khanh |
| Business rule mới | Khanh + QLVH |
| Deploy production | Vũ + Khanh |

## Cách dùng trong Cursor

### Task mới (khuyến nghị)

```
/orchestrator Mở task …
```

Hoặc `@sixmen-orchestrator` · Claude: `/orchestrator`

### Chỉ một vai trò

```
@sixmen-architect Review impact thêm bảng branches
@sixmen-qa Viết test plan cho login 3 role
```

## Ví dụ: GĐ0 B1 — Filament Shield

| Bước | Role | Artifact |
|------|------|----------|
| 1 | IT Manager | Task brief — module Core only |
| 2 | BA | AC — 3 role menu khác nhau |
| 3 | Architect | Impact — Shield + Spatie |
| 4 | Database | Migration note (nếu cần) |
| 5 | Backend | Shield config, seeder |
| 6 | Frontend | Menu ẩn/hiện Filament |
| 7 | QA | Test 403 + menu diff |
| 8 | DevOps | Staging checklist |
| 9 | Human | **QLVH ký matrix** |

Dry-run đầy đủ: [examples/dry-run/GD0_B1_Shield_RBAC.md](examples/dry-run/GD0_B1_Shield_RBAC.md)

## FAQ

**Skill không tự chạy?**  
`disable-model-invocation: true` — cần `@mention` tên skill.

**Repo này chỉ có tài liệu?**  
Đúng. Copy kit sang repo code: [bootstrap.md](bootstrap.md).

**Frontend?**  
Filament 4 + Livewire HYBRID — không React/Vue SPA admin GĐ0–3.

**Bắt đầu code?**  
Đọc [02-governance-and-memory.md](02-governance-and-memory.md) — không quét toàn repo; báo file đã đọc khi task high-risk.
