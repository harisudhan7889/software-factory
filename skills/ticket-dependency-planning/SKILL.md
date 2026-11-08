---
name: ticket-dependency-planning
description: Guides agents through analyzing approved product and technical work to draft dependencies between Jira tickets and identify blocked, ready, and parallel work. Use when planning execution order for Jira tickets, determining ready/blocked states, or identifying parallel work. Do not use for implementing tickets or changing Jira unless explicitly approved.
---

# Ticket Dependency Planning

## Purpose

Identify and organize dependencies between Jira tickets so the factory can
tell which tickets are ready, which are blocked, which can run in parallel, and
which should be done first. This skill plans dependency relationships. It does
not implement tickets.

## When to Use

Use when planning execution order for a set of tickets from PRD/RFC/ADR/Jira
sources, determining READY vs BLOCKED, identifying safe parallel work or
dependency levels, or checking dependencies for a newly created or materially
changed ticket.

Do not use to implement code (`implementation`), create or refine tickets
(`ticket`), or change requirements or architecture (`rfc` / `adr`).

## Inputs

Use the most relevant approved sources: PRD, RFC, ADR, UX/UI decisions that
create implementation dependencies, Jira tickets, and repository state when
needed. Treat each source by its approval authority, do not reinterpret it
beyond what it approves, and do not invent requirements.

## Workflow

1. Gather the approved sources.
2. Draft the dependency graph (Dependency Model), recording reason, source, evidence, and confidence for each edge.
3. Classify tickets as READY, BLOCKED, or parallel candidates.
4. Derive execution levels and check for cycles.
5. Run Verification, and request Human Review when required.
6. Report per Output without modifying Jira unless explicitly authorized.

## Capability Detection

When a new or materially changed ticket suggests a specialized capability
(Stripe subscriptions or one-time payments), route to the matching detector
skill and treat its output as candidate evidence only. Read
`references/capability-detection.md` for routing rules and boundaries.

## Dependency Model

`A blocks B` means B cannot be completed correctly until A is completed. Use a
dependency only with a meaningful reason. For each, record: blocking ticket,
dependent ticket, reason, source, evidence, and confidence (`FACT`,
`INFERENCE`, `HYPOTHESIS`, or `UNKNOWN`).

**Reason.** Good: "A blocks B because B requires the database structure created by A." Weak: "A probably comes first." Never create a dependency only because one ticket has a lower number, was created earlier, sounds more important, shares an Epic, or makes a convenient order.

**Evidence order.** Prefer: (1) an explicit dependency in an approved source, (2) a technical requirement in the RFC, (3) an architectural constraint in an ADR, (4) a clear requirement in the Jira ticket, (5) repository evidence, (6) reasoned inference. Never present inference as fact.

**Types.** A *hard* dependency means the dependent ticket cannot reasonably proceed (database schema → feature using it). A *soft* dependency means work can start but finishes more easily after the other (shared UI component → feature polish). Use soft dependencies only when they give useful guidance, and never turn a sequencing preference into a hard one.

## Ticket States

- **READY:** within approved scope, all required dependencies complete, source information available, no known blocker. It means ready from a planning perspective only, and a ticket may be READY while unrelated tickets are incomplete.
- **BLOCKED:** one or more required dependencies are incomplete; name the blocking tickets (for example `ADVERIFY-104 BLOCKED by ADVERIFY-101, ADVERIFY-103`). Do not block a ticket for unrelated incomplete work.

## Parallel Work and Levels

After A completes, B and C may proceed independently. Do not recommend
parallel execution when tickets depend on each other, modify the same critical
area in conflicting ways, need a shared unfinished foundation, or have a safety
or sequencing requirement. When uncertain, mark `UNKNOWN` or request review.

Execution levels (Level 0: A, B; Level 1: C, D; Level 2: E) are an aid.
Tickets in one level may be parallel candidates, subject to implementation and
Git safety checks. Levels do not replace the graph.

## Cycles

The graph should be acyclic (A → B → C → A is invalid). If a cycle appears, do
not break it silently: report it, identify the assumptions causing it, and ask
for clarification when approved sources cannot resolve it.

## Jira Relationship

When Jira supports dependency links, use `blocks` / `is blocked by`. Drafting a
graph and writing links to Jira are separate actions; do not modify Jira
unless the task explicitly authorizes it.

## Human Review

Treat the analysis as a draft when any important relationship is inferred.
Request review when a dependency materially changes execution order, is
uncertain, affects multiple teams or major system areas, creates a cycle,
conflicts with an approved source, or substantially changes approved scope.
Do not hide uncertainty to make the graph look complete. Reporting an
uncertain graph as DRAFT need not block; just do not write Jira links until
the required review is approved.

## Changes to the Graph

Dependencies change when PRD, RFC, ADR, or Jira scope changes, or when the
repository reveals new constraints. Re-evaluate affected dependencies, keep
the reason and source for the change, do not silently rewrite approved
decisions, and recalculate READY and BLOCKED. For tickets that are new or
changed, follow the Incremental Dependency Check below.

## Incremental Dependency Check

When a ticket is created or changes materially, re-evaluate its dependencies
in both directions, update the graph, and recalculate READY/BLOCKED. Read
`references/incremental-check.md` for the procedure and persistence rules.

## Scope Control and Policies

This skill must not implement tickets, change requirements or architecture,
create Jira scope without approval, change Git history, or merge Pull Requests.

Read only the relevant policies: `policies/guardrails.md` (scope, approval),
`policies/verification.md` (evidence), `policies/git-safety.md` (parallel
safety), `policies/security.md`, `policies/observability.md`,
`policies/dependency-safety.md`. For significant runs record run ID, agent,
task or Epic, tickets analyzed, dependencies proposed and changed, and the
verification result.

## Verification

Before reporting the plan:

- [ ] Every hard dependency has a reason, with source or evidence recorded when available, and FACT / INFERENCE / HYPOTHESIS / UNKNOWN preserved.
- [ ] READY tickets have no unresolved required dependencies; BLOCKED tickets name their blockers.
- [ ] Parallel candidates have no known conflicting dependencies.
- [ ] Cycles are detected and reported, and the graph matches the approved sources.
- [ ] No Jira dependency links were created or changed unless explicitly authorized.
- [ ] New or changed tickets were checked against existing tickets in both directions.
- [ ] The report lists graph deltas since the prior report, or "no changes".

Use the statuses and evidence rules in `policies/verification.md`.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The order is obvious, skip the reason." | Every hard dependency needs a reason and evidence. |
| "A lower ticket number comes first." | Never derive dependencies from ticket numbers, creation order, or importance. |
| "Mark uncertain edges as FACT to look complete." | Preserve the classification and request review. |

## Red Flags

- A hard dependency without reason, source, or evidence.
- A BLOCKED ticket with no named blockers, or a READY ticket with unresolved dependencies.
- Parallel work proposed for tickets with conflicting dependencies or a shared unfinished foundation.
- A cycle broken silently, or Jira links changed without authorization.

## Output

Keep it simple and skip detail when the structure is simple. `UNKNOWN:` in the
output is a category for uncertain relationships, not a confidence value;
always include `Reason / Evidence / Confidence:` with Confidence as FACT,
INFERENCE, HYPOTHESIS, or UNKNOWN.

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

## Self-Improvement

Follow `../self-improvement/references/standard.md`.
