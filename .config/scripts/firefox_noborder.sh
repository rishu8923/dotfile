#!/usr/bin/env bash
set -euo pipefail

echo "==> Firefox setup (dotfiles mode)"

DOTFILES_DIR="$HOME/dotfiles/setup"
USERJS_SOURCE="$DOTFILES_DIR/user.js"

if [[ ! -f "$USERJS_SOURCE" ]]; then
  echo "Error: $USERJS_SOURCE not found"
  exit 1
fi

# include Flatpak + standard locations
CANDIDATE_DIRS=(
  "$HOME/.mozilla/firefox"
  "$HOME/.config/firefox"
  "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox"
)

find_config_dir() {
  for dir in "${CANDIDATE_DIRS[@]}"; do
    [[ -d "$dir" ]] || continue

    if [[ -f "$dir/profiles.ini" ]]; then
      echo "$dir"
      return 0
    fi
  done
  return 1
}

CONFIG_DIR=$(find_config_dir || true)

# fallback: brute-force search
if [[ -z "${CONFIG_DIR:-}" ]]; then
  CONFIG_DIR=$(find "$HOME" -type f -name "profiles.ini" 2>/dev/null |
    head -n1 | xargs -r dirname || true)
fi

if [[ -z "${CONFIG_DIR:-}" ]]; then
  echo "Error: Could not locate Firefox config directory"
  exit 1
fi

echo "==> Config dir: $CONFIG_DIR"

PROFILES_INI="$CONFIG_DIR/profiles.ini"

# try normal parsing first
PROFILE_PATH=""
if [[ -f "$PROFILES_INI" ]]; then
  PROFILE_PATH=$(awk -F= '
    /^\[Install/ {found=1}
    found && /^Default=/ {print $2; exit}
  ' "$PROFILES_INI")

  if [[ -z "$PROFILE_PATH" ]]; then
    PROFILE_PATH=$(awk -F= '
      /^\[Profile/ {path=""; def=0}
      /^Path=/ {path=$2}
      /^Default=1/ {def=1}
      path && def {print path; exit}
    ' "$PROFILES_INI")
  fi
fi

# fallback: direct directory search (more reliable)
if [[ -z "$PROFILE_PATH" ]]; then
  echo "Falling back to directory scan..."

  PROFILE_PATH=$(find "$CONFIG_DIR" -maxdepth 1 -type d \
    \( -name "*.default*" -o -name "*.release*" \) \
    -printf "%T@ %f\n" | sort -nr | head -n1 | cut -d' ' -f2)
fi

if [[ -z "$PROFILE_PATH" ]]; then
  echo "Error: No profile found"
  exit 1
fi

# resolve absolute path
if [[ "$PROFILE_PATH" = /* ]]; then
  PROFILE_DIR="$PROFILE_PATH"
else
  PROFILE_DIR="$CONFIG_DIR/$PROFILE_PATH"
fi

if [[ ! -d "$PROFILE_DIR" ]]; then
  echo "Error: Profile directory missing: $PROFILE_DIR"
  exit 1
fi

echo "==> Using profile: $PROFILE_DIR"

# backup existing user.js if needed
if [[ -f "$PROFILE_DIR/user.js" && ! -L "$PROFILE_DIR/user.js" ]]; then
  echo "Backing up existing user.js"
  mv "$PROFILE_DIR/user.js" "$PROFILE_DIR/user.js.bak"
fi

echo "==> Linking user.js"
ln -sf "$USERJS_SOURCE" "$PROFILE_DIR/user.js"

mkdir -p "$PROFILE_DIR/chrome"

cat >"$PROFILE_DIR/chrome/userChrome.css" <<'EOF'
*,
*::before,
*::after {
  border-radius: 0 !important;
}

#TabsToolbar {
  display: none !important;
}

.titlebar-close,
.titlebar-min,
.titlebar-max {
  display: none !important;
}
EOF

cat >"$PROFILE_DIR/chrome/userContent.css" <<'EOF'
*,
*::before,
*::after {
  border-radius: 0 !important;
}
EOF

echo "==> Firefox configured successfully"
