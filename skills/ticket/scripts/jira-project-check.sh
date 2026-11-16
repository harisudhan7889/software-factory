#!/bin/bash

# Check whether a Jira project exists and is reachable, and report its
# issue types so callers can verify the `ticket` skill's expected issue
# types (Epic, Story, Bug, Task) are available.
#
# Usage: jira-project-check.sh <KEY>
#
# Exit codes:
#   0  Project found and reachable.
#   1  Error (bad input, auth/network failure, unexpected response).
#   3  Project not found (HTTP 404) — distinct code so callers can branch
#      on "does not exist yet" without treating it as a hard error.

set -euo pipefail
TMP1=""
TMP2=""
trap 'rm -f "${TMP1:-}" "${TMP2:-}"' EXIT

if [ "$#" -ne 1 ]; then
    echo "Usage: jira-project-check.sh <KEY>" >&2
    exit 1
fi

PROJECT_KEY="$1"

# Shared Jira credentials must come from the global environment, never
# from a project-local .env — see ADR-0003.
: "${JIRA_BASE_URL:?JIRA_BASE_URL is not set in the global environment}"
: "${JIRA_EMAIL:?JIRA_EMAIL is not set in the global environment}"
: "${JIRA_API_TOKEN:?JIRA_API_TOKEN is not set in the global environment}"

TMP1=$(mktemp)
HTTP_CODE=$(curl -sS -o "$TMP1" -w "%{http_code}" \
    -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
    -H "Accept: application/json" \
    "$JIRA_BASE_URL/rest/api/3/project/$PROJECT_KEY") || HTTP_CODE="000"
BODY=$(cat "$TMP1" 2>/dev/null || echo "")

if [ "$HTTP_CODE" = "000" ]; then
    echo "Error: could not reach Jira at $JIRA_BASE_URL (network or TLS failure)" >&2
    exit 1
fi

if [ "$HTTP_CODE" = "404" ]; then
    echo "Jira project not found: $PROJECT_KEY"
    exit 3
fi

if [ "$HTTP_CODE" != "200" ]; then
    echo "Error: Jira project lookup for $PROJECT_KEY failed with HTTP $HTTP_CODE" >&2
    echo "$BODY" >&2
    exit 1
fi

echo "Jira project found:"
echo "$BODY" | jq -r '
    "Key: \(.key)",
    "Id: \(.id)",
    "Name: \(.name)",
    "Type: \(.projectTypeKey)",
    "Style: \(.style // "unknown")"
'
echo "URL: $JIRA_BASE_URL/browse/$PROJECT_KEY"

ISSUE_TYPES=$(echo "$BODY" | jq -r '[.issueTypes[]?.name] | join(", ")')
if [ -n "$ISSUE_TYPES" ]; then
    echo "Issue types: $ISSUE_TYPES"
else
    echo "Issue types: (not reported by this endpoint)"
fi

# Best-effort global permission check. Not every Jira site/version returns
# a usable result for a global permission via mypermissions, so a failure
# or missing field here is reported as unknown, never treated as a pass
# or as a hard error (see ADR-0003, "verify ... where practical").
TMP2=$(mktemp)
PERM_HTTP=$(curl -sS -o "$TMP2" -w "%{http_code}" \
    -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
    -H "Accept: application/json" \
    "$JIRA_BASE_URL/rest/api/3/mypermissions?permissions=CREATE_PROJECT" 2>/dev/null) || PERM_HTTP="000"
PERM_BODY=$(cat "$TMP2" 2>/dev/null || echo "")

if [ "$PERM_HTTP" = "200" ]; then
    HAVE=$(echo "$PERM_BODY" | jq -r '.permissions.CREATE_PROJECT.havePermission // "unknown"' 2>/dev/null || echo "unknown")
    echo "Create-project permission for $JIRA_EMAIL: $HAVE"
else
    echo "Create-project permission for $JIRA_EMAIL: unknown (permission check returned HTTP $PERM_HTTP)"
fi
