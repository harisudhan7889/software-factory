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
