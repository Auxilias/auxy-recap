-- Attrappen-Test für Auxy Recap. Aufruf: cd AuxyRecap && luajit ../tests/recap-test.lua
local fail, total = 0, 0
local function check(name, ok) total = total + 1; if not ok then fail = fail + 1; io.stdout:write("FEHLER: ", name, "\n") end end
local noop = function() end
local mt = { __index = function(t, k) if type(k) == "string" and k:match("^%u") then return noop end end }

local now, frames, timers
local pos, locale
local function setup(loc)
    now, frames, timers, pos = 1000, {}, {}, { 0, 0 }
    locale = loc
    GetLocale = function() return loc end
    GetTime = function() return now end
    time = function() return 1700000000 end
    date = os.date
    local function region()
        local o = setmetatable({ pts = {} }, mt)
        o.Show = function(s) s.shown = true end; o.Hide = function(s) s.shown = false end
        o.IsShown = function(s) return s.shown == true end
        o.SetShown = function(s, v) s.shown = v and true or false end
        o.SetText = function(s, t) s.text = t end
        o.SetPoint = function(s, ...) s.pts[#s.pts + 1] = { ... } end
        o.ClearAllPoints = function(s) s.pts = {} end
        o.SetHeight = function(s, h) s.h = h end
        o.SetSize = function(s, w, h) s.w, s.h = w, h end
        o.SetWidth = function(s, w) s.w = w end
        return o
    end
    CreateFrame = function(kind, name, parent)
        local f = region()
        f.parent = parent
        f.scripts = {}
        f.SetScript = function(s, n, fn) s.scripts[n] = fn end
        f.CreateTexture = function() return region() end
        f.CreateFontString = function() return region() end
        f.RegisterEvent = function(s, e) s.ev = s.ev or {}; s.ev[e] = true end
        f.RegisterUnitEvent = function(s, e) s.ev = s.ev or {}; s.ev[e] = true end
        f.UnregisterEvent = function(s, e) if s.ev then s.ev[e] = nil end end
        if name then _G[name] = f end
        frames[#frames + 1] = f
        return f
    end
    UIParent = CreateFrame("Frame", "UIParent")
    C_Timer = { After = function(sec, fn) timers[#timers + 1] = { now + sec, fn } end, NewTicker = function(sec, fn) timers[#timers + 1] = { now + sec, fn, every = sec } end }
    hooksecurefunc = function(name, fn) _G["__hook_" .. name] = fn end
    JumpOrAscendStart = noop
    RepairAllItems = noop
    InCombatLockdown = function() return false end
    UnitAffectingCombat = function() return false end
    UnitIsDeadOrGhost = function() return false end
    UnitName = function() return "Grimbold" end
    GetRealmName = function() return "Testrealm" end
    UnitClass = function() return "Warrior", "WARRIOR" end
    UnitLevel = function() return 10 end
    UnitXPMax = function() return 4000 end
    UnitPosition = function() return pos[1], pos[2], 0, 1 end
    GetRealZoneText = function() return "Example Forest" end
    IsMounted = function() return false end
    UnitIsAFK = function() return false end
    UnitOnTaxi = function() return false end
    IsResting = function() return false end
    IsSwimming = function() return false end
    money = 5000
    GetMoney = function() return money end
    RequestTimePlayed = nil
    print = noop
    SlashCmdList = {}
    AuxyRecapDB, AuxyRecapFrame, AuxyRecapHistory = nil, nil, nil
    NUM_CHAT_WINDOWS = 0
    COMBATLOG_XPGAIN_FIRSTPERSON = "%s dies, you gain %d experience."
    COMBATLOG_XPGAIN_EXPLICIT = "%s dies, you gain %d experience. (%s exp %s bonus)"
    COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED = "You gain %d experience."
    LOOT_ITEM_SELF = "You receive loot: %s."
    LOOT_ITEM_SELF_MULTIPLE = "You receive loot: %sx%d."
    ERR_ZONE_EXPLORED_XP = "Discovered %s: %d experience gained"
    Screenshot = function() shot = (shot or 0) + 1 end
    shot = 0
end
local function fire(e, ...) for _, f in ipairs(frames) do if f.ev and f.ev[e] and f.scripts.OnEvent then f.scripts.OnEvent(f, e, ...) end end end
local function advance(sec, step)
    step = step or 3
    local stop = now + sec
    while now < stop do
        now = now + step
        for _, t in ipairs(timers) do
            if t.every then if now >= t[1] then t[1] = now + t.every; t[2]() end
            elseif not t.done and now >= t[1] then t.done = true; t[2]() end
        end
    end
end
local function load()
    assert(loadfile("AuxyRecap.lua"))("AuxyRecap", {})
    fire("ADDON_LOADED", "AuxyRecap"); fire("PLAYER_LOGIN")
end
local function texts(f) local t = {}; for _, r in ipairs(f.rows or {}) do if r.l.shown then t[#t + 1] = (r.l.text or "") .. "=" .. (r.r.text or "") end end; return table.concat(t, "\n") end
local function plain(s) return (s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")) end
local function playLevel(lv, kills, deaths)
    for i = 1, kills do fire("CHAT_MSG_COMBAT_XP_GAIN", "Wolf dies, you gain 55 experience.") end
    for i = 1, deaths do fire("PLAYER_DEAD") end
    fire("QUEST_TURNED_IN", 1, 300, 2500); money = money + 2500; fire("PLAYER_MONEY")
    advance(60)
    UnitLevel = function() return lv + 1 end
    fire("PLAYER_LEVEL_UP", lv + 1)
    advance(3)
end

for _, loc in ipairs({ "deDE", "enUS" }) do
    setup(loc)
    load()
    local DE = loc == "deDE"
    local db = AuxyRecapDB
    check(loc .. ": DB angelegt, Charakter erfasst", db and db.chars["Grimbold-Testrealm"] ~= nil)
    check(loc .. ": Fenster beim Start zu", AuxyRecapFrame == nil or not AuxyRecapFrame.shown)

    -- Level läuft: Tick, Kills, Beute, Quests, Händler, Reparatur, Flug
    advance(30)
    pos = { 100, 100 }; advance(3)
    check(loc .. ": Zeit wird gezählt", db.chars["Grimbold-Testrealm"].cur.sec >= 30)
    check(loc .. ": Strecke gezählt", db.chars["Grimbold-Testrealm"].cur.dist > 100)
    fire("CHAT_MSG_COMBAT_XP_GAIN", "Wolf dies, you gain 55 experience.")
    fire("CHAT_MSG_COMBAT_XP_GAIN", "Wolf dies, you gain 55 experience. (+27 exp Rested bonus)")
    fire("CHAT_MSG_COMBAT_XP_GAIN", "Boar dies, you gain 40 experience.")
    local c = db.chars["Grimbold-Testrealm"].cur
    check(loc .. ": Kills gezählt", c.kills == 3 and c.xpK == 150)
    check(loc .. ": Lieblingsgegner Wolf 2", c.mobs.Wolf == 2 and c.mobs.Boar == 1)
    check(loc .. ": Ruhe-XP erkannt", c.xpR == 27)
    fire("CHAT_MSG_SYSTEM", "Discovered Dark Cave: 90 experience gained")
    check(loc .. ": Entdeckung", c.ex == 1 and c.xpE == 90)
    fire("CHAT_MSG_LOOT", "You receive loot: |cff1eff00|Hitem:1::::::::::::|h[Green Sword]|h|r.")
    fire("CHAT_MSG_LOOT", "You receive loot: |cff9d9d9d|Hitem:2::::::::::::|h[Junk]|h|rx3")
    fire("CHAT_MSG_LOOT", "You receive loot: |cff9d9d9d|Hitem:2::::::::::::|h[Junk]|h|rx3.")
    check(loc .. ": Items nach Qualität, bester Fund", c.it[3] == 1 and c.it[1] == 3 and c.best and c.best.q == 2)
    fire("QUEST_ACCEPTED", 1); fire("QUEST_TURNED_IN", 1, 400, 3000)
    money = money + 3000; fire("PLAYER_MONEY")
    check(loc .. ": Quest-Gold zugeordnet", c.g.quest == 3000 and c.quests == 1 and c.xpQ == 400)
    fire("LOOT_OPENED"); money = money + 1200; fire("PLAYER_MONEY"); fire("LOOT_CLOSED")
    check(loc .. ": Beute-Gold", c.g.loot == 1200)
    fire("MERCHANT_SHOW"); money = money + 800; fire("PLAYER_MONEY")
    __hook_RepairAllItems(); money = money - 500; fire("PLAYER_MONEY")
    money = money - 300; now = now + 5; fire("PLAYER_MONEY"); fire("MERCHANT_CLOSED")
    check(loc .. ": Verkauf / Reparatur / Einkauf getrennt", c.g.sold == 800 and c.g.repair == -500 and c.g.bought == -300)
    now = now + 3
    fire("TAXIMAP_OPENED"); money = money - 400; fire("PLAYER_MONEY"); fire("TAXIMAP_CLOSED")
    check(loc .. ": Flugmeister", c.g.taxi == -400)
    check(loc .. ": Gold verdient/ausgegeben", c.gain == 3000 + 1200 + 800 and c.loss == 500 + 300 + 400)
    __hook_JumpOrAscendStart(); __hook_JumpOrAscendStart()
    check(loc .. ": Sprünge", c.jumps == 2)
    fire("UNIT_SPELLCAST_SUCCEEDED", "player", "x", 8690)
    fire("UNIT_SPELLCAST_SUCCEEDED", "player", "x", 133)
    check(loc .. ": Ruhestein + Fähigkeiten", c.hearth == 1 and c.casts == 2)
    UnitExists = function() return true end; UnitCanAttack = function() return true end; UnitIsDead = function() return false end
    UnitName = function() return "Defias Bandit" end
    fire("PLAYER_TARGET_CHANGED"); fire("PLAYER_DEAD"); UnitName = function() return "Grimbold" end
    check(loc .. ": Tod mit Zone und letztem Gegner", c.deaths == 1 and c.dz["Example Forest"] == 1 and c.kl["Defias Bandit"] == 1)
    IsMounted = function() return true end; advance(30); IsMounted = function() return false end
    check(loc .. ": Reittierzeit", (c.t.mount or 0) >= 27)

    -- Zwischenstand
    SlashCmdList.AUXYRECAP("jetzt")
    local F = AuxyRecapFrame
    check(loc .. ": Zwischenstand zeigt Fenster", F and F.shown)
    check(loc .. ": Titel Zwischenstand", F.title.text:find(DE and "Zwischenstand" or "so far", 1, true))
    local body = texts(F)
    check(loc .. ": Hauptwerte da", body:find(DE and "Dauer" or "Duration", 1, true) and body:find("Kills", 1, true))

    -- Level-Up
    UnitLevel = function() return 11 end
    UnitXPMax = function() return 4400 end
    fire("PLAYER_LEVEL_UP", 11)
    local rec = db.chars["Grimbold-Testrealm"].levels[10]
    check(loc .. ": Level 10 gespeichert", rec and rec.kills == 3 and rec.sec > 60 and rec.xp == 4000)
    check(loc .. ": neues Level läuft", db.chars["Grimbold-Testrealm"].cur.lv == 11)
    F.shown = false
    advance(3)
    check(loc .. ": Rückblick geht nach 2 s von selbst auf", AuxyRecapFrame.shown == true)
    check(loc .. ": Titel Level 10", AuxyRecapFrame.title.text == (DE and "Level 10 geschafft!" or "Level 10 done!"))
    body = plain(texts(AuxyRecapFrame))
    check(loc .. ": Funstats im Fenster (Strecke, Lieblingsgegner)", body:find("km", 1, true) and body:find("Wolf", 1, true))
    check(loc .. ": Gold netto", body:find(DE and "Gold netto" or "Gold net", 1, true))
    if not DE then check("englisch: kein deutsches Wort im Fenster", not body:find("Dauer") and not body:find("Tode")) end

    -- Kampf verschiebt
    AuxyRecapFrame:Hide()
    UnitAffectingCombat = function() return true end
    local before = db.chars["Grimbold-Testrealm"].cur
    playLevel(11, 2, 0)
    check(loc .. ": im Kampf kein Fenster", AuxyRecapFrame.shown == false)
    UnitAffectingCombat = function() return false end
    fire("PLAYER_REGEN_ENABLED"); advance(3)
    check(loc .. ": nach Kampf kommt der Rückblick", AuxyRecapFrame.shown == true and AuxyRecapFrame.title.text:find("11", 1, true))
    body = plain(texts(AuxyRecapFrame))
    check(loc .. ": Vergleich mit vorigem Level (Prozent)", body:find("%%%)") or body:find("%d %%"))

    -- weitere Level für Verlauf, Rekord, Prognose
    playLevel(12, 5, 1); playLevel(13, 9, 0); playLevel(14, 3, 2)
    check(loc .. ": mehrere Level gespeichert", Count == nil and db.chars["Grimbold-Testrealm"].levels[13] ~= nil)
    SlashCmdList.AUXYRECAP("")
    check(loc .. ": Befehl leer zeigt letztes Level", AuxyRecapFrame.title.text:find("14", 1, true))
    SlashCmdList.AUXYRECAP("verlauf")
    check(loc .. ": Verlauf offen mit Zeilen", AuxyRecapHistory and AuxyRecapHistory.shown and AuxyRecapHistory.hrows[1].shown and AuxyRecapHistory.hrows[0].shown)
    AuxyRecapHistory.hrows[2].scripts.OnClick(AuxyRecapHistory.hrows[2])
    check(loc .. ": Klick auf Verlaufszeile zeigt dieses Level", AuxyRecapFrame.title.text:find("1", 1, true))
    AuxyRecapHistory.hrows[0].scripts.OnClick(AuxyRecapHistory.hrows[0])
    check(loc .. ": Gesamt-Ansicht", AuxyRecapFrame.title.text:find(DE and "Gesamt" or "Total", 1, true))
    SlashCmdList.AUXYRECAP("gesamt"); SlashCmdList.AUXYRECAP("total")
    SlashCmdList.AUXYRECAP("test")
    check(loc .. ": Test-Fenster mit Beispielwerten", plain(texts(AuxyRecapFrame)):find("Example", 1, true) or plain(texts(AuxyRecapFrame)):find("Beispiel", 1, true))
    local more = AuxyRecapFrame.more
    more.scripts.OnClick(more)
    check(loc .. ": Weitere Funstats blättert", AuxyRecapFrame.head.text:find("2/", 1, true))
    SlashCmdList.AUXYRECAP("debug"); SlashCmdList.AUXYRECAP("reset"); SlashCmdList.AUXYRECAP("hilfe")
    SlashCmdList.AUXYRECAP("menü")

    -- Einstellungen
    db.auto = false; AuxyRecapFrame:Hide()
    playLevel(14, 1, 0)
    check(loc .. ": auto aus → kein Fenster", AuxyRecapFrame.shown == false)
    db.auto = true; db.screenshot = true
    local s0 = shot
    playLevel(15, 1, 0); advance(3)
    check(loc .. ": Screenshot-Option", shot == s0 + 1)

    -- /reload: Stand bleibt, neues Laden mit vorhandener DB
    local saved = AuxyRecapDB
    local lv = saved.chars["Grimbold-Testrealm"].cur.lv
    setup(loc); AuxyRecapDB = saved; UnitLevel = function() return lv end
    load()
    check(loc .. ": nach Neuladen läuft derselbe Level weiter", AuxyRecapDB.chars["Grimbold-Testrealm"].cur.lv == lv and not AuxyRecapDB.chars["Grimbold-Testrealm"].cur.partial)
    fire("PLAYER_LOGOUT")
end

-- Erster Start mitten im Level: Spielzeit-Abfrage, unvollständig markiert
setup("enUS")
local asked = false
RequestTimePlayed = function() asked = true end
load()
check("Erststart: Spielzeit wird abgefragt", asked)
fire("TIME_PLAYED_MSG", 90000, 1800)
local cc = AuxyRecapDB.chars["Grimbold-Testrealm"]
check("Erststart: Zeit im Level übernommen", cc.cur.sec >= 1800 and cc.total0 == 90000 and cc.cur.partial == true)
UnitLevel = function() return 11 end; fire("PLAYER_LEVEL_UP", 11); advance(3)
check("Erststart: erstes Level als unvollständig markiert", cc.levels[10].partial == true)
check("Erststart: Spielzeit insgesamt in der Anzeige", AuxyRecapFrame.sub.text:find("Total play time", 1, true))

-- unbekanntes XP-Format: wird als Kill gezählt und gemerkt
setup("enUS"); load()
fire("CHAT_MSG_COMBAT_XP_GAIN", "Totally new format 77")
check("unbekanntes Format wird gemerkt", #AuxyRecapDB.unmatched == 1 and AuxyRecapDB.chars["Grimbold-Testrealm"].cur.kills == 1)

io.stdout:write(string.format("%d Prüfungen, %d Fehler\n", total, fail))
if fail > 0 then os.exit(1) end
