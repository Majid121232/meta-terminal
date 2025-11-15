#!/usr/bin/env sh
set -eu

echo "[i] Security hardening (basic)"
# Disable world-writable files
find . -type f -perm -0002 -exec chmod o-w {} \;

# Remove secrets accidentally in logs
for f in logs/*.log; do
  [ -f "$f" ] || continue
  sed -i 's/API_KEY=[^ ]\+/API_KEY=****/g' "$f" 2>/dev/null || true
done

echo "[✔] Hardening complete"
