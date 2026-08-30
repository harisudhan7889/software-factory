# Skill Anatomy

This document describes the structure and format of agent-skills skill files. Use this as a guide when contributing new skills or understanding existing ones.

## File Location

Every skill lives in its own directory under `skills/`:

```text
skills/
  skill-name/
    SKILL.md           # Required: The skill definition
    scripts/           # Optional: Runnable helpers used by the skill workflow
    references/        # Optional: Skill-specific reference documentation
    supporting-file.md # Optional: Reference material loaded on demand
```

`SKILL.md` is the only required file. Add `scripts/` or `references/` only when the skill actually needs them, and omit them entirely for simpler skills.

## SKILL.md Format

### Frontmatter (Required)

```yaml
---
name: skill-name-with-hyphens
description: Guides agents through [task/workflow]. Use when [specific trigger conditions].
---
```

**Rules:**
- `name`: Lowercase, hyphen-separated. Must match the directory name.
- `description`: Start with what the skill does in third person, then include one or more clear "Use when" trigger conditions. Include both *what* and *when*. Maximum 1024 characters.

**Why this matters:** Agents discover skills by reading descriptions. The description is injected into the system prompt, so it must tell the agent both what the skill provides and when to activate it. Do not summarize the workflow — if the description contains process steps, the agent may follow the summary instead of reading the full skill.

### Standard Sections (Recommended Pattern)

The frontmatter contract above is required. The section layout below is a recommended pattern, not a rigid template: equivalent headings are acceptable when they serve the same purpose clearly.

```markdown
# Skill Title

## Overview
One-two sentences explaining what this skill does and why it matters.

## When to Use
- Bullet list of triggering conditions (symptoms, task types)
- When NOT to use (exclusions)

## [Core Process / The Workflow / Steps]
The main workflow, broken into numbered steps or phases.
Include code examples where they help.
Use flowcharts (ASCII) where decision points exist.

## [Specific Techniques / Patterns]
Detailed guidance for specific scenarios.
Code examples, templates, configuration.

## Common Rationalizations
| Rationalization | Reality |
|---|---|
| Excuse agents use to skip steps | Why the excuse is wrong |

## Red Flags
- Behavioral patterns indicating the skill is being violated
- Things to watch for during review

## Verification
After completing the skill's process, confirm:
- [ ] Checklist of exit criteria
- [ ] Evidence requirements
```

## Section Purposes

### Overview
The "elevator pitch" for the skill. Should answer: What does this skill do, and why should an agent follow it?

### When to Use
Helps agents and humans decide if this skill applies to the current task. Include both positive triggers ("Use when X") and negative exclusions ("NOT for Y").

### Core Process
The heart of the skill. The step-by-step workflow should be specific and actionable, not vague advice.

**Good:** "Run `npm test` and verify all tests pass"
**Bad:** "Make sure the tests work"

### Common Rationalizations
These are excuses agents use to skip important steps, paired with factual rebuttals. They prevent the agent from skipping required work.

### Red Flags
Observable signs that the skill is being violated. Useful during review and self-monitoring.

### Verification
The exit criteria. A checklist the agent uses to confirm the skill's process is complete. Every checkbox should be verifiable with evidence.

## Supporting Files

Create supporting files only when:
- Reference material exceeds 100 lines (keep the main `SKILL.md` focused)
- Code tools or scripts are needed
- Checklists are long enough to justify separate files

Keep patterns and principles inline when under 50 lines.

If a skill does not need runnable helpers, do not create an empty `scripts/` directory just to mirror other skills. Empty directories add noise without changing how the skill works.

## Shared References

Checklists used by more than one skill — testing, security, performance, accessibility, definition-of-done — live in `references/` at the repository root, deliberately *not* inside any skill directory.

This is a pack-level design choice. The Agent Skills spec describes a skill as a self-contained directory, but several skills here point at the same checklists. Colocating those would force one of two options: copy the checklist into every skill that uses it, or pick one skill to "own" it and have the others reach into that directory. Both drift over time. A single repo-root copy stays the source of truth.

The tradeoff is portability: a whole-repo install (such as the Claude Code marketplace plugin) carries `references/` along, but a per-skill install that copies only `skills/<name>/` leaves the repo-root sibling behind, and those links resolve to nothing. That gap is tracked in [#361](https://github.com/addyosmani/agent-skills/issues/361).

Current convention: material used by exactly one skill is a supporting file inside that skill's directory; material shared across skills goes in the root `references/` directory.

## Context Efficiency

Skills load on demand: only the skill name and description sit in context at startup. The full `SKILL.md` loads only when an agent decides the skill is relevant. To keep that load cheap:

- Keep `SKILL.md` under 500 lines.
- Write specific descriptions.
- Use progressive disclosure.
- Prefer scripts over inline code.
- Keep file references one level deep.

## Script Requirements

When a skill ships runnable helpers under `scripts/`, each script follows these conventions:

- Use a `#!/bin/bash` shebang.
- Use `set -e` for fail-fast behavior.
- Write status messages to stderr: `echo "Message" >&2`.
- Write machine-readable output (JSON) to stdout.
- Include a cleanup trap for temporary files.
- Reference the script path as `skills/<skill-name>/scripts/<script>.sh`.

## Writing Principles

1. Process over knowledge.
2. Specific over general.
3. Evidence over assumption.
4. Anti-rationalization.
5. Progressive disclosure.
6. Token-conscious.

## Naming Conventions

- Skill directories: `lowercase-hyphen-separated`
- Skill files: `SKILL.md`
- Supporting files: `lowercase-hyphen-separated.md`
- Shared references: root `references/` directory.
- Skill-specific references may live inside the skill directory.

## Cross-Skill References

Reference other skills by name:

```markdown
Follow the `test-driven-development` skill for writing tests.
If the build breaks, use the `debugging-and-error-recovery` skill.
```

Do not duplicate content between skills.

## Required vs Recommended

Required:

- `skills/<skill-name>/SKILL.md`
- Valid YAML frontmatter with `name` and `description`
- Description includes what the skill does and when to use it

Recommended:

- Standard section flow
- Equivalent clear headings
- Supporting files only when they keep `SKILL.md` focused
