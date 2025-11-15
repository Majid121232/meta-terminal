#!/usr/bin/env sh
set -eu

BACK_PORT="${BACK_PORT:-5253}"
FRONT_PORT="${FRONT_PORT:-3000}"

alive() { kill -0 "$1" 2>/dev/null; }
port_ok() { nc -z -w 2 127.0.0.1 "$1" >/dev/null 2>&1; }
http_ok() { curl -s --max-time 2 "http://127.0.0.1:$1/" >/dev/null 2>&1; }
health_ok() { curl -s --max-time 2 "http://127.0.0.1:$1/health" | grep -q '"status":"ok"'; }

check_pid() {
  svc="$1"; pidf="run/$svc.pid"
  if [ -f "$pidf" ]; then
    pid="$(cat "$pidf")"
    if alive "$pid"; then echo "[✔] $svc PID $pid alive"; return 0; else echo "[✘] $svc PID $pid dead"; return 1; fi
  else
    echo "[!] $svc pid file missing"
    return 2
  fi
}

rc=0

# Backend checks
check_pid backend || rc=1
if health_ok "$BACK_PORT"; then
  echo "[✔] backend /health OK"
elif http_ok "$BACK_PORT"; then
  echo "[✔] backend root HTTP OK"
elif port_ok "$BACK_PORT"; then
  echo "[✔] backend port OK"
else
  echo "[✘] backend unreachable"
  rc=1
fi

# Frontend checks
check_pid frontend || rc=1
if health_ok "$FRONT_PORT"; then
  echo "[✔] frontend /health OK"
elif http_ok "$FRONT_PORT"; then
  echo "[✔] frontend root HTTP OK"
elif port_ok "$FRONT_PORT"; then
  echo "[✔] frontend port OK"
else
  echo "[✘] frontend unreachable"
  rc=1
fi

[ "$rc" -eq 0 ] && echo "[✔] Self-test passed" || echo "[✘] Self-test failed"
exit "$rc"
