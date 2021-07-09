FROM telegraf:1.19.1-alpine

RUN apk add --update-cache \
    busybox-initscripts \
    curl \
    coreutils \
  && mkdir -p /etc/default \
  && rm -rf /var/cache/apk/*

ENV INFLUX_DB=tasks.monitor_influxdb:8086 \
    POWERWALL_PASSWORD=FAIL \
    COOKIE_FILE=/var/tmp/PWcookie.txt \
    POWERWALL_IP=powerwall

COPY root /

CMD ["/docker-entrypoint.sh"]