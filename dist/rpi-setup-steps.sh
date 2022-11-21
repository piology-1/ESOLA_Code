#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

_uptime=0
echostep() {
    if [[ $_uptime == 0 ]]; then
        echo -e "\n* $1\n"
    else
        echo -e "\n* $1 [`cut -d' ' -f1 /proc/uptime`]\n"
    fi
}

insert_after_line() {
    target="$1"
    line="$2"
    tmp=`mktemp -p /run`
    head -n$line "$target" >> $tmp
    cat /dev/stdin >> $tmp
    tail -n+$((line+1)) "$target" >> $tmp
    mv -f $tmp "$target"
}

usage() {
    echo "Aufruf: ${0##*/} <[1] [2] [3] [4]> [-u] [-h]"
    echo "Schritte zur Einrichtung der Solartankstelle auf Raspberry Pi OS ausführen."
    echo
    echo "1 - Systemkonfiguration"
    echo "  Nimmt länderspezifische Einstellungen für Deutschland am System vor, setzt den der"
    echo "  GPU zugewiesenen Anteil am RAM auf 256MB und aktiviert den SSH-Dienst."
    echo "  Weitere Einstellungen werden jeweils vorgenommen, wenn bei Ausführung des Skripts"
    echo "  folgende Umgebungsvariablen gesetzt sind:"
    echo "   - SOLARTANKSTELLE_HOSTNAME, zum Setzen des Netzwerk-Hostnamens"
    echo "   - SOLARTANKSTELLE_USERNAME, zum Einrichten bzw. Ändern des Standardbenutzers"
    echo "   - SOLARTANKSTELLE_CRYPTEDPW, Passwort für obigen Benutzer (im crypt-Format)"
    echo "   - SOLARTANKSTELLE_SSHKEY, zum Autorisieren eines SSH-Schlüssels für Remote-Login"
    echo "   - SOLARTANKSTELLE_WIFISSID, Zugangspunkt-Name zur Einrichtung eines WLAN-Netzwerks"
    echo "   - SOLARTANKSTELLE_WIFIPASS, Passwort für obigen WLAN-Zugangspunkt (als Klartext)"
    echo
    echo "2 - Systemupdate und Installation von Abhängigkeiten"
    echo "  Installiert die Pakete, die zum Betrieb der GUI benötigt werden."
    echo "  Außerdem werden vorinstallierte Pakete aktualisiert, damit am Ende alle Pakete im"
    echo "  System auf einem einheitlichen Stand sind."
    echo
    echo "3 - Installation des Qt Quick Timeline-Moduls"
    echo "  Dieses Modul wird von der GUI benutzt, aber von den Maintainern leider erst seit"
    echo "  Debian 12 \"bookworm\", welches zum Zeitpunkt der Erstellung der GUI noch nicht als"
    echo "  stabil eingestuft war, bereitgestellt, und auch dort erst für Qt 6."
    echo "  Daher ist es für die Inbetriebnahme der GUI nötig, es manuell zu kompilieren."
    echo "  Dieser Schritt automatisiert die doch recht umständliche Prozedur hierfür."
    echo
    echo "4 - Installation der Solartankstellen-GUI selbst"
    echo "  Installiert die vorliegenden Dateien der GUI nach /opt, legt einen Systemdienst an"
    echo "  und aktiviert ihn, damit sie direkt beim Hochfahren automatisch gestartet wird."
    echo "  Identisch zu Aufruf des Skripts install-local.sh mit Option --autostart."
    echo
    echo "Optionen:"
    echo "  -u, --uptime   Bei jedem Teilschritt Zeit seit Systemstart in Sekunden mit ausgeben"
    echo "  -h, --help     Nur diese Hilfe anzeigen und nichts tun"
}


_steps=
while (( $# > 0 )); do
    case "$1" in
        [1-4])
            _steps=$_steps$1
            ;;
        -u|--uptime)
            _uptime=1
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
if [[ -z "$_steps" ]]; then
    >&2 echo -e "Es wurden keine auszuführenden Schritte angegeben!\n"
    >&2 usage
    exit 1
fi

if ! which raspi-config &>/dev/null; then
    >&2 echo "Dieses Skript ist nur für Raspberry Pi OS geeignet!"
    exit 1
fi

if (( EUID != 0 )); then
    >&2 echo "Dieses Skript benötigt Root-Rechte. Bitte mit sudo ausführen."
    exit 1
fi



# Konfiguration: Benutzer, Sprache, Tastenbelegung, Zeitzone, WLAN, ...
#######################################################################
if [[ $_steps == *1* ]]; then
    if [[ -n "${SOLARTANKSTELLE_HOSTNAME-}" ]]; then
        echostep "Setze Hostnamen auf \"$SOLARTANKSTELLE_HOSTNAME\""
        raspi-config nonint do_hostname "$SOLARTANKSTELLE_HOSTNAME"
        hostnamectl set-hostname "$SOLARTANKSTELLE_HOSTNAME"
        systemctl restart dhcpcd --no-block
    fi

    if [[ -n "${SOLARTANKSTELLE_USERNAME-}" ]]; then
        echostep "Richte Benutzer \"$SOLARTANKSTELLE_USERNAME\" ein"
        [[ -z "$SOLARTANKSTELLE_CRYPTEDPW" ]] && SOLARTANKSTELLE_CRYPTEDPW="!!"
        /usr/lib/userconf-pi/userconf "$SOLARTANKSTELLE_USERNAME" "$SOLARTANKSTELLE_CRYPTEDPW"
        rm -f /etc/systemd/system/getty@tty1.service.d/autologin.conf

        if [[ -n "${SOLARTANKSTELLE_SSHKEY-}" ]]; then
            echostep "Erlaube SSH-Login für \"$(echo "$SOLARTANKSTELLE_SSHKEY" | cut -d' ' -f3)\""
            sshdir="/home/$SOLARTANKSTELLE_USERNAME/.ssh"
            if [[ ! -d "$sshdir" ]]; then
                mkdir -p "$sshdir"
                chown "$SOLARTANKSTELLE_USERNAME:$SOLARTANKSTELLE_USERNAME" "$sshdir"
            fi
            authorized_keys="$sshdir/authorized_keys"
            if [[ ! -f "$authorized_keys" || -z "$(grep "${SOLARTANKSTELLE_SSHKEY-}" "$authorized_keys")" ]]; then
                echo "$SOLARTANKSTELLE_SSHKEY" >> "$authorized_keys"
                chown "$SOLARTANKSTELLE_USERNAME:$SOLARTANKSTELLE_USERNAME" "$authorized_keys"
                chmod 600 "$authorized_keys"
            fi
        fi
    fi

    echostep 'Erhöhe GPU-Speicheranteil auf 256MB'
    raspi-config nonint do_memory_split 256

    echostep 'Setze Sprache auf Deutsch'
    [[ -d /run/firsttimeinit ]] && touch /run/firsttimeinit/locale_changed
    raspi-config nonint do_change_locale de_DE.UTF-8
    [[ -d /run/firsttimeinit ]] && touch /run/firsttimeinit/locale_changed
    set -a; . /etc/default/locale; set +a

    echostep 'Setze Tastenbelegung auf Deutsch'
    raspi-config nonint do_configure_keyboard de

    echostep 'Setze Zeitzone auf Berlin'
    raspi-config nonint do_change_timezone Europe/Berlin

    echostep 'Setze WLAN-Ländercode auf DE'
    #raspi-config nonint do_wifi_country DE
    killall wpa_supplicant &>/dev/null
    wpaconf=/etc/wpa_supplicant/wpa_supplicant.conf
    line=`grep -nm1 '^network=' $wpaconf` && line=$(( `echo $line | cut -d: -f1` - 1 )) || line=`wc -l $wpaconf | cut -d' ' -f1`
    blnk=`head -n$line $wpaconf | tac | grep -vnm1 '^[ '$'\t'']*$'` && blnk=$(( `echo $blnk | cut -d: -f1` - 1 )) || blnk=$line
    (( line -= blnk ))
    if grep -q '^country=' $wpaconf; then
        sed -i 's|^country=.*|country=DE|g' $wpaconf
    else
        insert_after_line $wpaconf $line <<<"country=DE"
        (( line += 1 ))
    fi
    rfkill unblock wifi
    for filename in /var/lib/systemd/rfkill/*:wlan ; do
        echo 0 > $filename
    done

    if [[ -n "${SOLARTANKSTELLE_WIFISSID-}" ]]; then
        echostep "Richte WLAN \"$SOLARTANKSTELLE_WIFISSID\" ein"
        #raspi-config nonint do_wifi_ssid_passphrase "$SOLARTANKSTELLE_WIFISSID" "${SOLARTANKSTELLE_WIFIPASS:-}"
        if [[ -n "${SOLARTANKSTELLE_WIFIPASS:-}" ]]; then
            if (( ${#SOLARTANKSTELLE_WIFIPASS} < 8 || ${#SOLARTANKSTELLE_WIFIPASS} > 63 )); then
                >&2 echo "FEHLER: Passwort ist nicht 8-63 Zeichen lang!"
            else
                auth="psk=$(wpa_passphrase "$SOLARTANKSTELLE_WIFISSID" "$SOLARTANKSTELLE_WIFIPASS" | sed -n 's|[ \t]\+psk=\(.*\)|\1|p')"
            fi
        else
            auth='key_mgmt=NONE'
        fi
        if [[ -n "${auth-}" ]] && ! grep "^[ "$'\t'"]*ssid=\"$SOLARTANKSTELLE_WIFISSID\"" -B2 -A3 $wpaconf | grep -q "$auth"; then
            insert_after_line $wpaconf $line <<EOF

network={
	ssid="$SOLARTANKSTELLE_WIFISSID"
	$auth
}
EOF
        fi
    fi
    systemctl restart dhcpcd --no-block

    echostep 'Aktiviere SSH-Dienst'
    ls /etc/ssh/ssh_host_*_key &>/dev/null || systemctl start regenerate_ssh_host_keys
    systemctl enable --now ssh --no-block
fi



# System aktualisieren und benötigte Pakete installieren
########################################################
if [[ $_steps == *2* ]]; then
    echostep 'Aktualisiere System'
    until apt-get update -y -q; do :; done
    until apt-get upgrade -y -q; do :; done

    echostep 'Installiere benötigte Pakete'
    PACKAGES=(
        python3-pyside2.qtquick
        qml-module-qtqml
        qml-module-qtquick2
        qml-module-qtquick-window2
        qml-module-qtgraphicaleffects
    )
    apt-get install -y -q "${PACKAGES[@]}"
fi



# Qt Quick Timeline-Modul kompilieren und installieren
######################################################
if [[ $_steps == *3* ]]; then
    echostep 'Kompiliere Qt Quick Timeline'

    # Build-Dateien in neues temporäres Verzeichnis kopieren
    BUILDDIR=/tmp/qtquicktimeline-build
    mkdir -p "$BUILDDIR"
    cp -r "${0%/*}"/qtquicktimeline "$BUILDDIR"
    cd "$BUILDDIR"/qtquicktimeline

    # Versionsnummer durch die des installierten Qt ersetzen
    DEBIAN="$BUILDDIR/qtquicktimeline/debian"
    src_version=`head -n1 "$DEBIAN/changelog" | sed 's|.*(\([0-9\.]*\).*|\1|'`
    inst_version=`dpkg -s libqt5qml5 | grep '^Version:' | sed 's|.* \([0-9\.]*\).*|\1|'`
    [[ -n "$src_version" && -n "$inst_version" ]] \
        && sed -i "s|$src_version|$inst_version|g" "$DEBIAN/changelog" "$DEBIAN/control"

    # Build-Deps installieren und Quellarchiv herunterladen und entpacken
    until apt-get install -y -q devscripts; do :; done
    until mk-build-deps --install --remove --tool='apt-get -y --no-install-recommends'; do :; done
    origtargz --unpack

    # Parallele Jobs begrenzen auf Anzahl CPU-Threads und Anzahl verfügbarer GB RAM abzüglich 320 MB
    mem_free_gb=`awk '/MemTotal/ { printf "%d \n", ($2/1024-320)/1024 }' /proc/meminfo`
    cpu_cores=`nproc`
    jobs=$(( mem_free_gb < cpu_cores ? mem_free_gb : cpu_cores ))
    jobs=$(( jobs >= 1 ? jobs : 1 ))

    # Paket bauen
    dpkg-buildpackage -b -j$jobs --no-sign

    echostep 'Installiere Qt Quick Timeline'
    apt-get install -y -q ../qml-module-qtquick-timeline_*.deb

    echostep 'Lösche Build-Verzeichnis und entferne Build-Deps'
    cd /tmp
    rm -rf "$BUILDDIR"
    apt-get purge devscripts qtquicktimeline-opensource-src-build-deps -y -q
    apt-get autoremove --purge -y -q
    apt-get clean -y -q
fi



# Solartankstelle installieren und Autostart aktivieren
#######################################################
if [[ $_steps == *4* ]]; then
    echostep 'Installiere Solartankstelle und aktiviere Autostart'
    "${0%/*}"/install-local.sh -a
fi
