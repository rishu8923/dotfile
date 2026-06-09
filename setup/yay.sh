#!/usr/bin/env bash
set -e

if command -v yay >/dev/null; then
  echo "yay already installed :)"
  exit 0
fi

echo "Installing yay..."

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay
