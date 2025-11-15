#!/usr/bin/env sh
set -eu
LOG="logs/agents.log"; PIDF="run/agent.pid"
PORT="${AGENT_PORT:-5255}"
mkdir -p logs run
echo "[i] Starting Agent Manager on $PORT"
python3 agents/agent_manager.py >>"$LOG" 2>&1 &
echo $! > "$PIDF"
echo "[✔] Agent Manager started (PID $(cat "$PIDF"))"
