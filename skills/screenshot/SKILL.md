---
name: screenshot
description: Starts or reuses a local web application and captures the actual rendered UI with the factory-owned Playwright capture scripts at a specified viewport. Returns the screenshot with basic metadata for visual verification. Use when implementation or verification needs evidence of the rendered UI. Do not judge visual fidelity, modify application code, or replace the approved design source.
---

# Screenshot

## Purpose

Capture the **actual rendered web application** so other factory workflows can verify what the user sees.

This skill owns the capture workflow through the factory-owned scripts:

1. identify the target project and capture parameters
2. invoke `scripts/capture.sh`
3. let the script start or reuse the local application
4. let the script wait until the application is reachable
5. let the script use Playwright + Chromium to capture the requested UI
6. return the screenshot and evidence metadata
7. let the script clean up only the process it started

This skill is a screenshot capability.

It does not decide whether the rendered application matches a design.

## Responsibility

This skill answers:

> "What does the running web application actually look like at this viewport?"

It does not answer:

> "Does it match the approved design?"

Visual comparison belongs to the verification workflow.

## When to Use

Use when:

- an implementation needs rendered UI evidence
- a Stitch design needs to be compared with the running application
- a UI Story requires visual verification
- a browser screenshot is needed for evidence
- the local application needs to be started before capture

Do not use when:

- there is no web application in the target project
- no target viewport is available
- the task is to implement or modify UI
- the task is to create or approve a design
- the task is to decide whether two images match
- the factory-owned screenshot scripts are missing or unusable

## Inputs

Required:

- target project root, or an already-running web application URL
- target viewport width
- target viewport height

Optional:

- route/path
- screenshot output path
- metadata output path
- wait condition or page-load condition
- interaction/state instructions needed to reach the target state
- explicit startup command when the calling workflow already knows it
- existing startup script name
- explicit target URL/port
- readiness timeout
- `--keep-app` when the caller explicitly needs the started app to remain running

The factory-owned capture script is the execution mechanism.

When a running URL is provided and reachable, pass it to the script and do not
start a second copy.

When only a project root is provided, pass the project root to the script. The
script discovers an existing project startup command from the repository. The
skill must not invent or add a startup script.

If the target viewport is not specified, use the viewport explicitly required by the calling workflow when provided; otherwise ask for it. Do not invent a design viewport.

## Screenshot Workflow

Follow this order:

1. Determine the target project, URL, route, state, and viewport.
2. Locate the factory-owned script:
   `scripts/capture.sh`
3. Invoke the script with the required project/URL, viewport, and route.
4. If the application is not already running, allow `capture.sh` to discover
   and start an existing project startup command.
5. Allow the script to wait for application readiness.
6. Allow `capture.mjs` to drive Playwright + Chromium and capture the rendered page.
7. Return the screenshot path/reference and metadata produced by the script.
8. Unless the caller explicitly requests `--keep-app`, allow the script to clean
   up only the process it started.

The skill must not reimplement browser automation in prose or require an MCP
browser server when the factory capture scripts are available.

Do not kill or otherwise terminate an application process that the factory
capture script did not start.

## Application Startup

Application startup is executed by the factory-owned script:

`scripts/capture.sh`

The skill supplies the target project and any caller-known startup parameters.
The script is responsible for:

- discovering an existing project startup script
- starting the local app when required
- recording the started process
- waiting for readiness
- detecting the application URL when possible
- cleaning up only the process it started

### Existing project commands

The capture script may use an existing `package.json` script such as:

```text
dev
start
preview
```

These are examples only. The target project's actual configuration is
authoritative.

Never create or modify a startup script just for screenshot capture.

### Parallel agents and worktrees

For parallel agents:

- invoke the capture script from the current worktree
- treat the current worktree as the project boundary
- do not reuse another worktree's server unless its identity is explicitly
  established
- use a project-supported port when a port must be configured
- do not hijack an occupied port belonging to another process or worktree

### Already-running application

When the target URL is already reachable:

- pass `--url` to `capture.sh`
- do not start another application instance
- do not stop the existing process

### Application startup failure

If `capture.sh` reports:

```text
Status: BLOCKED
```

do not claim a screenshot was captured.

Report the script's reason exactly and stop the screenshot workflow.

## Exact Target State

A screenshot is only useful as visual evidence when the correct state is shown.

Record:

```text
URL:
Viewport:
Route:
State:
Interaction steps:
```

Do not capture a different route or state merely because it is easier to reach.

## Screenshot Evidence

Return the canonical `## Output` format below. Always include URL, viewport, route, state, screenshot path/reference, and Status.

When possible, preserve the screenshot as a project artifact or temporary evidence artifact according to the calling workflow.

## Stitch Verification Use

When called for Stitch-based visual verification:

```text
Approved Stitch screenshot
        +
Running application
        ↓
screenshot skill
        ├─ start/reuse local app
        └─ Playwright capture
        ↓
actual rendered screenshot
        ↓
verification compares them
```

This skill does not treat the Stitch screenshot as its own input authority. It
only captures the implementation.

The approved Stitch screenshot comes from `stitch-handoff`.

## Multiple Viewports

Capture each requested viewport separately.

Example:

```text
Desktop:
1440x900

Tablet:
1024x768

Mobile:
390x844
```

Do not claim responsive fidelity from a single viewport.

## Browser Capability

The factory-standard browser mechanism is Playwright executed by the
factory-owned scripts:

```text
scripts/capture.sh
scripts/capture.mjs
```

The intended execution path is:

```text
OpenCode
   ↓
screenshot skill
   ↓
scripts/capture.sh
   ↓
scripts/capture.mjs
   ↓
Playwright + Chromium
   ↓
actual rendered screenshot
```

OpenCode does not need a Playwright MCP server for this skill.

Do not substitute:

- HTML inspection
- DOM-only inspection
- generated Stitch code
- a static HTML file
- visual inference from source code

for an actual browser screenshot.

Do not require a project Playwright/Cypress harness when the factory capture
scripts are available. A project test harness may be used only for preparing a
specific authenticated or application state when the calling workflow
explicitly requires that setup.

The factory scripts manage their own Playwright runtime and Chromium
installation. Do not add Playwright as a project dependency solely for
screenshot capture.

If the factory scripts are missing or cannot execute, report:

```text
Status: BLOCKED
Reason: Factory screenshot scripts are unavailable or unusable.
```

Do not silently fall back to manual code inspection and do not claim visual
verification.

## Browser Safety

Do not:

- submit real payments
- send real emails
- modify production data
- perform destructive actions
- expose secrets
- bypass authentication controls improperly

For authenticated test states, use approved test credentials or the project's configured testing mechanism.

## Verification

Before reporting a screenshot as complete:

- [ ] The factory-owned screenshot script executed successfully.
- [ ] The Playwright browser capture completed successfully.
- [ ] The application URL was reachable.
- [ ] If the application was not already running, the factory script discovered
      and used an existing project startup command.
- [ ] If the factory script started the application, its PID was recorded.
- [ ] The requested viewport was used.
- [ ] The correct route was captured.
- [ ] The requested state was reached.
- [ ] The screenshot was actually captured.
- [ ] URL, viewport, route, and state were recorded.
- [ ] Only a process started by the factory capture script was stopped during
      cleanup.
- [ ] No production data was modified.
- [ ] No secrets were exposed.


## Factory Script Invocation

The screenshot skill invokes the factory-owned script:

```text
scripts/capture.sh
```

For a project that is not already running:

```bash
scripts/capture.sh \
  --project <PROJECT_ROOT> \
  --viewport <WIDTH>x<HEIGHT> \
  --route <ROUTE>
```

For an application that is already running:

```bash
scripts/capture.sh \
  --url <URL> \
  --viewport <WIDTH>x<HEIGHT> \
  --route <ROUTE>
```

Supported optional arguments include:

```text
--output <FILE>
--metadata-output <FILE>
--startup-script <NAME>
--startup-command <CMD>
--timeout <MS>
--wait-ms <MS>
--wait-for-selector <CSS>
--state <LABEL>
--full-page
--keep-app
--no-start
```

Use only the arguments required by the calling workflow.

The capture script may install its factory-managed Playwright runtime and
Chromium on first use. Do not install browser tooling into the project unless
the project itself explicitly requires it.

## Output

Keep the output simple:

```text
Screenshot

Status:
PASS | BLOCKED | FAILED

Use script exit definitions: PASS = screenshot captured, BLOCKED = precondition/startup unavailable, FAILED = capture attempt failed. Do not use FAILED for unreachable preconditions.

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

## Relationship to the Factory

```text
Stitch
   ↓
stitch-handoff
   ↓
approved target screenshot

implementation
   ↓
running application
   ↑
screenshot skill starts/reuses app

screenshot skill
   ↓
Playwright
   ↓
actual rendered screenshot

verification
   ↓
compare target vs actual
```

This skill is a reusable capture capability.

It does not replace:

- UX
- UI Design
- Stitch
- `stitch-handoff`
- implementation
- verification

## Self-Improvement

Follow the common self-improvement standard in:

`../self-improvement/references/standard.md`

Only propose changes to this skill when real projects provide repeatable evidence that screenshot capture is missing an important capability or creating recurring reliability problems.
