---
name: ui-design
description: Guides agents through translating an approved UX specification into a structured visual UI design specification (layouts, components, states, responsive behavior, accessibility). Use when an approved UX/RFC exists and visual design, screen layouts, component variants/design-system tokens, or design-tool handoff is required. Do not use for UX journey definition (use ui-ux) or for application code/back-end implementation.
---

# UI Design Skill

## Purpose

Translate an approved UX specification into a visual UI design specification.
The skill covers visual design and presentation, not application code.

Given an approved UX specification: preserve the approved journey and
behavior; define visual hierarchy, screen layouts, reusable components,
visual states, responsive layouts, and accessibility considerations; reuse
existing design-system patterns; produce a structured specification; obtain
human approval; then materialize the approved specification in the project's
design tool (for example Stitch) and record the canonical links. That last
step is mandatory unless the user explicitly waives it (record the waiver and
reason in the artifact).

## When to Use

Use when an approved UX specification, accepted RFC, or approved design-system
change needs visual design; when new screens, major screen changes, or new
reusable components or variants are needed; when responsive or accessibility
visual behavior must be defined before implementation; or when a design-tool
artifact or handoff spec is requested.

Do not use to define user goals, journeys, or interaction behavior (use
`ui-ux`), to implement application code, APIs, or back-end architecture, or
when no approved UX/RFC exists and UX decisions remain open (resolve UX first).

## Scope

In scope: page and screen layouts, visual hierarchy, component composition and
variants, typography and spacing hierarchy, visual emphasis, visual states,
responsive visual behavior, interaction presentation, design-system usage,
accessibility considerations for visual design, and design handoff.

Out of scope: product requirements, UX and user journeys, backend, API, and
database design, application code, pricing, and legal, compliance, or security
architecture decisions.

## Inputs

Use the strongest approved design context, in order: approved UX
specification, accepted RFC, relevant accepted ADRs, existing approved UI
designs, design-system documentation, existing application UI and reusable
components, and the design-tool target (tool name plus project ID/URL, or an
instruction to create a new project). If the target is absent, request it at
approval time (create new vs use existing). Never assume no tool output is
wanted, and never record NOT APPLICABLE without evidence and user agreement.

An unapproved UX specification is not final design authority. If a required
UX decision is unresolved, identify it, do not invent a behavior, and stop to
ask when it materially affects the visual design.

**Design references** (existing designs, sketches, screenshots, images, URLs,
design-system examples) inform layout, hierarchy, density, spacing, component
and navigation patterns, and interaction presentation. They never override the
approved UX, accepted RFC/ADR requirements, product requirements, or
accessibility requirements. Do not copy another product's branding,
proprietary assets, or content unless the user explicitly provided them for
appropriate reuse. When a reference conflicts with approved UX or product
requirements, keep the requirement, explain the conflict, and ask if needed.

## Existing Design and Design System

Before designing, inspect existing approved designs, design-system patterns,
and reusable components for the affected feature, and extend existing patterns
instead of duplicating them. Do not redesign unrelated parts of the app.

If a design system exists, use its tokens, components, and visual language and
reuse patterns before adding new ones. If none exists, define only the minimum
visual foundations the feature needs, do not build a large system for one
screen, and record new reusable patterns for future evaluation. Do not
introduce a new visual language when an existing one suffices.

## UX Preservation

The approved UX specification is the behavioral source of truth. Preserve user
goals, journeys, navigation, interaction behavior, required states,
permission behavior, and responsive and accessibility requirements. Do not
silently change user flow, business behavior, product rules, or permissions.
If the visual design seems to need a UX change, identify the conflict, explain
why the current UX cannot be satisfied, and stop to request the UX decision.

## Workflow

1. Gather the strongest inputs (see Inputs).
2. Inspect existing designs and reusable components, and establish the tokens to reuse (minimum tokens if no system exists).
3. Verify UX preservation. If the visual design requires a UX change, stop and request a UX decision.
4. Classify the design scope (below).
5. Design screens, components, and visual foundations.
6. Produce `docs/ui/design/<feature>/overview.md` with status `Proposed` and request human approval.
7. After approval, materialize the specification in the design tool and record the links (see External Design Tools), or record a user waiver with reason.

```text
UX decision unresolved?           yes → stop, request clarification
Visual change needs UX change?    yes → stop, request UX decision
Specification approved?           no  → stay Proposed
                                  yes → materialize in tool (or record waiver + reason)
```

## Design Scope

Use the smallest scope that fully addresses the approved UX: (1) new screen or
page, (2) major existing-screen change, (3) new reusable component, (4)
existing component variation, (5) small visual adjustment.

## Screen Design

For each relevant screen define: purpose, layout structure, content regions,
navigation placement, visual hierarchy, primary and secondary actions,
component placement, information grouping, state presentation, responsive
behavior, and accessibility considerations.

```text
Screen: Compliance Review
Purpose: Let the editor understand the screening result and correct risky content.
Layout: Two-pane desktop. Left: source caption/editor. Right: findings and remediation actions.
Primary action: Run check / Re-check.
Secondary action: Export report.
```

## Components

For each new or materially changed reusable component define: name, purpose,
variants, states, content requirements, interaction presentation, responsive
behavior, and accessibility considerations. Before defining one, search the
project's components and design system and reuse a suitable existing one. Do
not create duplicate components under different names for the same behavior.

## Visual Foundations

For states, responsive behavior, accessibility, tokens, and interaction
presentation, follow `references/design-foundations.md` (load on demand). Key
rules:

- **States:** design all meaningful states (default, loading, empty, error, success, disabled, validation, permission-denied, pending, selected, expanded/collapsed, hover/focus/active), never happy-path only.
- **Responsive:** define desktop, tablet, and mobile behavior with meaningful layout changes while preserving UX intent; avoid framework-specific CSS unless needed.
- **Accessibility:** consider focus states, keyboard navigation, semantics, labels, contrast, non-color meaning, screen readers, and touch targets. Do not claim compliance from design alone.
- **Tokens:** reuse existing tokens; justify any new one and define the smallest reusable value.
- **Interaction presentation:** describe the appearance of buttons, forms, dialogs, drawers, tooltips, and tabs; do not redefine UX behavior.

## External Design Tools

The workflow is tool-agnostic (Figma, Stitch, or another MCP/adapter), and the
tool-neutral Markdown specification stays the source of truth. After the
specification is approved, materializing it in the design tool is mandatory
unless the user explicitly waives it. Follow
`references/external-design-tools.md` for the procedure, the completion test,
and how to handle generation timeouts and late-arriving screens without
creating duplicates.

## Design Artifact and Status

Save the specification at `docs/ui/design/<feature-or-rfc>/overview.md`. It
must include: feature, design status, UX reference, relevant screens,
components, states, responsive behavior, accessibility considerations, open
design questions, and the external design-tool links (the project link plus
one per materialized screen), or a user waiver with reason. A missing link
without a recorded waiver fails verification, and "not applicable" needs
evidence and user agreement.

Status is `Proposed` (under human review) or `Approved` (explicit human
approval given). Never treat a proposed design as approved.

## Human Approval

For new or materially changed UI, two confirmations are required.

**Approval 1, specification:** present the proposal, identify significant
design decisions, show the artifact or tool reference, ask for explicit
approval, and record `Proposed` → `Approved`.

**Approval 2, design-tool output** (after materialization): present the tool
project and screen links, confirm each tool screen matches the approved
specification (or report deviations), and ask for explicit confirmation unless
the user pre-authorized auto-proceed at Approval 1.

Do not hand an unapproved design to implementation as final.

## Handoffs

**To implementation:** the approved specification becomes the input; reuse
existing components where applicable; keep the design-tool references
available. If implementation finds a conflict between the design and technical
constraints, do not change the design silently; report it and request a
decision.

**To verification:** the specification should let UI verification compare layout,
visual hierarchy, responsive behavior, states, accessibility, and component
consistency against the intended design. This skill does not perform final
implementation verification.

## Verification

After completing visual design, confirm with evidence:

- [ ] The artifact exists and lists feature, status, UX reference, screens, components, states, responsive behavior, accessibility, open questions, and the tool link if applicable.
- [ ] The approved UX journey, navigation, and permission behavior are unchanged (or the conflict was escalated).
- [ ] Existing design-system tokens and components were reused where possible; new tokens are justified and recorded.
- [ ] Every screen defines layout, hierarchy, primary and secondary actions, and states (not happy-path only).
- [ ] Responsive behavior is defined for desktop, tablet, and mobile, and accessibility considerations are documented.
- [ ] Human approval was obtained and the status recorded; nothing was handed off as Approved without explicit approval.
- [ ] The post-approval design-tool step is resolved: canonical links recorded, or a user waiver with reason.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "No design system exists, so invent per-screen colors and fonts." | Define minimum reusable tokens only and record them for reuse; no one-off styling. |
| "The UX spec is a draft, but design can proceed." | Unapproved UX is not final; stop and ask if it affects the visual design. |
| "This reference looks better, so override the UX." | Approved UX/RFC/ADR wins over references; keep the requirement and explain the conflict. |
| "No design-tool project exists, so skip the tool output silently." | Request the target (create new vs use existing); skipping needs evidence and an explicit user waiver. |
| "Generation timed out, so retry immediately." | A timeout is not a failure; poll with backoff and re-check before any retry. |

## Red Flags

- Visual design changes user flow or permission behavior without a UX decision.
- A new component duplicates an existing one under a different name.
- A screen is designed only for desktop or only for the happy path.
- The design-tool link is missing without a recorded user waiver.
- A Proposed design is passed to implementation as final.

## Policies

- `policies/web-best-practices.md`: semantic HTML, accessibility, responsive behavior, design-system usage.
- `policies/verification.md`: UI verification and completion evidence.

## Self-Improvement

Follow `../self-improvement/references/standard.md`.
