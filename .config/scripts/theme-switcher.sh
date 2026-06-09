#!/usr/bin/env bash
set -euo pipefail

THEMES_DIR="$HOME/.config/themes"
HELLWAL_DIR="$HOME/.config/hellwal/themes"
CACHE_DIR="$HOME/.cache/hellwal"
LAST_THEME_FILE="$CACHE_DIR/last-theme"
CURRENT_WALL="$THEMES_DIR/current/wallpaper.png"

SCRIPT_DIR="$HOME/.config/scripts"

mkdir -p "$CACHE_DIR"

list_themes() {
  for hw in "$HELLWAL_DIR"/*.hellwal; do
    name=$(basename "$hw" .hellwal)
    if [ -f "$THEMES_DIR/$name/wallpaper.png" ]; then
      echo "$name"
    fi
  done
}

apply_hellwal() {
  hellwal -t "$HELLWAL_DIR/$1.hellwal"
}

apply_wallpaper() {
  ln -sf "$THEMES_DIR/$1/wallpaper.png" "$CURRENT_WALL"
}

reload_services() {
  swaymsg reload >/dev/null
  pkill -USR2 waybar 2>/dev/null || true
  pkill mako 2>/dev/null || true
  mako &
  disown
}

notify_theme() {
  notify-send "Theme applied" "$1" -u low
}

is_light_theme() {
  case "$1" in
  *light* | *latte* | *lotus*)
    return 0
    ;;
  *)
    return 1
    ;;
  esac
}

apply_app_theme() {
  if is_light_theme "$1"; then
    "$SCRIPT_DIR/light-theme.sh"
  else
    "$SCRIPT_DIR/dark-theme.sh"
  fi
}

theme=$(list_themes | wofi --dmenu --prompt "Theme")
[ -z "$theme" ] && exit 0

if [ -f "$LAST_THEME_FILE" ] && grep -qx "$theme" "$LAST_THEME_FILE"; then
  exit 0
fi

apply_hellwal "$theme"
apply_wallpaper "$theme"
apply_app_theme "$theme"

echo "$theme" >"$LAST_THEME_FILE"

reload_services
notify_theme "$theme"
