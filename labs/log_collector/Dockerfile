FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y openssh-client rsync sudo && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash loguser && \
    echo "loguser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copy the script and set permissions while still root
COPY fetch_logs.sh /home/loguser/
RUN chmod +x /home/loguser/fetch_logs.sh

USER loguser
WORKDIR /home/loguser

ENTRYPOINT ["./fetch_logs.sh"]
