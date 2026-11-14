# RFC-0004 — PR Review Capability

**Status:** Accepted

**Date:** 2026-11-14

**Authors:** Hari

## Context

A `skills/factory/references/pr-review.md` file was copied in from a
different software factory — one that builds against three platforms
(iOS, Android, web) and carries a matching set of agents, scripts, and
policy documents (`swift-reviewer`, `kotlin-reviewer`, and others with
no equivalent in this factory).

This factory currently has no PR *review* capability. `skills/factory/
references/github-pr.md` covers creating a Pull Request
(`/factory pr open`); `conflict-resolution.md` and `pipeline-debug.md`
cover conflicts and CI failures. Nothing produces an independent review
of a PR's diff.

The copied file's core idea — a local, read-only, two-part review
procedure (context acquisition, then review-and-render) producing a
structured report with a two-axis issue model (finding-category ×
change-type), a deterministic risk floor, and a suggested verdict a
human posts — is reusable and worth adding, adapted to this factory.

Per `skills/factory/SKILL.md` ("Factory capability development"), a new
agent, skill, or script is added only for a defined problem, and a
capability this size (two new agents, four new scripts, a new factory
operation) requires an RFC before being built.

## Goals

- Add `/factory pr review <PR#|branch>` as a new factory operation:
  single-PR, local, read-only. Never posts to GitHub, never commits,
  never auto-merges, never auto-fixes.
- Define the review as two parts, matching the source material's split:
  - **Part A — Acquire context:** resolve the PR, materialize an
    isolated worktree at the reviewed commit, compute the diff, score
    deterministic risk signals.
  - **Part B — Review and render:** dispatch review by changed-file
    type, normalize findings, compute a suggested verdict, render the
    report.
- Add a `pr-review-orchestrator` agent for reviewing several PRs in one
  request: it runs Part A per PR (it has terminal access) and seeds an
  isolated `pr-review-worker` per PR with that context.
- Add a `pr-review-worker` agent that receives Part A pre-seeded and
  runs Part B only — no terminal access needed.
- Add scripts under `skills/factory/scripts/`, one atomic action per
  script (matching the convention already used by `skills/ticket/
  scripts/jira-*.sh`):
  - `pr-review-resolve.sh` — resolve a PR number/branch via `gh pr view`
    to the target metadata object the source file described.
  - `pr-worktree-materialize.sh` — create the isolated review worktree.
  - `pr-risk-signals.sh` — compute a deterministic risk score/band and
    signal flags, recomputed for this factory's actual stack (below).
  - `pr-review-verdict.sh` — compute the suggested verdict from the
    normalized issues list (kept as-is: this logic is generic, not
    platform-specific).
- Ground every finding in this factory's existing policies:
  - A finding cites a rule ID from `policies/guardrails.md` (`GR-*`),
    `policies/web-best-practices.md` (`WEB-*`), `policies/security.md`
    (`SEC-*`), `policies/verification.md` (`VER-*`), `policies/
    dependency-safety.md`, or the Supabase/Postgres best-practices
    skill, when the finding rests on a stated rule.
  - A judgment-only finding (no rule behind it) says so explicitly
    instead of inventing one.
  - A finding whose fix is a refactor beyond the PR's stated scope is
    checked against `GR-SCOPE-001` (out-of-scope work): kept only as a
    **Deferred → backlog** suggestion, never a blocking issue, and never
    fabricated as required.
- Compute risk signals for this factory's actual stack:
  `SIGNAL_SECURITY` (auth, RLS, secrets, Stripe/payment paths),
  `SIGNAL_SCHEMA` (migrations/schema files), `SIGNAL_CI`
  (`.github/workflows/**`), `SIGNAL_DEPENDENCY` (`package.json`/
  lockfile changes), `SIGNAL_LARGE_DIFF`.
- Keep the dispatch step's *shape* (a changed-file-type → review-lens
  table) platform-ready, consistent with the `rfc` skill, which already
  plans product RFCs across iOS/Android/Web (`skills/rfc/references/
  create.md`). Populate it only with what this factory actually
  reviews today:
  - Web/frontend (`*.ts`, `*.tsx`, `*.js`, `*.jsx`, `*.css`, `*.html`) →
    `policies/web-best-practices.md` + `policies/guardrails.md` +
    `policies/verification.md`.
  - SQL/migrations (`*.sql`, `supabase/migrations/**`) → the
    `supabase-postgres-best-practices` skill + `policies/security.md`
    (RLS, secrets).
  - CI/workflow (`.github/workflows/**`) → `policies/git-safety.md` +
    `policies/security.md`.
  - Dependency manifests/lockfiles → `policies/dependency-safety.md`.
  - `ios/**`, `android/**` → **reserved, not implemented.** No
    `swift-reviewer`/`kotlin-reviewer` agent exists and none is created
    by this RFC, since no mobile codebase exists yet to validate one
    against. A diff touching these paths is reported `BLOCKED — no
    mobile reviewer defined`, not silently skipped or reviewed against
    the wrong criteria.
  - `docs`/config/other → the generic `Explore` agent, as in the source
    material.
- Keep the R1 report template, severity/confidence model, and the
  mandatory *"This report was generated by an AI agent."* disclaimer
  line — these are generic and don't depend on platform. Replace the
  `FDI-XXXX` backlog example with a generic `<PROJECT-KEY>-NNNN`
  placeholder (this factory's actual project key is read dynamically by
  `skills/ticket`, not hard-coded).
- Wire `/factory pr review` into `skills/factory/SKILL.md`'s
  `## Available operations` and `## References` sections, alongside the
  existing `pr open` / `pr resolve-conflicts` / `pr fix-build` entries.

## Non-goals

- No `swift-reviewer` / `kotlin-reviewer` agent, or any other mobile
  reviewer. Deferred until this factory actually builds iOS/Android
  code.
- No posting of review findings to GitHub (no PR comment, no review
  submission). The report stays local/chat-only; posting would be a
  separate, explicitly-approved capability if ever added later.
- No automatic verdict posting, approval, or merge. The suggested
  verdict is read by the human; posting it is their action.
- No change to `/factory pr open`, `pr resolve-conflicts`, or
  `pr fix-build`.

## Proposed workflow

### Part A — Acquire context (needs a terminal)

Run inline by `/factory pr review` for a single PR, or run by the
`pr-review-orchestrator` once per PR before seeding each
`pr-review-worker`:

1. **Resolve the target** — `pr-review-resolve.sh <PR#|branch>` wraps
   `gh pr view` (same mechanism `github-pr.md` already uses) and returns
   `{ number, title, url, author, headRefName, headRefOid, baseRefName,
   updatedAt, myLastReviewOid, myLastReviewState }`. Abort if no such
   open PR exists.
2. **Materialize the worktree** — `pr-worktree-materialize.sh --number
   <n> --oid <headRefOid> --base <baseRefName>` checks out the reviewed
   commit into an isolated `git worktree` (never the user's primary
   working tree — same isolation rule as `policies/git-safety.md` and
   RFC-0003's worktree rules). Prints `WORKTREE:<path>`.
3. **Compute the diff** — three-dot diff against the PR's real base,
   from inside the worktree, plus the changed-file list and `+/-` stat.
4. **Score risk** — `pr-risk-signals.sh <base-ref>` (run with cwd =
   worktree) computes `RISK_SCORE`, `RISK_BAND`, and the `SIGNAL_*` flags
   listed under Goals.
5. **Assemble the context bundle** for Part B: target metadata, diff,
   changed-file list, risk band + signals, worktree path, and (if
   `myLastReviewOid` is set) the incremental range
   `myLastReviewOid..HEAD`.

### Part B — Review and render (no terminal needed)

Run identically whether invoked inline or inside a seeded
`pr-review-worker`:

6. **Dispatch by changed-file type** per the table under Goals, each
   reviewer seeded with the diff, the worktree, the relevant policy
   files, and the PR context.
   - On `SIGNAL_SECURITY=1`, explicitly apply the `policies/
     security.md` lens.
   - Static review only — no builds/tests/linters unless the caller
     passes `--run-tests`.
   - Cited policy rules are binding; an unresolved violation is at
     least a 🟠 high finding.
7. **Normalize findings** into the two-axis issue model (finding-
   category × change-type), drop duplicates, and apply the `GR-
   SCOPE-001` out-of-scope check to every refactor-flavored finding —
   keep it only as a 🟢 low **Deferred → backlog** item, never a
   blocking issue, and never without a cited rule or an explicit
   "judgment call" label.
8. **Compute the suggested verdict** — pipe the normalized issues JSON
   (`{ issues: [{severity, confidence}, ...], open_questions, test_gap
   }`) into `pr-review-verdict.sh`. The result is a suggestion; the
   human posts the review.
9. **Render the R1 report** (template unchanged from the source
   material, aside from the rule-citation and backlog-ticket-ID
   adaptations under Goals).

## Agents

### `pr-review-orchestrator`

- Fans out review of multiple PRs given in one request.
- Has terminal/`execute` access; runs Part A for each PR.
- Seeds one isolated `pr-review-worker` per PR with that PR's Part A
  context bundle.
- Never reviews content itself — review judgment lives entirely in the
  worker.

### `pr-review-worker`

- Isolated, no terminal access.
- Receives a single PR's Part A bundle pre-seeded.
- Runs Part B only and returns its R1 report.
- Never pushes, commits, comments on GitHub, or merges — read-only by
  construction (no tools for those actions are granted).

## Security

- Both agents are read-only with respect to GitHub and Git state: no
  push, no comment, no merge, no branch mutation beyond the isolated
  review worktree itself.
- No GitHub or Jira credentials are placed in the context bundle beyond
  what `gh`/`git` already need locally, per `policies/security.md`.
- The review worktree is isolated per RFC-0003's worktree rules and
  never touches the user's primary working tree or another job's
  worktree.

## Idempotency

- Re-running `/factory pr review` on the same PR/commit reuses the
  resolved target and recomputes the diff and risk signals rather than
  mutating any shared state — the procedure has no side effects to
  deduplicate.
- An existing worktree for the same `(number, oid)` pair is reused
  rather than recreated.

## Acceptance criteria

1. `/factory pr review <PR#|branch>` runs Part A + B for a single PR and
   renders an R1 report in chat, with no GitHub or Git mutation.
2. A request naming several PRs dispatches `pr-review-orchestrator`,
   which seeds one `pr-review-worker` per PR and returns one R1 report
   per PR.
3. Every finding with a stated rule cites a rule ID from an existing
   factory policy (`GR-*`, `WEB-*`, `SEC-*`, `VER-*`, dependency-safety,
   or the Supabase/Postgres skill).
4. A diff touching `ios/**` or `android/**` is reported `BLOCKED — no
   mobile reviewer defined`, not silently reviewed or skipped.
5. `skills/factory/SKILL.md` lists `/factory pr review` under
   `## Available operations` and points to the rewritten
   `references/pr-review.md`.
6. No existing `/factory pr` operation's behavior changes.

## Future extensions

- A `swift-reviewer` / `kotlin-reviewer` (or equivalent) once this
  factory actually builds iOS/Android code.
- Posting review findings to GitHub as PR comments, behind its own
  explicit-approval step (mirroring `GR-APPROVAL-001`), if requested
  later.
- Feeding `pr-risk-signals.sh` output into `/factory pr open`'s CI
  handoff for a combined pre-merge summary.

These are deferred until there is real evidence they're needed.

## Relationship to existing factory capabilities

This RFC adds a new, independent factory operation. It reuses:

- The existing GitHub authentication model (ADR-0001).
- `policies/guardrails.md`, `web-best-practices.md`, `security.md`,
  `verification.md`, and `dependency-safety.md` as the review's grading
  criteria, instead of introducing new policy documents.
- RFC-0003's worktree-isolation rules for the review worktree.
- The script convention already used by `skills/ticket/scripts/`.

It does not change `/factory pr open`, `pr resolve-conflicts`, or
`pr fix-build`.
