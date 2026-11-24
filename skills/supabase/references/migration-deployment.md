# Deploying a Migration to the Project's Remote Environment

Committing a migration file and verifying it against a local/throwaway
Supabase stack is not the same as the project's real backend having that
schema. For a factory project, remote/managed Supabase per environment
is the actual backend (ADR-0002), not local tooling — a migration that
stops at local verification leaves that remote environment silently out
of sync, with nothing in CI to catch it (no factory-generated CI
workflow runs `supabase db push`).

## Steps

Once a migration is ready to ship (not just iterate on locally):

1. **Identify the target remote project** → `supabase projects list`
   shows every project linked on this machine; the project's `.env` /
   `.factory/project.yml` / RFC usually name which one is this project's
   environment (e.g. `<name>-dev`). If more than one plausibly matches
   or none clearly does, stop and ask rather than guessing.
2. **Push it** → `supabase db push` (requires the project to already be
   linked via `supabase link`). Review the list of pending migrations
   it prints before confirming.
3. **Confirm sync** → `supabase migration list` (no `--local` flag;
   compares local migration files against that remote project) should
   show every local migration also present under REMOTE.
4. If the target is a shared, staging, or production environment rather
   than an isolated per-developer/dev project, treat the push itself as
   a security-sensitive change per `policies/security.md`'s Environment
   Separation rules and get explicit approval first.

## Relationship to Jira Story completion

A Jira Story that adds or changes a migration isn't complete until this
step has run — see the `implementation` skill's workflow (Phase 7
"Database migrations" / Phase 11 verification) for when this gate
applies.
