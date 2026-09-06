# ADR-0002 — Default Web Backend Architecture

## Status

Accepted

## Date

2026-09-06

## Authors

Hari

## Context

The software factory had no clear backend standard for generated web
applications.

Prior inspection of the factory found:

- `policies/security.md` (`## Supabase Security`) applies only
  `When Supabase is used` and states that project RFCs and ADRs define
  the specific Supabase architecture. It does not require Supabase and
  does not distinguish remote versus local use.
- `policies/web-best-practices.md` (`WEB-SEC-001`) requires server-only
  secrets to stay out of browser code and to be moved to a server
  boundary, without defining what implements that boundary.
- `skills/product-director/SKILL.md` (`## Technical boundary`) and
  `agents/product-director.md` require the PRD to stay
  technology-neutral. Backend, database, and API choices belong in the
  RFC/ADR workflow. Mentions of Supabase Edge Functions and Fastify in
  that skill are negative examples of what must not go in a PRD.
- `skills/implementation/references/planning.md` (`## Architecture`)
  requires following accepted ADRs and not replacing a selected managed
  service with custom infrastructure. Its AdVerify sentence is a
  project-scoped example, not a factory-wide default.
- `skills/supabase/SKILL.md` and
  `skills/supabase-postgres-best-practices/SKILL.md` are conditional:
  they apply when a task already involves Supabase or Postgres. They do
  not select the backend.
- `skills/ui-ux/SKILL.md`, `skills/ui-design/SKILL.md`,
  `agents/ux-agent.md`, and `agents/ui-design-agent.md` explicitly
  exclude backend architecture and API implementation from their scope.
- `factory/docs/rfc/0003-headless-agent-orchestration/overview.md`
  (`A remote/shared backend is a future extension`) concerns factory
  job-state storage, not generated-application backends.
- No factory-level ADR defined a web-application backend. The only
  factory ADR is `0001-github-authentication`.

Without a default, agents must guess or ask on every project whether
to use remote Supabase, local Supabase only, or a custom
Express/Fastify/Node server, and where secrets, RLS, and tenant
isolation live.

## Decision

For web applications produced by the software factory, the default
backend architecture is **remote/managed Supabase per environment**.

1. Each environment (dev, test, staging, prod, or the project's
   defined equivalent) uses its own remote/managed Supabase project.
   No environment shares production data without explicit
   authorization, per `policies/security.md` (`## Environment
   Separation`).
2. Postgres, Auth, Row Level Security, Storage, and server-side logic
   use Supabase platform capabilities. Server-side logic uses Supabase
   Edge Functions where the capability fits, as defined by the
   project's RFC.
3. Remote/managed Supabase is the application's backend.
   Local Supabase services or CLI tooling may be used for development
   and testing when useful, but they are optional and do not replace
   the approved remote Supabase environment.
4. A custom Express/Fastify/Node server or other bespoke backend
   infrastructure is not the default and must not be introduced
   silently.
5. A custom backend is allowed only through an explicit project-level
   ADR exception that records rationale, alternatives, consequences,
   and security and tenant-isolation review, and is accepted before
   implementation. See `## Exception conditions`.

This ADR sets the factory default only. It does not design any single
product's schema, API surface, or Edge Function inventory. Those remain
in the project's RFC and ADRs.

## Alternatives considered

### No factory default (status quo)

**Advantages:**

- Maximum per-project freedom.
- No factory change required.

**Disadvantages:**

- Every project relitigates the backend choice.
- Agents guess or amplify inconsistency across generated apps.
- Secret handling, RLS, and tenant isolation have no predictable home.

**Decision:**

Rejected. This is the ambiguity this ADR resolves.

### Custom Node backend (Express/Fastify/bespoke API server) as default

**Advantages:**

- Full control over request handling and long-running work.
- Familiar pattern for teams coming from Express/Fastify.

**Disadvantages:**

- Reintroduces server operations, scaling, and hardening the factory
  otherwise avoids.
- Expands secret-handling surface (DB credentials, private API keys,
  service-role keys) beyond the managed boundary the security and web
  policies assume.
- Duplicates capabilities already covered by managed Supabase plus
  Edge Functions for the common web-app case.
- Conflicts with the existing managed-service preference in
  `skills/implementation/references/planning.md`.

**Decision:**

Rejected as the default. Available only by project ADR exception.

### Alternative managed backend as default

**Advantages:**

- Could match a specific product constraint if one existed.

**Disadvantages:**

- No factory evidence supports an alternative: the factory's skills,
  security guidance, and managed-service example all assume Supabase
  competence. Selecting another platform would require new skills,
  policies, and verification without a demonstrated need.

**Decision:**

Rejected. A project may propose an alternative managed backend through
a project ADR exception with evidence.

### Per-project free choice with no default but mandatory RFC section

**Advantages:**

- Forces an explicit choice per project without privileging Supabase.

**Disadvantages:**

- Still provides no starting point; every RFC starts blank.
- Does not resolve the recurring question this ADR answers.

**Decision:**

Rejected in favor of a default with an exception path.

## Consequences

### Positive

- Generated web apps start from a predictable backend: remote Supabase
  per environment, Edge Functions for server-side logic.
- Secrets, RLS, and tenant isolation have a defined home consistent
  with `policies/security.md` and
  `policies/web-best-practices.md` (`WEB-SEC-001`).
- Local Supabase CLI usage stays clearly scoped to iteration, not
  shared state.
- Custom servers become visible, reviewed decisions instead of silent
  additions.
- Implementation planning (`Use managed services where the
  architecture specifies them`) gains a concrete default to reference.

### Negative

- Products that genuinely need long-running compute, custom protocols,
  or infrastructure Supabase cannot provide must write an exception
  ADR, adding process overhead.
- Teams unfamiliar with Supabase RLS, Edge Functions, and Postgres
  practices must learn them; the `supabase` and
  `supabase-postgres-best-practices` skills become required reading.
- This ADR does not solve data modeling, API design, or environment
  provisioning details. Those still require project RFCs and ADRs.

## Exception conditions

A project may use a custom backend (Express, Fastify, other Node
server, or other bespoke infrastructure) or a non-Supabase managed
backend only when all of the following hold:

1. A project-level ADR records the exception before implementation.
2. The ADR states why remote Supabase plus Edge Functions cannot
   satisfy the requirement, with concrete limits, not preference.
3. The ADR records alternatives considered (including remote Supabase
   and at least one other option) and why each was rejected.
4. The ADR records consequences: operations, scaling, cost, and
   migration impact.
5. The ADR records a security review: authentication, authorization,
   tenant isolation, secret storage, service-role and private-key
   handling, and trust boundaries, consistent with
   `policies/security.md` and `policies/web-best-practices.md`.
6. The ADR records tenant-isolation tests and authorization tests that
   will verify the change.
7. The project RFC references the exception ADR; implementation and
   verification follow both.
8. The exception applies to that project only. It does not change this
   factory default.

Without an accepted exception ADR, the default in `## Decision`
applies.

## Security considerations

- Never commit or expose secrets (service-role keys, DB credentials,
  API private keys, tokens) per `policies/security.md`
  (`SEC-SECRET-001`) and `policies/guardrails.md` (`GR-SECRET-001`).
  Never place service-role credentials in browser-accessible code per
  `WEB-SEC-001`.
- Enable RLS on every table in an exposed schema and define policies
  matching the actual access model, per the `supabase` skill security
  checklist. Do not bypass RLS for development convenience.
- Keep privileged operations inside the approved trusted boundary
  (Edge Functions or the explicitly approved exception backend), not
  in client code.
- Keep environments separate. Never use production credentials for
  local development or a production database for tests without
  explicit authorization.
- Treat the Supabase MCP server, CLI, and any custom backend as trust
  boundaries per `policies/security.md` (`## Agent and Tool Trust`).
- Verify tenant isolation and authorization for affected changes; never
  claim a control is effective without evidence.

## Relationship to project RFCs/ADRs

- This is a factory-level default. It does not replace any single
  product's RFC or ADRs.
- A new project RFC adopts this default by reference or cites the
  project exception ADR when one exists. The RFC still designs the
  product-specific schema, API surface, functions, storage, and
  environment mapping.
- A project exception ADR overrides this default for that project
  only, once accepted. It must be explicitly approved before
  implementation, per `policies/guardrails.md` (`GR-APPROVAL-001`).
- Existing Accepted factory or project ADRs are unchanged. A conflict
  between this ADR and an existing Accepted ADR must be identified and
  resolved through the owning artifact, not by silent override, per
  `instructions/AGENTS.md` (`## Source of truth`) and
  `policies/guardrails.md` (`GR-AUTHORITY-001`).
- Changing this default requires amending or superseding this ADR with
  explicit human approval. Do not weaken it in a project RFC or skill
  edit to make a workflow pass.

## Risks and follow-up decisions

- Risk: projects treat local Supabase state as shared truth,
  recreating the ambiguity. Mitigation: RFCs must name the remote
  project per environment; verification must confirm it.
- Risk: exception ADRs become rubber stamps for backend preference.
  Mitigation: enforce `## Exception conditions` strictly; reject
  preference-only justifications.
- Follow-up (not decided here): environment provisioning workflow for
  remote Supabase projects (see `factory/docs/rfc/0001` non-goal on
  Supabase provisioning); Edge Function versus exception-backend
  selection criteria per workload; standard RLS and tenant-isolation
  test pack.

## References

- Factory ADR-0001 — GitHub Authentication and Authorization
- `instructions/AGENTS.md` (`## Source of truth`, `## Decision
  boundaries`)
- `policies/guardrails.md` (`GR-AUTHORITY-001`, `GR-APPROVAL-001`,
  `GR-SECRET-001`)
- `policies/security.md` (`## Supabase Security`, `## Environment
  Separation`, `SEC-SECRET-001`, `SEC-AUTH-001`)
- `policies/web-best-practices.md` (`WEB-SEC-001`)
- `policies/policy-anatomy.md` (`## Policy Boundaries`)
- `skills/adr/references/standard.md`
- `skills/implementation/references/planning.md` (`## Architecture`)
- `skills/product-director/SKILL.md` (`## Technical boundary`)
- `skills/supabase/SKILL.md`, `skills/supabase-postgres-best-practices/SKILL.md`
