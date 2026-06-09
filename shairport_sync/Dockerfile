ARG BUILD_FROM=homeassistant/aarch64-base:latest
FROM ${BUILD_FROM}

# Build-Abhängigkeiten
RUN apk add --no-cache \
    git \
    build-base \
    autoconf \
    automake \
    libtool \
    pkgconfig \
    avahi-dev \
    alsa-lib-dev \
    libconfig-dev \
    openssl-dev \
    popt-dev \
    soxr-dev \
    glib-dev \
    dbus-dev \
    avahi \
    avahi-tools \
    dbus \
    alsa-utils \
    libconfig \
    openssl \
    popt \
    soxr \
    glib

# shairport-sync aus Source bauen (stabile Version 4.3.2)
RUN git clone --depth 1 --branch 4.3.2 \
    https://github.com/mikebrady/shairport-sync.git /tmp/shairport-sync \
    && cd /tmp/shairport-sync \
    && autoreconf -i \
    && ./configure \
        --with-alsa \
        --with-avahi \
        --with-ssl=openssl \
        --with-soxr \
        --with-pipe \
    && make -j$(nproc) \
    && make install \
    && rm -rf /tmp/shairport-sync

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
