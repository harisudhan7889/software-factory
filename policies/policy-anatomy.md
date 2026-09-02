# Policy Anatomy

This document defines the standard structure and quality rules for software
factory policy files.

Policies define rules, constraints, controls, or required conditions.

Policies are not workflow instructions.

## File Location

Shared factory policies live in:

```text
policies/
  policy-anatomy.md
  guardrails.md
  security.md
  verification.md
  git-safety.md
  web-best-practices.md
  observability.md
  dependency-safety.md
```

A policy may also be scoped to a specific subsystem when the factory needs
that separation.

Keep one clear source of truth for each policy.

## Policy File Format

Policy files do not require YAML frontmatter unless the runtime that consumes
the policy explicitly requires metadata.

A policy should start with a clear title:

```markdown
# Policy Name
```

## Standard Sections

Use the following structure when applicable:

```markdown
# Policy Name

## Purpose
What the policy protects or controls.

## Scope
Where the policy applies.

## Principles
The main principles behind the policy.

## Rules
The actual policy requirements.

## Decision Boundaries
Actions that require stopping, approval, or escalation.

## Exceptions
Explicit permitted exceptions.

## Enforcement
How the policy can be enforced.

## Verification
How compliance with the policy is proven.

## Relationship to Other Policies
Related policies and ownership boundaries.

## Self-Improvement
Evidence-based improvement rules.
```

The structure is a recommended pattern.

Do not add sections that do not improve the policy.

## Policy Rule Anatomy

Each important rule should be atomic and testable.

Use this structure:

```markdown
## POLICY-ID — Rule name

Severity:
BLOCK / CONFIRM / WARN / INFO

Rule:
<what must or must not be true>

Trigger:
<when the rule applies>

Required action:
<what must happen>

Forbidden action:
<what must not happen>

Exception:
<explicit exception or "None">

Evidence:
<how compliance or violation is demonstrated>
```

Not every rule needs every field when the field is clearly not applicable.

## Severity

Use four severity levels.

### BLOCK

The action must stop.

Use for:

- Secret exposure
- Unsafe destructive action
- Required approval missing
- Critical security violation
- Known cross-Story contamination
- Required verification missing

### CONFIRM

The action requires explicit human approval.

Use for:

- High-impact but potentially valid actions
- Architectural changes
- Scope expansion
- Sensitive external mutations

### WARN

The action may continue when policy permits, but the condition must be
reported.

Use for:

- Non-blocking risks
- Known limitations
- Unusual but acceptable conditions

### INFO

Record the condition for traceability.

Use for:

- Observations
- Low-risk information
- Useful diagnostics

Do not use severity only as a label.

The required behavior for each severity must be clear.

## Rule Quality

A good policy rule is:

- Specific
- Observable
- Testable
- Relevant
- Limited in scope
- Consistent with other policies

Prefer:

```text
Before pushing, verify that the source branch does not contain commits from
another Jira Story.
```

Avoid:

```text
Be careful when pushing code.
```

Prefer:

```text
If a force-push is required, stop and ask for approval.
```

Avoid:

```text
Use Git safely.
```

## Policy Ownership

Each policy must have a clear responsibility.

Example:

```text
guardrails.md
→ cross-cutting agent behavior

security.md
→ security controls

verification.md
→ evidence and completion

git-safety.md
→ Git and branch safety

web-best-practices.md
→ web quality

observability.md
→ factory execution record

dependency-safety.md
→ dependency safety
```

Do not place a rule in a policy merely because it is related.

Place the rule where its primary responsibility belongs.

## Single Source of Truth

Do not duplicate the same detailed rule across multiple policy files.

When two policies need the same concept:

1. Identify the policy that owns the rule.
2. Keep the detailed rule there.
3. Reference that policy from the other policy.

A policy may summarize the relationship, but should not create conflicting
copies of the same rule.

## Policy Boundaries

Policies define constraints.

They must not silently define:

- Product requirements
- Architecture decisions
- UX decisions
- UI design decisions
- Jira scope
- Implementation details

unless the policy is specifically intended to govern that area.

For example:

```text
Product requirement:
Users must be able to recover access.

Policy:
Recovery credentials must not be logged.

Architecture:
Use a specific authentication provider.
```

These are different concerns.

## Exceptions

Do not leave important exceptions implicit.

Use:

```markdown
Exception:
<explicit condition>
```

If no exception is allowed:

```markdown
Exception:
None.
```

An exception must not silently weaken another policy.

If two policies conflict:

- Identify the conflict.
- Determine ownership.
- Ask when the conflict cannot be resolved safely.

## Enforcement

Separate policy from enforcement.

A policy states:

```text
Secrets must not enter source control.
```

An enforcement mechanism may be:

```text
Secret scanner
Pre-commit hook
CI check
```

Do not put large implementation details for hooks or scripts into the policy
unless they are required to understand the rule.

## Verification

Every important policy should define how compliance can be demonstrated.

Prefer evidence such as:

- Test result
- Static check
- Secret scan
- Git state
- CI result
- Jira read-back
- Design inspection
- Tool result
- Diff review

Avoid vague evidence such as:

```text
Looks correct.
```

A policy may be marked compliant only when its required evidence exists.

## Policy Status

When policy lifecycle is important, use:

```text
Status:
Proposed / Active / Deprecated
```

Use:

```text
Proposed
```

when the policy is not yet approved for use.

Use:

```text
Active
```

when the policy is approved and in effect.

Use:

```text
Deprecated
```

when it remains for history but should no longer be used.

Do not silently change an approved policy's meaning.

## Change Control

When changing an active policy:

1. Identify the affected rules.
2. Explain the reason for change.
3. Show the proposed change.
4. Obtain the required human approval.
5. Apply only the approved change.
6. Validate the policy after the change.
7. Record the change when project traceability requires it.

Do not silently weaken a policy to make a workflow pass.

## Policy Conflicts

When policies conflict:

1. Identify the conflicting rules.
2. Identify the policies involved.
3. Determine whether one policy clearly owns the decision.
4. If ownership does not resolve the conflict, stop.
5. Ask for the required decision.

Do not resolve policy conflicts by choosing the rule that is easier to
follow.

## Progressive Disclosure

Keep each policy focused.

Move detailed material to supporting references when:

- The material is long.
- Only some workflows need it.
- It is a reusable checklist.
- It contains detailed procedures rather than policy rules.

Do not turn policy files into large workflow manuals.

## Policy Naming

Use:

```text
lowercase-hyphen-separated.md
```

Examples:

```text
guardrails.md
security.md
git-safety.md
web-best-practices.md
verification.md
observability.md
dependency-safety.md
```

Use clear names that describe the policy's responsibility.

## Cross-Policy References

Reference related policies directly.

Example:

```markdown
Use `policies/security.md` for secret-handling requirements.
```

Do not create long chains of references.

Prefer direct references.

## Policy Review Checklist

Before accepting a policy, confirm:

- [ ] Purpose is clear.
- [ ] Scope is clear.
- [ ] Ownership is clear.
- [ ] Rules are specific and testable.
- [ ] Severity is used consistently.
- [ ] Exceptions are explicit.
- [ ] Enforcement is separated from policy.
- [ ] Verification produces evidence.
- [ ] No conflicting duplicate rules exist.
- [ ] Related policies are referenced directly.
- [ ] The policy does not silently define product or architecture decisions.
- [ ] The file is focused and maintainable.

## Self-Improvement

Review policy use for:

- Repeated violations
- Ambiguous rules
- False positives
- Missing enforcement
- Missing evidence
- Policy conflicts
- Repeated manual work

Only propose a policy change when real evidence shows that future behavior
should change.

Do not weaken a policy only because it blocks inconvenient work.

## Standard of Quality

A policy is good when an agent and a human can answer:

```text
What is required?
When does it apply?
What is forbidden?
What happens when it triggers?
Who can approve an exception?
How do we verify compliance?
Which policy owns the rule?
```

If these questions cannot be answered, improve the policy before relying on it.
