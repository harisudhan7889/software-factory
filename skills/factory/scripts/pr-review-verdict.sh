#!/bin/bash

set -euo pipefail

# Reads issues JSON from stdin:
# { "issues": [{ "severity": "...", "confidence": "..." }, ...],
#   "open_questions": <bool>, "test_gap": <bool> }
#
# Prints one suggested verdict: approve | comment | request-changes
# This is a suggestion only — the human posts the review.

INPUT=$(cat)

echo "$INPUT" | jq -r '
    (.issues // []) as $issues
    | ($issues | map(select(.severity == "critical" or .severity == "high"))) as $blocking_candidates
    | (any($blocking_candidates[]; .confidence == "high" or .confidence == "medium")) as $hard_block
    | (any($blocking_candidates[]; .confidence == "low")) as $soft_block
    | (.open_questions // false) as $open_questions
    | (.test_gap // false) as $test_gap
    | if $hard_block then "request-changes"
      elif $soft_block or $open_questions or $test_gap or (($issues | length) > 0) then "comment"
      else "approve"
      end
'
