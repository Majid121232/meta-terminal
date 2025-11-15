#!/usr/bin/env bash
set -euo pipefail

INTERVAL="${MONITOR_INTERVAL:-10}"
REPORT_DIR="${REPORT_DIR:-start}"
LOGDIR="logs"
RUNDIR="run"
BACK_PORT="${BACK_PORT:-5253}"
FRONT_PORT="${FRONT_PORT:-3000}"

mkdir -p "$LOGDIR" "$RUNDIR" "$REPORT_DIR"

probe_http() { curl -s --max-time 2 "http://127.0.0.1:$1/health" | grep -q '"status":"ok"'; }
probe_port() { nc -z -w 2 127.0.0.1 "$1" >/dev/null 2>&1; }

is_alive() { local pid="$1"; kill -0 "$pid" 2>/dev/null; }

restart_if_dead() {
  local svc="$1" script="$2" logf="$3" pidf="$4"
  if [ ! -f "$pidf" ] || ! is_alive "$(cat "$pidf" 2>/dev/null)"; then
    echo "[i] $svc down, restarting..."
    nohup "$script" >"$logf" 2>&1 &
    echo $! > "$pidf"
    echo "[✔] $svc restarted (PID $(cat "$pidf"))"
  fi
}

write_snapshot() {
  local ts="$(date +%F_%H:%M:%S)"
  local bpid="null" fpid="null"
  [ -f "$RUNDIR/backend.pid" ] && bpid="$(cat "$RUNDIR/backend.pid")"
  [ -f "$RUNDIR/frontend.pid" ] && fpid="$(cat "$RUNDIR/frontend.pid")"
  cat > "$REPORT_DIR/monitor_snapshot.json" <<JSON
{
  "timestamp": "$ts",
  "backend":  {"pid": $bpid, "port": $BACK_PORT},
  "frontend": {"pid": $fpid, "port": $FRONT_PORT}
}
JSON
  echo "[✔] Snapshot written: $REPORT_DIR/monitor_snapshot.json"
}

echo "==> Monitor loop (interval ${INTERVAL}s)"
while true; do
  # health checks
  if probe_http "$BACK_PORT"; then echo "[✔] backend /health OK"; elif probe_port "$BACK_PORT"; then echo "[✔] backend port OK"; else echo "[✘] backend unreachable"; fi
  if probe_http "$FRONT_PORT"; then echo "[✔] frontend /health OK"; elif probe_port "$FRONT_PORT"; then echo "[✔] frontend port OK"; else echo "[✘] frontend unreachable"; fi

  # status
  for svc in backend frontend; do
    pidf="$RUNDIR/$svc.pid"
    if [ -f "$pidf" ] && is_alive "$(cat "$pidf")"; then
      pid="$(cat "$pidf")"
      cpu="$(ps -p "$pid" -o %cpu= | tr -d '[:space:]' || echo 0)"
      mem="$(ps -p "$pid" -o %mem= | tr -d '[:space:]' || echo 0)"
      echo "[✔] $svc running (PID $pid) CPU=${cpu}% MEM=${mem}%"
    else
      echo "[✘] $svc not running"
    fi
  done

  # self-heal using your start scripts
  restart_if_dead "backend" "start/start_backend.sh" "$LOGDIR/backend.log" "$RUNDIR/backend.pid"
  restart_if_dead "frontend" "start/start_frontend.sh" "$LOGDIR/frontend.log" "$RUNDIR/frontend.pid"

  write_snapshot
  sleep "$INTERVAL"
done
