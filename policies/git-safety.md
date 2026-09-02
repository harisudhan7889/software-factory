# Git and Branch Safety Policy

## Purpose

Define safe Git rules for the software factory.

The goal is to keep Story work isolated, preserve history, prevent accidental
cross-Story changes, and avoid destructive Git operations.

## Scope

Applies to branch, commit, push, merge, rebase, and PR operations for Jira Stories.

## Core Principles

Apply these principles to all factory Git operations:

1. Preserve history.
2. Keep Story work isolated.
3. Use the correct base branch.
4. Verify before mutation.
5. Prefer non-destructive operations.
6. Never hide branch ancestry.
7. Report uncertainty before changing shared history.

## Default Branch

Determine the project's default branch from the repository or GitHub.

Usually:

- `main`
- `master`

Do not assume the default branch without checking when the repository state is
available.

## Implementation Branch

For a new Jira Story:

- Create a dedicated implementation branch.
- Base it on the current project default branch unless an explicit dependency
  requires another base.
- Use a deterministic branch name derived from the Jira issue: `feat/<JIRA>-<slug>` (evidence: branch name contains JIRA key).

Example:

```text
feat/ADVERIFY-88-tenancy-rbac
```

Do not create a new Story branch from another feature branch merely because the
Stories are related. Exception: None — use default branch as base unless explicit dependency is declared per `## Branch Ancestry`.

## Branch Ancestry

Before creating an implementation branch:

1. Identify the intended base branch.
2. Verify the base commit.
3. Inspect branch ancestry when another feature branch is proposed as the
   base.
4. Determine whether commits from another Jira Story would become part of the
   new branch.

If another Story's commits would be included:

- Identify the parent Story.
- Identify the parent branch.
- Identify the dependency.
- Prefer waiting for the parent Story to merge.
- Then create the new branch from the updated default branch.

If work must proceed before the parent merges:

- Mark the dependency explicitly.
- Report that the dependent branch contains parent work.
- Keep the dependency visible in the Pull Request plan.
- Do not present the dependent Story as independent.

## Cross-Story Isolation

A branch and Pull Request should normally contain work for one Jira Story.

Before Pull Request creation:

1. Compare the source branch with the target branch.
2. Inspect commits that are unique to the source branch.
3. Identify commits belonging to another Jira Story.
4. Identify unintended files or changes from another Story.

If unrelated Story work is present:

- Stop.
- Report the affected Jira issue, branch, and commits.
- Correct the branch ancestry or obtain explicit approval for the dependency.

Do not silently deliver another Story's work through the current Pull Request.

## Uncommitted Changes

Before branch operations:

- Inspect the working tree.
- Identify unrelated uncommitted changes.

Do not:

- Silently discard changes.
- Silently include unrelated changes.
- Reset the working tree to remove uncertainty.

If unrelated changes exist:

- Show them.
- Ask whether to stash, commit separately, or stop.

## Remote Branches

Before pushing:

1. Verify the remote repository.
2. Check whether the branch already exists remotely.
3. Compare local and remote state.
4. Detect divergence.

If the remote branch matches local state:

- Do not push unnecessarily.

If the remote branch differs:

- Do not force-push automatically.
- Explain the divergence.
- Determine a non-destructive resolution when possible.

## Push Safety

Severity: BLOCK for force-push; CONFIRM for divergence resolution.

Normal pushes may proceed when:

- The repository is correct.
- The source branch is correct.
- The target remote is correct.
- The push is non-destructive.
- No force-push is required.

Do not force-push by default.

If force-push is required:

1. Stop.
2. Explain why.
3. Explain the possible impact.
4. Identify a safe alternative if one exists.
5. Ask for explicit approval.

## History Rewriting

Severity: BLOCK for shared history; CONFIRM for local unpublished rewrite.

Treat these operations as history-sensitive:

- `git rebase`
- `git reset`
- `git commit --amend`
- `git push --force`
- `git push --force-with-lease`
- Replacing published commits

Do not rewrite shared or published history automatically.

A local, unpublished history rewrite may be acceptable when:

- It is necessary.
- It does not discard unrelated work.
- The operation is within the current task.
- The workflow explicitly permits it.

When uncertain, stop and ask.

## Merge and Rebase

Prefer the strategy that preserves the intended Story boundaries and shared
history.

Before merging or rebasing:

- Identify source and target.
- Determine whether commits from another Story are involved.
- Inspect current branch state.
- Check whether local changes are present.

After the operation:

- Verify the resulting ancestry.
- Verify the diff.
- Run relevant tests.

Do not use merge or rebase only to hide a branch ancestry problem.

## Conflict Safety

When conflicts occur:

- Use the conflict-resolution workflow.
- Understand both sides before resolving.
- Do not choose the newer commit automatically.
- Do not choose the target branch automatically.
- Do not discard one side without evidence.

Use:

`/factory pr resolve-conflicts`

when the current Pull Request requires conflict resolution.

## Pull Request Base Safety

Before creating a Pull Request:

Verify:

- Source branch.
- Target branch.
- Repository.
- Jira issue.
- Source branch ancestry.
- Unique commits.
- Changed files.

A Pull Request must not silently include another Story's implementation.

If the Pull Request is intentionally dependent on an unmerged parent:

- Report the dependency.
- Identify the parent Pull Request.
- Explain that merging the dependent Pull Request may also deliver parent
  changes.
- Require explicit approval before using that strategy when the normal workflow
  would expect isolated Stories.

## Protected Branches

Do not modify branch protection automatically.

Do not disable:

- Required reviews
- Required status checks
- Protection rules
- Security controls

only to make a Pull Request easier to merge.

If branch protection blocks a required action:

- Report the block.
- Use an approved workflow alternative.
- Ask when a protected setting must change.

## Delete Operations

Do not automatically delete:

- Another Story's branch
- Protected branches
- Remote branches belonging to other work
- Unmerged work

Branch cleanup is a separate controlled capability.

## Safe Inspection Commands

Inspection should prefer non-mutating commands such as:

```bash
git status
git branch --show-current
git log --oneline --decorate --graph --all
git diff --stat
git diff
git merge-base <source> <target>
git log <target>..<source> --oneline
```

Use additional commands when needed.

Do not run destructive commands merely to inspect state.

## Verification

Before reporting branch or Git work as complete, verify:

- [ ] Correct repository.
- [ ] Correct current branch.
- [ ] Correct base branch.
- [ ] Expected commit ancestry.
- [ ] No unintended cross-Story commits.
- [ ] No unrelated working-tree changes were included.
- [ ] Final diff is understood.
- [ ] Required tests were run.
- [ ] Remote state is confirmed after push.
- [ ] Pull Request source and target are correct.

## Evidence

When a branch decision is important, report evidence such as:

```text
Base branch:
master

Base commit:
<commit>

Implementation branch:
feat/ADVERIFY-88-tenancy-rbac

Parent dependency:
ADVERIFY-87

Parent commit included:
<commit>

Cross-Story commits detected:
Yes / No
```

Do not claim branch isolation without checking ancestry when the situation
could contain dependent work.

## Exceptions

Exception: Local unpublished history rewrite allowed only per `## History Rewriting` conditions; otherwise `Exception: None.`

## Enforcement

Pre-commit/-push hooks, branch protection, `git merge-base` / `git log target..source` checks, CI, human approval for force-push.

## Relationship to Other Policies

Use:

- `security.md` for security and data protection.
- `verification.md` for verification requirements and evidence.
- `guardrails.md` for agent behavior controls.
- `dependency-safety.md` for dependency safety.
- `web-best-practices.md` for web app best practices.
- `observability.md` for factory execution records.

Do not duplicate complete workflows across policy files.

## Decision Boundaries

Stop and ask when force-push, history rewrite on shared branches, or cross-story contamination is detected. See `## Exceptions` for local-rewrite allowance.

## Failure Handling

### Wrong base branch

- Stop before further delivery.
- Identify the correct base.
- Preserve current commits.
- Determine whether a non-destructive correction is possible.

### Cross-Story contamination

- Stop Pull Request creation.
- Identify the other Story.
- Identify the commits and branch relationship.
- Correct the ancestry or request approval for an intentional dependency.

### Remote divergence

- Do not force-push.
- Explain the divergence.
- Determine a safe path.

### Destructive operation required

- Stop.
- Explain the operation and risk.
- Ask for approval.

## Self-Improvement

Review Git operations for:

- Wrong branch base.
- Cross-Story contamination.
- Repeated ancestry problems.
- Unsafe Git workarounds.
- Missing branch checks.
- Repeated manual recovery steps.

Only propose a factory change when real evidence shows that future Git
operations should behave differently.

Do not propose cosmetic or hypothetical changes.
