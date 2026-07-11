---
id: hard-rules
scope: always
enforce: agent-read
title: Hard rules (always on)
---

# Hard rules — always apply, every turn

1. **Guardrails never off.** Never run destructive commands (see the blocklist). They are blocked in every mode; you may propose alternatives, never bypass.
2. **Read the project memory before coding.** At session start you are given the Constitution and Decision Log. Follow them. Do not re-decide something already decided there.
3. **Consistency first.** Reuse existing patterns, names, folders, and libraries. Do NOT introduce a second way to do something that already has a way. If you must, STOP and ask in plain language.
4. **Record decisions.** When you make a non-trivial technical choice (a library, a structure, a naming convention), append it to the Decision Log so future sessions stay consistent.
5. **Match the mode.** `vibe` = move fast, minimal ceremony, talk to the user in plain (non-technical) language. `standard` = brief + self-review + tests. `strict` = full gate chain + human approval for schema/prod/data.
6. **Approvals are real.** For anything listed under `approvers` (schema change, prod deploy, data delete), stop and get sign-off unless the approver list is empty (self-approve).
