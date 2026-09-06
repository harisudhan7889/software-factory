#!/bin/bash
#
# deny-dangerous.sh — block high-risk shell commands before execution.
#
# INPUT CONTRACT (factory-defined; OpenCode core defines no shell-stdin
# hook protocol — hooks are TypeScript plugins, see `permission` config):
#   - Raw candidate shell command text on stdin (e.g. the bash tool's
#     `command` argument, fed by the calling plugin wrapper).
#   - Empty, whitespace-only, or unreadable stdin means missing command
#     data and MUST BLOCK (fail closed).
#
# OUTPUT CONTRACT (exit-code convention, same as hooks/pre-commit:
# exit 0 allows, non-zero blocks):
#   - ALLOW: exit 0, no output.
#   - BLOCK: exit 1 and print `deny-dangerous: BLOCK: <reason>` to stderr.
#
# WIRING (verified OpenCode mechanisms, not implemented here):
#   - Plugin wrapper: pass `output.args.command` via stdin in
#     `tool.execute.before`; throw to block when this script exits 1.
#   - Or `permission.bash` deny rules in opencode.json (note: those are
#     wildcards with last-match-wins, not regex like patterns file).
#
# PATTERNS:
#   - Loaded from dangerous-patterns.txt next to this script (override
#     with DANGEROUS_PATTERNS_FILE only for testing/alternate deploys).
#   - One POSIX ERE per line, matched with `grep -E` against the command.
#   - Blank lines and `#` comment lines are ignored.
#
# FAIL CLOSED: missing/unreadable pattern file, invalid pattern, stdin
# read failure, or missing command data all BLOCK (exit 1).
#
# NEVER: executes the supplied command, modifies files, uses the network,
# or installs anything. No allowlists (not yet).
set -euo pipefail

PATTERNS_FILE="${DANGEROUS_PATTERNS_FILE:-$(dirname "$0")/dangerous-patterns.txt}"

block() {
  echo "deny-dangerous: BLOCK: $1" >&2
  exit 1
}

if [[ ! -f "$PATTERNS_FILE" ]]; then
  block "pattern file missing: $PATTERNS_FILE"
fi
if [[ ! -r "$PATTERNS_FILE" ]]; then
  block "pattern file unreadable: $PATTERNS_FILE"
fi

if ! cmd="$(cat)"; then
  block "cannot read hook input from stdin"
fi
if [[ -z "${cmd//[[:space:]]/}" ]]; then
  block "missing command data on stdin"
fi

lineno=0
while IFS= read -r pattern || [[ -n "$pattern" ]]; do
  lineno=$((lineno + 1))
  if [[ "$pattern" =~ ^[[:space:]]*$ ]]; then
    continue
  fi
  if [[ "$pattern" =~ ^[[:space:]]*# ]]; then
    continue
  fi

  rc=0
  printf '' | grep -E -q -e "$pattern" 2>/dev/null || rc=$?
  if [[ "$rc" -eq 2 ]]; then
    block "invalid pattern at $PATTERNS_FILE:$lineno"
  fi

  match_rc=0
  printf '%s' "$cmd" | grep -E -q -e "$pattern" 2>/dev/null || match_rc=$?
  if [[ "$match_rc" -eq 2 ]]; then
    block "pattern engine failure at $PATTERNS_FILE:$lineno"
  fi
  if [[ "$match_rc" -eq 0 ]]; then
    block "command matches dangerous pattern ($PATTERNS_FILE:$lineno)"
  fi
done < "$PATTERNS_FILE"

exit 0
