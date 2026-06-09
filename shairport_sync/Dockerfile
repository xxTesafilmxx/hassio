ARG BUILD_FROM=homeassistant/aarch64-base:latest
FROM ${BUILD_FROM}

# Abhängigkeiten aus Alpine 3.18 (im Base-Image vorhanden)
RUN apk add --no-cache \
    avahi \
    avahi-tools \
    dbus \
    alsa-utils \
    libconfig \
    openssl \
    popt \
    libglib \
    libsoxr

# shairport-sync-4.3.2-r1 direkt aus Alpine 3.20 Community installieren
RUN wget -q https://dl-cdn.alpinelinux.org/alpine/v3.20/community/aarch64/shairport-sync-4.3.2-r1.apk \
    -O /tmp/shairport-sync.apk \
    && apk add --no-cache --allow-untrusted /tmp/shairport-sync.apk \
    && rm /tmp/shairport-sync.apk

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
