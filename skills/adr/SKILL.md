---
name: adr
description: Create and manage Architecture Decision Records for the project.
---

# ADR Skill

This skill manages Architecture Decision Records (ADRs) for the project.

ADRs record significant architectural decisions, the reasoning behind
them, alternatives considered, and the consequences of the decision.

## Available operations

- `/adr create` — create a new ADR
- `/adr review` — review an existing ADR

## General rules

- Read `references/standard.md` before creating or reviewing an ADR.
- Check existing ADRs before creating a new one.
- Never reuse an ADR number.
- Use the next sequential ADR number.
- Do not create an ADR for trivial implementation details.
- Do not invent architectural decisions.
- Preserve the project's existing ADR conventions.
- A newly created ADR must start as `Proposed`.
- Never mark an ADR as `Accepted` without explicit user approval.
- Do not modify an existing Accepted ADR to silently change its decision.
- If an existing ADR already covers the decision, prefer referencing it
  rather than creating a duplicate ADR.

## `/adr create`

When the user asks to create an ADR:

1. Read `references/standard.md`.
2. Inspect the existing `docs/adr/` directory.
3. Determine the next sequential ADR number.
4. Understand the architectural decision.
5. Identify:
   - Context
   - Decision
   - Alternatives considered
   - Consequences
   - Risks or follow-up decisions
6. Draft the ADR.
7. Present the complete ADR to the user.
8. Ask for explicit approval.
9. Only after approval:
   - Create the ADR directory/file.
   - Use the next sequential number.
   - Set status to `Proposed` unless the user explicitly requests another
     valid status.
10. Do not modify unrelated files.

## `/adr review`

When reviewing an ADR:

1. Read the ADR.
2. Check it against `references/standard.md`.
3. Check for:
   - Missing context
   - Unclear decision
   - Missing alternatives
   - Unexplained consequences
   - Contradictions with existing ADRs
   - Duplicate decisions
   - Decisions that should be captured elsewhere
4. Report findings without silently changing the ADR.

## Important

An ADR records a decision. It is not an implementation plan and is not
a Jira ticket.

A single ADR may apply to many Jira Stories.

## Self-Improvement

Follow the common self-improvement standard in:

`../self-improvement/references/standard.md`
