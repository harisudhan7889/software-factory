---
name: screenshot
description: Starts or reuses a local web application and captures the actual rendered UI with the factory-owned Playwright capture scripts at a specified viewport. Returns the screenshot with basic metadata for visual verification. Use when implementation or verification needs evidence of the rendered UI. Do not judge visual fidelity, modify application code, or replace the approved design source.
---

# Screenshot

## Purpose

Capture the **actual rendered web application** so other factory workflows can
verify what the user sees. The skill answers "what does the running app look
like at this viewport?" It does not answer "does it match the approved design?"
Visual comparison belongs to the verification workflow.

The skill owns the capture workflow through the factory scripts. The script
starts or reuses the local app, waits until it is reachable, drives Playwright
+ Chromium to capture the UI, and cleans up only the process it started.

```text
screenshot skill → scripts/capture.sh → scripts/capture.mjs → Playwright + Chromium → rendered screenshot
```

No Playwright MCP server is needed.

## When to Use

Use when an implementation needs rendered-UI evidence, a Stitch design must be
compared with the running app, a UI Story requires visual verification, a
browser screenshot is needed as evidence, or the local app must be started
before capture.

Do not use when the target project has no web application, no target viewport
is available, the task is to implement or modify UI, create or approve a
design, or decide whether two images match, or when the factory scripts are
missing or unusable.

## Inputs

Required: a target project root or an already-running URL, plus viewport width
and height. If the viewport is not given, use the one the calling workflow
requires, otherwise ask. Never invent a design viewport.

Optional: route, screenshot and metadata output paths, wait condition,
interaction steps to reach the target state, explicit startup command or
script name, target URL or port, readiness timeout, and `--keep-app` when the
caller needs the started app to keep running.

## Workflow

1. Determine the project, URL, route, state, and viewport.
2. Invoke `scripts/capture.sh` (see Invocation) with the project or URL, viewport, and route.
3. If the app is not running, `capture.sh` discovers and starts an existing project startup command and waits for readiness.
4. `capture.mjs` captures the rendered page.
5. Return the screenshot reference and the script's metadata.
6. Unless `--keep-app` was requested, the script stops only the process it started. Never terminate a process the script did not start.

Do not reimplement browser automation in prose.

## Application Startup

The script discovers an existing project startup command (for example the
`dev`, `start`, or `preview` script in `package.json`; the project's actual
configuration is authoritative). Never create or modify a startup script just
for capture.

- **Parallel agents and worktrees:** run the script from the current worktree and treat it as the project boundary. Do not reuse another worktree's server unless its identity is established, use a project-supported port, and never take over a port held by another process.
- **Already running:** pass `--url`; do not start another instance or stop the existing one.
- **Startup failure:** if `capture.sh` reports `Status: BLOCKED`, do not claim a screenshot was captured. Report the script's reason exactly and stop.

## Exact Target State

A screenshot is evidence only if it shows the correct state. Record URL,
viewport, route, state, and interaction steps, and never capture a different
route or state because it is easier to reach.

Capture each requested viewport separately (for example desktop 1440x900,
tablet 1024x768, mobile 390x844). Do not claim responsive fidelity from one
viewport. Preserve the screenshot as a project or temporary evidence artifact
as the calling workflow requires.

For Stitch-based verification, this skill only captures the implementation.
The approved Stitch screenshot comes from `stitch-handoff`, and the
verification workflow compares the two.

## Browser Capability

Playwright via the factory scripts is the standard mechanism, and the scripts
manage their own Playwright runtime and Chromium. Do not add Playwright as a
project dependency just for capture, and do not require a project Playwright
or Cypress harness. A project test harness may prepare a specific
authenticated or application state only when the calling workflow explicitly
requires it.

Never substitute HTML inspection, DOM-only inspection, generated Stitch code,
a static HTML file, or inference from source code for a real browser
screenshot. If the scripts are missing or cannot run, report the following and
do not fall back to code inspection or claim visual verification:

```text
Status: BLOCKED
Reason: Factory screenshot scripts are unavailable or unusable.
```

## Browser Safety

Do not submit real payments, send real emails, modify production data, perform
destructive actions, expose secrets, or bypass authentication improperly. For
authenticated states use approved test credentials or the project's configured
testing mechanism.

## Invocation

```bash
# Project not running
scripts/capture.sh --project <PROJECT_ROOT> --viewport <WIDTH>x<HEIGHT> --route <ROUTE>

# Application already running
scripts/capture.sh --url <URL> --viewport <WIDTH>x<HEIGHT> --route <ROUTE>
```

Optional arguments: `--output <FILE>`, `--metadata-output <FILE>`,
`--startup-script <NAME>`, `--startup-command <CMD>`, `--timeout <MS>`,
`--wait-ms <MS>`, `--wait-for-selector <CSS>`, `--state <LABEL>`,
`--full-page`, `--keep-app`, `--no-start`. Use only what the calling workflow
needs. The script may install its factory-managed Playwright and Chromium on
first use; do not install browser tooling into the project.

## Verification

Before reporting a screenshot as complete:

- [ ] The factory script and the Playwright capture ran successfully.
- [ ] The URL was reachable. If the app was not running, the script used an existing project startup command and recorded its PID.
- [ ] The requested viewport, route, and state were used, and the screenshot was actually captured.
- [ ] URL, viewport, route, and state were recorded.
- [ ] Only a process the script started was stopped during cleanup.
- [ ] No production data was modified and no secrets were exposed.

## Output

```text
Screenshot

Status:
PASS | BLOCKED | FAILED

URL:
<url>

Viewport:
<width>x<height>

Route:
<route>

State:
<state>

Screenshot:
<path/reference>

Notes:
<optional>
```

Status follows the script's exit definitions: PASS = screenshot captured,
BLOCKED = precondition or startup unavailable, FAILED = the capture attempt
failed. Do not use FAILED for unreachable preconditions.

## Boundaries

Flow: `stitch-handoff` supplies the approved target screenshot,
`implementation` produces the running app, this skill captures the actual
screenshot, and verification compares them. This skill does not replace UX, UI
Design, Stitch, `stitch-handoff`, implementation, or verification.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The page probably looks fine; skip the capture." | The skill exists to produce evidence of the rendered UI, not assumptions. |
| "I'll judge visual fidelity from the screenshot too." | Judging fidelity belongs to the verification workflow. |
| "Fix the UI bug I just saw." | This skill does not modify application code. |

## Red Flags

- A screenshot was reported without viewport metadata.
- Capture used ad-hoc commands instead of the factory capture scripts.
- A server was left running after capture.

## Self-Improvement

Follow `../self-improvement/references/standard.md`. Propose changes only when
real projects show repeatable evidence that capture is missing a capability or
causing recurring reliability problems.
