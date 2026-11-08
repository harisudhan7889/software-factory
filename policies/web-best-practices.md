# Web Best Practices Policy

## Purpose

Define the minimum web quality requirements for frontend work in the software
factory. This policy states what a good web implementation must satisfy. It does
not define product requirements, visual design, or implementation frameworks.

## Scope

Applies to web pages, application screens, frontend components, forms,
navigation, client-side interactions, responsive layouts, public pages, and
authenticated web applications. Apply only the sections relevant to the changed
area. Do not require SEO for authenticated screens unless search indexing is a
product requirement.

## Principles

1. Accessible, semantic, responsive, secure, and fast by default.
2. Provide clear states and feedback.
3. Reuse approved design patterns.
4. Verify supported viewports.
5. Avoid unnecessary client-side complexity.
6. Preserve normal browser behavior where practical.

## Rules

### WEB-SEC-001 — No browser secrets

Severity:
BLOCK

Rule:
No server-only secret (Supabase service-role credentials, API private keys,
database passwords, GitHub or Jira tokens) appears in browser-accessible code.
`security.md` (`SEC-SECRET-001`) owns the secret definition.

Trigger:
A frontend build or commit contains a secret pattern.

Required action:
Block the change and move the secret to the server boundary. Frontend code must
also not trust unvalidated client data, insert untrusted HTML without
sanitization, or disable browser security controls without an approved reason.

Forbidden action:
Embed or log a secret in the client bundle.

Exception:
None.

Evidence:
A secret scan and a bundle search show no secret pattern.

### WEB-CLIENT-001 — No secrets or sensitive data in client storage or URLs

Severity:
BLOCK

Rule:
Do not store API keys, tokens, passwords, or sensitive personal data in
`localStorage`, `sessionStorage`, URLs, query parameters, browser history, or
console logs. Send only the data the operation needs.

Trigger:
Frontend code writes to client storage, a URL, history, or the console.

Exception:
None without an approved reason recorded in the RFC or ADR.

Evidence:
A search of storage and URL writes and a review of changed files show no secret
pattern.

### WEB-A11Y-001 — Accessible and keyboard usable

Severity:
BLOCK for a missing keyboard path or removed focus indicator. WARN for other
accessibility gaps.

Rule:
Target WCAG 2.2 AA unless the project defines another approved standard.
Accessibility must not depend on color alone. All interactive controls work with
a keyboard.

Trigger:
A change adds or alters interactive UI.

Required action:
Provide visible focus states, accessible names, correct form labels, clear error
messages, logical heading structure and reading order, sufficient contrast, and
accessible status messages. Verify Tab and Shift+Tab, Enter on buttons, links,
and menu items, Space on buttons and checkboxes, Escape to dismiss dialogs and
menus, and focus movement after dialogs or dynamic changes. Focus must not
become trapped outside an active modal or lost after a major state change.

Forbidden action:
Hide important information from keyboard users, remove a focus indicator
without an equivalent, or use placeholder text as the only form label.

Exception:
`NOT APPLICABLE` with explicit evidence.

Evidence:
An accessibility scan (for example `axe`) and a keyboard-only walkthrough.

## Quality Requirements

**Semantic HTML.** Use `header`, `nav`, `main`, `section`, `article`, `footer`,
`button`, `a`, `form`, `label`, `fieldset`, and `legend` where they match the
content and behavior. Do not use `div` or `span`, or clickable non-interactive
elements, in place of buttons or links. Use real links for navigation.

**Forms.** Provide a visible label for each field, a clear required or optional
indication, validation feedback associated with the affected field, useful input
types and autocomplete values, submit feedback, and keyboard support. Do not
clear valid input when unrelated validation fails, and do not show errors by
color alone. Avoid silent data loss, and preserve valid input after recoverable
errors. Warn before leaving only when the approved UX requires it.

**States.** Define loading, empty, error, success, disabled, pending, and
partial or degraded states for asynchronous operations. Never show a blank area
when the user needs to know data is loading, missing, or unavailable. Error
messages say what happened and what the user can do next. Do not show raw stack
traces or internal credentials to users.

**Responsive and touch.** Support the viewports in the approved UI design and
product scope. Without exact breakpoints, use content-driven behavior that
preserves task order and usability. Check desktop, mobile, and tablet when the
project supports it. Do not hide required functionality without approval. Keep
touch targets adequately sized and spaced, and do not make a critical
interaction depend only on hover.

**Navigation, links, and browser behavior.** Navigation is consistent,
predictable, keyboard accessible, clearly labeled, and compatible with browser
history. Do not change unrelated navigation. Links have meaningful accessible
names. Preserve back and forward, refresh, copy and paste, text selection, form
behavior, and accessible zoom. Do not prevent browser zoom.

**Images and media.** Use appropriate dimensions and formats. Give informative
images useful `alt` text and decorative images empty `alt` text. Set width and
height to prevent layout shift, and lazy-load non-critical media. Do not use
images of text where real text is needed.

**Performance.** Avoid unnecessary client-side rendering, JavaScript, network
requests, repeated fetching, and layout shifts, and keep interactions
responsive. Do not add an optimization that changes required product behavior
without approval. Use project performance measures when available.

**State and network.** Use the simplest state model that satisfies the feature
and follow the project's frontend architecture. Avoid duplicate sources of
truth, unnecessary global state, derivable state, and complex caches for small
interactions. Network calls handle loading, errors, and timeouts, avoid
duplicate submissions, respect authentication state, and send no unnecessary
data. Do not silently retry sensitive mutations unless they are idempotent.

**SEO.** Apply only to pages meant to be discoverable: a meaningful title, a
meta description, semantic headings, descriptive links, a canonical URL for
duplicate content, structured data where the product requires it, and correct
robots behavior.

**Progressive enhancement.** Preserve a useful baseline when JavaScript or
optional features are unavailable, except for fully client-driven authenticated
applications. Apply it where it adds resilience without needless complexity.

## Visual Design Compliance and Design System

For UI Stories follow the approved UX specification, the approved UI design
specification, the approved external design artifact when available, and the
approved design-system components. Do not replace an approved design with a
simpler one because it is faster. If implementation constraints prevent a
faithful result, identify the conflict, do not silently redesign, and follow the
decision and approval workflow.

When a design system exists, reuse its components, tokens, and interaction
patterns and avoid duplicates. When none exists, use the approved design
specification and introduce only the smallest reusable patterns the feature
needs. `verification.md` owns how UI is verified.

## Testing

Select tests by changed behavior: unit, component, integration, end-to-end,
accessibility, build, lint, typecheck, and performance checks when relevant. For
layout or interaction changes, test the project's supported browser and viewport
combinations, at minimum a desktop browser, a mobile browser, and keyboard-only
interaction. Do not claim broad browser compatibility without testing those
environments, and do not add tests with no connection to the change.
`verification.md` owns completion evidence.

## Decision Boundaries

This policy sets quality expectations and must not silently override approved
product requirements, accepted RFCs or ADRs, or the approved UX or UI design.
When requirements conflict, identify the conflict, use the source-of-truth and
approval rules in `guardrails.md`, and ask when the decision is not defined.

## Exceptions

`WEB-SEC-001` and `WEB-CLIENT-001` allow none beyond what each states.
Responsive, SEO, and accessibility checks may be `NOT APPLICABLE` with explicit
evidence.

## Enforcement

Lint (`eslint-plugin-jsx-a11y`), static checks, an `axe` accessibility scan,
design inspection, and a secret scan for browser secrets.

## Verification

Before reporting applicable web work complete:

- [ ] Semantic HTML, keyboard access, focus behavior, and form labels and validation are correct.
- [ ] Loading, empty, error, and success states are handled when applicable.
- [ ] Responsive behavior is verified, and the approved UX and UI design is followed.
- [ ] No browser-accessible secrets are present and relevant security checks pass.
- [ ] Relevant tests, build, lint, and typecheck pass, and SEO is satisfied when applicable.
- [ ] No unrelated web behavior was changed.

Every checked item has evidence when the workflow requires it.

## Relationship to Other Policies

`security.md` owns security and secrets, `verification.md` owns completion
evidence and UI verification, `guardrails.md` owns agent behavior and source of
truth, `git-safety.md` owns Git, `dependency-safety.md` owns dependencies, and
`observability.md` owns execution records. Do not duplicate their procedures.

## Self-Improvement

Review web implementation runs for repeated accessibility failures, responsive
defects, design deviations, performance regressions, repeated manual checks, and
missing automation. Propose a change only when real evidence shows future web
implementation should behave differently; no cosmetic or hypothetical changes.
