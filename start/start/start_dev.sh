#!/usr/bin/env sh
set -eu
export BACK_PORT=5253
export FRONT_PORT=3000
export MONITOR_INTERVAL=5
echo "[i] DEV profile applied"
./start/start.sh
