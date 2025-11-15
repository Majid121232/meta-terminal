#!/usr/bin/env sh
set -eu

OUT="${1:-start/env_snapshot.json}"
mkdir -p "$(dirname "$OUT")"

BACK_PORT="${BACK_PORT:-5253}"
FRONT_PORT="${FRONT_PORT:-3000}"

ts="$(date +%F_%H:%M:%S)"
bp="null"; fp="null"
[ -f run/backend.pid ] && bp="$(cat run/backend.pid)"
[ -f run/frontend.pid ] && fp="$(cat run/frontend.pid)"

cat > "$OUT.tmp" <<JSON
{
  "timestamp": "$ts",
  "env": {
    "PATH": "$(echo "$PATH" | sed 's/"/\\"/g')",
    "SHELL": "${SHELL:-/bin/sh}"
  },
  "backend": {"pid": $bp, "port": $BACK_PORT},
  "frontend": {"pid": $fp, "port": $FRONT_PORT}
}
JSON
mv "$OUT.tmp" "$OUT"
echo "[✔] Env snapshot: $OUT"
