---
name: stripe-one-time-payments
description: Detects when a product requirement needs a Stripe one-time payment capability and identifies candidate capability areas for ticket-dependency-planning. Use when a Jira ticket or approved product/technical source describes a one-time purchase or payment. Do not provide Stripe implementation guidance, create Jira tickets, modify Jira, or own the dependency graph.
---

# Stripe One-Time Payments

## Purpose

Detect whether a requirement needs the **Stripe one-time payments capability** and identify the high-level work areas that may be needed.

This skill is a **capability detector and classifier**.

It does not explain how to implement Stripe.

## Responsibility

This skill answers:

> "Does this requirement need a Stripe one-time payment, and what capability areas are involved?"

It does not answer:

> "How should Stripe be implemented?"

That implementation responsibility belongs to `stripe-best-practices`.

## Ownership

Keep responsibilities separate:

- `stripe-one-time-payments` — detect one-time payment requirements and identify candidate capability areas.
- `ticket-dependency-planning` — evaluate actual dependencies, own the persistent dependency graph, and determine READY/BLOCKED/parallel work.
- `ticket` — create and refine Jira tickets and require user confirmation before Jira changes.
- `implementation` — plan and implement accepted Jira Stories.
- `stripe-best-practices` — provide Stripe implementation guidance.
- `stripe-docs` — provide current Stripe documentation lookup.
- `upgrade-stripe` — handle Stripe API/SDK upgrades for existing integrations when that skill exists.
- `connect-recommend` — handle Stripe Connect decisions for marketplace or multi-party money flows when that skill exists.

Do not duplicate responsibilities across these skills.

## When to Use

Use when an approved source or Jira ticket describes:

- a one-time purchase
- a one-time payment
- paying a fixed amount to unlock a product or feature
- buying a digital or physical product once
- a one-off fee
- a single checkout/payment transaction that is not a subscription

Do not use when the requirement clearly describes recurring billing or a subscription. Use `stripe-subscriptions` for that case.

## Trigger Signals

Possible signals include:

- buy
- purchase
- one-time payment
- one-time purchase
- pay once
- single payment
- one-off payment
- unlock for $X
- checkout
- payment
- pay for product
- purchase product
- purchase feature

A trigger is only a signal for analysis. A keyword does not automatically prove that a one-time Stripe payment is required.

## Source Review

Before making a capability decision, inspect the relevant authoritative sources available for the project:

- approved PRD
- approved RFC
- accepted ADRs
- Jira ticket
- relevant existing project information

Respect the authority of each source.

Do not invent:

- payment amount
- currency
- product details
- taxes
- discounts
- refunds
- payment methods
- commercial terms

## Capability Decision

Return one of:

- `NOT_REQUIRED`
- `CANDIDATE`
- `REQUIRED`
- `BLOCKED`
- `UNKNOWN`

### REQUIRED

Use when the approved requirement clearly describes a one-time payment flow using Stripe.

### CANDIDATE

Use when the wording strongly suggests a payment, but it is not clear whether the payment is one-time or recurring, or whether Stripe is the approved provider.

### BLOCKED

Use when a one-time payment is intended but an important product, payment-provider, or architecture decision is missing.

### UNKNOWN

Use when the available sources do not provide enough evidence.

### NOT_REQUIRED

Use when the requirement clearly does not need a one-time Stripe payment.

## Candidate Capability Areas

For a confirmed one-time payment requirement, identify only the high-level capability areas that appear to be needed.

Possible areas:

```text
Stripe One-Time Payment
├── product / one-time price setup
├── payment checkout flow
├── payment completion / fulfillment handling
└── application payment state
```

These are **capability areas**, not Jira tickets.

Do not define their implementation details here.

The actual technical implementation is determined later by `stripe-best-practices`, the project's RFC/ADR, the existing codebase, and the implementation workflow.

## Existing Work

Check whether relevant one-time payment capability areas already exist.

Examples:

- existing one-time products or prices
- existing checkout/payment flow
- existing payment completion or fulfillment handling
- existing application payment state

Do not propose duplicate work when the project already has the required capability.

Only report what appears to be missing or affected.

## Distinguish One-Time vs Subscription

Use the approved requirement to distinguish:

```text
One-time:
User pays once for a product, feature, service, or fee.

Subscription:
User is charged on a recurring cadence such as weekly, monthly, or yearly.
```

If the requirement supports both, report both capabilities separately and hand both to `ticket-dependency-planning`.

Do not merge the two capabilities merely because they use Stripe.

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

Note: this skill's BLOCKED is a capability decision (missing product/provider/arch decision), not a ticket READY/BLOCKED state; `ticket-dependency-planning` owns the latter.

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

1. Re-evaluate whether the one-time payment capability applies.
2. Identify added, removed, or changed capability areas.
3. Pass the result to `ticket-dependency-planning`.
4. Let `ticket-dependency-planning` evaluate both dependency directions against existing tickets.
5. Preserve uncertainty.

Do not directly modify the persistent dependency graph.

## Example

Requirement:

> "User can buy the premium template for $20 once."

Result:

```text
Decision: REQUIRED

Detected:
- one-time purchase
- single payment

Candidate capability areas:
- product / one-time price setup
- payment checkout flow
- payment completion / fulfillment handling
```

Stop here.

Do not provide Checkout API instructions, webhook implementation instructions, schema design, or secret-management instructions.

Those belong to the implementation workflow and Stripe implementation guidance.

## Example: Payment Page Only

Requirement:

> "User can pay once for the selected product and continue after successful payment."

Result:

```text
Decision: REQUIRED

Candidate capability areas:
- payment checkout flow
- payment completion / fulfillment handling
```

Application payment state should only be identified when the approved product behavior requires the application to persist or query payment state.

## Example: Pricing UI Only

Requirement:

> "Show the product price and a Buy Now button."

Result:

```text
Decision: NOT_REQUIRED
```

unless an approved source establishes that the button starts a one-time Stripe payment flow.

## Example: Mixed Requirement

Requirement:

> "Users can buy the Starter package once or subscribe to Pro monthly."

Result:

```text
Stripe One-Time Payments:
Decision: REQUIRED

Stripe Subscriptions:
Decision: REQUIRED
```

Treat these as two separate capabilities.

## Implementation Handoff

When the accepted Jira Story requires actual Stripe one-time payment implementation:

1. `implementation` reads the Story and approved RFC/ADRs.
2. `implementation` loads `stripe-best-practices`.
3. `stripe-docs` is used when current Stripe documentation is needed.
4. The implementation follows the project's approved architecture.

This skill does not replace implementation guidance.

## Safety

The skill must:

- not expose secrets
- not invent prices, currencies, products, taxes, refunds, discounts, or payment methods
- not invent architecture
- not provide privileged Stripe implementation instructions
- not create Jira scope from keywords alone
- not modify Jira
- not modify the dependency graph
- not bypass approval gates

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| Buy/checkout mentioned so Stripe payment required | Keyword is only a signal; decide per Capability Decision + approved sources |
| Payment wording fits both; treat as one capability | Distinguish one-time vs subscription per `Distinguish One-Time vs Subscription`; report both separately when both apply |
| Skip evidence, the purchase intent is obvious | Record reason, source, evidence, and confidence for handoff |

## Red Flags

- Checkout/webhook/schema/secret implementation details provided instead of stopping at handoff
- Jira ticket created/modified or dependency graph updated by this skill
- Subscription and one-time capabilities merged because both use Stripe

## Verification

Before handing off the result, confirm:

- [ ] The decision is supported by the requirement.
- [ ] Relevant authoritative sources were reviewed.
- [ ] Candidate capability areas have a reason.
- [ ] Evidence and confidence are recorded when available.
- [ ] Existing one-time payment work was considered.
- [ ] One-time payment behavior is distinguished from subscription behavior.
- [ ] No implementation details were invented.
- [ ] No Jira changes were made.
- [ ] No dependency graph changes were made.

## Output

Keep the result simple:

```text
Stripe One-Time Payments Capability

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
- stripe-docs
- verification

## Self-Improvement

Follow the common self-improvement standard in `../self-improvement/references/standard.md`.

Only propose a factory change when real evidence shows that repeated one-time-payment detection runs are missing an important capability or creating a recurring problem.
