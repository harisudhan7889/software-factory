# Capability Detection

Dependency planning may use capability-specific detection skills when a new or materially
changed ticket suggests a specialized implementation capability.

For Stripe recurring subscriptions, use `stripe-subscriptions` as a capability detector. For Stripe one-time payments, use `stripe-one-time-payments` as a capability detector. Route each capability separately and never merge them merely because both use Stripe.

The capability detector:

- identifies whether the requirement needs the relevant Stripe capability (recurring subscriptions or one-time payments)
- identifies high-level candidate capability areas
- provides reason, source, evidence, confidence, existing work, and unknowns

The capability detector does not:

- create or modify Jira tickets
- create Jira dependency links
- decide final ticket dependencies
- own the persistent dependency graph
- implement the capability

After capability detection, continue this skill's normal dependency analysis.

Treat capability output as candidate evidence, not as an automatic dependency.

For Stripe work, implementation guidance belongs to `stripe-best-practices`; consult current Stripe documentation directly (use a docs-lookup skill only when `skills/stripe-docs/SKILL.md` exists). Do not duplicate those implementation responsibilities here.

