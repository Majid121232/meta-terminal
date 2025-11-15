#!/usr/bin/env sh
set -eu
LOG="logs/agents.log"; mkdir -p logs
echo "[i] Starting agents stub"
( while true; do echo "agent heartbeat $(date)"; sleep 15; done ) >>"$LOG" 2>&1 &
echo $! > run/agents.pid
echo "[✔] agents started (PID $(cat run/agents.pid))"
