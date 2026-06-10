#!/usr/bin/env bash
# setup/harden.sh — kernel/sysctl security hardening
# Safe for a desktop/laptop; does not break normal use.
set -euo pipefail

SYSCTL_FILE="/etc/sysctl.d/99-harden.conf"

echo "==> Writing sysctl hardening rules to $SYSCTL_FILE"

sudo tee "$SYSCTL_FILE" > /dev/null << 'EOF'
# ── Network hardening ─────────────────────────────────────────────────────────

# Ignore ICMP broadcast/multicast (smurf amplification)
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Ignore bogus ICMP error responses
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Reverse path filtering: drop packets with spoofed source addresses
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Do not accept IP source routing (used for MITM)
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0

# Disable ICMP redirects (prevents route hijacking)
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# Do not send ICMP redirects
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# SYN flood protection
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2

# Disable IPv6 router advertisements (we manage routing ourselves)
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0

# Log martian packets (packets with impossible source addresses)
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# ── Kernel hardening ──────────────────────────────────────────────────────────

# Restrict ptrace to parent processes only (stops process injection attacks)
# 1 = restricted (parents only), 2 = admin only, 3 = disabled
kernel.yama.ptrace_scope = 1

# Hide kernel pointers in /proc (prevents info leaks to unprivileged users)
kernel.kptr_restrict = 1

# Restrict dmesg to root (kernel ring buffer leaks addresses)
kernel.dmesg_restrict = 1

# Disable the SysRq key in production (enable temporarily with: sysctl kernel.sysrq=1)
kernel.sysrq = 0

# Restrict loading of kernel modules to CAP_SYS_MODULE (default: allow all)
# kernel.modules_disabled = 1   # Uncomment only AFTER confirming all modules load at boot

# ── Core dump hardening ───────────────────────────────────────────────────────
# Core dumps can contain sensitive memory (keys, passwords)
fs.suid_dumpable = 0
kernel.core_pattern = |/bin/false

# ── File system hardening ─────────────────────────────────────────────────────
# Protect symlink/hardlink creation in world-writable directories (/tmp etc.)
fs.protected_symlinks = 1
fs.protected_hardlinks = 1

# Restrict fifos and regular file access in world-writable sticky dirs
fs.protected_fifos = 2
fs.protected_regular = 2
EOF

echo "==> Applying sysctl rules immediately"
sudo sysctl --system | grep -E "harden|Applying" | head -20

# ── Restrict core dumps via limits.conf too ───────────────────────────────────
echo "==> Restricting core dumps via /etc/security/limits.d/"
sudo tee /etc/security/limits.d/99-no-coredump.conf > /dev/null << 'EOF'
* soft core 0
* hard core 0
EOF

# ── Ensure coredump storage is also disabled in systemd ──────────────────────
sudo mkdir -p /etc/systemd/coredump.conf.d
sudo tee /etc/systemd/coredump.conf.d/disable.conf > /dev/null << 'EOF'
[Coredump]
Storage=none
ProcessSizeMax=0
EOF

echo ""
echo "==> Hardening complete. Summary:"
echo "    - Network: spoofing, redirects, SYN floods blocked"
echo "    - ptrace restricted to parent processes (kernel.yama.ptrace_scope=1)"
echo "    - Kernel pointers hidden from unprivileged users"
echo "    - Core dumps disabled (can leak secrets from memory)"
echo "    - Symlink/hardlink attacks in /tmp blocked"
