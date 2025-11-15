#!/bin/sh
# Meta-Terminal Orchestrator (POSIX-safe, Enhanced)

set -e

ROOT_DIR="`pwd`"
START_DIR="$ROOT_DIR/start"
LOGDIR="$ROOT_DIR/logs"
RUNDIR="$ROOT_DIR/run"
REPORT="$ROOT_DIR/start/report.json"

BACK_SCRIPT="$START_DIR/start_backend.sh"
FRONT_SCRIPT="$START_DIR/start_frontend.sh"
BACK_PORT="5253"
FRONT_PORT="3000"

# رنگ‌ها برای خروجی خواناتر
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

log() {
  type="$1"; msg="$2"
  case "$type" in
    step)    printf "%b==> %s%b\n" "$YELLOW" "$msg" "$NC" ;;
    ok)      printf "%b[✔] %s%b\n" "$GREEN" "$msg" "$NC" ;;
    err)     printf "%b[✘] %s%b\n" "$RED"   "$msg" "$NC" ;;
    info)    printf "%b[i] %s%b\n" "$YELLOW" "$msg" "$NC" ;;
  esac
}

ensure_dirs() {
  mkdir -p "$LOGDIR" "$RUNDIR" "$START_DIR"
  chmod 755 "$LOGDIR" "$RUNDIR"
  touch "$LOGDIR/backend.log" "$LOGDIR/frontend.log" "$LOGDIR/monitor.log"
}

rotate_logs() {
  for lf in "$LOGDIR/backend.log" "$LOGDIR/frontend.log"; do
    [ -f "$lf" ] || continue
    size=$(wc -c < "$lf" 2>/dev/null || echo 0)
    if [ "$size" -ge 5242880 ]; then
      ts=$(date +%F_%H%M%S)
      mv "$lf" "${lf%.log}_$ts.log"
      : > "$lf"
      log info "Rotated $lf at $ts"
    fi
  done
}

start_service() {
  svc="$1"; script="$2"; logf="$3"; pidf="$4"
  if [ -x "$script" ]; then
    log step "Starting $svc..."
    nohup "$script" >"$logf" 2>&1 &
    echo $! > "$pidf"
    log ok "$svc started (PID `cat $pidf`)"
  else
    log err "$svc script not executable: $script"
  fi
}

stop_service() {
  svc="$1"; pidf="$RUNDIR/$svc.pid"
  if [ -f "$pidf" ]; then
    PID=$(cat "$pidf")
    if kill -0 "$PID" 2>/dev/null; then
      log step "Stopping $svc (PID $PID)..."
      kill "$PID" 2>/dev/null || true
      rm -f "$pidf"
      log ok "$svc stopped"
    else
      log err "$svc not running"; rm -f "$pidf" || true
    fi
  else
    log err "$svc pid file not found"
  fi
}

status_service() {
  svc="$1"; pidf="$RUNDIR/$svc.pid"
  if [ -f "$pidf" ]; then
    PID=$(cat "$pidf")
    if kill -0 "$PID" 2>/dev/null; then
      CPU=$(ps -p "$PID" -o %cpu= 2>/dev/null | tr -d '[:space:]' || echo "0")
      MEM=$(ps -p "$PID" -o %mem= 2>/dev/null | tr -d '[:space:]' || echo "0")
      log ok "$svc running (PID $PID) CPU=${CPU}% MEM=${MEM}%"
    else
      log err "$svc not running"
    fi
  else
    log err "$svc pid file not found"
  fi
}

health_check() {
  svc="$1"; port="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -s --max-time 2 "http://127.0.0.1:$port/" >/dev/null 2>&1 && \
      log ok "$svc HTTP OK on port $port" || log err "$svc HTTP unreachable on $port"
  else
    nc -z -w 2 127.0.0.1 "$port" >/dev/null 2>&1 && \
      log ok "$svc port $port reachable" || log err "$svc port $port unreachable"
  fi
}

write_report() {
  mkdir -p "$START_DIR"
  BPID="null"; FPID="null"
  [ -f "$RUNDIR/backend.pid" ] && BPID=$(cat "$RUNDIR/backend.pid")
  [ -f "$RUNDIR/frontend.pid" ] && FPID=$(cat "$RUNDIR/frontend.pid")
  TMP="$REPORT.tmp"
  {
    echo "{"
    echo "  \"backend\":  {\"pid\": $BPID},"
    echo "  \"frontend\": {\"pid\": $FPID}"
    echo "}"
  } > "$TMP"
  mv "$TMP" "$REPORT"
  log ok "Report written: $REPORT"
}

cmd_init() { ensure_dirs; log ok "Init complete"; }
cmd_start() { cmd_init; start_service backend "$BACK_SCRIPT" "$LOGDIR/backend.log" "$RUNDIR/backend.pid"; start_service frontend "$FRONT_SCRIPT" "$LOGDIR/frontend.log" "$RUNDIR/frontend.pid"; write_report; }
cmd_stop() { stop_service backend; stop_service frontend; write_report; }
cmd_status() { status_service backend; status_service frontend; write_report; }
cmd_report() { write_report; }
cmd_health() { health_check backend "$BACK_PORT"; health_check frontend "$FRONT_PORT"; }

cmd_monitor() {
  INTERVAL="${MONITOR_INTERVAL:-30}"
  log step "Monitor loop (interval ${INTERVAL}s)"
  ensure_dirs
  while true; do
    rotate_logs
    cmd_status
    cmd_health
    # Self-healing: restart if dead
    for svc in backend frontend; do
      pidf="$RUNDIR/$svc.pid"
      if [ ! -f "$pidf" ] || ! kill -0 "$(cat "$pidf" 2>/dev/null)" 2>/dev/null; then
        log info "$svc down, restarting..."
        [ "$svc" = "backend" ] && start_service backend "$BACK_SCRIPT" "$LOGDIR/backend.log" "$RUNDIR/backend.pid"
        [ "$svc" = "frontend" ] && start_service frontend "$FRONT_SCRIPT" "$LOGDIR/frontend.log" "$RUNDIR/frontend.pid"
      fi
    done
    sleep "$INTERVAL"
  done
}

CMD="${1:-}"
case "$CMD" in
  init)    cmd_init ;;
  start)   cmd_start ;;
  stop)    cmd_stop ;;
  status)  cmd_status ;;
  report)  cmd_report ;;
  health)  cmd_health ;;
  monitor) cmd_monitor ;;
  *)       echo "Usage: $0 {init|start|stop|status|report|health|monitor}"; exit 1 ;;
esac
