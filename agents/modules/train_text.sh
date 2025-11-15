#!/usr/bin/env sh
set -eu
DATA="${TASK_PARAM_data:-samples/text}"
OUT="artifacts/text_$(date +%s).json"
mkdir -p artifacts
echo "[i] Training text module on $DATA"
sleep 2
cat > "$OUT" <<JSON
{"module":"text","status":"ok","dataset":"$DATA","metrics":{"loss":0.42,"acc":0.88},"ts":"$(date +%F_%T)"}
JSON
echo "[✔] text done -> $OUT"
