#!/usr/bin/env sh
set -eu
LOG="logs/inference.log"; mkdir -p logs
echo "[i] Starting inference stub"
( while true; do echo "inference tick $(date)"; sleep 10; done ) >>"$LOG" 2>&1 &
echo $! > run/inference.pid
echo "[✔] inference started (PID $(cat run/inference.pid))"
