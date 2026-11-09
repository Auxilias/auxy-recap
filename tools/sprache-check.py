#!/usr/bin/env python3
# Auxy Recap: jeder Text mit L["…"] braucht einen englischen Eintrag in der Tabelle am Dateianfang.
import re, sys
src = open(sys.argv[1] + "/AuxyRecap.lua", encoding="utf-8").read()
tab = src[src.index('GetLocale() ~= "deDE"'):src.index("-- ENDE-SPRACHTABELLE")]
have = set(re.findall(r'^\s*\["((?:[^"\\]|\\.)*)"\] = ', tab, re.M))
used = set(re.findall(r'L\["((?:[^"\\]|\\.)*)"\]', src[src.index("-- ENDE-SPRACHTABELLE"):]))
miss = sorted(used - have)
extra = sorted(have - used)
if miss: print("Englisch fehlt für:", *miss, sep="\n  "); sys.exit(1)
if extra: print("Eintrag ohne Benutzung:", *extra, sep="\n  "); sys.exit(1)
