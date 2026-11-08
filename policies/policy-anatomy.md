# Policy Anatomy

This document defines the standard structure and quality rules for software
factory policy files. Policies define rules, constraints, controls, or required
conditions. Policies are not workflow instructions.

## File Location and Naming

Shared factory policies live in `policies/`: `policy-anatomy.md`,
`guardrails.md`, `security.md`, `verification.md`, `git-safety.md`,
`web-best-practices.md`, `observability.md`, and `dependency-safety.md`. A
policy may be scoped to a subsystem when the factory needs that separation.
Keep one clear source of truth for each policy.

Use `lowercase-hyphen-separated.md` and a name that describes the policy's
responsibility.

## Policy File Format

Policy files do not need YAML frontmatter unless the consuming runtime requires
metadata. Start with a clear `# Policy Name` title.

## Standard Sections

Use this structure when applicable, and do not add sections that do not improve
the policy:

```markdown
# Policy Name

## Purpose              What the policy protects or controls.
## Scope                Where the policy applies.
## Principles           The main principles behind the policy.
## Rules                The actual policy requirements.
## Decision Boundaries  Actions that require stopping, approval, or escalation.
## Exceptions           Explicit permitted exceptions.
## Enforcement          How the policy can be enforced.
## Verification         How compliance is proven.
## Relationship to Other Policies   Related policies and ownership boundaries.
## Self-Improvement     Evidence-based improvement rules.
```

## Policy Rule Anatomy

Each important rule is atomic and testable:

```markdown
### POLICY-ID — Rule name

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
<explicit exception or "None.">

Evidence:
<how compliance or violation is demonstrated>
```

Omit a field only when it clearly does not apply. Use a stable ID such as
`GR-SCOPE-001` so other files can reference the rule.

## Severity

Severity is not only a label. Each level has required behavior.

- **BLOCK:** the action must stop. Use for secret exposure, unsafe destructive action, missing required approval or verification, critical security violation, and known cross-Story contamination.
- **CONFIRM:** the action needs explicit human approval. Use for high-impact but potentially valid actions, architectural changes, scope expansion, and sensitive external mutations. Without approval the action stays blocked.
- **WARN:** the action may continue when policy permits, and the condition must be reported. Use for non-blocking risks, known limitations, and unusual but acceptable conditions.
- **INFO:** record the condition for traceability. Use for observations, low-risk information, and useful diagnostics.

## Rule Quality

A good rule is specific, observable, testable, relevant, limited in scope, and
consistent with other policies.

Prefer "Before pushing, verify that the source branch does not contain commits
from another Jira Story." Avoid "Be careful when pushing code."

Prefer "If a force-push is required, stop and ask for approval." Avoid "Use Git
safely."

## Ownership and Single Source of Truth

Each policy has a clear responsibility:

```text
guardrails.md           → cross-cutting agent behavior
security.md             → security controls
verification.md         → evidence and completion
git-safety.md           → Git and branch safety
web-best-practices.md   → web quality
observability.md        → factory execution record
dependency-safety.md    → dependency safety
```

Place a rule where its primary responsibility belongs, not merely where it is
related. Do not duplicate the same detailed rule across policy files. When two
policies need one concept, keep the detailed rule in the owning policy and
reference it from the other. A policy may summarize the relationship but must
not create a conflicting copy.

## Policy Boundaries

Policies define constraints. They must not silently define product
requirements, architecture decisions, UX or UI design decisions, Jira scope, or
implementation details, unless the policy is meant to govern that area. For
example, "Users must be able to recover access" is a product requirement,
"Recovery credentials must not be logged" is policy, and "Use a specific
authentication provider" is architecture.

## Exceptions

Do not leave important exceptions implicit. Write `Exception: <explicit
condition>` or `Exception: None.` An exception must not silently weaken another
policy.

## Enforcement

Separate policy from enforcement. "Secrets must not enter source control" is
policy. A secret scanner, pre-commit hook, or CI check is enforcement. Do not
put large hook or script details in a policy unless they are needed to
understand the rule.

## Verification

Every important policy defines how compliance is shown. Prefer evidence such as
a test result, static check, secret scan, Git state, CI result, Jira read-back,
design inspection, tool result, or diff review. Avoid vague evidence such as
"Looks correct." A policy is compliant only when its required evidence exists.

## Policy Status

When lifecycle matters, use `Status: Proposed / Active / Deprecated`.
`Proposed` means not yet approved for use, `Active` means approved and in
effect, and `Deprecated` means kept for history and no longer used. Do not
silently change an approved policy's meaning.

## Change Control

When changing an active policy:

1. Identify the affected rules and explain the reason.
2. Show the proposed change and obtain the required human approval.
3. Apply only the approved change and validate the policy afterward.
4. Record the change when project traceability requires it.

Do not silently weaken a policy to make a workflow pass.

## Policy Conflicts

When policies conflict:

1. Identify the conflicting rules and the policies involved.
2. Check whether one policy clearly owns the decision.
3. If ownership does not resolve it, stop and ask for the decision.

Do not resolve a conflict by choosing the rule that is easier to follow.

## Progressive Disclosure and References

Keep each policy focused, and aim for 300 lines or fewer. Move material to a
supporting reference when it is long, needed by only some workflows, a reusable
checklist, or a detailed procedure rather than a rule. Do not turn a policy into
a workflow manual.

Reference related policies directly, for example "Use `policies/security.md`
for secret-handling requirements." Avoid long chains of references.

## Policy Review Checklist

Before accepting a policy, confirm:

- [ ] Purpose, scope, and ownership are clear.
- [ ] Rules are specific and testable, and severity is used consistently.
- [ ] Exceptions are explicit and enforcement is separated from policy.
- [ ] Verification produces evidence.
- [ ] No conflicting duplicate rules exist, and related policies are referenced directly.
- [ ] The policy does not silently define product or architecture decisions.
- [ ] The file is focused and maintainable.

## Self-Improvement

Review policy use for repeated violations, ambiguous rules, false positives,
missing enforcement, missing evidence, policy conflicts, and repeated manual
work. Propose a change only when real evidence shows future behavior should
change. Do not weaken a policy only because it blocks inconvenient work.

## Standard of Quality

A policy is good when an agent and a human can answer: what is required, when it
applies, what is forbidden, what happens when it triggers, who can approve an
exception, how compliance is verified, and which policy owns the rule. If any
answer is missing, improve the policy before relying on it.
