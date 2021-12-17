FROM telegraf:1.21.1-alpine

RUN apk add --update-cache \
    busybox-initscripts \
    curl \
    coreutils \
  && mkdir -p /etc/default \
  && rm -rf /var/cache/apk/*

ENV INFLUX_DB=FAIL \
    POWERWALL_PASSWORD=FAIL \
    COOKIE_FILE=/var/tmp/PWcookie.txt \
    POWERWALL_IP=powerwall

COPY root /

CMD ["/docker-entrypoint.sh"]