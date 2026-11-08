---
name: stitch-handoff
description: Retrieves approved Stitch design artifacts for implementation and prepares a visual-first handoff. Use during implementation when an accepted Jira Story references an approved Stitch design. Treat the Stitch screenshot as the primary visual reference and HTML as supporting information only. Do not implement production code, create Jira work, change requirements, or own visual verification.
---

# Stitch Handoff

## Purpose

Prepare an approved Stitch design for the `implementation` skill. This solves
the design-to-code problem where implementation follows generated HTML too
closely and the result differs visually from the approved design.

```text
Screenshot            → primary visual reference
HTML / Stitch data    → secondary structural reference
```

This skill answers "which approved Stitch design should implementation use,
and what visual reference must it preserve?" It does not answer how to
implement the application; `implementation` owns that.

## When to Use

Use when an accepted Jira Story references an approved Stitch design, or the
implementation workflow needs the visual source, target dimensions, or visual
reference for a Stitch-designed screen.

Do not use when the Story has no Stitch design or the design is not approved,
or to create or redesign a Stitch screen, implement production code, change
Jira tickets, or change requirements or architecture.

## Preconditions

1. Read the Jira Story and confirm it references a Stitch design or approved design artifact.
2. Confirm the design is approved under the project's design workflow.
3. Identify the specific screen or screens the Story needs.
4. If approval or screen identity is unclear, stop and ask. A conversational "use the Stitch design" is not enough when the project requires an approved artifact.

## Visual Authority

```text
1. Approved Stitch screenshot
2. Approved project UI/design-system guidance
3. Approved UX/UI artifact
4. Stitch HTML / generated source
5. Other supporting metadata
```

The screenshot is the primary reference for visual fidelity. HTML is
supporting information only and is never a production-code template. If the
project has an approved design system, treat it as supporting guidance: do not
replace it with Stitch-generated markup, and preserve the project's reusable
components and tokens.

## Handoff Workflow

1. **Identify.** Find the exact approved screen the Story references. Never substitute a visually similar screen. Record screen, Stitch reference, Story, and target viewport.
2. **Retrieve.** Get the screenshot when the integration makes it available, plus HTML, dimensions or target viewport, design metadata, design-system guidance, and approved UX/UI references when available.
3. **Inspect.** Look at the screenshot itself before handing it over: layout, spacing, proportions, typography, color relationships, component placement, hierarchy, imagery and assets, and responsive framing when a viewport is given. Never approve a handoff from HTML alone, and never work from thumbnails or memory.
4. **Package.** Return the handoff in the Output format below.
5. **Return control** to `implementation`. Do not modify production code.

Multiple screens: prepare a separate visual reference per screen. Multiple
viewports (desktop, tablet, mobile): preserve each approved viewport
separately and never assume one represents another.

## Missing Artifacts

- **Stitch reachable, approved screenshot missing:** status `BLOCKED`. Name the missing artifact. Do not treat HTML as equivalent visual proof, invent a replacement screenshot, or mark the handoff complete.
  ```text
  Visual reference: MISSING
  Supporting HTML: AVAILABLE
  Handoff status: BLOCKED
  Reason: HTML is not a substitute for the approved visual reference.
  ```
- **Nothing retrievable or verifiable (Stitch unreachable):** status `UNKNOWN`.
  ```text
  Visual reference: UNKNOWN
  Supporting HTML: UNKNOWN
  Handoff status: UNKNOWN
  Reason: Stitch artifacts could not be accessed; no visual claim is possible.
  ```

## Boundaries

Flow: UX / UI design → Stitch → approved design → `stitch-handoff` →
`implementation` (planning, production code, architecture, tests, review,
commit) → real browser rendering → visual verification.

This skill prepares the target reference. It does not claim the production
implementation matches it; that comparison (approved screenshot against real
browser rendering) belongs to the project's visual-verification workflow.

This skill must not: use unapproved design references, invent missing visual
details, change requirements or architecture, create Jira work, modify the
dependency graph, modify production code, or treat generated HTML as
authoritative over an approved visual reference. It does not replace UX, UI
Design, Design Exploration, `ticket`, `ticket-dependency-planning`,
`implementation`, or verification.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The HTML looks complete, so the screenshot is unnecessary." | HTML is supporting only; without the approved screenshot the handoff is `BLOCKED`. |
| "A thumbnail or memory of the design is good enough." | Inspect the full screenshot and extract exact values. |
| "This screen looks similar enough to substitute." | Use the exact screen the Story references. |
| "Comparing the HTML proves the implementation matches." | A match claim needs real browser rendering against the approved screenshot. |

## Red Flags

- Handoff approved based on HTML alone.
- Screenshot substituted with a similar-looking screen.
- Missing visual artifacts silently treated as complete.
- Production code, Jira work, requirements, or architecture changed during handoff.

## Verification

Before reporting the handoff as complete:

- [ ] The Story, the referenced screen, and its approval status were identified.
- [ ] The screenshot was retrieved (when available) and visually inspected.
- [ ] HTML and supporting data were treated as secondary.
- [ ] Target viewport information was preserved when available.
- [ ] No production code, Jira, or dependency-graph changes were made.
- [ ] Missing artifacts were reported honestly.

## Output

```text
Stitch Handoff

Status:
READY | BLOCKED | UNKNOWN

Story:
<JIRA-KEY>

Screen:
<Stitch screen/reference>

Primary visual reference:
<screenshot path/reference>

Supporting reference:
<HTML / metadata, if available>

Target viewport:
<dimensions or NOT AVAILABLE>

Visual notes:
- ...

Approved source:
<design artifact/reference>

Missing:
- ...

Next owner:
implementation
```

## Self-Improvement

Follow `../self-improvement/references/standard.md`. Propose changes only when
real projects show repeatable evidence that the handoff misses important
information or causes recurring design-to-code fidelity problems.
