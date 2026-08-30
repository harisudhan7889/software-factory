# RFC-0001 — GitHub Repository Provisioning

**Status:** Accepted

**Date:** 2026-08-21

**Authors:** Hari

## Context

The software factory currently develops projects in a local Git repository.
The developer must manually create a GitHub repository, configure it,
connect the local repository to the remote, and push the initial code.

The factory should eventually be able to provision the GitHub repository
itself as part of project creation and delivery.

The first version will support provisioning repositories under a personal
GitHub account. GitHub organization repositories are a future extension.

Repository creation is an externally visible action and therefore requires
explicit human approval before execution.

GitHub repository provisioning is the first implementation of the software
factory's broader external-service provisioning capability. Future factory
capabilities may provision and configure services such as Jira and Supabase.

## Goals

The factory should be able to:

- Determine whether a project already has a GitHub repository.
- Determine whether the local project is already connected to a GitHub remote.
- Propose repository creation when one does not exist.
- Ask for explicit human approval before creating the repository.
- Create a GitHub repository with the requested name and visibility.
- Configure basic repository settings.
- Connect the local Git repository to the new remote.
- Push the initial branch.
- Verify that the repository is accessible.
- Verify that the project's GitHub Actions workflow is available.
- Report the complete provisioning result.
- Fail safely without corrupting the local repository when provisioning
  is unsuccessful.
- Allow failed provisioning operations to be retried safely.

## Non-goals

The first version will not:

- Deploy the application to production.
- Provision Supabase or other cloud infrastructure.
- Configure production secrets.
- Automatically merge pull requests.
- Automatically deploy releases.
- Manage Kubernetes or other container orchestration.
- Manage organization billing.
- Provision GitHub organization repositories.
- Modify unrelated repositories.
- Automatically commit or discard local changes.
- Make repository creation decisions without human approval.

## Proposed user experience

The factory should eventually support a command such as:

    /factory provision

The factory should inspect the current project and report:

- Project name
- Current Git state
- Whether a GitHub remote already exists
- Whether the remote points to the expected repository
- Proposed GitHub repository name
- Proposed owner/account
- Proposed visibility
- Actions that will be performed

Example:

    Repository does not exist.

    Proposed repository:
      Owner: <account>
      Name: AdVerify
      Visibility: Private

    Actions:
      - Create GitHub repository
      - Configure repository
      - Connect local Git remote
      - Push initial branch
      - Verify GitHub Actions

    This will create an external GitHub resource.

    Approve? [yes/no]

No external repository should be created before explicit approval.

If the repository or remote already exists, the factory should report the
current state instead of attempting to create another repository.

## Architecture

    /factory provision
            |
            v
    Factory provisioning skill
            |
       +----+----+
       |         |
       v         v
    Local Git  GitHub API
       |         |
       +----+----+
            |
            v
    GitHub repository
            |
            v
    GitHub Actions
            |
            v
    Provisioning result

The factory should separate provisioning into explicit stages:

1. Inspect
2. Plan
3. Human approval
4. Create GitHub repository
5. Configure repository
6. Configure local Git remote
7. Push initial branch
8. Verify
9. Report result

A failure in one stage must be reported explicitly.

The factory should preserve the successful state of earlier stages so that
later stages can be retried without unnecessarily repeating successful or
destructive operations.

## Authentication and authorization

The implementation must use a GitHub authentication mechanism that supports
the minimum permissions required for repository provisioning.

GitHub App authentication should be evaluated as the preferred long-term
integration model.

The final authentication mechanism will be established by a separate ADR.

The factory must not require broad GitHub permissions when narrower
permissions are sufficient.

The factory must distinguish between:

- Authentication: proving that the factory has access to GitHub.
- Authorization: determining whether the authenticated identity has the
  permissions required for the requested operation.

The factory should verify the required permissions before attempting
repository creation where practical.

Authentication credentials must not be committed to the repository or
exposed in logs, Jira comments, or implementation reports.

## Repository configuration

The initial implementation should establish explicit defaults for:

- Repository visibility
- Default branch
- Issues
- Pull requests
- GitHub Actions

Repository configuration should be deterministic and documented.

Private repositories should be the default unless the user explicitly
chooses another visibility.

The factory must not change repository settings outside the scope approved
by the user.

## Existing repository and remote behavior

If a GitHub repository already exists:

- Do not create another repository.
- Report the existing repository.
- Do not overwrite the existing remote.
- Do not change repository settings automatically.
- Ask for explicit approval before changing an existing remote or repository
  configuration.

If the local repository already has an `origin` remote:

- Inspect and report the remote.
- Do not replace it automatically.
- Determine whether it points to the expected GitHub repository.
- Ask for explicit approval before changing it.

Provisioning should be idempotent and safe to rerun.

## Local Git behavior

Before provisioning:

- Detect whether the directory is a Git repository.
- Detect existing remotes.
- Detect uncommitted changes.
- Detect the current branch.
- Confirm that the repository is safe to connect to the new remote.

If the local repository contains uncommitted changes, provisioning must not
automatically commit or discard them.

The factory should report the uncommitted state and require explicit approval
before continuing when the operation could affect the local repository.

After successful repository creation:

- Add the GitHub repository as `origin` when appropriate.
- Push the intended initial branch.
- Verify the remote.
- Preserve the local commit history.

The factory must not overwrite an existing remote without explicit approval.

## CI verification

The factory should verify that the project contains its expected GitHub
Actions workflow.

The first version should verify:

- Repository access.
- Expected GitHub Actions workflow presence.
- Basic repository accessibility.

It should not treat successful repository creation alone as successful
software delivery.

Successful provisioning means that the repository has been created or
confirmed, the local repository has been connected appropriately, the
initial branch has been pushed when required, and the expected CI workflow
is present.

## Security

- Authentication credentials must never be committed to the repository.
- Tokens must not be written to logs.
- Use the minimum GitHub permissions necessary.
- Repository creation requires explicit human approval.
- Private repositories should be the default unless explicitly changed.
- The factory must not expose credentials in Jira comments or reports.
- Failed authentication must fail safely.
- The factory must not modify unrelated repositories.
- Destructive repository operations require explicit human approval.
- The factory should avoid storing long-lived credentials when a more
  restricted authentication mechanism is available.

## Failure handling

If repository creation fails:

- Do not modify the local Git remote unless necessary.
- Report the GitHub error.
- Preserve the local repository.
- Do not retry destructive operations indefinitely.
- Allow the user to correct the problem and retry.

If repository creation succeeds but repository configuration fails:

- Report that the repository exists.
- Preserve the repository.
- Do not create another repository automatically.
- Allow configuration to be retried safely.

If repository creation succeeds but the initial push fails:

- Report that the remote repository exists.
- Preserve the local repository.
- Do not create another repository automatically.
- Allow the push/configuration step to be retried safely.

If a later provisioning stage fails, the factory must report which stages
succeeded and which stage failed.

## Idempotency

Provisioning operations should be safe to retry.

The factory must inspect the current state before performing each operation
and avoid repeating successful operations unnecessarily.

For example:

- An existing GitHub repository must not result in another repository.
- An existing correct `origin` must not be replaced.
- A successfully configured repository should not be configured again
  unnecessarily.
- A successfully pushed branch should not be recreated unnecessarily.
- A failed operation should be retryable from the last known successful
  stage.

Idempotency applies to both external GitHub operations and local Git
configuration.

## Future extensions

Later versions may support:

- GitHub organization repositories
- Repository templates
- Branch protection
- CODEOWNERS
- Pull-request creation
- Jira ↔ GitHub linking
- GitHub Actions configuration
- Environment configuration
- Secrets provisioning
- Automated pull-request workflows

These capabilities are outside the first version.

The broader factory provisioning model is expected to support other external
services in the future, including:

- Jira project and workflow provisioning
- Supabase project and configuration provisioning
- Other project infrastructure

Those services will be defined by their own factory capabilities and are
outside the scope of this RFC.

## Open questions

1. GitHub App versus another authentication mechanism for the first
   implementation.
2. Exact default repository settings.
3. Whether repository templates should be supported.
4. Which GitHub Actions verification should be considered successful.
5. Whether the first version should support repository naming conventions
   or simply use the project name.

## Acceptance criteria

The capability will eventually be considered complete when:

1. The factory can detect whether a GitHub remote exists.
2. The factory can detect whether the local project is already connected
   to the expected repository.
3. The factory can present a provisioning plan.
4. The factory requires explicit approval before creating a repository.
5. The factory can create a private GitHub repository under the configured
   personal account.
6. The factory can configure the repository using deterministic defaults.
7. The factory can connect the local repository to the new remote.
8. The factory can push the initial branch.
9. The factory can verify repository access.
10. The factory can verify the expected GitHub Actions workflow is present.
11. Credentials are not exposed in logs or committed files.
12. Provisioning failures leave the local project recoverable.
13. Provisioning operations can be safely retried.
14. The provisioning result clearly reports successful and failed stages.
15. Existing repositories and remotes are not overwritten without explicit
    approval.

## Relationship to the factory provisioning model

GitHub repository provisioning is the first implementation of the software
factory's broader external-service provisioning capability.

The same factory model is expected to support future provisioning of
services such as:

- Jira projects and workflows
- Supabase projects and configuration
- Other project infrastructure

This RFC is limited to GitHub repository provisioning and does not define
the implementation of those future provisioning capabilities.

The factory should treat integration, provisioning, and operation as
separate capabilities:

1. Integration — the factory can use an external service.
2. Provisioning — the factory can create or configure the service.
3. Operation — the factory can maintain or manage the service.

The current factory already has Jira integration capabilities. Jira
provisioning is a future factory capability and is intentionally not part
of this RFC.