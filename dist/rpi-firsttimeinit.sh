#!/bin/bash

SOLAR_ROOT=/boot/solartankstelle
LOGFILE=$SOLAR_ROOT/firsttimeinit.log
SERVICEFILE=/etc/systemd/system/firsttimeinit.service
STEPFILE=$SOLAR_ROOT/step
TMP=/run/firsttimeinit

echostep() {
    echo -e "\n* $1 [`cut -d' ' -f1 /proc/uptime`]\n"
}


if [[ ! -d $SOLAR_ROOT ]]; then
    >&2 echo "Dieses Skript ist nicht für manuellen Aufruf vorgesehen..."
    >&2 echo "Zum Einrichten der SD-Karte bitte prepare-sdcard.sh benutzen!"
    exit 1
fi

if [[ ! -f $LOGFILE ]]; then
    clear
    echo "### Ersteinrichtung DHBW Solartankstelle ###" | tee $LOGFILE
fi

if [[ $$ == 1 ]]; then
    mount -t tmpfs tmpfs /run
    mkdir -p $TMP
    mkfifo $TMP/logfifo
    tee -a $LOGFILE < $TMP/logfifo &
    exec &> $TMP/logfifo

    echostep "Erweitere Root-Dateisystem"

    # siehe /usr/lib/raspi-config/init_resize.sh
    init_resize () {
        # get_variables
        ROOT_PART_DEV=$(findmnt / -o source -n)
        ROOT_PART_NAME=$(echo "$ROOT_PART_DEV" | cut -d "/" -f 3)
        ROOT_DEV_NAME=$(echo /sys/block/*/"${ROOT_PART_NAME}" | cut -d "/" -f 4)
        ROOT_DEV="/dev/${ROOT_DEV_NAME}"
        ROOT_PART_NUM=$(cat "/sys/block/${ROOT_DEV_NAME}/${ROOT_PART_NAME}/partition")

        ROOT_DEV_SIZE=$(cat "/sys/block/${ROOT_DEV_NAME}/size")
        TARGET_END=$((ROOT_DEV_SIZE - 1))

        PARTITION_TABLE=$(parted -m "$ROOT_DEV" unit s print | tr -d 's')

        LAST_PART_NUM=$(echo "$PARTITION_TABLE" | tail -n 1 | cut -d ":" -f 1)

        ROOT_PART_LINE=$(echo "$PARTITION_TABLE" | grep -e "^${ROOT_PART_NUM}:")
        ROOT_PART_END=$(echo "$ROOT_PART_LINE" | cut -d ":" -f 3)


        # check_variables
        if [ "$ROOT_PART_NUM" -ne "$LAST_PART_NUM" ]; then
            FAIL_REASON="Root partition should be last partition"
            return 1
        fi

        if [ "$ROOT_PART_END" -gt "$TARGET_END" ]; then
            FAIL_REASON="Root partition runs past the end of device"
            return 1
        fi

        if [ ! -b "$ROOT_DEV" ] || [ ! -b "$ROOT_PART_DEV" ]; then
            FAIL_REASON="Could not determine partitions"
            return 1
        fi


        # main
        if [ "$ROOT_PART_END" -eq "$TARGET_END" ]; then
            return 2
        fi

        mount / -o remount,ro
        if ! parted -m "$ROOT_DEV" u s resizepart "$ROOT_PART_NUM" "$TARGET_END"; then
            FAIL_REASON="Root partition resize failed"
            return 1
        fi

        mount / -o remount,rw
        if ! resize2fs -f "$ROOT_PART_DEV"; then
            FAIL_REASON="Root filesystem resize failed"
            return 1
        fi
    }

    init_resize
    rc=$?
    if [[ $rc -eq 0 ]]; then
        echo "Resized root filesystem."
    elif [[ $rc -eq 2 ]]; then
        echo "Root filesystem is already expanded."
    else
        echo "Could not expand filesystem: $FAIL_REASON"
    fi

    mount / -o remount,rw
    cat <<EOF > $SERVICEFILE
[Unit]
Description=Ersteinrichtung DHBW Solartankstelle
Before=getty@tty1.service
[Service]
Type=oneshot
ExecStart=$0
TimeoutStartSec=infinity
StandardInput=tty
StandardOutput=tty
EOF
    echo -e "\n[Übergebe an systemd...]"
    exec /sbin/init --unit=firsttimeinit.service
fi

exec &> >(tee -a $LOGFILE)

# Im Hintergrund Netzwerkdienste starten
systemctl start dbus dhcpcd --no-block

if ! which dialog &>/dev/null; then
    echostep 'Installiere "dialog" für grafische Statusanzeige'
    dpkg --install $SOLAR_ROOT/dialog_*.deb
fi


STEPS=(
#Dauer #Beschreinung
    80 "Konfiguration: Benutzer, Sprache, Tastenbelegung, Zeitzone, WLAN, ..."
   490 "System aktualisieren und benötigte Pakete installieren"
   840 "Qt Quick Timeline-Modul kompilieren und installieren"
     5 "Solartankstelle installieren und Autostart aktivieren"
)

total_time=0
for (( i=0; i < ${#STEPS[@]}; i+=2 )); do
    (( total_time += STEPS[i] ))
done

max_permille=( 0 )
for (( i=0; i < ${#STEPS[@]}-2; i+=2 )); do
    time=0
    for (( j=0; j <= i; j+=2 )); do
        (( time += STEPS[j] ))
    done
    max_permille+=( $(( 1000 * time / total_time )) )
done
max_permille+=( 999 )


sl_height=$(( 4 + ${#STEPS[@]}/2 ))
stepschecklist() {
    step=`cat $STEPFILE`
    echo "\Zb\Z1Ersteinrichtung DHBW Solartankstelle\Zn"
    echo
    for (( i=1; i <= ${#STEPS[@]}/2; i++ )); do
        name="${STEPS[i*2-1]}"
        if (( i < step )); then
            echo "[√] $name"
        elif (( i == step )); then
            echo "\Zb[*] $name\Zn"
        else
            echo "[ ] $name"
        fi
    done
}

height=`tput lines`
width=`tput cols`
pwidth=$(( width * 7 / 10 ))
progressbar() {
    step=`cat $STEPFILE`
    if (( step > ${#STEPS[@]}/2 )); then
        bar_width=$pwidth
    else
        if [[ ! -f $TMP/step${step}_started_uptime ]]; then
            rm -f $TMP/step*_started_uptime
            sed 's|\([0-9]*\).*|\1|' /proc/uptime > $TMP/step${step}_started_uptime
        fi
        pm_in_step=$(( 1000 * (`sed 's|\([0-9]*\).*|\1|' /proc/uptime` - `cat $TMP/step${step}_started_uptime`) / total_time ))
        pm=$(( max_permille[step-1] + pm_in_step ))
        (( pm > max_permille[step] )) && pm=${max_permille[step]}
        bar_width=$(( pwidth * pm / 1000 ))
    fi
    dsh_width=$(( pwidth - bar_width ))

    echo -n "["
    (( bar_width > 0 )) && printf '%.0s█' $(seq 1 $bar_width)
    (( dsh_width > 0 )) && printf '%.0s-' $(seq 1 $dsh_width)
    echo "]"
}

export DIALOGRC=$TMP/dialogrc
cat <<-EOF > $DIALOGRC
	screen_color = (WHITE,WHITE,ON)
	button_active_color = (WHITE,WHITE,OFF)
	button_label_active_color = (RED,WHITE,ON)
EOF
cat /sys/module/vt/parameters/default_{red,grn,blu} > $TMP/orig_colors
setvtrgb <(echo '
	0,170,  0,170,  0,170,  0,202,142,226, 85,255, 85,255, 85,233
	0,  0,170, 85,  0,  0,170,213, 16,  0,255,255, 85, 85,255,233
	0,  0,  0,  0,170,170,170,210, 22, 26, 85, 85,255,255,255,233')


# Subshell für grafische Ausgabe:
# Ruft alle 6 Sekunden dialog neu auf (um Ladebalken zu aktualisieren).
# Mit nachfolgender Funktion redraw_dialog ist Neuaufruf außerdem auf
# Kommando möglich, um Checkliste sofort nach Abschluss eines Schrittes
# aktualisieren zu können.
exec &> /dev/tty
(
    log_pos=$(( sl_height + 1 ))
    log_height=$(( height - sl_height ))
    trap 'kill $dialog_pid' EXIT
    while true; do
        dialog --no-shadow --no-mouse \
               --begin $log_pos 0 --tailboxbg $LOGFILE $log_height $width --and-widget \
               --begin 0 0 --colors --ok-label "$(progressbar)" --msgbox "$(stepschecklist)" 10 $width &
        dialog_pid=$!
        sleep 6 & wait -n $! $dialog_pid
        [[ -f $TMP/locale_changed ]] && { set -a; . /etc/default/locale; rm -f $TMP/locale_changed; }
        kill $dialog_pid &>/dev/null
    done
) & dialog_loop=$!
trap "kill $dialog_loop; setvtrgb $TMP/orig_colors" EXIT

# Aufruf überspringt Rest der 6 Sekunden Wartezeit vorzeitig
redraw_dialog() {
    sleep_pid=`ps -o pid,ppid,comm | sed -n "s| *\([0-9]\+\) \+$dialog_loop \+sleep|\1|p"`
    [[ -n "$sleep_pid" ]] && kill $sleep_pid &>/dev/null
}

wait_for_internet() {
    if ! curl -s http://deb.debian.org -o /dev/null; then
        echo -e "\n[Warte auf Internetverbindung...]"
        while ! curl -s http://deb.debian.org -o /dev/null; do
            sleep 0.1
        done
    fi
}


# Ab hier nur nach LOGFILE ausgeben, da TTY von dialog übernommen
{
    # Bereits abgeschlossene Schritte einlesen und Unterbrechung behandeln
    [[ -f $STEPFILE ]] || echo 1 > $STEPFILE
    step=`cat $STEPFILE`
    if [[ $step == [23] ]]; then
        echostep 'Inkonsistenzen in Paketmanager nach Unterbrechung beheben'
        dpkg --configure -a
        wait_for_internet
    fi

    # Konfiguration einlesen (von prepare-install.sh generiert)
    IFS=$'\n'
    export $(cat $SOLAR_ROOT/config)
    unset IFS

    # Alle Schritte aus rpi-setup-steps.sh ausführen
    while (( step <= ${#STEPS[@]}/2 )); do
        $SOLAR_ROOT/dist/rpi-setup-steps.sh $step -u
        sync
        if [[ $step == 1 ]]; then
            set -a; . /etc/default/locale; set +a
            wait_for_internet
        fi
        echo $(( ++step )) > $STEPFILE
        sync
        redraw_dialog
    done &>> $LOGFILE

    echo -e "\n\n### Ersteinrichtung abgeschlossen ###"
    echo "`cut -d' ' -f1 /proc/uptime`s vergangen seit Systemstart"
    echo "Zeitpunkt der Fertigstellung: `date`"
} &>> $LOGFILE

# Aufräumen und normalen Systemstart anstoßen
cleanup() {
    sed -i 's| init=.*||' /boot/cmdline.txt
    install -m 644 $LOGFILE /var/log
    rm -rf $SOLAR_ROOT $TMP
    rm -f $SERVICEFILE
}
trap cleanup TERM
systemctl set-default multi-user.target &>/dev/null
systemctl isolate default.target
kill $$
