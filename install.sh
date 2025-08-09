#!/usr/bin/env bash
set -Eeuo pipefail
# prompts for sudo if needed
if [[ $EUID -ne 0 ]]; then
  sudo -v
fi
DEST="/usr/local/bin"
install -m 0755 bin/iSyslog "$DEST/iSyslog"
ln -sf "$DEST/iSyslog" "$DEST/iLive"
echo "✅ Installed: $DEST/iSyslog and symlink $DEST/iLive"
