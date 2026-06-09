#!/usr/bin/with-contenv bashio

bashio::log.info "=== Shairport Sync (Pipe Edition) startet ==="

AIRPLAY_NAME=$(bashio::config 'airplay_name')
PIPE_PATH=$(bashio::config 'pipe_path')

bashio::log.info "AirPlay Name : ${AIRPLAY_NAME}"
bashio::log.info "Pipe Pfad    : ${PIPE_PATH}"

# Pipe erstellen falls nicht vorhanden
if [ ! -p "${PIPE_PATH}" ]; then
    bashio::log.warning "Pipe fehlt – erstelle ${PIPE_PATH}..."
    mkdir -p "$(dirname ${PIPE_PATH})"
    mkfifo "${PIPE_PATH}"
    chmod 777 "${PIPE_PATH}"
    bashio::log.info "Pipe erstellt ✓"
else
    bashio::log.info "Pipe vorhanden ✓"
fi

# dbus + avahi starten
mkdir -p /var/run/dbus
dbus-daemon --system --nofork &
sleep 1
avahi-daemon --no-chroot -D
sleep 1

# shairport-sync.conf generieren
cat > /etc/shairport-sync.conf << EOF
general = {
  name = "${AIRPLAY_NAME}";
  log_verbosity = 0;
};

pipe = {
  name = "${PIPE_PATH}";
};
EOF

bashio::log.info "Starte shairport-sync..."
exec shairport-sync -o pipe
