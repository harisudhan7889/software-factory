#!/bin/bash

set -euo pipefail
trap 'rm -f "${TMP:-}"' EXIT 2>/dev/null || true

# Check arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: jira-comment.sh <JIRA-KEY> <COMMENT>" >&2
    echo 'Example: jira-comment.sh ADVERIFY-70 "Implementation completed."'
    exit 1
fi

ISSUE_KEY="$1"
COMMENT="$2"

# Jira credentials must already be available in the environment.
: "${JIRA_BASE_URL:?JIRA_BASE_URL is not set}"
: "${JIRA_EMAIL:?JIRA_EMAIL is not set}"
: "${JIRA_API_TOKEN:?JIRA_API_TOKEN is not set}"

# Build Jira Atlassian Document Format payload
REQUEST=$(jq -n \
    --arg comment "$COMMENT" \
    '{
        body: {
            type: "doc",
            version: 1,
            content: [
                {
                    type: "paragraph",
                    content: [
                        {
                            type: "text",
                            text: $comment
                        }
                    ]
                }
            ]
        }
    }'
)

# Add comment
RESPONSE=$(curl -sS \
    -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
    -X POST \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    "$JIRA_BASE_URL/rest/api/3/issue/$ISSUE_KEY/comment" \
    --data "$REQUEST")

# Verify response
COMMENT_ID=$(echo "$RESPONSE" | jq -r '.id // empty')

if [ -z "$COMMENT_ID" ]; then
    echo "Failed to add Jira comment:"
    echo "$RESPONSE" | jq .
    exit 1
fi

echo "Comment added to $ISSUE_KEY"
echo "Comment ID: $COMMENT_ID"
