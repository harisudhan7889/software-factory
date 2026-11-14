#!/bin/bash

set -euo pipefail

NUMBER=""
OID=""
BASE=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        --number) NUMBER="$2"; shift 2 ;;
        --oid) OID="$2"; shift 2 ;;
        --base) BASE="$2"; shift 2 ;;
        *) echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
done

if [ -z "$NUMBER" ] || [ -z "$OID" ] || [ -z "$BASE" ]; then
    echo "Usage: pr-worktree-materialize.sh --number <n> --oid <oid> --base <base>" >&2
    exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
WORKTREE_ROOT="$REPO_ROOT/.pr-review-worktrees"
WORKTREE_PATH="$WORKTREE_ROOT/pr-$NUMBER-${OID:0:12}"

mkdir -p "$WORKTREE_ROOT"

# This worktree is isolated from the user's primary working tree and from
# other jobs' worktrees (RFC-0003 worktree-isolation rule). Never run this
# against the primary checkout.

git fetch origin "pull/$NUMBER/head:refs/remotes/origin/pr/$NUMBER" --force
git fetch origin "$BASE"

if [ -d "$WORKTREE_PATH" ]; then
    echo "WORKTREE:$WORKTREE_PATH"
    exit 0
fi

git worktree add --detach "$WORKTREE_PATH" "$OID"

echo "WORKTREE:$WORKTREE_PATH"
