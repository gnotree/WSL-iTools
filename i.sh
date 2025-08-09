#!/usr/bin/env bash
# i.sh - bootstrap iSyslog/iLive, install, and push updates
[ -n "$BASH_VERSION" ] || { echo "[!] Please run with bash:  sudo bash i.sh  (or:  bash i.sh)"; exit 2; }
set -Eeuo pipefail

# must be inside a git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[!] Not inside a git repo. cd into your repo and run again."
  exit 1
fi

# normalize to repo root
REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

mkdir -p bin

# --- bin/iSyslog ------------------------------------------------------------
cat > bin/iSyslog <<'EOF'
#!/usr/bin/env bash
[ -n "$BASH_VERSION" ] || { echo "[!] Use bash to run this script"; exit 2; }
set -Eeuo pipefail

usage(){ echo "Usage: $(basename "$0") [--name LABEL] [--udid UDID]"; }

LABEL=""; UDID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name|-n) LABEL="${2:-}"; shift 2;;
    --udid|-u) UDID="${2:-}"; shift 2;;
    --help|-h) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 2;;
  esac
done

for cmd in idevicesyslog idevicepair date tee; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "[!] Missing $cmd. Install libimobiledevice."; exit 127; }
done

if ! idevicepair validate >/dev/null 2>&1; then
  echo "[!] Device not paired. Run: idevicepair pair"
  exit 100
fi

TS="$(date +%Y%m%d_%H%M%S)"
BASE="${HOME}/Forestry"
DIR="${BASE}/${TS}"
mkdir -p "$DIR"

NAME="${LABEL:-$TS}"
OUT="${DIR}/${NAME}.syslog.txt"

echo "[iSyslog] capturing to: $OUT"
echo "[iSyslog] press Ctrl-C to stop and save."

udidArg=()
[[ -n "$UDID" ]] && udidArg+=(--udid "$UDID")

if command -v stdbuf >/dev/null 2>&1; then
  idevicesyslog "${udidArg[@]}" | stdbuf -oL tee "$OUT"
else
  idevicesyslog "${udidArg[@]}" | tee "$OUT"
fi

echo
echo "[iSyslog] saved: $OUT"
EOF

# --- bin/iLive (thin wrapper) -----------------------------------------------
cat > bin/iLive <<'EOF'
#!/usr/bin/env bash
exec "$(dirname "$0")/iSyslog" "$@"
EOF

# --- install.sh -------------------------------------------------------------
cat > install.sh <<'EOF'
#!/usr/bin/env bash
[ -n "$BASH_VERSION" ] || { echo "[!] Use bash to run this script"; exit 2; }
set -Eeuo pipefail
sudo install -m 0755 bin/iSyslog /usr/local/bin/iSyslog
sudo ln -sfn /usr/local/bin/iSyslog /usr/local/bin/iLive
echo "✅ Installed: /usr/local/bin/iSyslog and symlink /usr/local/bin/iLive"
EOF

# strip CRLFs if created on a Windows mount
for f in i.sh bin/iSyslog bin/iLive install.sh; do
  sed -i 's/\r$//' "$f" 2>/dev/null || true
done

# make local copies executable (may be ignored on Windows mounts, but harmless)
chmod +x bin/iSyslog bin/iLive install.sh 2>/dev/null || true

# --- minimal README update ---------------------------------------------------
touch README.md
if ! grep -q "## iLive / iSyslog" README.md 2>/dev/null; then
  cat >> README.md <<'EOF'

## iLive / iSyslog
Capture iOS syslog until Ctrl-C, saved to `~/Forestry/<timestamp>/<name>.syslog.txt`.

### Install
    sudo bash ./install.sh

### Usage
    iLive --name test_run
    iSyslog --udid <UDID> --name mylabel
EOF
fi

# --- commit & push ----------------------------------------------------------
branch="$(git rev-parse --abbrev-ref HEAD)"
git add bin/iSyslog bin/iLive install.sh README.md || true
git commit -m "fix(iLive): syslog-only capture; add iSyslog; installer; docs" || true
if git remote get-url origin >/dev/null 2>&1; then
  git push -u origin "$branch" || echo "[git] push failed (check credentials)"
else
  echo "[git] no 'origin' remote; skipping push"
fi

echo "✅ Done. Now: sudo bash ./install.sh ; then open a new shell and run: iLive --name test_run"

