#!/usr/bin/env bash
set -euo pipefail

# Software Factory brand/design-system scanner.
# Read-only. No network. No file writes.

ROOT="${1:-.}"

if [ ! -d "$ROOT" ]; then
  echo "ERROR: Project path does not exist: $ROOT" >&2
  exit 1
fi

cd "$ROOT"

ROOT_DIR="$(pwd)"

echo "BRAND SCAN"
echo "Project: $ROOT_DIR"
echo

find_file() {
  local pattern="$1"
  find . \
    -path './.git' -prune -o \
    -path './node_modules' -prune -o \
    -path './dist' -prune -o \
    -path './build' -prune -o \
    -path './.next' -prune -o \
    -path './vendor' -prune -o \
    -type f -name "$pattern" -print 2>/dev/null | head -20
}

find_dir() {
  local path="$1"
  if [ -d "$path" ]; then
    printf '%s\n' "$path"
  fi
}

print_paths() {
  local label="$1"
  shift
  local found=0
  for path in "$@"; do
    [ -n "$path" ] || continue
    printf '%s\n' "$path"
    found=1
  done
  if [ "$found" -eq 0 ]; then
    echo "MISSING"
  fi
}

echo "## Design Tokens"
token_paths=()
while IFS= read -r p; do token_paths+=("$p"); done < <(
  {
    find_file 'tailwind.config.*'
    find_file 'tokens*.json'
    find . -type f \( -path '*/src/*/index.css' -o -path '*/src/*/globals.css' -o -path '*/src/index.css' -o -path '*/src/globals.css' \) \
      -not -path './.git/*' -not -path '*/node_modules/*' 2>/dev/null | head -30
  } | sort -u
)
print_paths "Design tokens:" "${token_paths[@]}"

echo
echo "## Typography"
font_files=()
while IFS= read -r p; do font_files+=("$p"); done < <(
  {
    find . -type f \( -name '*.css' -o -name '*.scss' -o -name '*.html' -o -name '*.htm' \) \
      -not -path './.git/*' -not -path '*/node_modules/*' \
      -print 2>/dev/null | head -200
  } | sort -u
)
font_hits=()
if [ "${#font_files[@]}" -gt 0 ]; then
  while IFS= read -r line; do
    [ -n "$line" ] && font_hits+=("$line")
  done < <(
    grep -EHi 'fonts\.googleapis\.com|font-family[[:space:]]*:|fontFamily[[:space:]]*[:=]' "${font_files[@]}" 2>/dev/null \
      | head -30 || true
  )
fi
if [ "${#font_hits[@]}" -eq 0 ]; then
  echo "MISSING"
else
  printf '%s\n' "${font_hits[@]}"
fi

echo
echo "## Colors / Theme Signals"
color_hits=()
theme_files=()
while IFS= read -r p; do theme_files+=("$p"); done < <(
  {
    find . -type f \( -name '*.css' -o -name 'tailwind.config.*' \) \
      -not -path './.git/*' -not -path '*/node_modules/*' \
      -print 2>/dev/null | head -200
  } | sort -u
)
if [ "${#theme_files[@]}" -gt 0 ]; then
  while IFS= read -r line; do
    [ -n "$line" ] && color_hits+=("$line")
  done < <(
    grep -EHi -- '(:root|--primary[[:space:]]*:|--background[[:space:]]*:|--radius[[:space:]]*:|colors[[:space:]]*:|backgroundColor[[:space:]]*:)' "${theme_files[@]}" 2>/dev/null \
      | head -50 || true
  )
fi
if [ "${#color_hits[@]}" -eq 0 ]; then
  echo "MISSING"
else
  printf '%s\n' "${color_hits[@]}"
fi

echo
echo "## Components"
component_paths=()
if [ -f "components.json" ]; then
  component_paths+=("components.json")
fi
while IFS= read -r p; do component_paths+=("$p"); done < <(
  find . -type d -path '*/src/components/ui' \
    -not -path './.git/*' -not -path '*/node_modules/*' \
    -print 2>/dev/null | head -20
)
print_paths "Component signals:" "${component_paths[@]}"

ui_count=0
while IFS= read -r p; do
  count="$(find "$p" -type f -not -path '*/node_modules/*' 2>/dev/null | wc -l | tr -d ' ')"
  echo "$p -> $count files"
  ui_count=$((ui_count + 1))
done < <(
  find . -type d -path '*/src/components/ui' \
    -not -path './.git/*' -not -path '*/node_modules/*' \
    -print 2>/dev/null | head -20
)

if [ "$ui_count" -eq 0 ] && [ ! -f "components.json" ]; then
  echo "No common component-library markers found."
fi

if [ -f "package.json" ]; then
  echo "package.json: PRESENT"
  deps="$(grep -E '"(@?radix-ui/|shadcn|tailwind|lucide-react|antd|mui|chakra|mantine|bootstrap)' package.json 2>/dev/null | head -20 || true)"
  if [ -n "$deps" ]; then
    echo "UI-related dependency signals:"
    printf '%s\n' "$deps"
  fi
else
  echo "package.json: MISSING"
fi

echo
echo "## Brand Assets"
asset_hits=()
if [ -d "public" ]; then
  while IFS= read -r p; do
    base="$(basename "$p")"
    case "$base" in
      *logo*|*Logo*|*LOGO*|*favicon*|*Favicon*|*og-image*|*og_image*|*brand*|*Brand*)
        asset_hits+=("$p")
        ;;
    esac
  done < <(
    find public -maxdepth 3 -type f \
      -not -path '*/node_modules/*' \
      -print 2>/dev/null | head -300
  )
fi
print_paths "Likely brand assets:" "${asset_hits[@]}"
if [ -d "public" ]; then
  echo "public/: PRESENT"
else
  echo "public/: MISSING"
fi

echo
echo "## Design Documentation"
doc_hits=()
while IFS= read -r p; do doc_hits+=("$p"); done < <(
  {
    find . -type f \( -iname 'DESIGN*.md' -o -iname 'brand*.md' -o -iname 'style-guide*.md' \) \
      -not -path './.git/*' -not -path '*/node_modules/*'
    find . -type d -path '*/docs/design*' \
      -not -path './.git/*' -not -path '*/node_modules/*'
    find . -type f \( -name '*.stories.*' -o -name '*.story.*' \) \
      -not -path './.git/*' -not -path '*/node_modules/*'
    find . -type d -name '.storybook' \
      -not -path './.git/*' -not -path '*/node_modules/*'
  } 2>/dev/null | sort -u | head -50
)
if [ "${#doc_hits[@]}" -eq 0 ]; then
  echo "MISSING"
else
  printf '%s\n' "${doc_hits[@]}"
fi

echo
if [ "${#token_paths[@]}" -eq 0 ] \
  && [ "${#font_hits[@]}" -eq 0 ] \
  && [ "${#color_hits[@]}" -eq 0 ] \
  && [ "${#component_paths[@]}" -eq 0 ] \
  && [ "${#asset_hits[@]}" -eq 0 ] \
  && [ "${#doc_hits[@]}" -eq 0 ]; then
  echo "No obvious brand files found — inspect existing component and inline styles."
fi

echo
echo "Scan complete. Discovery only; no design decisions made."
