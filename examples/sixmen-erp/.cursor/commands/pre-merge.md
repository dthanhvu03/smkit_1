# Pre-merge — kiểm tra trước merge main

Read `.cursor/skills/sixmen-orchestrator/SKILL.md` § Git sync · Branch lifecycle.

## Checklist (theo thứ tự)

1. Xác định Task-ID + branch hiện tại
2. **Sync main vào feature** (không chỉ `pull main`):
   ```bash
   bash .cursor/bootstrap/sync-main-into-branch.sh
   ```
3. Chạy gate:
   ```bash
   bash .cursor/bootstrap/pre-merge-check.sh -t {Task-ID}
   ```
4. Nếu FAIL conflict / behind → resolve hoặc **Cách B** (branch mới từ main + cherry-pick delta)
5. CI PR (nếu `gh` login) hoặc link compare GitHub

## Blockers (script FAIL)

- `Behind > 0` — chưa sync main vào feature
- Merge dry-run conflict — GitHub sẽ báo "Can't automatically merge"
- Pint / architecture-lint / Pest FAIL

## Verdict

**merge được / chặn** + lý do. Nhắc smoke test sau merge nếu PASS.
