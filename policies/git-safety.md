# Git and Branch Safety Policy

## Purpose

Define safe Git rules for the software factory: keep Story work isolated,
preserve history, prevent accidental cross-Story changes, and avoid
destructive Git operations.

## Scope

Applies to branch, commit, push, merge, rebase, and Pull Request operations
for Jira Stories. `guardrails.md` owns the general approval and contamination
behavior (`GR-APPROVAL-001`, `GR-DESTRUCTIVE-001`, `GR-SCOPE-002`). This policy
owns the Git mechanics.

## Principles

1. Preserve history.
2. Keep Story work isolated.
3. Use the correct base branch.
4. Verify before mutation.
5. Prefer non-destructive operations.
6. Never hide branch ancestry.
7. Report uncertainty before changing shared history.

## Rules

### GIT-BRANCH-001 — Branch base and name

Severity:
BLOCK

Rule:
Create a dedicated implementation branch per Jira Story, based on the project
default branch, named `feat/<JIRA>-<slug>` (for example
`feat/ADVERIFY-88-tenancy-rbac`).

Trigger:
A new Jira Story starts.

Required action:
Determine the default branch from the repository or GitHub (usually `main` or
`master`) and do not assume it. Before creating the branch, identify the base,
verify the base commit, and check whether commits from another Story would
enter the branch.

Forbidden action:
Base a Story branch on another feature branch because the Stories are related.

Exception:
An explicit, declared dependency. Identify the parent Story, branch, and
dependency, and prefer waiting for the parent to merge. If work must proceed
first, mark the dependency, report that the branch contains parent work, keep
it visible in the Pull Request plan, and never present the Story as
independent.

Evidence:
The branch name contains the Jira key and `git merge-base` shows the expected
base.

### GIT-ISOLATION-001 — Cross-Story isolation

Severity:
BLOCK

Rule:
A branch and Pull Request normally contain work for one Jira Story.

Trigger:
Before Pull Request creation, merge, or rebase.

Required action:
Compare the source branch with the target, inspect the commits unique to the
source, and identify commits or files that belong to another Story. If
unrelated work is present, stop, report the issue, branch, and commits, and
correct the ancestry or get explicit approval for the dependency. After a merge
or rebase, verify the resulting ancestry, diff, and tests.

Forbidden action:
Deliver another Story's work through the current Pull Request, or use merge or
rebase to hide an ancestry problem.

Exception:
A declared dependency on an unmerged parent. Report it, identify the parent
Pull Request, explain that merging may also deliver parent changes, and get
explicit approval when the normal workflow expects isolated Stories.

Evidence:
Use the Evidence block below.

### GIT-PUSH-001 — Push and history safety

Severity:
BLOCK for force-push and for rewriting shared or published history. CONFIRM for
resolving a divergent remote.

Rule:
Do not force-push or rewrite shared or published history automatically.
History-sensitive operations are `git rebase`, `git reset`,
`git commit --amend`, `git push --force`, `git push --force-with-lease`, and
replacing published commits.

Trigger:
A push, or any history-sensitive operation.

Required action:
Before pushing, verify the remote repository and branch, compare local and
remote state, and detect divergence. Do not push when the remote already
matches. If the remote differs, explain the divergence and find a
non-destructive resolution. If a force-push or shared-history rewrite is
required, stop, explain why and the impact, name a safe alternative, and ask for
explicit approval.

Forbidden action:
Force-push by default, or reset the working tree to remove uncertainty.

Exception:
A local, unpublished rewrite is allowed only when it is necessary, discards no
unrelated work, stays within the current task, and the workflow permits it.
When uncertain, stop and ask.

Evidence:
Remote state is confirmed after the push.

### GIT-TREE-001 — Uncommitted changes and conflicts

Severity:
CONFIRM

Rule:
Never silently discard or include unrelated changes.

Trigger:
A branch operation with a dirty working tree, or a merge conflict.

Required action:
Inspect the working tree first. If unrelated changes exist, show them and ask
whether to stash, commit separately, or stop. For conflicts, understand both
sides, and use `/factory pr resolve-conflicts` for a Pull Request.

Forbidden action:
Discard changes silently, or resolve a conflict by choosing the newer commit,
the target branch, or one side without evidence.

Exception:
None.

Evidence:
The working tree status is reported before and after the operation.

### GIT-PROTECT-001 — Protected branches and deletion

Severity:
BLOCK

Rule:
Do not modify branch protection or delete work automatically.

Trigger:
Branch protection blocks a required action, or a branch is a deletion
candidate.

Required action:
Report the block and use an approved workflow alternative. Ask when a protected
setting must change. Treat branch cleanup as a separate controlled capability.

Forbidden action:
Disable required reviews, status checks, protection rules, or security controls
only to ease a merge. Delete another Story's branch, a protected branch, a
remote branch that belongs to other work, or unmerged work.

Exception:
None without explicit approval.

Evidence:
The report names the blocking rule and the approved alternative.

## Safe Inspection Commands

Prefer non-mutating commands, and never run destructive commands only to
inspect state:

```bash
git status
git branch --show-current
git log --oneline --decorate --graph --all
git diff --stat
git merge-base <source> <target>
git log <target>..<source> --oneline
```

## Pull Request Base Safety

Before creating a Pull Request, verify the source branch, target branch,
repository, Jira issue, source branch ancestry, unique commits, and changed
files. A Pull Request must not silently include another Story's
implementation (`GIT-ISOLATION-001`).

## Failure Handling

- **Wrong base branch:** stop delivery, identify the correct base, preserve current commits, and look for a non-destructive correction.
- **Cross-Story contamination:** stop Pull Request creation, identify the other Story, commits, and branch relationship, then correct the ancestry or request approval for an intentional dependency.
- **Remote divergence:** do not force-push. Explain the divergence and find a safe path.
- **Destructive operation required:** stop, explain the operation and risk, and ask for approval.

## Decision Boundaries

Stop and ask when a force-push, a shared-history rewrite, or cross-Story
contamination is detected.

## Exceptions

Exceptions are stated per rule. A local unpublished history rewrite is allowed
only under `GIT-PUSH-001`.

## Enforcement

Pre-commit and pre-push hooks, branch protection, `git merge-base` and
`git log target..source` checks, CI, and human approval for force-push.

## Evidence

When a branch decision matters, report:

```text
Base branch / Base commit:
Implementation branch:
Parent dependency / Parent commit included:
Cross-Story commits detected: Yes / No
```

Do not claim branch isolation without checking ancestry when the branch could
contain dependent work.

## Verification

Before reporting Git work complete, verify:

- [ ] Correct repository, current branch, and base branch.
- [ ] Expected commit ancestry and no unintended cross-Story commits.
- [ ] No unrelated working-tree changes were included.
- [ ] The final diff is understood and required tests were run.
- [ ] Remote state is confirmed after push.
- [ ] Pull Request source and target are correct.

## Relationship to Other Policies

`guardrails.md` owns approval, destructive-action, and contamination behavior.
`security.md` owns security and secrets. `verification.md` owns completion
evidence. `dependency-safety.md`, `web-best-practices.md`, and
`observability.md` own their own areas. Do not duplicate complete workflows
across policy files.

## Self-Improvement

Review Git operations for wrong branch base, cross-Story contamination,
repeated ancestry problems, unsafe workarounds, missing checks, and repeated
manual recovery. Propose a factory change only when real evidence shows future
Git operations should behave differently; no cosmetic or hypothetical changes.
