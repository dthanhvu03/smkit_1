# Orchestrator — cách hoạt động (Human + Agent)

> **Canonical ritual:** `.cursor/commands/orchestrator.md` — `.claude/commands/orchestrator.md` là mirror (Claude Code).

## Tầng đọc (thứ tự bắt buộc)

```
AGENTS.md (hub)
  → orchestrator SKILL (+ /orchestrator command trên Cursor)
  → artifacts/PROGRESS.md
  → artifacts/{Task-ID}/00-gate-status.md (← CURRENT)
  → shared-memory.md (khi đụng schema / workflow / data / permission)
```

Rules `alwaysApply` **không thay** đọc `AGENTS.md` chủ động.

## Tự nạp theo nền tảng (SoT — tránh drift)

| Cơ chế | Cursor | Claude Code | Codex / Chat |
|--------|--------|-------------|--------------|
| Hub `AGENTS.md` | Auto (root) | `@AGENTS.md` trong `CLAUDE.md` | Read thủ công |
| Rules guardrail | 6× `alwaysApply` `.mdc` | `@.claude/rules/sixmen-always-on-parity.md` (import `CLAUDE.md`) | Read `.mdc` thủ công |
| Skill body | `/sixmen-*` hoặc `@` (disable auto) | Read `.cursor/skills/…/SKILL.md` | Read thủ công |
| Ritual orchestrator | `/orchestrator` → `.cursor/commands/orchestrator.md` | `/orchestrator` → mirror + **cùng file canonical** | Prompt + SKILL |
| Task 🔄 động | `sessionStart` hook → `additional_context` | `SessionStart` → `hookSpecificOutput` | Không |
| Team memory | `shared-memory.md` (Read khi trigger) | + auto `MEMORY.md` local — **promote** vào SKILL | Read thủ công |

Chi tiết hook: `.cursor/bootstrap/claude-session-digest.sh` (dual JSON). **Đồng bộ 2 IDE:** [`platform-agent-parity.md`](platform-agent-parity.md).

## Human gõ gì?

| Ý định | Cursor |
|--------|--------|
| Resume task đang chạy | `/orchestrator` |
| Task mới | `/orchestrator Mở task …` |
| Chỉ xem tiến độ | `/orchestrator Status` |
| Ép QA trước merge | `/orchestrator QA gate TASK-GDx-xxx` |

Hoặc `@sixmen-orchestrator` + mô tả (cùng workflow).

## Agent làm gì? (không tự code thay role)

1. **Orient** — đọc hub + gate; in blocking output (chưa code).
2. **Route** — IT → BA → Arch → DB → BE/FE → QA → (DevOps nếu deploy).
3. **Gate HO** — schema (Vũ) · nghiệp vụ (Khanh) · permission (QLVH) · merge/deploy → **STOP** nếu PENDING.
4. **Closeout** — cùng lượt: gate-status · PROGRESS · KNOWN-ISSUES · validate-artifacts · Pest/pre-push.

Task chạm **tồn/tiền/nghiệp vụ** → thêm **Human-control package** (walkthrough Khanh ký R1–Rn trước merge). Xem skill § Human-control package.

## File liên quan

| File | Vai trò |
|------|---------|
| `AGENTS.md` | Hub routing slim · SoT index · kit version |
| `docs/ai-agent/02-governance-and-memory.md` | Hub extended — artifact · KNOWN-ISSUES · implement envelope |
| `.cursor/commands/orchestrator.md` | Ritual CI-mode (Cursor) |
| `.cursor/skills/sixmen-orchestrator/SKILL.md` | Điều phối đầy đủ 8 bước |
| `.cursor/rules/sixmen-skill-routing.mdc` | Route role + `/orchestrator` |
| `.cursor/rules/sixmen-agent-closeout.mdc` | Sync artifact cùng lượt |
| `artifacts/PROGRESS.md` | Big picture task |
| `docs/ai-agent/reference/orchestration-ops.md` | Tiering · trace · git discipline |
| `docs/ai-agent/reference/platform-agent-parity.md` | Cursor ↔ Claude map · sync discipline |

## Giới hạn

- `/orchestrator` **ép hành vi agent** — không thay GitHub Actions CI.
- Hook `pre-push`: Pint · arch-lint · PHPStan.
- Agent **không** tự coi Human Owner đã duyệt.
