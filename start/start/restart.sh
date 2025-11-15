#!/usr/bin/env sh
set -eu
echo "[i] Restarting services"
./meta-terminal.sh stop || true
sleep 1
./start/start.sh
echo "[✔] restart complete"
