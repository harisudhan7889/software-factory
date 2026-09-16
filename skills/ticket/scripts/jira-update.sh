#!/bin/bash

set -euo pipefail
trap 'rm -f "${TMP:-}"' EXIT 2>/dev/null || true

# Update an existing Jira issue's fields (refine path).
# Usage: jira-update.sh <JIRA-KEY> < update.json
# update.json may contain: description_adf (ADF doc), labels (array),
# summary (string), priority (string). Only provided fields are updated.
# Example: jira-update.sh RARRADAR-5 < update.json

if [ "$#" -ne 1 ]; then
    echo "Usage: jira-update.sh <JIRA-KEY>" >&2
    echo 'Reads update JSON from stdin: {"description_adf": {...}, "labels": [...], "summary": "...", "priority": "..."}' >&2
    exit 1
fi

ISSUE_KEY="$1"

: "${JIRA_BASE_URL:?JIRA_BASE_URL is not set}"
: "${JIRA_EMAIL:?JIRA_EMAIL is not set}"
: "${JIRA_API_TOKEN:?JIRA_API_TOKEN is not set}"

INPUT=$(cat)

if [ -z "$INPUT" ]; then
    echo "Error: No update JSON provided on stdin" >&2
    exit 1
fi

# Guardrail: reject single-paragraph description dumps. Jira ADF ignores
# bare newlines inside one text node, so the whole description renders as
# one unformatted block. Descriptions must use structured nodes
# (heading / bulletList / orderedList / paragraph).
if echo "$INPUT" | jq -e '.description_adf' > /dev/null 2>&1; then
    DOC_TYPE=$(echo "$INPUT" | jq -r '.description_adf.type // empty')
    if [ "$DOC_TYPE" != "doc" ]; then
        echo "Error: description_adf.type must be \"doc\"" >&2
        exit 1
    fi
    NODE_COUNT=$(echo "$INPUT" | jq '.description_adf.content | length')
    FIRST_TYPE=$(echo "$INPUT" | jq -r '.description_adf.content[0].type // empty')
    FIRST_LEN=$(echo "$INPUT" | jq -r '.description_adf.content[0].content[0].text // "" | length')
    if [ "$NODE_COUNT" -eq 1 ] && [ "$FIRST_TYPE" = "paragraph" ] && [ "$FIRST_LEN" -gt 500 ]; then
        echo "Error: description_adf is a single paragraph with $FIRST_LEN chars." >&2
        echo "Build structured ADF instead: h2 headings, bulletList/orderedList, strong/code marks." >&2
        echo "See references/refine.md Phase 8 (Description format)." >&2
        exit 1
    fi
fi

# Build the fields object from provided keys only.
# Note: each branch emits a standalone object (or nothing) and the results
# are merged with `add`. Do NOT use `{k: (if ... else empty end), ...}`
# object construction here: in jq, one `empty` value voids the entire
# object, so partial updates would silently yield `{}`.
FIELDS=$(echo "$INPUT" | jq '[
    (if has("description_adf") then {description: .description_adf} else empty end),
    (if has("labels") then {labels: .labels} else empty end),
    (if has("summary") then {summary: .summary} else empty end),
    (if has("priority") then {priority: {name: .priority}} else empty end)
] | add // {} | with_entries(select(.value != null))')
# jq emits no output when every value is empty; normalise to {}.
if [ -z "$FIELDS" ]; then
    FIELDS='{}'
fi

if [ "$(echo "$FIELDS" | jq 'keys | length')" -eq 0 ]; then
    echo "Error: No updatable fields in input (need description_adf, labels, summary, or priority)" >&2
    exit 1
fi

REQUEST=$(jq -n --argjson fields "$FIELDS" '{fields: $fields}')

HTTP_CODE=$(curl -sS -o /dev/null -w "%{http_code}" \
    -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
    -X PUT \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    "$JIRA_BASE_URL/rest/api/3/issue/$ISSUE_KEY" \
    --data "$REQUEST")

if [ "$HTTP_CODE" != "204" ]; then
    echo "Error: Jira update failed with HTTP $HTTP_CODE for $ISSUE_KEY" >&2
    exit 1
fi

# Verify by re-reading the issue.
VERIFY=$(curl -sS \
    -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
    -H "Accept: application/json" \
    "$JIRA_BASE_URL/rest/api/3/issue/$ISSUE_KEY?fields=summary,labels,priority,status,description")

echo "Updated Jira issue:"
echo "Key: $ISSUE_KEY"
echo "$VERIFY" | jq -r '"Status: \(.fields.status.name) | Priority: \(.fields.priority.name) | Labels: \(.fields.labels | join(", "))"'
echo "URL: $JIRA_BASE_URL/browse/$ISSUE_KEY"
