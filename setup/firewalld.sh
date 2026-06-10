#!/usr/bin/env bash
# setup/firewalld.sh — replace UFW with firewalld, configure zones
set -euo pipefail

echo "==> Removing UFW"
sudo systemctl stop ufw 2>/dev/null || true
sudo systemctl disable ufw 2>/dev/null || true
# Remove but don't error if not installed
sudo pacman -Rns --noconfirm ufw 2>/dev/null || true

echo "==> Installing firewalld"
sudo pacman -S --noconfirm --needed firewalld

echo "==> Starting firewalld"
sudo systemctl enable --now firewalld

# ── Zone layout ───────────────────────────────────────────────────────────────
# default zone: public  — wifi/ethernet (deny inbound, allow outbound)
# vpn    zone: (auto-assigned to wg-* interfaces by wg-quick via config hooks)
#              allows traffic that comes out of the WireGuard tunnel
# drop   zone: for anything unknown (hard drop)

echo "==> Configuring public zone (default)"
sudo firewall-cmd --set-default-zone=public --permanent

# Allow DHCP client so you can get an IP address
sudo firewall-cmd --zone=public --add-service=dhcpv6-client --permanent

# Block all unsolicited inbound; allow established outbound (firewalld default)
sudo firewall-cmd --zone=public --remove-service=ssh --permanent 2>/dev/null || true
sudo firewall-cmd --zone=public --remove-service=mdns --permanent 2>/dev/null || true

echo "==> Creating vpn zone for WireGuard interfaces"
sudo firewall-cmd --new-zone=vpn --permanent 2>/dev/null || true

# Anything coming out of the WireGuard tunnel is trusted within that tunnel
sudo firewall-cmd --zone=vpn --set-target=ACCEPT --permanent

# Allow DNS inside VPN zone (ProtonVPN sends DNS through the tunnel)
sudo firewall-cmd --zone=vpn --add-service=dns --permanent

echo "==> Enabling masquerade (needed for WireGuard routing)"
sudo firewall-cmd --zone=public --add-masquerade --permanent

echo "==> Applying all changes"
sudo firewall-cmd --reload

echo "==> Current zone summary:"
sudo firewall-cmd --list-all-zones | grep -A6 "^public\|^vpn\|^drop"

echo ""
echo "==> firewalld setup complete."
echo "    WireGuard kill-switch is handled by PostUp/PreDown in each .conf"
echo "    (added by setup/wireguard.sh)."
