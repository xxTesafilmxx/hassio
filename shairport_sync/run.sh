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

# Pipe offen halten (verhindert Blockierung wenn kein Leser da ist)
tail -f "${PIPE_PATH}" > /dev/null &
bashio::log.info "Pipe-Reader gestartet ✓"

# DBus starten und warten
mkdir -p /var/run/dbus
rm -f /var/run/dbus/pid
dbus-daemon --system --nofork &
DBUS_PID=$!
bashio::log.info "DBus gestartet (PID: ${DBUS_PID})"
sleep 2

# Avahi starten und warten
rm -f /var/run/avahi-daemon/pid
mkdir -p /var/run/avahi-daemon
avahi-daemon --no-chroot -D 2>&1 || bashio::log.warning "Avahi-Start fehlgeschlagen – fahre trotzdem fort"
sleep 2

# Avahi-Status prüfen
if avahi-daemon --check 2>/dev/null; then
    bashio::log.info "Avahi läuft ✓"
else
    bashio::log.warning "Avahi nicht verfügbar – shairport-sync startet ohne mDNS"
fi

# shairport-sync.conf generieren
cat > /etc/shairport-sync.conf << EOF
general = {
  name = "${AIRPLAY_NAME}";
};

diagnostics = {
  log_verbosity = 0;
};

pipe = {
  name = "${PIPE_PATH}";
};
EOF

bashio::log.info "Starte shairport-sync..."
exec shairport-sync -o pipe -c /etc/shairport-sync.conf
