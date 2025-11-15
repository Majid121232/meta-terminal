#!/usr/bin/env sh
set -eu

KEEP_REPORTS="${KEEP_REPORTS:-1}"

echo "[i] Cleaning run/"
rm -rf run
mkdir -p run

echo "[i] Cleaning logs/"
if [ "$KEEP_REPORTS" = "1" ]; then
  find logs -type f ! -name "monitor_snapshot.json" -delete 2>/dev/null || true
else
  rm -rf logs
  mkdir -p logs
fi

echo "[✔] Clean complete"
