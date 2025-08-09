# WSL-iTools

Small, fast helpers for working with an attached iPhone from WSL (Debian/Ubuntu) using `libimobiledevice`.

This repo ships **iSyslog** (and a convenience symlink **iLive**) to capture live device syslog to a timestamped folder under `~/Forestry/`.

---

## Requirements

* WSL Debian/Ubuntu
* Windows USB/IP bridge (host PowerShell): `usbipd` (from Microsoft’s USBIPD-WIN)
* Packages in WSL:

  ```bash
  sudo apt-get update
  sudo apt-get install -y usbmuxd libimobiledevice-utils
  ```

  Provides `idevicesyslog` and `idevicepair`.

---

## Install

```bash
# from the repo root
sudo ./install.sh
# creates: /usr/local/bin/iSyslog and symlink /usr/local/bin/iLive
# both are simple bash wrappers around idevicesyslog
```

Open a **new shell** after installing so your `$PATH` picks up the new commands.

---

## Pair and Attach the iPhone

```bash
# on Windows (PowerShell as Admin):
usbipd wsl list
usbipd wsl attach --busid <BUSID>   # attach the iPhone to this WSL distro

# in WSL:
idevicepair pair
idevicepair validate
```

---

## Usage

`iLive` is just a friendly name for `iSyslog`. Both accept the same flags.

```bash
iLive [--name LABEL] [--udid UDID]
iSyslog [--name LABEL] [--udid UDID]
```

* `--name/-n` : Human label for the run (used in filename).
* `--udid/-u` : Target a specific device (optional if only one is attached).

### Examples

```bash
# Basic: capture until Ctrl+C
iLive --name test_run

# Target a specific device:
iLive --udid 00008110-0012345678901234 --name repro_wifi

# Raw tool (same as above)
iSyslog --name boot_trace
```

### Output

Logs are written to a timestamped directory under your home:

```
~/Forestry/<YYYYMMDD_HHMMSS>/<NAME>.idevicesyslog.log
```

You’ll also see the live stream in your terminal while it writes to disk.

---

## Tips (WSL on Windows drives)

If you run the repo from a Windows mount (`/mnt/c`, `/mnt/t`, etc.) and you hit odd permission issues, remount with metadata:

```bash
# example for T:
sudo umount /mnt/t 2>/dev/null || true
sudo mount -t drvfs T: /mnt/t -o metadata,uid=$(id -u),gid=$(id -g),umask=022,fmask=0111
```

If you edited scripts on Windows and shell complains about line endings:

```bash
sed -i 's/\r$//' i.sh bin/iSyslog install.sh
```

---

## Troubleshooting

* **“Please run with bash / Illegal option -o pipefail”**
  Run explicitly with bash: `bash iSyslog` or `bash i.sh`.

* **“Device not paired”**
  Run `idevicepair pair` then `idevicepair validate`.

* **No output / nothing captured**
  Confirm the phone is attached to WSL (`usbipd wsl list` then `usbipd wsl attach --busid <BUSID>`), and that `idevicesyslog` works on its own.

* **Permission denied installing to /usr/local/bin**
  Re-run: `sudo ./install.sh`

---

## What’s in the box

* `bin/iSyslog` – bash wrapper around `idevicesyslog` that:

  * Creates `~/Forestry/<timestamp>/`
  * Streams to terminal **and** saves to `<name>.idevicesyslog.log`
  * Accepts `--name` and `--udid`
* `bin/iLive` – symlink to `iSyslog`
* `install.sh` – copies/links the tools into `/usr/local/bin`

> Development helper: `i.sh` (kept in the repo) can bootstrap/update files during active development; end users only need `install.sh`.

---

## Uninstall

```bash
sudo rm -f /usr/local/bin/iSyslog /usr/local/bin/iLive
```

---

## License

MIT

