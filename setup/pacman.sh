#!/usr/bin/env bash
set -e

echo "Installing pacman packages..."

mapfile -t packages < <(grep -vE '^\s*(#|$)' setup/pacman-packages.txt)

sudo pacman -S --needed --noconfirm "${packages[@]}"

echo "Installed pacman packages"
