ARG BUILD_FROM=homeassistant/aarch64-base:latest
FROM ${BUILD_FROM}

RUN apk add --no-cache \
    shairport-sync \
    avahi \
    avahi-tools \
    dbus \
    alsa-utils \
    libconfig \
    openssl \
    popt

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
