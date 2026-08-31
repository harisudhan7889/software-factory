# Web Best Practices Policy

## Purpose

Define the minimum web quality requirements for frontend work in the software
factory.

This policy applies to web applications and web user interfaces.

It defines what a good web implementation must satisfy.

It does not define product requirements, visual design, or implementation
frameworks.

## Scope

Use this policy for:

- Web pages
- Web application screens
- Frontend components
- Forms
- Navigation
- Client-side interactions
- Responsive layouts
- Public web pages
- Authenticated web applications

Apply only the sections relevant to the changed area.

Do not require SEO for authenticated application screens when search
indexing is not a product requirement.

## Web Quality Principles

Apply these principles:

1. Accessible by default.
2. Semantic by default.
3. Responsive by default.
4. Secure by default.
5. Fast by default.
6. Provide clear states and feedback.
7. Reuse approved design patterns.
8. Verify supported viewport sizes.
9. Avoid unnecessary client-side complexity.
10. Preserve normal browser behavior where practical.

## Semantic HTML

Use semantic HTML elements when they match the content and behavior.

Prefer:

- `header`
- `nav`
- `main`
- `section`
- `article`
- `footer`
- `button`
- `a`
- `form`
- `label`
- `fieldset`
- `legend`

Do not use a generic element such as `div` or `span` when a semantic element
provides the required behavior.

Do not use clickable non-interactive elements to replace buttons or links.

## Accessibility

Target WCAG 2.2 AA unless the project explicitly defines another approved
standard.

Accessibility must not depend on color alone.

Use:

- Visible focus states
- Keyboard access
- Accessible names
- Correct form labels
- Clear error messages
- Logical heading structure
- Logical reading order
- Sufficient contrast
- Appropriate semantic elements
- Accessible status and feedback messages

Do not hide important information from keyboard users.

Do not remove focus indicators without an equivalent visible focus indicator.

Do not use placeholder text as the only form label.

## Keyboard Interaction

All interactive controls must be usable with a keyboard.

Verify:

- Tab navigation
- Shift+Tab navigation
- Enter activation (buttons, links, menu items)
- Space activation (buttons, checkboxes)
- Escape dismisses dialogs/menus where present
- Focus movement after dialogs or dynamic changes

Focus must not become trapped outside an active modal or lost after a major
state change.

## Forms

Forms must provide:

- A visible label for each required field
- Clear required or optional indication
- Validation feedback
- Error association with the affected field
- Useful input types and autocomplete values when appropriate
- Submit state feedback
- Keyboard support

Do not clear valid user input when unrelated validation fails.

Do not rely only on color to show validation errors.

## Loading, Empty, Error, and Success States

User-facing asynchronous operations should define applicable states:

- Loading
- Empty
- Error
- Success
- Disabled
- Pending
- Partial or degraded

Do not show a blank area when the user needs to know that data is loading,
missing, or unavailable.

Error messages should state:

- What happened
- What the user can do next

## Responsive Design

Support the viewports required by the approved UI design and product scope.

When no exact breakpoints are specified:

- Use content-driven responsive behavior.
- Avoid layouts that depend on one screen width.
- Preserve task order and usability across supported widths.

Check at least:

- Desktop
- Tablet (when project supports tablet layout)
- Mobile

Do not solve responsive problems by hiding required functionality without
approval.

## Touch and Pointer Interaction

Interactive targets must remain usable on touch devices.

Consider:

- Adequate target size
- Spacing between controls
- Hover behavior that is not the only way to access information
- Pointer and keyboard equivalents

Do not make a critical interaction depend only on hover.

## Visual Design Compliance

For UI Stories:

- Follow the approved UX specification.
- Follow the approved UI design specification.
- Use the approved external design artifact when available.
- Reuse approved design-system components.

Do not replace an approved design with a simpler implementation only because
the simpler implementation is faster.

If implementation constraints prevent faithful use of an approved design:

- Identify the conflict.
- Do not silently redesign.
- Follow the applicable decision and approval workflow.

## Design System

When an approved design system exists:

- Reuse its components.
- Reuse its tokens.
- Reuse its interaction patterns.
- Avoid duplicate components.

When no design system exists:

- Use the approved UI design specification.
- Introduce only the smallest reusable patterns required by the feature.
- Avoid creating a large design system for a small change.

## Performance

Frontend work should avoid unnecessary performance cost.

Consider:

- Avoiding unnecessary client-side rendering
- Reducing JavaScript sent to the browser
- Lazy loading large or optional resources
- Optimizing images
- Avoiding unnecessary network requests
- Avoiding repeated data fetching
- Preventing avoidable layout shifts
- Keeping interactive elements responsive

Do not add a performance optimization that changes required product behavior
without approval.

For performance-sensitive changes, use project-specific performance measures
when available.

## Images and Media

Use appropriate image dimensions and formats.

Provide:

- Useful `alt` text when the image conveys information.
- Empty `alt` text for purely decorative images when appropriate.
- Width and height information when it helps prevent layout shift.
- Lazy loading for non-critical media when appropriate.

Do not use images of text when real text is required for accessibility or
interaction.

## Navigation

Navigation must be:

- Consistent
- Predictable
- Keyboard accessible
- Clearly labeled
- Compatible with browser history

Do not change unrelated navigation behavior.

For destructive or high-impact navigation actions, preserve the approved UX.

## URLs and Links

Use real links for navigation.

Links should:

- Have a meaningful accessible name.
- Open the expected destination.
- Preserve normal browser behavior unless the product requires otherwise.

Do not use buttons for navigation when a normal link is sufficient.

## Browser Behavior

Do not unnecessarily break standard browser behavior.

Preserve, when appropriate:

- Back and forward navigation
- Refresh behavior
- Copy and paste
- Text selection
- Link behavior
- Form behavior
- Accessible zoom

Do not prevent browser zoom.

## Web Security Basics

Severity: BLOCK — browser secret exposure must stop.

## WEB-SEC-001 — No browser secrets

Rule: No server-only secret (service-role credentials, API private keys, DB passwords, GitHub/Jira tokens) may appear in browser-accessible code.
Trigger: Frontend build or commit contains secret pattern.
Required action: Block; move secret to server boundary (`security.md` Enforcement).
Forbidden action: Embed or log secret in client bundle.
Exception: None.
Evidence: Secret scan + bundle grep shows no secret pattern.

Frontend code must not:

- Expose server-only secrets.
- Embed privileged credentials.
- Trust unvalidated client data.
- Insert untrusted HTML without required sanitization.
- Disable browser security controls without an approved reason.

Do not place:

- Supabase service-role credentials
- API private keys
- Database passwords
- GitHub tokens
- Jira tokens

in browser-accessible code.

Follow the factory security policy for detailed security requirements.

## Client-Side Data

Only send data required for the current operation.

Do not store sensitive information in client storage without an approved
reason.

Rule: Do not store secrets or unnecessary sensitive data in client storage or URLs.
Trigger: Frontend writes to `localStorage`/`sessionStorage`/URL/query param/history/console.
Forbidden action: Store API keys, tokens, passwords, or sensitive PII there.
Exception: None without approved reason recorded in RFC/ADR.
Evidence: Storage/URL grep shows no secret pattern; review of changed files.

Be careful with:

- `localStorage`
- `sessionStorage`
- URLs
- Query parameters
- Browser history
- Console logging

Do not put secrets or unnecessary sensitive data into URLs or browser logs.

## Error Handling

Frontend errors must:

- Be understandable to the user when user action can help.
- Preserve useful context for developers through approved logging.
- Avoid exposing secrets or internal security details.

Do not show raw stack traces or internal credentials to users.

## Forms and Unsaved Work

When a user has entered important data:

- Avoid silent data loss.
- Warn before leaving or replacing content when the approved UX requires it.
- Preserve valid input after recoverable errors.

Do not add disruptive confirmation dialogs where the product does not need
them.

## State Management

Use the simplest state model that satisfies the feature.

Avoid:

- Duplicate sources of truth
- Unnecessary global state
- State that can be derived
- Complex client caches for small interactions

Follow the project's existing frontend architecture where one exists.

## API and Network Behavior

Frontend network calls should:

- Handle loading and error states.
- Handle timeouts or failures where applicable.
- Avoid duplicate submissions.
- Respect authentication state.
- Avoid sending unnecessary data.

Do not silently retry sensitive mutations unless the operation is designed to
be idempotent.

## SEO

Apply SEO requirements only when the page is intended to be discoverable by
search engines.

For public pages, consider:

- Meaningful page title
- Meta description for public indexed pages
- Semantic headings
- Descriptive links
- Canonical URL for duplicate-content pages
- Structured data where product requires it
- Correct robots behavior

Do not add SEO behavior to authenticated application screens without a product
need.

## Browser and Device Testing

For changes that affect layout or interaction:

Verify supported browser and viewport combinations defined by the project.

At minimum, for layout/interaction changes:

- Desktop browser
- Mobile browser
- Keyboard-only interaction

Do not claim broad browser compatibility without testing the relevant
environments.

## UI Verification

For UI work, verify the implementation against:

1. Approved UX specification
2. Approved UI design specification
3. External design artifact when available
4. Existing design-system conventions

Check:

- Layout
- Visual hierarchy
- Components
- States
- Interaction behavior
- Responsive behavior
- Accessibility

Functional tests alone are not sufficient for visual compliance.

## Testing Expectations

Select tests based on changed behavior.

Possible checks include:

- Unit tests
- Component tests
- Integration tests
- End-to-end tests
- Accessibility checks
- Build
- Lint
- Typecheck
- Performance checks when relevant

Do not add tests with no meaningful connection to the change.

Follow the factory verification policy for completion evidence.

## Progressive Enhancement

Preserve a useful baseline experience when JavaScript or optional browser features are unavailable, unless product is fully client-driven authenticated app (exception).

Do not require progressive enhancement when the product depends on a fully
client-driven authenticated application.

Apply the principle where it improves resilience without adding unnecessary
complexity.

## Exceptions

Exception: `WEB-SEC-001` and browser secret rules have `Exception: None`. Responsive/SEO/accessibility checks may be `NOT APPLICABLE` with explicit evidence (see `## Verification`).

## Web Quality Decision Boundary

This policy defines quality expectations.

It must not silently override:

- Approved product requirements
- Accepted RFCs
- Accepted ADRs
- Approved UX
- Approved UI design

When requirements conflict:

- Identify the conflict.
- Use the source-of-truth and approval policies.
- Ask when the decision is not already defined.

## Verification

Before reporting applicable web work as complete:

- [ ] Semantic HTML is appropriate.
- [ ] Keyboard access works for interactive controls.
- [ ] Focus behavior is usable.
- [ ] Forms have accessible labels and validation.
- [ ] Loading, empty, error, and success states are handled when applicable.
- [ ] Responsive behavior is verified.
- [ ] Approved UX/UI design is followed for UI Stories.
- [ ] No browser-accessible secrets are present.
- [ ] Relevant security checks pass.
- [ ] Relevant tests pass.
- [ ] Build, lint, and typecheck pass when required.
- [ ] SEO requirements are satisfied when applicable.
- [ ] No unrelated web behavior was changed.

Every checked item must have evidence when the workflow requires it.

## Enforcement

Lint (`eslint-plugin-jsx-a11y`), static checks, `axe` accessibility scan, design inspection, secret scan for browser secrets.

## Relationship to Other Policies

Use:

- `policies/guardrails.md` for cross-cutting agent controls.
- `policies/security.md` for security requirements.
- `policies/verification.md` for verification evidence and completion rules.
- `policies/git-safety.md` for Git and branch controls.
- Approved UX/UI artifacts for product experience and visual design.

Do not duplicate complete procedures from those policies.

## Self-Improvement

Review web implementation runs for:

- Repeated accessibility failures
- Repeated responsive defects
- Repeated design deviations
- Performance regressions
- Repeated manual web-quality checks
- Missing automated checks

Only propose a factory change when real evidence shows that future web
implementation should behave differently.

Do not propose cosmetic or hypothetical changes.
