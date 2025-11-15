#!/usr/bin/env sh
set -eu
echo "[i] Installing python3 and pip (Alpine)"
apk update
apk add --no-cache python3 py3-pip
python3 --version
pip3 --version || true
echo "[✔] Python installed"
