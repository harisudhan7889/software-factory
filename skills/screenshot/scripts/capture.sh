#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_DIR="${SF_SCREENSHOT_RUNTIME_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/software-factory/screenshot-runtime}"
PLAYWRIGHT_VERSION="${PLAYWRIGHT_VERSION:-1.63.0}"
export SF_SCREENSHOT_RUNTIME_DIR="$RUNTIME_DIR"

# Fast path: --help must not install anything.
for arg in "$@"; do
  if [[ "$arg" == "--help" || "$arg" == "-h" ]]; then
    exec node "$SCRIPT_DIR/capture.mjs" --help
  fi
done

command -v node >/dev/null 2>&1 || { echo "Status: BLOCKED"; echo "Reason: Node.js is required."; exit 2; }
command -v npm >/dev/null 2>&1 || { echo "Status: BLOCKED"; echo "Reason: npm is required."; exit 2; }

node_major="$(node -p 'Number(process.versions.node.split(".")[0])')"
(( node_major >= 20 )) || { echo "Status: BLOCKED"; echo "Reason: Node.js 20+ is required."; exit 2; }

mkdir -p "$RUNTIME_DIR"

if [[ ! -f "$RUNTIME_DIR/package.json" ]]; then
  cat > "$RUNTIME_DIR/package.json" <<'JSON'
{
  "name": "software-factory-screenshot-runtime",
  "private": true,
  "version": "1.0.0"
}
JSON
fi

if [[ ! -x "$RUNTIME_DIR/node_modules/.bin/playwright" ]]; then
  echo "Installing Playwright $PLAYWRIGHT_VERSION..."
  (
    cd "$RUNTIME_DIR"
    npm install --no-save --no-package-lock --no-audit --no-fund "playwright@$PLAYWRIGHT_VERSION"
  )
fi

installed_version="$(node -e 'console.log(require(process.argv[1]).version)' \
  "$RUNTIME_DIR/node_modules/playwright/package.json" 2>/dev/null || true)"
if [[ "$installed_version" != "$PLAYWRIGHT_VERSION" ]]; then
  echo "Status: BLOCKED"
  echo "Reason: Factory Playwright version mismatch. Expected $PLAYWRIGHT_VERSION, found ${installed_version:-unknown}."
  echo "Delete $RUNTIME_DIR/node_modules and rerun."
  exit 2
fi

BROWSERS_DIR="${PLAYWRIGHT_BROWSERS_PATH:-$RUNTIME_DIR/browsers}"
export PLAYWRIGHT_BROWSERS_PATH="$BROWSERS_DIR"
export PLAYWRIGHT_SKIP_BROWSER_GC=1
mkdir -p "$BROWSERS_DIR"

if ! find "$BROWSERS_DIR" -maxdepth 2 -type d -name 'chromium-*' -print -quit 2>/dev/null | grep -q .; then
  echo "Installing Chromium for Playwright $PLAYWRIGHT_VERSION..."
  "$RUNTIME_DIR/node_modules/.bin/playwright" install chromium
fi

exec node "$SCRIPT_DIR/capture.mjs" "$@"
