# Verification Policy

## Purpose

Define what the software factory must verify before it reports work as
complete. Verification must produce evidence. An agent must not claim that work
passed, succeeded, or is complete without evidence that supports the claim.

## Scope

Applies to all factory work that reports completion: Jira Stories, Pull
Requests, builds, tests, security, UI, Git, and CI. Verification must match the
change.

## Principles

1. Verify the actual result, not only the intended change.
2. Use the smallest sufficient verification set, at the correct level.
3. Prefer direct evidence.
4. Report failures and unknowns clearly.
5. Never turn "not run" into "passed", and do not hide skipped checks.
6. Re-run relevant checks after a corrective change.

## Rules

### VER-EVIDENCE-001 — Every claim has evidence

Severity:
BLOCK

Rule:
Every completion or success claim has supporting evidence and an explicit
status value.

Trigger:
An agent reports a check, build, test, push, Pull Request, Jira update, or CI
result.

Required action:
Report one status from the list below with the evidence.

Forbidden action:
Report `passed` for a check that was not run, convert an unknown or
inaccessible status into success, or include secrets in the evidence.

Exception:
None. Report a skipped check as `NOT RUN` with the reason.

Evidence:
Command and exit status, test, build, lint, or typecheck output, commit hash,
Pull Request URL, CI run result, Jira read-back, design artifact inspection, or
a security scan result.

### VER-COMPLETION-001 — Completion gate

Severity:
BLOCK

Rule:
A task is reported complete only when all of these hold:

- Required acceptance criteria are verified.
- Required tests, static checks, and security checks pass.
- Required design checks pass for UI work.
- Relevant RFC and ADR requirements are satisfied.
- Required delivery checks are satisfied.
- No unresolved blocking issue remains.

Trigger:
An agent is about to report full completion.

Required action:
If any required check is not verified, do not report full completion. State
the missing verification and what blocks completion.

Exception:
None.

Evidence:
The verification report below.

## Verification Status

Use these values:

- **PASS:** the check ran and the required result was confirmed.
- **FAIL:** the check ran and did not satisfy the requirement.
- **NOT RUN:** the check was not executed.
- **NOT VERIFIED:** the check may have happened indirectly, but the evidence cannot confirm the result.
- **BLOCKED:** the check could not run because a dependency, permission, or decision is missing.
- **UNKNOWN:** the evidence is insufficient to determine the result.

## Verification Levels

Use the level the task requires. Do not run every level for every change.

1. **Static:** file existence, configuration and schema validation, formatting, static analysis.
2. **Code:** unit and integration tests, typecheck, lint, build.
3. **System:** end-to-end tests, service integration, database behavior, authentication, authorization, tenant isolation, external services.
4. **Delivery:** commit exists, correct branch, Pull Request exists, CI status known, Jira update confirmed.

Verification must match the change. Running only unrelated tests or only a
formatting check gives false confidence. For an authentication change, run
authentication and authorization tests, typecheck, and relevant integration
tests.

## Check-Specific Rules

**Acceptance criteria.** Read the criteria, map each to an implementation or
verification result, verify every applicable one, and report any that are not
verified (`AC1: PASS — <evidence>`, `AC3: NOT VERIFIED — <reason>`). Do not mark
a Story complete while required criteria are unverified.

**Tests.** Run the project's normal test command, focused on the changed area,
and broaden it when other areas can be affected. Report actual counts such as
`Unit: 24 passed`.

**Build, lint, typecheck.** Run the project's command and report pass, fail, or
not run. A typecheck does not prove the production build succeeds, a build does
not prove typechecking unless it includes that check, and a local build does
not prove GitHub Actions succeeds. Do not hide warnings that affect the
acceptance decision.

**UI.** For UI Stories read the approved UX specification and UI design
specification, inspect the approved external design artifact (record the
artifact URL and inspection notes), and verify the implementation against it:
structure, layout, hierarchy, components, states, interaction, responsive
behavior, accessibility, and design-system usage. Functional tests alone do not
verify visual design, and design compliance cannot be claimed without
inspection. Record `NOT APPLICABLE — no artifact` only when no approved
artifact exists.

**Security.** For security-sensitive changes run the relevant checks
(authentication, authorization, RLS, tenant isolation, secret scan,
dependency checks, permission checks) as `security.md` requires. Do not report
the change verified when a required check is incomplete.

**RFC and ADR.** Verify the implementation against the applicable requirements
and accepted decisions, and identify deviations. For an intentional deviation,
record the reason and confirm the required approval. Never treat a deviation as
compliant silently.

**Jira.** Verify the actual Jira state by re-reading the issue, for example
`Description updated — confirmed`, `Transition: In Review — confirmed`. A
command returning without an obvious error is not confirmation.

**Git.** Verify the current branch, the expected commit, the working tree
state, and the final diff when relevant, and confirm the remote state after a
push. `git-safety.md` owns the Git rules.

**Pull Request.** Verify the repository, source and target branches, that the
Pull Request exists, the Jira reference when required, that a description is
present, and that CI status is known. Report these separately, for example
`Pull Request: Success`, `CI: Failure`. Creating a Pull Request does not mean CI
passed.

**CI.** Inspect the relevant workflow run. Distinguish failure from access
errors and pending from success. A `gh pr checks` permission error does not mean
CI failed. Use an approved fallback such as `gh run list` or workflow-run
status, and record the run URL and status. For a failed build or check, use the
pipeline-debug workflow. Allowed states are success, failure, pending,
cancelled, neutral, skipped, no run, and unknown.

## After a Fix

When a failed check is fixed:

1. Re-run the failed check and the relevant regression checks.
2. Confirm the original failure is gone and check for new failures.
3. Report the original and the regression results.

Do not declare an issue fixed after changing code without re-verification.

## Verification Report

```text
## Verification

Acceptance criteria:
- <criterion>: PASS — <evidence>

Tests / Build / Lint / Typecheck / Security:
- PASS/FAIL/NOT RUN — <result>

UI/Design, RFC/ADR:
- PASS/FAIL/NOT VERIFIED/NOT APPLICABLE — <result>

CI:
- PASS/FAIL/PENDING/UNKNOWN — <result>

Overall:
PASS / FAIL / PARTIAL / BLOCKED
```

## Decision Boundaries

Stop and ask when:

- Required verification cannot run (permission missing, environment unavailable). Status is `BLOCKED`.
- Evidence is insufficient to decide. Status is `UNKNOWN` or `NOT VERIFIED`.
- Completion is requested while required acceptance criteria remain unverified. `VER-COMPLETION-001` blocks.

## Exceptions

None. Skipped checks are `NOT RUN` with the reason and never become `PASS`.

## Enforcement

Automated: CI checks, the pipeline-debug workflow, and required status checks.
Manual: the verification report and peer diff review. Policy does not replace
technical enforcement.

## Verification

Compliance with this policy is shown by a verification report in which every
required check has a status and evidence, and by the absence of any completion
claim that lacks one.

## Relationship to Other Policies

This policy owns what must be verified. The relevant workflow owns how to do
the work, and specialized skills own detailed diagnostics. `security.md` owns
security, `git-safety.md` Git, `guardrails.md` agent behavior,
`dependency-safety.md` dependencies, `web-best-practices.md` web quality, and
`observability.md` execution records. Do not duplicate whole verification
workflows inside skills.

## Self-Improvement

Review verification runs for missing checks, false completion claims, repeated
manual verification, low-value checks, hard-to-detect failures, and chances to
automate. Propose a change only when real evidence shows future runs should
verify differently; no cosmetic or hypothetical changes.
