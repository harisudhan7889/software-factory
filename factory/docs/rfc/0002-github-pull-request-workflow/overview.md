# RFC-0002 — GitHub Pull Request Workflow

**Status:** Accepted

**Date:** 2026-08-23

**Authors:** Hari

## Context

The software factory can currently implement product work, run tests,
create Git commits, provision a GitHub repository, and maintain Jira
traceability.

The current delivery flow ends at a local Git commit:

    Jira
      ↓
    Implementation
      ↓
    Tests
      ↓
    Review
      ↓
    Commit
      ↓
    Jira → In Review

The next capability is to allow the factory to take a completed
implementation commit and turn it into a reviewable GitHub Pull Request.

The PR workflow must preserve the factory's existing principles:

- Safe operations may be automated.
- Externally visible or potentially destructive operations require explicit
  human approval.
- Product, architectural, security, legal, and compliance decisions must not
  be silently invented.
- Operations must be idempotent and retry-safe.
- Jira must remain traceable to the implementation and delivery state.
- CI status must be reported accurately and separately from PR creation
  success.

The GitHub authentication model is already defined by factory ADR-0001.
This RFC does not redefine GitHub authentication.

## Goals

The factory should be able to:

- Determine the appropriate branch for a completed implementation.
- Create or reuse a dedicated implementation branch safely.
- Push the implementation branch to GitHub.
- Detect whether a corresponding Pull Request already exists.
- Generate a proposed Pull Request title.
- Generate a proposed Pull Request description.
- Include relevant Jira issue information in the Pull Request.
- Show the proposed Pull Request content to the user.
- Require explicit approval before creating the Pull Request.
- Create the Pull Request after approval.
- Detect an existing Pull Request and avoid creating duplicates.
- Read the Pull Request's CI/check status.
- Distinguish Pull Request creation status from CI status.
- Update the Jira issue with the Pull Request information.
- Report the complete delivery result.
- Recover safely from failed push, PR creation, or CI operations.

## Non-goals

The first version will not:

- Automatically merge Pull Requests.
- Automatically approve Pull Requests.
- Automatically resolve review comments.
- Automatically modify branch protection.
- Force-push branches.
- Delete branches automatically.
- Resolve merge conflicts without explicit approval.
- Automatically change application code because CI fails.
- Automatically deploy to production.
- Provision GitHub repositories.
- Redefine GitHub authentication.
- Replace the existing implementation/test workflow.

## Proposed user experience

The factory should eventually support a command such as:

    /factory pr

The factory should inspect the current project and implementation state
before proposing a Pull Request.

Example:

    Implementation commit:
      225cfd7 — ADVERIFY-83: fix CI permission-denied failures

    Jira issue:
      ADVERIFY-83

    Target repository:
      harisudhan7889/AdVerify

    Proposed branch:
      fix/ADVERIFY-83-ci-permission-denied

    Proposed Pull Request:
      Title:
        ADVERIFY-83: fix CI permission-denied failures

      Description:
        <generated from Jira issue, implementation summary,
         tests, and review results>

    CI:
      Latest relevant status:
        <success/failure/pending/none>

    Create this Pull Request?
    [yes/no]

The Pull Request must not be created before explicit user approval.

## Workflow

The factory should separate the PR workflow into explicit stages:

1. Inspect
2. Determine branch
3. Validate local state
4. Push branch
5. Detect existing Pull Request
6. Generate Pull Request proposal
7. Human approval
8. Create Pull Request
9. Verify Pull Request
10. Read CI/check status
11. Update Jira
12. Report result

A failure in one stage must be reported explicitly.

Successful earlier stages must be preserved so that later stages can be
retried safely.

## Stage 1 — Inspect

Before changing GitHub or local Git state, inspect:

- Current branch.
- Current HEAD commit.
- Working tree state.
- Existing remotes.
- Existing branches.
- Existing GitHub repository.
- Existing implementation branch when present.
- Jira issue key when available.
- Existing Pull Requests associated with the branch or Jira issue.
- Current CI/check state when available.

Inspection must not modify the repository or GitHub.

## Stage 2 — Determine branch

The factory should use a dedicated implementation branch for the Pull
Request.

If the implementation is already on a non-default branch:

- Reuse the existing implementation branch.
- Do not create another branch unnecessarily.

If the implementation is on the default branch (`main` or `master`):

- Create a dedicated Pull Request branch at the current implementation
  commit.
- Do not rewrite, remove, or reset existing commits.
- Preserve the existing local history.
- Push the new branch to GitHub.
- Create the Pull Request from the new branch.

The new branch name should be deterministic and derived from the Jira
issue when available.

Examples:

    feat/ADVERIFY-72-rule-engine

    fix/ADVERIFY-83-ci-permission-denied

If creating the branch would require rewriting history or a destructive
Git operation, stop and ask the user for approval.

The factory must report the selected source branch and target branch in the
Pull Request plan.

## Stage 3 — Validate local state

Before pushing:

- Verify the working tree.
- Verify the intended commit.
- Verify the implementation commit belongs to the current project.
- Verify the remote points to the expected GitHub repository.
- Verify that no unrelated uncommitted changes will be included.

The factory must not silently include unrelated changes in a Pull Request.

If uncommitted changes exist:

- Show them.
- Ask the user whether to stash, commit separately, discard, or stop.
- Never silently discard them.

## Stage 4 — Push branch

The factory may automatically push a new implementation branch when:

- The repository is already provisioned.
- The branch is expected.
- The push is non-destructive.
- The remote is the expected GitHub repository.
- No force-push is required.

If the branch already exists remotely:

- Compare local and remote state.
- Do not force-push automatically.
- Ask before resolving divergence.

If pushing fails:

- Report the failure.
- Preserve local Git state.
- Do not retry destructive operations indefinitely.
- Allow the push to be retried after the cause is corrected.

## Stage 5 — Detect existing Pull Request

Before creating a Pull Request:

- Search for an existing open Pull Request from the implementation branch.
- Search for a Pull Request associated with the Jira issue when practical.
- Detect whether a Pull Request already exists for the same branch and
  repository.

If an appropriate Pull Request already exists:

- Do not create a duplicate.
- Report the existing Pull Request.
- Continue with verification and CI status when appropriate.

If an existing Pull Request is closed:

- Report it.
- Do not automatically recreate or reopen it without determining whether
  that is appropriate.

## Stage 6 — Generate Pull Request proposal

Generate a proposed Pull Request from available project context.

The proposal should use:

- Jira issue key and summary.
- Jira description and acceptance criteria.
- Implementation summary.
- Tests performed.
- Review results.
- Relevant RFC/ADR context when appropriate.
- Commit information.

The generated Pull Request should not invent requirements that are not
supported by the Jira issue or implementation evidence.

The proposal must include:

- Pull Request title.
- Pull Request description.
- Source branch.
- Target branch.
- Repository.
- Jira issue reference.
- Test/verification summary.
- Known limitations or remaining issues when relevant.

Example:

    Title:
    ADVERIFY-83: fix CI permission-denied failures

    Description:

    ## Summary
    - Add explicit Supabase grants for application roles.
    - Harden CI environment initialization.
    - Prevent required RLS tests from being silently skipped.

    ## Verification
    - RLS: 15/15 passed
    - Catalog: 8/8 passed
    - Engine integration: 3/3 passed
    - Lint: passed
    - Typecheck: passed

    ## Jira
    ADVERIFY-83

## Stage 7 — Human approval

Before creating the Pull Request:

1. Show the proposed title.
2. Show the proposed description.
3. Show the source branch.
4. Show the target branch.
5. Show the repository.
6. Show the Jira issue reference.
7. Ask for explicit approval.

The user may edit the title or description before approval.

Do not create the Pull Request before explicit approval.

## Stage 8 — Create Pull Request

After explicit approval:

1. Create the Pull Request.
2. Verify creation succeeded.
3. Record Pull Request number and URL.
4. Verify source and target branches.
5. Continue to CI/check inspection.

If Pull Request creation fails:

- Report the failure.
- Preserve the pushed branch.
- Do not create duplicate Pull Requests automatically.
- Allow safe retry.

## Stage 9 — Verify Pull Request

After creation or detection of an existing Pull Request, verify:

- Pull Request exists.
- Correct repository.
- Correct source branch.
- Correct target branch.
- Correct Jira reference where applicable.
- Pull Request title and description are present.

The factory must not represent Pull Request creation as successful unless
GitHub confirms the Pull Request exists.

## Stage 10 — CI and check status

GitHub Actions and other checks must be reported using separate facts.

The factory must distinguish:

1. Workflow presence.
2. Latest relevant workflow/check run state.
3. Pull Request creation state.

For example:

    Pull Request: created
    GitHub Actions workflow: present
    Latest CI run: failure

A failed CI run must never be reported as "CI verified" or "delivery
verified".

Possible CI states include:

- success
- failure
- pending
- cancelled
- neutral
- skipped
- no run yet
- unknown

The factory must not treat workflow-file presence as proof that CI passed.

A CI failure does not invalidate successful Pull Request creation.

The failure should instead be reported as a project-level verification
issue.

## Stage 11 — Jira update

After a Pull Request is created or discovered:

- Add a Jira comment with the Pull Request URL and number.
- Include the source branch.
- Include the current CI/check state when available.
- Do not expose credentials or secrets.
- Do not overwrite previous Jira implementation history.

Example:

    Pull Request created:
    #12 — https://github.com/harisudhan7889/AdVerify/pull/12

    Branch:
    fix/ADVERIFY-83-ci-permission-denied

    CI:
    Latest run: success

The factory should update the Jira issue only when the Jira issue can be
identified confidently.

If Jira update fails:

- Do not undo the Pull Request.
- Report that GitHub delivery succeeded but Jira traceability failed.
- Allow Jira synchronization to be retried.

## Idempotency

The PR workflow must be safe to run repeatedly.

Examples:

- Existing branch → reuse instead of creating another branch.
- Existing pushed branch → do not push unnecessarily.
- Existing Pull Request → do not create a duplicate.
- Existing Jira PR comment → avoid unnecessary duplicate comments when
  practical.
- Existing successful CI result → report it rather than initiating
  unrelated work.

The factory should inspect current state before each mutating operation.

## Failure handling

If branch push fails:

- Preserve the local commit.
- Report the cause where available.
- Do not force-push automatically.
- Allow retry.

If Pull Request creation fails after push succeeds:

- Report that the branch was successfully pushed.
- Preserve the branch.
- Allow Pull Request creation to be retried.

If CI fails:

- Report the failure separately from Pull Request creation.
- Do not automatically modify code.
- Do not automatically merge.
- Treat the failure as project work requiring investigation.

If Jira update fails:

- Preserve the Pull Request.
- Report the traceability failure.
- Allow Jira synchronization to be retried.

## Security

- Never expose GitHub credentials.
- Never commit credentials.
- Never include tokens in Pull Request titles/descriptions.
- Never include credentials in Jira comments.
- Use the GitHub authentication model defined by ADR-0001.
- Use the minimum permissions required.
- Do not force-push without explicit approval.
- Do not delete branches automatically.
- Do not modify repository protection settings automatically.

## Pull Request content rules

Generated Pull Request content must:

- Reflect the actual implementation.
- Reference the correct Jira issue.
- Summarize actual tests and verification performed.
- Identify known limitations when relevant.
- Avoid claiming tests passed when they did not.
- Avoid claiming CI passed when it failed or has not run.
- Avoid inventing product or architectural decisions.

## Branch lifecycle

The first version should not automatically delete the source branch after
merge.

Branch cleanup is a future capability requiring separate design.

## Future extensions

Later versions may support:

- Automatic merge after explicit approval.
- Branch cleanup.
- Review-comment assistance.
- Draft Pull Requests.
- Required-review detection.
- CI retry actions.
- Jira transition based on Pull Request/CI state.
- Release creation.
- Deployment automation.

These are outside the first version.

## Open questions

1. Exact branch naming convention.
2. Whether the factory should always branch from the default branch or reuse
   the current implementation branch.
3. Exact Jira → Pull Request linking convention.
4. Whether CI checks should be polled, queried on demand, or both.
5. Whether the first version should support draft Pull Requests.
6. Whether a Pull Request should move the Jira issue to a specific status
   automatically.

## Acceptance criteria

The capability will eventually be considered complete when:

1. The factory can determine or reuse an appropriate implementation branch.
2. The factory can safely push the implementation branch to GitHub.
3. The factory detects an existing Pull Request and avoids creating
   duplicates.
4. The factory generates a Pull Request title and description from Jira and
   implementation context.
5. The factory shows the complete Pull Request proposal before creation.
6. Pull Request creation requires explicit user approval.
7. The factory creates the Pull Request after approval.
8. The factory verifies the created Pull Request.
9. The factory reports workflow presence separately from CI/check outcomes.
10. A failed CI run is never reported as "verified".
11. The factory updates the originating Jira issue with Pull Request
    information when the Jira issue is known.
12. Failed Jira synchronization does not undo successful GitHub delivery.
13. The workflow is safe to retry and does not create duplicate Pull
    Requests.
14. The factory never exposes GitHub credentials.
15. The factory does not automatically merge, force-push, or delete branches.

## Relationship to existing factory capabilities

This RFC extends the existing GitHub provisioning capability defined by
RFC-0001.

RFC-0001 is responsible for creating and configuring the GitHub repository.

This RFC is responsible for delivery of implementation changes through
branches and Pull Requests.

The GitHub authentication model remains defined by ADR-0001.

The implementation workflow remains responsible for planning,
implementation, testing, review, and committing changes before the PR
workflow begins.

The intended delivery chain becomes:

    Jira
      ↓
    Implementation plan
      ↓
    Implementation
      ↓
    Tests and review
      ↓
    Commit
      ↓
    GitHub branch
      ↓
    Pull Request
      ↓
    CI/checks
      ↓
    Jira traceability

## Post-merge Jira synchronization

When a Pull Request associated with a Jira issue is merged:

1. GitHub Actions receives the `pull_request.closed` event.
2. The workflow continues only when `github.event.pull_request.merged == true`.
3. The workflow identifies the originating Jira issue.
4. The workflow checks the Jira issue's available transitions.
5. If the `Done` transition is available, transition the Jira issue to
   `Done`.
6. Add a Jira comment containing the Pull Request URL and merge information.
7. If the Pull Request is closed without being merged, do not transition the
   Jira issue to `Done`.
8. If Jira synchronization fails, do not undo or otherwise affect the GitHub
   merge. Report GitHub merge success and Jira synchronization failure
   separately.

The workflow must be idempotent. Repeated delivery of the merge event must
not create duplicate Jira transitions or unnecessary duplicate comments.

### Jira authentication

The GitHub Actions workflow uses the existing Jira API-token authentication
model.

Store the following values as GitHub Actions repository secrets:

- `JIRA_BASE_URL`
- `JIRA_EMAIL`
- `JIRA_API_TOKEN`

The secrets must never be committed to the repository, written into
workflow source, printed to logs, included in Pull Requests, or included in
Jira comments.

The Jira account associated with the token must have only the project
permissions required for this integration:

- Browse Projects
- Add Comments
- Transition Issues
