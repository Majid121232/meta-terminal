#!/usr/bin/env sh
set -eu

ARCHIVE="${1:-}"
[ -n "$ARCHIVE" ] || { echo "Usage: restore.sh <archive.tar.gz>"; exit 1; }
[ -f "$ARCHIVE" ] || { echo "[✘] archive not found: $ARCHIVE"; exit 1; }

echo "[i] Restoring from: $ARCHIVE"
tar -xzf "$ARCHIVE" || { echo "[✘] restore failed"; exit 1; }
echo "[✔] Restore complete"
