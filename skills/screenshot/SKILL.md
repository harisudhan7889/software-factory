---
name: screenshot
description: Captures screenshots of a running web application at a specified viewport and returns the image with basic metadata for visual verification. Use when implementation or verification needs evidence of the rendered UI. Do not judge visual fidelity, modify application code, or replace the approved design source.
---

# Screenshot

## Purpose

Capture the **actual rendered web application** so other factory workflows can verify what the user sees.

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

Do not use when:

- the application is not running
- no target URL is available
- the task is to implement or modify UI
- the task is to create or approve a design
- the task is to decide whether two images match

## Inputs

Required:

- running web application URL
- target viewport width
- target viewport height

Optional:

- route/path
- screenshot output path
- device pixel ratio when supported
- wait condition or page-load condition
- interaction steps needed to reach the target state

If the target viewport is not specified, ask for it or use the viewport explicitly required by the calling workflow. Do not invent a design viewport.

## Screenshot Workflow

Follow this order:

1. Confirm the application is reachable.
2. Open the required URL.
3. Set the requested viewport.
4. Perform only the interactions required to reach the target state.
5. Wait for the required page/state to settle.
6. Capture the screenshot.
7. Return the screenshot and metadata.

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

Return the canonical `## Output` format below. Required fields:

```text
Screenshot

URL:
<url>

Viewport:
<width>x<height>

Route:
<route>

State:
<description>

Screenshot:
<image/path/reference>
```

When possible, preserve the screenshot as a project artifact or temporary evidence artifact according to the calling workflow.

## Stitch Verification Use

When called for Stitch-based visual verification:

```text
Approved Stitch screenshot
        +
Running application
        ↓
screenshot
        ↓
actual rendered screenshot
        ↓
verification compares them
```

This skill does not treat the Stitch screenshot as its own input authority. It only captures the implementation.

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

## Failure Behavior

Status definitions:

```text
PASS: screenshot captured and URL/viewport/route/state recorded.
BLOCKED: preconditions not met (app unreachable, route/state unreachable).
FAILED: capture attempted but tool/capability failed.
```

If the application cannot be reached:

```text
Status: BLOCKED
Reason: Running application is not reachable.
```

If the requested route or state cannot be reached:

```text
Status: BLOCKED
Reason: Target UI state could not be reached.
```

If screenshot capture is unavailable:

```text
Status: BLOCKED
Reason: Screenshot capability is unavailable.
```

Do not claim a screenshot was captured when it was not.

## Browser Safety

Use the project's approved browser/testing capability (e.g. project Playwright/Cypress harness or caller-specified browser tool).
If the calling workflow specifies a tool, use it; otherwise use the project test harness. Do not invent a new harness.

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

- [ ] The application URL was reachable.
- [ ] The requested viewport was used.
- [ ] The correct route was captured.
- [ ] The requested state was reached.
- [ ] The screenshot was actually captured.
- [ ] URL, viewport, route, and state were recorded.
- [ ] No production data was modified.
- [ ] No secrets were exposed.

## Output

Keep the output simple:

```text
Screenshot

Status:
PASS | BLOCKED | FAILED

Use definitions in Failure Behavior. Do not use FAILED for unreachable preconditions.

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

screenshot
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
- stitch-handoff
- implementation
- verification

## Self-Improvement

Follow the common self-improvement standard in:

`../self-improvement/references/standard.md`

Only propose changes to this skill when real projects provide repeatable evidence that screenshot capture is missing an important capability or creating recurring reliability problems.
