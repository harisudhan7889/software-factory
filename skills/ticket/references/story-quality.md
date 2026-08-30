# Application Development Story Quality

## Purpose

Ensure RFC-derived Jira Stories represent concrete application or
technical capabilities rather than milestones, phases, workstreams,
or project-management activities.

## What a good Story represents

A Story should represent one:

- User capability
- Product capability
- System capability
- Concrete technical capability required to enable the product
- Observable application behavior

The Story should be independently implementable and verifiable.

## What is NOT a Story

Do not use these directly as Story summaries:

- Milestones
- Phases
- M0/M1/M2/M3 labels
- Workstreams
- Project stages
- Broad initiatives
- MVP vertical slice
- Security hardening
- Monitoring
- Evaluation
- "Backend work"
- "Frontend work"

Do not simply copy section headings from an RFC into Jira Stories.

Translate them into concrete capabilities.

## Story test

Before proposing a Story, answer:

1. What capability is being built?
2. Who or what uses it?
3. What observable behavior exists when it is complete?
4. Can it be independently implemented?
5. Can it be independently verified?
6. Does it have a clear boundary?

If these cannot be answered, reconsider whether the item is actually a Story.

## Split broad work

If an RFC item contains multiple capabilities, split it.

For example:

"Billing, metering + agency workspaces"

should become separate Stories such as:

- Track usage against an agency plan
- Enforce usage limits
- Allow agencies to manage clinic workspaces

Do not combine unrelated capabilities into one Story.

## Summary style

Use concise, action-oriented capability statements.

Prefer:

"Allow users to submit marketing content for compliance checking"

over:

"M1: MVP vertical slice"

Prefer:

"Display compliance violations with rule explanations"

over:

"MVP compliance reporting"

Prefer:

"Allow users to revise flagged content and re-run the compliance check"

over:

"M2: Rewrite + re-check loop"

Prefer:

"Store each compliance check as an audit record"

over:

"M3: Audit record, hash chain + PDF export"

Do not include milestone identifiers such as M0, M1, M2 or S7 in Story
summaries unless they are explicitly part of the product domain.

## Technical work

Technical work can be a Story when it represents a concrete,
necessary capability.

Prefer:

"Store compliance results with an immutable audit identifier"

over:

"Audit infrastructure"

Prefer:

"Validate uploaded images before compliance analysis"

over:

"Image processing backend"

Prefer:

"Record model evaluation results for each compliance rule"

over:

"Evaluation monitoring"

## Quality check

Before presenting the final RFC-derived Jira structure, review every
proposed Story against this reference.

Rewrite or split Stories that fail the Story test.
