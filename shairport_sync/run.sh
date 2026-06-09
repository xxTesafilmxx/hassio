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

# DBus starten
mkdir -p /var/run/dbus
rm -f /var/run/dbus/pid
dbus-daemon --system --nofork &
sleep 2

# Avahi starten
rm -f /var/run/avahi-daemon/pid
mkdir -p /var/run/avahi-daemon
avahi-daemon --no-chroot -D 2>&1 || bashio::log.warning "Avahi-Start fehlgeschlagen"
sleep 2

if avahi-daemon --check 2>/dev/null; then
    bashio::log.info "Avahi läuft ✓"
else
    bashio::log.warning "Avahi nicht verfügbar"
fi

# shairport-sync.conf generieren
# stdout als Output → wir schreiben selbst in die Pipe
cat > /etc/shairport-sync.conf << EOF
general = {
  name = "${AIRPLAY_NAME}";
};

diagnostics = {
  log_verbosity = 1;
};

stdout = {
};
EOF

bashio::log.info "Starte shairport-sync (stdout → pipe)..."

# shairport-sync schreibt nach stdout → direkt in Pipe umleiten
exec shairport-sync -o stdout -c /etc/shairport-sync.conf > "${PIPE_PATH}"
