#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/.local/bin"
CRON_SCHEDULE="*/5 * * * *"
CRON_CMD="$BIN_DIR/claude-catcher --kill --notify --quiet"

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

# Cron setup
echo ""
read -p "Install cron job to auto-kill strays every 5 minutes? [y/N] " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  # Remove any existing claude-catcher cron entry, then add new one
  (crontab -l 2>/dev/null | grep -v "claude-catcher"; echo "$CRON_SCHEDULE $CRON_CMD") | crontab -
  echo "  Cron installed: $CRON_SCHEDULE $CRON_CMD"
else
  echo "  Skipped cron setup. Run manually or add later:"
  echo "  $CRON_SCHEDULE $CRON_CMD"
fi

echo ""
echo "Done."
