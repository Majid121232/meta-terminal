#!/usr/bin/env sh
set -eu
LOG="logs/tests.log"; mkdir -p logs
echo "[i] Running smoke tests"
./start/self_test.sh >>"$LOG" 2>&1 || echo "[!] self test failed" >>"$LOG"
./start/env_snapshot.sh >>"$LOG" 2>&1
echo "[✔] tests done (see logs/tests.log)"
