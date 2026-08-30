# Software Factory Architecture

## Purpose

The software factory is a reusable engineering system that coordinates
software development across projects.

It is separate from any individual product repository.

## Lifecycle

The factory coordinates these stages:

1. Discovery
2. Design
3. Planning
4. Implementation
5. Verification
6. Delivery
7. Operation
8. Self-improvement

The stages are connected but independently evolvable.

## Factory responsibilities

### Discovery

Understand the product opportunity and market context.

### Design

Produce and review RFCs and ADRs.

### Planning

Convert approved product designs into actionable Jira work.

### Implementation

Plan, implement, test, and review software changes.

### Verification

Validate acceptance criteria, tests, linting, typechecking,
architecture alignment, and scope boundaries.

### Delivery

Manage repository, branch, pull-request, CI, and release workflows.

### Operation

Support deployment, monitoring, observability, and operational workflows.

### Self-improvement

Identify recurring workflow problems and propose improvements to the
factory itself.

## Global versus project-specific

Factory capabilities are reusable across projects.

Project-specific requirements belong to the project repository, including:

- Product RFCs
- Product ADRs
- Jira project configuration
- Application source code
- Product-specific infrastructure
- Product-specific compliance requirements

A factory capability may consume project artifacts, but should not encode
project-specific requirements into global instructions.

## Human decision boundary

The factory may automate execution, but important product, architectural,
security, legal, compliance, financial, and externally visible decisions
remain subject to explicit human approval.

## Design principle

Prefer the smallest reusable factory capability that solves a demonstrated
problem.

Do not create an agent, skill, script, or service merely for convenience
when an existing capability is sufficient.

## Future portability

The factory should remain tool-agnostic where practical.

The current implementation uses OpenCode-specific skills and configuration.
This is an implementation detail of the current runtime, not a requirement
of the factory itself.

Future work should separate the tool-neutral factory from tool-specific
adapters so that the same factory capabilities can be used with:

- OpenCode
- Claude Code
- Codex
- Other compatible agentic development tools

Portable skills should use a cross-tool-compatible skill location such as
`.agents/skills` rather than being tightly coupled to a specific agent
runtime.

Tool-specific configuration and agent definitions should remain behind
tool-specific adapters.

The migration should be performed incrementally:

1. Define a tool-neutral factory structure.
2. Separate reusable skills, scripts, references, and factory documents
   from tool-specific configuration.
3. Create an OpenCode adapter.
4. Migrate and verify existing capabilities.
5. Add adapters for other tools as needed.

This work is intentionally deferred until the current factory capabilities
and workflows are mature.
