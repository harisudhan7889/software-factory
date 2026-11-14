#!/bin/bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: pr-review-resolve.sh <PR#|branch>" >&2
    echo 'Example: pr-review-resolve.sh 42' >&2
    exit 1
fi

TARGET="$1"

if ! command -v gh >/dev/null 2>&1; then
    echo "Error: gh CLI is required." >&2
    exit 1
fi

if ! PR_JSON=$(gh pr view "$TARGET" --json number,title,url,author,headRefName,headRefOid,baseRefName,updatedAt 2>&1); then
    echo "Error: no open PR found for '$TARGET'." >&2
    echo "$PR_JSON" >&2
    exit 1
fi

NUMBER=$(echo "$PR_JSON" | jq -r '.number')
LOGIN=$(gh api user --jq '.login' 2>/dev/null || echo "")

MY_LAST_REVIEW_OID=""
MY_LAST_REVIEW_STATE=""

if [ -n "$LOGIN" ]; then
    REVIEWS_JSON=$(gh api "repos/{owner}/{repo}/pulls/$NUMBER/reviews" --paginate 2>/dev/null || echo "[]")
    LAST_REVIEW=$(echo "$REVIEWS_JSON" | jq -r --arg login "$LOGIN" '
        [ .[] | select(.user.login == $login) ] | sort_by(.submitted_at) | last // {}
    ')
    MY_LAST_REVIEW_OID=$(echo "$LAST_REVIEW" | jq -r '.commit_id // empty')
    MY_LAST_REVIEW_STATE=$(echo "$LAST_REVIEW" | jq -r '.state // empty')
fi

echo "$PR_JSON" | jq \
    --arg oid "$MY_LAST_REVIEW_OID" \
    --arg state "$MY_LAST_REVIEW_STATE" \
    '. + {
        myLastReviewOid: (if $oid == "" then null else $oid end),
        myLastReviewState: (if $state == "" then null else $state end)
    }'
