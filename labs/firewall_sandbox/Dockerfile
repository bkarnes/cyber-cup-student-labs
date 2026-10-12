FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y iptables iproute2 rsyslog netcat-openbsd curl && rm -rf /var/lib/apt/lists/*

# Simple rsyslog config for iptables logging
RUN echo ':msg, contains, "iptables:" /var/log/iptables/iptables.log' \
    >> /etc/rsyslog.d/iptables.conf && \
    echo '& ~' >> /etc/rsyslog.d/iptables.conf && \
    mkdir -p /var/log/iptables && \
    service rsyslog restart

COPY test_traffic.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/test_traffic.sh

CMD ["bash"]
