#!/usr/bin/env bash
set -e

echo "Enable libvirt socket activation..."
sudo systemctl enable --now libvirtd.socket

echo "Add user to libvirt group..."
sudo usermod -aG libvirt "$USER"

echo "Ensure KVM modules load at boot..."

if grep -qi intel /proc/cpuinfo; then
  echo -e "kvm\nkvm_intel" | sudo tee /etc/modules-load.d/kvm.conf >/dev/null
else
  echo -e "kvm\nkvm_amd" | sudo tee /etc/modules-load.d/kvm.conf >/dev/null
fi

echo "Creating default libvirt network if missing..."

if ! sudo virsh net-info default >/dev/null 2>&1; then
  sudo virsh net-define /usr/share/libvirt/networks/default.xml
fi

sudo virsh net-autostart default >/dev/null

echo "Checking if network is active..."

if ! sudo virsh net-list | grep -q " default.*active"; then
  sudo virsh net-start default
fi

echo "KVM/QEMU setup complete."
echo "Log out or reboot once to refresh group permissions."
