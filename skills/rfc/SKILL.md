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

## Self-Improvement

Follow the common self-improvement standard in:

`../self-improvement/references/standard.md`

<!-- ## breakdown

File Jira tickets from an existing RFC's Work breakdown table, one per row under that row's Epic, refine each created ticket with platform expert agents (the `ticket` skill's `refine` subcommand), then write the created keys back into the table. Idempotent — rows already listing a ticket are skipped.

**Input:** an RFC number (`NNNN`) or a path to an `overview.md`.

See `references/breakdown.md` for the full procedure.

## accept

**Usage:** `/rfc accept <NNNN | path-to-overview.md>`

Flip an RFC from Proposed to Accepted in its PR, immediately before merge.

1. Resolve the RFC: `NNNN` → `docs/rfc/NNNN-*/overview.md`, or use the given path. If it does not resolve to a single file, ask the user which RFC with the `vscode_ask_questions` tool.
2. In `docs/rfc/NNNN-*/overview.md`, replace the status cell from **Proposed** with **Accepted**. If it already reads **Accepted**, stop (no-op).
3. In `docs/rfc/UPDATES.md`, update that RFC's index-row status cell from Proposed to Accepted.
4. Commit both files on the PR branch via the commit skill (`bash .github/skills/commit/scripts/create-commit.sh "docs: accept RFC"`).

## reject

**Usage:** `/rfc reject <NNNN | path-to-overview.md>`

Flip an RFC from Proposed to Rejected and record why in the RFC reject memory (`.github/memories/rfc/rejected-1-200.md`), so future creators can learn what the team has already turned down and avoid re-proposing it. The mirror image of `accept`.

See `references/reject.md` for the full procedure.

## build

**Usage:** `/rfc build <NNNN | path-to-overview.md> [--stacked]`

Implement an RFC's already-filed Work breakdown tickets in parallel, enforcing that no wave crosses a dependency edge and no wave co-schedules two tickets that touch the same file. Computes the wave schedule from the table (Phase ordering + Depends-on/Files columns) and dispatches each wave through the `ticket` skill's `wave` subcommand in integrate mode (`--onto`).

Default shape commits every completed ticket onto a single RFC feature branch `feat/rfc-NNNN-<slug>` and opens one PR for the whole RFC (not one per ticket). With `--stacked`, each wave lands on its own branch `feat/rfc-NNNN-<slug>-wave<K>` that stacks on the previous wave's branch (wave 1 off `main`) and becomes one PR whose base is the branch below it, so reviewers see one wave's diff per PR. `--stacked` requires the `gh stack` extension (`gh extension install github/gh-stack`) and aborts if it is missing. Requires `breakdown` to have run first (no `_TBD_` rows).

See `references/build.md` for the full procedure.

## status

**Usage:** `/rfc status <NNNN | path-to-overview.md>`

Render a read-only rollup of an RFC's implementation — each Work-breakdown ticket's Jira status and PR state (open/merged/none), plus overall progress and the next unblocked wave.

See `references/status.md` for the full procedure. -->
