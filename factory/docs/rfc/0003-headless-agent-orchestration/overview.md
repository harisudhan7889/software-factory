# RFC-0003 — Headless Agent Orchestration

**Status:** Proposed

**Date:** 2026-08-24

**Authors:** Hari

## Context

The software factory currently requires an interactive coding-tool session to
implement Jira work.

The factory should eventually support headless execution so that a Jira
ticket can be given to a software agent without requiring the user to keep
an interactive coding session open.

The first version should prove the smallest useful workflow:

    Jira ticket
        ↓
    Factory worker
        ↓
    Isolated Git worktree
        ↓
    Headless OpenCode agent
        ↓
    Implementation workflow
        ↓
    Tests
        ↓
    Commit
        ↓
    Pull Request

This RFC intentionally focuses on one ticket and one agent.

## Goals

The first version should:

- Accept one Jira issue as a job.
- Create an isolated Git worktree for the job.
- Start one headless OpenCode agent.
- Provide the Jira issue and factory implementation instructions to the
  agent.
- Preserve the agent session/job state.
- Allow the agent to report a clarification question.
- Allow the job to resume after a clarification is answered.
- Run the existing implementation workflow.
- Commit the completed implementation.
- Create a Pull Request using the existing factory PR workflow.
- Return the final job status and Pull Request URL.
- Fail safely without corrupting the main working tree.

## Non-goals

The first version will not include:

- Telegram integration.
- Multiple agents.
- Parallel execution.
- Remote job persistence.
- Supabase-backed factory state.
- Web UI.
- Slack integration.
- Automatic dependency scheduling between tickets.
- Automatic merging.
- Automatic deployment.

These are future extensions.

## Proposed workflow

The first version should support a job concept such as:

    Build ADVERIFY-84

The factory should execute:

1. Validate the Jira issue.
2. Inspect the current repository.
3. Create an isolated worktree.
4. Create or determine the implementation branch.
5. Start a headless OpenCode worker.
6. Provide the Jira issue and relevant factory context.
7. Run the implementation workflow.
8. If a required clarification is needed, pause the job and report the
   question.
9. Resume the same job after the answer is provided.
10. Run tests and review.
11. Create the implementation commit.
12. Use the existing `/factory pr` workflow.
13. Return the Pull Request URL and final job state.

## Job state

Each job should maintain enough state to resume safely.

The minimum job state should include:

- Job ID
- Jira issue key
- Repository
- Worktree path
- Implementation branch
- OpenCode session ID
- Current job status
- Pending question, when applicable
- Commit hash, when available
- Pull Request URL, when available

Possible job states include:

- queued
- preparing
- planning
- waiting_for_approval
- implementing
- waiting_for_question
- testing
- creating_pr
- completed
- failed
- cancelled

## Worktree isolation

Each headless job must use an isolated Git worktree.

The worker must never implement changes directly in the user's primary
working directory when running as a headless job.

A job worktree must be separate from other jobs.

The factory must preserve:

- The user's primary working tree.
- Other job worktrees.
- Other Jira Story branches.

The worker must not force-push, reset, or rewrite unrelated history.

## OpenCode worker

The first implementation should use OpenCode in headless mode.

The factory worker should be able to:

- Start or connect to a headless OpenCode instance.
- Create or reuse a worker session.
- Send the implementation task.
- Observe job progress.
- Detect completion.
- Detect when the worker needs clarification.
- Continue the same session after clarification.
- Stop or cancel the worker safely.

The worker should use the existing factory skills and workflows rather than
creating a second implementation process.

## Clarification questions

When the worker encounters a genuine product, architecture, security,
compliance, or scope decision that it cannot safely determine:

- Do not guess.
- Pause the job.
- Store the question in job state.
- Report the question to the caller.
- Resume the same job after the answer is provided.

The worker must not silently change scope because a question was unanswered.

## Implementation workflow

The headless worker should follow the existing implementation workflow:

- Read the Jira issue.
- Read relevant RFCs and ADRs.
- Inspect the codebase.
- Determine the implementation branch.
- Create or reuse the correct branch.
- Obtain implementation-plan approval when required.
- Move Jira to `In Progress`.
- Implement the approved scope.
- Run tests.
- Review the implementation.
- Commit the implementation.
- Move Jira to `In Review`.
- Use the existing GitHub PR workflow.

The headless capability must reuse the existing factory workflows rather
than duplicating their logic.

## Pull Request

The first version should reuse the existing GitHub Pull Request workflow.

The headless worker should not create a separate PR implementation.

The final job result should include:

- Jira issue
- Commit hash
- Pull Request number
- Pull Request URL
- CI status
- Final job state

## Failure handling

If worktree creation fails:

- Do not modify the primary working tree.
- Mark the job failed.
- Report the failure.

If the OpenCode worker fails:

- Preserve the worktree.
- Preserve the job state.
- Report the failure.
- Allow safe retry.

If implementation fails:

- Preserve the worktree and commits created so far.
- Report the failure.
- Do not create a Pull Request unless the implementation is complete.

If Pull Request creation fails:

- Preserve the implementation branch and commit.
- Report the failure.
- Allow the PR stage to be retried.

## Idempotency

The same job must be safe to resume.

Examples:

- Existing worktree → reuse it when it belongs to the same job.
- Existing branch → reuse it when it belongs to the same job.
- Existing implementation commit → do not duplicate it.
- Existing Pull Request → do not create another.
- Existing OpenCode session → resume when possible.

The factory should inspect current state before repeating a mutating
operation.

## Security

- Do not expose GitHub or Jira credentials.
- Do not store credentials in job state.
- Do not include credentials in worker prompts.
- Do not write credentials to worktrees.
- Use existing factory authentication mechanisms.
- Keep the headless OpenCode server local/private.
- Do not expose the OpenCode control API directly to the public internet.

## Observability

Each job should produce enough information to understand:

- What Jira issue was requested.
- Which worktree was used.
- Which branch was used.
- Which worker/session was used.
- Current job state.
- Any clarification question.
- Commit hash.
- Pull Request URL.
- Final result.

The first version may store this state locally.

A remote/shared backend is a future extension.

## Acceptance criteria

The first version is complete when:

1. A single Jira issue can be submitted as a headless job.
2. The factory creates an isolated worktree.
3. One headless OpenCode worker can execute the existing implementation
   workflow.
4. The worker can pause for a clarification question.
5. The worker can resume after the clarification is answered.
6. The implementation can be committed safely.
7. The existing PR workflow can create the Pull Request.
8. The final job state and Pull Request URL are reported.
9. The user's primary worktree remains isolated and recoverable.
10. A failed job can be retried without creating duplicate branches, commits,
    or Pull Requests.

## Future extensions

Future versions may add:

- Telegram control.
- Multiple concurrent workers.
- Dependency-aware scheduling.
- Remote job persistence.
- Supabase-backed factory state.
- Web UI.
- Slack integration.
- Worker resource limits.
- Automatic cancellation/timeouts.
- Cross-project orchestration.

These capabilities are intentionally deferred until the single-worker flow
is proven.

## Relationship to existing factory capabilities

This RFC extends the existing implementation and GitHub PR workflows.

The headless worker should reuse:

- The existing Jira ticket workflow.
- The existing implementation workflow.
- The existing GitHub provisioning capability.
- The existing GitHub PR workflow.
- The existing self-improvement process.

This RFC defines orchestration around those capabilities; it does not replace
them.
