#!/usr/bin/env bash
set -e

TARGETS=("c-backup-01" "c-db-01" "c-db-02" "c-redis-01" \
         "p-ftp-01" "p-jumpbox-01" "p-web-01" "p-web-02")
BASE="/logs"

echo "Collecting logs from lab containers..."
for T in "${TARGETS[@]}"; do
    mkdir -p "$BASE/$T"
    echo " -> $T"
    sudo docker cp "$T:/var/log/." "$BASE/$T/" 2>/dev/null || echo "   [WARN] Could not copy from $T"
done

echo "All logs saved under /logs"
exec "$@"
