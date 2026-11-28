# Known Limitations

Factory-wide findings that were noticed during a run but **not** acted
on immediately — classification #2 ("Known limitation") from
`../../../skills/self-improvement/references/standard.md`. An applied
change does not get an entry here; the skill/policy diff and its commit
are already the record (`policies/observability.md`: Git is the source
of truth).

Read this file before proposing a factory change, so a known gap isn't
silently rediscovered as new. Each entry carries a `Status`; update it
to `resolved` (with the fixing commit/PR) rather than deleting the
entry, so the history of what was wrong and when it was fixed survives.

Statuses: `open` · `resolved` · `wontfix`.

This file is shared by every project. An entry MUST NOT contain project
names, repository names, Jira keys, customer data, or project code. See
"No project specifics in factory memory" in the standard.

---

## 2026-11-14 — rfc skill defaults to three platforms in a web-only factory

**Status:** open

**Finding:** `skills/rfc/references/create.md` (Step 2 and Step 5) still
asks for iOS/Android/Web platforms and defaults to all three when none
is given, and generates per-platform files using Swift/Kotlin/
TypeScript templates.

**Evidence:** This factory's actual policies (`policies/
web-best-practices.md`, `skills/github-web-ci`, ADR-0002 "default web
backend architecture") only support web. No iOS or Android capability
exists anywhere else in the factory.

**Affected artifact:** `skills/rfc/references/create.md`, `references/
platform.md`.

**Why not fixed now:** found while adapting an unrelated copied-in file
(`skills/factory/references/pr-review.md`, RFC-0004); fixing the `rfc`
skill itself was out of scope for that task.

**Expected fix (not yet proposed):** default to `web` only unless the
context or user explicitly asks for iOS/Android, and gate per-platform
scaffolding on an explicit request rather than assuming all three.

---

## 2026-11-14 — Self-improvement logic duplicated instead of shared

**Status:** open

**Finding:** `skills/factory/references/github-pr.md` and
`skills/factory/references/github-provisioning.md` each carry a full
inline "Self-Improvement Review" section (trigger, classification,
proposal format, approval, apply) instead of delegating to
`skills/self-improvement/references/standard.md`, the way
`skills/factory/SKILL.md` and the newer references already do.

**Evidence:** Both files duplicate the same classify/propose/approve/
apply steps with near-identical wording; the shared standard was
introduced after they were written and they were never migrated to
reference it.

**Affected artifact:** `skills/factory/references/github-pr.md`,
`skills/factory/references/github-provisioning.md`.

**Why not fixed now:** noticed while wiring the memory read/write rules
into `skills/self-improvement/references/standard.md`; refactoring two
existing reference workflows to delegate instead of duplicate is a
separate, larger change than that update.

**Expected fix (not yet proposed):** replace each inline section with a
pointer to `../self-improvement/references/standard.md`, so a future
change to the shared standard (like this memory mechanism) does not
need to be copied into every reference file by hand.

---

## 2026-11-26 — Copilot "Suppressed comments" format is unverified

**Status:** open

**Finding:** `skills/factory/references/address-comments.md` (Phase 2)
parses a `<details><summary>Suppressed comments (N)</summary>` block in
Copilot's review summary, with `**<path>:<line>**` item headings. That
format was assumed when the procedure was written and has not been
matched to a real Pull Request.

**Evidence:** A sampled Copilot review summary on a public Pull Request
used a newer layout (an "open issues" list, no "Suppressed comments"
text). A scan of 60 recent Pull Requests in one large open-source
repository found no summary with the phrase. This shows the format can
differ. It does not show the block never exists.

**Affected artifact:** `skills/factory/references/address-comments.md`,
`skills/factory/scripts/pr-threads-fetch.sh` (its `test("Suppressed
comments")` filter).

**Why not fixed now:** no real example was available to build against.
The procedure tells the agent to show unmatched text to the user instead
of guessing.

**Expected fix (not yet proposed):** when a PR with a real suppressed
block is found, record its exact shape here and tighten Phase 2 and the
script filter to match.
