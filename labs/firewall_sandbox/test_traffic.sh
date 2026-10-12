#!/usr/bin/env bash
set -e

echo "=== Basic connectivity checks ==="
curl -s http://p-web-01/ > /dev/null && echo "Web OK" || echo "Web BLOCKED"
nc -z -w3 p-jumpbox-01 22 && echo "SSH OK" || echo "SSH BLOCKED"
nc -z -w3 p-ftp-01 21 && echo "FTP OK" || echo "FTP BLOCKED"
