# Create Procedure

**Usage:** `/rfc create <context>`

The `<context>` is free-form text describing the feature, design, or proposal. It can include requirements, spec references, architecture, or any technical detail. Attached files and conversation history are also used as context.

## Step 1: Read the RFC README for instructions

Read `references/README.md` to understand:

- The current directory structure and conventions
- The next available RFC number (from the Index table)
- How files should be organized

Then read the templates:

- `references/overview.md` — structure for the shared overview
- `references/platform.md` — structure for each platform file

Also read the RFC reject memory (`/memories/rfc/rejected-1-200.md`, plus any higher-numbered `rejected-*.md` files) if it exists. If the requested RFC substantially overlaps a previously rejected one, do **NOT** silently re-propose it: surface the prior rejection and its rationale to the user via the `vscode_askQuestions` tool and confirm they still want to proceed before scaffolding.

## Step 2: Ask clarifying questions

Using the context provided, determine what is missing and ask the user (if needed):

- **Short title** (kebab-case slug): infer from context if obvious, otherwise ask
- **Platforms** (ios, android, web): infer from context if obvious, otherwise default to all three
- **Authors:** ask if not inferable from the conversation

Do NOT ask if the context already makes these clear.

## Step 3: Create the RFC directory

Assign the next sequential number (zero-padded to 4 digits) and create:

```bash
mkdir docs/rfc/NNNN-short-title
mkdir docs/rfc/UPDATES.md
```

## Step 4: Generate overview.md

Follow the structure in `references/overview.md` exactly and create it under `docs/rfc/NNNN-short-title`. Fill all sections from the user-provided context:

- **Status:** Always `Proposed`
- **Date:** Today's date
- **Authors:** From step 2
- **Context and scope:** Why this RFC exists
- **Goals:** Actionable deliverables
- **Non-goals:** Explicitly out of scope
- **System-context diagram:** Mermaid diagram of component relationships
- **Design principles:** Key architectural principles guiding the design
- **Platform-specific designs:** Table linking to the platform files
- **Cross-platform security checklist:** Security considerations across all platforms
- **Cross-cutting concerns:** Testing, backwards compatibility, logging
- **Implementation phases:** Sequential phases
- **Work breakdown:** Proposed implementation tickets as a table (`# | Task | Epic | Platform | Phase | Depends-on | Files | Type | Ticket`) — the deterministic source of truth for what gets built. One row per self-contained ticket; the Phase column references the delivering phase; name each task's owning Epic (default to this RFC's Epic). Fill `Depends-on` with the comma-separated row numbers (or ticket keys) a row must merge after (`-` if none) and `Files` with the comma-separated repo-relative source paths the row edits — these make `rfc build` wave scheduling deterministic. Leave `Ticket` as `TBD` until created.
- **Alternatives considered:** From context, or leave for team discussion

## Step 5: Generate platform files

For each platform, follow the structure in `references/platform.md` exactly. Use platform-idiomatic patterns:

| Platform | File | Language | Async | Error Pattern | Storage |
|---|---|---|---|---|---|
| iOS | `ios.md` | Swift | `async throws` | Public Error enum with explicit cases | Keychain |
| Android | `android.md` | Kotlin | `suspend` + `Result<T>` | sealed class | EncryptedSharedPreferences |
| Web | `web.md` | TypeScript | `Promise<T>` | Error class + code union | `sessionStorage` |

## Step 6: Update the README index

Append a row to the Index table in `docs/rfc/UPDATES.md`:

```text
| NNNN | [Title](NNNN-short-title/overview.md) | Proposed | YYYY-MM-DD |
```

## Quality Checks

Before completing, verify:

- [ ] `overview.md` has all template sections filled (no placeholder `...` or `<!-- →` comments remaining)
- [ ] The Work breakdown table is populated (one row per ticket, each mapped to an Epic and a phase); no placeholder rows remain
- [ ] Platform files match the template structure (APIs, Error Model, Data storage, Code, Degree of constraint, Alternatives, File structure)
- [ ] Platform file headers link back to `overview.md`
- [ ] README index is updated with the new entry
- [ ] RFC number is sequential and doesn't conflict with existing entries

## Step 7: Offer Jira ticket creation

Offer to create a Jira Epic for tracking implementation via the `vscode_askQuestions` tool: header `Create Epic`, question `Create a Jira Epic to track this RFC's implementation?`, options `Create Epic` / `Skip`. Provide the proposed epic summary (`<RFC title>`) and description (link to the RFC overview + scope bullets) in the message.

If the user selects `Create Epic`:

1. Create the epic via:

```bash
bash ~/.opencode/skills/ticket/scripts/jira-create.sh "Epic" "<RFC title>" "<description with RFC link>" "" "Medium" ""
```

2. Update the RFC's `overview.md` to fill in the Jira Epic field with the created epic key and link.
