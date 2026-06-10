#!/usr/bin/env bash
# vpn-switcher.sh — wofi WireGuard switcher (mirrors theme-switcher logic)
set -euo pipefail

WG_DIR="/etc/wireguard"

# ── Country display ───────────────────────────────────────────────────────────
country_label() {
  case "$1" in
    CA) echo "🇨🇦  Canada"       ;; CH) echo "🇨🇭  Switzerland" ;;
    JP) echo "🇯🇵  Japan"        ;; MX) echo "🇲🇽  Mexico"      ;;
    NL) echo "🇳🇱  Netherlands"  ;; NO) echo "🇳🇴  Norway"      ;;
    PL) echo "🇵🇱  Poland"       ;; RO) echo "🇷🇴  Romania"     ;;
    SG) echo "🇸🇬  Singapore"    ;; US) echo "🇺🇸  United States";;
    *)  echo "🌐  $1"            ;;
  esac
}

# "wg-CA-FREE-33" → "🇨🇦  Canada  #33"
iface_label() {
  local iface="$1"
  if [[ "$iface" =~ ^wg-([A-Z]+)-FREE-([0-9]+)$ ]]; then
    echo "$(country_label "${BASH_REMATCH[1]}")  #${BASH_REMATCH[2]}"
  elif [[ "$iface" =~ ^wg-([A-Z]+)-([0-9]+)$ ]]; then
    echo "$(country_label "${BASH_REMATCH[1]}")  #${BASH_REMATCH[2]}"
  else
    echo "$iface"
  fi
}

# ── State ─────────────────────────────────────────────────────────────────────
# ip link doesn't need root; shows all WireGuard interfaces
active_iface() {
  ip -o link show type wireguard 2>/dev/null \
    | awk -F': ' 'NR==1{ gsub(/@.*/,"",$2); print $2 }'
}

# ── Actions ───────────────────────────────────────────────────────────────────
do_disconnect() {
  local iface="$1"
  sudo wg-quick down "$iface"
  notify-send "VPN" "Disconnected from $(iface_label "$iface")" -u low
}

do_connect() {
  local iface="$1"
  sudo wg-quick up "$iface"
  notify-send "VPN" "Connected: $(iface_label "$iface")" -u low
}

# ── Build wofi menu ───────────────────────────────────────────────────────────
current=$(active_iface)

menu_items=()
if [ -n "$current" ]; then
  menu_items+=("⛔  Disconnect  —  $(iface_label "$current")")
fi

for conf in "$WG_DIR"/wg-*.conf; do
  [ -f "$conf" ] || continue
  iface=$(basename "$conf" .conf)
  label=$(iface_label "$iface")
  if [ "$iface" = "$current" ]; then
    menu_items+=("●  $label  ← connected")
  else
    menu_items+=("   $label")
  fi
done

printf '%s\n' "${menu_items[@]}" \
  | wofi --dmenu --prompt "󰒃  VPN" \
  > /tmp/vpn_wofi_selection 2>/dev/null || true

selection=$(cat /tmp/vpn_wofi_selection 2>/dev/null)
rm -f /tmp/vpn_wofi_selection
[ -z "$selection" ] && exit 0

# ── Handle disconnect ─────────────────────────────────────────────────────────
if [[ "$selection" == ⛔* ]]; then
  [ -n "$current" ] && do_disconnect "$current"
  pkill -USR2 waybar 2>/dev/null || true
  exit 0
fi

# ── Match selection back to an interface name ─────────────────────────────────
selected_iface=""
for conf in "$WG_DIR"/wg-*.conf; do
  [ -f "$conf" ] || continue
  iface=$(basename "$conf" .conf)
  label=$(iface_label "$iface")
  if echo "$selection" | grep -qF "$label"; then
    selected_iface="$iface"
    break
  fi
done

[ -z "$selected_iface" ] && exit 0
[ "$selected_iface" = "$current" ] && exit 0   # already connected

# Swap connections
[ -n "$current" ] && do_disconnect "$current"
do_connect "$selected_iface"
pkill -USR2 waybar 2>/dev/null || true
