---
name: ui-design
description: Transform an approved UX specification into a structured visual design specification for web applications.
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
10. Prepare the design specification for implementation and external design
   tools when available.

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

## Visual states

Design all applicable states identified by the UX specification.

Consider:

- Default
- Loading
- Empty
- Error
- Success
- Disabled
- Validation error
- Permission denied
- Partial/degraded
- Pending
- Selected
- Expanded
- Collapsed
- Hover
- Focus
- Active

Only include states that are meaningful for the component or screen.

Do not design only the happy path.

## Responsive design

Define visual behavior for:

- Desktop
- Tablet
- Mobile

Describe meaningful layout changes.

Examples:

- Two columns become stacked.
- Side navigation becomes a drawer.
- Tables become cards.
- Actions move to a bottom action area.
- Secondary information becomes collapsible.

Responsive behavior must preserve the UX intent.

Do not prescribe framework-specific CSS unless needed for clarity.

## Accessibility

Accessibility must be considered during design.

Consider:

- Visible focus states
- Keyboard navigation
- Semantic grouping
- Form labels
- Error presentation
- Accessible names
- Contrast
- Non-color-only meaning
- Screen-reader interpretation
- Touch target clarity
- Responsive text/content behavior

Do not claim accessibility compliance from design alone.

Accessibility is verified later.

## Design tokens

When the project has a design system, use existing tokens.

When a new visual token is genuinely required:

- Explain why the existing system cannot satisfy the requirement.
- Define the smallest appropriate token.
- Prefer reusable values over one-off styling.

Avoid arbitrary per-screen values when a reusable design token is suitable.

## Interaction presentation

Describe how interactions should appear visually.

Examples:

- Buttons
- Forms
- Validation
- Confirmation dialogs
- Drawers
- Tooltips
- Tabs
- Accordions
- Toasts
- Inline feedback
- Progress indicators

Do not redefine interaction behavior that belongs to the UX specification.

## External design tools

The skill is tool-agnostic.

When an external design tool is available, the design may be created or
represented through an appropriate tool or adapter.

Supported examples may include:

- Figma
- Stitch
- Other compatible design tools

Do not make the skill dependent on a specific design platform.

The tool-neutral UI design specification remains the source document for
the implementation workflow.

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
- External design-tool link when applicable

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

For new or materially changed UI:

1. Present the visual design proposal.
2. Identify significant design decisions.
3. Show the relevant design artifact or external design-tool reference.
4. Ask for explicit human approval.
5. Record the approval status.

Do not hand an unapproved design to implementation as final.

## External design tools

The UI Design workflow is design-tool agnostic.

When an approved design needs to be materialized in an external design tool,
use an available design-tool integration or MCP capability.

The agent must:
- preserve the approved UX and UI specification;
- use the available design tool without changing product behavior;
- record the canonical design artifact/link;
- report integration failures without silently substituting another tool.

The specific design tool is determined by the available integration.


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

## Self-Improvement

Follow the common self-improvement standard in:

`../self-improvement/references/standard.md`
