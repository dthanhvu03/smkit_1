---
id: onboard
title: Read the project and finish setup
description: On first use, have the agent read your codebase and fill in the project's constitution — what it is, who it's for, what it must never do, and its stack — then confirm with you. Turns a zero-question install into an accurate setup without a cold interview.
argument-hint: "[anything you want to add about the project]"
---

# /onboard

Finish setting up the kit by **reading the project instead of interrogating the user**. Run this once after `smkit init` (or whenever `.kit/constitution.md` is still placeholders).

1. **Read the project.** Look at the `README`, the manifest (`package.json` / `go.mod` / `pyproject.toml` / …), the folder structure, and a few key files. Infer what this project is, who it's for, the stack(s), and any obvious high-stakes "must never" (money, auth, personal data, production).
2. **Draft the constitution** into `.kit/constitution.md`, in the project's language (`kit.config.yaml` → `project.language`):
   - **What we are building** — one plain-language paragraph.
   - **Who uses it** — the real users.
   - **Must never happen** — the concrete, high-stakes lines for THIS project.
3. **Confirm, don't assume.** Present the draft in plain language and ask the founder to confirm or correct — *"You're building X for Y, and it must never Z — right?"* — then adjust. A couple of yes/no confirmations is enough; don't lecture.
4. **Reconcile the stack.** Compare `kit.config.yaml`'s `stack.profile` with what you actually see. If a stack is missing/wrong, or a monorepo needs per-folder `roots` (e.g. `go: apps/api`, `nextjs: apps/web`), propose the change, get a nod, edit the config, and rebuild (`smkit build`).
5. **Wire the enforceable must-nevers into `invariants:`.** A "must never" that lives only in the constitution is *soft* — the AI may drift from it as context grows. For each high-stakes line that maps to a **path + a checkable rule**, add it to `kit.config.yaml` → `invariants:` so the generator emits a **path-scoped rule** that fires whenever that area is touched — e.g. `path: "**/dto/**|**/public/**", rule: "public response = allowlist only, no PII/secret fields"`; `path: "**/*_admin*|**/handler/*admin*", rule: "every state change writes an audit record + actor"`. Propose the mapping, get a nod, edit the config, rebuild. What can't be pathed stays a constitution line.
6. **Record it.** Save the constitution, note any real decisions in `.kit/decisions.md`, and give a one-line summary of the setup. From here the consistency rules keep the AI aligned with the actual project.
7. **Domain brief (smart research once).** If the app direction is now clear and `.kit/domain-brief.md` is missing or still a template, run the **`domain-research`** skill: produce a dated brief (patterns · risks · sources) into `.kit/domain-brief.md`. Do **not** research again on every later reply — SessionStart will reuse the brief. Skip research for pure internal tools with no market/domain ambiguity if the founder says so.

Scale to the mode: `vibe` = a short draft + one confirmation; `standard` / `strict` = the full constitution and a recorded sign-off. **Never overwrite a constitution the user has already written** without asking — only fill placeholders or propose edits.
