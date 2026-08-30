# Self-Improvement Standard

## Purpose

Define the common self-improvement behavior used by software factory
skills and workflows.

The purpose is to improve future runs based on real evidence, not to
generate cosmetic or hypothetical changes.

## Review trigger

At the end of a significant skill or workflow run, review whether:

- A step failed.
- A step required a workaround.
- The workflow behaved differently from its documented behavior.
- The user corrected, rejected, or meaningfully reworked something.
- The run revealed something a future run needs.
- A real mistake could recur without a factory change.

## Improvement threshold

Propose an improvement only when it would:

- change what a future run actually does, or
- prevent recurrence of a real mistake.

Do not propose:

- cosmetic changes,
- wording-only changes with no behavioral benefit,
- hypothetical improvements,
- changes based only on speculation,
- changes merely for consistency.

Most runs should produce no improvement proposal.

## Classification

For each significant observation, classify it as exactly one of:

1. Informational observation
2. Known limitation
3. Project-specific issue
4. Factory improvement

Only `Factory improvement` should normally produce a change proposal.

## Improvement proposal

When a factory improvement is identified, the AI must formulate the
complete proposal.

The proposal must contain:

- Finding
- Root cause
- Evidence
- Exact affected artifact path
- Current behavior
- Proposed update
- Expected benefit

Use:

```text
Factory Improvement Proposal

Finding:
<what happened>

Root cause:
<why it happened>

Evidence:
<evidence from the current run>

Affected artifact:
<exact file path>

Current behavior:
<what the artifact currently says or does>

Proposed update:
<exact change to make>

Expected benefit:
<how future runs improve>
