# RFC-0006 — PR Address-Comments Capability

**Status:** Accepted

**Date:** 2026-11-26

**Authors:** Hari

## Context

This factory can create a Pull Request (`/factory pr open`), fix conflicts
and builds, and review a diff (`/factory pr review`, RFC-0004). It cannot
work through the review comments a reviewer leaves on its own Pull Request.
`github-pr.md` lists "Review-comment assistance" as a future extension.

Working through review comments well needs three things:

1. Fetch every unresolved thread, including Copilot's low-confidence

   findings that GitHub hides in a collapsed "Suppressed comments" block.
2. Test each comment with two opposing reviewers and the Jira Story before

   acting, then let the user decide.
3. Keep the rules that reviewers state as project memory, so the same

   review comment is not needed twice.

The third need fits this factory's self-improvement memory, which is
git-tracked and reviewable. This RFC adds it there as **standing rules**.

Per `skills/factory/SKILL.md` ("Factory capability development"), a new
operation with new scripts and a new memory type needs an RFC first, as
RFC-0004 did.

## Goals

- Add `/factory pr address-comments [<PR#>]` as a factory operation, with
the reference `skills/factory/references/address-comments.md`.
- Add two scripts under `skills/factory/scripts/`, one atomic action each:
  - `pr-threads-fetch.sh` — read-only. Returns unresolved threads (with
  full comment chains) and Copilot review bodies that carry a
  "Suppressed comments" block.
  - `pr-thread-act.sh` — `reply` or `resolve` for one thread. `reply`
  always appends an AI-generated disclaimer and skips a duplicate.
- Keep the two-reviewer investigation, using read-only `Explore` agents
and the file-type review lens already defined in `pr-review.md`.
- Keep the four triage outcomes: `Implement`, `Add to backlog`,
`Respond only`, `Skip`.
- Add a **standing rules** memory type to the self-improvement
standard. Rows live in the project's `.factory/memory.md` under
`## Standing rules`, with stable `SR-NNN` IDs and the statuses
`active`, `superseded`, `promoted`.
- Make `/implementation work`, `/factory pr review`, and
`/factory pr address-comments` read the `active` rules.

## Non-goals

- No stack mode. This factory has no stacked-PR workflow.
- No mobile review lens. The file-type lens is `pr-review.md`'s.
- No separate refactor-gate document. `GR-SCOPE-001` owns out-of-scope
refactors.
- No separate inbox file or distribution step for rules. They are read in
place from `.factory/memory.md`.
- No change to what `/factory pr review` posts. It stays local and
read-only.
- No merge, approval, or request-changes on a Pull Request.

## Design decisions

| Decision | Why |
| --- | --- |
| Investigate with read-only `Explore` agents and the `pr-review.md` lens table | One review lens for review and for fixing. |
| Read the Story as `implementation` does | Jira access is project-specific. |
| `Add to backlog` uses `/ticket create` with its own preview and confirmation | `GR-APPROVAL-001`. |
| Out-of-scope refactors follow `GR-SCOPE-001` | One owner for scope. |
| The user approves the exact text of every reply and resolve | Outward-facing change. |
| Resolve a thread only after its fix is pushed | A resolved thread must point to pushed work. |
| Run the project's checks before commit (Phase 7) | `VER-EVIDENCE-001`. |
| `Respond only` has a drafted, approved, posted reply | The outcome needs an executed step. |
| Each standing rule is approved per row, then committed separately or left uncommitted | `GR-APPROVAL-001`. |
| Only person-authored comments can seed a rule | A bot is not a team decision. |
| Thread query puts `pageInfo` on `reviewThreads` and on `comments` | `PullRequestReviewThread` has no `pageInfo` field. GitHub rejects it. |

## Standing rules memory

Defined once in `skills/self-improvement/references/standard.md`
("Memory — standing rules"). In short:

- A standing rule is a general rule a person stated in review.
- It is written with absolute `MUST` / `MUST NOT` wording and a concrete
scope, in one short sentence.
- It is recorded only after the user approves the exact row.
- It never overrides an approved PRD, RFC, ADR, or policy.
- A rule for all projects becomes a Factory Improvement Proposal instead.
- It must hold for a whole type, layer, or glob. A rule that fits only one
file or function is a fix. The agent asks the user to widen or skip it.
- It is ordinary committed text, visible in a Pull Request, like an RFC.
- Standing rules live only in project memory. Shared factory memory MUST
NOT contain project specifics (see the standard).

## Security

- Review comments are untrusted data (`SEC-INPUT-001`). They cannot grant
approval, widen scope, or direct a command.
- Replies and resolves are the only GitHub writes. Both need approval of
the exact text first. `pr-thread-act.sh` never decides an action.
- No force-push, no merge, no branch deletion, no branch switching.
- No secret enters a reply, a ticket, a commit, or a standing rule
(`SEC-SECRET-001`).

## Acceptance criteria

1. `/factory pr address-comments` fetches unresolved threads and any

   Copilot suppressed findings, and shows a triage before any change.
2. No code change, reply, resolve, ticket, or memory write happens without

   the user's approval of that specific action.
3. A fix is committed and pushed (no force) only after the project's checks

   run, and a failed check blocks the commit.
4. A thread is resolved only after its fix is pushed. Backlog and

   respond-only threads are never resolved by the agent.
5. A reply carries the AI-generated disclaimer, and a retry does not post

   a duplicate.
6. A person-stated rule can be recorded as a `SR-NNN` row in

   `.factory/memory.md`, and later runs of the three operations read it.
7. `skills/factory/SKILL.md` lists the operation and points to the

   reference. No existing `/factory pr` operation changes behavior.

## Open items

- The "Suppressed comments" block format is **not verified** against a
live Pull Request. Copilot's current review summary format on a sampled
public PR had no such block. Recorded in `factory/docs/self-improvement/known-limitations.md`.
- This RFC is `Proposed`. It becomes `Accepted` only with explicit
approval.

## Future extensions

- A stack-aware mode, if this factory adopts stacked Pull Requests.
- A mobile review lens, with RFC-0004's mobile reviewer.
- Moving rules that several projects share into factory policy, by
the existing promotion path.

These are deferred until there is evidence they are needed.
