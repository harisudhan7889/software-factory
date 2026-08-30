# Architecture Decision Record Standard

## Purpose

An Architecture Decision Record (ADR) documents a significant
architectural decision made during the development of the project.

An ADR should explain:

- why the decision was needed
- what decision was made
- what alternatives were considered
- what consequences result from the decision
- what risks or follow-up decisions remain

An ADR records an architectural decision. It is not an implementation
plan and it is not a Jira ticket.

## Location

Store ADRs under:

docs/adr/

## Naming convention

Use a sequential, zero-padded four-digit number followed by a
kebab-case short title.

Format:

docs/adr/NNNN-short-title.md

Examples:

docs/adr/
├── 0001-managed-first-architecture.md
├── 0002-background-job-strategy.md
└── 0003-document-processing.md

Numbers are assigned sequentially and must never be reused, including
for rejected ADRs.

Before creating an ADR:

1. Inspect the existing `docs/adr/` directory.
2. Find the highest existing ADR number.
3. Assign the next sequential number.
4. Never overwrite or reuse an existing ADR number.

## Statuses

| Status | Meaning |
|---|---|
| Proposed | Decision has been drafted and is awaiting approval |
| Accepted | Decision has been explicitly approved |
| Rejected | Decision was reviewed and rejected; the rationale is preserved |

A newly created ADR must normally start with:

**Status:** Proposed

An ADR must not be marked `Accepted` without explicit user approval.

## Required metadata

Every ADR must contain:

```markdown
# NNNN - Title

**Status:** Proposed
**Date:** YYYY-MM-DD
**Authors:** Name
