# Jira Project Provisioning

## Purpose

Provision (create and verify) the current project's Jira project, and
record its key locally, according to RFC-0005 and ADR-0003.

This reference defines the workflow for:

`/factory provision-jira`

Relevant factory documents:

- RFC: `/factory/docs/rfc/0005-jira-project-provisioning/overview.md`
- ADR: `/factory/docs/adr/0003-jira-authentication/overview.md`

The RFC and ADR are the source of truth for this capability. If the ADR is
still `Proposed` when this workflow runs, say so and ask for explicit
acceptance before creating an external Jira project — do not silently
treat a Proposed ADR as approved.

## Scope

The first version supports:

- A single, already-configured Jira Cloud site (`JIRA_BASE_URL`).
- Jira project inspection (does a recorded key resolve to a real project).
- Jira project creation using a deterministic default template.
- Recording the resulting project key in the project's local `.env` and
  in `.factory/project.yml`.
- A best-effort permission and issue-type verification after creation.

The first version does not include:

- Multiple Jira sites.
- Custom workflow, permission-scheme, or issue-type-scheme design.
- Seeding Epics, Stories, or any issue content — that remains the
  `ticket` skill's job (`/ticket create`, `/ticket rfctostories`) once the
  project exists.
- Jira project deletion or archival.
- Jira user/group management.

## Authentication

Use the shared Jira credentials already established for the `ticket`
skill and formalized by ADR-0003: `JIRA_BASE_URL`, `JIRA_EMAIL`,
`JIRA_API_TOKEN`, read from the global shell environment.

Do not:

- Ask the user to paste the API token into chat.
- Write the token to a file.
- Store the token in `.factory/project.yml`.
- Print the token.
- Include the token in logs, Jira comments, or reports.

Project creation additionally requires the `JIRA_EMAIL` identity to hold
the site-level "Create projects" global permission. The factory does not
grant this permission; it is configured by the user's Jira site
administrator outside the factory (ADR-0003).

## Invocation

The user invokes:

`/factory provision-jira`

The workflow operates on the current project.

## Phase 1 — Inspect local project

Before proposing any changes:

1. Determine whether `.factory/project.yml` exists and read any recorded
   Jira metadata (`jira.projectKey`, `jira.projectName`, `jira.baseUrl`).
2. Determine whether the project's local `.env` already defines
   `JIRA_PROJECT_KEY`.
3. Validate the global Jira credentials before inspecting project
   existence, mirroring the GitHub provisioning diagnostics pattern
   (`references/github-provisioning.md`, Phase 2):
   - Check `JIRA_BASE_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN` without
     exposing their values — report only masked length and a bounded
     prefix: never more than 4 characters of the value, plus `***`, and
     never the full value.
   - Detect placeholder or invalid values: `your-token`, `your_token`,
     `changeme`, `your-email@example.com`, empty string, or
     `JIRA_API_TOKEN` length < 10.
   - If no placeholder is detected, confirm the credentials actually
     authenticate with a lightweight call
     (`GET $JIRA_BASE_URL/rest/api/3/myself`) before relying on them for
     project lookup or creation. A `401`/`403` here means invalid
     credentials, not "project not found" — report it as an
     authentication failure and stop.
   - Never print the token, write it to a file, or include it in logs.

Do not modify anything during inspection.

## Phase 2 — Inspect Jira

Using the configured Jira credentials:

1. If a `JIRA_PROJECT_KEY` is already recorded (in `.env` or
   `.factory/project.yml`), run:

   ```bash
   skills/ticket/scripts/jira-project-check.sh "<KEY>"
   ```

   - Exit code `0`: the project exists and is reachable. Report its name,
     type, style, and issue types. There is nothing to create — skip
     Phases 3-5 entirely and go straight to Phase 6 (Verify) to confirm
     issue types, then report the "already provisioned" result using the
     Final result template. Do not create another project and do not
     present a creation-approval prompt.
   - Exit code `3`: the recorded key does not resolve to a real project
     (stale or incorrect). Report the mismatch explicitly and ask the
     user how to proceed (update the record, or provision a new project)
     — do not silently create or silently overwrite the recorded key.
   - Exit code `1`: report the error (likely an authentication or network
     problem) and stop; do not proceed to creation.

2. If no key is recorded, propose a project key and name from the current
   project name (see "Key derivation" below), then run
   `jira-project-check.sh` against the proposed key to detect whether a
   project with that key already exists in Jira even though it was never
   recorded locally.

   - If it exists: report it and ask for explicit approval before
     *adopting* it (recording its key locally) rather than creating a
     duplicate project.
   - If it does not exist (exit code `3`): proceed to Phase 3 to propose
     creating it.

Do not create or modify anything during inspection.

### Key derivation

Derive a candidate key from the project name: uppercase, strip non-letters
and non-digits, take a short prefix, 2-10 characters, starting with a
letter. Always show the derived key to the user as part of the
provisioning plan and let them override it before creation — never create
a project with an unconfirmed key.

## Phase 3 — Build provisioning plan

Before creating or modifying an external Jira resource, present a
provisioning plan.

The plan must include:

- Project name (factory project, not Jira project)
- Current `.factory/project.yml` / `.env` Jira state
- Proposed Jira project name
- Proposed Jira project key
- Proposed project type/template
- Whether `.env` will be created or modified
- Whether `.factory/project.yml` will be created or modified
- Any other externally visible action

Example:

```text
Jira Provisioning Plan

Project: AdVerify
Existing Jira record: none

Proposed Jira project:
  Name: AdVerify
  Key: ADV
  Type: software (team-managed, "Simplified Agility" template)

Planned actions:
1. Create Jira project
2. Verify project is reachable and reports expected issue types
3. Record JIRA_PROJECT_KEY in .env
4. Create/update .factory/project.yml

This will create an external Jira resource.

Approve?
```

No external Jira project should be created before explicit approval.

## Phase 4 — Create the Jira project

Only after explicit approval:

1. Re-run `jira-project-check.sh` for the approved key to catch a
   concurrent change since the plan was shown.
2. If it still does not exist, create it:

   ```bash
   jq -n --arg key "<KEY>" --arg name "<NAME>" \
     '{key: $key, name: $name}' \
     | skills/ticket/scripts/jira-project-create.sh
   ```

   Pass `project_type_key` / `template_key` only when the user explicitly
   asked for a specific template. Otherwise let the script's built-in
   fallback run: it tries `gh-simplified-agility` (team-managed), then
   `gh-kanban-template` (classic/company-managed — confirmed working on
   sites without team-managed project support) and stops at whichever one
   Jira accepts. It stops immediately on 401/403 without trying further
   templates, since a permission failure can't be fixed by changing the
   template.
3. Record which template the script reports as `Template:` in its output
   — that is the template actually used, which may differ from the first
   candidate tried. This is the value to show in the Final result.
4. If creation fails for every candidate template, report the Jira error
   verbatim (never retry destructively) and stop — the local project
   files must not be touched until creation succeeds.

## Phase 5 — Record local metadata

After successful creation:

1. Update the project's local `.env`: add or update the
   `JIRA_PROJECT_KEY=<KEY>` line only. Do not rewrite or reformat any
   other line in the file.
2. Create or update `.factory/project.yml` with:

   ```yaml
   jira:
     baseUrl: <JIRA_BASE_URL>
     projectKey: <KEY>
     projectName: <NAME>
   ```

   Never write credentials into this file.
3. Show the user the resulting diff of both files before/with the report
   (not before approval — approval already covered this in Phase 3).

## Phase 6 — Verify

Run `jira-project-check.sh "<KEY>"` again and confirm:

- The project resolves (exit code `0`).
- Its reported issue types include the types the `ticket` skill expects
  to use: Epic, Story, Bug, Task. Report any gap explicitly rather than
  assuming it — do not treat project creation alone as proof the `ticket`
  skill will work end-to-end.
- The create-project permission line is reported (even if "unknown");
  never upgrade "unknown" to "verified" in the final report. Carry this
  exact line into the Final result below.

## Final result

On successful provisioning, report:

```text
Jira Provisioning Complete

Project:
<key> — <name>

Type:
<projectTypeKey> / <style>

Template used:
<the projectTemplateKey that actually succeeded — on first creation only;
omit this line when reporting an already-provisioned project, since the
template used at creation time isn't returned by the project-check call>

Issue types:
<list, or "gap: missing <types>">

Create-project permission for <JIRA_EMAIL>:
<true / false / unknown>

Base URL:
<JIRA_BASE_URL>

Local record:
.env JIRA_PROJECT_KEY: <created/updated/unchanged>
.factory/project.yml: <created/updated/unchanged>

Result:
Success
```

If provisioning is partially successful, clearly report the partial
state (e.g. "project created, local record not yet written — rerun to
record it" ), per the idempotency rules in RFC-0005 and ADR-0003.

## Decision boundaries

The factory must not silently make decisions that belong to the user,
including:

- The Jira project key and name.
- The project type/template, when the user has expressed a preference.
- Adopting an existing Jira project instead of creating a new one.
- Overwriting a previously recorded `JIRA_PROJECT_KEY`.
- Treating a Proposed ADR-0003 as accepted.

When uncertain, stop and ask.

## Safety boundaries

The factory must never:

- Expose the Jira API token.
- Store the token in `.factory/project.yml`.
- Commit the token.
- Include the token in Jira comments, PR descriptions, or reports.
- Create a Jira project without explicit human approval.
- Delete, archive, or otherwise destructively modify a Jira project —
  out of scope for this capability entirely.
- Modify an unrelated, pre-existing Jira project.

## Verification

After a provisioning run, confirm with evidence:
- [ ] Local state (`.factory/project.yml`, `.env`) was inspected before any Jira call
- [ ] A recorded `JIRA_PROJECT_KEY` was checked against real Jira state, not assumed valid
- [ ] No Jira project was created without an explicit, shown provisioning plan and approval
- [ ] An already-provisioned project went straight to Phase 6 / Final result, with no creation-approval prompt shown
- [ ] `.env` and `.factory/project.yml` were only written after successful creation (or were left untouched on failure)
- [ ] The Jira API token was never printed, logged, or written to a file
- [ ] The final report states the issue-type check result explicitly (pass or named gap), never silently assumed
- [ ] On first creation, the final report names the template that actually succeeded and the create-project permission result for the authenticating identity
- [ ] If ADR-0003 was still Proposed, that was surfaced to the user before creating anything

## Self-improvement

After a provisioning run, review it for factory-level improvements
following the same procedure as GitHub provisioning
(`references/github-provisioning.md`, "Phase 7 — Self-Improvement
Review") and the common standard in
`../../self-improvement/references/standard.md`. The approval gate below
applies. In particular, watch for:

- The default project template still failing on some sites even with the
  current two-candidate fallback (team-managed `gh-simplified-agility`,
  then classic `gh-kanban-template`) — if a third distinct failure mode
  is observed, propose extending `template_keys` with real evidence
  rather than guessing another candidate key (open question #2 in
  RFC-0005).
- The `mypermissions` best-effort check never returning a usable result
  for this Jira site.
- Any workaround needed to authenticate non-interactively, mirroring the
  GitHub "Execution environments" issue recorded in ADR-0001's Amendment
  1.

**Approval gate.** If a factory improvement is identified, present it in the
proposal format from `../../self-improvement/references/standard.md`, then
ask: "Factory improvements were identified. Apply these changes?" Change no
factory file before explicit approval (`GR-APPROVAL-001`). After approval,
follow that standard.
