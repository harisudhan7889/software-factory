---
name: self-improvement
description: Record factory self-improvement findings in git-tracked memory when a real run provides evidence that future behavior should change. See references/standard.md for the full standard. Do not use for cosmetic, hypothetical, or one-off improvements.
---

Follow the common self-improvement standard used by the software factory (see `references/standard.md`).

Only propose factory changes when a real run provides evidence that future
behavior should change.

Do not propose cosmetic, hypothetical, or one-off improvements.

Never record a self-improvement finding only in the coding tool's own
private, per-account memory (for example Claude Code's own memory
system). That memory is invisible to teammates, to a different AI tool
running the same factory, and to anyone reviewing a Pull Request, so it
is not a substitute for factory memory. Every self-improvement finding
goes in the git-tracked location this skill standard defines:
`factory/docs/self-improvement/known-limitations.md` or
`rejected-proposals.md` for factory-wide findings, or the current
project's own `.factory/memory.md` for project-specific ones. Do not
skip this because a private memory write already happened to capture
the same note — the private note does not count as having recorded it.
