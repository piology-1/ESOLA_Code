#!/bin/bash

SOLARTANKSTELLE_HOSTNAME=${SOLARTANKSTELLE_HOSTNAME:-solartankstelle}
SOLARTANKSTELLE_USERNAME=${SOLARTANKSTELLE_USERNAME:-solar}

red="\e[31m"
yellow="\e[33m"
bold="\e[1m"
clear="\e[0m"

PID=$$
trap "exit 1" USR1


# Inspiriert von https://stackoverflow.com/a/63503388
askpass() {
    charcount=0
    prompt=''
    reply=''
    while IFS= read -n1 -p "$prompt" -r -s char; do
        case "$char" in
            $'\000') # NUL
                break
                ;;
            $'\010'|$'\177') # BACKSPACE, DELETE
                if (( charcount > 0 )); then
                    prompt=$'\b \b'
                    reply="${reply%?}"
                    (( charcount-- ))
                else
                    prompt=''
                fi
                ;;
            *)
                (( charcount > 0 )) && prompt=$'\b'"*$char" || prompt="$char"
                reply+="$char"
                (( charcount++ ))
                ;;
        esac
    done
    (( charcount > 0 )) && printf '\b*\n' >&2 || printf '\n' >&2
    echo "$reply"
}

crypt_password() {
    [[ -z "$1" ]] && return 1
    if which openssl &>/dev/null; then
        echo "$1" | openssl passwd -6 -stdin
    elif which python &>/dev/null; then
        python -c 'import crypt; print(crypt.crypt("'"$1"'", crypt.mksalt(crypt.METHOD_SHA512)))'
    else
        >&2 echo -e "${bold}${red}FEHLER:${clear} Kann Passwort nicht crypten, da weder openssl noch python verfügbar!"
        return 1
    fi
}

download() {
    url="$1"
    if (( $# >= 2 )); then
        target="$2/${url##*/}"
    fi

    if which curl &>/dev/null; then
        curl -fsSL "$url" ${target:+-o "$target"} 2>.tmp-dl-err
    elif which wget &>/dev/null; then
        wget -q "$url" -O "${target:--}" 2>.tmp-dl-err
    else
        >&2 echo -e "${bold}${red}FEHLER:${clear} Downloads unmöglich, da weder curl noch wget verfügbar!"
        kill -USR1 $PID
    fi
    if (( $? != 0 )); then
        >&2 echo -e "${bold}${red}FEHLER${clear} beim Abruf von $url:"
        >&2 cat .tmp-dl-err
        rm -f .tmp-dl-err
        kill -USR1 $PID
    fi
    rm -f .tmp-dl-err
}

is_rpi_sdcard() {
    [[ -f "$1/cmdline.txt" ]] || return 1
    [[ -f "$1/issue.txt" ]] || return 1
    [[ -n "$(grep -F "pi-gen" "$1/issue.txt")" ]] || return 1
    return 0
}

find_rpi_sdcard() {
    while read -a l; do
        [[ "${l[1]}" == "on" ]] || return
        if is_rpi_sdcard "${l[2]}"; then
            echo "${l[2]}" "${l[0]}"
            return 0
        fi
    done < <(LC_ALL=C mount | grep -F " type vfat")
    return 1
}

get_build_date() {
    date=$(sed -n "s|Raspberry Pi reference \([0-9-]*\)$|\1|p" "$BOOT/issue.txt")
    echo "${date:=unbekannt}"
}

get_pigen_commit() {
    commit=$(sed -n "s|.*pi-gen, \([0-9a-f]*\), .*|\1|p" "$BOOT/issue.txt")
    echo "${commit:=master}"
}

get_architecture() {
    [[ -f "$BOOT/kernel7.img" ]] && echo armhf || echo arm64
}

get_debian_release() {
    rel="$(download "https://github.com/RPi-Distro/pi-gen/raw/$PIGEN_COMMIT/build.sh" \
           | grep -F "export RELEASE=" | sed "s|.*:-\(.*\)}.*|\1|")"
    echo "${rel:-bullseye}"
}

download_dialog_deb() {
    set +f
    rm -f "$TARGETDIR"/dialog*.deb
    url="$(download "https://packages.debian.org/$DEBIAN_REL/$ARCH/dialog/download" \
           | grep -F ' href="http://ftp.de.debian.org/' | sed 's|.*href="\(.*\)".*|\1|')"
    download "$url" "$TARGETDIR"
}

install_files() {
    cd "$(dirname "$0")/.."
    rsync -a --files-from=<(find $(cat dist/install-files) dist/) . "$TARGETDIR"
}

modify_cmdline() {
    sed -i 's| init=.*||' "$BOOT/cmdline.txt"
    sed -i 's| systemd.run=.*||' "$BOOT/cmdline.txt"
    [[ -z $(grep -F ' quiet' "$BOOT/cmdline.txt") ]] && _quiet='quiet ' || _quiet=''
    sed -i 's|$|'"$_quiet"' init=/bin/bash -- -c "mount -t proc proc /proc; mount -t sysfs sys /sys; mount /boot; fsck.fat -a $(findmnt /boot -o source -n); exec /boot/solartankstelle/dist/rpi-firsttimeinit.sh"|' "$BOOT/cmdline.txt"
}



echo
while ! sdcard=( $(find_rpi_sdcard) ); do
    echo "Keine SD-Karte mit Raspberry Pi OS gefunden."
    echo "Bitte die SD-Karte einbinden und Enter drücken."
    echo -e "${bold}Hinweis:${clear} Nach Flashen von Raspberry Pi OS muss die SD-Karte"
    echo "eventuell neu eingesteckt werden, um zu erscheinen."
    read
done
BOOT="${sdcard[0]}"
TARGETDIR="$BOOT/solartankstelle"
PIGEN_COMMIT="$(get_pigen_commit)"
DEBIAN_REL="$(get_debian_release)"
ARCH="$(get_architecture)"

echo "Raspberry Pi OS gefunden:"
echo -e "  Gerät .......... ${bold}${sdcard[1]}${clear}"
echo -e "  Debian ......... ${bold}$DEBIAN_REL${clear}"
echo -e "  Architektur .... ${bold}$ARCH${clear}"
echo -e "  Build-Datum .... ${bold}$(get_build_date)${clear}"

echo -ne "\nBitte ${bold}sicheres${clear} Passwort festlegen (leer lassen für Login nur mit SSH-Key): "
cryptedPw="$(crypt_password $(askpass))" || cryptedPw=""
[[ -z "$cryptedPw" ]] && echo "Login wird nur mit SSH-Key möglich sein."

echo
if [[ ! -f "$HOME/.ssh/id_ed25519.pub" ]]; then
    if which ssh-keygen &>/dev/null; then
        echo "Generiere neuen SSH-Key vom Typ ed25519, da noch keiner vorhanden..."
        ssh-keygen -q -t ed25519 -f "$HOME/.ssh/id_ed25519" -N ""
    else
        echo -e "${bold}${yellow}WARNUNG:${clear} Kein SSH-Key vom Typ ed25519 vorhanden und kann"
        echo "keinen generieren, da ssh-keygen nicht installiert!"
    fi
fi
if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
    sshKey=( `cat "$HOME/.ssh/id_ed25519.pub"` )
    echo "Lokaler Key (${sshKey[2]}) wird für SSH-Login autorisiert."
else
    sshKey=()
    echo "Login über SSH wird nur mit Passwort möglich sein."
fi

if [[ -z "$cryptedPw" && -z "$sshKey" ]]; then
    echo -e "\n${bold}${yellow}WARNUNG:${clear} Weder Passwort noch SSH-Key sind für Login definiert!"
    echo "Für alle Aktionen, die Login erfordern (z. B. install-via-ssh.sh),"
    echo "wird dies vorher manuell behoben werden müssen..."
fi

echo -ne "\nBitte WLAN-SSID eingeben (leer lassen für Verbindung nur über LAN-Kabel): "
read -r wifiSsid
if [[ -z "$wifiSsid" ]]; then
    echo "Internetverbindung wird LAN-Kabel benötigen."
else
    valid=0
    while [[ $valid == 0 ]]; do
        echo -n "Bitte WLAN-Passwort eingeben: "
        wifiPass="$(askpass)"
        if [[ -z "$wifiPass" ]] || (( ${#wifiPass} >= 8 && ${#wifiPass} <= 63 )); then
            valid=1
        else
            echo "Ungültige Eingabe: Muss 8-63 Zeichen lang sein!"
        fi
    done
fi
echo


mkdir -p "$TARGETDIR" || {
    >&2 echo -e "${bold}${red}FEHLER:${clear} Die SD-Karte ist schreibgeschützt!"
    exit 1
}
echo "SD-Karte wird vorbereitet..."
CONFIG="$TARGETDIR/config"
rm -f "$CONFIG"
echo "SOLARTANKSTELLE_HOSTNAME=$SOLARTANKSTELLE_HOSTNAME" >> "$CONFIG"
echo "SOLARTANKSTELLE_USERNAME=$SOLARTANKSTELLE_USERNAME" >> "$CONFIG"
echo "SOLARTANKSTELLE_CRYPTEDPW=$cryptedPw" >> "$CONFIG"
echo "SOLARTANKSTELLE_SSHKEY=${sshKey[@]}" >> "$CONFIG"
echo "SOLARTANKSTELLE_WIFISSID=$wifiSsid" >> "$CONFIG"
echo "SOLARTANKSTELLE_WIFIPASS=$wifiPass" >> "$CONFIG"

download_dialog_deb
install_files
modify_cmdline

sync
echo "SD-Karten-Vorbereitung abgeschlossen!"
