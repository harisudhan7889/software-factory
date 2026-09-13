# `refine` Subcommand

# Refine an Existing Jira Ticket

## Goal

Safely update an existing Jira issue from a user's natural-language refinement
request.

The workflow should preserve the existing ticket's intent while applying only
the requested and approved changes.

Do not recreate the issue.

Do not modify the ticket before explicit user confirmation.

## Invocation

The user invokes:

`/ticket refine <JIRA-KEY>`

The Jira issue key must identify an existing issue in the current project.

## Supported refinements

The workflow may refine:

- Summary
- Description
- Acceptance criteria
- Priority
- Labels
- Epic assignment
- UX/UI design references
- Other fields supported by the project's Jira configuration

Only update fields that are relevant to the user's request.

Do not change unrelated fields merely for consistency.

## Phase 1 — Read the existing issue

Before proposing changes:

1. Read the Jira issue.
2. Confirm the issue belongs to `$JIRA_PROJECT_KEY`.
3. Read its current:
   - Summary
   - Description
   - Issue type
   - Priority
   - Labels
   - Epic/parent
   - Status
   - Relevant links
4. Read related Jira issues when useful.
5. Inspect relevant project context when the refinement depends on it.

Do not modify the issue during inspection.

## Phase 2 — Understand the refinement request

Determine exactly what the user wants changed.

Examples:

- "Add the approved UI design link."
- "Move this ticket to Epic ADVERIFY-53."
- "Split this scope."
- "Clarify the acceptance criteria."
- "Add the frontend label."
- "Remove the obsolete label."

Do not infer unrelated changes.

If the request is ambiguous and different interpretations would materially
change the ticket:

- Explain the ambiguity.
- Ask the user to clarify.
- Do not guess.

## Phase 3 — Preserve existing intent

When refining a ticket:

- Preserve useful existing content unless the user asks to replace it.
- Do not remove acceptance criteria silently.
- Do not weaken or broaden scope silently.
- Do not introduce unsupported requirements.
- Do not rewrite product decisions as implementation requirements.
- Preserve existing RFC/ADR references unless they are obsolete and the user
  requests their removal.

When changing a section of the description, prefer a targeted update over
rewriting the entire description.

## Phase 4 — UI/UX and design refinement

When the refinement concerns UI work:

1. Determine whether the issue actually requires UI/UX work.
2. Check for existing approved UX and UI design artifacts.
3. Identify the applicable design artifact.
4. Identify the canonical external design reference when available.
5. Use only approved design references.

For a UI issue, the refined description may include:

```text
UI/UX: Existing approved design

UX artifact:
<approved UX artifact path>

UI design artifact:
<approved UI design artifact path>

Design:
<canonical external design URL>

Design exploration:
Selection: design-explorations/<short-name>.selection.md (Status: Approved)
Comparison: design-explorations/<short-name>.html (Direction X — <Name>)
Selected: Direction X — <Name>
```

Omit the `Design exploration:` lines when no approved selection applies. When they apply, verify both files exist and the selection record has `Status: Approved` before adding them. Use only approved selections.

For a non-UI issue:

```text
UI/UX: None
```

Do not add a UI design reference to a backend, infrastructure, database, CI,
testing, or other non-UI issue.

If the issue introduces a new UI that has no approved design:

- Identify that design is missing.
- Do not invent a design reference.
- Ask whether the UI design workflow should be completed first.

## Phase 5 — Technical area labels

When refining a ticket:

- Add `agent-refined` to every ticket modified by `/ticket refine`.
- Preserve all existing labels unless the user explicitly asks to remove one.
- Do not replace the existing label set with the new labels.
- Add `frontend` when the refined ticket contains frontend/UI work.
- Add `backend` when the refined ticket contains backend/server/database work.
- Add both `frontend` and `backend` when the ticket genuinely spans both.
- Do not add duplicate labels.

Do not add labels merely because they might be useful.

## Phase 6 — Epic refinement

When the user asks to correct or determine the Epic:

1. Determine the most appropriate Epic from the available project context.
2. Consider:
   - Existing Jira Epics
   - Related RFCs and ADRs
   - Related Jira Stories or Bugs
   - Parent/originating issues
   - The current ticket's scope
   - Existing Epic relationships
3. Verify the selected Epic belongs to `$JIRA_PROJECT_KEY`.
4. Prefer the existing appropriate Epic over creating a duplicate.
5. If confidence is insufficient, ask the user instead of guessing.

When proposing a new Epic assignment, show:

```text
Current Epic:
<current Epic or None>

Proposed Epic:
<key — summary>

Reason:
<evidence>
```

Do not change the Epic before explicit approval.

## Phase 7 — RFC / ADR consistency

When a refinement changes requirements, scope, or architecture:

Determine whether the change belongs to:

- The Jira ticket only
- The RFC
- An ADR

Do not silently make a Jira ticket contradict an accepted RFC or ADR.

If the requested refinement conflicts with an accepted architectural decision:

- Identify the conflict.
- Explain why the current ticket cannot safely be changed as requested.
- Ask whether the ADR should be amended.
- Do not silently override the ADR.

If the refinement changes a product requirement represented by the RFC:

- Identify the affected RFC requirement.
- Do not silently invent the updated requirement.
- Ask whether the RFC should be updated when appropriate.

## Phase 8 — Prepare the proposed ticket

Present the complete proposed result.

Show:

```text
Jira:
<KEY>

Type:
<issue type>

Epic:
<current or proposed Epic>

Summary:
<summary>

Description:
<proposed description>

Priority:
<priority>

Labels:
<labels>

Status:
<current status>

Changes:
<exact fields that will change>
```

For description changes, clearly show the resulting description rather than
only a vague summary.

## Human confirmation

Before modifying Jira:

- Present the complete proposed changes.
- Ask for explicit confirmation.

Accept confirmation such as:

- `yes`
- `confirm`
- `go ahead`
- `apply`
- `update`

Do not call the Jira update operation before explicit confirmation.

If the user changes the requested refinement after the preview:

- Rebuild the proposal.
- Show the updated proposal.
- Ask for confirmation again.

## Phase 9 — Apply approved refinement

After explicit confirmation:

1. Update only the approved fields via the project's approved Jira update path (if no `scripts/jira-update.sh` exists, use the approved API call; do not use `scripts/jira-create.sh` for updates — it creates, not updates).
2. Preserve unrelated ticket data.
3. Verify the Jira update succeeded.
4. Re-read the issue when practical.
5. Confirm the resulting values match the approved proposal.

Do not recreate the Jira issue.

Do not create a duplicate issue.

## Phase 10 — Jira comments and traceability

When useful, add a concise Jira comment describing the refinement via `scripts/jira-comment.sh <KEY> <COMMENT>`.

The comment should include:

- What was refined
- Why it was refined
- Relevant design/RFC references when applicable

Do not include secrets or credentials.

Do not add a comment merely to create noise.

## Phase 11 — Idempotency

The refinement workflow must be safe to run repeatedly.

Before each mutating operation:

- Read the current Jira state.
- Determine whether the requested change is already present.
- Skip unnecessary updates.
- Do not duplicate design references.
- Do not duplicate labels.
- Do not create duplicate comments when avoidable.
- Already has `agent-refined` → do not add it again.
- Preserve all existing labels while adding refinement labels.

Examples:

```text
Already in correct Epic → do not update Epic.

Already has frontend label → do not add it again.

Already has approved design link → do not add a duplicate.

Already matches requested summary → report no change required.

If Existing ticket has 

Labels:
agent-created, frontend, Web

After /ticket refine, it should be
Labels:
agent-created, agent-refined, frontend, Web
```

## Phase 12 — Scope boundaries

The workflow must not silently:

- Expand ticket scope.
- Rewrite accepted requirements.
- Change architecture.
- Change legal/compliance behavior.
- Create new Jira work.
- Split a ticket into multiple issues without explicit approval.
- Delete useful existing ticket information.
- Move the ticket to `Done`.
- Change workflow status unless the user explicitly requests it.

If refinement reveals actionable work outside the ticket:

1. Explain the additional work.
2. Ask whether a separate Jira item should be created.
3. Do not create it before explicit approval.


## Phase 13 — Capability detection

When a refinement materially changes the ticket's payment, billing, or subscription behavior, re-evaluate applicable specialized capabilities before the final proposal.

For Stripe recurring subscriptions, use `stripe-subscriptions` as the capability detector. For Stripe one-time payments, use `stripe-one-time-payments` as the capability detector. Route each capability separately.

The detector may identify candidate capability areas, but it must not:

- create Jira tickets
- modify Jira dependency links
- expand the ticket scope silently
- own the persistent dependency graph
- provide Stripe implementation instructions

If the refinement changes dependency-relevant work, pass the capability findings to `ticket-dependency-planning`, which owns dependency analysis and graph updates.

Do not duplicate Stripe implementation guidance here. `stripe-best-practices` owns implementation guidance.

## Phase 14 — Self-improvement

Follow the common self-improvement standard in `../self-improvement/references/standard.md`.

Review the refinement run for:

- A failed step
- A required workaround
- A meaningful user correction
- A repeated ticket-refinement problem
- Incorrect assumptions in the ticket workflow
- A missing safety rule
- A recurring manual step that should become factory behavior

Only propose a factory change when real evidence shows that future ticket
refinement runs should behave differently.

Do not propose cosmetic, hypothetical, or one-off changes.

If a genuine factory improvement is identified:

- State the finding.
- Identify the affected factory artifact.
- Propose the complete update.
- Ask for explicit approval.
- Apply only the approved change.
- Show and validate the resulting diff.

## Final report

Report:

```text
Jira Refinement

Issue:
<JIRA-KEY>

Changes applied:
- <field>: <result>
- <field>: <result>

Unchanged:
- <relevant fields>

Verification:
<results>

Jira:
<updated / no change required / failed>

Self-improvement:
<none identified / proposal / applied>

Result:
<success / partial / failed>
```

If the update fails:

- Report the Jira failure.
- Do not claim the refinement succeeded.
- Preserve the existing issue.

## Decision boundaries

When uncertain:

- Stop.
- Explain what is unclear.
- Ask the user.

Never silently:

- Choose an uncertain Epic.
- Change accepted architecture.
- Add unsupported requirements.
- Remove existing acceptance criteria.
- Add unrelated design references.
- Create follow-up Jira work.
- Modify the Jira issue before confirmation.
