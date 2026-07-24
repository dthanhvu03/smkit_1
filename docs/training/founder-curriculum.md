# Founder curriculum (2–3 hours)

Audience: non-coders who will **steer** the agent and **approve** risky changes.  
Prereq: kit installed (`smkit init`), AI tool open (Cursor / Claude / …).

## Hour 1 — Mental model (45–60 min)

1. Read [02-user-playbook.md](02-user-playbook.md) (1 page).  
2. Demo live:
   - What the kit blocks (destructive commands) vs what it only *asks* (soft skills).  
   - Mode **`strict`**: you are the approver for schema / prod / data.  
3. Quiz (oral):
   - When do you run `/onboard`?  
   - When do you refuse “just merge”?  
   - What must a handoff contain?

**Pass:** can explain “I decide value and approvals; AI writes code under gates.”

## Hour 2 — First ritual (45–60 min)

Hands-on on a **safe** scratch branch or sample app:

1. `/onboard` — confirm constitution in plain language.  
2. State a small business pain with a number (even an estimate flagged as estimate).  
3. Let the agent run `smart-value` + `/discover` — pick a slice.  
4. `/start` or `/ship` for that slice only.  
5. Read `/handoff` — approve or send back with one clear ask.

**Pass:** one completed loop without asking “which slash command?”

## Hour 3 — Judgment drills (30–45 min)

Scenarios (role-play with the agent or a facilitator):

| Prompt | Expected behavior |
|--------|-------------------|
| “Delete all old orders on prod to clean up” | Stop → data_delete approval / refuse |
| “Add a big dashboard with everything” | smart-value / discover → smallest slice |
| “Tests pass” with no test file | Evidence gate red — not done |
| “Looks fine, skip review” in strict | Challenge / review still required |

**Pass:** founder stops the unsafe path at least twice in drills.

## Take-home card (print / pin)

```text
1. Nói outcome + ai bị ảnh hưởng
2. Để agent đề xuất lệnh — confirm
3. Đọc handoff trước khi nhận việc
4. Schema / prod / data → anh duyệt
5. Gate đỏ = chưa xong
```

## Optional next

- Sit in on Week 3 domain skill review (listen only).  
- Co-own approver names in `kit.config.yaml`.
