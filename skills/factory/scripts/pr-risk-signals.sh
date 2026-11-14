#!/bin/bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: pr-risk-signals.sh <base-ref>" >&2
    echo "Run from inside the PR review worktree (cwd = worktree)." >&2
    exit 1
fi

BASE_REF="$1"

CHANGED_FILES=$(git diff --name-only "${BASE_REF}...HEAD")
STAT=$(git diff --shortstat "${BASE_REF}...HEAD" || true)

INSERTIONS=$(echo "$STAT" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || true)
DELETIONS=$(echo "$STAT" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || true)
CHANGED_LINES=$(( ${INSERTIONS:-0} + ${DELETIONS:-0} ))

SIGNAL_SECURITY=0
SIGNAL_SCHEMA=0
SIGNAL_CI=0
SIGNAL_DEPENDENCY=0
SIGNAL_LARGE_DIFF=0

# Security-sensitive paths: auth, RLS/policy, Stripe/payments, secrets, env files.
if echo "$CHANGED_FILES" | grep -qiE '(auth|session|rls|policy|stripe|payment|secret|\.env)'; then
    SIGNAL_SECURITY=1
fi

# Schema/migration changes (Supabase Postgres).
if echo "$CHANGED_FILES" | grep -qiE '(supabase/migrations/|\.sql$|schema\.prisma$)'; then
    SIGNAL_SCHEMA=1
fi

# CI/workflow changes.
if echo "$CHANGED_FILES" | grep -qE '^\.github/workflows/'; then
    SIGNAL_CI=1
fi

# Dependency manifest/lockfile changes.
if echo "$CHANGED_FILES" | grep -qE '(^|/)(package\.json|package-lock\.json|pnpm-lock\.yaml|yarn\.lock)$'; then
    SIGNAL_DEPENDENCY=1
fi

# Large diff.
if [ "$CHANGED_LINES" -gt 400 ]; then
    SIGNAL_LARGE_DIFF=1
fi

RISK_SCORE=$(( SIGNAL_SECURITY * 3 + SIGNAL_SCHEMA * 2 + SIGNAL_CI * 1 + SIGNAL_DEPENDENCY * 1 + SIGNAL_LARGE_DIFF * 1 ))

if [ "$RISK_SCORE" -ge 4 ]; then
    RISK_BAND="high"
elif [ "$RISK_SCORE" -ge 2 ]; then
    RISK_BAND="medium"
else
    RISK_BAND="low"
fi

echo "RISK_SCORE=$RISK_SCORE"
echo "RISK_BAND=$RISK_BAND"
echo "SIGNAL_SECURITY=$SIGNAL_SECURITY"
echo "SIGNAL_SCHEMA=$SIGNAL_SCHEMA"
echo "SIGNAL_CI=$SIGNAL_CI"
echo "SIGNAL_DEPENDENCY=$SIGNAL_DEPENDENCY"
echo "SIGNAL_LARGE_DIFF=$SIGNAL_LARGE_DIFF"
