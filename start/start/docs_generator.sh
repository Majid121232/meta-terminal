#!/usr/bin/env sh
set -eu
OUT="DOCS.md"
echo "# Meta-Terminal Docs" > "$OUT"
echo "- Orchestrator commands: init, start, stop, status, report, health, monitor" >> "$OUT"
echo "- Start scripts: backend, frontend, dashboard, inference, agents, eval" >> "$OUT"
echo "- Tools: monitor, self_test, env_snapshot, port_guard, log_rotate" >> "$OUT"
echo "[✔] Docs generated: $OUT"
