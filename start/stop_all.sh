#!/bin/bash#!/usr/bin/env bash
# ============================================# stop_all.sh 
# - auto generated script Meta-Terminal Advanced Stopperecho 
# "Running stop_all.sh ..." Features: - Reads PID file - 
# Safe kill with checks - Colored output - JSON update 
# ============================================
set -euo pipefail PIDFILE="start/pids.json" 
REPORT="start/report.json" RED='\033[0;31m'; 
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m' 
function stop_service() {
  local name=$1 local pid=$(jq -r ".$name" $PIDFILE) if [ 
  "$pid" != "null" ]; then
    if kill -0 $pid 2>/dev/null; then kill $pid && echo -e 
      "${GREEN}[✔] Stopped $name (PID $pid)${NC}" \
        && jq --arg n "$name" '.[$n]="stopped"' $REPORT > 
        ${REPORT}.tmp && mv ${REPORT}.tmp $REPORT
    else echo -e "${YELLOW}[!] $name not running (PID $pid 
      invalid)${NC}"
    fi else echo -e "${RED}[✘] No PID found for $name${NC}" 
  fi
}
echo -e "${YELLOW}==> Stopping all services...${NC}" 
stop_service "backend" stop_service "frontend"
echo -e "${GREEN}All stop operations attempted.${NC}"
