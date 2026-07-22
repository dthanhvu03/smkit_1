# UI Review reference — WCAG 2.2 subset, missing states, responsive, tokens

The checklist the ui-review skill works from. Grounded in the WCAG 2.2 W3C Recommendation and
mature design-system guidance. Use it as the list to check against, not from memory.

## §1 — Accessibility: the enforceable WCAG 2.2 subset

Check these on every changed component. Level and auto-checkability noted, because the honest
enforcement story differs per criterion.

| Criterion | Level | Check | Auto-checkable? |
|---|---|---|---|
| **1.1.1 Non-text Content** | A | Every meaningful image/icon has a text alternative (`alt`, `aria-label`); decorative images are `alt=""`. | Presence: yes. Quality of the text: no. |
| **2.1.1 Keyboard** | A | All functionality is operable by keyboard alone — every control reachable and actionable via Tab/Enter/Space/arrows. | Partly (lint catches obvious gaps). |
| **2.1.2 No Keyboard Trap** | A | Focus that enters a component can leave it with the keyboard (no trap in modals/widgets). | Manual. |
| **4.1.2 Name, Role, Value** | A | Every interactive element has an accessible **name** and correct **role**; stateful controls expose state (`aria-expanded`/`checked`/`selected`/`disabled`). *The single most enforceable component invariant.* | Presence: yes (`eslint-plugin-jsx-a11y`, axe). |
| **2.4.7 Focus Visible** | AA | A visible keyboard focus indicator on every interactive element (don't remove outlines without a `:focus-visible` replacement). | Partly — presence detectable, *quality* is manual. |
| **2.4.11 Focus Not Obscured (Minimum)** | AA *(new in 2.2)* | A focused element is not entirely hidden by author content (sticky headers/footers, cookie bars). | Manual. |
| **1.4.3 Contrast (Minimum)** | AA | Text ≥ **4.5:1**; large text (≥18pt or ≥14pt bold) ≥ **3:1**. (Exceptions: incidental/disabled text, logotypes.) | Yes (axe/Lighthouse). |
| **1.4.11 Non-text Contrast** | AA | UI components and graphical objects ≥ **3:1** against adjacent colors (borders, icons, focus rings, chart marks). | Partly. |
| **2.5.8 Target Size (Minimum)** | AA *(new in 2.2)* | Pointer targets ≥ **24×24 CSS px** — *unless* the Spacing / Inline / Equivalent / User-agent / Essential exception applies. | Manual — honor the exceptions or it over-flags. |

**Enforcement honesty.** Only *presence of accessible name/role* and *`alt`* are reliably static —
those belong in the path-scoped a11y rule and in `eslint-plugin-jsx-a11y`. **Contrast** is best
enforced by axe/Lighthouse in CI. **Focus quality, target size, focus-not-obscured** need a human
or heuristic eye — keep them on this checklist, don't pretend a markdown rule blocks them.

Source: WCAG 2.2 — https://www.w3.org/TR/WCAG22/ · Quickref — https://www.w3.org/WAI/WCAG22/quickref/
· New in 2.2 — https://www.w3.org/WAI/standards-guidelines/wcag/new-in-22/

## §2 — Missing states (the most common UI defect)

A data-bearing component must handle three states beyond the happy path — treat a missing one as a
**major** finding, not a nit:

- **Loading** — a skeleton/placeholder, plus a visually-hidden "Loading" so screen readers announce
  it (skeletons are silent to AT by default).
- **Empty** — data loaded but there's nothing to show: a title + the next action, never a blank box.
- **Error** — loading failed: a message that is **specific**, **jargon-free**, **doesn't blame the
  user**, includes an **error code** when available, and offers a **Retry**.

Also confirm the interaction states are styled: default · hover · focus · active · disabled.

Source: gov.au design system (loading/error/empty) — https://design-system.agriculture.gov.au/patterns/loading-error-empty-states
· IBM Carbon empty states — https://carbondesignsystem.com/patterns/empty-states-pattern

## §3 — Responsive

- **Mobile-first**: styles hold from the smallest screen up, using `min-width` breakpoints.
- No **horizontal scroll**, no clipped or overlapping content at any breakpoint.
- Touch targets remain usable on small screens (ties back to 2.5.8).
- For components whose layout depends on their container (not the viewport), a **container query**
  is the correct tool.

Source: Tailwind responsive design — https://tailwindcss.com/docs/responsive-design

## §4 — Token consistency

- No raw hex/px in a component where a **semantic token** exists.
- No second pattern for something the design system already solves (spacing scale, color intent).
- New tokens are justified (none existing fit) and named by intent, not by raw value.

## Severity rubric

- **blocker** — unusable by keyboard/AT, or a state that loses user data / shows a raw stack trace.
- **major** — missing empty/error/loading, contrast failure, no accessible name on a control.
- **minor** — focus ring weak, small target with a plausible exception, minor responsive glitch.
- **nit** — anything a formatter/linter owns; note it, don't block on it.

## Effectiveness limits

This review reads code and rendered states; it does **not** replace running the app (qa) or an
automated axe/Lighthouse pass. Say what you could and couldn't verify — an unrun contrast check is
"not verified", not "passed".
