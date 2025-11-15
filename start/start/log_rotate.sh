#!/usr/bin/env bash
set -euo pipefail

LOGDIR="${1:-logs}"
THRESHOLD="${THRESHOLD_BYTES:-5242880}" # 5MB default

mkdir -p "$LOGDIR"
for lf in "$LOGDIR"/backend.log "$LOGDIR"/frontend.log "$LOGDIR"/monitor.log; do
  [ -f "$lf" ] || continue
  size=$(wc -c < "$lf" 2>/dev/null || echo 0)
  if [ "$size" -ge "$THRESHOLD" ]; then
    ts=$(date +%F_%H%M%S)
    mv "$lf" "${lf%.log}_$ts.log"
    : > "$lf"
    echo "[i] Rotated $lf at $ts"
  else
    echo "[i] $lf size=${size} bytes (no rotate)"
  fi
done
