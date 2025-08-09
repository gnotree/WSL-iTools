# WSL-iTools

Minimal iOS forensic/dev helpers for WSL (Debian/Ubuntu) using `libimobiledevice`.

## Tools
- **iCopy** — Collect crash/diagnostics to `~/GNO-DATA/<timestamp>/`
- **iLive** — Live syslog capture. Default until Ctrl+C; `-v` to print; durations `-10s`, `-5m`, or `-Xs 10`, `-Xm 2`.

## Install
```bash
./install.sh
```

## Pairing / Attach
```bash
idevicepair pair
idevicepair validate
# Windows (PowerShell):
# usbipd wsl list
# usbipd wsl attach --busid <BUSID>
```

## WSL drvfs tip
If writes under `/mnt/<drive>` fail (permissions/metadata), remount with:
```bash
sudo umount /mnt/t 2>/dev/null || true
sudo mount -t drvfs T: /mnt/t -o metadata,uid=$(id -u),gid=$(id -g),umask=022,fmask=0111
```
