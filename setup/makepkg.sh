#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FILE="$SCRIPT_DIR/makepkg.conf"
TARGET_FILE="/etc/makepkg.conf"

if [[ ! -f "$SOURCE_FILE" ]]; then
  echo "Error: $SOURCE_FILE not found"
  exit 1
fi

echo "Backing up existing makepkg.conf..."
sudo cp "$TARGET_FILE" "$TARGET_FILE.bak.$(date +%Y%m%d-%H%M%S)"

echo "Installing custom makepkg.conf..."
sudo cp "$SOURCE_FILE" "$TARGET_FILE"

echo "makepkg.conf successfully installed."
