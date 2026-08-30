#!/bin/bash

set -euo pipefail

# Check arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: jira-transition.sh <JIRA-KEY> <STATUS>"
    echo "Example: jira-transition.sh ADVERIFY-70 \"In Progress\""
    exit 1
fi

ISSUE_KEY="$1"
TARGET_STATUS="$2"

# Jira credentials must already be available in the environment.
: "${JIRA_BASE_URL:?JIRA_BASE_URL is not set}"
: "${JIRA_EMAIL:?JIRA_EMAIL is not set}"
: "${JIRA_API_TOKEN:?JIRA_API_TOKEN is not set}"

# Get available transitions
RESPONSE=$(curl -sS \
    -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
    -H "Accept: application/json" \
    "$JIRA_BASE_URL/rest/api/3/issue/$ISSUE_KEY/transitions")

# Find the transition whose destination status matches the requested status.
TRANSITION_ID=$(echo "$RESPONSE" | jq -r \
    --arg status "$TARGET_STATUS" \
    '.transitions[]
     | select(.to.name == $status)
     | .id' \
    | head -n 1)

if [ -z "$TRANSITION_ID" ] || [ "$TRANSITION_ID" = "null" ]; then
    echo "Error: No available transition to '$TARGET_STATUS' for $ISSUE_KEY"
    echo "Available transitions:"
    echo "$RESPONSE" | jq -r '.transitions[] | "\(.id): \(.name) → \(.to.name)"'
    exit 1
fi

# Execute transition
curl -sS \
    -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
    -X POST \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    "$JIRA_BASE_URL/rest/api/3/issue/$ISSUE_KEY/transitions" \
    --data "$(jq -n \
        --arg id "$TRANSITION_ID" \
        '{transition: {id: $id}}'
    )" \
    > /dev/null

# Verify resulting status
ISSUE=$(curl -sS \
    -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
    -H "Accept: application/json" \
    "$JIRA_BASE_URL/rest/api/3/issue/$ISSUE_KEY?fields=status")

CURRENT_STATUS=$(echo "$ISSUE" | jq -r '.fields.status.name // empty')

if [ "$CURRENT_STATUS" != "$TARGET_STATUS" ]; then
    echo "Error: Transition request completed, but status is '$CURRENT_STATUS'"
    exit 1
fi

echo "$ISSUE_KEY → $CURRENT_STATUS"
