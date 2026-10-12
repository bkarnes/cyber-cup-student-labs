FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y curl ftp dnsutils netcat-openbsd openssh-client smbclient freerdp2-x11 && rm -rf /var/lib/apt/lists/*
COPY generate_traffic.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/generate_traffic.sh
ENTRYPOINT ["/usr/local/bin/generate_traffic.sh"]
