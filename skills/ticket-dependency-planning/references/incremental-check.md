# Incremental Dependency Check

When a new Jira ticket is created or an existing ticket changes materially,
re-evaluate its dependency relationships.

Check both directions:

1. Does the new or changed ticket depend on existing tickets?
2. Do existing tickets depend on the new or changed ticket?

When a dependency is identified:

- Update the dependency graph.
- Record the reason, source, evidence, and confidence.
- Recalculate READY and BLOCKED states.
- Identify any newly available parallel work.

Updating Jira dependency links is a separate action.

Only apply Jira dependency links when:

- The dependency is supported by approved source material; or
- The dependency has been explicitly approved.

For an uncertain dependency:

- Mark the relationship as `INFERENCE`, `HYPOTHESIS`, or `UNKNOWN`.
- Do not automatically create the Jira dependency link.
- Request review when required.

The dependency graph is a persistent planning artifact and must be updated
rather than recreated as an isolated result for each ticket.

Persist the graph as the `Dependency Graph` + `READY/BLOCKED/PARALLEL` section in the report output and carry it forward to the next run; deltas (added/removed edges with reason/source/confidence) are the evidence for the verification checkbox. Storage: include the full section in this run's report; when a project dependency record exists (e.g. docs/plan/dependency-graph.md or agreed Jira parent comment), update it and cite path/URL in Output; otherwise state 'No persistent store configured — graph lives only in this report.'

