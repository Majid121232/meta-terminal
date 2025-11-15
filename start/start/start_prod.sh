#!/usr/bin/env sh
set -eu
export BACK_PORT="${BACK_PORT:-5253}"
export FRONT_PORT="${FRONT_PORT:-3000}"
export MONITOR_INTERVAL=30
echo "[i] PROD profile applied"
./start/start.sh
