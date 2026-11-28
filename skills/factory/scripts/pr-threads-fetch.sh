#!/bin/bash
#
# pr-threads-fetch.sh — fetch the review feedback that still needs an answer on
# one Pull Request. Read-only: it never posts, resolves, or commits anything.
#
# Output (JSON on stdout):
#   {
#     "pr": <number>,
#     "threads": [                      # unresolved review threads only
#       { "id", "isOutdated", "path", "line", "originalLine",
#         "comments": [ { "databaseId", "author", "authorType",
#                         "body", "createdAt", "diffHunk" } ] }   # oldest first
#     ],
#     "copilotReviewBodies": [          # Copilot review summaries that carry a
#       { "reviewId", "submittedAt", "commitId", "body" }          # "Suppressed comments" block
#     ]
#   }
#
# Why the second list exists: GitHub's Copilot reviewer keeps its low-confidence
# findings out of the inline threads and lists them only inside a collapsed
# "Suppressed comments (N)" block in the review summary body. The thread query
# alone never returns them. The script returns the raw bodies; the caller parses
# the block (see skills/factory/references/address-comments.md, Phase 2).

set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: pr-threads-fetch.sh <PR#>" >&2
    echo "Example: pr-threads-fetch.sh 42" >&2
    exit 1
fi

PR="$1"
case "$PR" in
    ''|*[!0-9]*) echo "Error: PR number must be a positive integer, got '$PR'." >&2; exit 1 ;;
esac

for tool in gh jq; do
    command -v "$tool" >/dev/null 2>&1 || { echo "Error: $tool is required." >&2; exit 1; }
done

# Current repository by default; GH_REPO=owner/name overrides it (gh convention).
NAME_WITH_OWNER=$(gh repo view ${GH_REPO:+"$GH_REPO"} --json nameWithOwner --jq '.nameWithOwner')
OWNER="${NAME_WITH_OWNER%%/*}"
REPO="${NAME_WITH_OWNER##*/}"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

COMMENT_FIELDS='databaseId body createdAt diffHunk author { login __typename }'

THREADS_QUERY='
query($owner: String!, $repo: String!, $pr: Int!, $after: String) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      reviewThreads(first: 100, after: $after) {
        pageInfo { hasNextPage endCursor }
        nodes {
          id isResolved isOutdated path line originalLine
          comments(first: 100) {
            pageInfo { hasNextPage endCursor }
            nodes { '"$COMMENT_FIELDS"' }
          }
        }
      }
    }
  }
}'

MORE_COMMENTS_QUERY='
query($id: ID!, $after: String) {
  node(id: $id) {
    ... on PullRequestReviewThread {
      comments(first: 100, after: $after) {
        pageInfo { hasNextPage endCursor }
        nodes { '"$COMMENT_FIELDS"' }
      }
    }
  }
}'

# 1. Page through every review thread; keep the unresolved ones.
: > "$TMP/threads.ndjson"
AFTER=""
while :; do
    ARGS=(-f owner="$OWNER" -f repo="$REPO" -F pr="$PR")
    [ -n "$AFTER" ] && ARGS+=(-f after="$AFTER")
    gh api graphql -f query="$THREADS_QUERY" "${ARGS[@]}" > "$TMP/page.json"
    jq -c '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false)' \
        "$TMP/page.json" >> "$TMP/threads.ndjson"
    [ "$(jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.hasNextPage' "$TMP/page.json")" = "true" ] || break
    AFTER=$(jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.endCursor' "$TMP/page.json")
done

# 2. A thread with more than 100 comments: fetch the remaining replies so no
#    reply that narrows or withdraws the request is missed.
: > "$TMP/complete.ndjson"
while IFS= read -r THREAD; do
    [ -n "$THREAD" ] || continue
    printf '%s' "$THREAD" | jq '.comments.nodes' > "$TMP/comments.json"
    HAS_MORE=$(printf '%s' "$THREAD" | jq -r '.comments.pageInfo.hasNextPage')
    CURSOR=$(printf '%s' "$THREAD" | jq -r '.comments.pageInfo.endCursor // empty')
    THREAD_ID=$(printf '%s' "$THREAD" | jq -r '.id')
    while [ "$HAS_MORE" = "true" ]; do
        gh api graphql -f query="$MORE_COMMENTS_QUERY" -f id="$THREAD_ID" -f after="$CURSOR" > "$TMP/more.json"
        jq -s '.[0] + .[1].data.node.comments.nodes' "$TMP/comments.json" "$TMP/more.json" > "$TMP/merged.json"
        mv "$TMP/merged.json" "$TMP/comments.json"
        HAS_MORE=$(jq -r '.data.node.comments.pageInfo.hasNextPage' "$TMP/more.json")
        CURSOR=$(jq -r '.data.node.comments.pageInfo.endCursor // empty' "$TMP/more.json")
    done
    printf '%s' "$THREAD" | jq -c --slurpfile comments "$TMP/comments.json" '
        {
          id, isOutdated, path, line, originalLine,
          comments: ($comments[0] | sort_by(.createdAt) | map({
            databaseId,
            author: (.author.login // "ghost"),
            authorType: (.author.__typename // "Unknown"),
            body, createdAt, diffHunk
          }))
        }' >> "$TMP/complete.ndjson"
done < "$TMP/threads.ndjson"

# 3. Copilot review summaries that hold a "Suppressed comments" block.
#    --paginate so a long review history cannot hide the body that carries it.
gh api "repos/$OWNER/$REPO/pulls/$PR/reviews" --paginate --jq '
    .[]
    | select(.user.login == "copilot-pull-request-reviewer[bot]")
    | select((.body // "") | test("Suppressed comments"))
    | { reviewId: .id, submittedAt: .submitted_at, commitId: .commit_id, body: .body }
' > "$TMP/copilot.ndjson"

jq -n \
    --argjson pr "$PR" \
    --slurpfile threads "$TMP/complete.ndjson" \
    --slurpfile copilot "$TMP/copilot.ndjson" \
    '{ pr: $pr, threads: $threads, copilotReviewBodies: $copilot }'
