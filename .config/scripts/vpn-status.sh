#!/usr/bin/env bash
# vpn-status.sh — stdout JSON for waybar custom/vpn module
# Runs as a regular user; uses `ip link` (no root needed)

# Country code → flag emoji for the waybar label
flag() {
  case "$1" in
    CA) echo "🇨🇦";; CH) echo "🇨🇭";; JP) echo "🇯🇵";; MX) echo "🇲🇽";;
    NL) echo "🇳🇱";; NO) echo "🇳🇴";; PL) echo "🇵🇱";; RO) echo "🇷🇴";;
    SG) echo "🇸🇬";; US) echo "🇺🇸";; *)  echo "🌐";;
  esac
}

iface=$(ip -o link show type wireguard 2>/dev/null \
  | awk -F': ' 'NR==1{ gsub(/@.*/,"",$2); print $2 }')

if [ -z "$iface" ]; then
  printf '{"text":"󰤮","tooltip":"VPN off","class":"disconnected"}\n'
  exit 0
fi

# Parse CC from wg-CA-FREE-33
if [[ "$iface" =~ ^wg-([A-Z]+) ]]; then
  cc="${BASH_REMATCH[1]}"
  f=$(flag "$cc")
  printf '{"text":"󰒃 %s","tooltip":"VPN: %s","class":"connected"}\n' \
    "$f $cc" "$iface"
else
  printf '{"text":"󰒃 VPN","tooltip":"VPN: %s","class":"connected"}\n' "$iface"
fi
