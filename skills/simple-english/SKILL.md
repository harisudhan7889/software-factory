---
name: simple-english
description: Guides agents through writing clear factory text using ASD-STE100 Simplified Technical English principles. Use when writing or rewriting factory text for users; Pragmatic mode by default and Strict mode when the user asks for ASD-STE100 or STE compliance. Do not use for changing technical content or identifiers.
---

# Simple English

## Purpose

Write clear, direct, easy-to-understand technical English, using ASD-STE100
Simplified Technical English as the main guide. It applies to agent responses,
workflow reports, plans, questions, documentation, Jira descriptions and
comments, Pull Request descriptions, error explanations, incident reports,
runbooks, API guides, release notes, and other user-facing technical text.

Do not change technical content only to make it sound simple.

## When to Use

Use when writing or rewriting factory text, or when checking text for Simple
English or STE compliance (Review mode).

Do not use to change code, identifiers, or technical accuracy (see
Untouchables), or to claim full ASD-STE100 compliance without the official
dictionary.

## Modes

**Pragmatic (default).** Short sentences, simple words, active voice, one idea
per sentence, one consistent term per concept, clear conditions, direct
instructions. Keep required technical terms such as Jira, Supabase, RLS, MCP,
API, RFC, ADR, GitHub Actions, webhook, endpoint, commit, and deploy; never
swap one for an unnatural synonym.

**Strict.** Use when the user asks for ASD-STE100, STE, Simplified Technical
English, or STE compliance. It applies stronger vocabulary discipline. Full
compliance needs the official ASD-STE100 dictionary, so never claim it without
one.

## Workflow

1. Pick the mode (Pragmatic unless the user asked for STE).
2. Classify the text as Procedural or Descriptive.
3. Apply the core rules below.
4. Rewrite, then run the Verification checklist and deliver.

**Procedural** text tells the reader what to do: imperative sentences, at most
20 words each, one instruction per sentence, the condition before the
instruction, clear warnings and cautions. Example: "If the build fails, read
the failed step in the GitHub Actions log."

**Descriptive** text explains what something is or does: simple present, past,
or future tense, at most 25 words per sentence, one topic and at most six
sentences per paragraph, clear links between sentences.

Do not mix the two styles without a clear section boundary. Word limits never
override technical accuracy; split a long sentence into several complete ones.

## Core Writing Rules

- **Sentences.** Short and complete. Keep needed articles (a, an, the). Avoid contractions when the full form is clearer, and do not create fragments just to cut words. Use a list for several separate items, and connectors such as "Then", "Because", "As a result".
- **Voice.** Prefer active ("The agent reads the RFC."). Passive is fine when the actor is unknown or unimportant.
- **Verbs.** Use direct verbs ("Read the log." "Update the ticket." "Create the branch.") instead of noun-heavy phrases ("Perform an analysis of the log."). Use `must`, `can`, `will`; avoid "should" when the text means mandatory.
- **Terminology.** One term per concept. Do not alternate settings, configuration, and config unless they mean different things.
- **Noun chains.** Avoid long ones. Write "The timeout value for the database connection," not "The database connection timeout configuration value."
- **Conditions.** Put the condition first ("If the branch exists, reuse it."). For safety text: "CAUTION: Do not force-push the branch. It can remove remote commits."
- **Words.** Avoid vague or promotional words (leverage, utilize, seamless) and filler (in order to, due to the fact that); prefer `use` to `leverage`. See `references/word-lists.md` for the full avoid list and the technical-term allowlist.
- **Lists and headings.** Use vertical lists when they help, one idea per bullet, never for decoration. Headings say what follows ("Root cause", "Fix", "Verification"); no decorative headings.

## Untouchables

Never alter code blocks, inline code, commands, URLs, file paths, identifiers,
environment variables, API field names, error messages, log output, commit
hashes, Jira keys, quoted source text, legal text marked verbatim, or
user-provided text when the task is not to rewrite it. You may explain these
items outside the untouched content.

## Questions, Decisions, and Reports

When asking for a decision: state the decision, say why it is needed, give a
small number of clear options when useful, and skip needless background.

```text
Decision needed:
Should the branch use `master` as its base?

Recommended:
Yes. This keeps the Story isolated from other work.
```

Workflow results:

```text
Result:
<clear result>

What happened:
<short explanation>

Action:
<next action>
```

Failures:

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

## Rewrite Behavior

Preserve meaning, technical identifiers, required terminology, and quoted or
verbatim text. Remove filler, split long sentences, use active voice and
direct verbs, and keep one term per concept. Do not add a new requirement
while simplifying.

## Review Mode

When asked to check text, report each meaningful violation as Rule, Original
(short excerpt), and Rewrite. Do not invent ASD-STE100 rule numbers; when
numbering is required, use a verified rule source.

## Verification

Before delivering user-facing text, check:

- [ ] Each sentence is clear and as short as practical, in active voice where possible.
- [ ] Terminology is consistent, conditions are explicit, and instructions are direct.
- [ ] Filler is removed and unsupported claims are avoided.
- [ ] Technical identifiers, quoted or verbatim text, and the original meaning are preserved.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "A shorter synonym is fine; skip consistent terminology." | Use one term per concept; inconsistency confuses readers. |
| "Promotional language sounds impressive." | Use direct language and avoid the vague words listed in `references/word-lists.md`. |
| "Passive voice is more formal, so use it always." | Prefer active voice; use passive only when the actor is unknown. |

## Red Flags

- Vague or promotional words are present.
- A noun chain has more than three nouns.
- The same concept uses different terms (settings, config).
- Passive voice is used where the actor is known.

## Shared Use

Other factory skills and agents (for example `product-director`, `rfc`,
`adr`, `ticket`, `implementation`, `factory`, `ui-ux`, `ui-design`) may
reference this skill instead of duplicating writing rules. The standard does
not change their workflow rules.

## Self-Improvement

Follow `../self-improvement/references/standard.md`. Propose a factory change
only when a real run shows future output needs different behavior; no cosmetic
or hypothetical changes.
