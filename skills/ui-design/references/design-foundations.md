# Design Foundations

Detailed guidance for visual design foundations. Load on demand when designing screens, components, or reviewing visual details.

## Visual states

Design all applicable states identified by the UX specification.

Consider:
- Default
- Loading
- Empty
- Error
- Success
- Disabled
- Validation error
- Permission denied
- Partial/degraded
- Pending
- Selected
- Expanded
- Collapsed
- Hover
- Focus
- Active

Only include states that are meaningful for the component or screen.

Do not design only the happy path.

## Responsive design

Define visual behavior for:
- Desktop
- Tablet
- Mobile

Describe meaningful layout changes.

Examples:
- Two columns become stacked.
- Side navigation becomes a drawer.
- Tables become cards.
- Actions move to a bottom action area.
- Secondary information becomes collapsible.

Responsive behavior must preserve the UX intent.

Do not prescribe framework-specific CSS unless needed for clarity.

## Accessibility

Accessibility must be considered during design.

Consider:
- Visible focus states
- Keyboard navigation
- Semantic grouping
- Form labels
- Error presentation
- Accessible names
- Contrast
- Non-color-only meaning
- Screen-reader interpretation
- Touch target clarity
- Responsive text/content behavior

Do not claim accessibility compliance from design alone.

Accessibility is verified later.

## Design tokens

When the project has a design system, use existing tokens.

When a new visual token is genuinely required:
- Explain why the existing system cannot satisfy the requirement.
- Define the smallest appropriate token.
- Prefer reusable values over one-off styling.

Avoid arbitrary per-screen values when a reusable design token is suitable.

## Interaction presentation

Describe how interactions should appear visually.

Examples:
- Buttons
- Forms
- Validation
- Confirmation dialogs
- Drawers
- Tooltips
- Tabs
- Accordions
- Toasts
- Inline feedback
- Progress indicators

Do not redefine interaction behavior that belongs to the UX specification.
