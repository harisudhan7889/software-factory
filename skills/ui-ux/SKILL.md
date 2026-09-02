---
name: ui-ux
description: Guides agents through analyzing web UI user experience and producing a structured UX specification (goals, journeys, screens, interactions, states) before visual design or implementation. Use when a product requirement, RFC, or feature needs UX analysis, new/modified user journeys/screens, or UX edge-case definition. Do not use for visual styling, component tokens, or application code (use ui-design).
---

# UI/UX Skill

This skill defines reusable UX analysis for product features that involve a
web user interface.

The skill focuses on understanding how users accomplish their goals.

It does not define visual styling or implementation details.

## Purpose

Given a product requirement, RFC, or feature description:

1. Understand the user's goal.
2. Identify the primary user journey.
3. Determine the screens and navigation required.
4. Define interactions and applicable UI states.
5. Identify important edge cases.
6. Consider accessibility and responsive behavior.
7. Produce a structured UX specification that can be consumed by UI design and implementation workflows.

## When to Use

Use when:
- A product requirement, accepted RFC, or feature description requires understanding user goals/journeys before UI work.
- New screens, journey modifications, or interaction/state design is needed.
- Existing UX must be validated or extended for an incremental change/Jira ticket.

Do not use when:
- Defining visual hierarchy, tokens, or design-system usage (use `ui-ux`→`ui-design` handoff; `ui-design` owns visual).
- Implementing application code, APIs, or back-end architecture.

## Scope

This skill is responsible for:

- User goals
- User journeys
- User flows
- Information architecture
- Screen/page identification
- Navigation
- Interactions
- UI states
- Validation behavior
- Error handling
- Empty states
- Loading states
- Success states
- Permission-related states
- Responsive considerations
- Accessibility considerations
- UX edge cases

This skill is not responsible for:

- Visual styling
- Color selection
- Typography
- CSS implementation
- React implementation
- Backend architecture
- API implementation
- Production infrastructure
- Product decisions outside the provided requirements



## Inputs

Use the strongest available product context.

For new product features, preferred inputs are:

1. Accepted RFC
2. Accepted ADRs
3. Existing approved UX/design artifacts
4. Existing product requirements
5. Existing application behavior

Jira Stories are normally created after UX and UI design for new UI-driven
features.

When the UX skill is invoked for an existing Jira ticket or an incremental
change, the Jira issue may be used as an input.

### Existing approved UX/design

Before creating new UX:

- Check whether an approved UX or UI design already exists for the affected
user journey, screen, or feature.
- Reuse existing approved UX/design where it still satisfies the current
requirement.
- Extend existing UX/design when the current requirement modifies an
existing experience.
- Do not discard or redesign existing approved UX/design without a
requirement-driven reason.
- If the new requirement conflicts with existing approved UX/design,
identify the conflict and determine whether a new design decision is
required.

Prefer extending existing patterns over introducing new interaction models.

Do not redesign unrelated parts of the application.

## Workflow

1. Gather strongest inputs (RFC, ADRs, existing UX/UI artifacts, product requirements, current app behavior) — see ## Inputs.
2. Inspect existing approved UX/design for reuse — see ## Existing approved UX/design.
3. Clarify user goals — see ## User goal.
4. Define journeys, flows, information architecture, and screens/navigation.
5. Define interactions, validation, and all applicable UI states (including edge cases, empty/loading/error/success/permission).
6. Consider responsive and accessibility implications for the journey.
7. Classify scope (new journey / modification / new screen / modification / small UI change) — see ## Determine UX scope.
8. Produce `docs/ux/<feature-or-rfc>/overview.md` artifact and request human approval.

```
         ┌─ Existing approved UX satisfies requirement? ─ yes ─► Reuse / Extend
         │                                                        │
         └─ no ─► Create new UX                                  │
         ┌─ Requirement conflicts with existing UX? ─ yes ─► Identify conflict, request decision
         └─ no ─► Continue
```

## Determine UX scope

Not every UI change requires a complete UX exercise.

Classify the work as one of:

1. New user journey
2. Existing journey modification
3. New screen/page
4. Existing screen/page modification
5. Small UI change with no meaningful UX impact

For a small UI change with no meaningful UX impact, perform only the UX
analysis necessary to confirm that the existing experience remains valid.

### UX artifact

For a finalized or approved UX analysis, save the UX specification as a
project-level Markdown artifact.

Preferred location:

`docs/ux/<feature-or-rfc>/overview.md`

The UX artifact should remain separate from the UX skill instructions.

For example:

`docs/ux/0001-adverify/overview.md`

## User goal

Clearly identify:

- Primary user
- User goal
- User intent
- Expected outcome
- Entry point

Use plain language.

Example:

```text
Primary user:
Compliance analyst

Goal:
Review a submitted advertisement and understand whether it contains
potential CAP Code violations.

Entry point:
Advertisement review screen

Expected outcome:
The user can understand the findings and decide what to correct.
```

## Verification

After completing UX analysis, confirm with evidence:
- [ ] UX artifact at `docs/ux/<feature>/overview.md` exists and lists user goals, journeys/flows, screens/navigation, interactions, and applicable states (validation, error, empty, loading, success, permission)
- [ ] Existing approved UX/design was inspected; reuse/extension or conflict was recorded
- [ ] Responsive and accessibility considerations documented
- [ ] Edge cases identified
- [ ] Human approval obtained (Proposed vs Approved) — never hand unapproved UX to ui-design

## Handoff to ui-design

Approved UX spec becomes input to `ui-design` skill. Preserve user goals, journeys, and behavioral states; do not redefine visual styling in UX.

## Common Rationalizations
| Rationalization | Reality |
|---|---|
| No RFC exists, so invent requirements in UX | Use strongest available product context; stop and request clarification if requirement is missing |
| Existing UX is old, so discard it silently | Reuse/extend where it satisfies current requirement; identify conflict explicitly before redesigning |
| Small UI change needs no UX check | Perform minimum UX analysis to confirm existing experience remains valid — see Determine UX scope #5 |

## Red Flags
- New UX discards existing approved journey without requirement-driven reason
- UX spec defines colors/typography instead of behavior
- States beyond happy-path (error, empty, permission) not documented
- Responsive text/content behavior not considered
- Unapproved UX handed to ui-design as final

## Policies

Use:
- `policies/web-best-practices.md` for accessibility, responsive behavior, and UI states.
- `policies/verification.md` for UX verification and completion evidence.

## Self-Improvement

Follow the common self-improvement standard in:

`../self-improvement/references/standard.md`

