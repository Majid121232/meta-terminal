#!/usr/bin/env sh
set -eu
echo "[i] Starting orchestrator monitor"
MONITOR_INTERVAL="${MONITOR_INTERVAL:-10}" ./meta-terminal.sh monitor
