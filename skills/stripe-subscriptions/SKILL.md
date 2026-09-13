---
name: stripe-subscriptions
description: Detects when a product requirement needs Stripe recurring subscriptions and identifies candidate capability areas for ticket-dependency-planning. Use when a Jira ticket or approved product/technical source describes subscriptions or recurring billing. Do not provide Stripe implementation guidance, create Jira tickets, modify Jira, or own the dependency graph.
---

# Stripe Subscriptions

## Purpose

Detect whether a requirement needs the **Stripe Subscriptions capability** and identify the high-level work areas that may be needed.

This skill is a **capability detector and classifier**.

It does not explain how to implement Stripe.

## Responsibility

This skill answers:

> "Does this requirement need Stripe subscriptions, and what capability areas are involved?"

It does not answer:

> "How should Stripe be implemented?"

That implementation responsibility belongs to `stripe-best-practices`.

## Ownership

Keep responsibilities separate:

- `stripe-subscriptions` — detect subscription requirements and identify candidate capability areas.
- `ticket-dependency-planning` — evaluate actual dependencies, own the persistent dependency graph, and determine READY/BLOCKED/parallel work.
- `ticket` — create and refine Jira tickets and require user confirmation before Jira changes.
- `implementation` — plan and implement accepted Jira Stories.
- `stripe-best-practices` — provide Stripe implementation guidance.
- Current Stripe documentation — consult directly for exact API behavior; use a docs-lookup skill only when `skills/stripe-docs/SKILL.md` exists.
- Stripe API/SDK upgrades — follow approved RFC/ADR + current Stripe changelog; use the `upgrade-stripe` skill only when `skills/upgrade-stripe/SKILL.md` exists.
- Stripe Connect marketplace decisions — follow approved product/architecture sources; use a Connect-specific capability only when that skill exists.

Do not duplicate responsibilities across these skills.

## When to Use

Use when an approved source or Jira ticket describes:

- subscriptions
- recurring billing
- recurring payments
- weekly plans
- monthly plans
- yearly or annual plans
- paid membership plans
- users subscribing to a service
- a subscription-related Stripe Checkout/payment flow

Do not use only because the word `Stripe` appears somewhere. Inspect the actual requirement.

## Trigger Signals

Possible signals include:

- subscribe
- subscription
- recurring
- recurring billing
- recurring payment
- monthly
- weekly
- yearly
- annual
- paid plan
- membership plan
- Stripe Checkout
- Stripe payment page

A trigger is only a signal for analysis. A keyword does not automatically prove that subscriptions are required.

## Source Review

Before making a capability decision, inspect the relevant authoritative sources available for the project:

- approved PRD
- approved RFC
- accepted ADRs
- Jira ticket
- relevant existing project information

Respect the authority of each source.

Do not invent requirements or commercial terms.

## Capability Decision

Return one of:

- `NOT_REQUIRED`
- `CANDIDATE`
- `REQUIRED`
- `BLOCKED`
- `UNKNOWN`

### REQUIRED

Use when the approved requirement clearly describes recurring subscription behavior.

### CANDIDATE

Use when the wording strongly suggests subscriptions but the required behavior is not confirmed.

### BLOCKED

Use when subscription behavior is intended but an important product or architecture decision is missing.

### UNKNOWN

Use when the available sources do not provide enough evidence.

### NOT_REQUIRED

Use when the requirement clearly does not need recurring subscriptions.

## Candidate Capability Areas

For a confirmed subscription requirement, identify only the high-level capability areas that appear to be needed.

Possible areas:

```text
Stripe subscription capability
├── plan / recurring price setup
├── subscription checkout/payment flow
├── subscription lifecycle handling
└── application subscription state
```

These are **capability areas**, not Jira tickets.

Do not define their implementation details here.

The actual technical implementation is determined later by `stripe-best-practices`, the project's RFC/ADR, the existing codebase, and the implementation workflow.

## Existing Work

Check whether relevant Stripe subscription capability areas already exist.

Examples:

- existing recurring plans
- existing subscription checkout flow
- existing subscription lifecycle integration
- existing application subscription state

Do not propose duplicate work when the project already has the required capability.

Only report what appears to be missing or affected.

## Handoff to Ticket Dependency Planning

Provide candidate capability areas to `ticket-dependency-planning`.

For each candidate, provide:

```text
Capability area
Reason
Source
Evidence
Confidence
Existing work
Unknowns / blockers
```

Use:

```text
FACT
INFERENCE
HYPOTHESIS
UNKNOWN
```

`ticket-dependency-planning` decides whether a candidate is an actual dependency and owns the persistent dependency graph.

Note: this skill's BLOCKED is a capability decision (missing product/arch decision), not a ticket READY/BLOCKED state; `ticket-dependency-planning` owns the latter.

This skill must not update the graph directly.

## Jira Boundary

This skill must not:

- create Jira tickets
- modify Jira tickets
- add Jira dependency links
- expand approved Jira scope silently

The `ticket` skill owns Jira creation/refinement and user confirmation.

The dependency-planning skill owns dependency relationships.

## Incremental Changes

When a Jira ticket is created or materially changed:

1. Re-evaluate whether the Stripe subscription capability applies.
2. Identify added, removed, or changed capability areas.
3. Pass the result to `ticket-dependency-planning`.
4. Let `ticket-dependency-planning` evaluate both dependency directions against existing tickets.
5. Preserve uncertainty.

Do not directly modify the persistent dependency graph.

## Example

Requirement:

> "Users can subscribe to weekly, monthly, or yearly plans."

Result:

```text
Decision: REQUIRED

Detected:
- recurring subscription
- weekly cadence
- monthly cadence
- yearly cadence

Candidate capability areas:
- plan / recurring price setup
- subscription checkout/payment flow
- subscription lifecycle handling
- application subscription state
```

Stop here.

Do not provide Checkout API instructions, webhook implementation instructions, schema design, or secret-management instructions.

Those belong to the implementation workflow and Stripe implementation guidance.

## Example: Payment Page Only

Requirement:

> "Navigate to the Stripe payment page for the selected monthly plan."

Result:

```text
Decision: CANDIDATE or REQUIRED
```

The decision depends on the approved product flow.

Possible capability areas:

```text
- plan / recurring price setup
- subscription checkout/payment flow
```

Additional lifecycle or application-state work should only be identified when the approved requirement requires it.

## Example: Pricing UI Only

Requirement:

> "Show monthly and yearly pricing options on the pricing page."

Result:

```text
Decision: NOT_REQUIRED
```

unless an approved source also establishes that selecting a plan starts a Stripe subscription flow.

## Implementation Handoff

When the accepted Jira Story requires actual Stripe subscription implementation:

1. `implementation` reads the Story and approved RFC/ADRs.
2. `implementation` loads `stripe-best-practices`.
3. Consult current Stripe documentation directly for exact API behavior (use a docs-lookup skill only when `skills/stripe-docs/SKILL.md` exists).
4. The implementation follows the project's approved architecture.

This skill does not replace the implementation guidance.

## Safety

The skill must:

- not expose secrets
- not invent prices, currencies, trials, discounts, or plan names
- not invent architecture
- not provide privileged Stripe implementation instructions
- not create Jira scope from keywords alone
- not modify Jira
- not modify the dependency graph
- not bypass approval gates

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| Monthly mentioned so subscription required | Keyword is only a signal; decide per Capability Decision + approved sources |
| Stripe mentioned so subscriptions needed | Inspect actual requirement; use NOT_REQUIRED when no recurring behavior is described |
| Skip evidence, the intent is obvious | Record reason, source, evidence, and confidence for handoff |

## Verification

Before handing off the result, confirm:

- [ ] The decision is supported by the requirement.
- [ ] Relevant authoritative sources were reviewed.
- [ ] Candidate capability areas have a reason.
- [ ] Evidence and confidence are recorded when available.
- [ ] Existing subscription work was considered.
- [ ] No implementation details were invented.
- [ ] No Jira changes were made.
- [ ] No dependency graph changes were made.

## Output

Keep the result simple:

```text
Stripe Subscriptions Capability

Decision:
REQUIRED | CANDIDATE | NOT_REQUIRED | BLOCKED | UNKNOWN

Detected:
- ...

Candidate Capability Areas:
- ...
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

## Relationship to the Factory

This skill is a small capability detector.

It does not replace:

- PRD
- RFC
- ADR
- ticket
- ticket-dependency-planning
- implementation
- stripe-best-practices
- current Stripe documentation (direct; docs-lookup skill only when it exists)
- verification
