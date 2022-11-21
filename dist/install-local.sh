#!/bin/bash

TARGETDIR="/opt/Solartankstelle_GUI"
TARGETUID=1000
TARGETGID=1000


usage() {
    echo "Aufruf: ${0##*/} [OPTION...]"
    echo
    echo "  -a, --autostart   Automtische Ausführung bei Systemstart aktivieren"
    echo "  -f, --force       Schutz vor Installation auf Nicht-Raspberry-Pi-Gerät umgehen"
    echo "  -h, --help        Nur diese Hilfe anzeigen und nichts tun"
}


_autostart=0
_force=0
while (( $# > 0 )); do
    case "$1" in
        -a|--autostart)
            _autostart=1
            ;;
        -f|--force)
            _force=1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            >&2 echo -e "Ungültige Option: $1\n"
            >&2 usage
            exit 1
            ;;
    esac
    shift
done

if [[ $_force != 1 ]] && ! which raspi-config &>/dev/null; then
    >&2 echo "Dies scheint kein Raspberry Pi OS zu sein."
    >&2 echo "Die Installation wird daher sicherheitshalber verweigert."
    >&2 echo "Um trotzdem zu installieren bitte mit -f ausführen."
    exit 1
fi

if (( EUID != 0 )); then
    >&2 echo "Installation benötigt Root-Rechte. Bitte mit sudo ausführen."
    exit 1
fi

cd "$(dirname "$0")/.."

echo "Kopiere Dateien nach $TARGETDIR..."
rsync -a --files-from=<(find $(cat dist/install-files)) --out-format='@@%n' . "$TARGETDIR" | sed "s|^@@|$TARGETDIR/|"

echo "Setze Dateirechte..."
chown -R "$TARGETUID:$TARGETGID" "$TARGETDIR"
chmod -R a=r,a+X,u+w "$TARGETDIR"
chmod +x "$TARGETDIR/gui_main.py"

echo "Installiere Systemd-Unit..."
install -m 644 dist/solartankstelle.service /etc/systemd/system/
systemctl daemon-reload
if systemctl is-enabled --quiet solartankstelle; then
    echo "Hinweis: Autostart ist bereits aktiv"
elif [[ $_autostart == 1 ]]; then
    echo "Aktiviere Autostart..."
    systemctl enable solartankstelle
else
    echo "Hinweis: Autostart kann mit folgendem Kommando aktiviert werden:"
    echo "  sudo systemctl enable solartankstelle"
fi

echo "Installation abgeschlossen"
