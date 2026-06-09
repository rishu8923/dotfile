#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mapfile -t packages < <(
  grep -vE '^\s*(#|$)' "$SCRIPT_DIR/uninstall_packages.txt" |
    sed 's/\s*$//' |
    while read -r pkg; do
      pacman -Q "$pkg" &>/dev/null && echo "$pkg"
    done
)

if [ ${#packages[@]} -eq 0 ]; then
  echo "No valid packages to remove"
  exit 0
fi

echo "Removing: ${packages[*]}"
sudo pacman -Rs --noconfirm "${packages[@]}"
