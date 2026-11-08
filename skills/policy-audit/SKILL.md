---
name: policy-audit
description: Audits factory policy files against the Policy Anatomy standard and proposes focused, evidence-based improvements. Use when reviewing, validating, standardizing, or optimizing a policy before or after deployment.
---

# Policy Audit

## Overview

Audit a policy against the factory Policy Anatomy standard. The audit is
read-only by default. Find required fixes and useful improvements without
duplicating the standard or changing files automatically.

## When to Use

- A new policy needs review, or an existing policy needs validation.
- Policies need standardization, or may conflict, duplicate each other, or be too large.
- A policy has unclear rules or boundaries.
- The user asks for a policy audit.

Do not use to implement application features, change runtime enforcement,
modify a policy without approval, or invent requirements that the Policy
Anatomy standard or approved factory decisions do not support.

## Inputs

1. The target policy.
2. `~/.opencode/policies/policy-anatomy.md` (canonical; `policies/policy-anatomy.md` from the repo root).
3. Related policies, only when needed to check ownership, duplication, or conflict.

Finding Classification, Evidence, Proposed Changes, and the Read-Only Boundary
follow `references/audit-methodology.md` (shared with `skill-audit`). Classify
each finding as exactly one of Required fix, Recommended improvement, or Not
applicable. Every finding needs rule, evidence, impact, and recommended change.

## Audit Process

Read only the files needed to verify a finding. Do not require a section that
does not apply.

1. **Locate the policy.** Path, name, related policies, referenced enforcement mechanisms and supporting documents.
2. **Compare against Policy Anatomy.** Purpose, scope, principles, rules, decision boundaries, exceptions, enforcement, verification, ownership, single source of truth, status, change control, naming, cross-policy references, progressive disclosure, self-improvement.
3. **Audit rule quality.** Each important rule needs a clear trigger, required behavior, forbidden behavior when needed, explicit exceptions, and testable compliance. Reject "Be careful with security." Prefer "If a secret is detected in a proposed commit, stop the commit."
4. **Audit severity.** `BLOCK`, `CONFIRM`, `WARN`, `INFO` must each map to a clear action and be used consistently. Do not add severity where it adds nothing.
5. **Audit ownership.** Look for product requirements, architecture decisions, or workflow procedures inside the policy, rules owned by another policy, and duplicates. Recommend a direct reference to the owning policy.
6. **Audit enforcement.** The policy should separate rule, enforcement mechanism, and verification. Point out rules that code, hooks, scanners, CI, or tool permissions could enforce. Do not require executable enforcement for rules that need human judgment.
7. **Audit exceptions and decision boundaries.** High-impact exceptions must be explicit. The policy must say when an agent must stop, ask for approval, continue with a warning, or record an observation. Agents must not infer important exceptions.
8. **Audit verification.** Important rules need provable evidence: test results, static checks, secret scans, git state, CI results, tool results, diff review, audit records. "Looks correct" is not evidence for a required control.
9. **Audit consistency.** Check for contradictory rules, conflicting severity, differing definitions or approval requirements, and duplicate sources of truth. If ownership cannot settle a conflict, report it and ask for a decision.
10. **Audit context efficiency.** Identify content that belongs in another policy, a reference, a workflow document, or executable enforcement. Do not split a small policy without a clear benefit.

## Verification

Before completing the audit, confirm:

- [ ] Policy Anatomy was read.
- [ ] Purpose, scope, rules (specificity, testability), and severity were checked.
- [ ] Exceptions, decision boundaries, enforcement, and verification were checked.
- [ ] Ownership, duplication, and related-policy conflicts were checked.
- [ ] Context efficiency was checked.
- [ ] Findings are evidence-based.
- [ ] The report follows the template below and the audit stopped there.

## Report

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

- A rule uses vague terms ("be careful", "use best judgment") without a boundary.
- A required rule has no verification method, or says "must" with no enforcement path.
- The same rule appears in multiple policies, or policies disagree on one control.
- A policy contains workflow steps, product decisions, or architecture decisions.
- A severity is defined without behavior, or an exception is implied but not stated.

## Self-Improvement

Follow `../self-improvement/references/standard.md`. Review the run for false
positives, false negatives, missed Policy Anatomy rules, repeated manual steps,
and confusing findings. Propose a factory change only when real evidence shows
future audits should behave differently; no cosmetic or hypothetical changes.
