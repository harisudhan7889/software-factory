# `rfctostories` Subcommand

# RFC to Stories

## Goal

Analyse an RFC and convert its actionable implementation work into an appropriate Jira structure.

The result may be:

1. No Jira work
2. Stories/Tasks
3. Epic + Stories

Do not assume that every RFC requires an Epic.

## Input

The RFC may be provided as:

- Text supplied by the user
- A local file path supplied by the user

If a file path is provided, read the RFC before analysing it.

## Story quality

When generating application-development Stories, read and follow:

`story-quality.md`

Use those rules to translate RFC workstreams and milestones into
concrete, independently implementable product or technical Stories.

## Analysis

First classify the RFC content into:

- Context
- Goals
- Requirements
- Decisions
- Constraints
- Dependencies
- Open questions
- Future ideas
- Actionable work

Only actionable work should normally become Jira issues.

Do not create issues for background information, decisions, or speculative future work.

### Foundation/scaffold tripwire

When the RFC's platform files or workstreams assume a framework, scaffold, or platform shell (app router, Xcode/Gradle project, CI pipeline, backend project) that no work item delivers:

1. Stop before proposing the structure.
2. Verify against the repo whether the foundation already exists.
3. If it is missing, ask the user whether to add a scaffold/setup story or task (owner of the foundation, depended on by the feature work) — do not silently file only the feature slices, and do not silently invent the scaffold ticket.
4. Record an assumed-but-unscheduled foundation as an open question in the proposal when the user declines to add it.

An assumed foundation with neither a ticket nor in-repo evidence is a defect in the proposal, not caution.

## Capability detection

During RFC decomposition, use capability detection when actionable work indicates a specialized implementation capability.

For Stripe recurring subscriptions, use `stripe-subscriptions` to determine whether the RFC contains subscription-related capability areas. For Stripe one-time payments, use `stripe-one-time-payments` to determine whether the RFC contains one-time-payment capability areas. Route each capability separately.

The capability detector (`stripe-subscriptions`) defines the candidate areas (plan/price setup, checkout flow, lifecycle, app state) — do not copy the list here; use detector output.

Treat these as candidate work areas supported by the RFC. Do not create additional Jira scope solely from keyword matches or from the detector alone.

When candidate work creates dependency relationships, pass the findings to `ticket-dependency-planning`. That skill owns the actual dependency graph and READY/BLOCKED/parallel analysis.

Do not put Stripe implementation instructions into the generated Stories. Use `stripe-best-practices` during implementation.

## Determine Jira structure

### No Jira work

Use this when the RFC contains no actionable implementation work.

Explain why no Jira issues are recommended.

### Stories/Tasks

Use this when the RFC contains implementation work that can be reasonably tracked without an Epic.

Create independently understandable Stories or Tasks.

### Epic + Stories

Use this when the RFC represents a substantial initiative with multiple distinct and independently trackable workstreams.

Create:

- One Epic representing the overall initiative
- Stories representing the individual workstreams

Do not create an Epic simply because the RFC is long.

## Story decomposition

Each Story should:

- Have one clear outcome
- Be independently understandable
- Have clear acceptance criteria
- Avoid unnecessary implementation details
- Avoid overlapping another Story
- Be supported by the RFC

Do not invent requirements.

## Backend and frontend decomposition

When an actionable workstream contains both backend and frontend work:

- Do not automatically combine backend and frontend work into one Jira
Story.
- Determine whether the backend and frontend can be independently
implemented, tested, reviewed, or delivered.
- If they can be independently implemented or reviewed, create separate
Stories or Tasks.
- If they are tightly coupled and represent one atomic outcome that cannot
reasonably be implemented or verified independently, they may remain in
one Story.
- When splitting the work, clearly define the relationship and dependency
between the resulting tickets.
- Do not duplicate the same acceptance criteria across both tickets.
- UI tickets must follow the UI/UX classification and design-reference rules
below.
- Backend-only tickets must not contain UI design references.



### Technical area labels

For every generated Story or Task, classify its implementation area:

- `backend` — backend, API, database, migration, server-side, engine, or
infrastructure work.
- `frontend` — web UI, frontend components, pages, client-side behavior, or
visual implementation.
- Both `backend` and `frontend` — only when the ticket genuinely requires
both areas.

Include the resulting labels in the proposed Jira structure.

Always preserve the other labels like `agent-created` aswell.

Example:

STORY
Summary: Implement compliance-check API
Labels: backend, agent-created

STORY
Summary: Build compliance-check screen
Labels: frontend, agent-created
UI/UX: Existing approved design
Design: <Stitch design URL>

## UI/UX classification

For each actionable workstream, determine whether UI/UX work is required.

Classify each workstream as exactly one of:

1. No UI/UX required
2. UI change using an existing approved design
3. New UI/UX design required



### No UI/UX required

For backend, infrastructure, database, API, CI, testing, documentation, or
other work that does not require user-facing UI changes:

- Do not invoke the UX or UI Design workflow.
- Do not include a UI design reference in the Jira ticket.
- Create the Jira issue using the normal Story/Task workflow.



### UI change using an existing approved design

When the work changes an existing user-facing experience and an approved
design already exists:

- Identify the applicable approved UX specification.
- Identify the applicable approved UI design.
- Identify the canonical external design link when available.
- Include the design reference in the Jira ticket description.
- Include design-fidelity acceptance criteria in the Jira ticket: the
implementation must match the approved screen's layout, design tokens,
states, and responsive/accessibility behavior. A reference link alone is
not an acceptance criterion and must never be the only design-related
content in the ticket.



### New UI/UX design required

When the work introduces a new user-facing experience that does not have an
approved design:

- Route the work through the UX workflow.
- Route the result through the UI Design workflow.
- Require human approval of the design before creating the implementation
Jira ticket.
- Store the approved UX and UI design artifacts in the project.
- Include the canonical approved design link in the Jira ticket description.



### Design reference rules

For UI-related Jira tickets:

- Include only approved design references.
- Prefer the canonical Sketch design link when a Sketch design has been
approved.
- Include the relevant design artifact path when available.
- The design link must correspond to the specific work being tracked.
- Do not add unrelated design links.
- Add design-fidelity acceptance criteria (layout, tokens, states per the
approved design). The ticket must be unverifiable as complete without
them; a reference link alone never counts as design coverage.

For non-UI Jira tickets:

- Do not include a UI design link.



## UI classification in the proposed Jira structure

For every proposed Story or Task, show:

```text
UI/UX: None
or:
UI/UX: Existing approved design
Design: <canonical Sketch URL>
UX artifact: <path>
UI design artifact: <path>
or:
UI/UX: New design required
Design status: Pending
```

A Jira implementation ticket for new UI work must not be created until the
required UX/UI design has been approved.

### One important change to your output

Your `Proposed Jira structure` should now show the UI classification for **each ticket**.

For example:

```text
STORY
Key: <generated later>
Summary: Build compliance review screen
Type: Story
Priority: Medium

UI/UX: Existing approved design
Design: <Sketch URL>
UX artifact:
docs/ux/0001-adverify/overview.md
UI design artifact:
docs/ui/design/0001-adverify/overview.md

Whereas:

STORY
Summary: Add rule catalog migration
Type: Story
Priority: Medium

UI/UX: None
```



## Proposed output

Before creating Jira issues, present:

### RFC Analysis

- Actionable work: Yes/No
- Recommended structure: No tickets / Stories / Epic + Stories



## Proposed Jira structure

Before creating anything, present the complete proposed Jira hierarchy.

### If an Epic is recommended

Present:

```text
EPIC
Summary: <epic summary>
Description: <epic description>
Priority: <priority>
```



### If Stories/Tasks only

Present each Story/Task with Summary/Description/Priority/Labels/UI-UX per above.

## Confirm

Show the complete Proposed Jira structure including Epics. Wait for explicit confirmation ("create"/"confirmed"/"yes"/"go ahead") before creating anything. If request changes, revise proposal and re-confirm. Do NOT call creation scripts until approved.

## Workflow

1. Read RFC.
2. Classify + detect capabilities.
3. Determine structure.
4. Draft Stories per Story quality + templates.
5. Show proposal + Confirm.
6. After confirmation, create via `scripts/jira-create.sh` (one call per issue, Epic first).
7. Return keys/URLs.
8. If an Epic is created during this workflow, update the RFC's `overview.md` Jira Epic field with the created Epic key and link.

