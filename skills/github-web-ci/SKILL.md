---
name: github-web-ci
description: "Provisions the minimum required GitHub CI workflows for a web application. Use during GitHub repository provisioning or when standard web-app PR checks need to be added. Detects available project commands and creates separate workflows for applicable checks: typecheck, lint, tests, production build, secret scanning, and critical end-to-end smoke tests. Do not invent missing scripts, change application behavior, or deploy the application."
---

# GitHub Web CI

## Purpose

Provision a small, reliable set of GitHub CI workflows for web applications.

Each applicable check should have its own workflow file:

```text
.github/workflows/
├── typecheck.yml
├── lint.yml
├── test.yml
├── build.yml
├── security.yml
└── e2e.yml
```

The workflows should run on pull requests to the project's protected/default branch.

Dependency installation is a prerequisite inside each workflow that needs it. It is not a separate standalone CI workflow.

## When to Use

Use when:

- a new web application repository is being provisioned
- GitHub CI is being added to an existing web application
- the factory needs to install its standard web-app PR checks

Do not use for:

- mobile applications
- deployment-only workflows
- changing application code to make CI pass
- broad performance/security benchmarking
- replacing project-specific CI requirements from an approved RFC/ADR

## Inputs

Inspect:

- repository root
- package manager and lockfile
- `package.json`
- available scripts
- test configuration
- E2E configuration such as Playwright or Cypress
- existing `.github/workflows/`
- existing GitHub CI configuration
- approved project RFC/ADR when CI requirements are project-specific

## Standard Workflow Set

### 1. Typecheck

Workflow:

```text
.github/workflows/typecheck.yml
```

Run the existing typecheck command when one exists.

Example:

```text
npm run typecheck
```

Do not invent a new typecheck script during provisioning.

If no typecheck command exists, do not create `typecheck.yml`. Report:

```text
NOT AVAILABLE — no project typecheck command detected
```

### 2. Lint

Workflow:

```text
.github/workflows/lint.yml
```

Run the existing lint command when one exists.

Example:

```text
npm run lint
```

Do not invent a new lint command during provisioning.

If no lint command exists, do not create `lint.yml`. Report:

```text
NOT AVAILABLE — no project lint command detected
```

### 3. Unit / Component Tests

Workflow:

```text
.github/workflows/test.yml
```

Run the project's existing automated test command when one exists.

Examples:

```text
npm test
npm run test:unit
```

Prefer the project's configured test command over guessing a framework-specific command.

If no automated test command exists, do not create `test.yml`. Report:

```text
NOT AVAILABLE — no project test command detected
```

### 4. Production Build

Workflow:

```text
.github/workflows/build.yml
```

For a web application, the production build is a required baseline check.

Run the project's existing production build command.

Example:

```text
npm run build
```

A production build command must exist.

Do not modify application code merely to create a build command.

If the build command is missing, provisioning is `BLOCKED` and no incomplete build workflow should be written.

### 5. Secret Scan

Workflow:

```text
.github/workflows/security.yml
```

Run the factory's approved secret scanner.

The factory currently uses Gitleaks.

The workflow should run a repository secret scan independently of local developer hooks.

Do not expose secrets in workflow logs.

### 6. Critical E2E / Smoke Test

Workflow:

```text
.github/workflows/e2e.yml
```

Run the project's existing critical browser test suite when one exists.

Examples:

```text
npm run test:e2e
npx playwright test
```

The suite should focus on critical user paths rather than attempting to test every screen.

Do not invent E2E tests during CI provisioning.

If no E2E suite exists, do not create `e2e.yml`. Report:

```text
NOT AVAILABLE — no existing critical E2E/smoke test detected
```

Do not silently mark missing E2E coverage as PASS.

## Dependency Installation

Each workflow that needs project dependencies must:

1. detect the package manager
2. use the project's lockfile
3. install dependencies deterministically

Examples:

```text
npm ci
pnpm install --frozen-lockfile
yarn install --immutable
```

Do not select a package-manager command by assumption.

Do not create a separate `install.yml` workflow because installation is a prerequisite of the checks, not an independent quality gate.

## Runtime Detection

Before writing workflows:

1. Detect the runtime version source from:
   - `.nvmrc`
   - `.node-version`
   - `package.json` engines
   - `package.json` Volta configuration
2. If no runtime version source exists, report:
   `NOT AVAILABLE — runtime version source not detected`
3. Do not invent a project runtime version.
4. The generated workflow may pin an explicit runtime only when the detected project configuration supports that choice.

## Detection Rules

Before writing CI:

1. Detect the package manager.
2. Read `package.json`.
3. Detect available scripts.
4. Detect existing test and E2E configuration.
5. Detect the runtime version source.
6. Inspect existing GitHub workflows.
7. Reuse existing project commands and infrastructure where possible.
8. Determine which standard gates are available.
9. Generate only the required workflow files.

Do not replace an existing working workflow merely to match the factory template.

## Workflow Trigger

Every generated standard web CI workflow should use pull requests only:

```yaml
on:
  pull_request:
```

The workflow should target the project's actual protected/default branch when branch filtering is required.

Do not add a `push` trigger for these standard CI workflows.

Do not assume `main`.

## Workflow Structure

Each workflow should be independently understandable and independently reportable.

Typical structure:

```text
Pull Request
   ├── typecheck
   ├── lint
   ├── test
   ├── build
   ├── security
   └── e2e
```

The workflows may run in parallel unless the project has a documented reason to sequence them.

Do not create an artificial dependency between CI workflows merely because they share dependency installation.

## Existing Workflow Safety

Before creating or changing `.github/workflows/*.yml`:

- inspect existing workflows
- avoid duplicate workflows or duplicate checks
- preserve useful existing checks
- do not remove project-specific required checks without evidence
- report conflicts instead of silently replacing workflows

If an existing workflow already provides a required check:

- reuse it when appropriate
- do not create a duplicate workflow
- report the reused workflow

## Failure Behavior

A required check must fail its workflow when the command fails.

Do not convert failures to warnings simply to make CI green.

A missing optional capability should be reported as:

```text
NOT AVAILABLE
```

rather than fabricated as a successful check.

The production build is required. If its prerequisite configuration is missing, report:

```text
BLOCKED
```

and do not create a misleading build workflow.

## E2E Environment

Critical E2E tests may require secrets, service URLs, or test accounts.

Use GitHub Actions secrets or the project's approved secret mechanism.

Never commit:

- credentials
- API tokens
- test passwords
- service-role keys
- `.env` files containing secrets

Do not print secret values in CI logs.

## Security

Follow the factory security and Git safety policies.

At minimum:

- use least privilege for GitHub Actions permissions
- keep repository checkout and actions pinned according to factory policy
- do not expose secrets
- do not execute untrusted pull-request code with privileged secrets
- keep CI changes scoped to the repository
- fail closed when required CI configuration is missing or unsafe

## Verification

After provisioning:

- [ ] Every generated workflow is valid YAML.
- [ ] Every generated workflow uses `pull_request` only.
- [ ] No generated standard workflow uses a `push` trigger.
- [ ] The detected package manager matches the lockfile.
- [ ] Existing project commands were used where available.
- [ ] Typecheck workflow is included when available.
- [ ] Lint workflow is included when available.
- [ ] Unit/component test workflow is included when available.
- [ ] Production build workflow is included.
- [ ] Gitleaks security workflow is included.
- [ ] Critical E2E/smoke workflow is included when an existing suite is available.
- [ ] No duplicate workflow was created unnecessarily.
- [ ] No application code was changed just to satisfy CI.
- [ ] No secrets were added.
- [ ] Every workflow targets the actual repository protected/default branch when filtering is used.
- [ ] Missing optional capabilities are reported honestly.
- [ ] Missing required build configuration is reported as BLOCKED.

## Output

Report:

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
- Typecheck: available / not available
- Lint: available / not available
- Tests: available / not available
- Build: available / missing
- Gitleaks: configured
- E2E/smoke: available / not available

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

Legend:
PASS = all applicable required workflows were created or reused and verified.
PARTIAL = required workflows are valid, but one or more optional capabilities are NOT AVAILABLE.
BLOCKED = a required build/configuration prerequisite is missing or unsafe, so the required workflow set could not be completed.
FAILED = workflows were written but verification failed.
```

## Scope Control

This skill must not:

- change application requirements
- create Jira tickets
- modify the RFC
- modify ADRs
- rewrite application code
- weaken CI failures
- deploy production
- change branch protection without explicit authorization
- invent missing test commands
- add push-triggered standard CI workflows

If CI cannot be provisioned safely from existing project configuration, stop and report the blocker.

## Relationship to Other Factory Work

```text
Project / GitHub provisioning
        ↓
github-web-ci
        ↓
.github/workflows/*.yml
        ↓
GitHub PR checks
        ↓
verification / PR / merge
```

The CI workflows are evidence.

They are not a replacement for local verification, implementation review, or PR review.

## Self-Improvement

Follow the common self-improvement standard.

Only propose changes to this skill when real projects provide repeatable evidence that the baseline CI is missing an important web-app check or is creating recurring unnecessary complexity.

Follow the common self-improvement standard in:

`../self-improvement/references/standard.md`
