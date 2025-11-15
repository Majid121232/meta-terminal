#!/usr/bin/env sh
set -eu

LOGDIR="${1:-logs}"
LINES="${LINES:-100}"

mkdir -p "$LOGDIR"

for lf in backend.log frontend.log monitor.log; do
  path="$LOGDIR/$lf"
  echo "==> $path (last $LINES lines)"
  if [ -f "$path" ]; then
    tail -n "$LINES" "$path"
  else
    echo "[i] missing: $path"
  fi
done
