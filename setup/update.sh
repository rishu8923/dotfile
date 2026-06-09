#!/usr/bin/env bash
set -e

echo "Updating system..."

if [ -f /var/lib/pacman/db.lck ]; then
  echo "Pacman lock detected. Removing stale lock..."
  sudo rm -f /var/lib/pacman/db.lck
fi

sudo pacman -Syu --noconfirm
