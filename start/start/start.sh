#!/usr/bin/env sh
set -eu
echo "[i] Port guard"
./start/port_guard.sh 5253 3000 || true
echo "[i] Init and start services"
./meta-terminal.sh init
./meta-terminal.sh start
./start/self_test.sh || true
echo "[✔] start sequence done"
