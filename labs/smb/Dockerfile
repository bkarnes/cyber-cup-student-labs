FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Samba and basic utilities
RUN apt-get update && \
    apt-get install -y samba && \
    rm -rf /var/lib/apt/lists/*

# Create a shared directory (guest‑readable) and a private one
RUN mkdir -p /srv/smb/public && chmod 777 /srv/smb/public && \
    mkdir -p /srv/smb/private && chown root:root /srv/smb/private

# Copy a flag file that will be used by the workbooks
COPY files/flag.txt /srv/smb/public/

# Create a user that will be used for credential‑reuse testing
RUN useradd -M -s /usr/sbin/nologin smbuser && \
    echo "smbuser:Password123" | chpasswd

# Samba configuration
RUN cat > /etc/samba/smb.conf <<'EOF'
[global]
   workgroup = WORKGROUP
   server string = Samba Server
   security = user
   map to guest = Bad User
   log level = 1
   dns proxy = no

[public]
   path = /srv/smb/public
   guest ok = yes
   read only = yes

[private]
   path = /srv/smb/private
   valid users = smbuser
   read only = no
EOF

EXPOSE 445
CMD ["smbd","-FS","-S"]
