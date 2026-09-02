---
name: adr
description: Guides agents through creating and managing Architecture Decision Records (ADRs) for the project. Use when recording a significant architectural decision, creating a new ADR, or reviewing an existing ADR against the ADR standard. Do not use for implementation plans or Jira tickets.
---

# ADR Skill

This skill manages Architecture Decision Records (ADRs) for the project.

ADRs record significant architectural decisions, the reasoning behind
them, alternatives considered, and the consequences of the decision.

## Available operations

- `/adr create` — create a new ADR
- `/adr review` — review an existing ADR

## When to Use

Use when:
- Recording a significant architectural decision as an ADR
- Creating a new ADR (`/adr create`)
- Reviewing an existing ADR for completeness and consistency (`/adr review`)

Do not use when:
- Drafting implementation plans (use Jira/implementation skills)
- Writing product RFCs (use `rfc` skill)
- Capturing trivial implementation details

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

## Verification

After ADR create/review, confirm with evidence:
- [ ] `references/standard.md` was read and ADR at `docs/adr/NNNN-short-title.md` follows naming `NNN` sequential, zero-padded, never reused
- [ ] ADR contains Status/Date/Authors and Context/Decision/Alternatives/Consequences/Risks
- [ ] New ADR starts as `Proposed` and was not marked `Accepted` without explicit user approval
- [ ] Existing ADRs were inspected for duplicates/contradictions before creating

## Common Rationalizations
| Rationalization | Reality |
|---|---|
| Skip reading standard.md, the format is obvious | Check references/standard.md first; naming, statuses, and metadata are strict per ADR |
| Reuse an ADR number, the old one was rejected | Never reuse numbers, including for rejected ADRs per references/standard.md:42 |
| Mark ADR as Accepted immediately, decision is clear | New ADRs must start as Proposed; Accepted requires explicit user approval per adr:27 |

## Red Flags
- ADR created for trivial implementation detail instead of significant decision
- ADR number reused or out of sequence
- ADR marked Accepted without explicit approval
- Existing ADR silently modified to change its decision
- Missing alternatives or consequences

## Policies

Use:
- `policies/guardrails.md` for scope, authority, approval, and evidence reporting. ADR must not expand scope without approval and must not be marked Accepted without explicit approval.
- `policies/security.md` for secrets and credentials. Never store secrets in ADRs.
- `policies/verification.md` for ADR verification and completion evidence.

## Self-Improvement

Follow the common self-improvement standard in:

`../self-improvement/references/standard.md`
