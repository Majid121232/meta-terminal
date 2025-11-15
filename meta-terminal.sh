#!/bin/sh
# Meta-Terminal Orchestrator (POSIX-safe)

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

ensure_dirs() {
  mkdir -p "$LOGDIR" "$RUNDIR" "$START_DIR"
  chmod 755 "$LOGDIR" "$RUNDIR"
  touch "$LOGDIR/backend.log" "$LOGDIR/frontend.log" "$LOGDIR/monitor.log"
}

cmd_init() {
  ensure_dirs
  echo "[OK] Init complete"
}

cmd_start() {
  cmd_init
  start_service "backend" "$BACK_SCRIPT" "$LOGDIR/backend.log" "$RUNDIR/backend.pid"
  start_service "frontend" "$FRONT_SCRIPT" "$LOGDIR/frontend.log" "$RUNDIR/frontend.pid"
  cmd_report
}

start_service() {
  svc_name="$1"
  svc_script="$2"
  log_file="$3"
  pid_file="$4"

  if [ -x "$svc_script" ]; then
    echo "==> Starting $svc_name..."
    nohup "$svc_script" >"$log_file" 2>&1 &
    echo $! > "$pid_file"
    echo "[OK] $svc_name started (PID `cat $pid_file`)"
  else
    echo "[ERR] $svc_name script not executable: $svc_script"
  fi
}

cmd_stop() {
  for svc in backend frontend; do
    stop_service "$svc"
  done
  cmd_report
}

stop_service() {
  svc="$1"
  PIDFILE="$RUNDIR/$svc.pid"
  if [ -f "$PIDFILE" ]; then
    PID=`cat "$PIDFILE"`
    if kill -0 "$PID" 2>/dev/null; then
      echo "==> Stopping $svc (PID $PID)..."
      kill "$PID" 2>/dev/null || true
      rm -f "$PIDFILE"
      echo "[OK] $svc stopped"
    else
      echo "[ERR] $svc not running"; rm -f "$PIDFILE" || true
    fi
  else
    echo "[ERR] $svc pid file not found"
  fi
}

cmd_status() {
  for svc in backend frontend; do
    report_service_status "$svc"
  done
  cmd_report
}

report_service_status() {
  svc="$1"
  PIDFILE="$RUNDIR/$svc.pid"
  if [ -f "$PIDFILE" ]; then
    PID=`cat "$PIDFILE"`
    if kill -0 "$PID" 2>/dev/null; then
      CPU=`ps -p "$PID" -o %cpu= 2>/dev/null | tr -d '[:space:]' || echo "0"`
      MEM=`ps -p "$PID" -o %mem= 2>/dev/null | tr -d '[:space:]' || echo "0"`
      echo "[OK] $svc running (PID $PID) CPU=${CPU}% MEM=${MEM}%"
    else
      echo "[ERR] $svc not running"
    fi
  else
    echo "[ERR] $svc pid file not found"
  fi
}

cmd_report() {
  mkdir -p "$START_DIR"
  BPID="null"; FPID="null"
  [ -f "$RUNDIR/backend.pid" ] && BPID=`cat "$RUNDIR/backend.pid"`
  [ -f "$RUNDIR/frontend.pid" ] && FPID=`cat "$RUNDIR/frontend.pid"`
  TMP="$REPORT.tmp"
  {
    echo "{"
    echo "  \"backend\":  {\"pid\": $BPID},"
    echo "  \"frontend\": {\"pid\": $FPID}"
    echo "}"
  } > "$TMP"
  mv "$TMP" "$REPORT"
  echo "[OK] Report written: $REPORT"
}

cmd_health() {
  check_service_health "backend" "$BACK_PORT"
  check_service_health "frontend" "$FRONT_PORT"
}

check_service_health() {
  svc="$1"
  port="$2"
  if nc -z -w 2 127.0.0.1 "$port" >/dev/null 2>&1; then
    echo "[OK] $svc healthy on port $port"
  else
    echo "[ERR] $svc port $port unreachable"
  fi
}

cmd_monitor() {
  INTERVAL="${MONITOR_INTERVAL:-30}"
  echo "==> Monitor loop (interval ${INTERVAL}s)"
  ensure_dirs
  while true; do
    cmd_status
    cmd_health
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
