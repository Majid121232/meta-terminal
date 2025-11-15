#!/usr/bin/env bash
set -euo pipefail

PORTS="${*:-5253 3000}"

for p in $PORTS; do
  echo "[i] Checking port $p"
  # ss preferred; fallback to netstat
  if command -v ss >/dev/null 2>&1; then
    line="$(ss -ltnp | grep -w ":$p" || true)"
  else
    line="$(netstat -ltnp 2>/dev/null | grep -w ":$p" || true)"
  fi
  if [ -n "$line" ]; then
    echo "[✘] Port $p in use:"
    echo "$line"
    pid="$(echo "$line" | sed -n 's/.*pid=\([0-9]\+\).*/\1/p')"
    if [ -n "$pid" ]; then
      echo "[i] Killing PID $pid using port $p"
      kill "$pid" 2>/dev/null || true
    else
      echo "[!] Could not extract PID; manual check needed."
    fi
  else
    echo "[✔] Port $p free"
  fi
done
