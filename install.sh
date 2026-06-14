#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
INSTALL_DIR="${INSTALL_DIR:-/opt/homebrew/bin}"
mkdir -p "$INSTALL_DIR"
for f in "$SCRIPT_DIR"/bin/*; do
  cp "$f" "$INSTALL_DIR/$(basename "$f")"
  chmod +x "$INSTALL_DIR/$(basename "$f")"
  echo "Installed $(basename "$f")"
done
echo "Done. Tools installed to $INSTALL_DIR"
