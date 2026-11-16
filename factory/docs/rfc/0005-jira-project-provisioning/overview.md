# RFC-0005 — Jira Project Provisioning

**Status:** Accepted

**Date:** 2026-11-16

**Authors:** Hari

## Context

The software factory already integrates with Jira through the `ticket`
skill (`/ticket create`, `/ticket rfctostories`, `/ticket refine`). That
skill creates and manages issues (Epics, Stories, Bugs, etc.) **inside a
Jira project that already exists**. It reads `JIRA_PROJECT_KEY` from the
current project's local `.env` and fails if it is not set, and it assumes
shared credentials (`JIRA_BASE_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN`) are
already present in the global environment.

Today, nothing in the factory creates the Jira project itself. A developer
must manually create the project in Jira, then hand the factory its key
before any ticket operation can run.

This mirrors the situation RFC-0001 solved for GitHub: before RFC-0001, a
developer had to manually create the GitHub repository before the factory
could push code or open pull requests. RFC-0001 explicitly named Jira
project provisioning as a future factory capability outside its own scope
(see RFC-0001, "Relationship to the factory provisioning model"). This RFC
is that future capability.

Jira project creation is an externally visible action and therefore
requires explicit human approval before execution, consistent with how
GitHub repository creation is handled.

## Goals

The factory should be able to:

- Determine whether the current project already has an associated Jira
  project (via `.factory/project.yml` and the project's `.env`).
- Determine whether the referenced Jira project actually exists and is
  reachable using the shared Jira credentials.
- Propose Jira project creation when no project exists.
- Ask for explicit human approval before creating the project.
- Create a Jira project with a requested name, key, and project
  type/template.
- Configure basic, deterministic project defaults (issue types, workflow
  scheme) using whatever the chosen template provides, without inventing
  custom workflow design.
- Write the resulting project key and metadata into
  `.factory/project.yml` and the project's local `.env`
  (`JIRA_PROJECT_KEY`) so the existing `ticket` skill can use it
  immediately.
- Verify that the created (or existing) project is accessible with the
  configured credentials before reporting success.
- Report the complete provisioning result, including any mismatch between
  recorded metadata and actual Jira state.
- Fail safely without corrupting local project files when provisioning is
  unsuccessful.
- Allow failed provisioning operations to be retried safely.

## Non-goals

The first version will not:

- Provision or manage Jira organizations/sites — it operates against a
  single, already-existing Jira site (`JIRA_BASE_URL`).
- Design custom issue-type schemes, workflows, or permission schemes
  beyond a standard project template.
- Seed Epics, Stories, or any issue content. Issue creation remains the
  responsibility of the existing `ticket` skill, once a project exists.
- Manage Jira users, groups, or permission grants beyond what the chosen
  project template creates by default.
- Migrate or import issues from another tracker.
- Delete or archive Jira projects.
- Modify an unrelated, pre-existing Jira project without explicit
  approval.
- Make Jira project-creation decisions without human approval.

## Proposed user experience

The factory should eventually support a command such as:

    /factory provision-jira

The factory should inspect the current project and report:

- Project name
- Current `.factory/project.yml` / `.env` state
- Whether a Jira project key is already recorded
- Whether that key resolves to a real, reachable Jira project
- Proposed Jira project name and key
- Proposed project type/template
- Actions that will be performed

Example:

    No Jira project is recorded for this project.

    Proposed Jira project:
      Name: AdVerify
      Key: ADV
      Type: Team-managed software project

    Actions:
      - Create Jira project
      - Verify project is reachable
      - Record JIRA_PROJECT_KEY in .env
      - Update .factory/project.yml

    This will create an external Jira resource.

    Approve? [yes/no]

No external Jira project should be created before explicit approval.

If a project key is already recorded and resolves to a real project, the
factory should report the current state instead of attempting to create
another project.

## Architecture

    /factory provision-jira
            |
            v
    Factory Jira provisioning skill
            |
       +----+----+
       |         |
       v         v
    Local files  Jira REST API
   (.env, project.yml)
       |         |
       +----+----+
            |
            v
    Jira project
            |
            v
    Provisioning result

The factory should separate provisioning into explicit stages:

1. Inspect local state (`.factory/project.yml`, `.env`)
2. Inspect Jira (does the recorded key exist and resolve?)
3. Plan
4. Human approval
5. Create Jira project
6. Record project key and metadata locally
7. Verify
8. Report result

A failure in one stage must be reported explicitly.

The factory should preserve the successful state of earlier stages so that
later stages can be retried without unnecessarily repeating successful or
destructive operations.

This capability reuses the existing Jira REST API access already
established by the `ticket` skill's scripts
(`skills/ticket/scripts/jira-create.sh`,
`skills/ticket/scripts/jira-update.sh`,
`skills/ticket/scripts/jira-transition.sh`,
`skills/ticket/scripts/jira-comment.sh`). It must not duplicate Jira API
implementation logic; it adds project-level operations (project existence
check, project creation) alongside the existing issue-level operations.

## Authentication and authorization

The `ticket` skill already assumes shared Jira credentials exist as global
environment variables: `JIRA_BASE_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN`
(API token + email Basic Auth, the standard Jira Cloud REST API
mechanism). This convention exists today only as skill documentation; it
has never been formalized as an ADR, unlike GitHub authentication
(ADR-0001).

This RFC recommends that a new ADR (next available number) be written to
formally adopt the existing `JIRA_BASE_URL` / `JIRA_EMAIL` /
`JIRA_API_TOKEN` convention as the factory's Jira authentication
mechanism, extending its scope from issue operations to project-creation
operations, and stating the required Jira permission (site/project
administration, specifically "create projects") needed for provisioning —
a broader permission than the issue-level scopes the `ticket` skill
needs today.

The factory must distinguish between:

- Authentication: proving that the factory has access to the Jira site.
- Authorization: determining whether the authenticated identity has the
  "create project" permission required for this operation.

The factory should verify the required permission before attempting
project creation where practical (for example, a dry-run / permission
check call) rather than discovering the failure only after attempting
creation.

Authentication credentials must not be committed to the repository or
exposed in logs, Jira comments, or implementation reports — consistent
with the existing `jira-create.sh` family of scripts, which already read
credentials only from environment variables.

## Project configuration

The initial implementation should establish explicit defaults for:

- Project type/template (e.g. team-managed software project)
- Project key derivation (from project name, validated against Jira's key
  rules) with user override
- Default issue types used by later ticket operations (Epic, Story, Bug,
  Task)

Project configuration should be deterministic and documented. The factory
must not change project settings outside the scope approved by the user.

## Existing project and metadata behavior

If `.factory/project.yml` or `.env` already records a `JIRA_PROJECT_KEY`:

- Verify it resolves to a real, reachable Jira project before doing
  anything else.
- If it resolves, report the existing project; do not create another one.
- If it does not resolve (stale/incorrect key), report the mismatch and
  ask the user how to proceed (update the record, or create a new
  project) rather than silently creating or silently overwriting the
  recorded key.

If no key is recorded but a Jira project with the expected name already
exists in Jira:

- Report the existing project.
- Ask for explicit approval before adopting it (i.e. recording its key
  locally) rather than creating a duplicate project.

Provisioning should be idempotent and safe to rerun.

## Local file behavior

Before provisioning:

- Detect whether `.factory/project.yml` exists and read any recorded Jira
  metadata.
- Detect whether the project's `.env` already defines `JIRA_PROJECT_KEY`.
- Detect whether shared Jira credentials are present in the global
  environment (without printing their values).

If the project's `.env` contains unrelated, uncommitted-looking content,
provisioning must only ever add/update the `JIRA_PROJECT_KEY` line — it
must not rewrite or reformat the rest of the file.

After successful project creation:

- Write `JIRA_PROJECT_KEY` into the project's `.env`.
- Create or update `.factory/project.yml` with the Jira project key, name,
  and base URL (never credentials).
- Preserve any other existing content in both files.

The factory must not overwrite an existing, resolvable `JIRA_PROJECT_KEY`
without explicit approval.

## Verification

The factory should verify, after creation:

- The created project is retrievable via the Jira REST API using the
  configured credentials.
- The project key matches what was recorded locally.
- The project's default issue types include the types the `ticket` skill
  expects to use (Epic, Story, Bug, Task), reporting a gap explicitly
  rather than assuming it.

It should not treat successful project creation alone as proof that the
`ticket` skill will work end-to-end; it should perform (or clearly direct
the user to perform) one smoke check, such as listing the project's issue
types, before declaring success.

## Security

- Authentication credentials must never be committed to the repository.
- Tokens must not be written to logs.
- Use the minimum Jira permission necessary; do not request broader site
  administration access than "create project" requires.
- Project creation requires explicit human approval.
- The factory must not expose credentials in Jira comments or reports.
- Failed authentication must fail safely.
- The factory must not modify an unrelated, pre-existing Jira project.
- Destructive Jira operations (there are none in this RFC's scope, since
  deletion/archival is a non-goal) remain out of scope; if ever added,
  they would require explicit human approval under a future RFC.

## Failure handling

If project creation fails:

- Do not modify `.factory/project.yml` or `.env` unless the project was
  actually created.
- Report the Jira API error.
- Preserve local files.
- Do not retry destructive operations indefinitely.
- Allow the user to correct the problem (e.g. permission, key collision)
  and retry.

If project creation succeeds but writing local metadata fails:

- Report that the Jira project exists and its key.
- Do not create another project automatically on retry.
- Allow the local-write step to be retried safely using the already
  recorded Jira state.

If a later provisioning stage fails, the factory must report which stages
succeeded and which stage failed.

## Idempotency

Provisioning operations should be safe to retry.

The factory must inspect the current state before performing each
operation and avoid repeating successful operations unnecessarily.

For example:

- An existing, resolvable Jira project must not result in another
  project.
- A correctly recorded `JIRA_PROJECT_KEY` must not be overwritten.
- A successfully created project should not be recreated on retry.
- A failed operation should be retryable from the last known successful
  stage.

Idempotency applies to both the external Jira operation and local file
writes.

## Future extensions

Later versions may support:

- Jira organization-level (multiple-site) provisioning
- Custom workflow and permission scheme provisioning
- Automatic initial Epic seeding from an accepted RFC (the `rfc breakdown`
  and `ticket rfctostories` workflows already cover this once the project
  exists, so this would be an optional convenience layer, not new Jira
  API surface)
- Jira project archival/deletion workflows
- Jira ↔ GitHub project linking

These capabilities are outside the first version.

## Open questions

1. Whether project key derivation should be fully automatic or always
   require user confirmation of the final key.
2. Which project template (team-managed vs. company-managed software
   project) should be the factory default.
3. Whether the "create project" Jira permission check should be a
   separate preflight call or inferred from the creation call's failure
   mode.
4. Whether a single global Jira site (`JIRA_BASE_URL`) is sufficient for
   all projects, or whether multiple Jira sites must eventually be
   supported.
5. Exact ADR number and scope for formalizing Jira authentication
   (recommended as part of this RFC's acceptance).

## Acceptance criteria

The capability will eventually be considered complete when:

1. The factory can detect whether a Jira project key is already recorded
   for the current project.
2. The factory can verify whether a recorded key resolves to a real,
   reachable Jira project.
3. The factory can present a provisioning plan before creating anything.
4. The factory requires explicit approval before creating a Jira project.
5. The factory can create a Jira project with a deterministic default
   template.
6. The factory can record the resulting project key in `.env` and
   `.factory/project.yml` without disturbing unrelated content.
7. The factory can verify the created project is accessible and has the
   issue types the `ticket` skill expects.
8. Credentials are not exposed in logs or committed files.
9. Provisioning failures leave local project files recoverable.
10. Provisioning operations can be safely retried.
11. The provisioning result clearly reports successful and failed stages.
12. An existing Jira project is never duplicated or silently overwritten.

## Relationship to the factory provisioning model

RFC-0001 established the factory's external-service provisioning model
(Integration → Provisioning → Operation) and explicitly named Jira
project provisioning as a future capability outside its own scope. This
RFC is that capability for Jira, following the same model GitHub
provisioning used:

1. Integration — already exists (the `ticket` skill's Jira REST API
   access).
2. Provisioning — this RFC (create and record the Jira project itself).
3. Operation — remains the existing `ticket` skill (issue creation,
   refinement, transitions) once the project exists.

This RFC is limited to Jira project provisioning. It does not change the
`ticket` skill's issue-level behavior, and it does not define Supabase or
other future provisioning capabilities.
