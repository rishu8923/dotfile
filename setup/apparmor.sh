#!/usr/bin/env bash
set -e

echo "Enabling AppArmor service..."
sudo systemctl enable --now apparmor

echo "Adding kernel parameters for AppArmor..."

if [ -d /boot/loader/entries ]; then
  for entry in /boot/loader/entries/*.conf; do
    if ! grep -q "apparmor=1" "$entry"; then
      echo "Patching $entry"
      sudo sed -i 's/^options \(.*\)$/options \1 apparmor=1 security=apparmor/' "$entry"
    fi
  done
else
  echo "systemd-boot entries not found."
fi

echo "Enforcing Firejail AppArmor profile..."
sudo aa-enforce firejail-default || true

if ! grep -q "apparmor=1" /proc/cmdline; then
  echo "AppArmor kernel parameters added."
  echo "Reboot required for AppArmor to activate."
fi

echo "AppArmor setup complete."
