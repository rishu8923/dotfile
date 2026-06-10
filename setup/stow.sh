#!/usr/bin/env bash
set -uo pipefail

# Resolve the dotfiles root (one level up from this script's directory)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${HOME}"

echo "==> Dotfiles dir: $DOTFILES_DIR"
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

  # Store patterns in variables — inline backslash-space inside [[ =~ ]] causes
  # a bash syntax error on some versions; variable form is always safe.
  local pat_not_owned='existing target is not owned by stow: (.*)$'
  local pat_cannot_stow='cannot stow.*over existing target (.*) since'

  cd "$DOTFILES_DIR"
  stow -nvt "$TARGET_DIR" . 2>&1 | while read -r line; do

    if [[ "$line" =~ $pat_not_owned ]]; then
      backup_if_exists "${TARGET_DIR}/${BASH_REMATCH[1]}"

    elif [[ "$line" =~ $pat_cannot_stow ]]; then
      backup_if_exists "${TARGET_DIR}/${BASH_REMATCH[1]}"

    fi

  done
}

# ---- EXECUTION FLOW ----

fix_absolute_symlinks

handle_conflicts

echo "==> Running stow"
cd "$DOTFILES_DIR"
stow -vt "$TARGET_DIR" .

echo "==> Done"
