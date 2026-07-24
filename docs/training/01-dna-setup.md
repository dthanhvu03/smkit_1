# Week 1 — Project DNA setup

Goal: give every new session **durable context** so the agent does not reinvent “what we are” or cross must-nevers.

## Checklist

- [ ] Run `/onboard` (or fill `.kit/constitution.md` by hand)
- [ ] Constitution has all four sections filled (no `<describe…>` placeholders)
- [ ] At least **5** decisions recorded (`.kit/decisions.md` or `.kit/decisions/*.md`)
- [ ] At least **3** high-stakes must-nevers mapped to `kit.config.yaml` → `invariants:`
- [ ] `smkit build` (or `node tools/kitgen/kitgen.mjs build`) after invariants change
- [ ] `smkit doctor` clean
- [ ] Smoke test: **new chat** — ask “What must this project never do?” → agent answers from constitution/invariants

## 1. Constitution (`.kit/constitution.md`)

Write in the project language (`kit.config.yaml` → `project.language`). Plain language.

| Section | Good | Bad |
|---------|------|-----|
| What we are building | One paragraph a stranger understands | Feature list / tech stack dump |
| Who uses it | Roles + jobs (ops, customer, admin) | “Users” |
| Must always be true | Checkable (“every stock move is append-only”) | Vague (“be secure”) |
| Must never happen | Concrete (“no DELETE on production inventory”) | “Don’t break things” |
| Non-negotiable choices | Stack/hosting already decided | Wishlist |

Template: [`.kit/constitution.template.md`](../../.kit/constitution.template.md).

## 2. Decision log

Record choices that must not be relitigated each session:

```md
## YYYY-MM-DD — <title>
- Context:
- Decision:
- Alternatives considered:
- Consequences / reversibility (one-way vs two-way door):
```

Busy team: one file per decision under `.kit/decisions/` (session-start injects both).

Use `/decide` after real choices. Prefer **append**; supersede instead of delete.

## 3. Invariants (enforceable must-nevers)

A line only in the constitution is **soft**. Map hot rules to path-scoped invariants:

```yaml
invariants:
  - path: "src/payments/**"
    rule: "All money changes go through PaymentService and need a test"
  - path: "**/inventory*/**"
    rule: "Balance changes only via InventoryService; movements append-only"
```

Starter examples: [templates/invariants-starter.yaml](templates/invariants-starter.yaml).

Rules:
- Prefer **path + checkable rule**
- What cannot be pathed stays in the constitution
- After edit: rebuild + doctor

## 4. Approvers (strict)

In `kit.config.yaml`:

```yaml
approvers:
  schema_change: ["<name>"]
  prod_deploy: ["<name>"]
  data_delete: ["<name>"]
```

Empty list = self-approve (weaker). For training, put real people.

## 5. Definition of Done (Week 1)

1. Placeholders gone from constitution.  
2. ≥5 decisions.  
3. ≥3 invariants built and visible in generated rules (Cursor `.mdc` / Claude rules).  
4. Fresh session can restate must-nevers correctly.

Then go to [02-user-playbook.md](02-user-playbook.md).
