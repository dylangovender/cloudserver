FROM ghcr.io/linuxserver/calibre:latest

USER root
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends inotify-tools bash \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY run.sh /app/run.sh
COPY kindle_map.csv /app/kindle_map.csv
RUN chmod +x /app/run.sh

ENV TZ=Africa/Johannesburg
CMD ["/app/run.sh"]
