#!/usr/bin/env bash
set -e

sudo pacman -Rns --noconfirm swaylock || true

echo "Installing AUR packages..."

yay -S --needed --noconfirm - <setup/aur-packages.txt
grep -vE "^\s*(#|$)" setup/aur-packages.txt | xargs yay -S --needed --noconfirm
