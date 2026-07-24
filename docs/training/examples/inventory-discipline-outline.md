# Example outline — inventory discipline

Worked outline you can paste into the [domain-skill scaffold](../templates/domain-skill/) for a stock/inventory domain. Adjust names to your SoT. For a full ERP pack see [`examples/sixmen-erp/`](../../../examples/sixmen-erp/).

```text
id:          inventory-discipline
when:        Changing stock/balance/movements, or asking to "fix inventory", GRN, adjustment, transfer
first move:  Read ERD + architecture envelope; restate: balance only via InventoryService; movements append-only
never:       Direct UPDATE on balance tables; DELETE movement history; mutate on reporting replica
output:      Touchpoints · Invariants · Legal transitions · Service boundary · Tests · HO gates
hand-off:    db-admin if schema; implementer for service; qa for Pest/happy+403; HO if migration
```

Suggested SoT pointers (replace with yours):

- ERD: `docs/erp/phases/.../ERD.md`
- Architecture envelope: `docs/.../04_Architecture.md` (single-entry services)
- Data safety: no prod DELETE/TRUNCATE; corrections via adjustment/reversal

Wire command-routing row:

| What the user is really asking for | Propose |
|---|---|
| Fix / change stock, GRN, warehouse balance | **inventory-discipline** skill, then `/ship` or `/start` |
