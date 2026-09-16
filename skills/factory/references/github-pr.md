# GitHub Pull Request Workflow

## Purpose

Create a reviewable GitHub Pull Request for completed implementation work
according to factory RFC-0002.

This reference defines the workflow for:

`/factory pr`

Relevant factory document:

- RFC: `/factory/docs/rfc/0002-github-pull-request-workflow/overview.md`

GitHub authentication and authorization remain governed by:

- ADR: `/factory/docs/adr/0001-github-authentication/overview.md`

RFC-0002 and ADR-0001 are the source of truth for this capability.

## Scope

The first version supports:

- Inspecting the current implementation state.
- Determining or reusing an implementation branch.
- Safely pushing an implementation branch.
- Detecting existing Pull Requests.
- Generating Pull Request title and description.
- User review/edit of Pull Request content.
- Explicit approval before Pull Request creation.
- Creating the Pull Request.
- Verifying the Pull Request.
- Reading GitHub Actions/check status.
- Updating the originating Jira issue with Pull Request information.
- Idempotent and retry-safe operation.

The first version does not include:

- Automatic merging.
- Automatic approval.
- Automatic review-comment resolution.
- Automatic branch deletion.
- Automatic force-push.
- Automatic merge-conflict resolution.
- Automatic deployment.
- Repository provisioning.
- GitHub authentication changes.

## Invocation

The user invokes:

`/factory pr`

The workflow operates on the current project/repository.

## Phase 1 — Inspect local project

Before changing local Git or GitHub state:

1. Determine whether the current directory is a Git repository.
2. Determine the current branch.
3. Determine the current HEAD commit.
4. Inspect the working tree.
5. Inspect configured remotes.
6. Determine the expected GitHub repository.
7. Determine the Jira issue associated with the implementation when
   available.
8. Detect whether a relevant Pull Request already exists.
9. Read `.factory/project.yml` when present.

Do not modify anything during inspection.

## Phase 2 — Validate implementation state

Determine whether the current implementation is ready for a Pull Request.

Verify:

- The implementation commit exists.
- The intended changes are committed.
- The working tree does not contain unrelated uncommitted changes.
- The current repository is the expected project repository.
- The Jira issue can be identified when Jira traceability is expected.

If uncommitted changes exist:

1. Show the user the current state.
2. Ask whether to:
   - stash them
   - commit them separately
   - discard them
   - stop the workflow
3. Never silently discard or include unrelated changes.

## Phase 3 — Determine branch

The factory should use a dedicated Pull Request branch.

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

The branch name should be deterministic and derived from the Jira issue
when available.

Examples:

    feat/ADVERIFY-72-rule-engine

    fix/ADVERIFY-83-ci-permission-denied

If creating the branch would require rewriting history or a destructive
Git operation:

- Stop.
- Explain the required operation.
- Ask for explicit approval.

The factory must report:

- Current/source branch.
- New/reused branch.
- Target branch.

## Cross-story commit safety

Before creating a Pull Request:

1. Compare the source branch with the target branch.
2. Identify commits present on the source branch that are not part of the
   current Jira Story.
3. Determine whether any such commits belong to another Jira Story.
4. If unrelated Story commits are present, stop Pull Request creation.
5. Report the affected Jira issues, commits, and branches.
6. Do not create or update the Pull Request until the branch ancestry is
   corrected or the dependency is explicitly approved.

A Pull Request must not silently deliver another Jira Story's implementation.

When a dependent Story intentionally includes an unmerged parent Story:

- Report the dependency explicitly.
- Identify both Jira issues.
- Identify the parent Pull Request.
- State that merging the dependent Pull Request will also deliver the
  parent's commits.
- Require explicit approval before proceeding with that dependent merge
  strategy.

## Dependent follow-up work

When a Jira issue is a follow-up to another issue with an open Pull Request:

- Do not automatically reuse the parent issue's Pull Request branch.
- Determine whether the follow-up should have its own branch.
- By default, create a dedicated branch for the follow-up issue.
- If the follow-up depends on the parent branch, the new branch may be based
  on the parent Pull Request branch.
- Preserve the parent Pull Request unchanged unless the user explicitly
  approves combining the work into the existing Pull Request.
- Create a separate Pull Request unless the user explicitly approves
  combining the work into the existing Pull Request.
- Report the parent issue, base branch, source branch, and target branch in
  the Pull Request plan before pushing.

## Phase 4 — Inspect GitHub branch state

Before pushing:

1. Verify the GitHub repository.
2. Check whether the intended branch already exists remotely.
3. Compare local and remote branch state.
4. Detect divergence.

If the branch does not exist remotely:

- A normal push may proceed when permitted by this workflow.

If the branch exists and matches local state:

- Do not push unnecessarily.

If the branch exists but differs:

- Do not force-push automatically.
- Explain the divergence.
- Ask before any potentially destructive resolution.

## Phase 5 — Push implementation branch

The factory may automatically push the implementation branch when:

- The repository is already provisioned.
- The branch is expected.
- The push is non-destructive.
- The remote is the expected GitHub repository.
- No force-push is required.

Before pushing, verify that the current GitHub authentication is usable.

If authentication fails, check the user's shell profile (e.g. ~/.zshrc,
~/.zshenv) for a valid GITHUB_TOKEN before stopping. Source it per-command
(e.g. zsh -c 'source ~/.zshrc; <command>') rather than exporting once,
because exports do not persist across tool invocations. Never print or copy
the token value.

If pushing fails:

- Report the failure.
- Preserve the local commit and branch.
- Do not force-push automatically.
- Do not create a Pull Request.
- Allow safe retry after the problem is corrected.

## Phase 6 — Detect existing Pull Request

Before generating or creating a Pull Request:

- Search for an open Pull Request from the implementation branch.
- Search for a Pull Request associated with the Jira issue when practical.
- Confirm the Pull Request belongs to the expected repository.

If an appropriate Pull Request already exists:

- Do not create another Pull Request.
- Report its number and URL.
- Verify its branches.
- Continue with CI/check inspection and Jira synchronization.

If a Pull Request exists but is closed:

- Report it.
- Do not automatically reopen or recreate it.
- Ask the user if further action is required.

## Phase 7 — Generate Pull Request proposal

Generate the Pull Request proposal from available project context.

Use:

- Jira issue key and summary.
- Jira description.
- Jira acceptance criteria.
- Implementation summary.
- Tests performed.
- Review results.
- Commit information.
- RFC/ADR context when relevant.
- Known limitations or remaining issues.

Do not invent requirements or claim work that was not performed.

The proposal must contain:

- Pull Request title.
- Pull Request description.
- Source branch.
- Target branch.
- Repository.
- Jira issue reference.
- Verification summary.
- Known limitations when relevant.

Example:

```text
Pull Request Proposal

Repository:
harisudhan7889/AdVerify

Source branch:
fix/ADVERIFY-83-ci-permission-denied

Target branch:
master

Jira:
ADVERIFY-83

Title:
ADVERIFY-83: fix CI permission-denied failures

Description:
## Summary
- Add explicit Supabase grants.
- Harden CI Supabase environment initialization.
- Prevent required RLS tests from being silently skipped.

## Verification
- RLS: 15/15 passed
- Catalog: 8/8 passed
- Engine integration: 3/3 passed
- Lint: passed
- Typecheck: passed

## Jira
ADVERIFY-83
```

## Phase 8 — Human review and approval

Before creating the Pull Request:

1. Show the proposed title.
2. Show the proposed description.
3. Show source branch.
4. Show target branch.
5. Show repository.
6. Show Jira issue reference.
7. Allow the user to edit the title or description.
8. Ask for explicit approval.

Do not create the Pull Request before explicit approval.

The user may respond with an edited title or description. Treat the edited
content as the approved version when the user subsequently confirms.

## Phase 9 — Create Pull Request

After explicit approval:

1. Create the Pull Request.
2. Verify creation succeeded.
3. Record Pull Request number.
4. Record Pull Request URL.
5. Verify source branch.
6. Verify target branch.
7. Continue to CI/check inspection.

If Pull Request creation fails:

- Report the failure.
- Preserve the pushed branch.
- Do not create duplicate Pull Requests automatically.
- Allow safe retry.

## Phase 10 — Verify Pull Request

Verify:

- Pull Request exists.
- Correct repository.
- Correct source branch.
- Correct target branch.
- Correct Jira reference when applicable.
- Title is correct.
- Description is present.

The factory must not report Pull Request creation as successful unless
GitHub confirms that the Pull Request exists.

## Phase 11 — CI and check status

Report CI/check status as separate facts.

If `gh pr checks` fails due to token permissions (e.g. "Resource not
accessible by personal access token"), fall back to:

    gh run list --branch <source-branch> --json name,status,conclusion

and report its state. Do not treat the permission error as a CI failure.

The factory must distinguish:

1. Workflow presence.
2. Latest relevant workflow/check status.
3. Pull Request creation status.

Possible CI/check states include:

- success
- failure
- pending
- cancelled
- neutral
- skipped
- no run yet
- unknown

A failed CI run must never be reported as "verified", "passed", or
"delivery verified".

Example:

```text
Pull Request: created
GitHub Actions workflow: present
Latest CI run: failure
```

A CI failure does not invalidate successful Pull Request creation.

Treat a CI failure as project-level verification work.

Do not automatically modify code because CI failed.

Do not automatically merge a Pull Request because CI passed.

## CI failure handoff

After creating or updating the Pull Request, inspect the relevant GitHub
Actions status.

If the relevant CI checks are passing:

- Report the successful CI status.
- Continue the Pull Request workflow normally.

If the relevant CI checks have failed:

1. Identify the failed workflow, job, and step.
2. Invoke the `pipeline-debug` skill for diagnosis.
3. Pass the Pull Request, workflow/run information, branch, commit SHA, and
   available failure logs as context.
4. Require `pipeline-debug` to diagnose the failure before proposing any
   change.
5. Do not modify the repository automatically merely because CI failed.

The `pipeline-debug` skill should determine:

- Exact failure location
- Failure classification
- Root cause
- Evidence
- Whether the failure belongs to the current Jira Story
- Whether a follow-up Jira item is required

If a fix is required:

- Present the `Pipeline Fix Proposal`.
- Wait for explicit user approval before modifying code.
- After approval, follow the normal implementation workflow.
- Re-run relevant verification.
- Recheck GitHub Actions.

Do not automatically retry, modify code, create a follow-up Jira issue, or
merge the Pull Request solely because CI failed.

### CI and Pull Request reporting

Report Pull Request state and CI state separately.

Example:

```text
Pull Request: Success
CI: Failure
Overall: Pull Request created successfully; CI requires investigation.
```

If `pipeline-debug` was invoked, also report:

```text
Pipeline diagnosis:
<summary>

Fix:
<not started / proposed / approved / applied>

Verification:
<results>
```

## Phase 12 — Update Jira

After a Pull Request is created or an existing Pull Request is detected:

- Add a Jira comment with the Pull Request number and URL when appropriate.
- Include source and target branches.
- Include the latest CI/check state when available.
- Do not expose credentials or secrets.
- Do not overwrite earlier implementation history.

Example:

```text
Pull Request:
#12 — https://github.com/harisudhan7889/AdVerify/pull/12

Source:
fix/ADVERIFY-83-ci-permission-denied

Target:
master

CI:
Latest run: success
```

If Jira synchronization fails:

- Do not undo the Pull Request.
- Report that GitHub delivery succeeded but Jira synchronization failed.
- Allow synchronization to be retried.

## Phase 12b — Transition Jira to review status

After the Pull Request comment is posted:

1. Read the Jira issue's available transitions.
2. If a transition to the review status (`In Review` or the project's
   equivalent) is available and the issue is not already in that status,
   transition it.
3. Report the transition (previous status → new status) alongside the
   Pull Request comment confirmation.
4. If no review transition is available, report that fact and continue.
   Do not fail the Pull Request workflow.
5. If the issue is already in the review status, skip the transition and
   report that no change was required.

If the transition call fails:

- Do not undo the Pull Request.
- Do not remove the Pull Request comment.
- Report GitHub delivery as successful and the Jira transition as failed.
- Allow the transition to be retried.

The transition step must be idempotent and must never invent a status
name. Use only transitions reported as available by Jira.

## Post-merge Jira synchronization

Post-merge synchronization is handled by GitHub Actions rather than by the
local factory process.

The GitHub workflow should trigger on:

`pull_request` with `types: [closed]`

The workflow must continue only when:

`github.event.pull_request.merged == true`

When a Pull Request is merged:

1. Identify the originating Jira issue.
2. Read the Jira issue's available transitions.
3. If `Done` is available, transition the issue to `Done`.
4. Add a Jira comment containing the Pull Request URL and merge information.
5. Report GitHub merge and Jira synchronization separately.

If the Pull Request is closed without being merged:

- Do not transition the Jira issue to `Done`.
- Do not add a misleading merge comment.

If Jira synchronization fails:

- Do not undo or modify the GitHub merge.
- Report the GitHub merge as successful.
- Report Jira synchronization as failed.
- Allow Jira synchronization to be retried.

The workflow must be idempotent and avoid unnecessary duplicate comments or
transitions.

### GitHub Actions Jira credentials

The workflow uses GitHub Actions repository secrets:

- `JIRA_BASE_URL`
- `JIRA_EMAIL`
- `JIRA_API_TOKEN`

Never expose these values in logs, Pull Requests, artifacts, or Jira
comments.

## Idempotency

The workflow must be safe to run repeatedly.

Before each mutating operation:

- Inspect current state.
- Determine what has already succeeded.
- Skip successful operations when no change is required.
- Continue from the last safe state.

Examples:

- Existing implementation branch → reuse it.
- Existing matching remote branch → do not push unnecessarily.
- Existing matching Pull Request → do not create another.
- Existing Jira PR comment → avoid unnecessary duplicates when practical.
- Existing CI result → report it rather than triggering unrelated work.

## Failure handling

### Branch creation failure

- Preserve existing commits.
- Report the failure.
- Do not modify unrelated branches.
- Allow safe retry.

### Branch push failure

- Preserve the local branch and commit.
- Report the failure.
- Do not force-push.
- Do not create a Pull Request.

### Pull Request creation failure

- Preserve the pushed branch.
- Report the failure.
- Do not create a duplicate Pull Request.
- Allow retry.

### CI failure

- Report CI failure separately from Pull Request creation.
- Do not automatically change source code.
- Do not automatically merge.
- Treat the failure as project work requiring investigation.

### Jira synchronization failure

- Preserve the Pull Request.
- Report the traceability failure.
- Allow Jira synchronization to be retried.

## Security

- Never expose GitHub credentials.
- Never commit credentials.
- Never include credentials in Pull Request titles or descriptions.
- Never include credentials in Jira comments.
- Use the authentication model defined by ADR-0001.
- Use the minimum permissions required.
- Do not force-push without approval.
- Do not delete branches automatically.
- Do not change branch protection automatically.

## Pull Request content rules

Generated Pull Request content must:

- Reflect the actual implementation.
- Reference the correct Jira issue when known.
- Summarize actual tests and verification performed.
- Distinguish successful tests from skipped tests.
- Report CI status accurately.
- Identify known limitations when relevant.
- Never claim tests passed when they did not.
- Never claim CI passed when it failed or has not run.
- Never invent product, compliance, security, or architectural decisions.

## Branch lifecycle

The first version must not automatically delete the source branch after
merge.

Branch cleanup is a future capability.

## Future extensions

Later versions may support:

- Draft Pull Requests.
- Automatic merge after explicit approval.
- Branch cleanup.
- Review-comment assistance.
- Required-review detection.
- CI retry actions.
- Jira transition based on Pull Request and CI state.
- Release creation.
- Deployment automation.

These capabilities are outside the first version.

## Self-Improvement Review

Before completing the workflow, review the execution for factory-level
improvements.

Look specifically for:

- Git or GitHub API failures.
- Workarounds that were required.
- User corrections or rejected actions.
- Missing permissions or configuration.
- Incorrect assumptions in RFC, ADR, skill, or reference.
- Safety or reporting issues.
- Repeated manual steps.
- Reusable improvements discovered during the run.

### Classify observations

For each significant observation, classify it as:

1. Informational observation
2. Known limitation
3. Project-specific issue
4. Factory improvement

Do not treat every error as a factory improvement.

### No factory improvement

If no factory-level improvement is identified, report:

```text
Self-improvement: No factory change identified.
```

### Factory improvement identified

For each genuine factory improvement, create a proposal containing:

- Finding
- Root cause
- Evidence
- Exact affected artifact path
- Current behavior
- Proposed update
- Expected benefit

Use:

```text
Factory Improvement Proposal

Finding:
<what happened>

Root cause:
<why it happened>

Evidence:
<evidence from the current run>

Affected artifact:
<exact file path>

Current behavior:
<what the artifact currently says or does>

Proposed update:
<exact change to make>

Expected benefit:
<how future runs improve>
```

The factory is responsible for formulating a complete and technically
appropriate proposed update.

The user should only need to approve or reject the proposal. Do not require
the user to rewrite the proposal or specify how the affected artifact should
be changed unless the factory cannot safely determine the correct update.

If the correct update cannot be determined confidently, identify the
uncertainty explicitly and ask the user for the missing decision instead of
guessing.

### Approval

After presenting all proposed factory improvements, ask:

```text
Factory improvements were identified.

Apply these changes?
```

Do not modify factory artifacts before explicit user approval.

### Apply approved improvements

If approved:

1. Apply only the approved changes.
2. Update the exact approved artifact path(s).
3. Do not modify unrelated files.
4. If an accepted ADR or RFC changes, preserve its history and explicitly
   record the amendment.
5. Show the resulting diff.
6. Validate the updated artifact(s).
7. Record which improvements were applied.
8. Do not automatically rerun `/factory pr`.

### Accepted ADR changes

If an approved improvement changes an Accepted ADR:

1. Do not silently replace the accepted decision.
2. Propose the amendment explicitly.
3. Ask for approval of the architectural change.
4. Update the ADR only after approval.
5. Preserve the previous decision/history.
6. Record the reason and evidence.
7. Show the ADR diff.

### RFC changes

If an approved improvement changes an RFC:

1. Identify the affected section.
2. Propose the change.
3. Ask for approval.
4. Update the RFC only after approval.
5. Show the resulting diff.

### Skill, reference, or script changes

If an approved improvement changes a factory skill, reference, or script:

1. Apply only the approved change.
2. Show the diff.
3. Validate the updated artifact where possible.
4. Record the change.
5. Do not automatically rerun `/factory pr`.

### Self-improvement completion

After approved updates are applied, report:

```text
Self-improvement

Findings:
<list>

Approved updates:
<list>

Updated artifacts:
<list>

Validation:
<results>
```

If the user declines the proposed improvements:

- Do not modify the factory.
- Report the findings as observations.
- Complete the current PR workflow normally.

## Final result

On successful Pull Request creation or detection, report:

```text
GitHub Pull Request

Repository:
<owner>/<repository>

Pull Request:
#<number> — <url>

Source branch:
<branch>

Target branch:
<branch>

Jira:
<JIRA-KEY or none>

GitHub Actions workflow:
<present/absent>

Latest CI/check status:
<success/failure/pending/none>

Jira synchronization:
<updated/not updated/not applicable>

Jira transition:
<transitioned to review / already in review / not available / failed / not applicable>

Self-improvement:
<none identified / improvements proposed / improvements applied>

Result:
Success
```

If Pull Request creation succeeds but CI fails, report:

```text
Pull Request:
Success

CI:
Failure

Overall:
Pull Request created successfully; project CI requires investigation.
```

If Jira synchronization fails after successful Pull Request creation, report
the Pull Request as successful and the Jira synchronization as failed.

## Decision boundaries

The factory must not silently:

- Merge Pull Requests.
- Force-push.
- Delete branches.
- Resolve merge conflicts.
- Modify branch protection.
- Change repository settings.
- Invent product, security, architectural, legal, or compliance decisions.

When uncertain, stop and ask.
