# GitHub Repository Provisioning

## Purpose

Provision and configure the current project's GitHub repository according
to the factory GitHub provisioning RFC and ADR.

This reference defines the workflow for:

`/factory provision`

Relevant factory documents:

- RFC: `/factory/docs/rfc/0001-github-repository-provisioning/overview.md`
- ADR: `/factory/docs/adr/0001-github-authentication/overview.md`

The RFC and ADR are the source of truth for this capability.

## Scope

The first version supports:

- The user's personal GitHub account
- Repository inspection
- Repository creation
- Basic repository configuration
- Local Git remote configuration
- Initial branch push
- GitHub Actions workflow verification
- Project factory metadata

The first version does not include:

- GitHub organization provisioning
- Production deployment
- Cloud infrastructure provisioning
- Automatic PR creation
- Automatic merging
- Production secrets provisioning

## Authentication

Use the GitHub fine-grained Personal Access Token configured by the user.

The token must already be available through the user's environment.

Do not:

- Ask the user to paste the token into chat.
- Write the token to a file.
- Store the token in `.factory/project.yml`.
- Print the token.
- Include the token in logs, Jira comments, or reports.

Use only the permissions required by the accepted GitHub authentication
ADR.

## Invocation

The user invokes:

`/factory provision`

The workflow operates on the current project/repository.

## Phase 1 — Inspect local project

Before proposing any changes:

1. Determine whether the current directory is a Git repository.
2. Determine the current branch.
3. Inspect configured Git remotes.
4. Detect uncommitted changes.
5. Inspect local/remote history when relevant.
6. Detect whether `.factory/project.yml` exists.
7. Read `.factory/project.yml` when present.
8. Determine whether a GitHub repository is already associated with the
  project.

Do not modify anything during inspection.

## Phase 2 — Inspect GitHub

Using the configured GitHub authentication:

1. Validate GitHub authentication before inspecting repository existence:
   - Check `GITHUB_TOKEN` / `GH_TOKEN` without exposing the token — report
     only masked length and a bounded prefix: at most the fixed, well-known
     token scheme (`github_pat***`, `ghp***`, `gho***`) plus `***`, never
     more than 10 characters of the value, and never the full value. If the
     value matches a known placeholder (`your-token`, `your_token`,
     `changeme`), report the placeholder name instead of its prefix. Never
     print the token, write it to a file, or include it in logs.
   - Detect placeholder or invalid values: `your-token`, `your_token`,
     `changeme`, empty string, length < 20, or `gh auth status` reporting
     `401 Bad credentials` / `Bad credentials` from the GitHub API.
   - If a placeholder or 401 is detected, report that the current shell
     environment shadows the valid fine-grained PAT configured in `~/.zshrc`
     (per ADR-0001) and that unauthenticated requests to private repositories
     correctly return `404 Not Found`. Do not treat the `404` as proof that
     the repository does not exist until authentication is fixed.
   - Remediation (read-only, no credential changes): ensure no placeholder
     override remains in the launch environment (`launchctl`, IDE / opencode
     launch config, shell profile), run `source ~/.zshrc` or re-login,
     validate with `zsh -c 'source ~/.zshrc; gh auth status'` and
     `zsh -c 'source ~/.zshrc; gh repo view <owner>/<repo> --json name,visibility'`,
     then restart the factory shell before retrying.
2. Determine whether the expected repository exists.
3. If `.factory/project.yml` contains GitHub metadata, compare it with the
   actual GitHub state.
4. Compare the Git remote with the expected GitHub repository.
5. Detect mismatches.

Do not make changes during inspection.

## Phase 3 — Handle existing repository

If the expected GitHub repository already exists:

- Report the repository owner and name.
- Report its visibility.
- Report the current local remote.
- Report whether the local remote matches the repository.
- Do not create another repository.

If connecting or changing the existing repository is required:

- Explain exactly what would change.
- Ask for explicit approval before changing the remote or repository
configuration.



## Phase 4 — Handle Git mismatches

If the local and GitHub state do not match:

### Safe resolution

The factory may automatically perform safe, non-destructive actions such
as:

- Re-reading remote metadata.
- Re-validating repository identity.
- Refreshing factory metadata.
- Re-running read-only checks.



### Potentially destructive resolution

Ask the user before:

- Replacing an existing remote.
- Force-pushing.
- Changing repository visibility.
- Removing history.
- Overwriting existing repository state.
- Making other potentially destructive changes.

Do not silently resolve destructive mismatches.

## Phase 5 — Handle uncommitted changes

If uncommitted changes exist:

1. Show the user the current Git state.
2. Explain that provisioning may require a clean or controlled Git state.
3. Ask the user whether to:
  - stash the changes
  - commit the changes
  - discard the changes
  - stop provisioning

Never automatically discard changes.

Never automatically create a commit containing user changes without
explicit approval.

If the user chooses commit, use the existing Git workflow and clearly
report the commit created.

## Phase 6 — Build provisioning plan

Before creating or modifying an external GitHub resource, present a
provisioning plan.

The plan must include:

- Project name
- Git repository state
- Current branch
- Existing remote, if any
- GitHub owner/account
- Proposed repository name
- Proposed repository visibility
- Repository configuration changes
- Local Git changes
- Whether code will be pushed
- Whether `.factory/project.yml` will be created or modified
- Any other externally visible or potentially destructive actions

Example:

```text
GitHub Provisioning Plan

Project: AdVerify
Local branch: main
Existing remote: none

GitHub owner: <account>
Repository: AdVerify
Visibility: <public/private>

Planned actions:
1. Create GitHub repository
2. Configure repository
3. Add origin
4. Push local main branch
5. Verify GitHub Actions
6. Create/update .factory/project.yml

External repository creation requires approval.

Proceed?
```

## GitHub Actions verification

GitHub Actions verification must report two separate facts:

1. Workflow presence: the expected workflow file exists locally and on the
   remote repository, and the remote workflow state is `active`.
2. Latest run outcome: the conclusion of the latest completed workflow run
   for the pushed branch, for example:

   ```bash
   gh api "repos/<owner>/<repo>/actions/runs?branch=<branch>&per_page=1"
   ```

Report both facts explicitly. Never summarize them as a single
"GitHub Actions: verified" result.

A failed latest run must never be reported as verified. Report it as a
project-level CI failure; it does not invalidate successful repository
provisioning.

## Phase 7 - Self-Improvement Review

Before completing the provisioning workflow, review the execution for
factory-level improvements.

Look specifically for:

- API or permission failures
- Workarounds that were required
- User corrections or rejected actions
- Missing permissions or configuration
- Repeated manual steps
- Incorrect assumptions in the RFC, ADR, skill, or reference
- Safety or reporting issues
- Reusable improvements discovered during the run

### Classify observations

For each significant observation, classify it as:

1. Informational observation
2. Known limitation
3. Project-specific issue
4. Factory improvement

Do not treat every error or observation as a factory improvement.

### No factory improvement

If no factory-level improvement is identified, report:

```text
Self-improvement: No factory change identified.
```

Then complete the workflow normally.

### Factory improvement identified

For every factory improvement, create a concrete improvement proposal.

The proposal must contain:

- Finding
- Root cause
- Evidence
- Affected artifact
- Current behavior
- Proposed update
- Expected benefit

Possible affected artifacts include:

- Factory RFC
- Factory ADR
- Factory skill
- Factory reference
- Factory script
- Factory documentation

### Improvement proposal

Present each improvement using this format:

```text
Factory Improvement Proposal

Finding:
<what happened>

Root cause:
<why it happened>

Evidence:
<evidence from the current run>

Affected artifact:
<file>

Current behavior:
<what the artifact currently says or does>

Proposed update:
<exact change to make>

Expected benefit:
<how future runs improve>
```

The placeholders above are a template for the factory. They must be
replaced with the actual finding and proposed change during a real
provisioning run.

### AI responsibility for improvement proposals

The factory is responsible for formulating a complete and technically
appropriate proposed update.

The user should only need to approve or reject the proposal. Do not require
the user to rewrite the proposal or specify how the affected artifact should
be changed unless the factory cannot safely determine the correct update.

If the correct update cannot be determined confidently, identify the
uncertainty explicitly and ask the user for the missing decision instead of
guessing.

### Approval

After presenting all proposed improvements, ask:

```text
Factory improvements were identified.

Apply these changes?
```

Do not modify any factory artifact before explicit user approval.

### Apply approved improvements

If the user approves:

1. Apply only the approved changes.
2. Update the exact approved artifact path(s).
3. Do not modify any other files.
3. If an accepted ADR or RFC requires modification, preserve its history
   and explicitly record the amendment/change rather than silently
   replacing the original decision.
4. Show the resulting diff for every updated artifact.
5. Validate the updated artifact(s).
6. Record which improvements were applied.
7. Do not automatically rerun the provisioning workflow.

### Accepted ADR changes

If the improvement changes an Accepted ADR:

1. Do not silently replace the accepted decision.
2. Propose an amendment or updated decision.
3. Ask for explicit approval of the architectural change.
4. Update the ADR only after approval.
5. Preserve the previous decision/history.
6. Record the reason for the change and the evidence that caused it.
7. Show the resulting ADR diff.

### RFC changes

If an approved improvement changes an RFC:

1. Do not silently rewrite the RFC.
2. Identify the relevant RFC section.
3. Propose the change.
4. Ask for explicit approval.
5. Update the RFC only after approval.
6. Show the resulting diff.

### Skill, reference, or script changes

If an approved improvement affects a factory skill, reference, or script:

1. Apply only the approved change.
2. Show the diff.
3. Validate the updated artifact where possible.
4. Record the change.
5. Do not automatically rerun provisioning.

### Affected artifact path

The improvement proposal must identify the exact file path to update.

Use the repository-relative path when the artifact belongs to the current
project or factory repository.

Examples:

- `docs/adr/0001-github-authentication/overview.md`
- `references/github-provisioning.md`
- `SKILL.md`
- `scripts/github-create.sh`

If the artifact is outside the current repository, identify its exact
configured path and do not guess.

If the correct artifact cannot be determined, do not modify anything.
Ask the user to clarify the target.

### Affected artifact path

- RFC: `/factory/docs/rfc/0001-github-repository-provisioning/overview.md`
- ADR: `/factory/docs/adr/0001-github-authentication/overview.md`

### Self-improvement completion

After approved updates are applied, report:

```text
Self-improvement

Findings:
<list>

Approved updates:
<list>

Updated artifacts:
<list>

Validation:
<results>
```

If the user declines the proposed improvements:

- Do not modify the factory.
- Report the findings as observations.
- Continue or finish the current provisioning workflow normally.

## Final result

On successful provisioning, report:

```text
GitHub Provisioning Complete

Repository:
<owner>/<repository>

Visibility:
<public/private>

Remote:
<remote>

Branch:
<branch>

GitHub Actions workflow:
<present/absent>

Latest CI run conclusion:
<success/failure/in_progress/none>

Factory metadata:
<created/updated/unchanged>

Commit:
<hash or none>

Self-improvement:
<none identified / improvements proposed / improvements applied>

Result:
Success
```

If provisioning is partially successful, clearly report the partial state.

## Decision boundaries

The factory must not silently make decisions that belong to the user,
including:

- Repository visibility
- Changing an existing remote
- Destructive Git operations
- Force pushes
- Replacing repository state
- Creating metadata commits
- Changing accepted architectural decisions
- Modifying factory instructions

When uncertain, stop and ask.

## Safety boundaries

The factory must never:

- Expose GitHub credentials.
- Store credentials in `.factory/project.yml`.
- Commit credentials.
- Include credentials in Jira comments.
- Modify unrelated repositories.
- Force-push without approval.
- Delete or overwrite repository history without approval.
- Silently change an Accepted ADR.
- Silently rewrite the factory's own instructions.

