---
name: skill-audit
description: Audits an agent skill against the project's Skill Anatomy standard and proposes focused, evidence-based improvements. Use when reviewing, validating, or standardizing a skill before or after deployment.
---

# Skill Audit

## Overview

Audit an existing skill against the project's Skill Anatomy standard.

The audit is read-only by default.

The goal is to identify required fixes and useful improvements without
duplicating the standard or changing files automatically.

## When to Use

Use when:

- A new skill needs review.
- An existing skill needs validation.
- A skill needs optimization.
- A skill has unclear triggers or workflow.
- A skill may be too large or contain unnecessary duplication.
- The user asks for a skill audit.

Do not use this skill to:

- Implement product features.
- Rewrite application code.
- Modify the target skill without approval.
- Invent requirements that are not in the Skill Anatomy standard.

## Inputs

Read these before auditing:

1. The target skill's `SKILL.md`.
2. The target skill's supporting files when relevant.
3. `references/skill-anatomy.md` as the audit standard.

Read only the additional files required to verify a finding.

Note: Finding Classification, Evidence, and Proposed Changes follow `references/audit-methodology.md` (shared with `policy-audit`).

## Audit Process

### 1. Identify the target

Determine:

- Skill directory.
- `SKILL.md` path.
- Supporting files.
- `references/`.
- `scripts/`.
- Cross-skill references.

### 2. Compare with the standard

Check:

- Frontmatter.
- Description and trigger clarity.
- Scope.
- Workflow specificity.
- Required versus recommended structure.
- Supporting-file use.
- Progressive disclosure.
- Context efficiency.
- Script conventions when scripts exist.
- Naming conventions.
- Cross-skill references.
- Verification.
- Anti-rationalization.
- Red flags.
- Duplication.
- Internal consistency.

Do not require sections that are not applicable.

### 3. Check behavior, not only structure

Ask:

- Can an agent discover when to use the skill?
- Can an agent follow the workflow without guessing?
- Are decision points explicit?
- Are stop conditions clear?
- Are approvals explicit where needed?
- Can completion be verified with evidence?
- Does the skill avoid duplicating another skill's process?

### 4. Check context efficiency

Measure the target `SKILL.md`.

If it is over 500 lines, identify material that can move to supporting files.

Do not fail a skill only because it exceeds 500 lines.

Determine whether the size creates a meaningful context or maintenance
problem.

### 5. Check shared material

Identify duplicated content that should be shared.

Do not remove duplication automatically.

Recommend a clear source of truth and a direct reference.

## Finding Classification

Follow `references/audit-methodology.md` — Finding Classification. Classify every finding as exactly one of Required fix / Recommended improvement / Not applicable. Do not convert recommended patterns into mandatory requirements. See shared file for full definitions.

## Evidence

Follow `references/audit-methodology.md` — Evidence. Every finding must include rule, evidence, impact, recommended change; no defect without evidence, no invented content.

## Proposed Changes

Follow `references/audit-methodology.md` — Proposed Changes. Provide focused minimal diff (exact insertion/replacement text); after approval show diff, validate, re-run audit, report new result.

## Verification

Before completing the audit, confirm:

- [ ] Frontmatter was checked.
- [ ] Description and trigger conditions were checked.
- [ ] Workflow was checked for specific actions.
- [ ] Scope and decision boundaries were checked.
- [ ] Verification was checked.
- [ ] Context efficiency was checked.
- [ ] Supporting files and references were checked when relevant.
- [ ] Duplication was checked.
- [ ] Internal consistency was checked.
- [ ] Findings are evidence-based.

## Report

Use:

```text
# Skill Audit

## Skill
<name>

## Path
<path>

## Result
PASS / PASS WITH RECOMMENDATIONS / FAIL

## Summary
<short summary>

## Required Fixes
- ...

## Recommended Improvements
- ...

## Not Applicable
- ...

## Context Efficiency
Lines: <number>
Assessment: <result>

## Verification
- [x] ...
- [ ] ...

## Proposed Changes
<focused changes or diff>
```

## Modification Boundary

The audit is read-only by default.

Do not:

- Edit the target skill.
- Delete files.
- Rename files.
- Move files.
- Change references.
- Apply proposed changes.

After the user explicitly approves proposed changes:

1. Apply only the approved changes.
2. Show the diff.
3. Validate the changed files.
4. Re-run the audit.
5. Report the new result.

## Self-Improvement

Review the audit run for:

- False positives.
- False negatives.
- Missed standard rules.
- Repeated manual audit steps.
- Missing validation.
- Confusing findings.

Only propose a factory change when real evidence shows that future audits
should behave differently.

Do not propose cosmetic or hypothetical changes.
