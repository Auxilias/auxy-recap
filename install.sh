#!/usr/bin/env bash
# Kopiert Auxy Recap ins Spiel (nur bei geschlossenem WoW). Vorher laufen die Tests.
set -e
cd "$(dirname "$0")"
ZIEL="$HOME/Faugus/battlenet/drive_c/Program Files (x86)/World of Warcraft/_forever_/Interface/AddOns/AuxyRecap"
if pgrep -f "[W]ow\.exe" >/dev/null; then echo "WoW läuft noch – bitte erst beenden (oder Dateien von Hand kopieren)."; exit 1; fi
./test.sh
mkdir -p "$ZIEL"
cp AuxyRecap/AuxyRecap.lua AuxyRecap/AuxyRecap.toc AuxyRecap/README.txt AuxyRecap/LICENSE "$ZIEL/"
echo "Installiert nach: $ZIEL"
