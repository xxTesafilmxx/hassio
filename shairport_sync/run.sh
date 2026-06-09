#!/usr/bin/with-contenv bashio

bashio::log.info "=== Shairport Sync (Pipe Edition) startet ==="

AIRPLAY_NAME=$(bashio::config 'airplay_name')
PIPE_PATH=$(bashio::config 'pipe_path')
LOG_LEVEL=$(bashio::config 'log_level')

bashio::log.info "AirPlay Name : ${AIRPLAY_NAME}"
bashio::log.info "Pipe Pfad    : ${PIPE_PATH}"
bashio::log.info "Log Level    : ${LOG_LEVEL}"

# shairport-sync Verbosity aus log_level ableiten
case "${LOG_LEVEL}" in
  trace|debug) VERBOSITY=3 ;;
  info)        VERBOSITY=2 ;;
  *)           VERBOSITY=1 ;;
esac
bashio::log.info "shairport Verbosity: ${VERBOSITY}"

# Pipe erstellen falls nicht vorhanden
if [ ! -p "${PIPE_PATH}" ]; then
    bashio::log.warning "Pipe fehlt – erstelle ${PIPE_PATH}..."
    mkdir -p "$(dirname ${PIPE_PATH})"
    mkfifo "${PIPE_PATH}"
    chmod 777 "${PIPE_PATH}"
    bashio::log.info "Pipe erstellt ✓"
else
    bashio::log.info "Pipe vorhanden ✓"
    ls -la "${PIPE_PATH}" | bashio::log.info "$(cat)"
fi

# DBus starten
bashio::log.info "Starte DBus..."
mkdir -p /var/run/dbus
rm -f /var/run/dbus/pid
dbus-daemon --system --nofork &
DBUS_PID=$!
sleep 2
bashio::log.info "DBus gestartet (PID: ${DBUS_PID}) ✓"

# Avahi starten
bashio::log.info "Starte Avahi..."
rm -f /var/run/avahi-daemon/pid
mkdir -p /var/run/avahi-daemon
avahi-daemon --no-chroot -D 2>&1 || bashio::log.warning "Avahi-Start fehlgeschlagen"
sleep 3

if avahi-daemon --check 2>/dev/null; then
    bashio::log.info "Avahi läuft ✓"
else
    bashio::log.warning "Avahi nicht verfügbar – mDNS funktioniert möglicherweise nicht!"
fi

# shairport-sync Version anzeigen
bashio::log.info "shairport-sync Version: $(shairport-sync --version 2>&1 | head -1)"

# Verfügbare Backends prüfen
bashio::log.info "Verfügbare Backends: $(shairport-sync -h 2>&1 | grep 'audio backend' || echo 'unbekannt')"

# shairport-sync.conf generieren
cat > /etc/shairport-sync.conf << EOF
general = {
  name = "${AIRPLAY_NAME}";
};

diagnostics = {
  log_verbosity = ${VERBOSITY};
};

stdout = {
};
EOF

bashio::log.info "Config geschrieben ✓"
bashio::log.info "--- shairport-sync.conf Inhalt ---"
cat /etc/shairport-sync.conf | while read line; do bashio::log.info "  $line"; done
bashio::log.info "---------------------------------"

bashio::log.info "Starte shairport-sync (stdout → pipe)..."
bashio::log.info "Befehl: shairport-sync -o stdout -c /etc/shairport-sync.conf > ${PIPE_PATH}"

# stdout → direkt in Pipe
exec shairport-sync -o stdout -c /etc/shairport-sync.conf > "${PIPE_PATH}"