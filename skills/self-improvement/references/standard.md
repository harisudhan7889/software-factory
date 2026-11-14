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

## Memory — check before proposing

Before formulating any proposal, or re-raising an observation, check
this factory's memory so a settled question isn't silently redone:

- `factory/docs/self-improvement/rejected-proposals.md` — has this
  exact change already been proposed and declined? If the reasoning
  hasn't materially changed, surface the prior rejection and its
  rationale to the user and confirm they still want to proceed instead
  of silently re-proposing it.
- `factory/docs/self-improvement/known-limitations.md` — is this a
  known, already-recorded gap? If so, there is usually nothing new to
  report; just note that it is tracked there instead of re-describing
  it as a fresh finding.
- The current project's own `.factory/memory.md`, when the finding is
  project-scoped rather than factory-wide.

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
```

## Memory — what gets recorded, and where

An applied `Factory improvement` does not get a memory entry: the
skill/policy diff and its commit are already the record
(`policies/observability.md`: Git is the source of truth). Memory exists
only for findings that do **not** result in an immediate change:

| Classification | Record it in |
| --- | --- |
| 4. Factory improvement, **declined** by the user | `factory/docs/self-improvement/rejected-proposals.md` |
| 2. Known limitation | `factory/docs/self-improvement/known-limitations.md` |
| 1. Informational observation | the current project's `.factory/memory.md` |
| 3. Project-specific issue | the current project's `.factory/memory.md` |

Most runs should write nothing, in either place — the same restraint as
the Improvement threshold above applies to memory entries.

Each entry states: a dated heading, the Finding, the Evidence, the
affected artifact, and a `Status`. Factory-level statuses are `open` /
`resolved` / `wontfix` (known limitations) or `rejected` / `superseded`
(rejected proposals). Project-level entries in `.factory/memory.md` use
`open` / `resolved` / `wontfix` / `promoted`. When a run discovers that
an `open` entry has since been fixed elsewhere, update its status to
`resolved` with the fixing commit or PR instead of leaving it open or
deleting it — a memory that never gets marked resolved is as misleading
as one that was never written.

**Promotion.** A project-specific issue that evidence shows is not
actually project-specific — it recurs in another project, or is clearly
a defect in the shared factory artifact itself — may be promoted from
that project's `.factory/memory.md` into factory memory. Promotion does
not itself change any skill or policy: it only moves the finding into
`known-limitations.md` (or becomes a normal Improvement proposal,
subject to the same approval gate as any other factory change). Mark
the project-level entry's status `promoted` with a pointer to the new
factory-level entry.

**Why this lives in the repository.** This factory's own coding tool
may keep a private, per-account memory of its own. That mechanism does
not substitute for the memory defined here: it is invisible to a
teammate, to a different AI tool executing the same factory, and to
anyone reviewing a change in a Pull Request. Factory and project memory
must be ordinary committed files for the same reason RFCs and ADRs are.
