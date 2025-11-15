#!/usr/bin/env bash
set -euo pipefail

OUT="${1:-start/report.json}"
RUNDIR="run"
BACK_PORT="${BACK_PORT:-5253}"
FRONT_PORT="${FRONT_PORT:-3000}"

mkdir -p "$(dirname "$OUT")"

bp="null"; fp="null"
[ -f "$RUNDIR/backend.pid" ] && bp="$(cat "$RUNDIR/backend.pid")"
[ -f "$RUNDIR/frontend.pid" ] && fp="$(cat "$RUNDIR/frontend.pid")"

cat > "$OUT.tmp" <<JSON
{
  "backend":  {"pid": $bp, "port": $BACK_PORT},
  "frontend": {"pid": $fp, "port": $FRONT_PORT}
}
JSON

mv "$OUT.tmp" "$OUT"
echo "[✔] Report written: $OUT"
