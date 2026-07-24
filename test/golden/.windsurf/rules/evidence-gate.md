---
# GENERATED — DO NOT EDIT. Edit engine/ or kit.config.yaml, then run: kit build
trigger: always_on
---

# Evidence gate — don't claim done without proof

- **Never report a task as done, passing, or fixed without evidence.** State what you actually ran and its result.
- If tests exist: run them and quote the outcome (pass/fail counts). If they fail, say so with the output — do not hide it.
- **A ticked "Tests pass" claim must name the real test file(s) and the command output.** "e2e / Docker tests", "tests pass", or a checked test-gate with **no corresponding test file that actually exists in the change** is a **RED gate, not a green one** — evidence is a file someone can run, not a sentence describing one. If you couldn't run it (no DB, not written yet), say exactly that and leave the gate unchecked; never tick a gate for a test that doesn't exist.
- If there are no tests: describe concretely how you verified the behavior (what you ran, what you observed).
- If a step was skipped or is unverified, say that plainly — don't imply it was checked.
- Skills that produce a review/verdict (code-review, test-design) must fill their **Test evidence** section; an empty evidence section means the gate is not satisfied.

## Required artifacts by risk (completeness)
Some change types are not "done" until a specific artifact exists — this is **not optional**, it is part of the gate:
- **Schema / data-shape change** → a **migration note AND a rollback step** (in the task / handoff). No migration note → not ready to ship.
- **Money, authentication, or personal-data (PII) touch** → a plain-language **business walkthrough**, a **second review pass**, AND a filled **`security-review`** output (attack surface · exploit scenarios · verdict). A bare diff or "looks fine" is not enough.
- **Auth, secrets, shell/command execution, file-path from user input, or new network fetch of user URLs** → **`security-review`** required even if not money/PII (same output bar).
- **Destructive or irreversible operation** → the **reversible / backed-up step is written down** before it runs.

If a required artifact is missing, STOP and produce it — or state plainly why it does not apply — before shipping. This mirrors the task file's **Gate status** checklist; keep the two in sync.

## Scanners vs kit review (hybrid)
The kit's `security-review` catches **logic / authz / design** flaws scanners miss. Dependency CVEs, leaked secrets, and known vulnerable packages belong in **CI** (`ci-pipeline` → kit-security workflow: audit · gitleaks · Trivy). Do not claim "no vulns" from markdown review alone when CI scanners were skipped without saying so.
