#!/usr/bin/env sh
set -eu
PORT="${DASH_PORT:-8080}"
LOG="logs/dashboard.log"; mkdir -p logs
echo "[i] Starting dashboard on $PORT"
python3 -m http.server "$PORT" --bind 127.0.0.1 >>"$LOG" 2>&1 &
echo $! > run/dashboard.pid
echo "[✔] dashboard started (PID $(cat run/dashboard.pid))"
