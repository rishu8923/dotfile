#!/usr/bin/env bash
# setup/wireguard.sh — install WireGuard configs + sudoers rule
set -euo pipefail

# ── Where your ProtonVPN configs live (adjust if different) ──────────────────
WG_SRC="${WG_SOURCE_DIR:-$HOME/Downloads/wireguard/main-wireguard}"
WG_TARGET="/etc/wireguard"

# ── Validate source ───────────────────────────────────────────────────────────
if [ ! -d "$WG_SRC" ]; then
  echo "ERROR: WireGuard config dir not found: $WG_SRC"
  echo "       Set WG_SOURCE_DIR env var to point at your .conf files."
  exit 1
fi

conf_count=$(find "$WG_SRC" -maxdepth 1 -name "*.conf" | wc -l)
if [ "$conf_count" -eq 0 ]; then
  echo "ERROR: No .conf files found in $WG_SRC"
  exit 1
fi

echo "==> Installing $conf_count WireGuard configs to $WG_TARGET"

# ── Copy configs ──────────────────────────────────────────────────────────────
sudo mkdir -p "$WG_TARGET"
sudo cp "$WG_SRC"/*.conf "$WG_TARGET/"
sudo chmod 600 "$WG_TARGET"/*.conf
sudo chown root:root "$WG_TARGET"/*.conf

echo "==> Adding kill-switch hooks to each config"

# Kill switch: block all non-VPN traffic while the tunnel is up.
# Uses iptables marks that wg-quick already sets — works with both
# iptables and iptables-nft (Arch default).
POSTUP='PostUp = iptables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT; ip6tables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT'
PREDOWN='PreDown = iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT; ip6tables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT'

for conf in "$WG_TARGET"/*.conf; do
  # Add kill-switch lines only if not already present
  if ! sudo grep -q "PostUp.*REJECT" "$conf" 2>/dev/null; then
    sudo sed -i "/^\[Interface\]/a $POSTUP\n$PREDOWN" "$conf"
    echo "   Kill-switch added: $(basename "$conf")"
  else
    echo "   Kill-switch already present: $(basename "$conf")"
  fi
done

# ── Passwordless sudo for wg-quick only ───────────────────────────────────────
echo "==> Configuring sudoers for wg-quick"

SUDOERS_FILE="/etc/sudoers.d/wg-quick"
echo "%wheel ALL=(ALL) NOPASSWD: /usr/bin/wg-quick" | sudo tee "$SUDOERS_FILE" > /dev/null
sudo chmod 440 "$SUDOERS_FILE"

# Validate the sudoers file syntax
sudo visudo -c -f "$SUDOERS_FILE" && echo "   Sudoers rule OK"

echo "==> WireGuard setup complete."
echo "    Switch VPN with:  ~/.config/scripts/vpn-switcher.sh"
echo "    Or press \$mod+Shift+v in Sway"
