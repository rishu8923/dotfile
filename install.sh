#!/usr/bin/env bash
set -e

trap 'echo "Installation failed at line $LINENO"' ERR

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
CACHE="$HOME/.cache/hellwal"
LOG="$DOTFILES_DIR/setup.log"

exec > >(tee -a "$LOG") 2>&1

echo "Starting installation..."

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

chmod +x "$SCRIPT_DIR"/setup/*.sh

# bash "$SCRIPT_DIR/setup/update.sh"

# bash "$SCRIPT_DIR/setup/uninstall.sh"
bash "$SCRIPT_DIR/setup/makepkg.sh"
# bash "$SCRIPT_DIR/setup/pacman.sh"

# bash "$SCRIPT_DIR/setup/yay.sh"
# bash "$SCRIPT_DIR/setup/aur.sh"

# bash "$SCRIPT_DIR/setup/ufw.sh"
bash "$SCRIPT_DIR/setup/dns.sh"
bash "$SCRIPT_DIR/setup/apparmor.sh"
bash "$SCRIPT_DIR/setup/firejail.sh"
bash "$SCRIPT_DIR/setup/kvm.sh"

bash "$SCRIPT_DIR/setup/screenshot.sh"
bash "$SCRIPT_DIR/setup/screenrecord.sh"
bash "$SCRIPT_DIR/setup/enviroment_d.sh"
# bash "$SCRIPT_DIR/setup/webapps.sh"
bash "$SCRIPT_DIR/setup/stow.sh"
bash "$SCRIPT_DIR/setup/symlinks.sh"
bash "$SCRIPT_DIR/setup/librewolf.sh"

echo "Installation Complete :)"
