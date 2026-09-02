---
name: ticket
description: Guides agents through creating and managing Jira tickets from natural-language requirements. Use when creating a single Jira ticket, converting an RFC into Stories/Epics, or refining an existing ticket via /ticket create|rfctostories|refine. Do not use for implementation or RFC/ADR creation.
---

# Ticket Skill

This skill manages Jira tickets using the Jira scripts in this skill directory.

## Available operations

- `/ticket create` — create a single Jira ticket
- `/ticket rfctostories` — analyse an RFC and convert actionable work into Jira Stories or an Epic with Stories
- `/ticket refine` — refine an existing Jira ticket

## When to Use

Use when:
- Creating a single Jira ticket from natural language (`/ticket create`)
- Analysing an RFC and converting work into Stories/Epics (`/ticket rfctostories`)
- Refining an existing ticket (`/ticket refine`)

Do not use when:
- Implementing code (use `implementation` skill)
- Creating RFCs/ADRs (use `rfc` / `adr` skills)

## Command routing

When the user invokes:

- `/ticket create` → read `references/create.md`
- `/ticket rfctostories` → read `references/rfctostories.md`
- `/ticket refine` → read `references/refine.md`

Follow the relevant reference for the command.

## General rules

- Do not create or modify Jira issues without user confirmation.
- Prefer clear, actionable tickets over vague tasks.
- Do not invent requirements that are not supported by the user's request.
- Keep tickets appropriately scoped.
- Use the current project's `.env` for project-specific configuration.
- Shared Jira credentials must be available as environment variables:
  - `JIRA_BASE_URL`
  - `JIRA_EMAIL`
  - `JIRA_API_TOKEN`

## Jira scripts

Use the scripts in:

`scripts/`

Do not duplicate Jira API implementation logic in the skill instructions.

## Epic assignment

When creating any Jira issue that can belong to an Epic:

1. Determine the most appropriate Epic from the available project context.
2. Consider:
   - Related RFCs and ADRs
   - Existing Jira Epics
   - Related Stories or Bugs
   - The originating issue when this is follow-up work
   - The user's current request and conversation context
3. Validate that the selected Epic belongs to the current Jira project.
4. Include the proposed Epic in the ticket preview shown to the user.
5. Assign the issue to the selected Epic only after user confirmation.
6. If a suitable Epic cannot be determined with reasonable confidence,
   ask the user rather than guessing.
7. Do not require the user to provide an Epic key when the factory can
   determine the correct Epic from available context.

## Verification

After ticket operations, confirm with evidence:
- [ ] Correct reference followed (`create` / `rfctostories` / `refine`) and Epic validated to belong to current project
- [ ] Ticket preview shown including Epic and user confirmation obtained before calling `scripts/jira-create.sh`
- [ ] No requirements invented; scope kept per reference templates
- [ ] Jira key/URL returned after creation

## Common Rationalizations
| Rationalization | Reality |
|---|---|
| No Epic found, pick the first one | Ask user rather than guessing per :60 — never invent Epic |
| Skip preview, just create | Do not create without user confirmation per :28 |

## Red Flags
- Jira issue created without Epic preview when Epic applicable
- Ticket created before explicit "create"/"yes" confirmation
- Requirements invented not in user request or RFC

## Policies

Use:
- `policies/guardrails.md` for scope and approval. Do not create or modify Jira issues without user confirmation.
- `policies/verification.md` for Jira verification and completion evidence.
- `policies/security.md` for Jira credentials and data protection.
- `policies/observability.md` for Jira run traceability and audit records.

## Self-Improvement

Follow the common self-improvement standard in:

`../self-improvement/references/standard.md`
