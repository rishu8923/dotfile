#!/usr/bin/env bash
set -e

CONFIG_FILE="/etc/systemd/resolved.conf"

echo "Backing up existing config..."

sudo cp "$CONFIG_FILE" "$CONFIG_FILE.bak.$(date +%s)"

echo "Appling DNS configuration..."

sudo sed -i 's/^#DNS=.*/DNS=1.1.1.1 1.0.0.1/' $CONFIG_FILE
sudo sed -i 's/^#DNSOverTLS=.*/DNSOverTLS=yes/' $CONFIG_FILE
sudo sed -i 's/^#DNSSEC=.*/DNSSEC=yes/' $CONFIG_FILE

sudo systemctl restart systemd-resolved

echo "DNS configuration applied."
echo "Current DNS status:"
resolvectl status | grep -E 'DNS Servers|DNSSEC|DNSOverTLS'
