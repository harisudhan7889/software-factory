---
name: stripe-best-practices
description: Guides agents through secure Stripe integration decisions and implementation planning for web applications. Use when an approved PRD, RFC, or Jira story requires Stripe payments, Checkout, Payment Element, billing, subscriptions, webhooks, tax, or related Stripe integration work. Do not use when the project does not require Stripe.
---

# Stripe Best Practices

## Purpose

Provide current, secure, and appropriate Stripe guidance when a project requires
Stripe.

This skill helps the agent choose the right Stripe integration, follow secure
patterns, and verify the implementation.

It does not decide whether a product needs payments. That decision comes from
approved product and architecture sources.

## When to Use

Use this skill when an approved project requirement includes:

- One-time payments
- Stripe Checkout
- Payment Element
- Saving payment methods
- Subscriptions or recurring billing
- Stripe webhooks
- Stripe Tax
- Other Stripe payment or billing integration work

Use the relevant Stripe documentation when exact or current API details are
needed.

## When Not to Use

Do not use this skill when:

- The project does not require Stripe.
- The task is unrelated to Stripe.
- The task is only a general UI change with no Stripe integration.
- The task is a Stripe Dashboard operation unrelated to the application's
  integration.

For Stripe Connect marketplace or multi-party payment architecture, use the
approved Connect-specific capability when available.

## Inputs

Use the approved sources available for the task:

- PRD
- RFC
- ADR
- UX/UI requirements
- Jira Story
- Existing implementation
- Existing Stripe integration

Treat each source according to its authority.

Do not invent payment requirements.

## Workflow

Follow this order:

1. Read the relevant approved product, architecture, and Jira sources.
2. Confirm why Stripe is required and identify the payment use case.
3. Choose the appropriate Stripe integration pattern.
4. Read the relevant current Stripe documentation/reference.
5. Check the project's approved backend and trusted-boundary architecture.
6. Plan the Stripe integration.
7. Implement through the normal `implementation` workflow.
8. Verify payment, webhook, security, and failure behavior.
9. Report evidence for the completed checks.

Do not silently change the approved architecture.

## Integration Routing

Use the simplest appropriate Stripe product.

Typical routing:

```text
Simple one-time payment
→ Checkout

Custom embedded payment experience
→ Checkout + Payment Element

Save a payment method for later use
→ SetupIntent

Subscription / recurring billing
→ Billing + Checkout

Marketplace / money movement between parties
→ Stripe Connect
```

For current API choices, exact parameters, and supported behavior, consult the
current Stripe documentation.

Prefer higher-level Stripe solutions when they satisfy the requirement.

Do not default to low-level PaymentIntents when Checkout or another
higher-level Stripe product is appropriate.

## Checkout

For normal web payments, prefer Stripe Checkout when it meets the product
requirements.

Checkout may be:

- Stripe-hosted
- Embedded

Choose based on the approved UX/UI requirements.

Do not build a custom card-entry experience when Checkout or Payment Element
already satisfies the approved requirement.

## Payment Element

Use Payment Element when the project requires a more customized embedded
payment experience.

Follow the current Stripe documentation for:

- Checkout Session integration
- client/server boundaries
- payment state
- supported payment methods
- confirmation flow

Do not invent Stripe API parameters.

## Payment Methods

Do not hard-code `payment_method_types` unless the specific integration
requires it and current Stripe documentation confirms the requirement.

Prefer Stripe's dynamic payment-method behavior when appropriate.

## Webhooks

Webhooks are part of the payment architecture.

Do not treat a success page as the source of truth for fulfillment.

For payment integrations:

- Verify webhook signatures.
- Process relevant webhook events securely.
- Make handlers idempotent.
- Handle retries safely.
- Update application state from trusted webhook processing.
- Do not grant access or fulfill an order only because a browser reached a
  success URL.

For asynchronous payment methods, follow the current Stripe event and
fulfillment guidance.

For subscriptions, use webhook events to keep application state synchronized.

## Stripe and Supabase

For projects using the factory-standard remote/managed Supabase architecture:

```text
Customer
  ↓
Web application
  ↓
Stripe
  ↓
Trusted webhook/server-side boundary
  ↓
Supabase
```

The exact implementation must follow the project's RFC and ADRs.

Use Supabase Edge Functions or another approved trusted boundary when the
project architecture supports that approach.

Never place Stripe secret keys, webhook secrets, or privileged Supabase
credentials in browser-accessible code.

Follow:

```text
policies/security.md
factory/docs/adr/0002-default-web-backend-architecture/overview.md
```

## API Keys and Secrets

Never commit or expose:

- Stripe secret keys
- Stripe restricted API keys
- Stripe webhook signing secrets
- Supabase service-role keys
- Database credentials
- Other secrets

Use the project's approved secret-management mechanism.

Prefer least-privilege Stripe restricted API keys when appropriate for the
integration.

Never print or expose environment variables through application endpoints,
error pages, logs, or UI.

## Stripe Client Usage

Use the current Stripe SDK pattern for the project's language.

Do not use deprecated global/module-level API-key initialization patterns when
the current SDK provides an instance-based client.

Read current Stripe documentation before writing integration code.

## Integration Identifiers

When the project's Stripe API version and current Stripe guidance require an
integration identifier for Checkout Sessions, use the documented parameter and
current format.

Do not add parameters based on outdated examples.

## Tax

Do not enable Stripe Tax automatically.

Before enabling automatic tax or implementing tax calculation:

- Confirm the approved product requirement needs it.
- Read current Stripe Tax documentation.
- Confirm required registrations or configuration.
- Verify the resulting behavior.

Do not claim tax is collected merely because an automatic-tax setting was
enabled.

## Subscriptions

For subscription work:

- Use Stripe Billing and Checkout where appropriate.
- Treat webhook processing as required.
- Handle subscription lifecycle events.
- Keep application subscription state synchronized with Stripe.
- Handle cancellation, payment failure, and status changes.
- Do not trust only the browser success page.

Follow the current Stripe billing documentation for exact events and API
behavior.

## Customer State and Fulfillment

Do not assume payment completion from:

- A button click
- A redirect
- A browser success page
- A client-side state change

Use trusted Stripe results and webhook processing to drive durable application
state.

Make fulfillment operations idempotent so repeated webhook delivery does not
create duplicate results.

## Testing

Stripe payment work should include appropriate tests for:

- Successful payment
- Failed payment
- Cancelled checkout when relevant
- Webhook signature validation
- Duplicate webhook delivery
- Asynchronous payment outcomes when applicable
- Subscription lifecycle events when applicable
- Authorization around payment-related application state
- Secret handling

Use Stripe test mode and approved test mechanisms.

Do not use real production credentials for development or testing.

## Stripe Documentation

Use current Stripe documentation as the source for exact API behavior.

When the project has access to the Stripe CLI documentation lookup capability,
use the `stripe docs` workflow for current Stripe documentation.

Do not rely on remembered API behavior when current documentation can be
checked.

## Compatibility and Upgrades

When an implementation changes Stripe API versions or SDK versions:

- Identify the current version.
- Review the relevant Stripe changelog or migration guidance.
- Check breaking changes.
- Update the integration.
- Run appropriate tests.
- Verify webhooks and related behavior.

For dedicated upgrade work, follow this section's changelog/breaking-change steps; use the `upgrade-stripe` skill only when `skills/upgrade-stripe/SKILL.md` exists.

## Scope Control

This skill must not:

- Decide that a product needs payments.
- Change product requirements.
- Change approved architecture.
- Introduce Stripe Connect without an approved marketplace or
  multi-party-payment requirement.
- Expose secrets.
- Bypass security controls.
- Change unrelated application code.

Use the normal `implementation` workflow for production changes.

## Policy References

Read only policies relevant to the current task.

Potentially relevant:

- `policies/security.md` — secrets, trust boundaries, authentication,
  external services
- `policies/verification.md` — testing and evidence
- `policies/guardrails.md` — scope and approval boundaries
- `policies/observability.md` — significant execution records
- `policies/dependency-safety.md` — Stripe SDK/dependency changes

Use the factory backend decision:

- `factory/docs/adr/0002-default-web-backend-architecture/overview.md`

Do not load irrelevant policies only because they exist.

## Verification

Before reporting Stripe integration work complete:

- [ ] The Stripe use case matches the approved product and architecture.
- [ ] The chosen Stripe integration is appropriate.
- [ ] Current Stripe documentation was checked for exact API behavior.
- [ ] Stripe secrets remain server-side.
- [ ] Webhook signatures are verified.
- [ ] Webhook processing is idempotent.
- [ ] Fulfillment does not rely only on the browser success page.
- [ ] Payment failure paths are handled.
- [ ] Subscription behavior is handled when applicable.
- [ ] Relevant tests pass.
- [ ] No unrelated architecture or scope changes were introduced.

Use `policies/verification.md` for evidence requirements.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| The success page proves payment | Durable payment state should come from trusted Stripe processing and webhooks |
| Put the Stripe secret in the frontend | Secret keys and webhook secrets must remain in the trusted server-side boundary |
| Use PaymentIntents for everything | Prefer the simplest appropriate Stripe integration |
| Skip webhook handling for a simple payment | Webhooks are part of the payment architecture |
| Copy an old Stripe API example | Check the current Stripe documentation before implementing |
| Add Stripe because most projects need it | Stripe is used only when the approved product actually requires it |
| Add Connect automatically | Connect is for marketplace or multi-party payment requirements |

## Red Flags

- Stripe secret or webhook signing secret appears in browser code.
- Payment fulfillment depends only on a success-page redirect.
- Webhook signature verification is missing.
- Webhook handler is not safe against duplicate delivery.
- A deprecated Stripe API pattern is used without current documentation support.
- A Stripe payment method configuration is hard-coded without a documented
  reason.
- Stripe Connect is introduced without an approved multi-party payment need.
- A custom payment implementation is created when an appropriate Stripe
  higher-level product already satisfies the requirement.
- Production Stripe credentials are used for development or testing.

## Observability

For significant Stripe integration work, record enough information to trace:

```text
Run ID
Agent
Project
Jira task
Stripe capability used
Integration type
Verification result
```

Do not record:

- API keys
- Webhook signing secrets
- Customer payment credentials
- Unnecessary sensitive customer data

Follow `policies/observability.md`.

## Self-Improvement

Review Stripe integration work for:

- Repeated integration mistakes
- Missing verification checks
- Outdated API assumptions
- Repeated security problems
- Unnecessary Stripe complexity

Only propose changes when real evidence shows that the current skill needs
improvement.

Follow the common self-improvement standard in:

`../self-improvement/references/standard.md`
