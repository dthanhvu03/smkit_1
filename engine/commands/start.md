---
id: start
title: Start or continue a task
description: Begin (or resume) work. Reads the project memory, plans the smallest next step, and builds it per the current mode.
argument-hint: "[what you want to build]"
---

# /start

1. Read `.kit/constitution.md` and `.kit/decisions.md`. Obey them.
2. If the user gave a request, restate it in one plain sentence and confirm. If not, ask what they want to build.
3. Plan the **smallest useful next step** (not the whole thing).
4. Build it following the current mode:
   - `vibe`: just do it, reuse existing patterns, talk in plain language.
   - `standard`: short brief → build → self-review → run tests.
   - `strict`: full gate chain; get approver sign-off for schema/prod/data.
5. When a non-trivial decision is made, append it to `.kit/decisions.md`.
6. Finish with a plain-language summary of what changed and ask what's next.
