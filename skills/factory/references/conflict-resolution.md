# Pull Request Conflict Resolution

## Purpose

Define the workflow for diagnosing and resolving Git merge conflicts for the
current Pull Request or implementation branch.

This reference is used by:

`/factory pr resolve-conflicts`

The goal is to resolve conflicts according to the intended product and
implementation behavior, not merely to make Git accept a merge.

## Scope

This workflow covers:

- Detecting merge conflicts.
- Identifying conflicting files and commits.
- Understanding both sides of each conflict.
- Using Jira, RFC, ADR, implementation, and Pull Request context to determine
  intended behavior.
- Resolving conflicts when the correct resolution is unambiguous.
- Asking the user when conflicting behavior requires a decision.
- Running relevant verification after conflict resolution.
- Creating a commit for conflict-resolution changes when appropriate.

This workflow does not:

- Force-push.
- Rewrite unrelated history.
- Silently discard one side of a conflict.
- Merge unrelated work.
- Change product requirements.
- Change accepted architecture without approval.
- Merge the Pull Request.
- Create follow-up Jira work without approval.

## Invocation

The user invokes:

`/factory pr resolve-conflicts`

The workflow operates on the current project/repository and the relevant
Pull Request when one exists.

## Phase 1 — Inspect repository and Pull Request state

Before changing anything:

1. Determine whether the current directory is a Git repository.
2. Determine the current branch.
3. Determine the current HEAD commit.
4. Inspect the working tree.
5. Inspect configured remotes.
6. Identify the relevant Pull Request when available.
7. Identify the Pull Request source and target branches.
8. Determine whether the branch is behind, diverged, or has merge conflicts.
9. Identify the commit or branch relationship causing the conflict.

Do not modify files during inspection.

If the repository is not in a state where conflict resolution can be performed
safely:

- Report the condition.
- Stop.

## Phase 2 — Preserve repository safety

Before attempting resolution:

- Preserve the current branch and commits.
- Do not reset or discard uncommitted changes silently.
- Do not force-push.
- Do not rewrite existing history.
- Do not delete branches.
- Do not modify unrelated branches.

If uncommitted changes unrelated to the conflict exist:

1. Show the user the affected state.
2. Ask whether to stash, commit separately, or stop.
3. Do not include unrelated changes in the conflict resolution.

## Phase 3 — Identify conflicting files

Determine:

- Conflicting files.
- Conflict type.
- Source branch changes.
- Target branch changes.
- Relevant commits on each side.
- Whether the conflict is textual, structural, semantic, or generated-file
  related.

For each conflict, record:

```text
File:
<path>

Source side:
<summary>

Target side:
<summary>

Conflict type:
<textual / structural / semantic / generated>

Relevant context:
<summary>
```

Do not resolve a conflict before understanding both sides.

## Phase 4 — Gather project context

Use the strongest available context to determine intended behavior.

Inspect when relevant:

- Jira Story/Bug.
- Pull Request title and description.
- Implementation plan.
- RFCs.
- ADRs.
- Existing implementation.
- Tests.
- Related commits.
- Related Pull Requests.
- Existing design artifacts for UI changes.

The Jira Story and accepted architecture remain the primary scope and
decision boundaries.

Do not assume the newer commit is automatically correct.

Do not assume the target branch is automatically correct.

## Phase 5 — Classify each conflict

Classify each conflict as exactly one primary type:

1. Non-overlapping textual conflict.
2. Equivalent change with different formatting or wording.
3. Dependency/order conflict.
4. Configuration conflict.
5. Generated-file conflict.
6. API/schema contract conflict.
7. Behavioral/product conflict.
8. Architecture conflict.
9. Security/compliance conflict.
10. Unknown / insufficient evidence.

If multiple types apply:

- Identify the primary type.
- List secondary contributing factors.

## Phase 6 — Determine resolution

For each conflict, determine whether the correct resolution is unambiguous.

### Safe to resolve

A conflict may be resolved automatically when evidence shows that:

- Both sides preserve the same intended behavior.
- One side contains a clearly superseded change under the current Story.
- The change is mechanical and deterministic.
- The conflict is formatting-only.
- A generated artifact can be deterministically regenerated from the
  authoritative source.
- The accepted RFC/ADR clearly determines which behavior is required.

Record why the resolution is safe.

### Requires user decision

Stop and ask the user when:

- Both sides implement materially different product behavior.
- The conflict changes a business rule.
- The conflict changes an API or data contract in incompatible ways.
- The conflict changes security or compliance behavior.
- The conflict involves competing architectural decisions.
- The intended behavior cannot be determined confidently.
- Resolving the conflict would require expanding the current Jira scope.

Do not guess.

Use:

```text
Conflict Decision Required

File:
<path>

Option A:
<behavior>

Option B:
<behavior>

Current evidence:
<evidence>

Decision needed:
<exact question>
```

## Phase 7 — Proposed resolution

Before resolving a conflict, summarize the intended resolution.

Use:

```text
Conflict Resolution Proposal

Pull Request:
<# and URL>

File:
<path>

Conflict:
<what conflicts>

Resolution:
<what will be kept/combined/regenerated>

Reason:
<evidence from Jira/RFC/ADR/code>

Verification:
<tests/checks to run>
```

For multiple safe conflicts, they may be grouped into one proposal.

Do not modify the repository when the resolution requires explicit user
approval under the normal implementation decision boundaries.

## Phase 8 — Resolve conflicts

When the resolution is unambiguous and permitted:

- Resolve only the affected conflicts.
- Preserve valid changes from both sides when required.
- Remove conflict markers completely.
- Avoid unrelated formatting or refactoring.
- Do not change unrelated files.

After resolution:

```bash
git status
git diff --check
git diff
```

Inspect the final diff for accidental loss of code.

## Phase 9 — Generated files

For generated files:

- Prefer resolving the authoritative source and regenerating the artifact.
- Do not hand-edit generated output when deterministic regeneration is
  available.
- Verify that the generated result matches the intended source state.

If the generated artifact cannot be regenerated safely, stop and ask.

## Phase 10 — UI conflicts

When conflicts involve a UI Story:

- Read the approved UX specification.
- Read the approved UI design specification.
- Inspect the referenced design artifact when available.
- Preserve the approved UX and UI behavior.
- Do not resolve to a simpler or less complete UI merely because one side is
  easier to merge.

If both sides contain materially different approved designs or behavior:

- Stop.
- Ask which design should remain authoritative.
- Do not silently choose one.

## Phase 11 — Verification

After conflict resolution:

Run relevant verification.

At minimum, when applicable:

- Build.
- Unit tests.
- Integration tests.
- Lint.
- Typecheck.
- Relevant UI verification.

Check that:

- Conflict markers are gone.
- The original Story behavior remains intact.
- Both necessary changes are preserved.
- No unrelated files changed.
- The working tree contains only intended conflict-resolution changes.

For UI Stories, also verify the implementation against the approved UX and
UI design artifacts.

Do not claim the conflict is resolved if verification fails.

## Phase 12 — Commit

When the resolution is verified:

- Create a commit containing the conflict-resolution changes.
- Use a clear commit message referencing the Jira issue when available.

Example:

`ADVERIFY-84: resolve PR merge conflicts`

Do not amend or rewrite unrelated commits unless explicitly required and
approved.

## Phase 13 — Push

Push the resolved branch only when the push is non-destructive and permitted
by the existing GitHub PR workflow.

Do not force-push automatically.

If the branch requires a force-push because conflict resolution was performed
through a history-rewriting operation:

- Stop.
- Explain why.
- Ask for explicit approval.

Prefer a normal merge/rebase strategy that preserves history when possible.

## Phase 14 — Recheck Pull Request

After pushing:

1. Verify the Pull Request still exists.
2. Verify source and target branches.
3. Verify the conflict state is cleared.
4. Check GitHub Actions.
5. Report CI state separately from Pull Request state.

If CI fails after conflict resolution:

- Do not assume the conflict caused the failure.
- Use `/factory pr fix-build` / the `pipeline-debug` workflow for diagnosis.

## Idempotency

The workflow should be safe to resume.

Before each mutating operation:

- Inspect current state.
- Determine which conflicts are already resolved.
- Avoid repeating completed operations.
- Preserve existing conflict-resolution commits.
- Do not create duplicate Pull Requests.

Examples:

- Conflicts already resolved → verify instead of resolving again.
- Resolution commit already exists → do not duplicate it.
- Branch already pushed → do not push unnecessarily.
- Pull Request already reflects the resolution → verify state.

## Failure handling

### Unable to determine intended resolution

- Stop.
- Explain the conflicting behaviors.
- Ask for the required decision.
- Do not modify the repository.

### Tests fail after resolution

- Report the failing tests.
- Determine whether the failure is caused by the resolution.
- Do not claim the conflict is resolved until the relevant verification
  succeeds.

### Push fails

- Preserve the local resolution.
- Report the failure.
- Do not force-push automatically.

### Pull Request state cannot be verified

- Report the limitation.
- Preserve the local state.
- Do not claim successful delivery.

## Self-Improvement Review

Before completing the workflow, review the run for factory-level improvements.

Look for:

- A conflict type the workflow did not handle well.
- A repeated manual resolution step.
- A missing safety check.
- A misleading conflict or resolution report.
- A recurring source of conflicts that suggests a reusable workflow change.
- A workaround that future runs should no longer require.

Only propose a factory change when real evidence shows that future conflict
resolution runs should behave differently.

Do not propose cosmetic, hypothetical, or one-off changes.

When a genuine factory improvement is identified, follow the common
self-improvement standard and obtain explicit approval before modifying
factory artifacts.

## Final report

Report:

```text
Conflict Resolution Report

Repository:
<owner/repository>

Pull Request:
<# and URL>

Source branch:
<branch>

Target branch:
<branch>

Conflicts:
<number>

Resolved:
<files / summary>

User decisions:
<none / list>

Commit:
<hash and message>

Verification:
<results>

GitHub Actions:
<success / failure / pending / not checked>

Jira:
<updated / unchanged / not applicable>

Result:
<success / partial / failed>
```

Never report success when unresolved conflicts remain.

Never report success when required verification has failed.

## Decision boundaries

The factory must not silently:

- Force-push.
- Rewrite unrelated history.
- Delete branches.
- Discard one side of a meaningful behavioral conflict without evidence.
- Change product behavior.
- Change accepted architecture.
- Change security or compliance behavior.
- Expand Jira scope.
- Create follow-up Jira work without approval.
- Merge the Pull Request.

When uncertain, stop and ask.
