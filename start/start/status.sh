#!/usr/bin/env sh
set -eu

RUNDIR="run"
BACK_PORT="${BACK_PORT:-5253}"
FRONT_PORT="${FRONT_PORT:-3000}"

alive() { pid="$1"; kill -0 "$pid" 2>/dev/null; }
port_ok() { nc -z -w 2 127.0.0.1 "$1" >/dev/null 2>&1; }

read_mem_kb() {
  pid="$1"
  [ -r "/proc/$pid/status" ] || { echo 0; return; }
  awk '/VmRSS:/ {print $2}' "/proc/$pid/status" 2>/dev/null || echo 0
}

print_status() {
  svc="$1"
  pidf="$RUNDIR/$svc.pid"
  port="$2"
  if [ -f "$pidf" ]; then
    pid="$(cat "$pidf")"
    if alive "$pid"; then
      mem_kb="$(read_mem_kb "$pid")"
      mem_mb="$(awk "BEGIN {printf \"%.2f\", $mem_kb/1024}")"
      echo "[✔] $svc running (PID $pid) MEM=${mem_mb}MB"
    else
      echo "[✘] $svc not running"
    fi
  else
    echo "[✘] $svc pid file not found"
  fi
  if port_ok "$port"; then
    echo "[✔] $svc port $port OK"
  else
    echo "[✘] $svc port $port unreachable"
  fi
}

print_status backend "$BACK_PORT"
print_status frontend "$FRONT_PORT"
