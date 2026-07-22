---
# GENERATED — DO NOT EDIT. Edit engine/ or kit.config.yaml, then run: kit build
name: "ui-design"
description: "Use before building or changing UI — after the feature is clear, before writing components. Invoke to pin the UI contract the founder and code agree on: the design tokens to use, every state a component must handle (including the loading/empty/error states UI usually forgets), and how it reflows on small screens. Turns \"make a screen\" into a spec the code can't quietly cut corners on."
license: "Apache-2.0"
compatibility: "Requires repository read access."
---

# UI Design skill

The bridge from "what it should look/feel like" to a contract the component **must** satisfy.
Run it after the problem is framed (analyst / domain-model) and before the frontend role writes
code. Talk to the founder in plain language ("what does the user see while it loads? when there's
nothing yet? when it fails?"); make the artifact precise. Most UI bugs are a state nobody named or
a raw value that broke theming — design them out here.

## Workflow
1. **Reuse first.** Search the codebase and design system for an existing component/pattern that
   already does this. Extend it before inventing a second one — a parallel pattern is a bug.
2. **Tokens, three tiers** — never hardcode hex/px in a component. Work down the layers:
   - **Primitive / reference** — raw scale, context-free (`color.blue-500`, `space-100 = 4px`).
   - **Semantic** — named by *intent*, referencing primitives (`color.text-critical`,
     `space.gutter`); this is the layer components use, and where theming/contrast is decided.
   - **Component-scoped** — bound to one use (`space-card-padding`) when a component needs its own.
   Pick from the existing token set; propose a new token only when none fits, and say why.
3. **Component contract — every state, not just the happy path.** Declare:
   - **Interaction states**: default · hover · focus (visible ring) · active · disabled.
   - **Data states** (the ones AI-built UI drops): **loading** (skeleton + a visually-hidden
     "Loading" for screen readers), **empty** (a title + the next action, not a blank box),
     **error** (a specific, jargon-free, non-blaming message with an error code when available
     and a Retry action).
   - **Props / variants**: the inputs and the allowed variants, each mapping to states above.
4. **Responsive — mobile-first.** Design the smallest screen first, add `min-width` breakpoints
   upward (project scale, e.g. Tailwind `sm/md/lg/xl/2xl`). For a reusable component whose layout
   depends on its slot, prefer a **container query** over a viewport breakpoint.
5. **Accessibility by design.** Name/role for every interactive element (WCAG 4.1.2),
   keyboard-operable with visible focus (2.1.1/2.4.7), `alt` on images, contrast baked into the
   token pairing (text ≥ 4.5:1, non-text ≥ 3:1). Decide these now, not in review.
6. **Confirm & record.** Present the contract in plain language, get the founder's nod, and record
   the token choices and any new pattern in the task / Decision Log so the next change reuses them.

## Output format (required)
```md
## Component & purpose (one line, founder's words)
## Tokens used (semantic; new tokens flagged + why)
## States (interaction: default/hover/focus/active/disabled · data: loading/empty/error)
## Props & variants
## Responsive behavior (breakpoints or container query)
## Accessibility (name/role, keyboard/focus, alt, contrast pairing)
```
A contract that lists no empty/error/loading state, or hardcodes a raw color/size, fails the bar —
name the state or say plainly why it can't exist (e.g. a purely static element has no data states).
Scale to the mode: `vibe` = the tokens, the three data states, and the top interaction states for
one component; `strict` = the full contract, every variant, and the responsive + a11y detail wired.
