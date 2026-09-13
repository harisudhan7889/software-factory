---
name: ui-design
description: Guides agents through translating an approved UX specification into a structured visual UI design specification (layouts, components, states, responsive behavior, accessibility). Use when an approved UX/RFC exists and visual design, screen layouts, component variants/design-system tokens, or design-tool handoff is required. Do not use for UX journey definition (use ui-ux) or for application code/back-end implementation.
---

# UI Design Skill

This skill defines the reusable process for translating an approved UX
specification into a visual UI design specification.

It focuses on visual design and presentation.

It does not implement application code.

## Purpose

Given an approved UX specification:

1. Preserve the approved user journey and behavior.
2. Define visual hierarchy.
3. Define layouts for relevant screens.
4. Select or define reusable UI components.
5. Define visual states.
6. Define responsive layouts.
7. Define accessibility considerations.
8. Reuse existing design-system patterns where possible.
9. Produce a structured UI design specification.
10. Obtain human approval of the specification.
11. Materialize the approved specification in the project's design tool
    (e.g. Stitch) and record the canonical links — see ## External design tools.
    This step is mandatory after approval unless the user explicitly waives
    it (record the waiver + reason in the artifact).

## When to Use

Use when:
- An approved UX specification, accepted RFC, or approved design-system change requires visual design.
- New screens, major screen changes, or new reusable components/variants are needed.
- Responsive or accessibility visual behavior must be defined before implementation.
- A design-tool artifact or handoff spec is requested.

Do not use when:
- Defining user goals, journeys, or interaction behavior (use `ui-ux` skill).
- Implementing application code, APIs, or back-end architecture.
- No approved UX/RFC exists and UX decisions remain open — resolve UX first.

## Scope

This skill is responsible for:

- Page and screen layouts
- Visual hierarchy
- Component composition
- Typography hierarchy
- Spacing hierarchy
- Visual emphasis
- Component variants
- Visual states
- Responsive visual behavior
- Interaction presentation
- Design-system usage
- Accessibility considerations for visual design
- Design handoff

This skill is not responsible for:

- Product requirements
- UX/user journeys
- Backend architecture
- API implementation
- Application code
- Database design
- Product pricing
- Legal decisions
- Compliance decisions
- Security architecture

## Inputs

Use the strongest available approved design context.

Preferred inputs:

1. Approved UX specification
2. Accepted RFC
3. Relevant accepted ADRs
4. Existing approved UI designs
5. Existing design-system documentation
6. Existing application UI and reusable components
7. Design-tool target: tool name (e.g. Stitch, Figma) + project reference
   (project ID/URL, or instruction to create a new project). If absent, the
   agent must request it at approval time (create-new vs use-existing) — never
   assume no design-tool output is wanted and never record NOT APPLICABLE
   without evidence and user agreement.

An unapproved UX specification must not be treated as final design authority.

If required UX decisions remain unresolved:

- Identify the unresolved decision.
- Do not silently invent a UX behavior.
- Stop and request clarification when the unresolved decision materially
  affects the visual design.

## Design references

The UI Design workflow may receive one or more design references provided by
the user or project.

References may include:

- Existing approved project designs
- Sketch documents
- Screenshots
- Images
- URLs
- Design-system examples
- Other visual references

Use design references to inform visual direction such as:

- Layout patterns
- Visual hierarchy
- Information density
- Spacing
- Component patterns
- Navigation patterns
- Interaction presentation

Design references must not override:

- The approved UX specification
- Accepted RFC requirements
- Accepted ADR decisions
- Product requirements
- Accessibility requirements

Do not copy another product's branding, proprietary assets, or content
unless the user has explicitly provided them for reuse and the reuse is
appropriate.

When a reference conflicts with the approved UX or product requirements:

- Preserve the approved UX/product requirement.
- Explain the visual conflict.
- Ask for clarification when necessary.  

## Existing design

Before creating new visual design:

1. Inspect existing approved designs for the affected feature.
2. Inspect existing design-system patterns.
3. Inspect existing reusable UI components.
4. Identify patterns that can be reused.
5. Extend existing patterns where appropriate.

Prefer reuse over creating duplicate visual patterns.

Do not redesign unrelated parts of the application.

## Design system

If the project already has a design system:

- Use its tokens and components.
- Follow its established visual language.
- Reuse existing patterns before introducing new ones.

If no design system exists:

- Define only the minimum visual foundations required for the feature.
- Avoid creating a large design system for a single screen.
- Record newly introduced reusable patterns so they can be evaluated for
  future reuse.

Do not introduce a new visual language when an existing one is sufficient.

## UX preservation

The approved UX specification is the behavioral source of truth.

Preserve:

- User goals
- User journeys
- Navigation
- Interaction behavior
- Required states
- Permission behavior
- Responsive requirements
- Accessibility requirements

Do not silently change:

- User flow
- Business behavior
- Product rules
- Permission behavior

If visual design appears to require a UX change:

1. Identify the conflict.
2. Explain why the visual design cannot satisfy the current UX.
3. Stop and request the required UX decision.

## Workflow

1. Gather strongest inputs (approved UX, RFC, ADRs, existing designs, design-system docs) — see ## Inputs.
2. Inspect existing designs and reusable components — see ## Existing design.
3. Establish design-system tokens to reuse — see ## Design system; if none, define minimum tokens.
4. Verify UX preservation; if visual design requires UX change → stop and request UX decision (see diagram below).
5. Classify scope (new screen / major change / new component / variation / small adjustment) — see ## Determine design scope.
6. Design screens and components (layout, hierarchy, states, responsive, accessibility) — see ## Screen design, ## Components, ## Visual foundations (references/design-foundations.md).
7. Produce `docs/ui/design/<feature>/overview.md` with status `Proposed` and request human approval of the specification — see ## Design artifact, ## Design status, ## Human approval.
8. After approval: materialize the approved specification in the project's design tool and record the canonical links — see ## External design tools. Only a user waiver (recorded with reason) skips this step.

```
              ┌─ UX decision unresolved? ─ yes ─► Stop, request clarification
              │                                          │
              └─ no ─► Continue                         │
              ┌─ Visual change needs UX change? ─ yes ──► Stop, request UX decision
              └─ no ─► Continue to Scope classification
                                                         │
              ┌─ Specification approved? ─ no ─► Stay Proposed, await approval
              │                                          │
              └─ yes ─► Materialize in design tool (or record user waiver + reason)
```

## Determine design scope

Not every UI change requires a complete visual design exercise.

Classify the work as one of:

1. New screen or page
2. Major existing-screen change
3. New reusable component
4. Existing component variation
5. Small visual adjustment

Use the smallest design scope that fully addresses the approved UX.

## Screen design

For each relevant screen define:

- Screen purpose
- Layout structure
- Content regions
- Navigation placement
- Visual hierarchy
- Primary action
- Secondary actions
- Component placement
- Information grouping
- State presentation
- Responsive behavior
- Accessibility considerations

Example:

```text
Screen:
Compliance Review

Purpose:
Allow the editor to understand the screening result and correct risky
content.

Layout:
Two-pane desktop layout.

Left:
Source caption/editor.

Right:
Findings and remediation actions.

Primary action:
Run check / Re-check.

Secondary action:
Export report.
```

## Components

For every newly introduced or materially changed reusable component define:

- Name
- Purpose
- Variants
- States
- Content requirements
- Interaction presentation
- Responsive behavior
- Accessibility considerations

Before defining a new component:

- Search existing project components.
- Search the project's design system.
- Reuse an existing component when suitable.

Do not create duplicate components with different names for the same
behavior.

## Visual foundations

For states, responsive behavior, accessibility, design tokens, and interaction presentation, follow `references/design-foundations.md` (load on demand). Key rules:

- **Visual states** — design all meaningful states (default, loading, empty, error, success, disabled, validation, permission-denied, pending, selected, expanded/collapsed, hover/focus/active); never happy-path-only.
- **Responsive** — define desktop/tablet/mobile behavior with meaningful layout changes (stacked columns, drawer, cards, etc.); preserve UX intent; avoid framework-specific CSS unless needed.
- **Accessibility** — consider focus states, keyboard navigation, semantics, labels, contrast, non-color meaning, screen-reader and touch targets; do not claim compliance from design alone.
- **Design tokens** — reuse existing tokens; when a new token is genuinely required explain why, define the smallest reusable value.
- **Interaction presentation** — describe visual appearance of buttons, forms, dialogs, drawers, tooltips, tabs, etc.; do not redefine UX behavior.

## External design tools

The workflow is tool-agnostic. Supported integrations include Figma, Stitch, or other MCP/adapters — do not make the skill dependent on a specific platform. The tool-neutral Markdown specification remains the source of truth.

After the specification is approved, materializing it in the project's design tool is mandatory — it is not an optional follow-up. The only way to skip it is an explicit user waiver, recorded in the Design artifact section with the reason.

When materializing an approved design in an external tool, the agent must:
- preserve the approved UX and UI specification without changing product behavior;
- use the project's configured design-tool target (tool + project reference from ## Inputs); if no target is configured, request it (create-new vs use-existing) instead of skipping;
- create or update one screen per approved screen, then review each tool screen against the specification; fix deviations through tool edits, never by redefining the spec silently;
- record the canonical project/screen links in the Design artifact section;
- report integration failures with evidence, without silently substituting another tool.

Completion test for this step: every approved screen exists in the tool, matches the specification (layout, hierarchy, states, responsive intent), and its link is recorded — or a user waiver with reason is recorded instead.

### Generation timeouts and late arrivals

Generation calls may time out client-side while the design tool keeps working server-side — a timeout is not evidence of failure. Evidence: timed-out requests have repeatedly landed minutes later, and every blind retry produced a duplicate screen.

Rules:

- On a generation timeout, do not retry immediately. Poll `list-screens` (or the tool equivalent) with ~90s backoff, up to ~10 minutes total, to confirm absence.
- Re-check the screen list immediately before any retry. Only retry on confirmed absence.
- A late-arriving screen from the original request counts as success — adopt it, do not regenerate.
- Prefer editing the landed screen over regenerating it when corrections are needed.
- If duplicates do occur (no delete capability, or a very late arrival), record primary vs duplicate in the artifact and reference only the primary going forward; never silently drop the record.

## Design artifact

When the visual design is ready for handoff, save the design specification
as a project-level Markdown artifact.

Preferred location:

`docs/ui/design/<feature-or-rfc>/overview.md`

The artifact must include:

- Feature
- Design status
- UX reference
- Relevant screens
- Components
- States
- Responsive behavior
- Accessibility considerations
- Open design questions
- External design-tool links (one per materialized screen plus project link),
  OR a user waiver with reason when materialization was explicitly skipped.
  A missing link without a recorded waiver fails verification — "not
  applicable" requires evidence (e.g. no integration exists) AND user agreement,
  never a silent default.

Example:

```text
Design tool:
Figma

Design:
<canonical Figma URL>
```

## Design status

Every UI design artifact must have one of:

- `Proposed`
- `Approved`

`Proposed` means it is still under human review.

`Approved` means explicit human approval has been given.

Never treat a proposed design as approved.

## Human approval

For new or materially changed UI, two confirmations are required:

Approval 1 — specification:
1. Present the visual design proposal.
2. Identify significant design decisions.
3. Show the relevant design artifact or external design-tool reference.
4. Ask for explicit human approval.
5. Record the approval status (`Proposed` → `Approved`).

Approval 2 — design-tool output (after materialization per ## External design tools):
1. Present the tool project/screen links.
2. Confirm each tool screen matches the approved specification (or report deviations).
3. Ask for explicit human confirmation unless the user pre-authorized auto-proceed at Approval 1.

Do not hand an unapproved design to implementation as final.

## Handoff to implementation

After approval:

- The approved UI design specification becomes implementation input.
- The implementation workflow should follow the approved design.
- Existing reusable components should be used where applicable.
- External design-tool references should remain available to the
  implementation workflow.

If implementation discovers a conflict between approved design and
technical constraints:

- Do not silently change the design.
- Report the conflict.
- Request a decision.

## Handoff to verification

The design specification should provide enough information for UI
verification to compare implementation against intended behavior and
appearance.

Verification should consider:

- Layout
- Visual hierarchy
- Responsive behavior
- States
- Accessibility
- Component consistency

The design skill does not perform final implementation verification.

## Verification

After completing visual design, confirm with evidence:
- [ ] Artifact at `docs/ui/design/<feature>/overview.md` exists and lists Feature, Design status, UX reference, Screens, Components, States, Responsive behavior, Accessibility, Open questions, and external tool link if applicable
- [ ] Approved UX journey, navigation, and permission behavior preserved unchanged (or conflict was escalated)
- [ ] Existing design-system tokens/components reused where possible; new tokens justified and recorded
- [ ] All screens define layout, visual hierarchy, primary/secondary actions, and states per UX spec (no happy-path-only)
- [ ] Responsive behavior defined for desktop/tablet/mobile with meaningful layout changes
- [ ] Accessibility considerations documented (focus, semantics, labels, contrast, touch targets)
- [ ] Human approval obtained and status recorded as Proposed or Approved; never handed off as Approved without explicit approval
- [ ] Post-approval design-tool step resolved: canonical project/screen links recorded, OR a user waiver with reason recorded. A missing link without a waiver fails this checklist — "not applicable" needs evidence AND user agreement

## Common Rationalizations
| Rationalization | Reality |
|---|---|
| No design system exists, so invent per-screen colors/fonts | Define minimum reusable tokens only; record for future reuse — don't create one-off styling |
| UX spec is draft but design can proceed | Unapproved UX must not be treated as final — stop and request clarification if it affects visual design |
| Design reference looks better, so override UX | Approved UX/RFC/ADR always wins over references — preserve requirement and explain conflict |
| No design-tool project exists, so skip tool output silently | Request the design-tool target (create-new vs use-existing) — skipping needs evidence AND an explicit user waiver, never silence |
| Generation timed out, so retry immediately | A timeout is not a failure — poll with backoff (~90s, up to ~10 min) and re-check before any retry; late arrivals count as success |

## Red Flags
- Visual design changes user flow or permission behavior without UX decision
- New component duplicates an existing reusable component under a different name
- Screen designed only for desktop or only happy-path state
- Design-tool artifact link missing from handoff artifact without a recorded user waiver
- Unapproved (Proposed) design passed to implementation as final

## Policies

Use:
- `policies/web-best-practices.md` for semantic HTML, accessibility, responsive behavior, and design-system usage.
- `policies/verification.md` for UI verification and completion evidence.

## Self-Improvement

Follow the common self-improvement standard in:

`../self-improvement/references/standard.md`
