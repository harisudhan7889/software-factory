#!/bin/bash

set -euo pipefail
trap 'rm -f "${TMP:-}"' EXIT 2>/dev/null || true

# Load project configuration
PROJECT_DIR="$(pwd)"

if [ -f "$PROJECT_DIR/.env" ]; then
    set -a
    source "$PROJECT_DIR/.env"
    set +a
else
    echo "Error: .env not found in $PROJECT_DIR" >&2
    exit 1
fi

# Check required environment variables
: "${JIRA_BASE_URL:?JIRA_BASE_URL is not set}"
: "${JIRA_EMAIL:?JIRA_EMAIL is not set}"
: "${JIRA_API_TOKEN:?JIRA_API_TOKEN is not set}"
: "${JIRA_PROJECT_KEY:?JIRA_PROJECT_KEY is not set}"

# Read JSON from stdin
INPUT=$(cat)

if [ -z "$INPUT" ]; then
    echo "Error: No ticket JSON provided" >&2
    exit 1
fi

# Extract fields
SUMMARY=$(echo "$INPUT" | jq -r '.summary // empty')
DESCRIPTION=$(echo "$INPUT" | jq -r '.description // empty')
ISSUE_TYPE=$(echo "$INPUT" | jq -r '.issue_type // "Story"')
PRIORITY=$(echo "$INPUT" | jq -r '.priority // "Low"')
LABELS=$(echo "$INPUT" | jq -r '.labels // empty')
PARENT=$(echo "$INPUT" | jq -r '.parent // empty')

# Validate required fields
if [ -z "$SUMMARY" ]; then
    echo "Error: summary is required" >&2
    exit 1
fi

if [ -z "$DESCRIPTION" ]; then
    echo "Error: description is required" >&2
    exit 1
fi

# Build Jira request
REQUEST=$(jq -n \
    --arg project "$JIRA_PROJECT_KEY" \
    --arg summary "$SUMMARY" \
    --arg description "$DESCRIPTION" \
    --arg issue_type "$ISSUE_TYPE" \
    --arg priority "$PRIORITY" \
    --arg labels "$LABELS" \
    --arg parent "$PARENT" \
    '
    {
        fields: {
            project: {
                key: $project
            },
            summary: $summary,
            priority: {
                name: $priority
            },
            description: {
                type: "doc",
                version: 1,
                content: [
                    {
                        type: "paragraph",
                        content: [
                            {
                                type: "text",
                                text: $description
                            }
                        ]
                    }
                ]
            },
            issuetype: {
                name: $issue_type
            }
        }
    }

    |

    if $labels != "" then
        .fields.labels = ($labels | split(",") | map(gsub("^\\s+|\\s+$"; "")))
    else
        .
    end

    |

    if $parent != "" then
        .fields.parent = {
            key: $parent
        }
    else
        .
    end
    ')

# Create Jira issue
RESPONSE=$(curl -sS \
    -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
    -X POST \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    "$JIRA_BASE_URL/rest/api/3/issue" \
    --data "$REQUEST")

# Check response
ISSUE_KEY=$(echo "$RESPONSE" | jq -r '.key // empty')

if [ -z "$ISSUE_KEY" ]; then
    echo "Failed to create Jira ticket:"
    echo "$RESPONSE" | jq .
    exit 1
fi

echo "Created Jira issue:"
echo "Key: $ISSUE_KEY"
echo "URL: $JIRA_BASE_URL/browse/$ISSUE_KEY"