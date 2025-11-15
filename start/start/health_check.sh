#!/usr/bin/env bash
# Health Check Script for Meta-Terminal
set -euo pipefail

BACK_PORT=5253
FRONT_PORT=3000

check_service() {
  local name="$1"
  local port="$2"
  if command -v curl >/dev/null 2>&1; then
    if curl -s --max-time 2 "http://127.0.0.1:$port/health" | grep -q '"status":"ok"'; then
      echo "[✔] $name healthy on port $port"
    else
      echo "[✘] $name unhealthy on port $port"
    fi
  else
    if nc -z -w 2 127.0.0.1 "$port" >/dev/null 2>&1; then
      echo "[✔] $name port $port reachable"
    else
      echo "[✘] $name port $port unreachable"
    fi
  fi
}

check_service "backend" "$BACK_PORT"
check_service "frontend" "$FRONT_PORT"
