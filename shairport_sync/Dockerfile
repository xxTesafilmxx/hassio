ARG BUILD_FROM=homeassistant/aarch64-base:latest
FROM ${BUILD_FROM}

RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk update \
    && apk add --no-cache \
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
