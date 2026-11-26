#!/usr/bin/env bash
set -euo pipefail

# Stop GNOME user session services for the current user
if command -v systemctl >/dev/null 2>&1 && systemctl --user is-active --quiet default.target 2>/dev/null; then
  systemctl --user stop \
    gnome-session.target \
    'gnome-*' \
    'org.gnome.*' \
    xdg-desktop-portal-gnome.service \
    pipewire.service \
    pipewire-pulse.service \
    wireplumber.service 2>/dev/null || true
fi

# Stop display managers (GNOME uses gdm3)
for dm in gdm3 lightdm sddm; do
  if systemctl is-active --quiet "$dm" 2>/dev/null; then
    sudo systemctl stop "$dm"
  fi
done

# Kill any remaining GNOME / desktop session processes owned by the current user
pkill -u "$USER" -f 'gnome-shell|gnome-session|xdg-desktop-portal-gnome|evolution-alarm-notify|gsd-' 2>/dev/null || true

# Verify networking stays active
if ! ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1; then
  echo "Warning: Network check failed; verify NetworkManager or systemd-networkd." >&2
fi

echo "GNOME stopped. Launch your browser now (e.g., startx /usr/bin/google-chrome or firefox)."
