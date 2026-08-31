# Audit Methodology

Shared evidence-based methodology for auditing factory artifacts against their anatomy standards.

This file is the source of truth for Finding Classification, Evidence, Proposed Changes, and read-only audit boundaries.
It is used by both `skill-audit` (audits skills against `Skill Anatomy`) and `policy-audit` (audits policies against `Policy Anatomy`).

Loaded on demand via progressive disclosure — `SKILL.md` keeps a brief pointer, details live here.

## Finding Classification

Classify every meaningful finding as exactly one of:

### Required fix

The target violates a required standard rule (Skill Anatomy or Policy Anatomy) or has a defect that can cause incorrect, unsafe, or unreliable behavior.

### Recommended improvement

The target meets the required standard but can be clearer, smaller, safer, easier to enforce, or more maintainable.

### Not applicable

The standard does not apply to the target in this context.

Do not convert recommended patterns into mandatory requirements.

## Evidence

Every finding must include:

- Rule or standard being checked.
- Evidence from the target (exact file, lines, or behavior).
- Impact if not fixed.
- Recommended change.

Do not report a defect without evidence.

Do not invent missing content.

## Proposed Changes

Provide focused, minimal-diff changes.

Prefer:

- Exact replacement text.
- Exact insertion point.
- Minimal diff.

Do not rewrite an entire file when a small change is sufficient.

After explicit user approval:

1. Apply only the approved changes.
2. Show the diff.
3. Validate the changed files (frontmatter, line count, verification).
4. Re-run the audit.
5. Report the new result (PASS / PASS WITH RECOMMENDATIONS / FAIL).

## Read-Only Boundary

The audit is read-only by default.

Do not:

- Edit the target.
- Delete files.
- Rename files.
- Move files.
- Change references or enforcement.
- Apply proposed changes.

Without explicit approval, only produce the audit report.

## Self-Improvement

Review the audit run for:

- False positives / false negatives.
- Missed standard rules.
- Repeated manual steps that should be scripted.
- Missing validation or confusing findings.

Only propose a factory change when real evidence shows future audits should behave differently.

Do not propose cosmetic or hypothetical changes.

## Portability Note

Per `Skill Anatomy` Shared References, this file lives at repo-root `references/` (not per-skill). A per-skill install that copies only `skills/<name>/` will not carry this sibling; that gap is tracked in [addyosmani/agent-skills#361](https://github.com/addyosmani/agent-skills/issues/361).
