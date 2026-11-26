#!/usr/bin/env bash
set -euo pipefail

echo "Updating package index..."
sudo apt update

# Core Xorg + xinit for launching a single browser from TTY on modern Ubuntu
# (avoids obsolete legacy wrappers unless explicitly present in your repo)
PACKAGES=(
  xinit
  xserver-xorg-core
  xserver-xorg-input-libinput
)

# Add modesetting/fbdev video driver if available on this Ubuntu release
for drv in xserver-xorg-video-modesetting xserver-xorg-video-fbdev; do
  if apt-cache show "$drv" >/dev/null 2>&1; then
    PACKAGES+=("$drv")
  fi
done

echo "Installing minimal X11 packages: ${PACKAGES[*]}"
sudo apt install --no-install-recommends -y "${PACKAGES[@]}"

echo ""
echo "Checking installed browser binaries..."
FOUND_BROWSER=0
for b in google-chrome google-chrome-stable chromium chromium-browser firefox brave-browser microsoft-edge; do
  if command -v "$b" >/dev/null 2>&1; then
    echo "  Found: $b -> $(command -v "$b")"
    FOUND_BROWSER=1
  fi
done

if [ "$FOUND_BROWSER" -eq 0 ]; then
  echo "  No common browser binary found in PATH. Install Chrome, Firefox, or Chromium before running startx." >&2
fi

echo ""
echo "Verification: $(command -v startx || echo 'startx missing') and $(command -v Xorg || echo 'Xorg missing')."
