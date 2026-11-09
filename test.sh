#!/usr/bin/env bash
# Alle Prüfungen für Auxy Recap: Syntax, eigene Globals, Zeichen, lokale Funktionen, Sprache, Attrappen-Test (ohne WoW).
set -e
cd "$(dirname "$0")/AuxyRecap"
luajit -bl AuxyRecap.lua >/dev/null || { echo "SYNTAXFEHLER"; exit 1; }
erlaubt='AuxyRecapDB|SLASH_AUXYRECAP1|SLASH_AUXYRECAP2'
fremd=$(luajit -bl AuxyRecap.lua | grep GSET | sed 's/.*; "//; s/"$//' | sort -u | grep -vxE "$erlaubt" || true)
[ -z "$fremd" ] || { echo "Unerwartete globale Namen: $fremd"; exit 1; }
for c in zeichen-check lokal-check sprache-check; do python3 -I ../tools/$c.py . || exit 1; done
# Regel: nur eigener Code, keine persönlichen Namen
if grep -nE "Julian|Swobu|Akando|Darlenes|Thelights|Logic Limit|LORD1" ./*; then echo "Persönliche Namen im Addon – bitte entfernen."; exit 1; fi
ausgabe=$(luajit ../tests/recap-test.lua 2>&1) || { echo "$ausgabe" | grep -E "^FEHLER|error|\.lua:" ; echo "TEST FEHLGESCHLAGEN"; exit 1; }
echo "$ausgabe" | grep -E "^FEHLER" || true; echo "$ausgabe" | tail -1
