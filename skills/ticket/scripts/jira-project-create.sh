#!/bin/bash

# Create a new Jira project. This is an externally visible, high-risk
# operation: the caller (the factory's Jira provisioning workflow,
# references/jira-provisioning.md) must have already obtained explicit
# human approval before invoking this script. This script does not ask
# for approval itself.
#
# Usage: jira-project-create.sh < project.json
#
# project.json fields:
#   key              required. 2-10 uppercase letters, must start with a
#                    letter (Jira's project key rules).
#   name             required.
#   description      optional.
#   project_type_key optional, default "software".
#   template_key     optional. When given, used exactly as provided, with
#                    no fallback — Jira's error is reported directly if it
#                    fails.
#   template_keys    optional array, tried in order, stopping at the first
#                    one Jira accepts. Ignored when template_key is given.
#                    When neither is given, defaults to:
#                      1. com.pyxis.greenhopper.jira:gh-simplified-agility
#                         (Atlassian's documented team-managed example;
#                         not available on every site/plan)
#                      2. com.pyxis.greenhopper.jira:gh-kanban-template
#                         (classic/company-managed Kanban; confirmed
#                         working against a real site, 2026-11-16, where
#                         both team-managed "simplified" templates
#                         returned "template does not exist")
#                    A 401/403 on any attempt stops the fallback
#                    immediately — retrying other templates cannot fix an
#                    authentication/permission failure.
#   lead_account_id  optional. Defaults to the authenticated user's own
#                    accountId (via /rest/api/3/myself) when omitted.
#   assignee_type    optional, default "PROJECT_LEAD".
#
# Exit codes:
#   0  Project created.
#   1  Error (bad input, auth/network failure, Jira rejected the request).

set -euo pipefail
TMP1=""
TMP2=""
trap 'rm -f "${TMP1:-}" "${TMP2:-}"' EXIT

: "${JIRA_BASE_URL:?JIRA_BASE_URL is not set in the global environment}"
: "${JIRA_EMAIL:?JIRA_EMAIL is not set in the global environment}"
: "${JIRA_API_TOKEN:?JIRA_API_TOKEN is not set in the global environment}"

INPUT=$(cat)
if [ -z "$INPUT" ]; then
    echo "Error: No project JSON provided on stdin" >&2
    exit 1
fi

KEY=$(echo "$INPUT" | jq -r '.key // empty')
NAME=$(echo "$INPUT" | jq -r '.name // empty')
DESCRIPTION=$(echo "$INPUT" | jq -r '.description // empty')
PROJECT_TYPE_KEY=$(echo "$INPUT" | jq -r '.project_type_key // "software"')
TEMPLATE_KEY_SINGLE=$(echo "$INPUT" | jq -r '.template_key // empty')
LEAD_ACCOUNT_ID=$(echo "$INPUT" | jq -r '.lead_account_id // empty')
ASSIGNEE_TYPE=$(echo "$INPUT" | jq -r '.assignee_type // "PROJECT_LEAD"')

if [ -z "$KEY" ]; then
    echo "Error: key is required" >&2
    exit 1
fi

if ! [[ "$KEY" =~ ^[A-Z][A-Z0-9]{1,9}$ ]]; then
    echo "Error: key '$KEY' is invalid. Jira project keys must be 2-10 characters, start with an uppercase letter, and contain only uppercase letters/digits." >&2
    exit 1
fi

if [ -z "$NAME" ]; then
    echo "Error: name is required" >&2
    exit 1
fi

TEMPLATE_CANDIDATES=()
if [ -n "$TEMPLATE_KEY_SINGLE" ]; then
    TEMPLATE_CANDIDATES=("$TEMPLATE_KEY_SINGLE")
else
    while IFS= read -r CANDIDATE_LINE; do
        [ -n "$CANDIDATE_LINE" ] && TEMPLATE_CANDIDATES+=("$CANDIDATE_LINE")
    done < <(echo "$INPUT" | jq -r '.template_keys // empty | if type=="array" then .[] else empty end')
    if [ "${#TEMPLATE_CANDIDATES[@]}" -eq 0 ]; then
        TEMPLATE_CANDIDATES=(
            "com.pyxis.greenhopper.jira:gh-simplified-agility"
            "com.pyxis.greenhopper.jira:gh-kanban-template"
        )
    fi
fi

if [ -z "$LEAD_ACCOUNT_ID" ]; then
    TMP1=$(mktemp)
    SELF_HTTP=$(curl -sS -o "$TMP1" -w "%{http_code}" \
        -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
        -H "Accept: application/json" \
        "$JIRA_BASE_URL/rest/api/3/myself") || SELF_HTTP="000"
    if [ "$SELF_HTTP" = "000" ]; then
        echo "Error: could not reach Jira at $JIRA_BASE_URL (network or TLS failure)" >&2
        exit 1
    fi
    if [ "$SELF_HTTP" != "200" ]; then
        echo "Error: could not resolve the authenticated user's accountId (HTTP $SELF_HTTP) to default lead_account_id. Pass lead_account_id explicitly." >&2
        cat "$TMP1" >&2
        exit 1
    fi
    LEAD_ACCOUNT_ID=$(jq -r '.accountId // empty' "$TMP1")
    if [ -z "$LEAD_ACCOUNT_ID" ]; then
        echo "Error: /myself response did not contain an accountId. Pass lead_account_id explicitly." >&2
        exit 1
    fi
fi

USED_TEMPLATE_KEY=""
TRIED_SUMMARY=()
LAST_HTTP=""
LAST_BODY=""

for CANDIDATE in "${TEMPLATE_CANDIDATES[@]}"; do
    REQUEST=$(jq -n \
        --arg key "$KEY" \
        --arg name "$NAME" \
        --arg description "$DESCRIPTION" \
        --arg projectTypeKey "$PROJECT_TYPE_KEY" \
        --arg projectTemplateKey "$CANDIDATE" \
        --arg leadAccountId "$LEAD_ACCOUNT_ID" \
        --arg assigneeType "$ASSIGNEE_TYPE" \
        '
        {
            key: $key,
            name: $name,
            projectTypeKey: $projectTypeKey,
            projectTemplateKey: $projectTemplateKey,
            leadAccountId: $leadAccountId,
            assigneeType: $assigneeType
        }
        |
        if $description != "" then .description = $description else . end
        ')

    TMP2=$(mktemp)
    HTTP_CODE=$(curl -sS -o "$TMP2" -w "%{http_code}" \
        -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
        -X POST \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        "$JIRA_BASE_URL/rest/api/3/project" \
        --data "$REQUEST") || HTTP_CODE="000"
    BODY=$(cat "$TMP2" 2>/dev/null || echo "")
    rm -f "$TMP2"

    if [ "$HTTP_CODE" = "000" ]; then
        echo "Error: could not reach Jira at $JIRA_BASE_URL (network or TLS failure)" >&2
        exit 1
    fi

    TRIED_SUMMARY+=("$CANDIDATE (HTTP $HTTP_CODE)")

    if [ "$HTTP_CODE" = "201" ]; then
        USED_TEMPLATE_KEY="$CANDIDATE"
        break
    fi

    if [ "$HTTP_CODE" = "401" ] || [ "$HTTP_CODE" = "403" ]; then
        echo "Error: Jira rejected the request with HTTP $HTTP_CODE (authentication/permission failure) while trying template '$CANDIDATE'. Not retrying with other templates." >&2
        echo "$BODY" >&2
        exit 1
    fi

    echo "Note: template '$CANDIDATE' rejected with HTTP $HTTP_CODE; trying next candidate if any." >&2
    LAST_HTTP="$HTTP_CODE"
    LAST_BODY="$BODY"
done

if [ -z "$USED_TEMPLATE_KEY" ]; then
    echo "Error: Jira project creation failed for every candidate template: ${TRIED_SUMMARY[*]}" >&2
    echo "Last error (HTTP $LAST_HTTP):" >&2
    echo "$LAST_BODY" >&2
    exit 1
fi

CREATED_KEY=$(echo "$BODY" | jq -r '.key // empty')
if [ -z "$CREATED_KEY" ]; then
    echo "Error: Jira did not return a project key" >&2
    echo "$BODY" >&2
    exit 1
fi

echo "Created Jira project:"
echo "Key: $CREATED_KEY"
echo "Id: $(echo "$BODY" | jq -r '.id // "unknown"')"
echo "Template: $USED_TEMPLATE_KEY"
echo "URL: $JIRA_BASE_URL/browse/$CREATED_KEY"
