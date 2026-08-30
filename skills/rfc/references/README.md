# Request for Comments (RFCs)

This directory contains RFC documents for proposed features, SDK augmentations, and cross-platform design specifications in the project.

## What is an RFC?

An RFC is a detailed technical design proposal for a significant feature or change. Unlike ADRs (which capture a single decision), RFCs describe full system designs including APIs, data models, implementation phases, and alternatives considered. RFCs are reviewed by the team before implementation begins.

## How to add a new RFC

1. Create a new directory with the next sequential number within the project directory:

```bash
mkdir docs/rfc/NNNN-short-title
```

2. Create an `overview.md` using the template structure below.
3. Add platform-specific files as needed (`ios.md`, `android.md`, `web.md`).
4. Add an entry to the index table below.

## Template: overview.md

```markdown
# NNNN - Title

**Status:** Proposed
**Date:** YYYY-MM-DD
**Authors:** Name

## Context and scope

<!-- Why is this needed? What problem does it solve? -->

## Goals

<!-- Bullet list of what this RFC achieves -->

## Non-goals

<!-- Explicitly out of scope -->

## System-context diagram

<!-- Mermaid diagram showing components and interactions -->

## Design principle

<!-- Key architectural principle guiding the design -->

## Platform-specific designs

<!-- Table linking to ios.md, android.md, web.md with key differentiators -->

## Cross-platform security checklist

<!-- Table of security requirements per platform -->
```

## Statuses

| Status | Meaning |
|---|---|
| Proposed | Under discussion, not yet accepted |
| Accepted | Approved and ready for implementation |
| Rejected | Reviewed and declined (rationale preserved for history) |

## Directory Structure

```text
docs/rfc/
├── README.md
├── 0001-short-title/
│   ├── overview.md       ← shared context, goals, system diagram, security, phases
│   ├── ios.md            ← Swift API, Keychain, ASWebAuthenticationSession
│   ├── android.md        ← Kotlin API, EncryptedSharedPreferences, Ktor
│   └── web.md            ← TypeScript API, PKCE, sessionStorage, Web Crypto
├── 0002-another-feature/
│   ├── overview.md
│   └── ios.md            ← single-platform features only need relevant files
```

Conventions:

- Directory names use the format `NNNN-short-title/` (zero-padded 4-digit number + kebab-case)
- Numbers are assigned sequentially and never reused, even for rejected RFCs
- `overview.md` is required — contains status, goals, non-goals, system diagram, cross-cutting concerns
- Platform files (`ios.md`, `android.md`, `web.md`) contain platform-specific API, storage, and implementation details
- Single-platform features only include the relevant platform file(s)
- Do not nest further subdirectories within an RFC folder
