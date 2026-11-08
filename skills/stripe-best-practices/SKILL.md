---
name: stripe-best-practices
description: Guides agents through secure Stripe integration decisions and implementation planning for web applications. Use when an approved PRD, RFC, or Jira story requires Stripe payments, Checkout, Payment Element, billing, subscriptions, webhooks, tax, or related Stripe integration work. Do not use when the project does not require Stripe.
---

# Stripe Best Practices

## Purpose

Provide current, secure Stripe guidance when a project requires Stripe: choose
the right integration, follow secure patterns, and verify the result. This
skill does not decide whether a product needs payments; approved product and
architecture sources decide that.

## When to Use

Use when an approved requirement includes one-time payments, Stripe Checkout,
Payment Element, saving payment methods, subscriptions or recurring billing,
webhooks, Stripe Tax, or other Stripe payment or billing integration work.

Do not use when the project does not require Stripe, the task is unrelated to
Stripe or is a general UI change, or the task is a Stripe Dashboard operation
unrelated to the application's integration. For Connect marketplace or
multi-party payment architecture, use the approved Connect capability when
available.

## Inputs

Use the approved sources available, each according to its authority: PRD, RFC,
ADR, UX/UI requirements, Jira Story, existing implementation, existing Stripe
integration. Do not invent payment requirements.

## Workflow

1. Read the relevant approved product, architecture, and Jira sources.
2. Confirm why Stripe is required and identify the payment use case.
3. Choose the Stripe integration pattern (see Integration Routing).
4. Read the current Stripe documentation for exact API behavior. When the Stripe CLI docs lookup is available, use `stripe docs` or the `stripe-docs` skill. Do not rely on remembered API behavior or outdated examples.
5. Check the approved backend and trusted-boundary architecture.
6. Plan, then implement through the normal `implementation` workflow.
7. Verify payment, webhook, security, and failure behavior, and report evidence.

Do not change the approved architecture silently.

## Integration Routing

Use the simplest appropriate Stripe product. Prefer higher-level products over
low-level PaymentIntents when they satisfy the requirement.

| Need | Use |
|---|---|
| Simple one-time payment | Checkout |
| Custom embedded payment experience | Checkout + Payment Element |
| Save a payment method for later | SetupIntent |
| Subscription / recurring billing | Billing + Checkout |
| Marketplace / money movement between parties | Stripe Connect (only with an approved multi-party requirement) |

- **Checkout** is the default for normal web payments, Stripe-hosted or embedded, chosen from the approved UX/UI. Do not build custom card entry when Checkout or Payment Element satisfies the requirement.
- **Payment Element** is for more customized embedded experiences. Follow current docs for the Checkout Session integration, client/server boundaries, payment state, supported methods, and confirmation flow. Do not invent API parameters.
- **Payment methods:** do not hard-code `payment_method_types` unless the integration requires it and current docs confirm it. Prefer dynamic payment methods.
- **Integration identifiers:** when the API version and current guidance require one for Checkout Sessions, use the documented parameter and format.
- **SDK client:** use the current instance-based client for the project's language, not deprecated global API-key initialization.

## Webhooks, Fulfillment, and Subscriptions

Webhooks are part of the payment architecture. A button click, redirect,
browser success page, or client-side state change is never proof of payment.

- Verify webhook signatures.
- Process relevant events securely, with idempotent handlers that survive retries and duplicate delivery.
- Drive durable application state and fulfillment from trusted Stripe results and webhook processing; never grant access only because a browser reached a success URL.
- For asynchronous payment methods, follow current Stripe event and fulfillment guidance.
- For subscriptions, use Billing and Checkout, handle lifecycle events, keep application subscription state synchronized with Stripe, and handle cancellation, payment failure, and status changes. Follow current billing docs for exact events.

## Stripe and Supabase

For the factory-standard managed Supabase architecture the flow is: customer →
web application → Stripe → trusted webhook/server-side boundary → Supabase.
Follow the project's RFC and ADRs (`factory/docs/adr/0002-default-web-backend-architecture/overview.md`)
and use Supabase Edge Functions or another approved trusted boundary. Never
place Stripe secret keys, webhook secrets, or privileged Supabase credentials
in browser-accessible code.

## API Keys and Secrets

Never commit or expose Stripe secret keys, restricted API keys, webhook signing
secrets, Supabase service-role keys, database credentials, or other secrets.
Use the project's approved secret-management mechanism, prefer least-privilege
restricted keys, and never print environment variables through endpoints,
error pages, logs, or UI. Follow `policies/security.md`.

## Tax

Do not enable Stripe Tax automatically. First confirm the approved requirement
needs it, read the current Stripe Tax docs, confirm required registrations and
configuration, and verify the resulting behavior. An automatic-tax setting
alone does not mean tax is collected.

## Testing

Test with Stripe test mode and approved mechanisms; never use production
credentials for development or testing. Cover: successful payment, failed
payment, cancelled checkout when relevant, webhook signature validation,
duplicate webhook delivery, asynchronous outcomes and subscription lifecycle
events when applicable, authorization around payment-related state, and secret
handling.

## Compatibility and Upgrades

When changing Stripe API or SDK versions: identify the current version, review
the changelog or migration guidance, check breaking changes, update the
integration, run tests, and verify webhooks. Use the `upgrade-stripe` skill
only when `skills/upgrade-stripe/SKILL.md` exists.

## Scope Control

This skill must not decide that a product needs payments, change product
requirements or approved architecture, introduce Connect without an approved
requirement, expose secrets, bypass security controls, or change unrelated
code. Use the `implementation` workflow for production changes.

## Policies

Read only the relevant ones: `policies/security.md` (secrets, trust
boundaries), `policies/verification.md` (testing and evidence),
`policies/guardrails.md` (scope and approval), `policies/observability.md`
(significant execution records), `policies/dependency-safety.md` (Stripe SDK
changes). For significant work record run ID, agent, project, Jira task,
Stripe capability, integration type, and verification result, never API keys,
webhook secrets, payment credentials, or unnecessary customer data.

## Verification

Before reporting Stripe work complete:

- [ ] The use case and chosen integration match the approved product and architecture.
- [ ] Current Stripe documentation was checked for exact API behavior.
- [ ] Stripe secrets remain server-side.
- [ ] Webhook signatures are verified and processing is idempotent.
- [ ] Fulfillment does not rely only on the browser success page.
- [ ] Payment failure paths and subscription behavior (when applicable) are handled.
- [ ] Relevant tests pass, with no unrelated architecture or scope changes.

Use `policies/verification.md` for evidence requirements.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The success page proves payment." | Durable state comes from trusted Stripe processing and webhooks. |
| "Put the Stripe secret in the frontend." | Secret keys and webhook secrets stay in the trusted server-side boundary. |
| "Use PaymentIntents for everything." | Prefer the simplest appropriate Stripe integration. |
| "Skip webhooks for a simple payment." | Webhooks are part of the payment architecture. |
| "Copy an old Stripe example." | Check current Stripe documentation first. |
| "Add Stripe or Connect because most projects need it." | Use Stripe only when the approved product requires it, and Connect only for multi-party payments. |

## Red Flags

- A Stripe secret or webhook signing secret appears in browser code.
- Fulfillment depends only on a success-page redirect.
- Webhook signature verification is missing, or the handler is unsafe under duplicate delivery.
- A deprecated API pattern or hard-coded payment method configuration has no documented reason.
- Connect is introduced without an approved multi-party need.
- A custom payment implementation exists where a higher-level Stripe product fits.
- Production credentials are used for development or testing.

## Self-Improvement

Follow `../self-improvement/references/standard.md`. Review Stripe work for
repeated integration mistakes, missing checks, outdated API assumptions,
repeated security problems, and unnecessary complexity. Propose changes only on
real evidence.
