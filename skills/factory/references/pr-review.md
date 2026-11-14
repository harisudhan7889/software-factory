# PR Review Procedure

Review a single pull request and produce one **local, read-only** review
report (the R1 template) in the chat. Never post to GitHub, never commit,
never invent new rules beyond the factory's existing policies — it is a
pure reviewer. Multi-PR fan-out is the `pr-review-orchestrator` agent's
job; this procedure reviews exactly one PR.

Invoked as `/factory pr review <PR#|branch>`.

## Two parts

The procedure is split so it serves both callers:

- **Part A — Context acquisition** (needs a terminal). Run by whichever
  caller has `execute`: `/factory pr review` runs it inline; the
  `pr-review-orchestrator` runs it and **seeds** the isolated
  `pr-review-worker` with the result.
- **Part B — Review & render** (no terminal needed). Run identically by
  the inline invocation and by the seeded worker.

`/factory pr review` runs **A + B**. A dispatched `pr-review-worker`
receives **A pre-seeded** and runs **B**.

---

## Part A — Acquire context

1. **Resolve the target.** For a single PR number or branch:

   ```bash
   bash ../scripts/pr-review-resolve.sh <PR#|branch>
   ```

   Take the single target object:

   ```text
   { number, title, url, author, headRefName, headRefOid,
     baseRefName, updatedAt, myLastReviewOid, myLastReviewState }
   ```

   Abort if no such open PR exists.

2. **Materialize the worktree** at the reviewed commit:

   ```bash
   bash ../scripts/pr-worktree-materialize.sh \
     --number <number> --oid <headRefOid> --base <baseRefName>
   ```

   Capture the `WORKTREE:<path>` line. All later file paths and links
   are relative to this worktree. This worktree is isolated from the
   user's primary working tree (same isolation rule RFC-0003 uses for
   headless jobs) — never run the review against the primary checkout.

3. **Compute the diff** — three-dot, against the PR's real base
   (correct for stacked PRs), from inside the worktree:

   ```bash
   git -C <worktree> diff "origin/<baseRefName>...HEAD"
   ```

   Also capture the changed-file list (`--name-only`) and `+/-` stat.

4. **Score risk** (deterministic floor), run from inside the worktree:

   ```bash
   bash ../scripts/pr-risk-signals.sh "origin/<baseRefName>"  # cwd = <worktree>
   ```

   Parse `RISK_SCORE`, `RISK_BAND`, and the `SIGNAL_*` flags:
   `SIGNAL_SECURITY`, `SIGNAL_SCHEMA`, `SIGNAL_CI`,
   `SIGNAL_DEPENDENCY`, `SIGNAL_LARGE_DIFF`.

5. **Assemble the context bundle** for Part B: the target metadata, the
   diff, the changed-file list, the risk band + signals, the worktree
   path, and (if `myLastReviewOid` is set) the incremental commit range
   `myLastReviewOid..HEAD`.

---

## Part B — Review and render

6. **Dispatch review by changed-file type:**

   | Changed files | Review lens |
   | --- | --- |
   | `*.ts`, `*.tsx`, `*.js`, `*.jsx`, `*.css`, `*.html` (web/frontend) | `policies/web-best-practices.md` + `policies/guardrails.md` + `policies/verification.md` |
   | `*.sql`, `supabase/migrations/**` | the `supabase-postgres-best-practices` skill + `policies/security.md` (RLS, secrets) |
   | `.github/workflows/**` | `policies/git-safety.md` + `policies/security.md` |
   | `package.json`, lockfiles | `policies/dependency-safety.md` |
   | `docs/config/other` | the generic `Explore` agent (read-only search) |
   | `ios/**`, `android/**` | **reserved, not implemented.** Report `BLOCKED — no mobile reviewer defined` for any file under these paths. Do not review them against web criteria and do not silently skip them. |

   This table is kept platform-ready (matching how the `rfc` skill
   already plans product RFCs across iOS/Android/Web), but only the web
   and SQL/migration rows have a real reviewer today — this factory has
   not yet built a mobile reviewer agent, and none is invented here.

   - On `SIGNAL_SECURITY=1`, explicitly apply the `policies/security.md`
     lens regardless of file type.
   - **Static only** — no builds/tests/linters unless `--run-tests` is
     given.
   - Cited policy rules are **binding** review criteria; a residual
     violation is at least a 🟠 high finding.

7. **Normalise findings** into the two-axis issue model (see below),
   dropping duplicates, then apply the out-of-scope check
   (`policies/guardrails.md` `GR-SCOPE-001`) to every remaining finding
   whose *Suggested fix* is a refactor beyond the PR's stated scope:

   - Keep such a finding only as a 🟢 low **Deferred → backlog** item,
     never as a blocking issue, and never without either a cited rule
     or an explicit "judgment call" label.
   - Do not read files outside the diff and the code it calls to look
     for refactor opportunities.

8. **Compute the suggested verdict** from the issues (deterministic):

   ```bash
   printf '%s' '<issues-json>' | bash ../scripts/pr-review-verdict.sh
   ```

   where `<issues-json>` is:

   ```json
   { "issues": [{ "severity": "...", "confidence": "..." }, ...],
     "open_questions": <bool>, "test_gap": <bool> }
   ```

   The result is a **suggestion** only — the human posts the review.

9. **Render the R1 report** (sections below).

---

## R1 report template

Sections render top-to-bottom; those marked *(conditional)* appear only
when they have content.

1. **Verdict + metadata header** — TL;DR + suggested decision (approve /
   comment / request-changes); `#<number>` · `@author` · `base…head`
   (short) · `+/-` · files · **risk band**. The risk band ("how hard to
   look") is separate from the verdict ("what I found").
2. **Since your last review** *(conditional — only if `myLastReviewOid`
   set)* — the commits `myLastReviewOid..HEAD` and a one-line "what
   changed"; if `myLastReviewOid` is not an ancestor of HEAD
   (rebase/force-push), note that and show a full review without the
   precise delta. Full review is always done; `--since-last` narrows to
   the delta.
3. **Overview** — grouped into themes.
4. **Flow diagram** *(conditional)* — a Mermaid flow/sequence diagram
   only when control flow is non-trivial or spans modules.
5. **Issues (high → low)** — per-issue schema below; "None found" if
   empty.
6. **Test coverage** — does the diff carry tests for its changes?
7. **Positives** *(conditional)*.
8. **Questions for author** *(conditional)* — clarifications, not
   assertions.
9. **Deferred → backlog** *(conditional)* — real but out-of-scope items,
   each a candidate ticket (`<PROJECT-KEY>-NNNN: ...`, using this
   project's actual Jira project key). A refactor item explains why it
   is out of scope per `GR-SCOPE-001`.
10. **AI-generated disclaimer** — the report MUST end with the italic
    line:

   *This report was generated by an AI agent.*

   The report is local and chat-only (never posted to GitHub).

### Per-issue schema

Order issues high → low. ID = band letter + running number:
`C1, C2, H1, H2, M1, L1` (stable within one review).

- **Severity** — one of 🔴 critical / 🟠 high / 🟡 medium / 🟢 low
  (reviewer judgment; independent of the header risk band).
- **Confidence** — `high | medium | low` (a low-confidence high/critical
  never hard-blocks — it downgrades the verdict to `comment`).
- **Two axes:**
  - *finding-category* (what's wrong): `correctness` · `security` ·
    `concurrency/data-race` · `performance` · `error-handling` ·
    `API-design` · `backward-compat` · `test-gap` ·
    `convention/style` · `readability` · `docs`.
  - *change-type* (what introduced it): `behavior-change` ·
    `API-change` · `dependency-bump` · `optimization` · `bugfix` ·
    `new-feature` · `refactor` · `test-only` · `docs` ·
    `cleanup/deprecation` · `config/build/infra` ·
    `data/schema/migration`.
- **Location** — a **local worktree link** with line anchors: target
  `<worktree-branch-slug>/<repo-relative-path>#L42-L58`, display text
  the clean repo-relative path + lines. Non-contiguous ranges get
  separate links. No GitHub permalink (the report is chat-only; read
  while the worktree exists).
- **What it does** — one–three sentences stating, in grounded terms,
  the current behaviour at that location and citing the exact lines.
  This is the factual basis the rest of the issue builds on — not a
  restatement of the title.
- **Rule / criterion** *(conditional — when the finding rests on a
  stated rule)* — name the policy rule ID (for example
  `web-best-practices.md` `WEB-A11Y-001`, `guardrails.md`
  `GR-SCOPE-001`, `security.md` `SEC-SECRET-001`) or RFC/ADR clause,
  and quote its operative sentence, with a clickable link to the
  source. If the finding is judgment, say so in one clause instead of
  inventing a rule.
- **Evidence / cross-refs** *(conditional)* — the corroborating facts
  that make the finding checkable: a related test, a related call
  site, or the canonical value being violated — each a clickable link.
  Call out any nuance the finding must account for (for example a
  cited TODO that actually covers a different field, or a fix that
  carries a public-API cost).
- **Impact** — the concrete consequence for users or callers (what
  breaks, mis-renders, or misleads), not a generic "this is bad".
- **Suggested fix** — concrete and actionable; prefer bringing the code
  to parity with an existing in-repo pattern when one exists (link it),
  and flag feasibility caveats (public-API change, migration) when the
  obvious fix has them.
- **Before / after** — wrap long blocks in `<details>`.

**Every referenced file is a clickable link.** Every path an issue
names — the Location, the violated policy rule, sibling sources, tests,
and related call sites — MUST render as a local worktree link with line
anchors (display text = the clean repo-relative path + lines). Never
leave a referenced file as plain text or inline code. Non-contiguous
ranges get separate links.

**Depth scales with severity.** 🔴/🟠 issues carry the full field set
above; 🟡 may collapse to a single line with *What it does* into
*Impact*; 🟢 low may fold *What it does* into *Impact* and never strip
the grounding (Location + rule/evidence links) from a finding. Never
pad a nit to look severe, and never strip the grounding from a
high/critical finding.

---

## Example issue

### 🟠 H1 — Missing RLS policy on new table

`category: security` · `change-type: new-feature` · `confidence: high`

**What it does:** The new `invoices` table is created without a
`CREATE POLICY` statement, so Postgres RLS defaults to denying all rows
once RLS is enabled, or — if RLS is never enabled on the table — allows
any authenticated role unrestricted access.

**Rule:** `security.md` `SEC-AUTH-001` — authorization controls must
not be bypassed or left undefined for a change touching access control.

**Evidence:** The migration enables `ALTER TABLE invoices ENABLE ROW
LEVEL SECURITY` but defines no policy, so every query against the table
currently returns zero rows for every role.

**Impact:** Either the feature is unusable (RLS denies everything) or,
if RLS is disabled to "fix" that, tenant data becomes readable across
accounts.

**Fix:** Add a `CREATE POLICY` restricting rows to the owning tenant,
matching the pattern used by the sibling `invoices_line_items` table.
Add a test asserting cross-tenant access is denied.

<details><summary>Before / after</summary>

```diff
- ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
+ ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
+ CREATE POLICY invoices_tenant_isolation ON invoices
+   USING (tenant_id = current_setting('app.tenant_id')::uuid);
```

</details>
