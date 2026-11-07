---
name: rfc
description: "Create new RFC documents from context. Use when: creating an RFC, writing a design proposal, drafting a technical spec, proposing a new feature, documenting a cross-platform design, filing implementation tickets from an RFC, accepting an RFC before merge, rejecting an RFC and recording why, building an RFC's tickets in dependency-ordered parallel waves, checking an RFC's implementation status. Subcommands: 'create' to scaffold a new RFC from provided context, 'breakdown' to file Jira tickets from an RFC's Work breakdown table, 'accept' to flip an RFC from Proposed to Accepted before merge, 'reject' to flip an RFC from Proposed to Rejected and record the rationale in memory, 'build' to implement an RFC feature branch, 'status' to show a live rollup of ticket and PR state, 'help' to list subcommands."
argument-hint: "create <context> | breakdown <NNNN | path> | accept <NNNN | path> | reject <NNNN | path> | build <NNNN | path> [--stacked] | status <NNNN | path> | help"
---

# RFC

Create RFC (Request for Comments) documents for proposed features and cross-platform designs.

## Subcommands

| Subcommand | Description |
|---|---|
| `create` | Scaffold a new RFC from the provided context |
| `breakdown` | File Jira tickets from an RFC's Work breakdown table, each under its listed Epic, then refine each with platform expert agents |
| `accept` | Flip an RFC from Proposed to Accepted in its PR, immediately before merge |
| `reject` | Flip an RFC from Proposed to Rejected and record the rationale in memory |
| `build` | Implement an RFC's filed tickets in dependency- and file-contention-aware parallel waves. Defaults: commit each onto one RFC feature branch (single PR at the end). `--stacked`: land each wave on its own branch stacked on the previous and open one PR per wave |
| `status` | Show a live rollup of each Work-breakdown ticket's Jira status and PR state |
| `help` | Show this table |

## create

Scaffold a new RFC from free-form `<context>`: read the README + overview.md, ask only for missing title/platforms/authors, generate `overview.md` and platform files, update the README index, and offer to create a tracking Jira Epic.

See `references/create.md` for the full procedure.

## breakdown

**Usage:** `/rfc breakdown <NNNN | path-to-overview.md>`

Create the Jira implementation tickets for an approved RFC. Read the RFC overview and supporting design documents, identify the work items, and determine dependencies and file conflicts using the ticket dependency-planning skill. Present the proposed tickets and dependency plan for user review and obtain explicit approval before creating tickets. Use the existing ticket skill for Jira ticket creation; do not implement code as part of breakdown. After successful creation, update the RFC Work breakdown with the real Jira ticket keys and dependency information. Handle partial failures without creating duplicate tickets on retry.

Refine each created ticket with the appropriate platform expert agents, following the ticket skill's documented refinement workflow.

See `references/breakdown.md` for the full procedure.

## build

**Usage:** `/rfc build <NNNN | path-to-overview.md> [--stacked]`

Implement an RFC's already-filed Work breakdown tickets in dependency-safe waves. Respect phase ordering, dependencies, and file conflicts. Use the ticket dependency-planning skill to determine safe waves, and follow `references/build.md` for preflight, dispatch, isolated worktrees, integration, verification, and recovery. Dispatch individual ticket implementations through the existing implementation skill. Preserve the implementation skill's planning and explicit user-approval gate before coding; wave scheduling must not bypass it. Do not use the ticket skill for implementation or assume a ticket wave operation exists.

Default mode integrates completed tickets onto a single RFC feature branch `feat/rfc-NNNN-<slug>` and opens one PR for the RFC. With --stacked, each wave uses a branch `feat/rfc-NNNN-<slug>-wave<K>` based on the preceding wave (wave 1 starts from the configured default branch, currently main) and opens a PR based on the preceding wave's branch. Stacked mode requires the gh stack extension (`gh extension install github/gh-stack`) and must stop if it is missing. `/rfc breakdown` must run first; no `_TBD_` ticket rows are allowed.

See `references/build.md` for the full procedure.

## Policies

Use:
- `policies/guardrails.md` for scope, approval, and evidence reporting. RFC `accept` requires explicit approval.
- `policies/security.md` for secrets and credentials. Never store secrets in RFCs.
- `policies/verification.md` for completion evidence and delivery checks.
- `policies/git-safety.md` for branch isolation and Pull Request safety when building RFC waves.

## Self-Improvement

Follow the common self-improvement standard in:

`../self-improvement/references/standard.md`

<!-- ## accept

**Usage:** `/rfc accept <NNNN | path-to-overview.md>`

Flip an RFC from Proposed to Accepted in its PR, immediately before merge.

1. Resolve the RFC: `NNNN` → `docs/rfc/NNNN-*/overview.md`, or use the given path. If it does not resolve to a single file, ask the user which RFC with the `vscode_ask_questions` tool.
2. Verify the work-breakdown foundation is scheduled or evidenced: every framework path in the table's `Files` column must resolve to either a scaffold row in the same table or recorded in-repo evidence. If the foundation is assumed but unscheduled, stop — do not flip to Accepted. Report the missing scaffold and ask whether to amend the RFC first.
3. In `docs/rfc/NNNN-*/overview.md`, replace the status cell from **Proposed** with **Accepted**. If it already reads **Accepted**, stop (no-op).
4. In `docs/rfc/UPDATES.md`, update that RFC's index-row status cell from Proposed to Accepted.
5. Commit both files on the PR branch via the commit skill (`bash .github/skills/commit/scripts/create-commit.sh "docs: accept RFC"`).

## reject

**Usage:** `/rfc reject <NNNN | path-to-overview.md>`

Flip an RFC from Proposed to Rejected and record why in the RFC reject memory (`.github/memories/rfc/rejected-1-200.md`), so future creators can learn what the team has already turned down and avoid re-proposing it. The mirror image of `accept`.

See `references/reject.md` for the full procedure.

## status

**Usage:** `/rfc status <NNNN | path-to-overview.md>`

Render a read-only rollup of an RFC's implementation — each Work-breakdown ticket's Jira status and PR state (open/merged/none), plus overall progress and the next unblocked wave.

See `references/status.md` for the full procedure. -->
