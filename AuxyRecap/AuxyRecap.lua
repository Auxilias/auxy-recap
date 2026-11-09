-- Auxy Recap – Rückblick nach jedem Level-Up (WoW Forever)
--   Zeichnet Level für Level auf (Dauer, XP, Kills, Quests, Tode, Gold, viele kleine Funstats) und zeigt nach dem
--   Level-Up ein kleines Fenster mit dem Rückblick, Vergleich zum letzten Level und Prognose fürs nächste.
--   Alles pro Charakter. Befehl /auxyrecap (oder /recap). Eigener Code, MIT-Lizenz – github.com/Auxilias/auxy-recap
local ADDON = ...

-- Sprache: Deutsch (deDE) im Code als Schlüssel, alle anderen Clients bekommen Englisch. Fehlt ein Eintrag → deutscher Text.
local L = setmetatable({}, { __index = function(_, k) return k end })
local isDE = true
if GetLocale and GetLocale() ~= "deDE" then
    isDE = false
    for de, en in pairs({
        ["Level %d geschafft!"] = "Level %d done!",
        ["Zwischenstand Level %d"] = "Level %d so far",
        ["Gesamt (Level %d–%d)"] = "Total (levels %d–%d)",
        ["Spielzeit insgesamt: %s"] = "Total play time: %s",
        ["Dauer"] = "Duration",
        ["XP pro Stunde"] = "XP per hour",
        ["Kills (mit XP)"] = "Kills (with XP)",
        ["Quests abgegeben"] = "Quests turned in",
        ["Tode"] = "Deaths",
        ["Gold verdient"] = "Gold earned",
        ["Gold ausgegeben"] = "Gold spent",
        ["Gold netto"] = "Gold net",
        ["Funstats"] = "Fun stats",
        ["Weitere Funstats"] = "More fun stats",
        ["Verlauf"] = "History",
        ["Schließen"] = "Close",
        ["Prognose nächstes Level: etwa %s (Schnitt der letzten %d)"] = "Next level: about %s (average of the last %d)",
        ["Erstes Level: unvollständig (Addon kam mitten im Level dazu)."] = "First level: incomplete (addon joined mid-level).",
        ["Zwischenstand: das Level läuft noch."] = "Level still in progress.",
        ["Neuer Rekord: dein schnellstes Level!"] = "New record: your fastest level!",
        ["Dein langsamstes Level bisher."] = "Your slowest level so far.",
        ["Strecke (grob)"] = "Distance (rough)",
        ["Sprünge"] = "Jumps",
        ["Meiste Zeit in"] = "Most time in",
        ["Gebiete besucht"] = "Areas visited",
        ["Lieblingsgegner"] = "Favourite enemy",
        ["Kills pro Stunde"] = "Kills per hour",
        ["XP pro Kill (Schnitt)"] = "XP per kill (avg)",
        ["XP-Quellen"] = "XP sources",
        ["Kills"] = "kills",
        ["Quests"] = "quests",
        ["Entdeckung"] = "exploring",
        ["Ruhe-XP verbraucht"] = "Rested XP used",
        ["Neue Gebiete entdeckt"] = "New areas discovered",
        ["Gefährlichste Zone"] = "Deadliest zone",
        ["Meist gesehen vor dem Tod"] = "Most seen before dying",
        ["Als Geist unterwegs"] = "Time as a ghost",
        ["Leichenläufe"] = "Corpse runs",
        ["Auf dem Reittier"] = "Mounted",
        ["Im Flug (Flugmeister)"] = "On flights",
        ["Schwimmend"] = "Swimming",
        ["Abwesend (AFK)"] = "Away (AFK)",
        ["Im Kampf"] = "In combat",
        ["Ausgeruht (Stadt, Gasthaus)"] = "Resting (city, inn)",
        ["Items gefunden"] = "Items found",
        ["grau"] = "grey",
        ["weiß"] = "white",
        ["grün"] = "green",
        ["blau"] = "blue",
        ["episch"] = "epic",
        ["Bester Fund"] = "Best find",
        ["Gold aus Beute"] = "Gold from loot",
        ["Gold aus Quests"] = "Gold from quests",
        ["Gold pro Quest (Schnitt)"] = "Gold per quest (avg)",
        ["Beim Händler verkauft"] = "Sold to vendors",
        ["Beim Händler gekauft"] = "Bought from vendors",
        ["Reparaturen"] = "Repairs",
        ["Flugmeister"] = "Flight masters",
        ["Training"] = "Training",
        ["Post, Auktion, Handel"] = "Mail, auction, trade",
        ["Gold pro Stunde"] = "Gold per hour",
        ["Ruhestein benutzt"] = "Hearthstone used",
        ["Fähigkeiten eingesetzt"] = "Abilities used",
        ["Lieblingsfähigkeit"] = "Favourite ability",
        ["Quests angenommen"] = "Quests accepted",
        ["Tage"] = "d",
        ["Level"] = "Level",
        ["Zeit"] = "Time",
        ["Gesamt"] = "Total",
        ["Verlauf aller Level (Klick = Rückblick, Mausrad = blättern)"] = "All levels (click = recap, wheel = scroll)",
        ["Noch kein Level aufgezeichnet. Der erste Rückblick kommt beim nächsten Level-Up; /recap jetzt zeigt den Zwischenstand."] = "No level recorded yet. The first recap comes at your next level-up; /recap now shows the current level.",
        ["Level-Up %d: %s, %s XP/h, %d Kills, %d Quests, %d Tode, Gold %s"] = "Level-up %d: %s, %s XP/h, %d kills, %d quests, %d deaths, gold %s",
        ["Automatisch nach dem Level-Up zeigen"] = "Show automatically after a level-up",
        ["Kurze Zeile im Chat"] = "Short line in chat",
        ["Screenshot beim Level-Up"] = "Screenshot on level-up",
        ["Größe"] = "Size",
        ["Rückblick zeigen (letztes Level)"] = "Show recap (last level)",
        ["Zwischenstand (aktuelles Level)"] = "Current level so far",
        ["Test mit Beispielwerten"] = "Test with example values",
        ["Fensterposition zurücksetzen"] = "Reset window position",
        ["Position zurückgesetzt."] = "Position reset.",
        ["/auxyrecap – (leer) letzter Rückblick · jetzt/now Zwischenstand · verlauf/history alle Level · gesamt/total Summe · test · menü/menu · reset · debug. Rechtsklick auf die Titelzeile = Einstellungen."] = "/auxyrecap – (empty) last recap · now current level · history all levels · total sum · test · menu · reset · debug. Right-click the title bar for settings.",
        ["Beispiel-Wald"] = "Example Forest",
        ["Beispiel-Wolf"] = "Example Wolf",
        ["Beispiel-Höhle"] = "Example Cave",
        ["Beispiel-Räuber"] = "Example Bandit",
        ["Beispiel-Spinne"] = "Example Spider",
        ["Seit %s: %d Level, %s"] = "Since %s: %d levels, %s",
    }) do L[de] = en end
end
-- ENDE-SPRACHTABELLE

local db, char, cur
local frame, hist
local ctx = {}
local questCredit, questCreditT = 0, 0
local repairUntil = 0
local lastMoney, lastTick, lastX, lastY, lastInst
local lastHostile, lastHostileT
local pendingRec
local needSeed, seeding = false, false
local ShowRecap, TryShow, ShowHistory, OpenMenu

local DEFAULTS = { auto = true, chat = false, screenshot = false, scale = 1 }
local WIDTH, HEAD, ROW, FUNPAGE = 320, 24, 15, 8
local MAXLEVELS = 120

local function secret(v) return issecretvalue ~= nil and issecretvalue(v) end
local function msg(t) print("|cffffd100Auxy Recap:|r " .. t) end
local function Add(t, k, v) t[k] = (t[k] or 0) + (v == nil and 1 or v) end

-- ---------------------------------------------------------------- Formate
local SEP = isDE and "." or ","
local function Int(n)
    local s, k = tostring(math.floor((n or 0) + 0.5))
    repeat s, k = s:gsub("^(-?%d+)(%d%d%d)", "%1" .. SEP .. "%2") until k == 0
    return s
end
local function Dec1(x) local s = string.format("%.1f", x); if isDE then s = s:gsub("%.", ",") end; return s end
local function Dur(s)
    s = math.floor((s or 0) + 0.5)
    if s < 60 then return s .. " s" end
    local d, h, m = math.floor(s / 86400), math.floor(s % 86400 / 3600), math.floor(s % 3600 / 60)
    if d > 0 then return d .. " " .. L["Tage"] .. " " .. h .. " h" end
    if h > 0 then return h .. " h " .. m .. " min" end
    return m .. " min " .. (s % 60) .. " s"
end
local function DurShort(s) -- für Verlauf: knapp
    s = math.floor((s or 0) + 0.5)
    if s >= 3600 then return string.format("%d:%02d h", math.floor(s / 3600), math.floor(s % 3600 / 60)) end
    return string.format("%d:%02d", math.floor(s / 60), s % 60)
end
local function Money(c, plain)
    c = math.floor(c or 0)
    local sign = ""
    if c < 0 then sign = "-"; c = -c end
    local g, s, k = math.floor(c / 10000), math.floor(c % 10000 / 100), c % 100
    local parts = {}
    if g > 0 then parts[#parts + 1] = Int(g) .. "|cffffd700g|r" end
    if s > 0 or g > 0 then parts[#parts + 1] = s .. "|cffc7c7cfs|r" end
    parts[#parts + 1] = k .. "|cffeda55fc|r"
    return sign .. table.concat(parts, " ")
end
local function Pct(a, b) if not b or b <= 0 then return 0 end; return a / b * 100 end

local function Top(t)
    local bk, bv
    for k, v in pairs(t or {}) do if not bv or v > bv then bk, bv = k, v end end
    return bk, bv
end
local function Count(t) local n = 0; for _ in pairs(t or {}) do n = n + 1 end; return n end
local function Trim(t, n)
    if Count(t) <= n then return end
    local list = {}
    for k, v in pairs(t) do list[#list + 1] = { k, v } end
    table.sort(list, function(a, b) return a[2] > b[2] end)
    for k in pairs(t) do t[k] = nil end
    for i = 1, n do t[list[i][1]] = list[i][2] end
end

-- Formattext der Spiel-Meldungen (z. B. "%s dies, you gain %d experience.") in ein Lua-Muster verwandeln
local function Pat(fmt)
    if type(fmt) ~= "string" then return nil end
    local out, argOf, kinds, i, seq = {}, {}, {}, 1, 0
    while i <= #fmt do
        local c = fmt:sub(i, i)
        local n, k = fmt:match("^%%(%d+)%$([sd])", i)
        if n then
            argOf[#argOf + 1] = tonumber(n); kinds[tonumber(n)] = k; i = i + #n + 3
            out[#out + 1] = (k == "s") and "(.+)" or "(%d+)"
        else
            k = fmt:match("^%%([sd])", i)
            if k then
                seq = seq + 1; argOf[#argOf + 1] = seq; kinds[seq] = k; i = i + 2
                out[#out + 1] = (k == "s") and "(.+)" or "(%d+)"
            else
                if c:match("[%^%$%(%)%%%.%[%]%*%+%-%?]") then out[#out + 1] = "%" .. c else out[#out + 1] = c end
                i = i + 1
            end
        end
    end
    return { pat = "^" .. table.concat(out) .. "$", argOf = argOf, kinds = kinds }
end
local function Parse(text, P)
    if not P then return nil end
    local caps = { text:match(P.pat) }
    if #caps == 0 then return nil end
    local args = {}
    for ci, a in ipairs(P.argOf) do args[a] = caps[ci] end
    return args, P.kinds
end
local function PatList(names)
    local list = {}
    for _, g in ipairs(names) do local p = Pat(_G[g]); if p then list[#list + 1] = p end end
    return list
end
local function ParseAny(text, list)
    for _, P in ipairs(list) do local a, k = Parse(text, P); if a then return a, k end end
end
local killPats, lootPats, explorePats

-- ---------------------------------------------------------------- Daten
local function NewCur(level)
    local xpmax = UnitXPMax and UnitXPMax("player") or 0
    return { lv = level, sec = 0, xp = xpmax or 0, xpK = 0, xpQ = 0, xpE = 0, xpR = 0,
        kills = 0, quests = 0, accepted = 0, deaths = 0, ghost = 0, gain = 0, loss = 0, jumps = 0, dist = 0,
        hearth = 0, casts = 0, ex = 0, g = {}, t = {}, it = { 0, 0, 0, 0, 0, 0 },
        mobs = {}, zones = {}, dz = {}, kl = {}, sp = {}, t0 = time and time() or 0 }
end

local function InitChar()
    db.chars = db.chars or {}
    local key = (UnitName("player") or "?") .. "-" .. (GetRealmName and GetRealmName() or "")
    char = db.chars[key]
    local lvl = UnitLevel and UnitLevel("player") or 1
    if not char then
        char = { levels = {}, name = UnitName("player"), first = time and time() or 0 }
        if UnitClass then char.class = select(2, UnitClass("player")) end
        db.chars[key] = char
    end
    char.levels = char.levels or {}
    if not char.cur or char.cur.lv ~= lvl then
        local had = char.cur ~= nil
        char.cur = NewCur(lvl)
        char.cur.partial = (had or lvl > 1) and true or nil
        needSeed = lvl > 1 or had
        if lvl == 1 and not had then needSeed = false end
    end
    cur = char.cur
    lastMoney = GetMoney and GetMoney() or 0
end

local function Finish(c)
    Trim(c.mobs, 8); Trim(c.zones, 6); Trim(c.dz, 4); Trim(c.kl, 4); Trim(c.sp, 6)
    c.t1 = time and time() or 0
end

local function Sorted() -- Level absteigend
    local list = {}
    for lv, r in pairs(char.levels) do list[#list + 1] = r end
    table.sort(list, function(a, b) return a.lv > b.lv end)
    return list
end

local function Merge(into, from)
    for k, v in pairs(from) do
        if type(v) == "number" then
            if k ~= "lv" and k ~= "t0" and k ~= "t1" then into[k] = (into[k] or 0) + v end
        elseif type(v) == "table" and k ~= "best" then
            into[k] = into[k] or {}
            Merge(into[k], v)
        end
    end
    if from.best and (not into.best or from.best.q >= into.best.q) then into.best = from.best end
end
local function Total()
    local sum = { it = {}, g = {}, t = {} }
    local lo, hi
    local n = 0
    for _, r in pairs(char.levels) do
        Merge(sum, r); n = n + 1
        lo = (not lo or r.lv < lo) and r.lv or lo
        hi = (not hi or r.lv > hi) and r.lv or hi
    end
    sum.lv = hi or 0; sum.lo = lo; sum.n = n
    return sum
end

local function PlayedTotal()
    if char and char.total0 then return char.total0 + (char.acc or 0) end
end

-- ---------------------------------------------------------------- Zeitgeber
local function Tick()
    if not cur then return end
    local t = GetTime()
    local dt = t - (lastTick or t)
    lastTick = t
    if dt <= 0 or dt > 120 then return end
    cur.sec = cur.sec + dt
    char.acc = (char.acc or 0) + dt
    local ct = cur.t
    if UnitIsDeadOrGhost and UnitIsDeadOrGhost("player") then Add(ct, "dead", dt) end
    if UnitIsAFK and UnitIsAFK("player") then Add(ct, "afk", dt) end
    if IsMounted and IsMounted() then Add(ct, "mount", dt) end
    if UnitAffectingCombat and UnitAffectingCombat("player") then Add(ct, "combat", dt) end
    if UnitOnTaxi and UnitOnTaxi("player") then Add(ct, "taxi", dt) end
    if IsResting and IsResting() then Add(ct, "rest", dt) end
    if IsSwimming and IsSwimming() then Add(ct, "swim", dt) end
    local z = GetRealZoneText and GetRealZoneText()
    if type(z) == "string" and z ~= "" and not secret(z) then Add(cur.zones, z, dt) end
    if UnitPosition then
        local y, x, _, inst = UnitPosition("player")
        if type(y) == "number" and type(x) == "number" and not secret(y) and not secret(x) then
            if lastX and inst == lastInst then
                local d = math.sqrt((x - lastX) ^ 2 + (y - lastY) ^ 2)
                if d > 0 and d < 400 then cur.dist = cur.dist + d end
            end
            lastX, lastY, lastInst = x, y, inst
        else
            lastX = nil
        end
    end
    if UnitLevel and UnitXPMax and UnitLevel("player") == cur.lv then
        local m = UnitXPMax("player")
        if type(m) == "number" and m > 0 then cur.xp = m end
    end
end

-- ---------------------------------------------------------------- Gold
local function Open(name) ctx[name] = math.huge end
local function Close(name) ctx[name] = GetTime() + 1.5 end
local function Active(name) local v = ctx[name]; return v ~= nil and v > GetTime() end

local function CatPlus()
    if Active("merchant") then return "sold" end
    if Active("mail") then return "mail" end
    if Active("ah") then return "ah" end
    if Active("trade") then return "trade" end
    if Active("loot") then return "loot" end
    return "other"
end
local function CatMinus()
    if Active("merchant") then return (GetTime() < repairUntil) and "repair" or "bought" end
    if Active("taxi") then return "taxi" end
    if Active("trainer") then return "train" end
    if Active("mail") then return "mail" end
    if Active("ah") then return "ah" end
    if Active("trade") then return "trade" end
    return "other"
end

local function OnMoney()
    if not cur or not GetMoney then return end
    local m = GetMoney()
    local d = m - (lastMoney or m)
    lastMoney = m
    if d == 0 then return end
    local t = GetTime()
    if d > 0 then
        cur.gain = cur.gain + d
        if questCredit > 0 and t - questCreditT < 5 then
            local q = math.min(d, questCredit)
            questCredit = questCredit - q
            Add(cur.g, "quest", q)
            d = d - q
        end
        if d > 0 then Add(cur.g, CatPlus(), d) end
    else
        cur.loss = cur.loss - d
        Add(cur.g, CatMinus(), d)
    end
end

-- ---------------------------------------------------------------- Auswertung
local QCOL = { ["9d9d9d"] = 0, ["ffffff"] = 1, ["1eff00"] = 2, ["0070dd"] = 3, ["a335ee"] = 4, ["ff8000"] = 5 }
local function SpellName(id)
    if C_Spell and C_Spell.GetSpellName then return C_Spell.GetSpellName(id) end
    if GetSpellInfo then return (GetSpellInfo(id)) end
end

local function FunStats(r)
    local f = {}
    local function F(label, value) f[#f + 1] = { label, value } end
    local sec = r.sec or 0
    local function Share(x) return Int(Pct(x, sec)) .. " %" end
    local function TimeShare(key, label)
        local v = (r.t or {})[key]
        if v and v >= 20 then F(label, Dur(v) .. " (" .. Share(v) .. ")") end
    end
    if r.rec then F(r.rec == "fast" and "|cff66d973" .. L["Neuer Rekord: dein schnellstes Level!"] .. "|r" or L["Dein langsamstes Level bisher."], "") end
    if (r.dist or 0) > 50 then F(L["Strecke (grob)"], Dec1(r.dist * 0.9144 / 1000) .. " km") end
    if (r.jumps or 0) > 0 then F(L["Sprünge"], Int(r.jumps) .. "×") end
    local zk, zv = Top(r.zones)
    if zk then F(L["Meiste Zeit in"], zk .. " (" .. Dur(zv) .. ")") end
    local nz = Count(r.zones)
    if nz > 1 and not r.n then F(L["Gebiete besucht"], tostring(nz)) end
    local mk, mv = Top(r.mobs)
    if mk then F(L["Lieblingsgegner"], mk .. " (" .. Int(mv) .. "×)") end
    if (r.kills or 0) > 0 and sec >= 60 then F(L["Kills pro Stunde"], Int(r.kills / sec * 3600)) end
    if (r.kills or 0) > 0 and (r.xpK or 0) > 0 then F(L["XP pro Kill (Schnitt)"], Int(r.xpK / r.kills)) end
    local xs = (r.xpK or 0) + (r.xpQ or 0) + (r.xpE or 0)
    if xs > 0 then
        F(L["XP-Quellen"], Int(Pct(r.xpK or 0, xs)) .. " % " .. L["Kills"] .. " · " .. Int(Pct(r.xpQ or 0, xs)) .. " % " .. L["Quests"]
            .. ((r.xpE or 0) > 0 and (" · " .. Int(Pct(r.xpE, xs)) .. " % " .. L["Entdeckung"]) or ""))
    end
    if (r.xpR or 0) > 0 then F(L["Ruhe-XP verbraucht"], Int(r.xpR) .. " XP") end
    if (r.ex or 0) > 0 then F(L["Neue Gebiete entdeckt"], tostring(r.ex)) end
    local dk, dv = Top(r.dz)
    if dk then F(L["Gefährlichste Zone"], dk .. " (" .. Int(dv) .. "×)") end
    local kk, kv = Top(r.kl)
    if kk then F(L["Meist gesehen vor dem Tod"], kk .. " (" .. Int(kv) .. "×)") end
    if ((r.t or {}).dead or 0) >= 20 then F(L["Als Geist unterwegs"], Dur(r.t.dead)) end
    if (r.ghost or 0) > 0 then F(L["Leichenläufe"], Int(r.ghost) .. "×") end
    TimeShare("mount", L["Auf dem Reittier"])
    TimeShare("taxi", L["Im Flug (Flugmeister)"])
    TimeShare("swim", L["Schwimmend"])
    TimeShare("afk", L["Abwesend (AFK)"])
    TimeShare("combat", L["Im Kampf"])
    TimeShare("rest", L["Ausgeruht (Stadt, Gasthaus)"])
    local it = r.it or {}
    local found = {}
    local names = { [2] = L["grün"], [3] = L["blau"], [4] = L["episch"] }
    for q = 2, 4 do if (it[q + 1] or 0) > 0 then found[#found + 1] = Int(it[q + 1]) .. " " .. names[q] end end
    if #found > 0 then F(L["Items gefunden"], table.concat(found, ", ")) end
    if (it[1] or 0) > 0 or (it[2] or 0) > 0 then
        F(L["Items gefunden"], Int(it[1] or 0) .. " " .. L["grau"] .. ", " .. Int(it[2] or 0) .. " " .. L["weiß"])
    end
    if r.best and r.best.link then F(L["Bester Fund"], r.best.link) end
    local g = r.g or {}
    if (g.loot or 0) > 0 then F(L["Gold aus Beute"], Money(g.loot)) end
    if (g.quest or 0) > 0 then
        F(L["Gold aus Quests"], Money(g.quest))
        if (r.quests or 0) > 0 then F(L["Gold pro Quest (Schnitt)"], Money(g.quest / r.quests)) end
    end
    if (g.sold or 0) > 0 then F(L["Beim Händler verkauft"], Money(g.sold)) end
    if (g.bought or 0) < 0 then F(L["Beim Händler gekauft"], Money(-g.bought)) end
    if (g.repair or 0) < 0 then F(L["Reparaturen"], Money(-g.repair)) end
    if (g.taxi or 0) < 0 then F(L["Flugmeister"], Money(-g.taxi)) end
    if (g.train or 0) < 0 then F(L["Training"], Money(-g.train)) end
    local misc = (g.mail or 0) + (g.ah or 0) + (g.trade or 0)
    if misc ~= 0 then F(L["Post, Auktion, Handel"], (misc > 0 and "+" or "") .. Money(misc)) end
    if sec >= 60 and ((r.gain or 0) > 0 or (r.loss or 0) > 0) then
        local per = ((r.gain or 0) - (r.loss or 0)) / sec * 3600
        F(L["Gold pro Stunde"], (per > 0 and "+" or "") .. Money(per))
    end
    if (r.hearth or 0) > 0 then F(L["Ruhestein benutzt"], Int(r.hearth) .. "×") end
    if (r.casts or 0) > 0 then F(L["Fähigkeiten eingesetzt"], Int(r.casts)) end
    local sk, sv = Top(r.sp)
    if sk then
        local n = SpellName(sk)
        if n then F(L["Lieblingsfähigkeit"], n .. " (" .. Int(sv) .. "×)") end
    end
    if (r.accepted or 0) > 0 then F(L["Quests angenommen"], Int(r.accepted)) end
    return f
end

local function Forecast()
    local list, sum, n = Sorted(), 0, 0
    for _, r in ipairs(list) do
        if not r.partial and r.sec and r.sec > 0 and n < 3 then sum = sum + r.sec; n = n + 1 end
    end
    if n > 0 then return sum / n, n end
end

local function Delta(a, b, lowerBetter)
    if not a or not b or b <= 0 then return "" end
    local p = (a - b) / b * 100
    if math.abs(p) < 1 then return "" end
    local txt = (p > 0 and "+" or "-") .. Int(math.abs(p)) .. " %"
    if lowerBetter == nil then return " |cff9a9a9a(" .. txt .. ")|r" end
    local good = (p < 0) == lowerBetter
    return " |cff" .. (good and "66d973" or "f27366") .. "(" .. txt .. ")|r"
end

local function Snapshot() -- laufendes Level als Rückblick-Tabelle
    Tick()
    local c = {}
    for k, v in pairs(cur) do c[k] = v end
    return c
end

-- ---------------------------------------------------------------- Fenster
local function Btn(parent, text, onClick)
    local b = CreateFrame("Button", nil, parent)
    b.fs = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    b.fs:SetPoint("CENTER")
    b.fs:SetTextColor(0.24, 0.68, 0.91)
    b:SetScript("OnEnter", function() b.fs:SetTextColor(1, 1, 1) end)
    b:SetScript("OnLeave", function() b.fs:SetTextColor(0.24, 0.68, 0.91) end)
    b:SetScript("OnClick", onClick)
    b.SetLabel = function(self, t) self.fs:SetText(t); self:SetSize(math.max(40, #t * 6 + 10), 16) end
    b:SetLabel(text)
    return b
end

local function SavePoint(f)
    if not f.GetPoint then return end
    local p, _, rp, x, y = f:GetPoint()
    if p then db.point = { p, rp, x, y } end
end
local function Place(f)
    f:ClearAllPoints()
    local pt = db.point
    if pt then f:SetPoint(pt[1], UIParent, pt[2], pt[3], pt[4]) else f:SetPoint("CENTER", UIParent, "CENTER", 0, 120) end
    f:SetScale(db.scale or 1)
end
local function MakeWindow(name, w)
    local f = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    f:SetSize(w, 200)
    f:SetMovable(true); f:EnableMouse(true); f:SetClampedToScreen(true)
    f:SetFrameStrata("DIALOG")
    f:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    f:SetBackdropColor(0, 0, 0, 0.88)
    f:SetBackdropBorderColor(1, 1, 1, 0.12)
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.title:SetPoint("TOPLEFT", 10, -7)
    f.title:SetTextColor(1, 0.82, 0)
    f.title:SetShadowColor(0, 0, 0, 1); f.title:SetShadowOffset(1, -1)
    local line = f:CreateTexture(nil, "BORDER")
    line:SetPoint("TOPLEFT", 0, -HEAD); line:SetPoint("TOPRIGHT", 0, -HEAD); line:SetHeight(1)
    line:SetColorTexture(1, 0.82, 0, 0.45)
    local drag = CreateFrame("Frame", nil, f)
    drag:SetPoint("TOPLEFT"); drag:SetPoint("TOPRIGHT", -24, 0); drag:SetHeight(HEAD)
    drag:EnableMouse(true); drag:RegisterForDrag("LeftButton")
    drag:SetScript("OnDragStart", function() f:StartMoving() end)
    drag:SetScript("OnDragStop", function() f:StopMovingOrSizing(); SavePoint(f) end)
    drag:SetScript("OnMouseUp", function(self, button) if button == "RightButton" and OpenMenu then OpenMenu(self) end end)
    local x = CreateFrame("Button", nil, f)
    x:SetSize(22, 22); x:SetPoint("TOPRIGHT", -2, -1)
    x.fs = x:CreateFontString(nil, "OVERLAY", "GameFontNormal"); x.fs:SetPoint("CENTER"); x.fs:SetText("×")
    x.fs:SetTextColor(0.7, 0.7, 0.7)
    x:SetScript("OnEnter", function() x.fs:SetTextColor(1, 1, 1) end)
    x:SetScript("OnLeave", function() x.fs:SetTextColor(0.7, 0.7, 0.7) end)
    x:SetScript("OnClick", function() f:Hide() end)
    f:Hide()
    table.insert(UISpecialFrames or {}, name)
    return f
end

local function Row(f, i)
    f.rows = f.rows or {}
    local r = f.rows[i]
    if not r then
        r = {}
        r.l = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        r.l:SetJustifyH("LEFT"); r.l:SetWidth(130); r.l:SetWordWrap(false); r.l:SetTextColor(0.62, 0.62, 0.62)
        r.r = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        r.r:SetJustifyH("RIGHT"); r.r:SetWidth(WIDTH - 20 - 136); r.r:SetWordWrap(false)
        f.rows[i] = r
    end
    return r
end

local frameState = {}
local function Fill(rec, o)
    o = o or {}
    if not frame then
        frame = MakeWindow("AuxyRecapFrame", WIDTH)
        frame.sub = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        frame.sub:SetJustifyH("LEFT"); frame.sub:SetTextColor(0.62, 0.62, 0.62)
        frame.head = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.head:SetTextColor(1, 0.82, 0)
        frame.note = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        frame.note:SetJustifyH("LEFT"); frame.note:SetWidth(WIDTH - 20); frame.note:SetTextColor(0.62, 0.62, 0.62)
        frame.more = Btn(frame, L["Weitere Funstats"], function() frameState.o.page = (frameState.page or 1) + 1; Fill(frameState.rec, frameState.o) end)
        frame.hist = Btn(frame, L["Verlauf"], function() ShowHistory() end)
        frame.close = Btn(frame, L["Schließen"], function() frame:Hide() end)
        Place(frame)
    end
    if o.page == nil then o.page = 1 end
    frameState.rec, frameState.o = rec, o
    frameState.page = o.page
    local prev = o.noPrev and nil or char.levels[(rec.lv or 0) - 1]
    if o.live and not prev then local l = Sorted(); prev = l[1] end
    frame.title:SetText(o.title or string.format(L["Level %d geschafft!"], rec.lv))
    local y = -(HEAD + 6)
    frame.sub:ClearAllPoints(); frame.sub:SetPoint("TOPLEFT", 10, y)
    local pt = PlayedTotal()
    frame.sub:SetText(o.sub or (pt and string.format(L["Spielzeit insgesamt: %s"], Dur(pt)) or ""))
    y = y - 18
    for _, r in ipairs(frame.rows or {}) do r.l:Hide(); r.r:Hide() end
    local n = 0
    local function Line(label, value, vr, vg, vb)
        n = n + 1
        local r = Row(frame, n)
        r.l:ClearAllPoints(); r.l:SetPoint("TOPLEFT", 10, y)
        r.r:ClearAllPoints(); r.r:SetPoint("TOPRIGHT", -10, y)
        r.l:SetText(label); r.r:SetText(value)
        r.r:SetTextColor(vr or 1, vg or 1, vb or 1)
        r.l:Show(); r.r:Show()
        y = y - ROW
    end
    local sec = rec.sec or 0
    Line(L["Dauer"], Dur(sec) .. (prev and Delta(sec, prev.sec, true) or ""))
    if not o.live and sec >= 60 and (rec.xp or 0) > 0 then
        local ps = prev and prev.sec and prev.sec >= 60 and (prev.xp or 0) > 0
        Line(L["XP pro Stunde"], Int(rec.xp / sec * 3600) .. (ps and Delta(rec.xp / sec, prev.xp / prev.sec, false) or ""))
    end
    Line(L["Kills (mit XP)"], Int(rec.kills or 0) .. (prev and Delta(rec.kills, prev.kills) or ""))
    Line(L["Quests abgegeben"], Int(rec.quests or 0) .. (prev and Delta(rec.quests, prev.quests) or ""))
    if (rec.deaths or 0) > 0 then Line(L["Tode"], Int(rec.deaths) .. (prev and Delta(rec.deaths, prev.deaths, true) or ""), 0.95, 0.45, 0.4)
    else Line(L["Tode"], "0", 0.4, 0.85, 0.45) end
    Line(L["Gold verdient"], Money(rec.gain or 0), 0.4, 0.85, 0.45)
    Line(L["Gold ausgegeben"], Money(rec.loss or 0), 0.95, 0.45, 0.4)
    local net = (rec.gain or 0) - (rec.loss or 0)
    if net >= 0 then Line(L["Gold netto"], "+" .. Money(net), 0.4, 0.85, 0.45) else Line(L["Gold netto"], Money(net), 0.95, 0.45, 0.4) end
    y = y - 6
    local fun = FunStats(rec)
    local pages = math.max(1, math.ceil(#fun / FUNPAGE))
    local page = ((frameState.page - 1) % pages) + 1
    frameState.page = page
    frame.head:ClearAllPoints(); frame.head:SetPoint("TOPLEFT", 10, y)
    frame.head:SetText(L["Funstats"] .. (pages > 1 and (" " .. page .. "/" .. pages) or ""))
    y = y - 16
    for i = (page - 1) * FUNPAGE + 1, math.min(#fun, page * FUNPAGE) do Line(fun[i][1], fun[i][2]) end
    y = y - 4
    local note
    if o.live then
        note = L["Zwischenstand: das Level läuft noch."]
    else
        local avg, cnt = Forecast()
        if avg then note = string.format(L["Prognose nächstes Level: etwa %s (Schnitt der letzten %d)"], Dur(avg), cnt) end
    end
    if rec.partial then note = (note and (note .. "\n") or "") .. L["Erstes Level: unvollständig (Addon kam mitten im Level dazu)."] end
    if o.note then note = o.note end
    frame.note:ClearAllPoints(); frame.note:SetPoint("TOPLEFT", 10, y)
    frame.note:SetText(note or "")
    if note then y = y - (note:find("\n", 1, true) and 28 or 14) - 4 end
    y = y - 4
    frame.more:ClearAllPoints(); frame.more:SetPoint("TOPLEFT", 6, y); frame.more:SetShown(pages > 1)
    frame.close:ClearAllPoints(); frame.close:SetPoint("TOPRIGHT", -6, y)
    frame.hist:ClearAllPoints(); frame.hist:SetPoint("RIGHT", frame.close, "LEFT", -4, 0)
    y = y - 20
    frame:SetHeight(-y)
    frame:Show()
end

ShowRecap = function(rec, o)
    if not db then return end
    Fill(rec, o)
end

-- Verlauf: alle Level dieses Charakters, Klick = Rückblick
local HROWS, HW = 14, 360
local histOffset = 0
local function RefreshHistory()
    local list = Sorted()
    local total = Total()
    local maxOff = math.max(0, #list - HROWS)
    if histOffset > maxOff then histOffset = maxOff end
    if histOffset < 0 then histOffset = 0 end
    local function Cells(row, lvl, r)
        row.c[1]:SetText(lvl); row.c[2]:SetText(DurShort(r.sec or 0))
        row.c[3]:SetText((r.sec or 0) >= 60 and (r.xp or 0) > 0 and Int((r.xp or 0) / r.sec * 3600) or "-")
        row.c[4]:SetText(Int(r.kills or 0)); row.c[5]:SetText(Int(r.deaths or 0))
        row.c[6]:SetText(Money((r.gain or 0) - (r.loss or 0)))
        row.c[5]:SetTextColor((r.deaths or 0) > 0 and 0.95 or 0.6, (r.deaths or 0) > 0 and 0.45 or 0.6, (r.deaths or 0) > 0 and 0.4 or 0.6)
    end
    for i = 0, HROWS do
        local row = hist.hrows[i]
        local r, lvl
        if i == 0 then r = total; lvl = L["Gesamt"] else r = list[histOffset + i]; lvl = r and tostring(r.lv) end
        if r and (i > 0 or total.n > 0) then
            Cells(row, lvl, r)
            row.rec = r; row.isTotal = (i == 0)
            row:Show()
        else
            row:Hide()
        end
    end
    hist:SetHeight(HEAD + 20 + (HROWS + 1) * ROW + 24)
end

local function BuildHistory()
    hist = MakeWindow("AuxyRecapHistory", HW)
    hist.title:SetText(L["Verlauf"])
    hist.hint = hist:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hist.hint:SetPoint("TOPLEFT", 10, -HEAD - 5); hist.hint:SetTextColor(0.62, 0.62, 0.62)
    hist.hint:SetText(L["Verlauf aller Level (Klick = Rückblick, Mausrad = blättern)"])
    hist.hrows = {}
    local xs, ws = { 10, 52, 120, 190, 240, 280 }, { 40, 66, 66, 48, 38, 80 }
    local heads = { L["Level"], L["Zeit"], "XP/h", L["Kills"], L["Tode"], "Gold" }
    for i = 0, HROWS do
        local row = CreateFrame("Button", nil, hist)
        row:SetSize(HW - 12, ROW)
        row:SetPoint("TOPLEFT", 6, -(HEAD + 20) - i * ROW)
        row.c = {}
        for c = 1, 6 do
            local fs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            fs:SetPoint("LEFT", xs[c] - 6, 0); fs:SetWidth(ws[c]); fs:SetJustifyH(c >= 3 and "RIGHT" or "LEFT"); fs:SetWordWrap(false)
            row.c[c] = fs
        end
        row.hl = row:CreateTexture(nil, "BACKGROUND"); row.hl:SetAllPoints(); row.hl:SetColorTexture(1, 1, 1, 0)
        row:SetScript("OnEnter", function(self) self.hl:SetColorTexture(1, 1, 1, 0.08) end)
        row:SetScript("OnLeave", function(self) self.hl:SetColorTexture(1, 1, 1, 0) end)
        row:SetScript("OnClick", function(self)
            local r = self.rec
            if not r then return end
            if self.isTotal then
                Fill(r, { title = string.format(L["Gesamt (Level %d–%d)"], r.lo or 0, r.lv or 0), noPrev = true,
                    sub = string.format(L["Seit %s: %d Level, %s"], date and date("%d.%m.%Y", char.first or 0) or "", r.n or 0, Dur(r.sec or 0)) })
            else
                Fill(r)
            end
        end)
        hist.hrows[i] = row
    end
    hist:EnableMouseWheel(true)
    hist:SetScript("OnMouseWheel", function(_, d) histOffset = histOffset - d; RefreshHistory() end)
    hist.heads = {}
    for c = 1, 6 do
        local fs = hist:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetPoint("TOPLEFT", xs[c], -(HEAD + 18)); fs:SetWidth(ws[c]); fs:SetJustifyH(c >= 3 and "RIGHT" or "LEFT")
        fs:SetTextColor(1, 0.82, 0); fs:SetText(heads[c])
        hist.heads[c] = fs
    end
    hist:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    hist:SetScale(db.scale or 1)
end

ShowHistory = function()
    if not db then return end
    if not hist then BuildHistory() end
    histOffset = 0
    RefreshHistory()
    hist:Show()
end

-- ---------------------------------------------------------------- Level-Up
local function ChatLine(r)
    local sec = r.sec or 0
    msg(string.format(L["Level-Up %d: %s, %s XP/h, %d Kills, %d Quests, %d Tode, Gold %s"], r.lv, Dur(sec),
        sec >= 60 and Int((r.xp or 0) / sec * 3600) or "-", r.kills or 0, r.quests or 0, r.deaths or 0,
        Money((r.gain or 0) - (r.loss or 0))))
end

local function Records(r) -- schnellstes / langsamstes Level markieren
    if r.partial or (r.sec or 0) < 60 then return end
    local fast, slow, n = true, true, 0
    for _, o in pairs(char.levels) do
        if o ~= r and not o.partial and (o.sec or 0) >= 60 then
            n = n + 1
            if o.sec <= r.sec then fast = false end
            if o.sec >= r.sec then slow = false end
        end
    end
    if n >= 3 then r.rec = fast and "fast" or (slow and "slow" or nil) end
end

local function OnLevelUp(newLevel)
    if not cur then return end
    Tick()
    local old = cur
    Finish(old)
    old.xpDone = old.xp
    Records(old)
    char.levels[old.lv] = old
    local count = Count(char.levels)
    if count > MAXLEVELS then
        local lo
        for lv in pairs(char.levels) do if not lo or lv < lo then lo = lv end end
        char.levels[lo] = nil
    end
    cur = NewCur(newLevel)
    char.cur = cur
    if db.chat then ChatLine(old) end
    if db.auto then pendingRec = old; C_Timer.After(2, TryShow) end
end

TryShow = function()
    if not pendingRec then return end
    if (InCombatLockdown and InCombatLockdown()) or (UnitAffectingCombat and UnitAffectingCombat("player"))
        or (UnitIsDeadOrGhost and UnitIsDeadOrGhost("player")) then return end
    local r = pendingRec
    pendingRec = nil
    ShowRecap(r)
    if db.screenshot and Screenshot then C_Timer.After(1, function() pcall(Screenshot) end) end
end

-- ---------------------------------------------------------------- Ereignisse
local H = {}
H.PLAYER_LEVEL_UP = function(lv) OnLevelUp(tonumber(lv) or ((UnitLevel and UnitLevel("player")) or cur.lv + 1)) end
H.PLAYER_MONEY = OnMoney
H.QUEST_TURNED_IN = function(_, xp, money)
    if not cur then return end
    cur.quests = cur.quests + 1
    if type(xp) == "number" and not secret(xp) then cur.xpQ = cur.xpQ + xp end
    if type(money) == "number" and money > 0 and not secret(money) then questCredit = questCredit + money; questCreditT = GetTime() end
end
H.QUEST_ACCEPTED = function() if cur then cur.accepted = cur.accepted + 1 end end
H.CHAT_MSG_COMBAT_XP_GAIN = function(text)
    if not cur or type(text) ~= "string" or secret(text) then return end
    local args, kinds = ParseAny(text, killPats)
    if args then
        local name, amount, rest = nil, nil, {}
        for i = 1, #kinds do
            if kinds[i] == "s" then if i == 1 then name = args[1] else rest[#rest + 1] = args[i] end
            elseif not amount then amount = tonumber(args[i]) end
        end
        if name then cur.kills = cur.kills + 1; Add(cur.mobs, name) end
        if amount then cur.xpK = cur.xpK + amount end
        local b = tonumber(table.concat(rest, " "):match("%d+"))
        if b then cur.xpR = cur.xpR + b end
    else -- unbekanntes Format: als Kill zählen und zur Fehlersuche merken
        cur.kills = cur.kills + 1
        local n = tonumber(text:match("%d+"))
        if n then cur.xpK = cur.xpK + n end
        db.unmatched = db.unmatched or {}
        if #db.unmatched < 10 then db.unmatched[#db.unmatched + 1] = text end
    end
end
H.CHAT_MSG_SYSTEM = function(text)
    if not cur or type(text) ~= "string" or secret(text) then return end
    local args = ParseAny(text, explorePats)
    if args then cur.ex = cur.ex + 1; cur.xpE = cur.xpE + (tonumber(args[2]) or 0) end
end
H.CHAT_MSG_LOOT = function(text)
    if not cur or type(text) ~= "string" or secret(text) then return end
    local args, kinds = ParseAny(text, lootPats)
    if not args then return end
    local link, count
    for i = 1, #kinds do
        if kinds[i] == "s" and not link then link = args[i] elseif kinds[i] == "d" then count = tonumber(args[i]) end
    end
    if not link then return end
    local q = QCOL[(link:match("|c%x%x(%x%x%x%x%x%x)") or ""):lower()]
    if not q then return end
    cur.it[q + 1] = (cur.it[q + 1] or 0) + (count or 1)
    if q >= 2 and (not cur.best or q >= cur.best.q) then cur.best = { link = link, q = q } end
end
H.PLAYER_DEAD = function()
    if not cur then return end
    cur.deaths = cur.deaths + 1
    local z = GetRealZoneText and GetRealZoneText()
    if type(z) == "string" and z ~= "" and not secret(z) then Add(cur.dz, z) end
    if lastHostile and lastHostileT and GetTime() - lastHostileT < 60 then Add(cur.kl, lastHostile) end
end
H.PLAYER_UNGHOST = function() if cur then cur.ghost = cur.ghost + 1 end; C_Timer.After(3, TryShow) end
H.PLAYER_ALIVE = function() C_Timer.After(3, TryShow) end
H.PLAYER_REGEN_ENABLED = function() if pendingRec then C_Timer.After(2, TryShow) end end
H.PLAYER_TARGET_CHANGED = function()
    if UnitExists and UnitExists("target") and UnitCanAttack and UnitCanAttack("player", "target") and not UnitIsDead("target") then
        local n = UnitName("target")
        if type(n) == "string" and not secret(n) then lastHostile, lastHostileT = n, GetTime() end
    end
end
H.UNIT_SPELLCAST_SUCCEEDED = function(_, _, spellID)
    if not cur or type(spellID) ~= "number" or secret(spellID) then return end
    cur.casts = cur.casts + 1
    Add(cur.sp, spellID)
    if spellID == 8690 then cur.hearth = cur.hearth + 1 end
end
H.TIME_PLAYED_MSG = function(total, atLevel)
    if not seeding then return end
    seeding = false
    if cur and type(atLevel) == "number" then
        cur.sec = math.max(cur.sec, atLevel)
        char.total0 = total; char.acc = 0
    end
    for i = 1, NUM_CHAT_WINDOWS or 10 do
        local cf = _G["ChatFrame" .. i]
        if cf and cf.RegisterEvent then cf:RegisterEvent("TIME_PLAYED_MSG") end
    end
end
for ev, name in pairs({ MERCHANT_SHOW = "merchant", MAIL_SHOW = "mail", AUCTION_HOUSE_SHOW = "ah", TRADE_SHOW = "trade",
    TRAINER_SHOW = "trainer", TAXIMAP_OPENED = "taxi", LOOT_OPENED = "loot" }) do
    H[ev] = function() Open(name) end
end
for ev, name in pairs({ MERCHANT_CLOSED = "merchant", MAIL_CLOSED = "mail", AUCTION_HOUSE_CLOSED = "ah", TRADE_CLOSED = "trade",
    TRAINER_CLOSED = "trainer", TAXIMAP_CLOSED = "taxi", LOOT_CLOSED = "loot" }) do
    H[ev] = function() Close(name) end
end

local function SeedPlayed()
    if not needSeed or not RequestTimePlayed then return end
    needSeed = false
    seeding = true
    for i = 1, NUM_CHAT_WINDOWS or 10 do -- Blizzards Chat-Ausgabe der Spielzeit unterdrücken
        local cf = _G["ChatFrame" .. i]
        if cf and cf.UnregisterEvent then cf:UnregisterEvent("TIME_PLAYED_MSG") end
    end
    RequestTimePlayed()
    C_Timer.After(10, function() if seeding then H.TIME_PLAYED_MSG() end end)
end

H.PLAYER_LOGIN = function()
    InitChar()
    killPats = PatList({ "COMBATLOG_XPGAIN_EXPLICIT", "COMBATLOG_XPGAIN_FIRSTPERSON", "COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED" })
    lootPats = PatList({ "LOOT_ITEM_SELF_MULTIPLE", "LOOT_ITEM_SELF", "LOOT_ITEM_PUSHED_SELF_MULTIPLE", "LOOT_ITEM_PUSHED_SELF" })
    explorePats = PatList({ "ERR_ZONE_EXPLORED_XP" })
    lastTick = GetTime()
    C_Timer.NewTicker(3, Tick)
    if JumpOrAscendStart then hooksecurefunc("JumpOrAscendStart", function() if cur then cur.jumps = cur.jumps + 1 end end) end
    if RepairAllItems then hooksecurefunc("RepairAllItems", function() repairUntil = GetTime() + 3 end) end
    SeedPlayed()
end
H.PLAYER_LOGOUT = function() Tick() end

-- ---------------------------------------------------------------- Menü und Befehle
local function FillMenu(root)
    root:CreateCheckbox(L["Automatisch nach dem Level-Up zeigen"], function() return db.auto end, function() db.auto = not db.auto end)
    root:CreateCheckbox(L["Kurze Zeile im Chat"], function() return db.chat end, function() db.chat = not db.chat end)
    root:CreateCheckbox(L["Screenshot beim Level-Up"], function() return db.screenshot end, function() db.screenshot = not db.screenshot end)
    local sz = root:CreateButton(L["Größe"])
    for _, v in ipairs({ 0.8, 1, 1.2, 1.5 }) do
        sz:CreateRadio(math.floor(v * 100) .. " %", function() return (db.scale or 1) == v end, function()
            db.scale = v
            if frame then frame:SetScale(v) end
            if hist then hist:SetScale(v) end
        end)
    end
    root:CreateButton(L["Rückblick zeigen (letztes Level)"], function() SlashCmdList.AUXYRECAP("") end)
    root:CreateButton(L["Zwischenstand (aktuelles Level)"], function() SlashCmdList.AUXYRECAP("jetzt") end)
    root:CreateButton(L["Verlauf"], function() ShowHistory() end)
    root:CreateButton(L["Test mit Beispielwerten"], function() SlashCmdList.AUXYRECAP("test") end)
    root:CreateButton(L["Fensterposition zurücksetzen"], function() SlashCmdList.AUXYRECAP("reset") end)
end
OpenMenu = function(owner)
    if MenuUtil and MenuUtil.CreateContextMenu then
        MenuUtil.CreateContextMenu(owner or UIParent, function(_, root) root:CreateTitle("Auxy Recap"); FillMenu(root) end)
    end
end

local function TestRecord()
    local r = NewCur(((cur and cur.lv) or 10) - 1)
    r.lv = math.max(1, r.lv)
    r.sec = 1523; r.xp = 4200; r.xpK = 3100; r.xpQ = 900; r.xpE = 200; r.xpR = 640
    r.kills = 61; r.quests = 7; r.accepted = 9; r.deaths = 2; r.ghost = 1; r.gain = 142350; r.loss = 38200
    r.jumps = 214; r.dist = 5230; r.hearth = 1; r.casts = 388; r.ex = 3
    r.g = { loot = 61200, quest = 53150, sold = 28000, bought = -9000, repair = -12400, taxi = -4800, train = -12000 }
    r.t = { mount = 410, combat = 520, taxi = 95, rest = 130, swim = 64, afk = 40, dead = 75 }
    r.it = { 31, 20, 6, 2, 0, 0 }
    r.best = { link = "|cff0070dd|Hitem:0::::::::::::|h[Beispiel-Schwert]|h|r", q = 3 }
    r.mobs = { [L["Beispiel-Wolf"]] = 24, [L["Beispiel-Spinne"]] = 17, [L["Beispiel-Räuber"]] = 9 }
    r.zones = { [L["Beispiel-Wald"]] = 1100, [L["Beispiel-Höhle"]] = 423 }
    r.dz = { [L["Beispiel-Höhle"]] = 2 }
    r.kl = { [L["Beispiel-Räuber"]] = 2 }
    r.sp = {}
    r.partial = nil
    return r
end

SLASH_AUXYRECAP1 = "/auxyrecap"
SLASH_AUXYRECAP2 = "/recap"
SlashCmdList.AUXYRECAP = function(arg)
    if not db or not cur then return end
    arg = (arg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    if arg == "" then
        local list = Sorted()
        if list[1] then ShowRecap(list[1]) else msg(L["Noch kein Level aufgezeichnet. Der erste Rückblick kommt beim nächsten Level-Up; /recap jetzt zeigt den Zwischenstand."]); ShowRecap(Snapshot(), { live = true, title = string.format(L["Zwischenstand Level %d"], cur.lv) }) end
    elseif arg == "jetzt" or arg == "now" or arg == "live" then
        ShowRecap(Snapshot(), { live = true, title = string.format(L["Zwischenstand Level %d"], cur.lv) })
    elseif arg == "verlauf" or arg == "history" then
        ShowHistory()
    elseif arg == "gesamt" or arg == "total" then
        local t = Total()
        if t.n == 0 then msg(L["Noch kein Level aufgezeichnet. Der erste Rückblick kommt beim nächsten Level-Up; /recap jetzt zeigt den Zwischenstand."]); return end
        ShowRecap(t, { title = string.format(L["Gesamt (Level %d–%d)"], t.lo or 0, t.lv or 0), noPrev = true,
            sub = string.format(L["Seit %s: %d Level, %s"], date and date("%d.%m.%Y", char.first or 0) or "", t.n, Dur(t.sec or 0)) })
    elseif arg == "test" then
        ShowRecap(TestRecord(), { noPrev = true })
    elseif arg == "menü" or arg == "menu" or arg == "optionen" then
        OpenMenu(frame or UIParent)
    elseif arg == "reset" then
        db.point = nil
        if frame then Place(frame) end
        msg(L["Position zurückgesetzt."])
    elseif arg == "debug" then
        Tick()
        msg("Level " .. cur.lv .. ", " .. Dur(cur.sec) .. ", Kills " .. cur.kills .. ", Quests " .. cur.quests .. ", Tode " .. cur.deaths
            .. ", Gold +" .. cur.gain .. "/-" .. cur.loss .. ", Sprünge " .. cur.jumps .. ", Gebiete " .. Count(cur.zones)
            .. ", nicht erkannte XP-Meldungen: " .. #(db.unmatched or {}))
        for _, t in ipairs(db.unmatched or {}) do msg("  " .. t) end
    else
        msg(L["/auxyrecap – (leer) letzter Rückblick · jetzt/now Zwischenstand · verlauf/history alle Level · gesamt/total Summe · test · menü/menu · reset · debug. Rechtsklick auf die Titelzeile = Einstellungen."])
    end
end

-- ---------------------------------------------------------------- Start
local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        if ... ~= ADDON then return end
        AuxyRecapDB = AuxyRecapDB or {}
        db = AuxyRecapDB
        for k, v in pairs(DEFAULTS) do if db[k] == nil then db[k] = v end end
        for e in pairs(H) do
            if e == "UNIT_SPELLCAST_SUCCEEDED" then pcall(self.RegisterUnitEvent, self, e, "player")
            elseif e ~= "TIME_PLAYED_MSG" then pcall(self.RegisterEvent, self, e) end
        end
        self:UnregisterEvent("ADDON_LOADED")
        return
    end
    local h = H[event]
    if h then h(...) end
end)
-- TIME_PLAYED_MSG nur während des Einlesens beim ersten Start
do
    local seedFrame = CreateFrame("Frame")
    seedFrame:RegisterEvent("TIME_PLAYED_MSG")
    seedFrame:SetScript("OnEvent", function(_, e, ...) H.TIME_PLAYED_MSG(...) end)
end
