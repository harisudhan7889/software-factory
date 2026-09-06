# Ticket Templates

Templates for the Jira ticket description field, organized by issue type. Lines that serve as section headings (e.g., "Acceptance criteria", "Expected behaviour") are rendered **bold** automatically by the creation script.

## Story / Task

```text
[brief description of ticket]

Acceptance criteria
1. [numbered list of acceptance criterion]

Additional context
[any additional information or dependency]
```

When a UI Story builds an approved design-exploration direction, append this optional block to the description:

```text
Design input
Selection: design-explorations/<short-name>.selection.md (Status: Approved, Direction X — <Name>)
Comparison: design-explorations/<short-name>.html (Direction X section)
UX artifact: <approved UX artifact path or NONE>
UI design artifact: <approved UI design artifact path or NONE>
```

For such Stories, include acceptance criteria that the implementation follows the selected direction per its `Preserve:` decisions, leaves approved UX/RFC/ADR behavior unchanged, and handles aspirational elements as specified. Omit the block when no approved selection applies.

## Bug

```text
Expected behaviour
[short sentence describing expected behaviour]

Actual behaviour
[short sentence describing actual behaviour]

Steps to reproduce
1. [numbered list of steps to reproduce]
```

## Epic

```text
[brief description of the epic's purpose and goal]

Scope
- [bulleted list of work areas this epic covers]
```

## Spike

```text
[brief description of ticket]

Scope
- [bulleted list of the scope of the investigation ticket]

Spike outcome(s)
- [bulleted list of the expected outcomes]
```

## Sub-task

```text
[brief description of ticket]

Acceptance criteria
1. [numbered list of acceptance criterion]

Additional context
[any additional information or dependency]
```

