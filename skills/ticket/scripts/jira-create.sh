#!/bin/bash

set -euo pipefail
trap 'rm -f "${TMP:-}"' EXIT 2>/dev/null || true

# Resolve project-specific Jira configuration.
# Only JIRA_PROJECT_KEY may come from the current project's .env.
# Shared Jira credentials must already exist in the global environment.
PROJECT_DIR="$(pwd)"
PROJECT_ENV="$PROJECT_DIR/.env"

if [ ! -f "$PROJECT_ENV" ]; then
    echo "Error: Project-local .env not found in $PROJECT_DIR" >&2
    echo "Ask the user to provide JIRA_PROJECT_KEY for this project, then add it to $PROJECT_ENV." >&2
    exit 1
fi

# Read only JIRA_PROJECT_KEY from the project-local .env.
# Do not source the full file: project .env values must not override
# globally provided Jira credentials.
JIRA_PROJECT_KEY=$(
    awk '
        /^[[:space:]]*export[[:space:]]+JIRA_PROJECT_KEY[[:space:]]*=/ {
            sub(/^[[:space:]]*export[[:space:]]+JIRA_PROJECT_KEY[[:space:]]*=[[:space:]]*/, "")
            print
            exit
        }
        /^[[:space:]]*JIRA_PROJECT_KEY[[:space:]]*=/ {
            sub(/^[[:space:]]*JIRA_PROJECT_KEY[[:space:]]*=[[:space:]]*/, "")
            print
            exit
        }
    ' "$PROJECT_ENV"
)

# Strip one matching pair of surrounding quotes, if present.
if [[ "$JIRA_PROJECT_KEY" =~ ^".*"$ ]]; then
    JIRA_PROJECT_KEY="${JIRA_PROJECT_KEY:1:${#JIRA_PROJECT_KEY}-2}"
elif [[ "$JIRA_PROJECT_KEY" =~ ^'.*'$ ]]; then
    JIRA_PROJECT_KEY="${JIRA_PROJECT_KEY:1:${#JIRA_PROJECT_KEY}-2}"
fi

if [ -z "$JIRA_PROJECT_KEY" ]; then
    echo "Error: JIRA_PROJECT_KEY is not configured for this project." >&2
    echo "Ask the user explicitly for the Jira project key, then add it to $PROJECT_ENV." >&2
    exit 1
fi

# Shared Jira credentials must come from the global environment.
: "${JIRA_BASE_URL:?JIRA_BASE_URL is not set in the global environment}"
: "${JIRA_EMAIL:?JIRA_EMAIL is not set in the global environment}"
: "${JIRA_API_TOKEN:?JIRA_API_TOKEN is not set in the global environment}"

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
LINKS=$(echo "$INPUT" | jq -r '.links // empty')

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

# Optional issue links, comma-separated: "Relates:KEY,Blocks:KEY,BlockedBy:KEY".
#   Relates   -> new issue relates to KEY (symmetric).
#   Blocks    -> new issue blocks KEY.
#   BlockedBy -> new issue is blocked by KEY.
# Links are created only after the issue exists. A failed link never undoes
# the creation: the key is already printed above, failures are reported here.
if [ -n "$LINKS" ]; then
    LINK_OK=0
    LINK_FAIL=0
    OLD_IFS="$IFS"
    IFS=','
    for SPEC in $LINKS; do
        REL="$(echo "$SPEC" | cut -d: -f1 | tr '[:upper:]' '[:lower:]' | tr -d ' -')"
        TARGET="$(echo "$SPEC" | cut -sd: -f2- | tr -d ' ')"
        case "$REL" in
            relates) TYPE="Relates"; INWARD="$TARGET"; OUTWARD="$ISSUE_KEY" ;;
            blocks) TYPE="Blocks"; INWARD="$TARGET"; OUTWARD="$ISSUE_KEY" ;;
            blockedby) TYPE="Blocks"; INWARD="$ISSUE_KEY"; OUTWARD="$TARGET" ;;
            *)
                echo "Warning: skipping invalid link '$SPEC' (use Relates:KEY, Blocks:KEY, or BlockedBy:KEY)" >&2
                LINK_FAIL=$((LINK_FAIL + 1))
                continue
                ;;
        esac
        if [ -z "$TARGET" ]; then
            echo "Warning: skipping link '$SPEC' (missing issue key)" >&2
            LINK_FAIL=$((LINK_FAIL + 1))
            continue
        fi
        LINK_RESPONSE=$(curl -sS \
            -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
            -X POST \
            -H "Accept: application/json" \
            -H "Content-Type: application/json" \
            "$JIRA_BASE_URL/rest/api/3/issueLink" \
            --data "$(jq -n \
                --arg type "$TYPE" \
                --arg inward "$INWARD" \
                --arg outward "$OUTWARD" \
                '{type: {name: $type}, inwardIssue: {key: $inward}, outwardIssue: {key: $outward}}')")
        if echo "$LINK_RESPONSE" | jq -e '.errorMessages // .errors // empty' > /dev/null 2>&1; then
            echo "Warning: link '$SPEC' failed:" >&2
            echo "$LINK_RESPONSE" | jq . >&2
            LINK_FAIL=$((LINK_FAIL + 1))
        else
            echo "Linked: $ISSUE_KEY $REL $TARGET"
            LINK_OK=$((LINK_OK + 1))
        fi
    done
    IFS="$OLD_IFS"
    if [ "$LINK_FAIL" -gt 0 ]; then
        echo "Warning: $LINK_FAIL of $((LINK_OK + LINK_FAIL)) link(s) failed (issue $ISSUE_KEY was still created)" >&2
    fi
fi