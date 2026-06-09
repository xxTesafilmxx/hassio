ARG BUILD_FROM=homeassistant/aarch64-base:latest
FROM ${BUILD_FROM}

# Alpine 3.17 Repos explizit nutzen (kompatibel mit älteren Kerneln)
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.17/main" >> /etc/apk/repositories \
    && echo "https://dl-cdn.alpinelinux.org/alpine/v3.17/community" >> /etc/apk/repositories \
    && apk update \
    && apk add --no-cache \
        --repository https://dl-cdn.alpinelinux.org/alpine/v3.17/community \
        shairport-sync \
    && apk add --no-cache \
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
