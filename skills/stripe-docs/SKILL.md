---
name: stripe-docs
description: Retrieves current Stripe documentation and API reference through the Stripe CLI documentation commands. Use when Stripe implementation work needs current documentation or API details. Prefer this skill over direct fetching of docs.stripe.com content.
---

# Stripe Docs

## Purpose

Provide the implementation agent with current Stripe documentation and API reference information.

This skill is a **documentation lookup skill**.

It does not:

- design the product
- choose the product architecture
- create Jira work
- implement Stripe code
- replace `stripe-best-practices`

## Responsibility

This skill answers:

> "What does the current Stripe documentation say?"

It should be used when current Stripe documentation or API reference details are needed.

Implementation decisions remain with the relevant project architecture and `stripe-best-practices`.

## When to Use

Use when:

- implementing a Stripe integration and current API behavior is needed
- checking a Stripe API resource or method
- checking a Stripe webhook event or API object
- confirming current Stripe integration guidance
- verifying a Stripe parameter, endpoint, or documentation page

Prefer this skill over directly fetching `docs.stripe.com` with `curl` or `WebFetch`.

## Primary Tool

Use the Stripe CLI documentation commands:

```text
stripe docs <web-path>
stripe docs search "<query>"
stripe docs api <resource>
stripe docs api <HTTP-method> <path>
stripe docs api <event-type>
```

Examples:

```text
stripe docs /payments
stripe docs search "subscriptions"
stripe docs api product
stripe docs api GET /v1/products
stripe docs api product.created
```

The Stripe documentation skill published in Stripe's official `stripe/ai` repository uses `stripe docs` as the purpose-built documentation interface for agents and recommends it over direct fetching of Stripe documentation.

## Lookup Workflow

Follow this order:

1. Identify the exact Stripe question.
2. Verify the `stripe docs` interface is available; if unavailable, do not invent results — report the tool gap and uncertainty per Boundaries, and use only a factory-approved fallback.
3. Prefer the narrowest relevant documentation lookup.
4. Read the returned documentation.
5. Use the result as current Stripe documentation evidence.
6. Apply the documentation to the approved project architecture.
7. Continue implementation using `stripe-best-practices` when implementation guidance is required.

Do not search broadly when a specific API resource or documentation path is known.

## Source of Truth

For Stripe API behavior, current Stripe documentation is the source of truth.

Do not rely on remembered Stripe API behavior when the current documentation can be checked.

Stripe's current official best-practices skill explicitly instructs agents to read the relevant Stripe reference before answering integration questions or writing code.

## Boundaries

This skill must not:

- invent Stripe behavior
- infer undocumented API behavior as fact
- replace current Stripe documentation with training-data memory
- decide whether Stripe is required for a product
- decide whether Stripe Connect is required
- create or modify Jira tickets
- modify the dependency graph
- expose secrets or credentials

When documentation is unclear or conflicting, report the uncertainty rather than guessing.

## Relationship to Other Stripe Skills

```text
stripe-subscriptions
        ↓
What capability is needed?

stripe-best-practices
        ↓
How should Stripe be integrated?

stripe-docs
        ↓
What does the current Stripe documentation say?

upgrade-stripe (only when skills/upgrade-stripe/SKILL.md exists)
        ↓
How should an existing Stripe integration be upgraded?
        ↓
connect-recommend (only when skills/connect-recommend/SKILL.md exists)
        ↓
Is Stripe Connect needed and which Connect model fits?
```

Do not duplicate the responsibilities of these skills.

## Documentation Evidence

When reporting a documentation lookup, include:

```text
Topic:
Lookup:
Relevant result:
Important current behavior:
Source:
```

Do not quote large sections of Stripe documentation.

Summarize the relevant information and retain the documentation path or API reference used.

## Current-Version Awareness

Do not hard-code Stripe API or SDK versions into project instructions unless the current official documentation supports them.

When version information matters:

1. look it up using current Stripe documentation
2. report the version found with its source path
3. follow the project's approved version strategy

Do not state a latest version from memory. Treat any remembered version as unverified until rechecked through a current lookup.

## Implementation Handoff

When a lookup is needed during implementation:

```text
implementation
    ↓
stripe-best-practices
    ↓
needs current Stripe detail
    ↓
stripe-docs
    ↓
current documentation evidence
    ↓
implementation continues
```

The lookup result should inform implementation; it does not authorize scope changes.

## Verification

Before reporting a documentation lookup as complete:

- [ ] The requested Stripe topic was identified.
- [ ] The current Stripe documentation was queried.
- [ ] The relevant result was read.
- [ ] Documentation behavior is clearly distinguished from inference.
- [ ] No unsupported Stripe behavior was invented.
- [ ] Lookup reported per Documentation Evidence template with Topic, Lookup, and Source path.
- [ ] No Jira or dependency-graph changes were made.



## Common Rationalizations


| Rationalization                               | Reality                                                  |
| --------------------------------------------- | -------------------------------------------------------- |
| "I remember how Stripe works"                 | Use current Stripe documentation when the detail matters |
| "The old API example is probably still valid" | Verify the current API documentation                     |
| "I can just curl docs.stripe.com"             | Prefer the Stripe CLI documentation interface            |
| "The docs lookup can decide the architecture" | Architecture remains owned by the project's RFC/ADR      |




## Red Flags

- API behavior stated without current documentation when a lookup was available
- Deprecated Stripe API patterns presented as current
- Documentation result treated as approval to change product scope
- Secrets or credentials included in lookup output
- Large copied sections of Stripe documentation returned unnecessarily



## Self-Improvement

Follow the common self-improvement standard in `../self-improvement/references/standard.md`.

Only propose a factory change when real evidence shows that repeated Stripe documentation lookups are missing an important capability or creating a recurring problem.