# Verification Policy

## Purpose

Define what the software factory must verify before it reports work as
complete.

Verification must produce evidence.

An agent must not claim that work passed, succeeded, or is complete without
evidence that supports the claim.

## Scope

Applies to all factory work that reports completion — Jira Stories, PRs, builds, tests, security, UI, Git, and CI. All verification must match the change.

## Verification Principles

Apply these principles:

1. Verify the actual result, not only the intended change.
2. Use the smallest sufficient verification set.
3. Prefer direct evidence.
4. Verify at the correct level.
5. Report failures and unknowns clearly.
6. Never turn "not run" into "passed".
7. Do not hide skipped checks.
8. Re-run relevant checks after a corrective change.

## Verification Levels

Use the level required by the current task.

### Level 1 — Static verification

Use when appropriate:

- File existence
- Configuration validation
- Formatting
- Schema validation
- Static analysis

### Level 2 — Code verification

Use when code changes exist:

- Unit tests
- Integration tests
- Typecheck
- Lint
- Build

### Level 3 — System verification

Use when the change affects multiple components:

- End-to-end tests
- Service integration
- Database behavior
- Authentication
- Authorization
- Tenant isolation
- External service integration

### Level 4 — Delivery verification

Use for delivery workflows:

- Commit exists
- Correct branch
- Pull Request exists
- CI status is known
- Jira update is confirmed

Do not run every possible level for every change. Run all checks required by
the change and project rules.

## Acceptance Criteria

For Jira implementation work:

1. Read the acceptance criteria.
2. Map each criterion to an implementation or verification result.
3. Verify every applicable criterion.
4. Report any criterion that is not verified.

Use:

```text
Acceptance criteria:
- AC1: PASS — <evidence>
- AC2: PASS — <evidence>
- AC3: NOT VERIFIED — <reason>
```

Do not mark the Jira Story complete when required acceptance criteria remain
unverified.

## Tests

When tests apply:

- Run the relevant tests.
- Use the project's normal test command.
- Prefer focused tests for the changed area.
- Run broader tests when the change can affect other areas.
- Report the actual result.

Example:

```text
Tests:
- Unit: 24 passed
- Integration: 8 passed
```

Do not report:

```text
Tests: passed
```

when tests were not run.

## Build

When a build is relevant:

- Run the project's build command.
- Confirm the command completed successfully.
- Record the relevant result.

A successful typecheck is not proof that the production build succeeds.

A local build is not proof that GitHub Actions succeeds.

## Lint

When linting is part of the project workflow:

- Run the project's lint command.
- Report pass, failure, or not run.
- Do not hide warnings that affect the acceptance decision.

## Typecheck

When a typed project requires typechecking:

- Run the project's typecheck command.
- Report the actual result.
- Do not assume a successful build means typechecking was independently
  verified unless the build includes that check.

## UI Verification

For UI Stories:

1. Read the approved UX specification.
2. Read the approved UI design specification.
3. Inspect the approved external design artifact (evidence: artifact URL + inspection notes).
4. Verify the implementation against the approved design.

Check for all UI Stories:

- Screen structure
- Layout
- Visual hierarchy
- Components
- States
- Interaction behavior
- Responsive behavior
- Accessibility requirements
- Design-system usage

Exception: External artifact may be skipped only when no approved artifact exists — evidence: `NOT APPLICABLE — no artifact`.

Functional tests alone are not sufficient to verify visual design.

Do not claim design compliance when the design was not inspected.

## Security Verification

For security-sensitive changes, run the relevant security checks.

Examples:

- Authentication tests
- Authorization tests
- RLS tests
- Tenant isolation tests
- Secret scanning
- Dependency security checks
- Permission checks

Use the project's security policy to determine the required controls.

Do not report a security-sensitive implementation as verified when a required
security check was not completed.

## RFC and ADR Verification

When an implementation is governed by an approved RFC or ADR:

- Verify the implementation against the applicable requirements.
- Verify that accepted architectural decisions were followed.
- Identify deviations.

If a deviation is intentional:

- Record the reason.
- Verify that the required approval exists.

Do not silently treat an architecture deviation as compliant.

## Jira Verification

For Jira operations, verify the actual Jira state.

Examples:

```text
Issue:
ADVERIFY-88

Update:
Description updated — confirmed

Comment:
Added — confirmed

Transition:
In Review — confirmed
```

Do not claim a Jira update succeeded only because the command returned without
an obvious error.

Re-read the issue to confirm the state persisted.

## Git Verification

Before reporting a commit or branch operation as complete:

- Verify the current branch.
- Verify the expected commit exists.
- Verify the working tree state.
- Inspect the final diff when relevant.
- Verify the remote state after a push.

Do not claim a push succeeded without confirmation.

## Pull Request Verification

Before reporting Pull Request delivery as complete:

Verify:

- Correct repository
- Correct source branch
- Correct target branch
- Pull Request exists
- Jira reference is correct when required
- Description is present
- CI/check status is known

Separate these states:

```text
Pull Request:
Success

CI:
Failure
```

A successful Pull Request creation does not mean CI passed.

A `gh pr checks` permission error does not automatically mean CI failed.
Use an approved fallback: `gh run list` / workflow-run status — evidence: run URL and status.

## CI Verification

When CI is required:

- Inspect the relevant workflow run.
- Identify its status.
- Distinguish failure from access errors.
- Distinguish pending from success.
- Use the `pipeline-debug` workflow for a failed build or check when applicable.

Allowed states include:

- success
- failure
- pending
- cancelled
- neutral
- skipped
- no run
- unknown

Do not convert an unknown or inaccessible status into success.

## Evidence Requirements

Every completion claim should have supporting evidence.

Useful evidence includes:

- Command and exit status
- Test output
- Build output
- Lint output
- Typecheck output
- Git commit hash
- GitHub Pull Request URL
- CI run result
- Jira read-back
- Design artifact inspection
- Security scan result

Do not include secrets in verification evidence.

## Verification Status

Use explicit status values:

```text
PASS
FAIL
NOT RUN
NOT VERIFIED
BLOCKED
UNKNOWN
```

Meaning:

### PASS

The check ran and the required result was confirmed.

### FAIL

The check ran and did not satisfy the requirement.

### NOT RUN

The check was not executed.

### NOT VERIFIED

The check may have happened indirectly, but there is not enough evidence to
confirm the required result.

### BLOCKED

The check could not run because a required dependency, permission, or
decision is missing.

### UNKNOWN

The available evidence is insufficient to determine the result.

## Scope of Verification

Verification must match the change.

Do not create false confidence by running only unrelated tests.

For example:

```text
Changed:
Authentication

Required:
Authentication tests
Authorization tests
Typecheck
Relevant integration tests
```

Running only a formatting check is not sufficient.

## After a Fix

When a failed check is fixed:

1. Re-run the failed check.
2. Run relevant regression checks.
3. Verify that the original failure is gone.
4. Check for new failures.
5. Report both the original and regression results.

Do not declare the issue fixed after changing code without re-verification.

## Completion Gate

A task may be reported as complete only when:

- Required acceptance criteria are verified.
- Required tests pass.
- Required static checks pass.
- Required security checks pass.
- Required design checks pass for UI work.
- Relevant RFC/ADR requirements are satisfied.
- Required delivery checks are satisfied.
- No unresolved blocking issue remains.

If any required check is not verified:

- Do not report full completion.
- State the missing verification.
- State what blocks completion.

## Verification Report

Use:

```text
## Verification

Acceptance criteria:
- <criterion>: PASS — <evidence>

Tests:
- <test>: PASS/FAIL/NOT RUN — <result>

Build:
- PASS/FAIL/NOT RUN — <result>

Lint:
- PASS/FAIL/NOT RUN — <result>

Typecheck:
- PASS/FAIL/NOT RUN — <result>

Security:
- PASS/FAIL/NOT RUN — <result>

UI/Design:
- PASS/FAIL/NOT VERIFIED/NOT APPLICABLE — <result>

RFC/ADR:
- PASS/FAIL/NOT VERIFIED/NOT APPLICABLE — <result>

CI:
- PASS/FAIL/PENDING/UNKNOWN — <result>

Overall:
PASS / FAIL / PARTIAL / BLOCKED
```

## Decision Boundaries

Stop and ask when:

- Required verification cannot run (permission missing, environment unavailable) → `BLOCKED`.
- Evidence is insufficient to determine PASS/FAIL → `UNKNOWN` / `NOT VERIFIED`.
- Completion is requested but required acceptance criteria remain unverified → BLOCK per `## Completion Gate`.

## Exceptions

Exception: None. Skipped checks must be reported as `NOT RUN` with reason; do not convert to `PASS`. See `## Verification Status`.

## Enforcement

Automated: CI checks, `pipeline-debug` workflow, required status checks. Manual: checklists in `## Verification Report` and peer diff review. Policy does not substitute for technical enforcement.

## Separation of Concerns

Use:

- `policies/verification.md` for what must be verified.
- The relevant workflow for how to perform the work.
- Specialized skills for detailed diagnostics.
- CI and hooks for automated enforcement when available.

Do not duplicate entire verification workflows inside every skill.

## Relationship to Other Policies

Use `policies/guardrails.md` for approval and evidence reporting, `policies/security.md` for security verification, `policies/git-safety.md` for Git state verification.

## Self-Improvement

Review verification runs for:

- Missing checks
- False completion claims
- Repeated manual verification
- Checks that provide little value
- Important failures that were hard to detect
- Opportunities for automated enforcement

Only propose a factory change when real evidence shows that verification
should change for future runs.

Do not propose cosmetic or hypothetical changes.
