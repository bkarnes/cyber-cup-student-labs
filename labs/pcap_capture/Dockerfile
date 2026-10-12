FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y tcpdump && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["tcpdump"]
