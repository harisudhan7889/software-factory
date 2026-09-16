# Implementation Workflow

## Purpose

Implement an accepted Jira Story using:

- the Jira Story
- the relevant accepted RFC
- relevant ADRs
- the current codebase
- the implementation planning rules

The workflow should produce the minimum implementation required to
satisfy the Story.

Do not invent requirements or implement unrelated work.

## Input

The user provides a Jira Story key.

Example:

/implementation work ADVERIFY-69

## Phase 1 — Understand the Story

Read the Jira Story and identify:

- Summary
- Description
- Acceptance criteria
- Priority
- Parent Epic
- Relevant Jira comments, when useful

Treat the Jira Story as the immediate implementation scope.

## Phase 2 — Read project context

Identify and read:

- The relevant accepted RFC
- Relevant ADRs
- Existing implementation references
- Project-level development instructions

The RFC describes the intended product and system design.

ADRs describe architectural decisions that constrain implementation.

If an existing ADR governs the Story, follow that ADR.

Do not create a new ADR simply because the Story has implementation
work.

### UI/UX design references

When the Jira Story contains UX or UI design references, the implementation
workflow must treat the approved UX and UI design artifacts as implementation
inputs.

Before creating the implementation plan:

1. Read the referenced UX specification.
2. Read the referenced UI design specification.
3. Inspect the referenced external design artifact when available,
   including the configured design-tool integration.
4. Identify the screens, states, components, responsive behavior,
   interactions, accessibility requirements, and design-system usage relevant
   to the current Story.
5. Use these artifacts when creating the implementation plan.

### Design-exploration inputs

When the Jira Story references approved design-exploration artifacts:

1. Read the referenced `.selection.md` and verify `Status: Approved` and all required fields are present.
2. Inspect the selected direction section of the referenced comparison `.html`.
3. Map the `Preserve:` decisions and aspirational/gap handling into the implementation plan.
4. A conversational selection without a `.selection.md` is not valid input.

Authority: Use .selection.md as the approved visual-direction record. Use the source that owns a requirement for behavioral or architectural decisions. The visual exploration must not override an approved product, UX, architecture, or security requirement.

A design link must not be treated as informational metadata only.

If a referenced UX/UI design artifact cannot be located or accessed:

- Stop before implementation.
- Report exactly which artifact is missing or inaccessible.
- Ask the user whether to proceed without the design.
- Do not silently create an inferred or basic replacement UI.

This applies equally to a missing design-exploration `.selection.md` or comparison `.html`: report the exact missing path.

## Phase 3 — Inspect the codebase

Before proposing implementation changes:

- Inspect the repository structure.
- Find existing code related to the Story.
- Identify reusable components.
- Identify existing conventions.
- Determine whether the repository is greenfield or already contains
  relevant implementation.

Do not assume that a component needs to be created if an existing
component can be reused.

## Phase 4 — Check architectural decisions

Determine whether the existing RFC and ADRs are sufficient to make the
implementation decision.

### If existing architecture is sufficient

Continue to implementation planning.

### If a genuinely new architectural decision is required

Do not make a significant architectural decision silently.

Explain:

- what decision is required
- why the existing RFC/ADRs are insufficient
- the options that need to be considered

Use the ADR workflow to draft a new ADR.

The ADR must be explicitly approved before implementation continues.

Do not create an ADR for routine implementation details.

## Phase 5 — Create implementation plan

Read:

`references/planning.md`

Create an implementation plan based on the Jira Story, RFC, ADRs, and
existing codebase.

The plan should identify only the work required for the Story.

## Phase 6 — Present the plan

Present the implementation plan to the user.

Do not modify the codebase yet.

Ask:

> Implementation plan ready. Proceed with implementation?

Wait for explicit approval.


## Phase 6.1 — Determine Implementation Branch

After the implementation plan is explicitly approved and before
implementation begins, determine the correct Git branch.

### Standard implementation

If the current branch is the project's default branch (`main` or `master`):

- Create a dedicated implementation branch.
- The branch name should be deterministic and derived from the Jira key
  and implementation type when possible.
- Do not rewrite or remove existing commits.

Examples:

`feat/ADVERIFY-71-rule-catalog`

`fix/ADVERIFY-84-supabase-jwt-secret`

`chore/ADVERIFY-85-jira-post-merge-sync`

If the current branch is already a dedicated branch for the same Jira
Story:

- Reuse the branch.
- Do not create another branch.

### Follow-up work with an open Pull Request

If the Jira Story is follow-up work for another Jira issue that has an
open Pull Request:

- Do not automatically reuse the parent issue's branch.
- Create a dedicated branch for the follow-up issue.
- If the follow-up depends on the parent's unmerged changes, base the new
  branch on the parent Pull Request branch.
- Do not duplicate, revert, or rewrite the parent issue's changes.
- Report the parent issue, base branch, new branch, and target branch.

### Branch ancestry safety

When creating an implementation branch for a Jira Story:

- The default base branch must be the project's default branch
  (`main` or `master`).
- A feature branch must not be used as the base for another Story merely
  because the Stories are related.
- Before creating the branch, inspect the proposed base commit and branch
  ancestry.

If the new Story depends on unmerged work from another Story:

1. Identify the dependency explicitly.
2. Determine whether the dependent Story can safely be based on the parent
   branch.
3. Report that the resulting Pull Request will include the parent Story's
   commits until the parent is merged.
4. Prefer waiting for the parent Story to merge and then creating the new
   branch from the updated default branch.
5. If work must proceed before the parent merges, clearly mark the dependent
   branch/PR as dependent and ensure the parent changes are not accidentally
   treated as part of the dependent Story's own scope.
6. Before creating the Pull Request, verify the source branch's commits
   relative to the target branch and report any commits belonging to another
   Jira Story.

The workflow must not silently create a new Story branch from another
feature branch.

Before implementation begins, report:

- Base branch
- Base commit
- Implementation branch
- Parent/dependency branch, if any
- Whether the implementation branch contains commits from another Jira Story

### Existing unrelated branch

If the current branch belongs to another Jira Story or unrelated work:

- Do not implement the new Story on that branch.
- Create or switch to the correct branch.
- Preserve the unrelated branch and its commits.

### Safety

Never:

- Force-push.
- Reset or rewrite existing history.
- Delete another Story's branch.
- Silently move unrelated commits between branches.

If creating or changing branches would require a destructive operation,
stop and ask the user.

Before implementation begins, report:

- Current branch
- Base branch
- New/reused implementation branch
- Jira Story
- Whether the branch contains another Story's work

### Branch decision must be resolved before implementation

The implementation workflow must explicitly determine and report the
implementation branch before Jira is moved to `In Progress`.

It must inspect:

- The current Git branch.
- The Jira Story's Epic and related issues.
- Any originating/follow-up Jira relationship.
- Open Pull Requests for related Jira issues.
- Whether the current branch is already associated with another Jira Story.

If the Story is follow-up work for an issue with an open Pull Request, the
workflow must create or select the dedicated follow-up branch before entering
`In Progress`.

Do not begin implementation while the branch decision remains unresolved.

The implementation plan confirmation and branch decision are separate
steps. Approval of the implementation plan does not implicitly approve
using the current branch.

After the branch is determined, report:

- Base branch
- Implementation branch
- Parent issue/PR, when applicable
- Reason for the selected branch

Only then may the workflow proceed to Jira → `In Progress`.


## Phase 6.2 — Start Jira Work

After the user explicitly approves the implementation plan:

1. Transition the Jira Story to `In Progress`.
2. Run:

`skills/ticket/scripts/jira-transition.sh <JIRA-KEY> "In Progress"`

3. Verify that the transition succeeds.
4. Only after the Jira transition succeeds, begin implementation.

If the transition fails:

- Do not modify the codebase.
- Report the Jira transition failure to the user.
- Stop the workflow.

### UI design precondition

For UI Stories, before modifying UI code, verify that:

- The approved UX specification has been read.
- The approved UI design specification has been read.
- Any referenced external design artifact has been inspected when available.
- When the Story declares design-exploration input, the `.selection.md` and comparison `.html` have been inspected and the implementation plan maps them.
- The implementation plan identifies how the approved design will be
  translated into the UI.

If these requirements have not been satisfied:

- Do not modify UI code.
- Stop and report the missing design input.

## Phase 7 — Implement

Before modifying the codebase, verify that the current Git branch matches
the implementation branch selected in Phase 6.1.

If it does not match:

- Stop.
- Do not modify or commit code.
- Report the mismatch.
- Return to Phase 6.1 and resolve the branch before continuing.

Only after explicit approval:

- Implement the approved plan.
- Follow the RFC.
- Follow relevant ADRs.
- Reuse existing code where appropriate.
- Use managed services where the architecture specifies them.
- Add only the code required by the Story.
- Do not implement future Stories.
- Do not expand scope without approval.

## Phase 8 — Test

Run the tests relevant to the implementation.

At minimum, when applicable:

- unit tests
- integration tests
- application tests
- type checking
- linting

Add or update tests required by the Story.

Do not claim tests passed unless they were actually run.

## Phase 9 — Review

Review the implementation against:

1. Jira acceptance criteria
2. Implementation plan
3. Relevant RFC requirements
4. Relevant ADR decisions

Check for:

- missing acceptance criteria
- unnecessary changes
- architecture violations
- test gaps
- accidental scope expansion
- secrets or sensitive data committed to the repository

Fix issues that are within the Story scope.

If an issue requires a new architectural decision or exceeds Story
scope, stop and report it.

### UI design compliance

For UI Stories, verify the implementation against:

1. Approved UX specification
2. Approved UI design specification
3. Referenced external design artifact
4. Approved design-exploration selection and comparison (when the Story references them)

Verify, when applicable:

- Screen structure
- Layout
- Visual hierarchy
- Components
- States
- Interactions
- Responsive behavior
- Accessibility
- Design-system usage
- Selected-direction `Preserve:` decisions and aspirational/gap handling (when design-exploration input applies)
- No unrelated redesign

Method for v1 design-exploration verification: manual browser side-by-side comparison of the running app against the selected direction section of the comparison artifact. Do not add screenshot-diff infrastructure for v1.

A UI Story must not be considered fully implemented when it only satisfies
the Jira acceptance criteria but materially deviates from the approved
UX/UI design.

If material visual or behavioral deviation is found:

- Fix it when it is within the approved Story scope.
- Otherwise stop and report the deviation rather than silently redesigning.

## Phase 10 — Scope and Decision Boundaries

Before final verification, explicitly inspect the implementation review
for unresolved issues, known limitations, or work identified as
out-of-scope.

For every identified issue, classify it as exactly one of:

1. Current Story work
2. Informational observation
3. Unresolved decision
4. Actionable follow-up work

### Current Story work

If the issue is within the current Jira Story and can be resolved using
the existing RFC, ADRs, and acceptance criteria:

- Fix it as part of the current implementation.
- Re-run the relevant tests.
- Include the change in the implementation review.

### Informational observation

If the issue does not require additional work:

- Do not create a Jira item.
- Record it under `Remaining issues` in the final report.

### Unresolved decision

If the issue requires a product, legal, compliance, security, or
architectural decision:

- Do not invent a decision.
- Do not silently implement a solution.
- Record the unresolved decision.
- Determine whether a Jira follow-up is appropriate.

### Actionable follow-up work

If the issue represents real additional implementation, product,
compliance, or other project work outside the current Story:

1. Describe the proposed follow-up work.
2. Explain why it is outside the current Story.
3. Ask the user whether a Jira item should be created.
4. STOP and wait for the user's answer before creating the Jira item.
5. If the user approves, create the Jira Story or Task.
6. Link the new Jira item to the current Story when appropriate.
7. If the user declines, record the item under `Remaining issues`.
8. Do not expand the current Story's scope without explicit approval.

The implementation workflow MUST NOT silently create follow-up Jira items.

The implementation workflow MUST NOT silently discard actionable
follow-up work.

### Example

If implementation discovers:

- "Exception/safe-phrasing resolution is required but is outside the
  current Story."
- "Final compliance wording requires compliance-reviewer curation."

The workflow must report:

> I found two out-of-scope follow-up items:
>
> 1. Exception/safe-phrasing resolution
> 2. Compliance wording curation
>
> Would you like me to create Jira follow-up items for these?

Wait for the user's response.

Do not create the Jira items before explicit confirmation.

Do not silently mark these items as resolved.

### Important

Completion of the current Story and creation of follow-up work are
separate actions.

The current Story may be considered technically complete when all of its
acceptance criteria are satisfied, even when follow-up work remains.

Follow-up work must be tracked separately rather than expanding the
current Story.

## Phase 11 — Final verification

Before completing the workflow, verify:

- All acceptance criteria are satisfied.
- Relevant tests pass.
- Type checking passes.
- Linting passes.
- No unrelated functionality was changed.
- No secrets were committed.
- The implementation follows relevant ADRs.
- For UI Stories, the implementation matches the approved UX and UI design
  artifacts, and referenced external design artifacts were inspected when
  available.
- For UI Stories with design-exploration input, the implementation matches the approved selection and comparison artifacts.

## Phase 12 — Commit

Create a Git commit containing the completed implementation.

Use a clear commit message that references the Jira Story.

Example:

`ADVERIFY-69: implement authentication foundation`

Do not push to a remote repository unless the user explicitly asks.

Committing and pushing must not transition the Jira Story. The Story
stays `In Progress` after commit and after push. The transition to
`In Review` happens only when the Pull Request is opened and is owned by
the `/factory pr` skill — never by this workflow.

## Final report

Report:

### Story

<Jira key and summary>

### Implemented

<What was changed>

### Tests

<Tests and verification performed>

### Review

<Whether the implementation satisfies the Story>

### Design input

<Selection path and direction, comparison path and section, when applicable>

### Commit

<Commit hash and message>

### Remaining issues

<List unresolved issues, risks, or follow-up work>

If implementation was not completed, clearly explain what remains.

## Phase 13 — Update Jira

After the implementation has been successfully committed:

1. Capture the commit hash.
2. Prepare a concise implementation summary.
3. Prepare the verification results.
4. Add a Jira comment using:

`skills/ticket/scripts/jira-comment.sh <JIRA-KEY> "<COMMENT>"`

The comment should include:

- Implementation summary
- Commit hash
- Tests performed and their results
- Lint/typecheck results
- Review result
- Any remaining issues

Example:

Implementation completed.

Commit: e9a72bc

Tests:
- API: 21 passed
- Web: 5 passed
- RLS: 15/15 passed
- Lint: passed
- Typecheck: passed

Review:
- Acceptance criteria: PASS
- RFC alignment: PASS
- ADR alignment: PASS

Remaining issues:
- None

Do not include secrets, credentials, API tokens, or sensitive data in
the Jira comment.

If adding the Jira comment fails:

- Do not undo the implementation.
- Report that the implementation succeeded but the Jira update failed.
- Include the commit hash in the final response.

## Phase 14 — In Review transition (not performed here)

Do not transition the Story to `In Review` in this workflow — not on
commit and not on push.

The transition to `In Review` happens only when the Pull Request is
opened and is owned by the `/factory pr` skill.

Do not transition the Story to `Done`.

`In Review` means the implementation is ready for human review.

