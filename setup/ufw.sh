#!/usr/bin/env bash
set -e

echo "Configuring firewall rules..."

sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow OpenSSH 2>/dev/null || true

echo "Enabling UFW..."

sudo systemctl enable --now ufw
sudo ufw --force enable

# echo "Firewall status:"
# sudo ufw status verbose

echo "UFW setup complete."
