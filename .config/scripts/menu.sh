#!/usr/bin/env bash
set -euo pipefail

# robust path resolution (works in wofi, keybinds, symlinks, etc.)
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]:-$0}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
SELF_NAME="$(basename "$SCRIPT_PATH")"

declare -A LABEL_TO_SCRIPT
menu_entries=()

list_scripts() {
  find "$SCRIPT_DIR" -maxdepth 1 -type f -name "*.sh" ! -name "$SELF_NAME"
}

extract_label() {
  local file="$1"
  local line label

  line=$(grep -m1 '^# *MENU_LABEL=' "$file" 2>/dev/null || true)

  if [[ -n "$line" ]]; then
    sed -E 's/^# *MENU_LABEL="(.*)"/\1/' <<<"$line"
  else
    basename "$file" .sh | sed -E 's/[_-]+/ /g; s/\b(.)/\U\1/g'
  fi
}

# build menu (no subshell issues)
while IFS= read -r script; do
  label=$(extract_label "$script")

  # skip duplicates
  if [[ -n "${LABEL_TO_SCRIPT[$label]:-}" ]]; then
    continue
  fi

  LABEL_TO_SCRIPT["$label"]="$script"
  menu_entries+=("$label")
done < <(list_scripts | sort)

# guard
if [[ ${#menu_entries[@]} -eq 0 ]]; then
  notify-send "menu.sh" "No scripts found in $SCRIPT_DIR" -u critical
  exit 1
fi

choice=$(printf "%s\n" "${menu_entries[@]}" | wofi --dmenu --prompt "Scripts")
[[ -z "$choice" ]] && exit 0

script_path="${LABEL_TO_SCRIPT[$choice]}"

if [[ ! -f "$script_path" ]]; then
  notify-send "menu.sh" "Invalid selection" -u critical
  exit 1
fi

chmod +x "$script_path"
notify-send "Running script" "$choice" -u low

exec bash "$script_path"
