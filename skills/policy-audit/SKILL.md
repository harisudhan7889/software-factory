---
name: policy-audit
description: Audits factory policy files against the Policy Anatomy standard and proposes focused, evidence-based improvements. Use when reviewing, validating, standardizing, or optimizing a policy before or after deployment.
---

# Policy Audit

## Overview

Audit a policy against the factory Policy Anatomy standard.

The audit is read-only by default.

The goal is to find required fixes and useful improvements without duplicating
the policy standard or changing files automatically.

## When to Use

Use when:

- A new policy needs review.
- An existing policy needs validation.
- Policies need standardization.
- A policy has unclear rules or boundaries.
- Policies may conflict or duplicate each other.
- A policy may be too large or difficult to maintain.
- The user asks for a policy audit.

Do not use this skill to:

- Implement application features.
- Change runtime enforcement.
- Modify a policy without approval.
- Invent policy requirements that are not supported by the Policy Anatomy
  standard or approved factory decisions.

## Inputs

Read:

1. The target policy.
2. `~/.opencode/policies/policy-anatomy.md` (canonical; `policies/policy-anatomy.md` when running from repo root).
3. Related policies when needed to check ownership, duplication, or conflict.

Read only the files required to verify findings.

Note: Finding Classification, Evidence, and Proposed Changes follow `references/audit-methodology.md` (shared with `skill-audit`).

## Audit Process

### 1. Locate the policy

Determine:

- Policy path.
- Policy name.
- Related policies.
- Referenced enforcement mechanisms.
- Referenced supporting documents.

### 2. Compare against Policy Anatomy

Check:

- Purpose
- Scope
- Principles
- Rules
- Decision boundaries
- Exceptions
- Enforcement
- Verification
- Policy ownership
- Single source of truth
- Policy status when applicable
- Change control
- Naming
- Cross-policy references
- Progressive disclosure
- Self-improvement

Do not require a section when it is not applicable.

### 3. Audit rule quality

For each important rule, check:

- Is the rule specific?
- Is the trigger clear?
- Is the required behavior clear?
- Is forbidden behavior clear when needed?
- Are exceptions explicit?
- Is the rule testable?
- Can a human understand what compliance means?

Reject vague rules such as:

```text
Be careful with security.
```

Prefer rules such as:

```text
If a secret is detected in a proposed commit, stop the commit.
```

### 4. Audit severity

Check that severity is used consistently:

- `BLOCK`
- `CONFIRM`
- `WARN`
- `INFO`

Verify that the action associated with each severity is clear.

Do not add severity where it does not improve the policy.

### 5. Audit ownership and boundaries

Determine whether each rule belongs in the target policy.

Look for:

- Product requirements placed in policies.
- Architecture decisions placed in policies.
- Workflow procedures copied into policies.
- Rules owned by another policy.
- Duplicate rules across policies.

Recommend a direct reference to the owning policy instead of duplicated
detailed rules.

### 6. Audit enforcement

Check whether the policy clearly separates:

- Policy rule
- Enforcement mechanism
- Verification

If a rule can be reliably enforced by code, hooks, scanners, CI, or tool
permissions, identify that opportunity.

Do not require executable enforcement for rules that need human judgment.

### 7. Audit exceptions and decision boundaries

Check that high-impact exceptions are explicit.

Verify that the policy states when an agent must:

- Stop
- Ask for approval
- Continue with a warning
- Record an observation

Do not allow agents to infer important exceptions.

### 8. Audit verification

Check that important rules have evidence that can prove compliance.

Prefer evidence such as:

- Test results
- Static checks
- Secret scans
- Git state
- CI results
- Tool results
- Diff review
- Audit records

Do not accept:

```text
Looks correct.
```

as sufficient evidence for a required control.

### 9. Audit consistency

Check the target policy against related policies.

Look for:

- Contradictory rules
- Conflicting severity
- Different definitions of the same term
- Different approval requirements
- Duplicate sources of truth

When a conflict cannot be resolved from policy ownership, report it and ask
for a decision.

### 10. Audit context efficiency

Check whether the policy is focused.

Identify content that should move to:

- Another policy
- A supporting reference
- A workflow document
- An executable enforcement mechanism

Do not split a small policy without a clear maintenance or context benefit.

## Finding Classification

Follow `references/audit-methodology.md` — Finding Classification. Classify every finding as exactly one of Required fix / Recommended improvement / Not applicable. Do not convert recommended patterns into mandatory requirements. See shared file for full definitions (Required fix = violates Policy Anatomy or causes unsafe behavior).

## Evidence

Follow `references/audit-methodology.md` — Evidence. Every finding must include rule, evidence, impact, recommended change; no defect without evidence, no invented content.

## Proposed Changes

Follow `references/audit-methodology.md` — Proposed Changes. Provide focused minimal diff (exact insertion/replacement text); after approval show diff, validate, re-run audit, report new result.

## Read-Only Boundary

The audit is read-only by default.

Do not:

- Edit the policy.
- Delete files.
- Rename files.
- Move policies.
- Change enforcement.
- Change related policies.

After explicit user approval:

1. Apply only the approved changes.
2. Show the diff.
3. Validate the changed policy.
4. Re-run the audit.
5. Report the new result.

## Verification

Before completing the audit, confirm:

- [ ] Policy Anatomy was read.
- [ ] Purpose and scope were checked.
- [ ] Rules were checked for specificity and testability.
- [ ] Severity was checked.
- [ ] Exceptions and decision boundaries were checked.
- [ ] Enforcement and verification were checked.
- [ ] Ownership and duplication were checked.
- [ ] Related policy conflicts were checked when relevant.
- [ ] Context efficiency was checked.
- [ ] Findings are evidence-based.
- [ ] Report was generated per `## Report` template and audit stopped.

## Report

Use:

```text
# Policy Audit

## Policy

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
Assessment: <focused / should extract ...>

## Findings

<evidence-backed detail>

## Proposed Changes

<focused changes or diff>

## Verification

- [x] ...
- [ ] ...
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The rule is clear enough." | A policy must be specific enough to guide and verify behavior. |
| "This exception is obvious." | Important exceptions must be explicit. |
| "The other policy probably covers it." | Identify the owner and reference it directly. |
| "We can enforce this later." | Identify enforcement needs now, even when implementation comes later. |
| "The policy is short, so structure does not matter." | Short policies still need clear ownership, rules, and verification. |

## Red Flags

Treat these as audit signals:

- A rule uses vague terms such as "be careful" or "use best judgment" without
  defining the boundary.
- A required rule has no verification method.
- The same rule appears in multiple policies.
- A policy contains workflow steps that belong in a reference.
- A policy contains product or architecture decisions.
- A severity is defined without behavior.
- An exception is implied but not stated.
- A policy says "must" but provides no enforcement or verification path.
- Policies disagree on the same control.

## Self-Improvement

Review the audit run for:

- False positives.
- False negatives.
- Missed Policy Anatomy rules.
- Repeated manual audit steps.
- Missing validation.
- Confusing findings.

Only propose a factory change when real evidence shows that future policy
audits should behave differently.

Do not propose cosmetic or hypothetical changes.

Follow the common self-improvement standard in:

../self-improvement/references/standard.md
