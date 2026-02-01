#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

# Symlink commands
for cmd in claude-catcher stray-claude hang-claude; do
  ln -sf "$REPO_DIR/bin/$cmd" "$BIN_DIR/$cmd"
  echo "  $BIN_DIR/$cmd → $REPO_DIR/bin/$cmd"
done

# Check PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  echo ""
  echo "WARNING: $BIN_DIR is not on your PATH."
  echo "Add this to your shell config:"
  echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# Cron setup via config command
echo ""
"$REPO_DIR/bin/claude-catcher" config

echo ""
echo "Done."
