---
name: ui-ux
description: Analyze user experience for web UI features and produce a structured UX specification before visual design or implementation.
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

