#!/usr/bin/env sh
set -eu
LOG="logs/ai.log"; mkdir -p logs
echo "[i] Starting AI service stub"
( while true; do echo "{\"ts\":\"$(date)\",\"msg\":\"ai tick\"}"; sleep 12; done ) >>"$LOG" 2>&1 &
echo $! > run/ai.pid
echo "[✔] AI service started (PID $(cat run/ai.pid))"
