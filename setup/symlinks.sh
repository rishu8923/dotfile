#!/bin/bash
set -euo pipefail

CONFIG_DIR="$HOME/.config"
CACHE_DIR="$HOME/.cache/hellwal"
HELLWAL_THEMES="$CONFIG_DIR/hellwal/themes"

# ── CHANGE THIS to your preferred default theme ──────────────────────────────
DEFAULT_THEME="gruvbox-material"
# ─────────────────────────────────────────────────────────────────────────────

mkdir -p "$CONFIG_DIR/wofi"
mkdir -p "$CONFIG_DIR/mako"
mkdir -p "$CONFIG_DIR/zathura"
mkdir -p "$CONFIG_DIR/themes/current"
mkdir -p "$CACHE_DIR"

echo "Creating symlinks..."

ln -sf "$CACHE_DIR/wofi.css"         "$CONFIG_DIR/wofi/style.css"
ln -sf "$CACHE_DIR/mako"             "$CONFIG_DIR/mako/config"
ln -sf "$CACHE_DIR/zathura-colors"   "$CONFIG_DIR/zathura/zathura-colors"
ln -sf "$CACHE_DIR/waybar-colors.css" "$CONFIG_DIR/waybar/colors.css"

echo "Symlinks created."

# ── Determine which theme to initialise with ──────────────────────────────────
if [ -f "$CACHE_DIR/last-theme" ] && [ -n "$(cat "$CACHE_DIR/last-theme")" ]; then
  INITIAL_THEME=$(cat "$CACHE_DIR/last-theme")
  echo "Restoring previous theme: $INITIAL_THEME"
else
  INITIAL_THEME="$DEFAULT_THEME"
  echo "No previous theme found; using default: $INITIAL_THEME"
fi

# ── Set the wallpaper symlink ─────────────────────────────────────────────────
WALL_SRC="$CONFIG_DIR/themes/$INITIAL_THEME/wallpaper.png"
if [ -f "$WALL_SRC" ] && [ -s "$WALL_SRC" ]; then
  ln -sf "$WALL_SRC" "$CONFIG_DIR/themes/current/wallpaper.png"
  echo "Wallpaper set to: $INITIAL_THEME"
else
  echo "WARNING: Wallpaper for '$INITIAL_THEME' not found at $WALL_SRC"
  echo "         Place your wallpaper image there and re-run this script."
fi

# ── Run hellwal to pre-generate the colour cache ──────────────────────────────
# This ensures waybar/mako/alacritty etc. have colours on first boot.
if command -v hellwal >/dev/null 2>&1; then
  THEME_FILE="$HELLWAL_THEMES/$INITIAL_THEME.hellwal"
  if [ -f "$THEME_FILE" ]; then
    echo "Initialising hellwal with theme: $INITIAL_THEME"
    hellwal --theme "$INITIAL_THEME" >/dev/null 2>&1 || \
      echo "WARNING: hellwal exited non-zero; colours may not be generated yet."
    echo "$INITIAL_THEME" > "$CACHE_DIR/last-theme"
  else
    echo "WARNING: hellwal theme file not found: $THEME_FILE"
    echo "         Run 'hellwal --theme $INITIAL_THEME' manually after install."
  fi
else
  echo "WARNING: hellwal not found; install it and run 'hellwal --theme $INITIAL_THEME'."
fi

echo "Symlink setup complete."
