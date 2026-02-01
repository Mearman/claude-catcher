#!/bin/sh
set -e

REPO="https://github.com/Mearman/claude-catcher"
DEST="$HOME/.claude-catcher"

if [ -d "$DEST" ]; then
  echo "Updating $DEST..."
  git -C "$DEST" pull --ff-only
else
  echo "Cloning to $DEST..."
  git clone "$REPO" "$DEST"
fi

"$DEST/claude-catcher" install --no-config

echo ""
echo "Run 'claude-catcher config' to set up the cron job."
