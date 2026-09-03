---
name: ticket-dependency-planning
description: Guides agents through analyzing approved product and technical work to draft dependencies between Jira tickets and identify blocked, ready, and parallel work. Use when planning execution order for Jira tickets, determining ready/blocked states, or identifying parallel work. Do not use for implementing tickets or changing Jira unless explicitly approved.
---

# Ticket Dependency Planning

## Purpose

Identify and organize dependencies between Jira tickets so the software factory can determine:

- Which tickets are ready to start
- Which tickets are blocked
- Which tickets can be implemented in parallel
- Which tickets should be done first

This skill plans dependency relationships.

It does not implement the tickets.

## When to Use

Use when:
- Planning execution order for a set of Jira tickets from PRD/RFC/ADR/Jira sources
- Determining which tickets are READY vs BLOCKED
- Identifying safe parallel work or dependency levels

Do not use when:
- Implementing code (use `implementation`)
- Creating or refining tickets (use `ticket`)
- Changing requirements or architecture (use `rfc` / `adr`)

## Inputs

Use the most relevant approved sources available:

- PRD
- RFC
- ADR
- UX/UI decisions when they create implementation dependencies
- Jira tickets
- Existing repository state when needed

Treat each source according to its approval authority. Do not reinterpret PRD/RFC/ADR/Jira beyond what that source approves.

Do not invent requirements that are not supported by the source material.

## Workflow

Follow this order:

1. Gather the most relevant approved sources from `Inputs`.
2. Draft the dependency graph using `Dependency Model`, recording reason, source, evidence, and confidence for each edge.
3. Classify tickets as READY, BLOCKED, or parallel candidates per `Ready Tickets`, `Blocked Tickets`, and `Parallel Work`.
4. Derive execution levels and check for cycles per `Execution Levels` and `Cycles`.
5. Run `Verification`, then request `Human Review` when required.
6. Report per `Output` without modifying Jira unless explicitly authorized.

## Dependency Model

Represent a dependency as:

```text
Ticket A
  ↓ blocks
Ticket B
```

Meaning:

```text
Ticket B cannot be completed correctly until Ticket A is completed.
```

Use a dependency only when there is a meaningful reason.

For each dependency, record:

```text
Blocking ticket
Dependent ticket
Reason
Source
Evidence
Confidence
```

Use these confidence labels:

```text
FACT
INFERENCE
HYPOTHESIS
UNKNOWN
```

## Dependency Reason

Every proposed dependency must have a clear reason.

Good:

```text
A blocks B because B requires the database structure created by A.
```

Weak:

```text
A probably comes first.
```

Do not create dependencies only because:

- One ticket has a lower number
- One ticket was created earlier
- One ticket sounds more important
- The tickets are in the same Epic
- A particular implementation order feels convenient

## Dependency Sources

Prefer evidence in this order for dependency reasoning:

1. Explicit dependency stated in an approved source
2. Technical requirement in the RFC
3. Architectural constraint in an ADR
4. Clear implementation requirement in the Jira ticket
5. Repository evidence
6. Reasoned inference

Do not present inference as fact.

## Dependency Types

Use simple dependency types when they improve clarity.

### Hard dependency

The dependent ticket cannot reasonably proceed without the blocking ticket.

Example:

```text
Database schema
  ↓
Feature using that schema
```

### Soft dependency

Work can begin, but completion or integration is easier after another ticket.

Example:

```text
Shared UI component
  ↓
Feature polish
```

Only use soft dependencies when they provide useful execution guidance.

Do not turn normal sequencing preferences into hard dependencies.

## Ready Tickets

A ticket is `READY` when:

- It is within approved scope.
- All required dependencies are complete.
- Required source information is available.
- No known blocking condition prevents implementation.

`READY` means the ticket is ready from a dependency and planning perspective.
It does not guarantee that every implementation prerequisite is available.

A ticket may be ready even when unrelated tickets are still incomplete.

## Blocked Tickets

A ticket is `BLOCKED` when one or more required dependencies are incomplete.

Record the blocking tickets.

Example:

```text
ADVERIFY-104
Status: BLOCKED
Blocked by:
- ADVERIFY-101
- ADVERIFY-103
```

Do not mark a ticket blocked because unrelated work is incomplete.

## Parallel Work

Identify tickets that can safely run in parallel.

Example:

```text
A
├── B
└── C
```

After A is complete, B and C can proceed independently.

Do not recommend parallel execution when the tickets:

- Modify the same critical area in conflicting ways
- Depend on each other
- Require a shared unfinished foundation
- Have a safety or sequencing requirement that prevents parallel work

When uncertain, mark the relationship as `UNKNOWN` or request review.

## Execution Levels

A useful representation is a set of dependency levels:

```text
Level 0:
A, B

Level 1:
C, D

Level 2:
E
```

Tickets in the same level may be candidates for parallel execution, subject to implementation and Git safety checks.

Levels are an execution aid, not a replacement for the dependency graph.

## Cycles

A dependency graph should normally be acyclic.

Example of an invalid cycle:

```text
A → B
B → C
C → A
```

If a cycle is detected:

- Do not silently break it.
- Report the cycle.
- Identify the assumptions causing it.
- Request human clarification when the cycle cannot be resolved from the approved sources.

## Graph Output

The planner should produce a simple graph or equivalent structured record.

Example:

```text
ADVERIFY-101
  ├── blocks → ADVERIFY-104
  └── blocks → ADVERIFY-105

ADVERIFY-102
  └── blocks → ADVERIFY-105
```

Then summarize:

```text
READY:
- ADVERIFY-101
- ADVERIFY-102

BLOCKED:
- ADVERIFY-104 ← ADVERIFY-101
- ADVERIFY-105 ← ADVERIFY-101, ADVERIFY-102
```

## Jira Relationship

When Jira supports dependency links, use the appropriate relationship, such as:

```text
blocks
is blocked by
```

Do not modify Jira automatically unless the task explicitly authorizes Jira updates.

Drafting a dependency graph and writing dependency links to Jira are separate actions.

## Human Review

Dependency analysis should be treated as a draft when any important relationship is inferred.

Human review should be requested when:

- A dependency materially changes execution order.
- A dependency is uncertain.
- A dependency affects multiple teams or major system areas.
- A cycle is detected.
- The proposed dependency conflicts with an approved source.
- Adding the dependency would substantially change approved scope.

Do not hide uncertainty to make the graph look complete.

## Changes to the Graph

Dependencies may change when:

- PRD requirements change
- RFC design changes
- ADR decisions change
- Jira scope changes
- Repository implementation reveals new constraints

When this happens:

1. Re-evaluate affected dependencies.
2. Preserve the reason and source for the change.
3. Do not silently rewrite approved dependency decisions.
4. Recalculate READY and BLOCKED states.

## Scope Control

This skill must not:

- Implement Jira tickets
- Change product requirements
- Change architecture
- Create new Jira scope without approval
- Change Git history
- Merge Pull Requests

It plans work relationships.

To implement tickets, use `implementation`. To create or refine tickets, use `ticket`. To change product or technical decisions, use `rfc` / `adr`.

## Policy References

Read only the policies required by the current task.

Potentially relevant policies include:

- `policies/guardrails.md` — scope, authority, approval, and safety boundaries
- `policies/verification.md` — verification and evidence requirements
- `policies/git-safety.md` — when evaluating parallel implementation safety
- `policies/security.md` — when security or sensitive data affects dependency planning
- `policies/observability.md` — when recording significant planning events
- `policies/dependency-safety.md` — when dependency relationships affect the plan

Do not load policies that are not relevant to the current task.

## Verification

Before reporting the dependency plan:

- [ ] Every hard dependency has a reason.
- [ ] The source or evidence is recorded when available.
- [ ] FACT / INFERENCE / HYPOTHESIS / UNKNOWN is preserved.
- [ ] READY tickets have no unresolved required dependencies.
- [ ] BLOCKED tickets identify their blockers.
- [ ] Parallel candidates do not have known conflicting dependencies.
- [ ] Cycles are detected and reported.
- [ ] The graph matches the approved source material.
- [ ] No Jira changes were made unless explicitly authorized.

Use the statuses and evidence rules in `policies/verification.md`.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| Skip the reason, the order is obvious | Every hard dependency needs a reason per `Dependency Reason` — obvious orders still need evidence |
| Lower ticket number means it comes first | Do not create dependencies from ticket numbers, creation order, or importance per `Dependency Reason` |
| Mark uncertain edges as FACT to look complete | Do not present inference as fact; preserve FACT / INFERENCE / HYPOTHESIS / UNKNOWN and request review |

## Red Flags

- Hard dependency without reason, source, or evidence
- BLOCKED ticket without named blockers, or READY ticket with unresolved required dependencies
- Parallel work proposed for tickets with conflicting dependencies or shared unfinished foundation
- Cycle silently broken instead of reported with assumptions
- Jira links changed without explicit authorization

## Observability

For significant dependency-planning runs, record enough information to trace:

```text
Run ID
Agent
Task or Epic
Tickets analyzed
Dependencies proposed
Dependencies changed
Verification result
```

Follow `policies/observability.md`.

## Output

Keep the result simple.

The preferred output is:

```text
Dependency Graph

A
├── B
└── C
    └── D

READY:
A

BLOCKED:
B ← A
C ← A
D ← C

PARALLEL:
B and C

UNKNOWN:
D ← C
Reason: ...
Evidence: ...
Confidence: INFERENCE
```

Do not produce unnecessary detail when the dependency structure is simple.

## Self-Improvement

Follow the common self-improvement standard in:

`../self-improvement/references/standard.md`
