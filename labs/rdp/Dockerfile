FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install a lightweight Xfce desktop and xrdp
RUN apt-get update && \
    apt-get install -y xfce4 xfce4-terminal xrdp && \
    rm -rf /var/lib/apt/lists/*

# Create a user that matches the SMB credentials
RUN useradd -m -s /bin/bash rdpuser && \
    echo "rdpuser:Password123" | chpasswd

# Allow the user to log in via xrdp
RUN echo "rdpuser" > /etc/xrdp/users

EXPOSE 3389
CMD ["/usr/sbin/xrdp","-nodaemon"]
