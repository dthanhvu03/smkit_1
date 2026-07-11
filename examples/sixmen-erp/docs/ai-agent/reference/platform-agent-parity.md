# Platform agent parity — Cursor + Claude Code song song

> **Mục tiêu:** Cùng repo, hai IDE — hành vi agent **khớp** trên guardrail, ritual, hooks.

## Canonical vs mirror

| Lớp | Canonical (sửa đây trước) | Claude mirror | Cursor runtime |
|-----|---------------------------|---------------|----------------|
| Hub | `AGENTS.md` (~145 dòng slim) | `@AGENTS.md` trong `CLAUDE.md` | Auto-load root |
| Luật cứng session | `CLAUDE.md` § LUẬT CỨNG | Claude only | — |
| Always-on guards | `.cursor/rules/*.mdc` | `.claude/rules/sixmen-always-on-parity.md` | `alwaysApply: true` |
| Orchestrator ritual | `.cursor/commands/orchestrator.md` | `.claude/commands/orchestrator.md` | `/orchestrator` |
| Role commands | `.cursor/commands/{role}.md` | `.claude/commands/{role}.md` | `/brief`, `/backend`, … |
| Skills | `.cursor/skills/sixmen-*/SKILL.md` | Read thủ công (cùng path) | `/` hoặc `@` |
| Task 🔄 động | — | `SessionStart` hook | `sessionStart` hook |
| Hook script | `.cursor/bootstrap/claude-session-digest.sh` | dual JSON | dual JSON |

## Slash commands — bảng map

| Claude `/` | Cursor `/` | Skill |
|------------|------------|-------|
| `orchestrator` | `orchestrator` | `sixmen-orchestrator` |
| `it-manager` | `brief` | `sixmen-it-manager` |
| `backend` | `backend` | `sixmen-backend` |
| `frontend` | `frontend` | `sixmen-frontend` |
| `architect` | `architect` | `sixmen-architect` |
| `database` | `database` | `sixmen-database` |
| `ba` | `ba` | `sixmen-ba` |
| `qa` | `qa-gate` | `sixmen-qa` |
| `devops` | `devops` | `sixmen-devops` |

Claude-only / Cursor-only: Cursor có `status`, `pre-merge`, `help` — không bắt buộc mirror sang Claude.

## Quy trình sửa guard (tránh drift)

1. Sửa **`.cursor/rules/{name}.mdc`** (canonical).
2. Cập nhật section tương ứng trong **`.claude/rules/sixmen-always-on-parity.md`**.
3. Ghi **`rules-changelog.md`** + bump Kit Version `AGENTS.md`.
4. Nếu đổi ritual: sync **`.cursor/commands/`** và **`.claude/commands/`**.

## Hooks — phải sửa cả hai

| Hook | Cursor | Claude |
|------|--------|--------|
| Session start | `.cursor/hooks.json` | `.claude/settings.json` § SessionStart |
| Shell guard | `guard-shell-cursor.sh` → `guard-shell-core.sh` | `guard-pretooluse.sh` → cùng core |
| | Chặn: `down -v` · `volume prune/rm` · `system prune --volumes` | Deny/ask trong `settings.json` § permissions |
| Read guard | `guard-read-cursor.sh` | *(permissions)* |
| Sanitize output | `sanitize-tool-output.sh` | cùng script |

## Claude memory cảnh báo

`~/.claude/.../memory/MEMORY.md` **chỉ máy local** — không thay SoT team. Rule cross-agent → **promote** vào SKILL + `rules-changelog` ([`02-governance-and-memory.md`](../02-governance-and-memory.md) § Claude memory).

## Human bắt đầu session

| IDE | Gõ |
|-----|-----|
| Cursor | `/orchestrator` hoặc `/orchestrator Status` |
| Claude Code | `/orchestrator` (mirror → canonical ritual) |

Orchestrator flow: [`orchestrator-how-it-works.md`](orchestrator-how-it-works.md)
