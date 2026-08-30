---
name: simple-english
version: 1.0.0
description: Write clear factory text using ASD-STE100 Simplified Technical English principles, with Pragmatic mode as the default and Strict mode when the user asks for ASD-STE100 or STE compliance.
---

# Simple English

## Purpose

Use this skill when writing or rewriting factory text for users.

The goal is clear, direct, and easy-to-understand technical English.

Use ASD-STE100 Simplified Technical English as the main writing guide.

This skill improves:

- Agent responses
- Workflow reports
- Plans
- Questions
- Documentation
- Jira descriptions and comments
- Pull Request descriptions
- Error explanations
- Incident reports
- Runbooks
- API guides
- Release notes
- Other user-facing technical text

Do not change technical content only to make it sound simple.

## Modes

Use one of these modes:

### Pragmatic

Use Pragmatic mode by default.

Apply the main structural rules:

- Use short sentences.
- Use simple words.
- Use active voice.
- Use one clear idea per sentence.
- Use one consistent term for the same concept.
- Use clear conditions.
- Use direct instructions.
- Keep required technical terms.

Pragmatic mode allows necessary project and domain terms such as:

- Jira
- Supabase
- RLS
- MCP
- API
- RFC
- ADR
- GitHub Actions
- webhook
- endpoint
- commit
- deploy

Do not replace a required technical term with an unnatural synonym.

### Strict

Use Strict mode when the user asks for:

- ASD-STE100
- STE
- Simplified Technical English
- STE compliance

Strict mode applies stronger vocabulary discipline.

Full ASD-STE100 compliance requires the official ASD-STE100 dictionary. Do
not claim full compliance without the official dictionary.

## Classify the text

Before writing, classify the text as:

### Procedural

The text tells the reader what to do.

Use:

- Imperative sentences.
- Maximum 20 words per sentence.
- One instruction per sentence.
- A required condition before the instruction.
- Clear warnings and cautions.

Example:

```text
If the build fails, read the failed step in the GitHub Actions log.
```

### Descriptive

The text explains what something is or does.

Use:

- Simple present, past, or future tense.
- Maximum 25 words per sentence.
- One topic per paragraph.
- Maximum six sentences per paragraph.
- Clear links between related sentences.

Do not mix procedural and descriptive styles without a clear section
boundary.

## Core writing rules

### Sentences

- Write short and complete sentences.
- Keep articles such as "a", "an", and "the" when needed.
- Do not use contractions when a full form is clearer.
- Do not create sentence fragments only to reduce word count.
- Use a list when the content contains several separate items.
- Use clear connectors such as "Then", "Because", and "As a result".

### Voice

Prefer active voice.

Use:

```text
The agent reads the RFC.
```

Instead of:

```text
The RFC is read by the agent.
```

Passive voice is allowed when the actor is unknown or not important.

### Verbs

Use direct verbs.

Prefer:

```text
Read the log.
Update the ticket.
Create the branch.
```

Avoid noun-heavy phrases:

```text
Perform an analysis of the log.
Carry out an update of the ticket.
Creation of the branch must be done.
```

Use these modal verbs where appropriate:

- must
- can
- will

Avoid vague requirements such as "should" when the text means a mandatory
requirement.

### Consistent terminology

Use one term for one concept.

For example, do not alternate between:

```text
settings
configuration
config
```

unless they mean different things.

Choose the correct project term and keep it consistent.

### Long noun chains

Avoid long sequences of nouns.

Prefer:

```text
The timeout value for the database connection
```

Instead of:

```text
The database connection timeout configuration value
```

### Conditions

Put important conditions before instructions.

Prefer:

```text
If the branch exists, reuse it.
```

Instead of:

```text
Reuse the branch if it exists.
```

For safety instructions, use:

```text
CAUTION: Do not force-push the branch. It can remove remote commits.
```

## Words to avoid

Do not use vague, promotional, or decorative language when it adds no useful
information.

Avoid terms such as:

- leverage
- utilize
- seamless
- robust
- powerful
- comprehensive
- cutting-edge
- state-of-the-art
- streamline
- facilitate
- delve
- dive into
- in order to
- prior to
- due to the fact that
- it is worth noting that
- crucially
- simply
- just
- easily
- effortlessly
- and/or

Prefer clear alternatives.

Examples:

```text
leverage → use
utilize → use
in order to → to
prior to → before
due to the fact that → because
facilitate → help
```

When a phrase adds no information, delete it.

## Technical vocabulary

Keep required technical vocabulary.

Do not rewrite:

- Code terms
- API names
- CLI commands
- File paths
- URLs
- Jira keys
- Git branches
- Commit hashes
- Environment variable names
- Error codes
- Database table names
- Function names
- Type names
- Product names
- Tool names

Example:

```text
Run `npm run typecheck`.
```

Do not change the command to a plain-English substitute.

## Untouchables

Do not alter:

- Code blocks
- Inline code
- Commands
- URLs
- File paths
- Identifiers
- Environment variables
- API field names
- Error messages
- Log output
- Commit hashes
- Jira keys
- Quoted source text
- Legal text marked as verbatim
- User-provided text when the task is not to rewrite it

You may explain these items outside the untouched content.

## Numbers and word count

For procedural text:

- Prefer a maximum of 20 words per sentence.

For descriptive text:

- Prefer a maximum of 25 words per sentence.

Do not damage technical accuracy just to meet a word limit.

Split a long sentence into several complete sentences.

## Lists

Use vertical lists when they improve clarity.

Use one idea per bullet where practical.

Do not create lists only to make text look structured.

## Headings

Use headings that tell the reader what follows.

Prefer:

```text
## Root cause
## Fix
## Verification
```

Avoid decorative headings.

## Questions and decisions

When asking a user for a decision:

- State the decision clearly.
- State why the decision is needed.
- Give a small number of clear options when useful.
- Avoid unnecessary background text.

Example:

```text
Decision needed:

Should the branch use `master` as its base?

Recommended:
Yes. This keeps the Story isolated from other work.
```

## Factory output

When reporting a workflow result:

Prefer this structure:

```text
Result:
<clear result>

What happened:
<short explanation>

Action:
<next action>
```

For failures:

```text
Failure:
<exact failure>

Cause:
<known cause or "Not established">

Evidence:
<direct evidence>

Next step:
<clear next step>
```

Do not hide uncertainty.

## Rewrite behavior

When rewriting text:

1. Preserve the meaning.
2. Preserve technical identifiers.
3. Preserve required terminology.
4. Remove filler.
5. Split long sentences.
6. Use active voice.
7. Use direct verbs.
8. Keep one term for one concept.
9. Preserve quoted and verbatim text.

Do not introduce a new requirement while simplifying text.

## Review mode

When the user asks to check text for Simple English or STE:

For each meaningful violation, report:

```text
Rule:
<rule or principle>

Original:
<short excerpt>

Rewrite:
<clear rewrite>
```

Do not invent ASD-STE100 rule numbers.

When strict rule numbering is required, use a verified rule source.

## Self-check

Before delivering user-facing text, check:

- Is each sentence clear?
- Is each sentence as short as practical?
- Is the voice active where possible?
- Is the terminology consistent?
- Are conditions explicit?
- Are instructions direct?
- Did I remove filler?
- Did I preserve technical identifiers?
- Did I preserve quoted or verbatim text?
- Did I avoid unsupported claims?
- Did I preserve the original meaning?

## Integration with factory skills

This skill is a shared writing capability.

Other factory skills and agents may reference it instead of duplicating its
writing rules.

Examples:

```text
market-director
product-director
rfc
adr
ticket
implementation
factory
ui-ux
ui-design
pipeline-debug
```

The writing standard does not change the workflow rules of those skills.

## Self-Improvement

Follow the common factory self-improvement standard.

Only propose a factory change when a real run shows that future output needs
different behavior.

Do not propose cosmetic or hypothetical changes.

