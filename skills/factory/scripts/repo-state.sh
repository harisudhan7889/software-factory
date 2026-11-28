#!/bin/bash
#
# repo-state.sh — report the current Git and Pull Request state in one call.
# Read-only: it changes nothing. Replaces the repeated "inspect the repository"
# steps in the pr open, resolve-conflicts, and address-comments workflows.
#
# Usage: repo-state.sh [--fetch]
#   --fetch   run `git fetch` first so ahead/behind and the PR head are current.
#             Without it, ahead/behind uses the last fetched state.
#
# Output: KEY=value lines, then the short working-tree status after a
# "STATUS:" line. Remote URLs have embedded credentials masked.
#
#   IS_GIT_REPO      true | false
#   BRANCH           current branch, or DETACHED
#   HEAD             current commit
#   DEFAULT_BRANCH   from origin/HEAD, or unknown
#   REMOTE_<name>    remote URL (credentials masked)
#   GITHUB_REPO      owner/name parsed from origin, or unknown
#   UPSTREAM         tracked branch, or none
#   AHEAD, BEHIND    commits ahead of / behind UPSTREAM
#   DIRTY_FILES      count of changed or untracked files
#   FACTORY_PROJECT  present | absent   (.factory/project.yml)
#   FACTORY_MEMORY   present | absent   (.factory/memory.md)
#   PR_NUMBER, PR_STATE, PR_URL, PR_BASE, PR_HEAD_REF, PR_HEAD_OID, PR_MERGEABLE
#                    for the open or latest PR of this branch; PR_NUMBER=none
#                    when there is none or `gh` is unavailable

set -euo pipefail

FETCH=0
case "${1:-}" in
    --fetch) FETCH=1 ;;
    "") ;;
    *) echo "Usage: repo-state.sh [--fetch]" >&2; exit 1 ;;
esac

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "IS_GIT_REPO=false"
    exit 0
fi
echo "IS_GIT_REPO=true"

if [ "$FETCH" -eq 1 ]; then
    git fetch --quiet 2>/dev/null || echo "WARN: git fetch failed; remote state may be stale" >&2
fi

BRANCH=$(git branch --show-current)
echo "BRANCH=${BRANCH:-DETACHED}"
echo "HEAD=$(git rev-parse --verify -q HEAD || echo none)"

DEFAULT=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##' || true)
echo "DEFAULT_BRANCH=${DEFAULT:-unknown}"

# Masked remote URLs: never print a token that is part of the URL.
while read -r NAME URL _; do
    [ -n "${NAME:-}" ] || continue
    echo "REMOTE_${NAME}=$(printf '%s' "$URL" | sed -E 's#//[^/@]+@#//***@#')"
done < <(git remote -v | awk '/\(fetch\)/ {print $1, $2}')

ORIGIN=$(git remote get-url origin 2>/dev/null || true)
SLUG=$(printf '%s' "$ORIGIN" | sed -E 's#^.*github\.com[:/]##; s#\.git$##')
case "$SLUG" in
    */*) echo "GITHUB_REPO=$SLUG" ;;
    *)   echo "GITHUB_REPO=unknown" ;;
esac

UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)
echo "UPSTREAM=${UPSTREAM:-none}"
if [ -n "$UPSTREAM" ]; then
    read -r BEHIND AHEAD < <(git rev-list --left-right --count "${UPSTREAM}...HEAD")
    echo "AHEAD=$AHEAD"
    echo "BEHIND=$BEHIND"
fi

STATUS=$(git status --short)
if [ -n "$STATUS" ]; then DIRTY=$(printf '%s\n' "$STATUS" | wc -l | tr -d ' '); else DIRTY=0; fi
echo "DIRTY_FILES=$DIRTY"

[ -f .factory/project.yml ] && echo "FACTORY_PROJECT=present" || echo "FACTORY_PROJECT=absent"
[ -f .factory/memory.md ]   && echo "FACTORY_MEMORY=present"  || echo "FACTORY_MEMORY=absent"

PR_NUMBER=none
if [ -n "$BRANCH" ] && command -v gh >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    if PR_JSON=$(gh pr view "$BRANCH" --json number,state,url,baseRefName,headRefName,headRefOid,mergeable 2>/dev/null); then
        PR_NUMBER=$(printf '%s' "$PR_JSON" | jq -r '.number')
        echo "PR_NUMBER=$PR_NUMBER"
        printf '%s' "$PR_JSON" | jq -r '
            "PR_STATE=\(.state)",
            "PR_URL=\(.url)",
            "PR_BASE=\(.baseRefName)",
            "PR_HEAD_REF=\(.headRefName)",
            "PR_HEAD_OID=\(.headRefOid)",
            "PR_MERGEABLE=\(.mergeable)"'
    fi
fi
[ "$PR_NUMBER" = "none" ] && echo "PR_NUMBER=none"

echo "STATUS:"
printf '%s\n' "$STATUS"
