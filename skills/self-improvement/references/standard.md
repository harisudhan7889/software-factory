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
  project-scoped rather than factory-wide. Its `## Standing rules`
  rows (see "Memory — standing rules") are rules the project has
  already adopted; do not propose a change that breaks an `active` one.

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

**No project specifics in factory memory.** Entries in
`factory/docs/self-improvement/` are shared by every project and live in
the factory repository. They MUST NOT contain project names, repository
names, Jira keys, customer or user data, or project code. Evidence in a
factory entry shows how the factory behaved, not what a project
contained. Write "the step posted a duplicate reply", not the PR number,
repository, or ticket where it happened. Project specifics belong only
in that project's `.factory/memory.md`. Before writing a factory entry,
check the text for these items and remove them.

**Promotion.** A project-specific issue that evidence shows is not
actually project-specific — it recurs in another project, or is clearly
a defect in the shared factory artifact itself — may be promoted from
that project's `.factory/memory.md` into factory memory. Promotion does
not itself change any skill or policy: it only moves the finding into
`known-limitations.md` (or becomes a normal Improvement proposal,
subject to the same approval gate as any other factory change).

Promotion writes a new, generic entry. Do not copy the project entry.
Rewrite the finding and evidence without project specifics, show the
rewritten text to the user, and save it only after the user approves.
Then mark the project-level entry's status `promoted` with a pointer to
the new factory-level entry. The pointer goes one way only: the project
entry points to the factory entry, and the factory entry never points
back to the project.

**Why this lives in the repository.** This factory's own coding tool
may keep a private, per-account memory of its own. That mechanism does
not substitute for the memory defined here, and recording a finding
only there does not satisfy this standard: it is invisible to a
teammate, to a different AI tool executing the same factory, and to
anyone reviewing a change in a Pull Request. Factory and project memory
must be ordinary committed files for the same reason RFCs and ADRs are.
Before closing out any run that identified a classification 1-3
finding, confirm the entry was actually written to the table above
(`known-limitations.md`, `rejected-proposals.md`, or the project's
`.factory/memory.md`) — a note saved only to a private memory tool is
the same, for this standard's purposes, as not having recorded it at
all.

## Memory — standing rules

A **standing rule** is a general, reusable rule that a person states
in a Pull Request review and that the project should follow beyond that
one fix. Examples are an architecture, API-design, testing, security, or
process rule. It is not an observation about the factory, so it is not
one of the four classifications above. It has its own record.

**Where.** The current project's `.factory/memory.md`, in a
`## Standing rules` section. Create the section when the first
rule is recorded. Use one table:

```markdown
## Standing rules

| ID | Rule | Rationale | Source | Status |
| --- | --- | --- | --- | --- |
| SR-001 | API route handlers MUST validate request bodies with the shared zod schema. | Unvalidated input reaches the database. | PR #12, @reviewer, 2026-11-26 | active |
```

`ID` is `SR-NNN`, numbered in order and never reused. `Status` is
`active`, `superseded` (with a pointer to the replacing ID), or
`promoted` (with a pointer to the factory-level entry). Never delete a
row. A rule that no longer holds is marked `superseded`, so the
history of the rule survives.

**Writer.** `/factory pr address-comments`, Phase 11, is the writer
today (`skills/factory/references/address-comments.md`). Any other run
may record a rule only under the conditions below.

**Readers.** Read the `active` rows before acting. They bind
`/implementation work`, `/factory pr review`, and
`/factory pr address-comments` in that project. A standing rule never
overrides an approved PRD, RFC, ADR, or policy (`GR-AUTHORITY-001`).

**Conditions for a row.**

1. **Source.** Record only a rule that a person stated. Never record one
   that only a bot stated (for example a Copilot finding). Record the
   Pull Request number, the reviewer, and the date.
2. **Absolute wording.** Use `MUST`, `MUST NOT`, `REQUIRED`, `SHALL`, or
   `SHALL NOT`, in uppercase. Do not use `SHOULD`, `MAY`, `RECOMMENDED`,
   `OPTIONAL`, or hedges such as `generally`, `prefer`, or `where
   possible`. Name the concrete scope: a type, layer, or file glob. If the
   comment cannot be reduced to an absolute rule, do not record it.
3. **General.** The rule must hold for a whole type, layer, or file glob,
   not for one file, function, or ticket. Apply this test: if the rule
   only makes sense for a single named file or function, it is a fix, not
   a rule. Do not record it silently. Tell the user it is too narrow, and
   offer to widen it to the layer it belongs to, or to skip it. Record a
   narrow rule only if the user confirms that it is a deliberate rule.
4. **Concise.** One rule per row. The rule is one sentence of at most
   30 words. The rationale is one clause of at most 15 words and states
   the consequence of breaking the rule. Keep exact identifiers, paths,
   and flags unchanged. No code blocks, no story of the PR.
5. **No duplicates.** Compare with every `active` row. If one already
   covers it, add nothing. If the new rule narrows or strengthens a row,
   rewrite that row in place within these limits.
6. **No conflict with authority.** If the rule contradicts an approved
   policy, RFC, ADR, or PRD, do not record it. Report the conflict. If it
   contradicts an `active` row, show both to the user and let them decide.
   Mark the losing row `superseded`.
7. **Approval.** A rule changes what future runs do. Show each row
   exactly as it would be written and record it only after the user
   approves it. The user may edit or reject any row.
8. **No secrets.** Never write a secret or credential into a row
   (`SEC-SECRET-001`).

**Promotion.** A rule that is not specific to one project, or that
the factory itself should enforce, is not recorded as a project row. It
is a Factory Improvement Proposal (above), with the same approval gate.
When it is approved and applied, mark the project row `promoted` with a
pointer to the changed artifact.

The "Why this lives in the repository" rule above applies in full. A
rule saved only to a coding tool's private memory has not been
recorded.
