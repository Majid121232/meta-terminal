#!/usr/bin/env bash
set -euo pipefail

RUNDIR="run"
OUT="${1:-start/crash_snapshot.json}"
BACK_PORT="${BACK_PORT:-5253}"
FRONT_PORT="${FRONT_PORT:-3000}"

mkdir -p "$(dirname "$OUT")"

alive() { local pid="$1"; kill -0 "$pid" 2>/dev/null; }

bp="null"; fp="null"; bstat="down"; fstat="down"
[ -f "$RUNDIR/backend.pid" ] && bp="$(cat "$RUNDIR/backend.pid")" && alive "$bp" && bstat="up"
[ -f "$RUNDIR/frontend.pid" ] && fp="$(cat "$RUNDIR/frontend.pid")" && alive "$fp" && fstat="up"

curl -s --max-time 2 "http://127.0.0.1:$BACK_PORT/health" | grep -q '"status":"ok"' && bhealth="ok" || bhealth="fail"
curl -s --max-time 2 "http://127.0.0.1:$FRONT_PORT/health" | grep -q '"status":"ok"' && fhealth="ok" || fhealth="fail"

ts="$(date +%F_%H:%M:%S)"
cat > "$OUT.tmp" <<JSON
{
  "timestamp": "$ts",
  "backend":  {"pid": $bp, "state": "$bstat", "health": "$bhealth"},
  "frontend": {"pid": $fp, "state": "$fstat", "health": "$fhealth"}
}
JSON
mv "$OUT.tmp" "$OUT"

if [ "$bstat" = "down" ] || [ "$fstat" = "down" ] || [ "$bhealth" = "fail" ] || [ "$fhealth" = "fail" ]; then
  echo "[✘] Crash or unhealthy detected. Snapshot: $OUT"
  exit 1
fi

echo "[✔] All services healthy. Snapshot: $OUT"
