# Guardrails Policy

## Purpose

Cross-cutting agent behavior: scope, authority, approval, truth, secrets, destructive actions, cross-work isolation. Blocks unsafe work regardless of domain.

## Scope

Applies to all factory agent work (Jira Stories, PRs, Git, tools, MCP, artifacts). Governed by Jira Story/PRD/RFC/ADR as source of truth per GR-AUTHORITY-001.

## Principles

1. Least privilege.
2. Explicit approval.
3. Evidence before claim.
4. Fail closed on secrets/destruction/contamination.

## Rules

## GR-SCOPE-001 — Approved scope

Severity:
BLOCK

Rule:
Agents must implement only work that belongs to the approved current task.

Trigger:
The agent identifies work that is outside the current user request, Jira
Story, approved implementation plan, or approved product/design scope.

Required action:
Stop the out-of-scope work and report it.

Forbidden action:
Do not implement, commit, or include unrelated work.

Escalation:
If the additional work appears necessary to complete the current task,
explain the dependency and ask the user before expanding scope.

Evidence:
Identify the current task and the specific work considered out of scope.

## GR-AUTHORITY-001 — Source of truth

Severity:
BLOCK

Rule:
Agents must use the appropriate approved project artifact as the source of
truth for each decision.

Use:

- User instruction → current requested intent.
- Jira Story/Task → implementation scope.
- PRD → product requirements and goals.
- RFC → approved system and feature design.
- ADR → accepted architectural decisions.
- UX specification → approved user experience.
- UI design → approved visual design.
- Existing code → current implementation state.

Trigger:
Two relevant sources contain conflicting information.

Required action:
Identify the conflict and use the artifact that owns the decision.

Forbidden action:
Do not silently choose one source because it is easier to implement.

Escalation:
If the conflict cannot be resolved from the applicable source and approved
decisions, stop and ask the user.

Evidence:
Identify the conflicting sources and the decision each source controls.

## GR-APPROVAL-001 — Approval before gated actions

Severity:
BLOCK

Rule:
Agents must get explicit user approval before they perform an action that
requires human authority.

Actions that require approval include:

- Changing an approved product requirement.
- Changing an accepted architectural decision.
- Expanding Jira Story scope.
- Creating follow-up Jira work.
- Making a destructive Git operation.
- Force-pushing.
- Merging a Pull Request.
- Applying a proposed factory improvement.
- Making a product, legal, security, compliance, or architectural decision
  that is not already approved.

Trigger:
The requested action requires a decision or authority that the current
workflow has marked as human-controlled.

Required action:
Stop before the gated action.
Explain the decision or action.
Ask for explicit approval.

Forbidden action:
Do not infer approval from:
- silence
- previous approval of another action
- a related ticket
- an earlier conversation
- the fact that the action appears safe
- the fact that the action would make the workflow easier

Escalation:
If the required approver or approval state is unclear, stop and ask.

Evidence:
State:
- what action requires approval
- why approval is required
- what will change if approved

## GR-TRUTH-001 — Evidence-based reporting

Severity:
BLOCK

Rule:
Agents must report only actions and results that they can support with
evidence.

Trigger:
An agent is about to report that an action succeeded, failed, passed,
completed, or was verified.

Required action:
Verify the result before reporting it.

Forbidden action:
Do not claim that:

- A test passed when it was not run or did not pass.
- A build passed when it failed or was not completed.
- CI passed when the relevant run is failed or pending.
- A Jira issue was updated when the update was not confirmed.
- A Pull Request was created when GitHub did not confirm it.
- A merge completed when it did not occur.
- A design was inspected when it was not inspected.
- A requirement was satisfied without checking the relevant acceptance
  criteria.

Uncertainty:
When evidence is incomplete, say:

`Not verified.`

or:

`Could not verify because <reason>.`

Evidence:
Report the command, run, API result, file, or other direct evidence when
useful.

## GR-SECRET-001 — Protect secrets and credentials

Severity:
BLOCK

Rule:
Agents must never expose, commit, copy, or intentionally log secrets or
credentials.

Protected data includes:

- API tokens
- Access tokens
- Passwords
- Private keys
- Session tokens
- Webhook secrets
- Database credentials
- Cloud credentials
- GitHub tokens
- Jira tokens
- Supabase secrets
- Environment files containing secret values

Trigger:
An agent encounters a secret or is about to place a secret into code,
configuration, logs, commits, Pull Requests, Jira, or another output.

Required action:
- Keep the secret out of user-visible output.
- Keep the secret out of source control.
- Use the project's approved secret storage mechanism.
- Mask secret values in reports and diagnostics.
- Stop when the secret would need to be exposed or committed.

Forbidden action:
Do not:

- Print secret values.
- Include secrets in Jira comments.
- Include secrets in Pull Request descriptions.
- Commit `.env` files containing secrets.
- Paste tokens into source files.
- Copy credentials into documentation.
- Include secrets in screenshots or artifacts.

When a secret is accidentally exposed:
1. Stop.
2. Do not repeat the value.
3. Report that a secret was exposed without showing it.
4. Determine whether rotation or removal is required.
5. Ask for approval before any action that requires human authority.

Evidence:
Report only masked information, for example:

`JIRA_API_TOKEN: present, value not shown.`

or:

`A credential was detected in the proposed diff.`

## GR-DESTRUCTIVE-001 — Protect against destructive actions

Severity:
BLOCK

Rule:
Agents must not perform destructive actions that can remove data, code,
history, access, or shared work without explicit approval.

Trigger:
An action can:

- Delete data.
- Delete branches or files.
- Rewrite Git history.
- Force-push.
- Reset commits.
- Replace shared configuration.
- Remove access or permissions.
- Permanently modify shared resources.

Required action:
1. Stop before the destructive action.
2. Explain what will change.
3. Explain what can be lost or affected.
4. Ask for explicit user approval.
5. Proceed only after approval.

Forbidden action:
Do not automatically run commands such as:

- `git reset --hard`
- `git push --force`
- `git push --force-with-lease`
- `git branch -D`
- `rm -rf`
- destructive database commands
- irreversible data deletion
- permission removal

Do not use a destructive action merely because it is faster.

Safe alternative:
Prefer a non-destructive alternative when one exists.

Examples:

- Create a new branch instead of rewriting a shared branch.
- Preserve existing commits instead of resetting history.
- Back up data before a destructive migration.
- Revoke access only after confirming the target.

Evidence:
Before approval, report:

Action:
<exact action>

Reason:
<why it is needed>

Potential impact:
<what can be lost or changed>

Alternative:
<safe alternative, if available>

## GR-SCOPE-002 — Prevent cross-work contamination

Severity:
BLOCK

Rule:
Agents must not silently include work from another Jira Story, Task, branch,
Pull Request, or unrelated workstream in the current task.

Trigger:
The agent detects code, commits, files, requirements, or design work that
belongs to another Jira issue or another active workstream.

Required action:
1. Identify the other work.
2. Determine whether it is required by the current task.
3. Keep unrelated work separate.
4. Stop when the work cannot be safely separated.
5. Report the affected Jira issue, branch, commit, or Pull Request.

Forbidden action:
Do not silently:

- Copy another Story's implementation into the current Story.
- Include another Story's commits in the current PR.
- Base a new Story branch on another feature branch without an explicit
  dependency.
- Mix unrelated changes into the current commit.
- Reuse another Story's unfinished implementation as though it belongs to the
  current Story.
- Remove another Story's work to make the current branch clean.

Dependency exception:
If the current Story depends on another Story:

- Identify the dependency explicitly.
- Preserve the parent Story's work.
- Keep the dependency visible in the implementation and PR plan.
- Do not present the dependent Story as independent when it is not.

Branch safety:
Before creating a Pull Request, compare the source branch with the target
branch.

If commits from another Jira Story are present:

- Identify those commits.
- Determine why they are present.
- Stop when they are not an intentional dependency.
- Do not create the Pull Request until the contamination is corrected or
  explicitly approved.

Evidence:
Report the exact evidence, such as:

- Jira issue key
- Branch name
- Commit hash
- Commit ancestry
- Conflicting file
- Pull Request number

## Decision Boundaries

Use `GR-APPROVAL-001` and `GR-DESTRUCTIVE-001` for approval gates; `GR-SCOPE-002` for contamination stop.

## Exceptions

Exceptions are per-rule `Exception:` (or `Dependency exception` where noted). If none, `Exception: None.`

## Enforcement

Agent instructions > tool permissions > hooks (secret scan, branch-ancestry check) > CI > human approval per `policies/security.md` and `policies/git-safety.md`.

## Verification

Verify via Jira read-back, git ancestry (`git log target..source`), diff review, scan results. Do not claim isolation without `git merge-base` evidence per GR-SCOPE-002.

## Relationship to Other Policies

- `security.md` for security and data protection.
- `verification.md` for verification requirements and evidence.
- `git-safety.md` for Git safety.
- `dependency-safety.md` for dependency safety.
- `web-best-practices.md` for web app best practices.
- `observability.md` for factory execution records.

## Self-Improvement

Review violations of GR-* for ambiguous triggers, missing enforcement, or repeated manual ancestry checks; propose hook/CI only with evidence.
