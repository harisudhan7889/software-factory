# [Platform] Platform Design — [Short Title]

> Part of [RFC NNNN — Short Title](../overview.md)

**Language:** Swift | Kotlin | TypeScript  
**Dependencies:** list key dependencies
**Backend platform:** factory default per ADR-0002 (remote/managed Supabase per environment), or the project exception ADR reference when the default does not apply. Name the concrete platform — never leave this as a bare "server-side".

## APIs

### Public Types

```text
// Configuration, result types, client interface
```

### Error Model

```text
// Platform-idiomatic error type
```

## Data storage

| Data | Storage | Access Control |
|---|---|---|
| ... | ... | ... |

Every row must name the platform service that implements it (e.g. Supabase Postgres table, Supabase Storage bucket, Edge Function + table) — not just "server-side". Include expiry/retention mechanics and the secret boundary (which keys live server-side only per WEB-SEC-001) wherever they apply. When the factory default (ADR-0002) applies, say so once in **Backend platform** and keep each row specific.

## Code and pseudo-code

<!-- Add platform-specific implementation code or pseudo-code here. -->

## Degree of constraint

| Aspect | Constraint Level | Rationale |
|---|---|---|
| ... | High/Medium/Low | ... |

## Alternatives considered

| Alternative | Reason Rejected |
|---|---|
| ... | ... |

## File structure

```text
path/to/new/files/
├── ...
```
