---
name: rfc
description: "Creates RFC (Request for Comments) design documents, files Jira tickets from them, and builds them in dependency-ordered parallel waves. Use when the user wants to write an RFC, draft a design proposal or technical spec, propose a new feature or cross-platform design, break an RFC into Jira tickets, or implement an RFC's tickets as a feature branch, even if they do not say 'RFC'. Subcommands: create, breakdown, build, help. Do not use for single-decision records (use adr) or single-ticket work (use ticket)."
argument-hint: "create <context> | breakdown <NNNN | path> | build <NNNN | path> [--stacked] | help"
---

# RFC

## Overview

Create RFC (Request for Comments) documents for proposed features and cross-platform designs, turn them into Jira tickets, and implement those tickets safely in parallel.

## When to Use

- A feature or cross-platform design needs a written proposal before implementation (`create`).
- An approved RFC needs Jira implementation tickets (`breakdown`).
- An RFC's filed tickets are ready to be implemented (`build`).

Do not use for a single architectural decision (use `adr`), a single Jira ticket (use `ticket`), or implementing one story (use `implementation`).

## Subcommands

| Subcommand | Description |
|---|---|
| `create` | Scaffold a new RFC from the provided context |
| `breakdown` | File Jira tickets from an RFC's Work breakdown table, each under its listed Epic, then refine each with platform expert agents |
| `build` | Implement an RFC's filed tickets in dependency- and file-contention-aware parallel waves. Defaults: commit each onto one RFC feature branch (single PR at the end). `--stacked`: land each wave on its own branch stacked on the previous and open one PR per wave |
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

## Verification

- [ ] `create`: `overview.md`, platform files, and the README index entry all exist and agree.
- [ ] `breakdown`: user approved the ticket plan before any Jira write; the Work breakdown table holds real ticket keys and no `_TBD_` rows; a retry created no duplicates.
- [ ] `build`: every ticket went through the `implementation` skill's approval gate; verification evidence is reported per wave.
- [ ] No secrets appear in any RFC.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The RFC is clear, skip user review of the ticket plan." | Jira writes are hard to undo; approval is required before creating tickets. |
| "These tickets look independent, run them in one wave." | File contention causes merge conflicts; use `ticket-dependency-planning` to set waves. |
| "Skip the implementation approval gate to save time in `build`." | Wave scheduling must never bypass the `implementation` skill's planning gate. |

## Red Flags

- Tickets created before the user approved the plan.
- `build` started while `_TBD_` ticket rows remain.
- Subcommands used that are not in the table above (for example `accept`, `reject`, `status`; they are not implemented here).

## Policies

Use:
- `policies/guardrails.md` for scope, approval, and evidence reporting. RFC `accept` requires explicit approval.
- `policies/security.md` for secrets and credentials. Never store secrets in RFCs.
- `policies/verification.md` for completion evidence and delivery checks.
- `policies/git-safety.md` for branch isolation and Pull Request safety when building RFC waves.

## Self-Improvement

Follow the common self-improvement standard in:

`../self-improvement/references/standard.md`
