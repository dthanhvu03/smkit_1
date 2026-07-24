---
id: session-continuity
scope: always
enforce: agent-read
title: Session continuity — file SoT, no invented direction
---

# Session continuity — every new chat re-grounds from files

Prior conversation is **not** authoritative. The kit’s memory is under `.kit/`. Before
non-trivial design or code in a **new session** (or when unsure what is in scope):

1. Obey **Constitution** + **Decision Log** (+ domain brief when present).
2. If `.kit/state/current-task` or an `in-progress` task exists, treat that task’s **In/Out**,
   acceptance criteria, and plan as binding — do not quietly expand **Out**.
3. Prefer **`/resume`** when picking up mid-feature; it forces a restatement before edits.
4. If the user’s ask conflicts with recorded direction or task scope → **STOP and confirm**.
5. Do not re-litigate decisions already in the Decision Log unless the user explicitly
   reopens them.

Claude SessionStart injects these files automatically; on Cursor/Copilot/Windsurf, **read
them** (or run `/resume`) at the start of the session — same discipline, no hook required.
