#!/usr/bin/env sh
set -eu

OUT="${1:-backup_$(date +%F_%H%M%S).tar.gz}"
INCLUDE="${INCLUDE:-run logs start/*.sh meta-terminal.sh}"

echo "[i] Creating backup: $OUT"
tar -czf "$OUT" $INCLUDE 2>/dev/null || {
  echo "[✘] backup failed"
  exit 1
}
echo "[✔] Backup created: $OUT"
