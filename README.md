<p align="center">
  <img src="https://raw.githubusercontent.com/Auxilias/auxy-recap/main/media/logo.png" width="110" alt="Auxy Recap Logo">
</p>

<h1 align="center">Auxy Recap</h1>

<p align="center">
  Level-Rückblick für <b>World of Warcraft: Forever</b><br>
  <i>Level recap for World of Warcraft: Forever – <a href="#english">English below</a></i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/WoW%20Forever-1.60.1-1eff00" alt="WoW Forever 1.60.1">
  <img src="https://img.shields.io/badge/Sprache-Deutsch%20%2F%20English-lightgrey" alt="Sprache: Deutsch / English">
  <a href="https://github.com/Auxilias/auxy-recap/blob/main/LICENSE"><img src="https://img.shields.io/github/license/Auxilias/auxy-recap?color=blue" alt="Lizenz"></a>
</p>

Nach jedem Level-Up zeigt Auxy Recap ein kleines Fenster: wie lange das Level gedauert hat, wie viel XP pro Stunde, Kills, Quests, Tode und wohin das Gold ging. Dazu kommen viele kleine Funstats, ein Vergleich mit deinem letzten Level und eine Prognose fürs nächste.

## Funktionen

- **Rückblick nach jedem Level-Up:** Dauer, XP pro Stunde, Kills, Quests, Tode, Gold verdient und ausgegeben. Zahlen im Vergleich zum Level davor, in Grün oder Rot. Im Kampf wartet das Fenster, bis der Kampf vorbei ist.
- **Auszeichnung fürs Level:** „Der Sprinter“, „Unsterblich“, „Geistwanderer“, „Hüpfer“, „Reisender“, „Questheld“ und mehr, aus deinen Zahlen abgeleitet.
- **Rund 30 Funstats:** Strecke, Sprünge, Lieblingsgegner, Zeit auf dem Reittier, im Flug, schwimmend, AFK oder im Kampf, Ruhe-XP, entdeckte Gebiete, gefährlichste Zone, bester Fund, Gold nach Quelle (Beute, Quests, Händler, Reparatur, Flug, Training), Ruhestein, Lieblingsfähigkeit. Alles auf einer Seite in zwei Spalten.
- **Kampfwerte** (nach jedem Kampf aus Blizzards Schadensmesser): Kämpfe, Schaden gesamt und je Kampf, bester Kampf (DPS) und größter Kampf mit Gegner, stärkster Zauber, erlittener Schaden, knappster Kampf (Anteil des Lebens), Heilung. Krits gibt die Spiel-API nicht her.
- **Aussehen:** goldener WoW-Rahmen (Standard), schlicht schwarz oder wie Auxy UI Suite.
- **Live-Tempo:** eine schmale Zeile zeigt, wie viel vom Level geschafft ist, wie lange es noch dauert und ob du schneller oder langsamer bist als dein Schnitt.
- **Verlauf und Gesamt:** alle Level eines Charakters als Liste. Klick zeigt den Rückblick des Levels, „Gesamt“ die Summe.
- **Teilen:** `/recap teilen` schickt einen Einzeiler in Gruppe oder Gilde.
- **Pro Charakter gespeichert.** Optional Chat-Zeile oder Screenshot beim Level-Up.

## Installation

1. Von [Releases](https://github.com/Auxilias/auxy-recap/releases/latest) die `AuxyRecap.zip` herunterladen.
2. Entpacken nach `World of Warcraft\_forever_\Interface\AddOns\`. Danach liegt dort der Ordner `AuxyRecap`.
3. WoW neu starten.

## Bedienung

Zum Ausprobieren `/recap test` eingeben. Das zeigt den Rückblick mit Beispielwerten.

| Befehl | Was passiert |
|---|---|
| `/recap` | letzter Rückblick |
| `/recap jetzt` | Zwischenstand des laufenden Levels |
| `/recap verlauf` | alle Level als Liste |
| `/recap gesamt` | Summe über alle Level |
| `/recap teilen [gilde\|gruppe\|sagen]` | Einzeiler in den Chat |
| `/recap menü` | Einstellungen |
| `/recap reset` | Fensterposition zurücksetzen |
| `/recap debug` | Zähler zur Fehlersuche |

Verschieben über die goldene Titelzeile, Rechtsklick auf die Titelzeile öffnet die Einstellungen. Das Live-Tempo verschiebst du mit Shift + ziehen.

## Gut zu wissen

- Kills zählen aus den Meldungen „… stirbt, Ihr bekommt X Erfahrung“. Graue Gegner ohne XP werden nicht gezählt.
- Kommt das Addon mitten im Level dazu, ist dieses erste Level unvollständig (Kills und Quests davor sind unbekannt). Die Zeit wird aus `/played` gelesen und stimmt.
- Die Oberfläche ist **Deutsch bei deutschem Client, sonst Englisch**. Befehle gibt es deutsch und englisch.
- Fehler oder Ideen gerne als [Issue](https://github.com/Auxilias/auxy-recap/issues). Bei Lua-Fehlern hilft der Text aus BugSack.

## Wie es entstanden ist

Auxy Recap ist ein Hobbyprojekt für meine Gruppe in WoW Forever. Der Code ist größtenteils mit KI geschrieben (Claude von Anthropic). Ideen, Tests im Spiel und die Entscheidung, was rein kommt, kommen von mir.

## Lizenz

MIT, siehe [LICENSE](https://github.com/Auxilias/auxy-recap/blob/main/LICENSE).

---

## English

After every level-up, Auxy Recap shows a small window: how long the level took, XP per hour, kills, quests, deaths and where your gold went. On top come lots of small fun stats, a comparison with your last level and a forecast for the next one.

### Features

- **Recap after every level-up:** duration, XP per hour, kills, quests, deaths, gold earned and spent. Numbers are compared with the previous level in green or red. In combat the window waits until the fight is over.
- **An award for the level:** "The Sprinter", "Immortal", "Ghost Walker", "Bunny Hopper", "Globetrotter", "Quest Hero" and more, derived from your numbers.
- **About 30 fun stats:** distance, jumps, favourite enemy, time mounted, on flights, swimming, AFK or in combat, rested XP, areas discovered, deadliest zone, best find, gold by source (loot, quests, vendors, repairs, flights, training), hearthstone, favourite ability. All on one page in two columns.
- **Combat stats** (after every fight, from Blizzard's damage meter): fights, total damage and per fight, best fight (DPS) and biggest fight with the enemy, strongest spell, damage taken, closest call (share of your health), healing. The game API does not expose crits.
- **Look:** golden WoW frame (default), plain black, or like Auxy UI Suite.
- **Live pace:** a slim line shows how far into the level you are, how long it still takes and whether you're faster or slower than your average.
- **History and total:** all levels of a character as a list. Click shows that level's recap, "Total" the sum.
- **Share:** `/recap share` sends a one-liner to party or guild.
- **Saved per character.** Optional chat line or screenshot on level-up.

### Installation

1. Download `AuxyRecap.zip` from [Releases](https://github.com/Auxilias/auxy-recap/releases/latest).
2. Unpack it to `World of Warcraft\_forever_\Interface\AddOns\`. You then have a folder `AuxyRecap` there.
3. Restart WoW.

### Usage

Type `/recap test` to try it. It shows the recap with example values.

| Command | What it does |
|---|---|
| `/recap` | last recap |
| `/recap now` | current level so far |
| `/recap history` | all levels as a list |
| `/recap total` | sum over all levels |
| `/recap share [guild\|party\|say]` | one-liner to chat |
| `/recap menu` | settings |
| `/recap reset` | reset window position |
| `/recap debug` | counters for troubleshooting |

Move the window by dragging the golden title bar; right-click the title bar for settings. Move the live pace line with Shift + drag.

### Good to know

- Kills are counted from the "… dies, you gain X experience" messages. Grey enemies without XP are not counted.
- If you install the addon mid-level, that first level is incomplete (earlier kills and quests are unknown). The time is read from `/played` and is correct.
- The interface is **German on German clients and English on all others**. Commands work in German and English.
- Bugs or ideas are welcome as an [issue](https://github.com/Auxilias/auxy-recap/issues). For Lua errors, the text from BugSack helps.

### How it was made

Auxy Recap is a hobby project for my group in WoW Forever. The code is largely written with AI (Claude by Anthropic). Ideas, in-game testing and deciding what goes in come from me.

### License

MIT, see [LICENSE](https://github.com/Auxilias/auxy-recap/blob/main/LICENSE).
