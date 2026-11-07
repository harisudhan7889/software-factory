# RFC Breakdown --- Ticket Planning and Filing Procedure

## Purpose

Turn an approved RFC into a reviewable, dependency-aware set of Jira
tickets, then update the RFC Work breakdown table with the actual Jira
keys. This procedure plans and files work; it does not implement the
tickets.

## Ownership boundaries

-   **RFC breakdown** owns translating the approved RFC into a phased
    ticket proposal, checking dependency/file-scope completeness,
    getting approval, coordinating ticket creation, and updating the RFC
    Work breakdown table.
-   **Ticket dependency planning** owns dependency analysis, dependency
    validation, and parallel-safety recommendations. Reuse
    `skills/ticket-dependency-planning/SKILL.md`; do not create a second
    dependency-planning system.
-   **Ticket** owns Jira ticket creation and other Jira operations. Use
    the existing ticket skill's documented create workflow; do not
    duplicate its Jira API or ticket-creation implementation here.
-   **RFC build** owns implementing already-filed tickets in safe waves.
    Breakdown must not dispatch implementation work.
-   **Implementation** owns the implementation plan, approval gate,
    coding, and verification for an individual ticket.

## Inputs and prerequisites

Usage:

``` text
/rfc breakdown <NNNN | path-to-overview.md>
```

Resolve an RFC number to exactly one `docs/rfc/NNNN-*/overview.md`, or
use the supplied overview path.

Before proceeding:

1.  Read the RFC overview and relevant platform-specific design
    documents.
2.  Confirm the RFC is approved/accepted according to the repository's
    existing status conventions. If status is unclear or not approved,
    stop and ask the user.
3.  Confirm the RFC contains sufficient goals, non-goals, design
    decisions, implementation phases, and acceptance criteria to plan
    tickets. Identify gaps rather than inventing requirements.
4.  Read `skills/ticket/SKILL.md`,
    `skills/ticket-dependency-planning/SKILL.md`, and applicable
    policies, including `policies/guardrails.md` and
    `policies/git-safety.md` if present.
5.  Confirm Jira access and the ticket skill's documented creation
    operation are available. If not, produce the proposed breakdown
    only; do not pretend tickets were filed.
6.  Inspect the existing RFC Work breakdown table, if any. Preserve
    valid existing ticket rows and avoid creating duplicates.

## Phase 1 --- Derive candidate tickets

Translate the approved RFC into small, reviewable implementation
tickets.

For each candidate ticket, define:

-   **Title / summary:** specific, action-oriented, and distinguishable
    from other tickets.
-   **Purpose:** the outcome and why it is needed.
-   **Scope:** concrete work included in the ticket.
-   **Out of scope:** nearby work explicitly excluded.
-   **Acceptance criteria:** observable, testable conditions for
    completion.
-   **Verification:** appropriate tests, checks, or evidence expected.
-   **Phase:** the RFC phase or milestone this ticket belongs to.
-   **Depends-on:** prerequisite ticket keys once filed, or stable
    temporary references in the proposal.
-   **Files:** likely file paths or directories expected to change,
    including relevant tests and configuration.
-   **Risks / assumptions:** uncertainties, migration or security
    concerns, and decisions that need user input.

Split work so that each ticket has a coherent deliverable that can be
implemented and verified independently once its dependencies are
complete. Avoid overly broad tickets, unrelated bundles, and artificial
splitting that adds coordination without useful independence.

Do not invent product requirements, architectural decisions,
credentials, file paths, or acceptance criteria unsupported by the RFC.
Mark unknowns and ask for clarification when they materially affect
scope.

## Phase 2 --- Order and validate dependencies

1.  Use `skills/ticket-dependency-planning/SKILL.md` to analyze
    prerequisites, sequencing, and possible parallel work.
2.  Assign stable proposal identifiers such as `T1`, `T2`, and `T3`
    before Jira keys exist.
3.  Express each dependency using proposal identifiers during review.
    After Jira creation, map them to real Jira keys.
4.  Ensure dependencies point only to valid candidate tickets or
    already-filed tickets.
5.  Check for self-dependencies, missing references, ambiguous
    references, and cycles. Resolve these before filing; never silently
    remove a dependency to make the plan work.
6.  Respect RFC phase order when phases are explicitly sequential.
7.  Identify overlapping or uncertain file scopes. Include shared
    configuration, package manifests, lockfiles, shared types, generated
    files, migrations, and test fixtures where relevant.
8.  Mark which tickets could be candidates for the same build wave, but
    do not promise parallel execution. Final wave scheduling belongs to
    `/rfc build`.
9.  If the dependency planner reports uncertainty, show the evidence and
    ask the user to resolve material questions before ticket creation.

## Phase 3 --- Present the proposal for approval

Before creating or changing Jira tickets, present the complete proposed
breakdown to the user.

Include a compact summary table with:

-   Proposal ID
-   Phase
-   Proposed title
-   Depends-on proposal IDs
-   Files / likely file scope
-   Key acceptance outcome

Then include each ticket's full scope, out-of-scope notes, acceptance
criteria, verification, risks, and assumptions.

Explicitly identify:

-   unresolved requirements or design decisions
-   dependency edges and any potential cycles
-   file-scope overlaps and parallelism risks
-   existing Jira tickets that appear to cover the same work
-   tickets that should be deferred or split

Ask the user to approve the proposed breakdown before creating Jira
tickets. Approval to draft the proposal is not approval to file it. If
the user requests changes, revise the proposal and obtain approval
again.

## Phase 4 --- Create tickets through the ticket skill

Only after explicit approval:

1.  Re-check existing Jira tickets and the RFC Work breakdown table for
    duplicates or changes since the proposal.
2.  Create each approved ticket using the existing documented workflow
    in `skills/ticket/SKILL.md`. Do not invent an undocumented
    subcommand, API, or agent capability.
3.  Include the approved scope, out-of-scope notes, acceptance criteria,
    verification requirements, phase, file scope, and relevant RFC
    link/reference in each ticket, to the extent supported by the ticket
    skill's fields.
4.  Create tickets in dependency-safe order when Jira links require
    prerequisite tickets to exist first.
5.  Add Jira dependency links using the existing ticket workflow when
    supported. If linking is unavailable, record the missing link and
    report it; do not claim the dependency was created.
6.  Capture the actual Jira key and URL returned for each created
    ticket.
7.  If creation fails partway through, stop and report which tickets
    were created and which were not. Do not blindly retry operations
    that could create duplicates. Resume by reconciling the actual Jira
    state first.
8.  Do not implement code, create implementation branches, create
    worktrees, or dispatch implementation agents during breakdown.

## Phase 5 --- Update the RFC Work breakdown table

After creation, update the RFC overview's existing Work breakdown table
using its established format. Do not create a competing table if one
already exists.

For each ticket row, record the actual Jira key, title, phase,
`Depends-on` Jira keys, and `Files` scope, following the repository's
existing column names and conventions. Preserve existing valid rows and
avoid duplicate entries.

Rules:

-   Never leave placeholder keys such as `TBD` or `_TBD_` for tickets
    reported as filed.
-   Never invent a Jira key or URL.
-   If a ticket was not created, mark it clearly as not filed according
    to the existing RFC convention, or leave it out of the filed-ticket
    table and report it separately.
-   Re-read the updated RFC and confirm every filed ticket maps to
    exactly one row and every dependency maps to an existing ticket or
    explicitly documented external prerequisite.
-   Preserve unrelated user edits. If the RFC file changed concurrently,
    stop and reconcile rather than overwriting it.

## Phase 6 --- Validate and report

Validate that:

1.  Every proposed ticket approved for filing has an accurate final
    outcome.
2.  Every created Jira key and URL is grounded in the actual creation
    result.
3.  Dependency links and `Depends-on` entries are consistent, or any
    missing links are disclosed.
4.  The RFC Work breakdown table contains no duplicate ticket rows.
5.  All required dependencies refer to real Jira keys or clearly
    identified external prerequisites.
6.  No implementation work was started.

Report:

-   RFC identifier and path
-   ticket proposals approved
-   Jira tickets actually created, with keys and links
-   tickets not created and the reason
-   dependency links created or still missing
-   updated Work breakdown table location
-   unresolved assumptions, conflicts, or manual actions

Use clear statuses such as `CREATED`, `NOT CREATED`, `BLOCKED`, or
`UNVERIFIED` only when supported by evidence.

## Important limitations

This procedure defines the expected workflow. It does not itself provide
Jira access, guarantee a particular ticket-skill subcommand, or
implement ticket creation. Confirm the existing ticket skill and
available tools before filing. If a required capability is missing, stop
at that boundary and report it rather than simulating success.
