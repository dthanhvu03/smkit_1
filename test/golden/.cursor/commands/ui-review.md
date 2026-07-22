<!-- GENERATED — DO NOT EDIT. Edit engine/ or kit.config.yaml, then run: kit build -->

# UI Review skill

Review the user-facing changes — read the diff and the rendered states, don't declare it works at
runtime (that's qa). Complements **code-review**: that skill owns correctness and security; this one
owns accessibility, states, responsiveness, and token consistency.

For the WCAG 2.2 checklist (which criteria, what level, what's auto-checkable vs manual) and the
missing-state / responsive checks, work from
**[references/wcag-checklist.md](references/wcag-checklist.md)** — open it and use it as the checklist
rather than reviewing from memory.

## Workflow
1. Identify the changed UI (components/screens/styles in the diff). For a large diff, review in
   bounded chunks and say what was and wasn't covered.
2. **Accessibility (§1 of the reference).** For each interactive element check: accessible
   name + role (4.1.2, A), keyboard-operable + no trap (2.1.1/2.1.2, A), visible focus (2.4.7, AA);
   images have `alt`; contrast pairings meet 1.4.3 / 1.4.11. Flag target-size (2.5.8) and
   focus-not-obscured (2.4.11) as manual checks — they over-flag if automated naively.
3. **States (§2).** Confirm every data-bearing component handles **loading, empty, and error** —
   the states most often missing. An error with no message/Retry, or an empty view that's just a
   blank box, is a finding, not a nit.
4. **Responsive (§3).** Check it holds mobile-first from the smallest breakpoint up — no horizontal
   scroll, no clipped/overlapping content, touch targets usable.
5. **Token consistency (§4).** Flag raw hex/px where a semantic token exists, and any second
   pattern for something the design system already solves.
6. Rank findings by severity (blocker · major · minor · nit), most severe first, each with
   file:line, why it matters (which criterion / which state), and the fix. Substance over style.

## Output format (required)
```md
## Summary
## Changed UI reviewed (and any not covered)
## Findings
| Severity | File:line | Issue | Criterion / state | Fix |
|---|---|---|---|---|
## Required fixes (blocker / major)
## Optional improvements (minor / nit)
## Accessibility evidence (what was checked: keyboard, focus, contrast, states)
## Verdict (ship / fix first)
```
Severity must be one of **blocker · major · minor · nit**. An empty **Accessibility evidence**
section fails the gate — say concretely what you checked (axe/lint output, or manual keyboard/focus
and the empty/error states you exercised). Scale to the mode: `vibe` = a11y basics + the three data
states; `strict` = the full WCAG subset, responsive, and token audit.
