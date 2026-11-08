---
name: stripe-subscriptions
description: Detects when a product requirement needs Stripe recurring subscriptions and identifies candidate capability areas for ticket-dependency-planning. Use when a Jira ticket or approved product/technical source describes subscriptions or recurring billing. Do not provide Stripe implementation guidance, create Jira tickets, modify Jira, or own the dependency graph.
---

# Stripe Subscriptions

## Purpose

Detect whether a requirement needs the **Stripe Subscriptions capability** and
identify the high-level work areas involved. This skill is a capability
detector and classifier. It does not explain how to implement Stripe.

Read `../../references/stripe-capability-detector.md` first. It defines the
shared rules: ownership, source review, decision values, handoff format,
incremental changes, boundaries, output template, and verification. This file
adds only what is specific to subscriptions.

## When to Use

Use when an approved source or Jira ticket describes subscriptions, recurring
billing or payments, weekly/monthly/yearly plans, paid membership plans, users
subscribing to a service, or a subscription-related Stripe Checkout flow.

Do not use only because the word `Stripe` appears. Inspect the actual
requirement. For a single payment, use `stripe-one-time-payments`.

Trigger signals: subscribe, subscription, recurring (billing/payment),
monthly, weekly, yearly, annual, paid plan, membership plan, Stripe Checkout,
Stripe payment page.

Related decisions that belong elsewhere: API/SDK upgrades follow the approved
RFC/ADR plus the current Stripe changelog (`upgrade-stripe` only if it
exists). Connect marketplace decisions follow approved product/architecture
sources.

## Decision Criteria

- `REQUIRED`: the approved requirement clearly describes recurring subscription behavior.
- `CANDIDATE`: the wording strongly suggests subscriptions but the behavior is not confirmed.
- `BLOCKED`: subscriptions are intended but an important product or architecture decision is missing.

## Candidate Capability Areas

```text
Stripe subscription capability
├── plan / recurring price setup
├── subscription checkout/payment flow
├── subscription lifecycle handling
└── application subscription state
```

Existing work to check: recurring plans, subscription checkout flow,
subscription lifecycle integration, application subscription state.

## Examples

**Full subscription.** "Users can subscribe to weekly, monthly, or yearly
plans." Decision `REQUIRED`; detected recurring subscription with weekly,
monthly, and yearly cadence; all four capability areas. Stop at the handoff.

**Payment page only.** "Navigate to the Stripe payment page for the selected
monthly plan." Decision `CANDIDATE` or `REQUIRED`, depending on the approved
product flow. Areas: plan / recurring price setup, subscription
checkout/payment flow. Identify lifecycle or application-state work only when
the approved requirement needs it.

**Pricing UI only.** "Show monthly and yearly pricing options on the pricing
page." Decision `NOT_REQUIRED`, unless an approved source says selecting a
plan starts a Stripe subscription flow.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Monthly is mentioned, so subscription is required." | A keyword is only a signal; decide from the criteria and approved sources. |
| "Stripe is mentioned, so subscriptions are needed." | Use `NOT_REQUIRED` when no recurring behavior is described. |
| "The intent is obvious, skip the evidence." | Record reason, source, evidence, and confidence for the handoff. |

## Red Flags

- Stripe implementation guidance appears in the output.
- Jira tickets are created or modified, or the dependency graph is updated.
- A capability is reported as needed without source evidence.
- Invented prices, currencies, trials, discounts, or plan names.

## Verification

Complete the shared checklist in `../../references/stripe-capability-detector.md`, plus:

- [ ] Existing subscription work was considered.
- [ ] A one-time payment was not reported as a subscription.

## Self-Improvement

Follow `../self-improvement/references/standard.md`.
