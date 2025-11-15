#!/usr/bin/env sh
set -eu

echo "[i] Updating permissions and line endings"
find start -type f -name "*.sh" -exec dos2unix {} \; 2>/dev/null || true
find start -type f -name "*.sh" -exec chmod +x {} \;

echo "[✔] Update complete"
