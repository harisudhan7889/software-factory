---
name: github-web-ci
description: "Provisions the minimum required GitHub CI workflows for a web application. Use during GitHub repository provisioning or when standard web-app PR checks need to be added. Detects available project commands and creates separate workflows for applicable checks: typecheck, lint, tests, production build, secret scanning, and critical end-to-end smoke tests. Do not invent missing scripts, change application behavior, or deploy the application."
---

# GitHub Web CI

## Purpose

Provision a small, reliable set of GitHub CI workflows for web applications.
Each applicable check gets its own file under `.github/workflows/`
(`typecheck.yml`, `lint.yml`, `test.yml`, `build.yml`, `security.yml`,
`e2e.yml`) and runs on pull requests to the project's protected/default
branch. Dependency installation is a prerequisite inside each workflow that
needs it, never a standalone workflow or quality gate (no `install.yml`).

## When to Use

Use when a new web application repository is being provisioned, GitHub CI is
being added to an existing web application, or the factory needs its standard
web-app PR checks.

Do not use for mobile applications, deployment-only workflows, changing
application code to make CI pass, broad performance or security benchmarking,
or replacing project-specific CI requirements from an approved RFC/ADR.

## Inputs

Inspect the repository root, package manager and lockfile, `package.json` and
its scripts, test configuration, E2E configuration (Playwright or Cypress),
existing `.github/workflows/` and CI configuration, and the approved RFC/ADR
when CI requirements are project-specific.

## Detection

Before writing any workflow:

1. Detect the package manager and read `package.json` for available scripts.
2. Detect existing test and E2E configuration.
3. Detect the runtime version source from `.nvmrc`, `.node-version`, `package.json` engines, or Volta configuration. If none exists report `NOT AVAILABLE — runtime version source not detected`. Never invent a runtime version; pin one only when project configuration supports it.
4. Inspect existing GitHub workflows and reuse existing commands and infrastructure.
5. Decide which standard gates are available and generate only those workflow files.

Do not replace an existing working workflow just to match the factory template.

## Standard Workflow Set

Run the project's existing command for each gate. Never invent scripts,
commands, or tests during provisioning, and prefer the project's configured
command over a guessed framework command.

| Workflow | Runs | If missing |
|---|---|---|
| `typecheck.yml` | existing typecheck command (e.g. `npm run typecheck`) | Skip the file; report `NOT AVAILABLE — no project typecheck command detected` |
| `lint.yml` | existing lint command (e.g. `npm run lint`) | Skip the file; report `NOT AVAILABLE — no project lint command detected` |
| `test.yml` | existing unit/component test command (e.g. `npm test`, `npm run test:unit`) | Skip the file; report `NOT AVAILABLE — no project test command detected` |
| `build.yml` | existing production build command (e.g. `npm run build`); a required baseline for web apps | Provisioning is `BLOCKED`; write no incomplete build workflow; do not modify app code to create the command |
| `security.yml` | the factory's approved secret scanner (currently Gitleaks), independent of local hooks; never expose secrets in logs | Always provisioned |
| `e2e.yml` | existing critical browser suite (e.g. `npm run test:e2e`, `npx playwright test`) focused on critical user paths | Skip the file; report `NOT AVAILABLE — no existing critical E2E/smoke test detected`; never mark missing E2E coverage as PASS |

## Dependency Installation

Each workflow that needs dependencies must detect the package manager, use the
project's lockfile, and install deterministically (`npm ci`,
`pnpm install --frozen-lockfile`, `yarn install --immutable`). Do not choose a
package-manager command by assumption.

## Triggers and Structure

Use pull requests only (`on: pull_request`), filtered to the project's actual
protected/default branch when filtering is needed. Do not assume `main` and do
not add a `push` trigger to these workflows.

Each workflow must be independently understandable and reportable. They may
run in parallel; do not create dependencies between them just because they
share dependency installation.

## Existing Workflow Safety

Before creating or changing `.github/workflows/*.yml`: inspect existing
workflows, avoid duplicate workflows or checks, preserve useful existing
checks, and do not remove project-specific required checks without evidence.
If an existing workflow already provides a required check, reuse it and report
it instead of creating a duplicate. Report conflicts instead of silently
replacing workflows.

## Failure Behavior

A required check must fail its workflow when its command fails. Never convert
failures to warnings to make CI green. Report a missing optional capability
as `NOT AVAILABLE`, never as a successful check. Report a missing required
build configuration as `BLOCKED`.

## E2E Environment and Security

Critical E2E tests may need secrets, service URLs, or test accounts. Use
GitHub Actions secrets or the project's approved secret mechanism. Never commit
credentials, API tokens, test passwords, service-role keys, or `.env` files
with secrets, and never print secret values in CI logs.

Follow the factory security and Git safety policies. At minimum: use least
privilege for Actions permissions, pin checkout and actions per factory
policy, never run untrusted pull-request code with privileged secrets, keep CI
changes scoped to the repository, and fail closed when required configuration
is missing or unsafe.

## Verification

After provisioning:

- [ ] Every generated workflow is valid YAML, uses `pull_request` only, and has no `push` trigger.
- [ ] The detected package manager matches the lockfile, and existing project commands were used where available.
- [ ] Typecheck, lint, and test workflows are included when available; the build and Gitleaks workflows are included; e2e is included when a suite exists.
- [ ] No duplicate workflow was created, no application code was changed to satisfy CI, and no secrets were added.
- [ ] Each workflow targets the real protected/default branch when filtering is used.
- [ ] Missing optional capabilities are reported honestly, and missing build configuration is reported as BLOCKED.

## Output

```text
GitHub Web CI

Workflows:
- .github/workflows/typecheck.yml — created / reused / NOT AVAILABLE
- .github/workflows/lint.yml — created / reused / NOT AVAILABLE
- .github/workflows/test.yml — created / reused / NOT AVAILABLE
- .github/workflows/build.yml — created / reused / BLOCKED
- .github/workflows/security.yml — created / reused
- .github/workflows/e2e.yml — created / reused / NOT AVAILABLE

Detected:
- Package manager: ...
- Runtime version source: ...
- Typecheck / Lint / Tests / E2E: available / not available
- Build: available / missing
- Gitleaks: configured

Existing workflows reused:
- ...

Not available:
- ...

Blockers:
- ...

Verification:
- ...

Result:
PASS / PARTIAL / BLOCKED / FAILED
```

- `PASS`: all applicable required workflows were created or reused and verified.
- `PARTIAL`: required workflows are valid, but one or more optional capabilities are NOT AVAILABLE.
- `BLOCKED`: a required build or configuration prerequisite is missing or unsafe.
- `FAILED`: workflows were written but verification failed.

## Scope Control

This skill must not change application requirements, create Jira tickets,
modify the RFC or ADRs, rewrite application code, weaken CI failures, deploy
production, change branch protection without explicit authorization, invent
missing test commands, or add push-triggered standard CI workflows. If CI
cannot be provisioned safely from existing configuration, stop and report the
blocker. CI workflows are evidence; they do not replace local verification,
implementation review, or PR review.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "No lint script exists, so add one." | This skill never invents scripts; skip that workflow and report it. |
| "Merge all checks into one workflow." | Separate workflows give per-check status and clearer failures. |
| "Add a deploy step while here." | Deployment is out of scope. |

## Red Flags

- A workflow runs a command that does not exist in `package.json`.
- Secrets appear in workflow files or logs.
- Application code was changed.

## Self-Improvement

Follow `../self-improvement/references/standard.md`. Propose changes only when
real projects show repeatable evidence that baseline CI misses an important
web-app check or creates recurring unnecessary complexity.
