#!/usr/bin/env sh
set -eu
PORT="${1:-5253}"
COUNT="${COUNT:-5}"
echo "[i] Latency probe on port $PORT (count $COUNT)"
for i in $(seq 1 "$COUNT"); do
  t0=$(date +%s%3N)
  curl -s --max-time 2 "http://127.0.0.1:$PORT/" >/dev/null 2>&1 || true
  t1=$(date +%s%3N)
  echo "[i] sample $i latency=$((t1 - t0)) ms"
  sleep 1
done
echo "[✔] latency probe done"
