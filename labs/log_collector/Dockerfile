FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y openssh-client rsync sudo && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash loguser && \
    echo "loguser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER loguser
WORKDIR /home/loguser

COPY fetch_logs.sh .
RUN chmod +x fetch_logs.sh

ENTRYPOINT ["./fetch_logs.sh"]
