#!/usr/bin/env bash
set -e

APP_DIR="$HOME/.local/share/applications"
PROFILE_DIR="$HOME/.local/share/webapps"

mkdir -p "$APP_DIR"
mkdir -p "$PROFILE_DIR"

chmod 700 "$PROFILE_DIR"

create_webapp() {

  NAME="$1"
  URL="$2"
  ICON="$3"

  FILE_NAME=$(echo "$NAME" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
  APP_PROFILE="$PROFILE_DIR/$FILE_NAME"

  mkdir -p "$APP_PROFILE"

  cat >"$APP_DIR/$FILE_NAME.desktop" <<EOF
[Desktop Entry]
Name=$NAME
Exec=/usr/lib/chromium/chromium --user-data-dir=$APP_PROFILE --profile-directory=Default --app=$URL --class=$FILE_NAME --ozone-platform=wayland --enable-features=UseOzonePlatform,VaapiVideoDecoder --enable-gpu-rasterization --process-per-site --disable-background-networking --disable-sync --disable-component-update --disable-domain-reliability --disable-features=MediaRouter,OptimizationHints --force-dark-mode
Terminal=false
Type=Application
Categories=WebApp;
EOF

  echo "Created $NAME"
}

# create_webapp "YouTube Music" "https://music.youtube.com" "youtube-music"
# create_webapp "WhatsApp" "https://web.whatsapp.com" "whatsapp"
# create_webapp "Github" "https://github.com" "github"
# create_webapp "Gitlab" "https://gitlab.com" "gitlab"
# create_webapp "Codeberg" "https://codeberg.org" "codeberg"
# create_webapp "DevDocs" "https://devdocs.io" "devdocs"
# create_webapp "Instagram" "https://instagram.com" "instagram"
# create_webapp "Wikipedia" "https://en.wikipedia.org" "wikipedia"
# create_webapp "Twitch" "https://twitch.tv" "twitch"
# create_webapp "ArchWiki" "https://wiki.archlinux.org" "archwiki"
create_webapp "Tuta" "https://mail.tutanota.com/" "tuta"
# create_webapp "Proton" "https://account.proton.me" "proton"
# create_webapp "Raindrop" "https://app.raindrop.io/account" "raindrop"
# create_webapp "MonkeyType" "https://monkeytype.com" "monkeytype"
# create_webapp "WakaTime" "https://wakatime.com/dashboard" "wakatime"
# create_webapp "Dropbox" "https://www.dropbox.com/home" "dropbox"

update-desktop-database "$APP_DIR" || true

echo "Web apps installed!"
