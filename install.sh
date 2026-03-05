#!/usr/bin/env bash
set -Eeuo pipefail
# prompts for sudo if needed
if [[ $EUID -ne 0 ]]; then
  sudo -v
fi
DEST="/usr/local/bin"
install -m 0755 bin/iSyslog "$DEST/iSyslog"
install -m 0755 bin/iCopy "$DEST/iCopy"
install -m 0755 bin/iHelp "$DEST/iHelp"
ln -sf "$DEST/iSyslog" "$DEST/iLive"
echo "✅ Installed: $DEST/iSyslog, $DEST/iCopy, $DEST/iHelp and symlink $DEST/iLive"
