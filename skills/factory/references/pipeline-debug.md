---
name: pipeline-debug
description: Diagnose and safely resolve GitHub Actions CI, build, test, and pipeline failures using evidence from the failing run and the current project.
---

# Pipeline Debug Skill

This skill diagnoses and, when approved, fixes GitHub Actions CI and pipeline
failures.

It is intended for failures involving:

- Build jobs
- Test jobs
- Linting
- Type checking
- Integration tests
- Deployment checks
- Environment setup
- Dependencies
- Permissions
- CI configuration
- Service startup
- GitHub Actions configuration

The skill focuses on determining the actual failure before proposing or
making changes.

## Purpose

Given a failed GitHub Actions run or pipeline failure:

1. Identify the exact failing workflow, job, and step.
2. Collect the relevant failure evidence.
3. Determine the most likely root cause from evidence.
4. Classify the failure.
5. Determine whether the failure belongs to the current Jira Story.
6. Reproduce the problem locally when practical.
7. Propose the smallest appropriate fix.
8. Apply the fix only according to the implementation and approval rules.
9. Re-run relevant verification.
10. Report the result clearly.

Do not guess the root cause.

## Scope

This skill may diagnose:

- GitHub Actions workflow failures
- Build failures
- Test failures
- Lint failures
- Typecheck failures
- CI environment failures
- Service startup failures
- Dependency installation failures
- Permission failures
- Secret/configuration failures
- Pipeline configuration failures

This skill does not automatically:

- Change product requirements
- Change accepted architecture
- Expand Jira Story scope
- Modify production infrastructure without approval
- Merge Pull Requests
- Force-push
- Delete or rewrite repository history

## Inputs

Use the strongest available evidence.

Preferred inputs:

1. Failed GitHub Actions run
2. Pull Request
3. Jira Story/Bug associated with the PR
4. Workflow file
5. Relevant logs
6. Current repository state
7. Relevant RFCs and ADRs
8. Previous successful/failed runs when useful

If the user provides only an error message:

- Determine what additional evidence is available.
- Inspect the relevant CI run when accessible.
- Do not invent missing context.

## Phase 1 — Identify the failure

Determine:

- Repository
- Pull Request
- Workflow
- Run ID
- Branch
- Commit SHA
- Job
- Step
- Failure status
- Failure message

Report the exact failing location.

Example:

```text
Workflow: CI
Run: 32645524344
Job: tenancy-rls
Step: Export Supabase env
Commit: 1fe7d8d
Status: failure
```

Do not describe a workflow as generally "broken" when a specific failing
job or step can be identified.

## Phase 2 — Collect evidence

Collect the minimum evidence needed to determine the cause.

Inspect, when relevant:

- Failed-step logs
- Workflow configuration
- Environment setup steps
- Dependency versions
- Service startup sequence
- Test output
- Previous runs
- Related source files
- Configuration files

Prefer direct evidence over assumptions.

Never expose:

- API tokens
- Passwords
- Secrets
- Private keys
- Credential values

When reporting credential/configuration failures, use masked diagnostics.

## Phase 3 — Classify the failure

Classify the failure as exactly one primary category:

1. Application code failure
2. Test failure
3. Dependency failure
4. Build/toolchain failure
5. Configuration failure
6. Environment/service failure
7. Permission/authentication failure
8. GitHub Actions workflow failure
9. External service/platform failure
10. Unknown / insufficient evidence

If multiple categories are involved:

- Identify the primary failure.
- List secondary contributing failures separately.

Do not classify a failure as an application-code defect merely because the
pipeline stopped.

## Phase 4 — Determine root cause

For the primary failure, identify:

- Immediate failure
- Root cause
- Contributing factors
- Evidence

Use this structure:

```text
Failure:
<what failed>

Root cause:
<why it failed>

Evidence:
<direct evidence>

Contributing factors:
<optional>
```

Do not claim certainty when the evidence only supports a hypothesis.

When evidence is insufficient:

```text
Root cause:
Not yet established.

Current evidence:
<evidence>

Next diagnostic step:
<next step>
```

## Phase 5 — Check Jira scope

Identify the Jira issue associated with the failing Pull Request.

Determine whether the failure is:

### Current Story work

The failure is required to satisfy the current Story or was introduced by
the current implementation.

In this case:

- Include the fix in the current implementation.
- Do not create duplicate Jira work.

### Informational observation

The failure does not require action.

Record it and continue.

### Actionable follow-up work

The failure is real but outside the current Story.

In this case:

1. Explain why it is outside the current Story.
2. Report the proposed follow-up.
3. Ask the user whether a Jira item should be created.
4. Do not create the Jira item before explicit approval.
5. Do not expand the current Story silently.

### Unresolved decision

The failure requires a product, architectural, security, compliance, or
other explicit decision.

In this case:

- Stop before making the affected change.
- Explain the decision required.
- Ask the user.

## Phase 6 — Reproduce locally

When practical, reproduce the failure locally.

Prefer the smallest reproducible command.

Examples:

```text
npm test
npm run lint
npm run typecheck
supabase db reset
supabase status -o env
```

For CI-only failures:

- Reproduce the underlying condition rather than blindly reproducing the
  GitHub runner.
- Document meaningful differences between local and CI environments.

If local reproduction is impossible:

- Say so.
- Use CI evidence to continue diagnosis.
- Do not pretend the issue was reproduced locally.

## Phase 7 — Diagnose before modifying

Before proposing a fix:

1. Identify the exact failed behavior.
2. Determine whether the failure is caused by code, configuration,
   environment, dependency, permissions, or external infrastructure.
3. Inspect the current implementation/configuration.
4. Identify the smallest change that addresses the established cause.

Do not modify files merely to "see whether it works."

Do not apply speculative fixes.

## Phase 8 — Proposed fix

Before making changes, present:

```text
Pipeline Fix Proposal

Failure:
<failure>

Root cause:
<root cause>

Affected files:
<files>

Proposed change:
<exact change>

Why:
<why this addresses the root cause>

Verification:
<tests/checks to run>
```

Follow the normal implementation approval rules before modifying the
repository.

## Phase 9 — Implementation

When the fix is approved and belongs to the current Story:

- Follow the existing implementation workflow.
- Use the correct implementation branch.
- Preserve unrelated work.
- Change only the files required by the approved fix.
- Do not rewrite history.
- Do not force-push.
- Do not modify unrelated CI workflows.

If the fix belongs to a separate follow-up Jira issue:

- Do not implement it as part of the current Story unless explicitly
  approved.

## Phase 10 — CI-specific verification

After the fix:

Run relevant local verification where possible.

At minimum, when applicable:

- Build
- Test
- Lint
- Typecheck
- Relevant integration tests

Then push the approved change through the normal PR workflow.

Verify the new GitHub Actions run.

Do not report the CI failure as resolved until the relevant pipeline has
actually passed, unless the user explicitly requests another verification
strategy.

## Phase 11 — Regression review

After the pipeline passes:

Check that:

- The original failure is resolved.
- No unrelated jobs regressed.
- The fix addresses the established root cause.
- The workflow remains readable and maintainable.
- Secrets remain protected.
- No unnecessary configuration was changed.

## Phase 12 — Existing failure and retry behavior

When a GitHub Actions run is already failed:

- Inspect the existing run before triggering another run.
- Re-run only when useful for verification.
- Do not create duplicate Pull Requests.
- Do not create duplicate Jira issues.
- Do not claim a retry fixed the root cause unless the underlying cause is
  understood.

## Design-related pipeline failures

When the failing Story is a UI Story:

- Do not treat passing functional tests as sufficient if UI verification is
  required.
- Verify the implementation still follows the approved UX/UI design after
  resolving the pipeline failure.
- Do not remove UI verification merely to make CI pass.

## Self-Improvement

Follow the common self-improvement standard used by the software factory.

Review the run for:

- A missing diagnostic step
- A repeated CI failure pattern
- An inadequate failure classification
- A workaround that future runs should no longer require
- A misleading pipeline report
- A missing safety or verification rule

Only propose a factory change when real evidence shows that future pipeline
debugging runs should behave differently.

Do not propose cosmetic, hypothetical, or one-off changes.

## Final report

Report:

```text
Pipeline Debug Report

Repository:
<owner/repository>

Pull Request:
<number and URL>

Workflow:
<workflow>

Run:
<run ID>

Failure:
<job / step>

Root cause:
<root cause>

Classification:
<category>

Fix:
<what changed>

Verification:
<local results>

GitHub Actions:
<passed / failed / pending>

Jira:
<updated / unchanged / follow-up required>

Self-improvement:
<none identified / proposal / applied>

Result:
<success / partial / failed>
```

Never claim success when the relevant pipeline remains failed or pending.

## Decision boundaries

The skill must not silently:

- Expand Jira Story scope
- Change accepted architecture
- Modify unrelated code
- Change production secrets
- Force-push
- Rewrite Git history
- Merge a Pull Request
- Create follow-up Jira work without approval
- Suppress or ignore a genuine pipeline failure
- Mark a failed pipeline as successful

When uncertain, stop and ask.
