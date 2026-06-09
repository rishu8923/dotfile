#!/usr/bin/env bash
set -uo pipefail

DOTFILES_DIR="${HOME}/dotfiles"
TARGET_DIR="${HOME}"

echo "==> Starting GNU Stow"

backup_if_exists() {
  local target="$1"

  if [ -e "$target" ] || [ -L "$target" ]; then
    local ts
    ts=$(date +%s)
    local backup="${target}.bak.${ts}"
    echo "Backing up: $target -> $backup"
    mv "$target" "$backup"
  fi
}

fix_absolute_symlinks() {
  echo "==> Fixing absolute symlinks"

  find "$DOTFILES_DIR" -type l | while read -r link; do
    target=$(readlink "$link")

    # only process absolute symlinks
    [[ "$target" != /* ]] && continue

    if [ ! -e "$target" ]; then
      echo "Removing broken symlink: $link -> $target"
      rm "$link"
      continue
    fi

    echo "Converting: $link -> $target"

    rel_target=$(realpath --relative-to="$(dirname "$link")" "$target") || {
      echo "Skipping (realpath failed): $link"
      continue
    }

    rm "$link"
    ln -s "$rel_target" "$link"
  done
}

handle_conflicts() {
  echo "==> Scanning for conflicts"

  stow -nvt "$TARGET_DIR" . 2>&1 | while read -r line; do

    if [[ "$line" =~ existing\ target\ is\ not\ owned\ by\ stow:\ (.*)$ ]]; then
      backup_if_exists "${TARGET_DIR}/${BASH_REMATCH[1]}"

    elif [[ "$line" =~ cannot\ stow.*over\ existing\ target\ (.*)\ since ]]; then
      backup_if_exists "${TARGET_DIR}/${BASH_REMATCH[1]}"

    fi

  done
}

# ---- EXECUTION FLOW ----

fix_absolute_symlinks

handle_conflicts

echo "==> Running stow"
stow -vt "$TARGET_DIR" .

echo "==> Done"
