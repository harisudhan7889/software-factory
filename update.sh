#!/bin/bash
#
# update.sh — get the latest software factory and refresh your AI tools.
#
# 1. Pulls the latest changes for this repository (fast-forward only).
# 2. Re-runs the installer for the tools that already have the factory, so new
#    skills and agents are linked and removed ones are cleaned up.
#
# Existing skills and agents update by themselves in link mode, because the
# tool folders link to this repository. The refresh step adds new items.
#
# Usage:
#   ./update.sh [--no-pull] [--dry-run] [--yes] [--no-hooks]
#     --no-pull   skip the git pull; only refresh links (use after adding a
#                 skill or agent locally)
#     --dry-run   show what would change; pulls nothing, changes nothing
#     --yes       do not ask for confirmation
#     --no-hooks  do not add or change command-guard hooks
set -euo pipefail

self="$0"
while [ -L "$self" ]; do
  t="$(readlink "$self")"
  case "$t" in /*) self="$t" ;; *) self="$(dirname "$self")/$t" ;; esac
done
ROOT="$(cd "$(dirname "$self")" && pwd)"

PULL=1
DRY=0
PASS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --no-pull) PULL=0; shift ;;
    --dry-run) DRY=1; PASS+=("--dry-run"); shift ;;
    --yes|-y) PASS+=("--yes"); shift ;;
    --no-hooks) PASS+=("--no-hooks"); shift ;;
    -h|--help) sed -n '2,18p' "$self" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $1 (try --help)" >&2; exit 2 ;;
  esac
done

say() { echo "$*" >&2; }

if [ "$PULL" -eq 1 ]; then
  if ! command -v git >/dev/null 2>&1 || ! git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    say "This folder is not a git repository, so it cannot pull updates."
    say "Download the latest version again, or use: ./update.sh --no-pull"
    exit 1
  fi
  branch="$(git -C "$ROOT" symbolic-ref --short -q HEAD || true)"
  upstream="$(git -C "$ROOT" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"
  if [ -z "$branch" ] || [ -z "$upstream" ]; then
    say "The current branch has no upstream to pull from."
    say "Set one (git branch --set-upstream-to=origin/main) or use: ./update.sh --no-pull"
    exit 1
  fi

  say "Checking for updates on $upstream ..."
  if ! git -C "$ROOT" fetch --quiet; then
    say "Could not reach the remote. Check your network, or use: ./update.sh --no-pull"
    exit 1
  fi

  old="$(git -C "$ROOT" rev-parse HEAD)"
  behind="$(git -C "$ROOT" rev-list --count HEAD..@{u})"
  ahead="$(git -C "$ROOT" rev-list --count @{u}..HEAD)"

  if [ "$behind" -eq 0 ]; then
    say "Already up to date."
  else
    say "$behind new commit(s) available:"
    git -C "$ROOT" log --oneline HEAD..@{u} | sed 's/^/  /' >&2
    if [ "$ahead" -gt 0 ]; then
      say "You also have $ahead local commit(s) that are not pushed. A fast-forward is not possible."
      say "Merge or rebase yourself, then run: ./update.sh --no-pull"
      exit 1
    fi
    if [ "$DRY" -eq 1 ]; then
      say "(dry run: not pulling)"
    else
      if ! git -C "$ROOT" merge --ff-only --quiet '@{u}'; then
        say "Could not fast-forward. Your local changes may conflict with the update."
        say "Commit or stash them, then run ./update.sh again. Nothing was changed."
        exit 1
      fi
      say "Updated: $(git -C "$ROOT" rev-parse --short "$old") -> $(git -C "$ROOT" rev-parse --short HEAD)"
      say "Changed files:"
      git -C "$ROOT" diff --stat --stat-width=70 "$old" HEAD | tail -n 15 | sed 's/^/  /' >&2
    fi
  fi
fi

say ""
say "Refreshing the tools that already have the factory ..."
if "$ROOT/install.sh" --tool installed ${PASS[@]+"${PASS[@]}"}; then
  :
else
  rc=$?
  say "No refresh was done. If this is a first install, run ./install.sh."
  exit $rc
fi
say "Update finished. Restart your AI tool to load new skills and agents."
