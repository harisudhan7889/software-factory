# `create` Subcommand

# Create a new Jira Ticket in the project.

## Goal

Turn a user's natural-language requirement into one well-structured Jira ticket.

## Gather Ticket Details

Infer from user input. Only ask for values that cannot be determined:

|Field | Rule |
|------|------|
| Project key | Always `$JIRA_PROJECT_KEY`.Never ask.|
| Issue type | Infer: `Bug` ("bug", "broken", "fix", "crash", "regression", "defect", "issue with"), `Story`("story", "user story", "as a user", "feature", "implement", "add support for"), `Sub-task` ("subtask", "sub-task", "child of"), `Task` (default). Ask only if ambiguous between two+ types. Epic/Spike are created via rfctostories/refine paths, not /ticket create inference. |
| Summary | Extract from input. If unclear, ask. |
| Description | Format using template from `references/templates.md` matching the issue type. Populate fields from input. Ask if required fields are missing. All text MUST use "should" - never "will", "shall", or past tense. The describes intent, not a changelog. |
| Priority | `Highest`, `High`, `Medium`, `Low`, `Lowest`. Default: `Medium`. Infer "critical"/"blocker" as `Highest`; "urgent"/"important" as `High`; "minor"/"low priority" as `Low`; "trivial" as `Lowest`, Ask only if unclear. |
| Labels | Infer platform: `iOS` (iOS, Swift, Xcode, Apple, iPhone, iPad), `Android` (Android, Kotlin, Gradle), `Web`. If all three apply, include all three. If none mentioned, omit. Never ask. And add `agent-created` also. |
| RFC reference | If the ticket originates from an RFC `breakdown` invocation (or the user supplies an RF number/path), append an **RFC reference** to the description: a link `docs/rfc/short-title/overview.md`. Omit when not RFC-driven | 
| Design exploration | If the user supplies a `design-explorations/<short-name>.selection.md` path, verify the file exists with `Status: Approved`, then append a **Design input** block to the description per `references/templates.md` with the selection path, comparison path, and selected direction. Omit when no approved selection applies. Never accept a conversational selection alone. Show the design references in the confirmation preview. |
| Epic | Determine the most appropriate Epic for any issue that can belong to an Epic. Search the current Jira project and use the current request, RFC/ADR context, related Jira issues, and originating issue when applicable. Verify the Epic belongs to `$JIRA_PROJECT_KEY`. Never invent an Epic. If no suitable Epic can be determined with reasonable confidence, ask the user. |
| Links | Optional comma-separated relationships to existing issues: `Relates:KEY` (follow-up / associated work), `Blocks:KEY` (new issue blocks KEY), `BlockedBy:KEY` (new issue is blocked by KEY). Propose from the originating issue and related Jira issues when applicable; show in the confirmation preview; create only after confirmation. Omit entirely when nothing is related — never invent links. |

## Bug evidence and reproduction rules

When creating a Bug ticket:

- Distinguish observed evidence from reproduction instructions.
- If the failure has already been captured in logs, CI runs, test output,
  or other available evidence, preserve that evidence in the ticket.
- Do not invent a reproduction procedure that was not actually established.
- Do not require rerunning an already-captured failure merely to populate
  reproduction steps.
- When a reproduction procedure is not known, state that clearly and include
  the available evidence instead.
- Separate:
  - Steps to reproduce: a verified procedure for reproducing the problem.
  - Evidence: the actual observed failure, including relevant run IDs,
    logs, test names, or error messages.


## Capability detection

When the ticket requirement suggests a specialized capability, perform capability detection before the final confirmation preview.

For Stripe recurring subscriptions, use `stripe-subscriptions` as the capability detector. For Stripe one-time payments, use `stripe-one-time-payments` as the capability detector; its candidate areas are defined by that skill — use detector output. Route each capability separately.

The capability detector (`stripe-subscriptions`) defines the candidate areas (plan/price setup, checkout flow, lifecycle, app state) — do not copy the list here; use detector output.

Treat these as candidate capability areas, not automatic Jira scope. Do not create extra tickets or expand the requested scope from keyword matches alone.

Pass candidate capability findings to `ticket-dependency-planning` when dependency analysis is part of the workflow. That skill owns actual dependency relationships and the persistent dependency graph.

Do not duplicate Stripe implementation guidance here. `stripe-best-practices` owns implementation guidance.

## Confirm

Present to user:

```text
Type: Task
Epic: <EPIC-KEY> — <epic summary>
Summary: <ticket summary>
Description: (none)
Priority: Medium
Labels: Web, agent-created
Links: Relates:<ISSUE-KEY> (or Blocks:<ISSUE-KEY> / BlockedBy:<ISSUE-KEY>, or (none))
```

Wait for explicit confirmation. The user must explicitly say "create", "confirmed", "yes", "go ahead", or similar affirmation before proceeding. If user request changes, loop back to step 2. **Do NOT call the creation script until the user has explicitly approved.**


## Workflow

1. Understand the request.
2. Draft the ticket.
3. Resolve the appropriate Epic.
   - Search the current Jira project for relevant Epics.
   - Use the current request, RFCs, ADRs, related Jira issues, and the
     originating issue when applicable.
   - Verify the selected Epic belongs to `$JIRA_PROJECT_KEY`.
   - If confidence is insufficient, ask the user instead of guessing.
4. Show the complete proposed ticket, including the selected Epic.
5. Ask the user to confirm.
6. After confirmation, create the ticket using:

`scripts/jira-create.sh`

Pass relationships via the `links` input (e.g. `"links": "Relates:RARRADAR-6"`).
Links are created after the issue; a failed link never undoes the creation
(the script reports which links failed — relay that to the user).

7. Return the Jira key and URL.

## Important

Never create the ticket before confirmation.
