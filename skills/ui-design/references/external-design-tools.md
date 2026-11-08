# External Design Tools

Procedure for materializing an approved UI specification in the project's
design tool (Figma, Stitch, or another MCP/adapter). The tool-neutral Markdown
specification stays the source of truth; do not make the workflow depend on one
platform.

## Rule

After the specification is approved, materializing it in the project's design
tool is mandatory. The only way to skip it is an explicit user waiver, recorded
in the Design artifact with the reason.

## Procedure

1. Preserve the approved UX and UI specification without changing product behavior.
2. Use the configured design-tool target (tool + project reference). If none is configured, request it (create new vs use existing) instead of skipping.
3. Create or update one screen per approved screen, then review each tool screen against the specification. Fix deviations by editing the tool screen, never by redefining the spec silently.
4. Record the canonical project and screen links in the Design artifact.
5. Report integration failures with evidence. Never substitute another tool silently.

Completion test: every approved screen exists in the tool, matches the
specification (layout, hierarchy, states, responsive intent), and its link is
recorded, or a user waiver with reason is recorded instead.

## Generation timeouts and late arrivals

A client-side generation timeout is not evidence of failure; the tool may keep
working server-side. Timed-out requests have landed minutes later, and every
blind retry produced a duplicate screen.

- On a timeout, do not retry immediately. Poll `list-screens` (or the tool equivalent) with about 90 s backoff, up to about 10 minutes, to confirm absence.
- Re-check the screen list immediately before any retry. Retry only on confirmed absence.
- A late-arriving screen from the original request counts as success; adopt it instead of regenerating.
- Prefer editing the landed screen to regenerating it.
- If duplicates occur (no delete capability, or a very late arrival), record primary vs duplicate in the artifact and reference only the primary from then on.
