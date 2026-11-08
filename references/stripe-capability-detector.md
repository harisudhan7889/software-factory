# Stripe Capability Detector Standard

Shared rules for `stripe-one-time-payments` and `stripe-subscriptions`. Each
skill owns its own triggers, decision criteria, capability areas, and examples.
This file owns everything common to both detectors.

## Role

A detector decides whether a requirement needs one Stripe capability and names
the high-level capability areas involved. It does not explain how to implement
Stripe. Each detector answers "does this requirement need X, and which areas?"
and never "how should Stripe be implemented?".

## Ownership

| Owner | Responsibility |
|---|---|
| Detector skill | Detect the capability and identify candidate capability areas |
| `ticket-dependency-planning` | Evaluate real dependencies, own the persistent dependency graph, decide READY/BLOCKED/parallel |
| `ticket` | Create and refine Jira tickets; require user confirmation before Jira changes |
| `implementation` | Plan and implement accepted Jira Stories |
| `stripe-best-practices` | Stripe implementation guidance |
| `stripe-docs` | Current Stripe documentation lookup |
| `upgrade-stripe`, `connect-recommend` | Upgrades and Connect decisions, only when those skills exist |

Do not duplicate responsibilities across these skills.

Detect each capability separately. When one requirement needs both one-time
payments and subscriptions, report both and never merge them because both use
Stripe.

## Source Review

Inspect the authoritative sources the project has, and respect each source's
authority: approved PRD, approved RFC, accepted ADRs, the Jira ticket, and
relevant existing project information. Never invent amounts, currencies,
prices, plan names, trials, taxes, discounts, refunds, payment methods,
products, or commercial terms.

A trigger keyword is only a signal for analysis. It never proves the
capability is required, and the word "Stripe" alone is not a reason to run.

## Capability Decision

Return exactly one of `NOT_REQUIRED`, `CANDIDATE`, `REQUIRED`, `BLOCKED`,
`UNKNOWN`.

- `REQUIRED`: the approved requirement clearly describes the capability.
- `CANDIDATE`: the wording strongly suggests it but the behavior is not confirmed.
- `BLOCKED`: the capability is intended but an important product, provider, or architecture decision is missing. This is a capability decision, not a ticket READY/BLOCKED state; `ticket-dependency-planning` owns the latter.
- `UNKNOWN`: the sources do not give enough evidence.
- `NOT_REQUIRED`: the requirement clearly does not need it.

Each skill adds what `REQUIRED` and `CANDIDATE` mean for its own capability.

## Capability Areas and Existing Work

Capability areas are high-level work areas, not Jira tickets. Do not define
implementation details; `stripe-best-practices`, the RFC/ADR, the codebase, and
the implementation workflow determine those later. Check whether each area
already exists in the project and report only what appears missing or
affected, so no duplicate work is proposed.

## Handoff to Ticket Dependency Planning

For each candidate area provide: capability area, reason, source, evidence,
confidence, existing work, unknowns/blockers. Label evidence as `FACT`,
`INFERENCE`, `HYPOTHESIS`, or `UNKNOWN`. `ticket-dependency-planning` decides
whether a candidate is an actual dependency; the detector never updates the
graph.

## Incremental Changes

When a Jira ticket is created or materially changed:

1. Re-evaluate whether the capability applies.
2. Identify added, removed, or changed capability areas.
3. Pass the result to `ticket-dependency-planning`, which evaluates both dependency directions against existing tickets.
4. Preserve uncertainty.

## Boundaries

A detector must not:

- create or modify Jira tickets, add dependency links, or expand approved scope silently
- modify the dependency graph
- provide Checkout API, webhook, schema, or secret-management instructions; stop at the handoff
- expose secrets or invent architecture
- create Jira scope from keywords alone
- bypass approval gates

## Implementation Handoff

When an accepted Jira Story needs the actual Stripe work: `implementation`
reads the Story and approved RFC/ADRs, loads `stripe-best-practices`, uses
`stripe-docs` (or current Stripe documentation directly if that skill does not
exist) for exact API behavior, and follows the approved architecture.

## Output Template

```text
Stripe <Capability> Capability

Decision:
REQUIRED | CANDIDATE | NOT_REQUIRED | BLOCKED | UNKNOWN

Detected:
- ...

Candidate Capability Areas:
- ...

Existing Work:
- ...

Reason / Evidence / Confidence:
- ...

Unknowns / Blockers:
- ...

Handoff:
ticket-dependency-planning
```

## Verification

Before handing off, confirm:

- [ ] The decision is supported by the requirement and the authoritative sources were reviewed.
- [ ] Every candidate area has a reason, with evidence and confidence when available.
- [ ] Existing work was considered.
- [ ] No implementation details were invented.
- [ ] No Jira or dependency-graph changes were made.
- [ ] Skill-specific checks (see the skill) were done.

## Self-Improvement

Follow `../skills/self-improvement/references/standard.md`. Propose a factory
change only when real evidence shows repeated detection runs miss an important
capability or create a recurring problem.
