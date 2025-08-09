#!/usr/bin/env bash
set -euo pipefail

need(){ command -v "$1" >/dev/null 2>&1 || { echo "Missing: $1"; exit 127; }; }

echo "[*] Installing dependencies..."
sudo apt-get update -y >/dev/null
sudo apt-get install -y libimobiledevice-utils usbmuxd coreutils grep gawk sed >/dev/null

echo "[*] Installing commands to /usr/local/bin ..."
sudo install -m 0755 bin/iLive /usr/local/bin/iLive
sudo install -m 0755 bin/iCopy /usr/local/bin/iCopy

echo "[*] Ensuring ~/GNO-DATA exists..."
mkdir -p "${HOME}/GNO-DATA"

echo "[*] Ensuring ~/Forestry exists..."
mkdir -p "${HOME}/Forestry"

# Quality-of-life: aliases/functions into ~/.bashrc once
BRC="${HOME}/.bashrc"
if ! grep -q "# WSL-iTools BEGIN" "$BRC" 2>/dev/null; then
  cat >> "$BRC" <<'RC'
# WSL-iTools BEGIN
iHelp(){
  cat <<'TXT'
Custom iDevice Commands:
  iCopy [--since 5m|2h|1d] [--zip] [-v]   Snapshot iOS crash/diag into ~/GNO-DATA/<ts>
  iLive [--since 5m|2h|1d] [--zip] [-v]   Pull .ips & diagnostics into ~/Forestry/<ts>
  iDevicePair [args]                      idevicepair passthrough
  iDeviceSyslog                           idevicesyslog passthrough
TXT
}
iDevicePair(){ command -v idevicepair >/dev/null && idevicepair "$@"; }
iDeviceSyslog(){ command -v idevicesyslog >/dev/null && idevicesyslog "$@"; }
alias iHelp='iHelp'
# WSL-iTools END
RC
  echo "[*] Appended helper aliases to ~/.bashrc (reload with: source ~/.bashrc)"
fi

echo "[*] Done. Try: iHelp, iCopy --since 10m --zip -v"
