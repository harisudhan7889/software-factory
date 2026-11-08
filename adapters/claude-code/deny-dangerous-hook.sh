#!/bin/bash
#
# Claude Code PreToolUse adapter for hooks/deny-dangerous.sh.
#
# Claude Code sends the tool call as JSON on stdin. The factory guard expects
# the raw shell command on stdin. This adapter extracts `tool_input.command`,
# runs the guard, and exits 2 (Claude Code's "block" code) when the guard
# blocks or anything is unclear (fail closed). Exit 0 allows the call.
set -euo pipefail

self="$0"
while [ -L "$self" ]; do
  target="$(readlink "$self")"
  case "$target" in
    /*) self="$target" ;;
    *) self="$(dirname "$self")/$target" ;;
  esac
done
here="$(cd "$(dirname "$self")" && pwd)"
guard="$here/../../hooks/deny-dangerous.sh"

fail() {
  echo "deny-dangerous: $1; blocking (fail closed)" >&2
  exit 2
}

payload="$(cat)" || fail "cannot read hook input"

if command -v jq >/dev/null 2>&1; then
  command_text="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty')" \
    || fail "cannot parse hook input"
elif command -v python3 >/dev/null 2>&1; then
  command_text="$(printf '%s' "$payload" | python3 -c \
    'import json,sys; print((json.load(sys.stdin).get("tool_input") or {}).get("command") or "", end="")')" \
    || fail "cannot parse hook input"
else
  fail "neither jq nor python3 is available to parse hook input"
fi

[ -x "$guard" ] || fail "guard script not found or not executable at $guard"

if ! reason="$(printf '%s' "$command_text" | "$guard" 2>&1)"; then
  echo "${reason:-deny-dangerous: guard blocked the command}" >&2
  exit 2
fi
exit 0
