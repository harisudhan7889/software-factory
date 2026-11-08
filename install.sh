#!/bin/bash
#
# install.sh — install the software factory into your AI coding tools.
#
# Detects Claude Code, OpenCode, and Codex, and links the factory into each
# tool's config directory so skills, agents, policies, and guards work there.
# Default mode links files to this repository, so `git pull` updates every tool.
#
# Usage:
#   ./install.sh [--tool claude|opencode|codex|all|installed] [--copy] [--no-hooks]
#                [--dry-run] [--uninstall] [--yes]
#
# Environment overrides (config directories):
#   CLAUDE_HOME (default ~/.claude), OPENCODE_HOME (default ~/.config/opencode),
#   CODEX_HOME (default ~/.codex)
#
# Safety: never overwrites an existing file or directory that is not a link to
# this repository (it skips and reports it). Edits to shared config files
# (CLAUDE.md, AGENTS.md, settings.json) are idempotent and backed up first.
set -euo pipefail

BEGIN_MARK="<!-- software-factory:begin -->"
END_MARK="<!-- software-factory:end -->"

# Resolve the repository root even when this script is run through a symlink.
self="$0"
while [ -L "$self" ]; do
  t="$(readlink "$self")"
  case "$t" in /*) self="$t" ;; *) self="$(dirname "$self")/$t" ;; esac
done
ROOT="$(cd "$(dirname "$self")" && pwd)"

TOOL="auto"
MODE="link"
HOOKS=1
DRY=0
UNINSTALL=0
ASSUME_YES=0
STAMP="$(date +%Y%m%d-%H%M%S)"
WARNINGS=0

while [ $# -gt 0 ]; do
  case "$1" in
    --tool) TOOL="${2:-}"; shift 2 ;;
    --copy) MODE="copy"; shift ;;
    --no-hooks) HOOKS=0; shift ;;
    --dry-run) DRY=1; shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    --yes|-y) ASSUME_YES=1; shift ;;
    -h|--help) sed -n '2,22p' "$self" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $1 (try --help)" >&2; exit 2 ;;
  esac
done

case "$TOOL" in auto|all|installed|claude|opencode|codex) ;; *)
  echo "Invalid --tool value: $TOOL (use claude, opencode, codex, all, or installed)" >&2; exit 2 ;;
esac

say()  { echo "$*" >&2; }
warn() { echo "  ! $*" >&2; WARNINGS=$((WARNINGS + 1)); }
act()  { if [ "$DRY" -eq 1 ]; then echo "  [dry-run] $*" >&2; else echo "  + $*" >&2; fi; }

claude_home()   { echo "${CLAUDE_HOME:-$HOME/.claude}"; }
opencode_home() { echo "${OPENCODE_HOME:-$HOME/.config/opencode}"; }
codex_home()    { echo "${CODEX_HOME:-$HOME/.codex}"; }

detected() {
  case "$1" in
    claude)   command -v claude   >/dev/null 2>&1 || [ -d "$(claude_home)" ] ;;
    opencode) command -v opencode >/dev/null 2>&1 || [ -d "$(opencode_home)" ] ;;
    codex)    command -v codex    >/dev/null 2>&1 || [ -d "$(codex_home)" ] ;;
  esac
}

# is_installed TOOL: true when the factory was installed into that tool before.
is_installed() {
  local home f; home="$(home_of "$1")"
  for f in "$home/CLAUDE.md" "$home/AGENTS.md"; do
    [ -f "$f" ] && grep -qF "$BEGIN_MARK" "$f" && return 0
  done
  [ -d "$home/skills" ] && find "$home/skills" -maxdepth 1 -type l -lname "$ROOT/*" 2>/dev/null | grep -q . && return 0
  return 1
}

home_of() {
  case "$1" in
    claude) claude_home ;; opencode) opencode_home ;; codex) codex_home ;;
  esac
}

label_of() {
  case "$1" in claude) echo "Claude Code" ;; opencode) echo "OpenCode" ;; codex) echo "Codex" ;; esac
}

# --- file helpers -----------------------------------------------------------

# link_item SRC DEST: link (or copy) SRC to DEST without overwriting foreign files.
link_item() {
  local src="$1" dest="$2"
  if [ -L "$dest" ]; then
    if [ "$dest" -ef "$src" ]; then return 0; fi   # already resolves to the factory file
    if [ -d "$dest" ] || [ -f "$dest" ]; then
      case "$(readlink "$dest")" in "$ROOT"/*) ;; *)
        warn "skipped $dest (already links elsewhere: $(readlink "$dest"))"; return 0 ;;
      esac
    fi
  elif [ -e "$dest" ]; then
    warn "skipped $dest (exists and is not managed by the factory)"; return 0
  fi
  act "$dest -> $src"
  [ "$DRY" -eq 1 ] && return 0
  mkdir -p "$(dirname "$dest")"
  if [ "$MODE" = "copy" ]; then
    rm -rf "$dest"; cp -R "$src" "$dest"
  else
    rm -f "$dest"; ln -s "$src" "$dest"
  fi
}

# unlink_item DEST: remove DEST only if it points into this repository.
unlink_item() {
  local dest="$1"
  if [ -L "$dest" ]; then
    case "$(readlink "$dest")" in "$ROOT"/*)
      act "remove $dest"; [ "$DRY" -eq 1 ] || rm -f "$dest" ;;
    esac
  fi
}

backup_file() {
  local f="$1"
  if [ -f "$f" ] && [ "$DRY" -eq 0 ]; then
    cp "$f" "$f.factory-backup-$STAMP"
    say "    backup: $f.factory-backup-$STAMP"
  fi
}

strip_block() {
  awk -v b="$BEGIN_MARK" -v e="$END_MARK" '$0==b{skip=1;next} $0==e{skip=0;next} !skip' "$1"
}

# write_block FILE CONTENT: add or refresh the factory block in a shared file.
write_block() {
  local file="$1" content="$2" tmp
  tmp="$(mktemp)"
  if [ -f "$file" ]; then
    # Drop the old block and any trailing blank lines left behind.
    strip_block "$file" | awk '{l[NR]=$0} END{n=NR; while(n>0 && l[n]=="") n--; for(i=1;i<=n;i++) print l[i]}' > "$tmp"
  fi
  { cat "$tmp"; [ -s "$tmp" ] && echo; echo "$BEGIN_MARK"; echo "$content"; echo "$END_MARK"; } > "$tmp.new"
  if [ -f "$file" ] && cmp -s "$tmp.new" "$file"; then
    rm -f "$tmp" "$tmp.new"; return 0   # already up to date
  fi
  act "update managed block in $file"
  if [ "$DRY" -eq 0 ]; then
    mkdir -p "$(dirname "$file")"
    if [ -f "$file" ] && ! grep -qF "$BEGIN_MARK" "$file"; then backup_file "$file"; fi
    mv "$tmp.new" "$file"
  fi
  rm -f "$tmp" "$tmp.new"
}

remove_block() {
  local file="$1" tmp
  [ -f "$file" ] && grep -qF "$BEGIN_MARK" "$file" || return 0
  act "remove managed block from $file"
  [ "$DRY" -eq 1 ] && return 0
  tmp="$(mktemp)"
  strip_block "$file" | awk '{l[NR]=$0} END{n=NR; while(n>0 && l[n]=="") n--; for(i=1;i<=n;i++) print l[i]}' > "$tmp"
  if [ -s "$tmp" ]; then mv "$tmp" "$file"; else rm -f "$tmp" "$file"; fi   # drop a file we created
}

# --- per-tool install -------------------------------------------------------

# has_content DIR: true when DIR holds real files (not only ignored junk such as .DS_Store).
has_content() { find "$1/" -type f ! -name .DS_Store 2>/dev/null | grep -q .; }

# prune_stale HOME: remove factory links whose target no longer exists
# (a skill or agent that was removed or renamed in the repository).
prune_stale() {
  local home="$1" l
  for l in "$home"/skills/* "$home"/agents/* "$home"/plugins/* "$home/policies" "$home/references"; do
    [ -L "$l" ] || continue
    case "$(readlink "$l")" in "$ROOT"/*)
      # Stale when the target is gone, or is a folder left behind with only
      # ignored junk (git removes tracked files but keeps files like .DS_Store).
      if [ ! -e "$l" ] || { [ -d "$l" ] && ! has_content "$l"; }; then
        act "prune stale link $l"; [ "$DRY" -eq 1 ] || rm -f "$l"
      fi ;;
    esac
  done
  return 0
}

link_shared() {
  local home="$1" d f
  mkdir -p "$home" 2>/dev/null || true
  prune_stale "$home"
  for d in "$ROOT"/skills/*/; do
    d="${d%/}"
    has_content "$d" || continue   # skip folders left behind after a skill was removed
    link_item "$d" "$home/skills/$(basename "$d")"
  done
  link_item "$ROOT/policies" "$home/policies"
  link_item "$ROOT/references" "$home/references"
  for f in "$ROOT"/agents/*.md "$ROOT"/agents/market/*.md; do
    [ -f "$f" ] && link_item "$f" "$home/agents/$(basename "$f")"
  done
  return 0
}

unlink_shared() {
  local home="$1" d f
  for d in "$ROOT"/skills/*/; do d="${d%/}"; unlink_item "$home/skills/$(basename "$d")"; done
  unlink_item "$home/policies"
  unlink_item "$home/references"
  for f in "$ROOT"/agents/*.md "$ROOT"/agents/market/*.md; do
    [ -f "$f" ] && unlink_item "$home/agents/$(basename "$f")"
  done
  if [ "$DRY" -eq 0 ]; then
    rmdir "$home/skills" "$home/agents" "$home/plugins" 2>/dev/null || true   # only if empty
  fi
  return 0
}

claude_settings_edit() {  # $1 = add|remove
  local settings hook_cmd
  settings="$(claude_home)/settings.json"
  hook_cmd="$ROOT/adapters/claude-code/deny-dangerous-hook.sh"
  if ! command -v python3 >/dev/null 2>&1; then
    warn "python3 not found; add this PreToolUse hook (matcher Bash) to $settings yourself: $hook_cmd"
    return 0
  fi
  [ "$1" = "remove" ] && [ ! -f "$settings" ] && return 0
  local present=0
  if [ -f "$settings" ] && grep -qF "$hook_cmd" "$settings"; then present=1; fi
  if [ "$1" = "add" ] && [ "$present" -eq 1 ]; then return 0; fi
  if [ "$1" = "remove" ] && [ "$present" -eq 0 ]; then return 0; fi
  act "$1 deny-dangerous hook in $settings"
  [ "$DRY" -eq 1 ] && return 0
  [ -f "$settings" ] && backup_file "$settings"
  mkdir -p "$(dirname "$settings")"
  python3 - "$settings" "$hook_cmd" "$1" <<'PY'
import json, os, sys
path, cmd, action = sys.argv[1], sys.argv[2], sys.argv[3]
data = {}
if os.path.exists(path) and os.path.getsize(path) > 0:
    with open(path) as f:
        data = json.load(f)
hooks = data.setdefault("hooks", {})
pre = hooks.setdefault("PreToolUse", [])
def has(entry):
    return any(h.get("command") == cmd for h in entry.get("hooks", []))
if action == "add":
    if not any(has(e) for e in pre):
        pre.append({"matcher": "Bash", "hooks": [{"type": "command", "command": cmd}]})
else:
    pre[:] = [e for e in pre if not has(e)]
    if not pre: hooks.pop("PreToolUse", None)
    if not hooks: data.pop("hooks", None)
with open(path, "w") as f:
    json.dump(data, f, indent=2); f.write("\n")
PY
}

factory_block() {  # $1 = tool
  local home; home="$(home_of "$1")"
  case "$1" in
    claude)
      echo "# Software Factory"
      echo "@$ROOT/instructions/AGENTS.md"
      echo "Factory skills, policies, and references are linked under \`$home\`."
      ;;
    *)
      echo "# Software Factory"
      echo
      sed '1{/^# /d;}' "$ROOT/instructions/AGENTS.md" | sed '1{/^$/d;}'
      echo
      echo "Factory skills are in \`$home/skills/<name>/SKILL.md\`. When a task matches a skill, read its SKILL.md and follow it."
      echo "Factory policies are in \`$home/policies/\` and shared references are in \`$home/references/\`."
      ;;
  esac
}

install_tool() {
  local tool="$1" home; home="$(home_of "$tool")"
  say ""; say "== $(label_of "$tool")  ($home)"
  link_shared "$home"
  case "$tool" in
    claude)
      write_block "$home/CLAUDE.md" "$(factory_block claude)"
      [ "$HOOKS" -eq 1 ] && claude_settings_edit add
      ;;
    opencode)
      write_block "$home/AGENTS.md" "$(factory_block opencode)"
      [ "$HOOKS" -eq 1 ] && link_item "$ROOT/plugins/deny-dangerous.ts" "$home/plugins/deny-dangerous.ts"
      ;;
    codex)
      write_block "$home/AGENTS.md" "$(factory_block codex)"
      say "  note: Codex has no agent-file or hook mechanism; agents and the command guard are not installed."
      ;;
  esac
  return 0
}

uninstall_tool() {
  local tool="$1" home; home="$(home_of "$tool")"
  say ""; say "== $(label_of "$tool")  ($home)"
  unlink_shared "$home"
  case "$tool" in
    claude) remove_block "$home/CLAUDE.md"; claude_settings_edit remove ;;
    opencode) remove_block "$home/AGENTS.md"; unlink_item "$home/plugins/deny-dangerous.ts" ;;
    codex) remove_block "$home/AGENTS.md" ;;
  esac
  return 0
}

# --- main -------------------------------------------------------------------

targets=""
if [ "$TOOL" = "auto" ] || [ "$TOOL" = "all" ] || [ "$TOOL" = "installed" ]; then
  for t in claude opencode codex; do
    if [ "$TOOL" = "all" ]; then targets="$targets $t"
    elif [ "$TOOL" = "installed" ]; then is_installed "$t" && targets="$targets $t"
    elif detected "$t"; then targets="$targets $t"; fi
  done
else
  targets="$TOOL"
fi

if [ -z "${targets// /}" ]; then
  if [ "$TOOL" = "installed" ]; then
    say "The factory is not installed in any tool yet. Run ./install.sh first."
  else
    say "No supported AI coding tool found (looked for Claude Code, OpenCode, Codex)."
    say "Install one, or force a target:  ./install.sh --tool claude|opencode|codex"
  fi
  exit 1
fi

verb="Install"; [ "$UNINSTALL" -eq 1 ] && verb="Uninstall"
say "Software Factory — $verb"
say "Factory location: $ROOT"
say "Tools:$(for t in $targets; do printf ' %s' "$(label_of "$t")"; done)"
[ "$DRY" -eq 1 ] && say "(dry run: nothing will be changed)"

if [ "$ASSUME_YES" -eq 0 ] && [ "$DRY" -eq 0 ] && [ -r /dev/tty ]; then
  printf "Continue? [Y/n] " >&2
  read -r reply < /dev/tty || reply=""
  case "$reply" in n|N|no|NO) say "Cancelled."; exit 0 ;; esac
fi

for t in $targets; do
  if [ "$UNINSTALL" -eq 1 ]; then uninstall_tool "$t"; else install_tool "$t"; fi
done

say ""
if [ "$UNINSTALL" -eq 0 ]; then
  command -v gitleaks >/dev/null 2>&1 || say "Tip: install gitleaks for the pre-commit secret scan (see hooks/gitleaks-setup-readme.md)."
  say "Done. Restart your AI tool to load the factory."
else
  say "Done. The factory links were removed. Repository files were not touched."
fi
[ "$WARNINGS" -gt 0 ] && say "$WARNINGS item(s) were skipped; see the lines marked with '!' above."
exit 0
