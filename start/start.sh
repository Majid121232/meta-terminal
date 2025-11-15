#!/usr/bin/env bash
# ============================================# start.sh - 
# auto generated script Meta-Terminal Advanced Starterecho 
# "Running start.sh ..." Features: - Colored output - JSON 
# reporting with timestamps - PID tracking - Health checks - 
# Resource monitoring 
# ============================================
set -euo pipefail REPORT="start/report.json" LOGDIR="logs" 
PIDFILE="start/pids.json" mkdir -p $LOGDIR
# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; 
NC='\033[0m' function log_step() { echo -e "${YELLOW}==> 
$1${NC}"; } function success() { echo -e "${GREEN}[✔] 
$1${NC}"; } function fail() { echo -e "${RED}[✘] $1${NC}"; } 
function write_json() {
  local key=$1; local value=$2 jq --arg k "$key" --arg v 
  "$value" '.[$k]=$v' $REPORT > ${REPORT}.tmp && mv 
  ${REPORT}.tmp $REPORT
}
function monitor_resources() { local name=$1; local pid=$2 
  local cpu=$(ps -p $pid -o %cpu= | tr -d ' ') local 
  mem=$(ps -p $pid -o %mem= | tr -d ' ') jq --arg n "$name" 
  --arg cpu "$cpu" --arg mem "$mem" \
     '.[$n]={"cpu":$cpu,"mem":$mem}' $REPORT > ${REPORT}.tmp 
     && mv ${REPORT}.tmp $REPORT
}
# Init report
echo "{}" > $REPORT; echo "{}" > $PIDFILE log_step 
"Initializing logs..." ./start/init_logs.sh && success "Logs 
ready" && write_json "init_logs" "success" || { fail "Logs 
failed"; write_json "init_logs" "fail"; } log_step 
"Installing Python deps..." ./start/install_python.sh && 
success "Python deps installed" && write_json 
"install_python" "success" || { fail "Python install 
failed"; write_json "install_python" "fail"; } log_step 
"Installing Node deps..." ./start/install_node.sh && success 
"Node deps installed" && write_json "install_node" "success" 
|| { fail "Node install failed"; write_json "install_node" 
"fail"; } log_step "Starting backend..." nohup 
./start/start_backend.sh > $LOGDIR/backend_$(date 
+%F_%T).log 2>&1 & BACK_PID=$! success "Backend started (PID 
$BACK_PID)" write_json "backend_pid" "$BACK_PID" jq --arg 
pid "$BACK_PID" '.backend=$pid' $PIDFILE > ${PIDFILE}.tmp && 
mv ${PIDFILE}.tmp $PIDFILE monitor_resources "backend" 
$BACK_PID log_step "Starting frontend..." nohup 
./start/start_frontend.sh > $LOGDIR/frontend_$(date 
+%F_%T).log 2>&1 & FRONT_PID=$! success "Frontend started 
(PID $FRONT_PID)" write_json "frontend_pid" "$FRONT_PID" jq 
--arg pid "$FRONT_PID" '.frontend=$pid' $PIDFILE > 
${PIDFILE}.tmp && mv ${PIDFILE}.tmp $PIDFILE 
monitor_resources "frontend" $FRONT_PID success "All 
services started successfully!"
echo "Report written to $REPORT"
