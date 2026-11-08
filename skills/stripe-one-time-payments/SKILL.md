---
name: stripe-one-time-payments
description: Detects when a product requirement needs a Stripe one-time payment capability and identifies candidate capability areas for ticket-dependency-planning. Use when a Jira ticket or approved product/technical source describes a one-time purchase or payment. Do not provide Stripe implementation guidance, create Jira tickets, modify Jira, or own the dependency graph.
---

# Stripe One-Time Payments

## Purpose

Detect whether a requirement needs the **Stripe one-time payments capability**
and identify the high-level work areas involved. This skill is a capability
detector and classifier. It does not explain how to implement Stripe.

Read `../../references/stripe-capability-detector.md` first. It defines the
shared rules: ownership, source review, decision values, handoff format,
incremental changes, boundaries, output template, and verification. This file
adds only what is specific to one-time payments.

## When to Use

Use when an approved source or Jira ticket describes a one-time purchase or
payment, paying a fixed amount to unlock a product or feature, buying a
product once, a one-off fee, or a single checkout transaction that is not a
subscription.

Do not use when the requirement clearly describes recurring billing; use
`stripe-subscriptions` for that.

Trigger signals: buy, purchase, one-time payment/purchase, pay once, single
payment, one-off payment, unlock for $X, checkout, payment, pay for product.

## Decision Criteria

- `REQUIRED`: the approved requirement clearly describes a one-time payment flow using Stripe.
- `CANDIDATE`: the wording strongly suggests a payment, but it is unclear whether it is one-time or recurring, or whether Stripe is the approved provider.
- `BLOCKED`: a one-time payment is intended but a product, payment-provider, or architecture decision is missing.

## Candidate Capability Areas

```text
Stripe One-Time Payment
├── product / one-time price setup
├── payment checkout flow
├── payment completion / fulfillment handling
└── application payment state
```

Existing work to check: one-time products or prices, checkout/payment flow,
payment completion or fulfillment handling, application payment state.

## One-Time vs Subscription

One-time: the user pays once for a product, feature, service, or fee.
Subscription: the user is charged on a recurring cadence (weekly, monthly,
yearly). If a requirement supports both, report both capabilities separately
and hand both to `ticket-dependency-planning`.

## Examples

**Clear purchase.** "User can buy the premium template for $20 once." Decision
`REQUIRED`; detected one-time purchase and single payment; areas: product /
one-time price setup, payment checkout flow, payment completion / fulfillment
handling. Stop at the handoff.

**Payment flow only.** "User can pay once for the selected product and
continue after successful payment." Decision `REQUIRED`; areas: payment
checkout flow, payment completion / fulfillment handling. Identify application
payment state only when the approved behavior needs the application to persist
or query it.

**Pricing UI only.** "Show the product price and a Buy Now button." Decision
`NOT_REQUIRED`, unless an approved source says the button starts a one-time
Stripe payment flow.

**Mixed.** "Users can buy the Starter package once or subscribe to Pro
monthly." One-time payments `REQUIRED` and subscriptions `REQUIRED`, as two
separate capabilities.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Buy or checkout is mentioned, so a Stripe payment is required." | A keyword is only a signal; decide from the criteria and approved sources. |
| "The wording fits both, so treat it as one capability." | Distinguish one-time from subscription; report both separately when both apply. |
| "The purchase intent is obvious, skip the evidence." | Record reason, source, evidence, and confidence for the handoff. |

## Red Flags

- Checkout, webhook, schema, or secret implementation details appear instead of stopping at the handoff.
- A Jira ticket is created or modified, or the dependency graph is updated.
- Subscription and one-time capabilities are merged because both use Stripe.
- Invented amounts, currencies, taxes, refunds, discounts, or payment methods.

## Verification

Complete the shared checklist in `../../references/stripe-capability-detector.md`, plus:

- [ ] Existing one-time payment work was considered.
- [ ] One-time behavior was distinguished from subscription behavior.

## Self-Improvement

Follow `../self-improvement/references/standard.md`.
