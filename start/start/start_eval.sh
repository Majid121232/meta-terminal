#!/usr/bin/env sh
set -eu
LOG="logs/eval.log"; mkdir -p logs
echo "[i] Starting eval stub"
( for i in $(seq 1 50); do echo "eval step $i"; sleep 1; done ) >>"$LOG" 2>&1 &
echo $! > run/eval.pid
echo "[✔] eval started (PID $(cat run/eval.pid))"
