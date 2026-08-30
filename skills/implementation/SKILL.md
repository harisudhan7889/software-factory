---
name: implementation
description: Guides agents through planning and implementing accepted Jira stories using the RFC, ADRs, and existing codebase. Use when an accepted Jira Story is ready for implementation planning or implementation. Do not use for RFC/ADR creation or product discovery.
---

# Implementation Skill

This skill plans and implements accepted Jira Stories using the
project RFCs, ADRs, and existing codebase.

## Available operations

- `/implementation plan <JIRA-KEY>` — create an implementation plan
- `/implementation work <JIRA-KEY>` — plan, implement, test, review, and commit a Jira Story

## When to Use

Use when:
- An accepted Jira Story (with RFC/ADRs) is ready for implementation planning (`/implementation plan`)
- An accepted Jira Story is ready for implementation (`/implementation work`)

Do not use when:
- Creating RFCs/ADRs (use `rfc` / `adr` skills)
- Product discovery or UX/UI design without a Jira Story

## General rules

- Read the Jira Story before planning or implementing.
- Read the relevant accepted RFC.
- Read relevant ADRs.
- Inspect the existing codebase before proposing changes.
- Prefer existing code and infrastructure over creating new components.
- Follow accepted architecture decisions.
- Use managed services where the architecture specifies them.
- Do not invent requirements.
- Do not implement unrelated Jira Stories.
- Do not modify the codebase during the planning phase.
- Do not create an ADR for routine implementation details.
- If a genuinely new architectural decision is required, stop and use
  the ADR workflow before proceeding.

## Command routing

When the user invokes:

`/implementation plan <JIRA-KEY>`

read:

`references/planning.md`

Follow that reference to produce the implementation plan.

When the user invokes:

`/implementation work <JIRA-KEY>`

read:

`references/workflow.md`

Follow that reference for the complete implementation workflow.

## Implementation workflow

The `/implementation work` operation must:

1. Read the Jira Story.
2. Read the relevant RFC and ADRs.
3. Inspect the existing codebase.
4. Determine whether existing architecture is sufficient.
5. Create an implementation plan using `references/planning.md`.
6. Present the plan to the user.
7. Wait for explicit approval.
8. Implement only after approval.
9. Run relevant tests, linting, and type checking.
10. Review the implementation against the Story, RFC, and ADRs.
11. Commit the completed implementation locally.
12. Do not push to a remote unless explicitly requested.

## Verification

Before commit, confirm per references/workflow.md Phase 11:
- [ ] Acceptance criteria satisfied, relevant tests/typecheck/lint pass, no unrelated changes, no secrets committed, ADR/RFC alignment verified (and for UI Stories, UX/UI design compliance per Phase 9)

## Common Rationalizations
| Rationalization | Reality |
|---|---|
| Skip inspecting existing codebase, just implement | Inspect repository first per General rules:21 and references/workflow.md Phase 3 |
| Modify code before plan approval to save time | Do not modify codebase during planning / Wait for explicit approval per :27,67 |
| Create ADR for every Story change | Do not create ADR for routine details; only when genuinely new architecture decision per :28 |

## Red Flags
- Implementation modifies code before `references/planning.md` approval
- New ADR created for routine implementation detail
- Unrelated Jira Story implemented or Jira scope silently expanded
- Force-push, history rewrite, or push without explicit request

## Self-Improvement

Follow the common self-improvement standard in:

`../self-improvement/references/standard.md`
