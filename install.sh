#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
INSTALL_DIR="${INSTALL_DIR:-/opt/homebrew/bin}"

# Install CLI tools
mkdir -p "$INSTALL_DIR"
for f in "$SCRIPT_DIR"/bin/*; do
  cp "$f" "$INSTALL_DIR/$(basename "$f")"
  chmod +x "$INSTALL_DIR/$(basename "$f")"
  echo "Installed $(basename "$f")"
done

# Install default workspace template (first install only)
WORKSPACE_DIR="${COWORK_WORKSPACE_DIR:-$HOME/.config/cocowork/workspace}"
if [[ ! -d "$WORKSPACE_DIR" ]]; then
  mkdir -p "$WORKSPACE_DIR"
  cp -r "$SCRIPT_DIR/workspace/"* "$WORKSPACE_DIR/"
  echo "Created default workspace at $WORKSPACE_DIR"
  echo "Set COWORK_WORKSPACE_DIR or use abg-open /path/to/project for other workspaces."
fi

echo "Done. Tools installed to $INSTALL_DIR"
