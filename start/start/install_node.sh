#!/usr/bin/env sh
set -eu
echo "[i] Installing nodejs and npm (Alpine)"
apk update
apk add --no-cache nodejs npm
node -v && npm -v
echo "[✔] Node.js installed"
