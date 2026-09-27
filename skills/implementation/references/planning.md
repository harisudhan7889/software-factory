# Implementation Planning

## Inputs

The implementation plan must be based on:

1. The Jira Story
2. The accepted RFC
3. Relevant ADRs
4. The existing codebase
5. The approved design-exploration selection and comparison (when the Story references them)
6. The approved Stitch design handoff and primary screenshot (when the Story references Stitch)

## Goal

Determine the minimum implementation required to complete the Jira Story.

The plan must distinguish between:

- Existing code that can be reused
- Code that must be modified
- New code that must be created
- Managed services that should be used
- Infrastructure configuration that is required
- Tests that must be added or updated

## Architecture

Follow accepted ADRs.

Do not replace a selected managed service with custom infrastructure
unless the Jira Story or an ADR requires it.

For generated web applications, use the factory-standard remote/managed Supabase architecture defined by factory ADR-0002 (`factory/docs/adr/0002-default-web-backend-architecture/overview.md`), unless an accepted project ADR explicitly defines an exception. Do not create custom infrastructure for capabilities assigned to Supabase or another managed service.

## Implementation areas

Evaluate whether the Story requires changes to:

- Frontend
- Backend/application code
- Database
- Authentication/authorization
- Managed services
- Background jobs
- Compliance engine
- External integrations
- Tests
- Documentation

Only include areas that are actually required.

## Plan format

Return:

# Implementation Plan

## Story

<Jira key and summary>

## Understanding

<Brief explanation of what the Story needs to accomplish.>

## Design input

<List the approved selection path and direction plus the comparison path and section when the Story references design-exploration input. Omit when not applicable.

When the Story references an approved Stitch design, also include the `stitch-handoff` result: the Stitch screen/reference, primary screenshot, supporting HTML when available, target viewport when available, and important visual notes. Treat the screenshot as the primary visual reference and HTML as supporting information only. Omit Stitch details when not applicable.>

## Existing code

<List relevant existing components, files, modules, or services that
can be reused or modified.>

## Changes required

### Frontend

<List only if required.>

### Backend/Application

<List only if required.>

### Database

<List only if required.>

### Managed services

<List only if required.>

### Background jobs

<List only if required.>

### Other

<List only if required.>

## Tests

<List tests required to verify the Story.>

## Files likely to change

<List existing files and new files, where known.>

## Architecture considerations

<Explain how the implementation follows the RFC and relevant ADRs.>

## Out of scope

<List things that should not be implemented as part of this Story.>

## Risks / open questions

<List unresolved issues only.>

## Implementation sequence

Provide an ordered sequence of implementation steps.

Do not write code.

## Quality check

Before finalizing the plan, verify:

- The plan satisfies the Jira Story.
- The plan follows the RFC.
- The plan follows relevant ADRs.
- Existing code was considered.
- Managed services are used where appropriate.
- No unnecessary infrastructure is proposed.
- No requirements were invented.
- Tests are included.
- Out-of-scope work is identified.
- When design-exploration input applies, the plan identifies how the approved selection translates into the UI.
- When Stitch design input applies, the plan identifies the approved Stitch screenshot as the primary visual reference and treats Stitch HTML as supporting information only.
- When the Story references an approved UX/UI design, the plan includes
  its visual implementation (layout, tokens, states) — a structure-only
  baseline with styling deferred is not a complete plan unless the visual
  work is split into a tracked follow-up ticket at plan time. Deferred
  styling without a ticket means "never", not "later".
