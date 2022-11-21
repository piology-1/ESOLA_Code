In diesem Ordner befindet sich alles Nötige, um die GUI-Software auf einen
Raspberry Pi zu installieren oder upzudaten.

Alle ausführbaren Scripts sind sind entweder interaktiv oder zeigen Hinweise an,
wenn sie mit ungültigen Argumenten oder der Option `-h`/`--help` aufgerufen
werden. Für den Pi bestimmte Scripts prüfen selbstständig, ob sie auf dem Pi
ausgeführt werden, damit man nicht aufpassen muss, sie nicht versehentlich am
PC auszuführen.

Es folgt eine kurze Beschreibung aller Dateien:

### Ausführbare Scripts

- `install-local.sh` installiert/aktualisiert die GUI auf dem lokalen System
  (Raspberry Pi) in /opt.
- `install-via-ssh.sh` installiert/aktualisiert die GUI vom PC aus übers
  Netzwerk in /opt auf dem Raspberry Pi.
- `prepare-sdcard.sh` präpariert eine SD-Karte mit vorhandenem Raspberry Pi OS
  für die vollautomatische Ersteinrichtung von allem, was zum Betrieb der GUI
  notwendig ist.
- `rpi-setup-steps.sh` führt einzelne Einrichtungsschritte durch:
  Systemkonfiguration, Paketinstallation, Installation der GUI selbst.

### Sonstige Dateien/Ordner

- `install-files` bestimmt, welche Dateien installiert werden. Hier nicht
  aufgelistete Dateien werden bei der Installation weggelassen.
- `solartankstelle.service` Service-File für systemd, mit dem der Autostart
  der GUI bewerkstelligt wird.
- `qtquicktimeline/` enthält ein Debian-Build-Rezept für das Timeline-Modul
  von Qt Quick, das leider in den Debian-Repos nicht enthalten ist. Schritt 3
  in _rpi-setup-steps.sh_ erzeugt hieraus das installierbare Paket.
- `rpi-firsttimeinit.sh` wird von _prepare-sdcard.sh_ auf der SD-Karte als
  Init-Script eingerichtet und führt nacheinander alle Schritte aus
  _rpi-setup-steps.sh_ durch und zeigt eine Fortschrittsübersicht an.
  Es sollte **niemals** manuell aufgerufen werden!
