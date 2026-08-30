---
name: factory
description: Manage and evolve the software factory itself. Use for factory-level architecture, provisioning, workflow design, capability planning, and self-improvement.
---

# Software Factory

The software factory is the global engineering system that coordinates
product discovery, RFCs, ADRs, Jira planning, implementation, verification,
delivery, and continuous improvement.

## Available operations
- `/factory provision` — inspect and provision the current project's GitHub repository according to the factory GitHub provisioning specification.
- `/factory pr open` — prepare, review, and create a GitHub Pull Request for completed implementation work according to the GitHub Pull Request workflow.
- `/factory pr resolve-conflicts` — diagnose and resolve Git merge conflicts for the current Pull Request or implementation branch.
- `/factory pr fix-build` — diagnose and resolve failed GitHub Actions builds for the current Pull Request.

## Scope

This skill governs the factory itself, not a specific product.

Factory-level concerns include:

- Factory architecture
- Factory capabilities
- Global skills and workflows
- Repository provisioning
- GitHub integration
- CI/CD provisioning
- Factory security and permissions
- Factory self-improvement
- Factory observability and health

Project-specific requirements belong to the project's own RFCs, ADRs,
Jira tickets, and source code.

## Principles

1. Prefer deterministic workflows over unnecessary agent autonomy.
2. Keep human approval at important decision boundaries.
3. Do not silently make product, legal, compliance, security, or architectural
   decisions.
4. Prefer reusable factory capabilities over project-specific automation.
5. Keep project artifacts separate from factory artifacts.
6. Every factory capability should have a clear purpose, inputs, outputs,
   permissions, and failure behavior.
7. Improve the factory from observed evidence rather than speculation.

## Factory lifecycle

The intended lifecycle is:

Discovery
→ RFC
→ ADR
→ Jira
→ Implementation
→ Verification
→ Delivery
→ Operation
→ Self-improvement

## Factory capability development

When adding a significant factory capability:

1. Define the problem.
2. Determine whether the capability is global or project-specific.
3. Create a factory RFC when the capability is architecturally significant.
4. Create a factory ADR when an architectural decision is required.
5. Define implementation work.
6. Implement and test the capability.
7. Document how it is used.
8. Evaluate the result and improve the factory when justified.

Do not add a new agent, skill, or script merely because it appears convenient.
Prefer the smallest reusable capability that solves the problem.

## Self-improvement

After significant factory runs, evaluate whether the factory itself should
be improved.

Only propose a factory change when there is meaningful evidence such as:

- repeated failure,
- repeated workaround,
- repeated user correction,
- missing workflow control,
- recurring manual work,
- or a reusable capability discovered during implementation.

Follow the common self-improvement standard in:

`../self-improvement/references/standard.md`

Factory self-improvements require explicit human approval before modifying
factory instructions or workflows.

## References

Read `references/architecture.md` when:

- designing or reviewing factory architecture,
- adding a new factory capability,
- deciding whether something belongs to the factory or a project,
- changing the factory lifecycle,
- or evaluating whether an existing skill/script should be replaced,
  extended, or kept separate.

The architecture reference describes the stable structure and boundaries
of the software factory. Do not treat it as a list of implementation tasks
or a backlog.

Read `references/github-provisioning.md` when the user invokes
`/factory provision`.

The GitHub provisioning reference defines the detailed workflow,
approval boundaries, safety rules, and verification steps.

Read `references/github-pr.md` → when the user invokes `/factory pr open`.
Read `/factory pr resolve-conflicts` → read `references/conflict-resolution.md`
Read `/factory pr fix-build` → read `references/pipeline-debug.md`

The GitHub PR reference defines the branch, push, Pull Request, CI,
Jira synchronization, approval, idempotency, and self-improvement rules.

## Factory documents

Factory RFCs and ADRs are stored under:

- `/factory/docs/rfc/`
- `/factory/docs/adr/`

Use the global `rfc` and `adr` skills when creating or reviewing these
documents.

Do not duplicate the RFC or ADR skill inside the factory skill.
