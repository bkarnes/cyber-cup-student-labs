#!/usr/bin/env bash
set -e

# Give services a moment to start
sleep 5

echo "=== HTTP ==="
curl -s http://p-web-01/ > /dev/null
curl -s http://p-web-02/ > /dev/null

echo "=== FTP ==="
ftp -inv p-ftp-01 <<EOF
user anonymous ""
binary
get dummy.txt
quit
EOF

echo "=== DNS ==="
dig @127.0.0.1 example.com > /dev/null

echo "=== SMTP (netcat) ==="
printf "HELO test\r\nMAIL FROM:<test@example.com>\r\nRCPT TO:<test@example.com>\r\nDATA\r\nTest email\r\n.\r\nQUIT\r\n" |
  nc -w3 127.0.0.1 25 || true

echo "=== SSH ==="
ssh -o StrictHostKeyChecking=no -o PasswordAuthentication=no p-jumpbox-01 "echo ssh-ok"

echo "=== SMB ==="
smbclient //smb/private -U smbuser%Password123 -c 'ls' > /dev/null

echo "=== RDP (auth‑only) ==="
xfreerdp /v:rdp /u:rdpuser /p:Password123 +auth-only > /dev/null 2>&1 || true

echo "Traffic generation complete."
