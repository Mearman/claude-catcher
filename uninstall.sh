#!/bin/bash
set -e

BIN_DIR="$HOME/.local/bin"

# Remove symlinks
for cmd in claude-catcher stray-claude hang-claude; do
  if [ -L "$BIN_DIR/$cmd" ]; then
    rm "$BIN_DIR/$cmd"
    echo "  Removed $BIN_DIR/$cmd"
  fi
done

# Remove cron entry
if crontab -l 2>/dev/null | grep -q "claude-catcher"; then
  crontab -l 2>/dev/null | grep -v "claude-catcher" | crontab -
  echo "  Removed cron entry"
fi

echo ""
echo "Done. Log file at ~/.local/log/claude-catcher.log was left in place."
