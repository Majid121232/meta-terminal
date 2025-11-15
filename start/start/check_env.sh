#!/usr/bin/env sh
set -eu
echo "[i] Checking environment"
for cmd in python3 curl nc httpd; do
  if command -v "$cmd" >/dev/null 2>&1; then echo "[✔] $cmd found"; else echo "[✘] $cmd missing"; fi
done
echo "[✔] Env check complete"
