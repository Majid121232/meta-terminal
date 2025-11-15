#!/usr/bin/env sh
set -eu
echo "[i] Installing docker (Alpine)"
apk update
apk add --no-cache docker
rc-service docker start || service docker start || true
docker version || echo "[!] Docker available but daemon might need manual start"
echo "[✔] Docker install attempted"
