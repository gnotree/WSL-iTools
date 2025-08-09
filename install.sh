#!/usr/bin/env bash
set -euo pipefail

echo "[*] Installing dependencies..."
sudo apt-get update -y
sudo apt-get install -y usbmuxd libimobiledevice-utils coreutils grep gawk sed || true

echo "[*] Installing commands to /usr/local/bin ..."
sudo install -m 0755 bin/iCopy /usr/local/bin/iCopy
sudo install -m 0755 bin/iLive /usr/local/bin/iLive
sudo install -m 0755 bin/iHelp /usr/local/bin/iHelp

echo "[*] Ensuring ~/GNO-DATA exists..."
mkdir -p "${HOME}/GNO-DATA"

if command -v systemctl >/dev/null 2>&1; then
  sudo systemctl restart usbmuxd || true
fi

echo "[*] Done. Try: iHelp, iCopy, iLive -v"
