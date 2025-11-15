#!/usr/bin/env sh
set -eu
echo "[i] Setting environment defaults"
cat > .env <<ENV
BACK_PORT=5253
FRONT_PORT=3000
MONITOR_INTERVAL=10
ENV
echo "[✔] .env created"
