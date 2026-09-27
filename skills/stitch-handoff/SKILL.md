---
name: stitch-handoff
description: Retrieves approved Stitch design artifacts for implementation and prepares a visual-first handoff. Use during implementation when an accepted Jira Story references an approved Stitch design. Treat the Stitch screenshot as the primary visual reference and HTML as supporting information only. Do not implement production code, create Jira work, change requirements, or own visual verification.
---

# Stitch Handoff

## Purpose

Prepare an approved Stitch design for the `implementation` skill.

This skill exists to solve the design-to-code handoff problem where implementation can follow generated HTML too closely and produce a result that differs visually from the approved Stitch design.

The handoff must preserve the distinction between:

```text
Screenshot
→ primary visual reference

HTML / supporting Stitch data
→ secondary structural reference
```

## Responsibility

This skill answers:

> "What approved Stitch design should implementation use, and what visual reference must implementation preserve?"

It does not answer:

> "How should the application be implemented?"

Production implementation remains owned by `implementation`.

## When to Use

Use when:

- an accepted Jira Story references an approved Stitch design
- the implementation workflow needs the visual source for a Stitch-designed screen
- the implementation workflow needs the target screen dimensions or visual reference

Do not use when:

- the Story has no Stitch design
- the design is not approved
- the task is to create or redesign a Stitch screen
- the task is to implement production code
- the task is to create or modify Jira tickets
- the task is to change product requirements or architecture

## Preconditions

Before starting:

1. Read the Jira Story.
2. Confirm that the Story references a Stitch design or approved design artifact.
3. Confirm that the design is approved according to the project's design workflow.
4. Identify the specific Stitch screen or screens required by the Story.
5. If approval or screen identity is unclear, stop and ask for clarification.

Do not proceed from a conversational statement such as "use the Stitch design" when the project requires an approved design artifact or reference.

## Handoff Sources

Collect the available approved Stitch information:

- Stitch screen identifier or reference
- screenshot
- HTML or generated source, when available
- screen dimensions / target viewport, when available
- design metadata, when available
- project design-system guidance, when available
- approved UX/UI references connected to the Story

Prefer the exact screen referenced by the Story.

Do not substitute a different Stitch screen because it appears visually similar.

## Visual Authority

Use the following authority order for visual implementation:

```text
1. Approved Stitch screenshot
2. Approved project UI/design-system guidance
3. Approved UX/UI artifact
4. Stitch HTML / generated source
5. Other supporting metadata
```

The screenshot is the primary reference for visual fidelity.

HTML is supporting information only.

Do not use Stitch HTML as a production-code template.

## Handoff Workflow

Follow this order:

### 1. Identify

Identify the exact approved Stitch screen required by the Story.

Record:

```text
Screen:
Stitch reference:
Story:
Target viewport:
```

### 2. Retrieve

Retrieve the available Stitch design artifacts.

At minimum, obtain the screenshot when the Stitch integration makes it available.

Obtain HTML or other supporting Stitch data when available.

### 3. Inspect

Visually inspect the screenshot before handing it to implementation.

Check the visible:

- layout
- spacing
- proportions
- typography
- color relationships
- component placement
- hierarchy
- imagery and assets
- responsive framing when a target viewport is specified

Do not approve the handoff based on HTML alone.

### 4. Package the Handoff

Return a compact handoff containing:

```text
Stitch Handoff

Story:
<jira key>

Screen:
<screen/reference>

Primary visual reference:
<screenshot path/reference>

Supporting reference:
<html path/reference, if available>

Target viewport:
<dimensions, if available>

Important visual notes:
- ...

Approved source:
<design artifact/reference>
```

### 5. Return Control

After the handoff is prepared, return control to `implementation`.

Do not modify production code.

## Missing Artifacts

If the Story references Stitch but the required approved screenshot cannot be retrieved:

- report `BLOCKED` or `UNKNOWN` according to the evidence
- identify the missing artifact
- do not substitute HTML as equivalent visual proof
- do not invent a replacement screenshot
- do not approve the handoff as complete

If HTML exists but the screenshot does not, report:

```text
Visual reference: MISSING
Supporting HTML: AVAILABLE
Handoff status: BLOCKED
Reason: HTML is not a substitute for the approved visual reference.
```

If the Stitch integration itself cannot be accessed (no Stitch data retrievable at all — neither screenshot nor supporting data), report `UNKNOWN` instead of `BLOCKED`:

```text
Visual reference: UNKNOWN
Supporting HTML: UNKNOWN
Handoff status: UNKNOWN
Reason: Stitch artifacts could not be accessed; no visual claim is possible.
```

Use `BLOCKED` when Stitch is reachable but the required approved screenshot is missing. Use `UNKNOWN` only when nothing could be retrieved or verified.

## Multiple Screens

When a Story references multiple Stitch screens:

```text
Story
├── Screen A
├── Screen B
└── Screen C
```

Prepare a separate visual reference for each screen.

Do not collapse multiple screens into one generic handoff.

## Multiple Viewports

When the project provides approved Stitch designs for multiple viewports:

```text
Desktop
Tablet
Mobile
```

Preserve each approved viewport separately.

Do not assume that one viewport represents another.

## Design System

If the project has an existing approved design system:

- identify it as supporting guidance
- do not replace it with Stitch-generated implementation markup
- preserve the project's reusable components and tokens during implementation

The handoff is visual guidance, not an instruction to duplicate Stitch's generated component structure.

## Interaction With Implementation

The expected flow is:

```text
implementation
      ↓
Story references approved Stitch design
      ↓
stitch-handoff
      ↓
retrieve + inspect screenshot
      ↓
return visual handoff
      ↓
implementation
      ↓
production implementation
```

`implementation` remains responsible for:

- implementation planning
- production code
- project architecture
- tests
- code review
- commit

## Visual Verification Boundary

This skill prepares the target reference.

It does not claim that the production implementation matches the target.

After implementation:

```text
Approved Stitch screenshot
        +
Real browser rendering
        ↓
Visual verification
```

The comparison result belongs to the project's verification/visual-validation workflow.

## Safety

This skill must:

- use only approved design references
- never invent missing visual details
- never substitute HTML for missing visual proof
- never alter product requirements
- never alter architecture
- never create Jira work
- never modify the dependency graph
- never modify production code
- never treat generated HTML as authoritative over an approved visual reference

## Common Rationalizations
| Rationalization | Reality |
|---|---|
| The HTML looks complete, so the screenshot is unnecessary | HTML is supporting information only; without the approved screenshot the handoff is BLOCKED |
| A thumbnail or memory of the design is good enough | Inspect the full screenshot and extract exact values; never translate designs from thumbnails or memory |
| This Stitch screen looks similar enough to substitute | Use the exact screen referenced by the Story; do not substitute a visually similar screen |
| The implementation can be claimed matching based on HTML comparison | This skill prepares the target reference only; a match claim requires real browser rendering against the approved screenshot |

## Red Flags
- Handoff approved based on HTML alone
- Screenshot substituted with a similar-looking screen
- Missing visual artifacts silently treated as complete
- Production code, Jira work, requirements, or architecture changed during handoff

## Verification

Before reporting the handoff as complete:

- [ ] The Jira Story was identified.
- [ ] The referenced Stitch screen was identified.
- [ ] Approval status was confirmed when required by the project.
- [ ] The screenshot was retrieved when available.
- [ ] The screenshot was visually inspected.
- [ ] HTML/supporting data was clearly treated as secondary.
- [ ] Target viewport information was preserved when available.
- [ ] No production code was modified.
- [ ] No Jira or dependency-graph changes were made.
- [ ] Missing visual artifacts were reported honestly.

## Output

Keep the result simple:

```text
Stitch Handoff

Status:
READY | BLOCKED | UNKNOWN

Story:
<JIRA-KEY>

Screen:
<Stitch screen/reference>

Primary visual reference:
<screenshot>

Supporting reference:
<HTML / metadata, if available>

Target viewport:
<dimensions or NOT AVAILABLE>

Visual notes:
- ...

Missing:
- ...

Next owner:
implementation
```

## Relationship to the Factory

```text
UX / UI Design
      ↓
Stitch
      ↓
Approved Stitch design
      ↓
stitch-handoff
      ↓
implementation
      ↓
real browser rendering
      ↓
visual verification
```

This skill is a handoff capability.

It does not replace:

- UX
- UI Design
- Design Exploration
- ticket
- ticket-dependency-planning
- implementation
- verification

## Self-Improvement

Follow the common self-improvement standard in:

`../self-improvement/references/standard.md`

Only propose changes to this skill when real projects provide repeatable evidence that the Stitch handoff is missing important information or causing recurring design-to-code fidelity problems.
