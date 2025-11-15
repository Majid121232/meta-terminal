#!/usr/bin/env sh
set -eu

BASE="${1:-.}"

echo "[i] Fixing permissions under: $BASE"
find "$BASE" -type d -exec chmod 755 {} \;
find "$BASE" -type f -name "*.sh" -exec chmod +x {} \;
find "$BASE" -type f ! -name "*.sh" -exec chmod 644 {} \;

echo "[✔] Permissions fixed"
