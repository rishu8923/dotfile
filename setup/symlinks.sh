#!/bin/bash
set -euo pipefail

CONFIG_DIR="$HOME/.config"
CACHE_DIR="$HOME/.cache/hellwal"

mkdir -p "$CONFIG_DIR/wofi"
mkdir -p "$CONFIG_DIR/mako"
mkdir -p "$CONFIG_DIR/zathura"
mkdir -p "$CONFIG_DIR/themes/current"

echo "Creating symlinks..."

ln -sf "$CACHE_DIR/wofi.css" "$CONFIG_DIR/wofi/style.css"
ln -sf "$CACHE_DIR/mako" "$CONFIG_DIR/mako/config"
ln -sf "$CACHE_DIR/zathura-colors" "$CONFIG_DIR/zathura/zathura-colors"
ln -sf "$HOME/.config/themes/gruvbox-material/wallpaper.png" "$CONFIG_DIR/themes/current/wallpaper.png"
ln -sf "$CACHE_DIR/waybar-colors.css" "$CONFIG_DIR/waybar/colors.css"

echo "Symlinks created."
