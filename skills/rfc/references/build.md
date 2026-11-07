# RFC Build --- Multi-Ticket Orchestration Procedure

## Purpose

Implement Jira tickets already recorded in an RFC Work breakdown table
in dependency-safe waves. Coordinate isolated implementations, integrate
their results, verify the combined change, and report blocked or failed
work. This is the procedure referenced by `skills/rfc/SKILL.md` for
`/rfc build`.

## Ownership boundaries

-   **RFC build** owns orchestration: preflight, wave scheduling,
    dispatch, integration, recovery, and reporting.
-   **Ticket dependency planning** owns dependency analysis and
    parallel-safety recommendations. Reuse
    `skills/ticket-dependency-planning/SKILL.md`; do not create a second
    dependency graph or silently override its findings.
-   **Implementation** owns one Jira ticket's implementation. Dispatch
    each ticket through `skills/implementation/SKILL.md` and its
    relevant references.
-   **Ticket** owns Jira operations such as creating, refining, or
    updating tickets. Do not add implementation logic to the ticket
    skill just to make RFC build work.
-   **Git safety policy** governs branches, worktrees, commits, and pull
    requests. Follow `policies/git-safety.md` and stricter
    repository-specific rules.

Never claim a ticket was dispatched, run in parallel, integrated, or
verified unless the action happened and evidence exists.

## Inputs

Usage:

``` text
/rfc build <NNNN | path-to-overview.md> [--stacked]
```

Resolve an RFC number to exactly one `docs/rfc/NNNN-*/overview.md`, or
use the supplied overview path. `--stacked` selects the stacked-wave
delivery mode described in `skills/rfc/SKILL.md`. Default mode uses one
RFC feature branch and one final PR. Do not create Jira tickets here;
run RFC breakdown first if tickets have not been filed.

## Phase 1: Preflight

1.  Resolve the RFC overview and platform-specific design files.
2.  Read the RFC status, goals, non-goals, phases, and Work breakdown
    table.
3.  Confirm every planned row has a real Jira key. If any key is `TBD`,
    `_TBD_`, blank, or not filed, stop and ask the user to run
    `/rfc breakdown`. Never invent keys or create tickets.
4.  Match each ticket unambiguously to one Work breakdown row.
5.  Read `skills/ticket-dependency-planning/SKILL.md`,
    `skills/implementation/SKILL.md` and relevant references,
    `policies/guardrails.md`, `policies/verification.md`, and
    `policies/git-safety.md`.
6.  Inspect repository state before changes. Do not discard, reset,
    overwrite, or silently include existing user changes. If the
    worktree is dirty or the branch conflicts with the selected delivery
    mode, stop and ask how to proceed.
7.  Confirm required tools are available: Git, project verification
    tools, Jira access when needed, and a supported agent/task dispatch
    mechanism. Never assume a capability exists because this procedure
    mentions it.

Report the RFC, ticket count, delivery mode, and preflight blockers
before implementation.

## Phase 2: Build the ticket inventory

For each Work breakdown row, record the row number, Jira key and
summary, phase, `Depends-on`, declared `Files`, platform/type, current
Jira status when available, readiness, evidence, and unresolved
questions.

The Work breakdown table is the initial source for ticket membership and
declared files. Dependency planning supplies dependency analysis; Jira
supplies current ticket details. If these disagree, report the
discrepancy and stop affected work until resolved.

Resolve every `Depends-on` reference to an unambiguous row or key.
Missing references, self-dependencies, ambiguous keys, and dependency
cycles are blockers. Never silently remove a dependency to make
scheduling possible.

## Phase 3: Determine safe execution waves

1.  Invoke the existing ticket dependency-planning skill with the RFC,
    Work breakdown table, and ticket details as evidence.
2.  Respect every hard dependency. A ticket cannot enter a wave until
    its required predecessors have completed and been integrated for the
    chosen delivery mode.
3.  Respect RFC phase ordering when phases are defined as sequential. Do
    not assume different phases can run together just because no
    dependency is written.
4.  Consider file contention as well as dependencies:
    -   Tickets with overlapping declared `Files` paths must not be
        co-scheduled unless analysis establishes the overlap is safe and
        non-conflicting.
    -   A directory path overlaps files beneath it.
    -   Unknown actual file scope is not proof of no conflict; schedule
        conservatively.
    -   Consider package manifests, lockfiles, shared types, routing
        registries, generated files, and shared configuration where
        relevant.
5.  Respect security, migration, release, and other sequencing
    requirements even if the graph permits parallelism.
6.  If analysis is uncertain, separate the affected tickets and ask for
    clarification when needed.
7.  Detect cycles and report their path. Do not run tickets in a cyclic
    set.
8.  Present the proposed schedule before dispatch, including wave
    membership, dependencies, file-conflict rationale, and
    blocked/uncertain tickets. Ask for confirmation if a material
    assumption or scope decision is required.

A wave is a set of candidates for parallel execution, not proof that the
current runtime supports parallel dispatch.

## Phase 4: Choose delivery mode

### Default: one RFC feature branch and one final PR

-   Use the branch convention in `skills/rfc/SKILL.md`, currently
    `feat/rfc-NNNN-<slug>`.
-   Keep integrated ticket changes on the RFC feature branch.
-   Each concurrently running ticket must use its own isolated Git
    worktree and ticket-specific branch. Never let agents edit the same
    checkout or branch concurrently.
-   Start ticket worktrees from the correct wave base; later waves must
    see earlier integrated waves.
-   Open one PR for the completed RFC unless the user explicitly chooses
    another supported mode.

### Stacked mode: `--stacked`

-   Follow the mode and naming contract in `skills/rfc/SKILL.md`.
-   Each wave builds on the previous integrated wave; wave 1 starts from
    the configured default branch.
-   Open one PR per wave, based on the preceding wave branch.
-   Confirm the `gh stack` extension is installed and usable before
    creating stacked branches or PRs. If missing, stop before modifying
    delivery state and explain the prerequisite.
-   Never silently fall back to the default mode.

For both modes, follow repository branch and commit conventions. Do not
force-push, rewrite shared history, or bypass Git safety controls.

## Phase 5: Dispatch each wave

For each wave, in dependency order:

1.  Confirm all predecessor tickets are complete and integrated into the
    required base.
2.  Re-check repository and branch state.
3.  Create one worktree and ticket-specific branch for each approved
    parallel ticket. Use predictable RFC/ticket-based names; check that
    each path and branch is unused. Never overwrite an existing worktree
    or branch.
4.  Ensure each worktree starts from the correct wave base. No agents
    share a worktree.
5.  Before dispatching implementation work for a wave, present the user with the proposed wave plan and the implementation plans for all tickets in that wave. Obtain one explicit user approval for the wave. That approval covers the reviewed plans for all tickets in the approved wave. If a ticket's scope, implementation plan, dependencies, or material risks change after approval, pause that ticket and obtain renewed approval for the changed plan. Do not bypass the existing implementation skill's planning and approval requirements.    
6.  Dispatch each ticket through the existing implementation workflow,
    providing:
    -   Jira key and full ticket details
    -   RFC overview and relevant platform design
    -   Work breakdown row, dependencies, and declared files
    -   accepted wave schedule and exact base commit/branch
    -   assigned worktree path and ticket branch
    -   approved scope and required verification
    -   instruction to report changed files, commits, test evidence,
        blockers, and newly discovered dependencies/conflicts
7.  Use only an agent/task dispatch mechanism actually available in this
    OpenCode environment. If separate dispatch is unavailable, do not
    pretend to run tickets concurrently; ask whether to run the safe
    wave sequentially or stop until dispatch is configured.
8.  Do not dispatch tickets with incomplete dependencies, ambiguous
    scope, or unknown safety status.
9.  Wait for every ticket in a wave to finish or fail before integrating
    the wave. Do not start dependent waves early.

Do not allow ticket agents to merge to the default branch or change the
schedule on their own. If an agent discovers a new dependency or file
conflict, pause affected work, update planning evidence, and recalculate
remaining waves.

## Phase 6: Review and integrate results

For each ticket:

1.  Confirm the agent used its assigned worktree and branch.
2.  Inspect the diff and changed-file list. Reject unrelated,
    out-of-scope, secret-bearing, generated, or unexplained changes.
3.  Inspect actual verification evidence; a report alone is not evidence
    when command output or test results are available.
4.  Confirm acceptance criteria are addressed and no required checks are
    blocked or unverified.
5.  Do not integrate a ticket that fails verification or exceeds scope.
    Record it as failed/blocked and follow recovery.
6.  Integrate passing changes into the RFC integration branch using the
    repository's safe merge/cherry-pick procedure. Never use destructive
    resets or force-pushes to resolve conflicts.
7.  If integration conflicts occur, stop integrating that wave. Resolve
    only if the correct result is unambiguous; otherwise ask the user.
    Re-run affected verification after resolution.
8.  Record each integrated commit and the base commit used for the wave.

Do not treat branches as independent if their diffs reveal a shared-file
conflict missed during planning.

## Phase 7: Failure and recovery

If an agent fails, times out, returns incomplete work, or reports a
blocker:

1.  Keep its worktree and branch until the failure is understood. Do not
    delete uncommitted work.
2.  Do not mark the ticket complete or integrate it.
3.  Record ticket, failed step, error evidence, changed files, commits,
    and possible impact on other tickets.
4.  Continue only with independent tickets whose safety is unaffected.
    Do not run descendants of the failed ticket.
5.  Recompute remaining waves if a new dependency, conflict, or scope
    change is discovered.
6.  Ask the user if recovery requires scope changes, destructive
    actions, ambiguous conflict resolution, or a change to the approved
    RFC.
7.  After retrying, re-run the affected ticket's required verification
    sequence.

Never discard agent changes, force-reset a worktree, or delete a branch
as generic cleanup.

## Phase 8: Verify the integrated RFC

After intended tickets are integrated:

1.  Run required checks on the combined branch, including applicable
    typecheck, lint, tests, production build, security checks, and
    critical E2E/smoke checks.
2.  Run RFC-specific cross-ticket/integration tests.
3.  Inspect the final diff against the delivery base for scope, secrets,
    accidental files, and unreviewed changes.
4.  Give every Work breakdown row an accurate outcome: integrated,
    blocked, failed, or not run.
5.  Confirm dependencies were satisfied and all intended completed waves
    are present.
6.  If any required check fails or remains unverified, say so; do not
    claim the RFC is fully verified.
7.  Create/update PRs only after relevant checks and Git safety
    requirements are satisfied. Do not merge unless the workflow and
    user explicitly authorize it.

## Phase 9: Cleanup

-   Remove a ticket worktree only after its changes are safely
    integrated or the user explicitly authorizes abandoning it, and only
    after confirming there is no uncommitted work to preserve.
-   Do not delete branches containing unintegrated or unresolved
    changes.
-   Retain logs, commit identifiers, test evidence, and the final wave
    report in the agreed output.
-   Do not add orchestration state to the RFC unless its format defines
    a suitable place.

## Final report

Report the RFC and delivery mode; planned and actual waves; whether
execution was parallel or sequential; completed/integrated, blocked,
failed, and unrun tickets; worktrees/branches created and cleaned up;
commits and PR links when available; verification commands and actual
outcomes; conflicts or schedule changes; and remaining manual actions.

Use `PASS`, `FAIL`, `BLOCKED`, or `UNVERIFIED` only when evidence
supports the status. Distinguish implementation completion from
successful integration and final RFC verification.

## Important limitations

This procedure defines expected behavior; it does not itself provide
agent dispatch, Jira access, or Git capabilities. Confirm required tools
exist. If a required capability is missing, stop at that boundary and
report it rather than simulating success.
