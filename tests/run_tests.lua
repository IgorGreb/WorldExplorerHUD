-- Offline test harness: emulates the parts of the WoW API the addon uses.
-- Run from the repository root:  lua5.1 tests/run_tests.lua
local ADDON_DIR = arg[1] or "."
local chat = {}
local function noop() end

-- generic frame mock
local function NewFrame(name)
    local f = { scripts = {}, shown = true, w = 1000, h = 667 }
    local mt = { __index = function(t, k)
        return function(self, ...) return nil end
    end }
    setmetatable(f, mt)
    function f:SetScript(k, fn) self.scripts[k] = fn end
    function f:HookScript(k, fn) self.scripts[k] = fn end
    function f:Show() self.shown = true end
    function f:Hide() self.shown = false end
    function f:IsShown() return self.shown end
    function f:GetWidth() return self.w end
    function f:GetHeight() return self.h end
    function f:GetFrameLevel() return 1 end
    function f:CreateTexture() return NewFrame() end
    function f:CreateFontString() local fs = NewFrame(); function fs:SetText(t) self.text = t end; return fs end
    function f:GetStatusBarTexture() return NewFrame() end
    function f:GetPoint() return "CENTER", nil, "CENTER", 0, 0 end
    function f:SetStatusBarColor(r, g, b) self.color = { r, g, b } end
    function f:SetValue(v) self.value = v end
    function f:SetText(t) self.text = t end
    function f:GetText() return self.text end
    function f:SetChecked(v) self.checked = v and true or false end
    function f:GetChecked() return self.checked end
    function f:SetAlpha(a) self.alpha = a end
    function f:GetAlpha() return self.alpha or 1 end
    function f:SetParent(p) self.parent = p end
    if name then _G[name] = f end
    return f
end
CreateFrame = function(_, name) return NewFrame(name) end
UIParent = NewFrame()
Minimap = NewFrame("Minimap"); Minimap.w = 140
function Minimap:GetCenter() return 100, 100 end
function Minimap:GetEffectiveScale() return 1 end
GameTooltip = NewFrame()
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) table.insert(chat, m) end }
string.trim = function(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
PlaySound = function(id) Sounds = (Sounds or 0) + 1 end
UISpecialFrames = {}
wipe = function(t) for k in pairs(t) do t[k] = nil end return t end
time = os.time
securecallfunction = function(f, ...) return f(...) end
geterrorhandler = function() return function(e) error(e, 2) end end
ShiftDown = false
IsShiftKeyDown = function() return ShiftDown end
GetCursorPosition = function() return 0, 0 end
ShowUIPanel = function(f) f:Show() end
SettingsCalls = { registered = 0, opened = nil }
Settings = {
    RegisterCanvasLayoutCategory = function(panel, name)
        return { panel = panel, name = name, GetID = function() return 4242 end }
    end,
    RegisterAddOnCategory = function() SettingsCalls.registered = SettingsCalls.registered + 1 end,
    OpenToCategory = function(id) SettingsCalls.opened = id end,
}
function InstallMockDBIcon()
    local lib = LibStub:NewLibrary("LibDBIcon-1.0", 1)
    MockDBIcon = { registered = {}, shown = {} }
    function lib:Register(name, obj, db) MockDBIcon.registered[name] = { obj = obj, db = db }; MockDBIcon.shown[name] = not db.hide end
    function lib:Show(name) MockDBIcon.shown[name] = true end
    function lib:Hide(name) MockDBIcon.shown[name] = false end
end
SlashCmdList = {}

-- world state
local state = { mapID = 1429, zoneText = "Елвінський ліс", subText = "", x = 0.5, y = 0.5, player = "Alice", completed = {} }
local maps = {
    [1429] = { name = "Елвінський ліс", mapType = 3, parentMapID = 1415 },
    [1415] = { name = "Східні королівства", mapType = 2, parentMapID = 947 },
    [9001] = { name = "Шахта Фарґодіп", mapType = 5, parentMapID = 1429 },
    [2001] = { name = "Isle of Zefris", mapType = 3, parentMapID = 1414 },
    [2002] = { name = "Острів Зефріс", mapType = 3, parentMapID = 1414 },
    [1453] = { name = "Stormwind City", mapType = 3, parentMapID = 1415 },
}
Enum = { UIMapType = { Cosmic = 0, World = 1, Continent = 2, Zone = 3, Dungeon = 4, Micro = 5, Orphan = 6 } }
C_Map = {
    GetBestMapForUnit = function() return state.mapID end,
    GetMapInfo = function(id) return maps[id] end,
    GetPlayerMapPosition = function(id)
        return { GetXY = function() return state.x, state.y end }
    end,
    GetMapWorldSize = function() return 3200, 2133 end,
}
C_QuestLog = {
    IsQuestFlaggedCompleted = function(id) return state.completed[id] or false end,
    GetNumQuestLogEntries = function() return 3 end,
}
GetRealZoneText = function() return state.zoneText end
GetSubZoneText = function() return state.subText end
UnitName = function() return state.player end
GetRealmName = function() return "Forever" end
UnitClass = function() return "Mage", "MAGE" end
UnitRace = function() return "Human", "Human" end
UnitLevel = function() return 5 end
GetLocale = function() return "enUS" end
GetAddOnMetadata = function(_, f) if f == "Version" then return "0.5.0" end end
WorldMapFrame = NewFrame("WorldMapFrame")
WorldMapFrame.ScrollContainer = NewFrame(); WorldMapFrame.ScrollContainer.Child = NewFrame()
WorldMapFrame.shown = false
function WorldMapFrame:GetMapID() return state.viewMap or state.mapID end
function WorldMapFrame:SetMapID(id) state.viewMap = id end

-- Mock HereBeDragons(-Pins): records registered icons; a world icon is "visible"
-- when the world map shows exactly its uiMapID (showFlag 0 semantics).
MockPins = { world = {}, mini = {}, created = 0 }
function InstallMockHBD()
    if LibStub.libs["HereBeDragons-Pins-2.0"] then return end
    local hbd = LibStub:NewLibrary("HereBeDragons-2.0", 1)
    function hbd:GetZoneDistance(m1, x1, y1, m2, x2, y2)
        local dx, dy = (x2 - x1) * 3200, (y2 - y1) * 2133
        return math.sqrt(dx * dx + dy * dy)
    end
    local pins = LibStub:NewLibrary("HereBeDragons-Pins-2.0", 1)
    function pins:AddWorldMapIconMap(ref, icon, mapID, x, y, flag)
        assert(x >= 0 and x <= 1 and y >= 0 and y <= 1, "coords must be 0-1")
        assert(flag == 0, "pins must be limited to their own zone map")
        MockPins.world[icon] = { mapID = mapID, x = x, y = y }
        return true
    end
    function pins:RemoveWorldMapIcon(ref, icon) MockPins.world[icon] = nil end
    function pins:AddMinimapIconMap(ref, icon, mapID, x, y, parent, float)
        MockPins.mini[icon] = { mapID = mapID, x = x, y = y, float = float }
        return true
    end
    function pins:RemoveMinimapIcon(ref, icon) MockPins.mini[icon] = nil end
end
function WorldPins(filter)
    local out = {}
    for icon, d in pairs(MockPins.world) do
        if WorldMapFrame.shown and d.mapID == WorldMapFrame:GetMapID() and (not filter or filter(icon)) then
            table.insert(out, icon)
        end
    end
    return out
end
function MiniPins(filter)
    local out = {}
    for icon, d in pairs(MockPins.mini) do
        if not filter or filter(icon) then table.insert(out, icon) end
    end
    return out
end
local function count(t) local n = 0 for _ in pairs(t) do n = n + 1 end return n end

-- load addon in .toc order
local WE = {}
local function load(saved)
    WorldExplorerDB, WorldExplorerCharDB = saved, nil
    WE = {}
    LibStub = nil -- fresh library registry per load
    for line in io.lines(ADDON_DIR .. "/WorldExplorerHUD.toc") do
        if line:match("%.lua$") then
            local path = line:gsub("\\", "/")
            if path:match("^Libs/LibStub") or path:match("^Libs/CallbackHandler") or path:match("^Libs/LibDataBroker") then
                assert(loadfile(ADDON_DIR .. "/" .. path))() -- real libraries
                if path:match("^Libs/LibStub") then InstallMockHBD() end
            elseif path:match("^Libs/LibDBIcon") then
                if UseMockDBIcon then InstallMockDBIcon() end -- not in the repo (fetched by packager)
            elseif not path:match("^Libs/") then
                local chunk = assert(loadfile(ADDON_DIR .. "/" .. path))
                chunk("WorldExplorerHUD", WE)
            end
        end
    end
    -- fire ADDON_LOADED via the core event frame (last frame with OnEvent)
    return WE
end
local coreFrame
local realCreate = CreateFrame
CreateFrame = function(t, name, ...)
    if t == "Button" and name == nil and MockPins then MockPins.created = MockPins.created + 1 end
    local f = realCreate(t, name, ...)
    local orig = f.SetScript
    f.SetScript = function(self, k, fn) orig(self, k, fn); if k == "OnEvent" then coreFrame = self end end
    return f
end
local function fire(ev, ...) coreFrame.scripts.OnEvent(coreFrame, ev, ...) end
local function tick() coreFrame.scripts.OnUpdate(coreFrame, 0.6) end

local passed, failed = 0, 0
local function check(cond, msg)
    if cond then passed = passed + 1 else failed = failed + 1; print("FAIL: " .. msg) end
end
local function goTo(mapID, x, y, sub, zoneText)
    state.mapID, state.x, state.y, state.subText = mapID, x, y, sub or ""
    state.zoneText = zoneText or (maps[mapID] and maps[mapID].name) or state.zoneText
    fire("ZONE_CHANGED")
end

---------------------------------------------------------------- 1. migration
local legacy = {
    account = { zones = {
        ["Mulgore"] = { discoveredSubzones = { ["Bloodhoof Village"] = true }, completedQuests = { [1] = true }, questTitles = {}, secretsFound = {}, learnedPins = {}, customPins = {} },
        ["Mul Gore"] = { discoveredSubzones = { ["thunder bluff"] = true, ["Some Hut"] = true }, completedQuests = { [2] = true }, questTitles = {}, secretsFound = {}, learnedPins = {}, customPins = {} },
        ["Zephras Isle"] = { discoveredSubzones = { ["Galecliff"] = true }, completedQuests = {}, questTitles = {}, secretsFound = {}, learnedPins = {}, customPins = { { name = "My Spot", x = 1, y = 1 } } },
        ["Elwynn Forest"] = { discoveredSubzones = { ["Goldshire"] = true, ["Lion's Pride Inn"] = true, ["My Spot2"] = true }, completedQuests = {}, questTitles = {}, secretsFound = {}, learnedPins = {}, customPins = { { name = "My Spot2", x = 10, y = 10 } } },
        ["Stormwind City"] = { discoveredSubzones = { ["Trade District"] = true }, completedQuests = {}, questTitles = {}, secretsFound = {} , learnedPins = {}, customPins = {} },
    } },
    characters = { ["Alice-Forever"] = { level = 5, zones = {
        ["Mul Gore"] = { discoveredSubzones = { ["Thunder Bluff"] = true }, completedQuests = { [2] = true }, questTitles = {}, secretsFound = {} },
        ["Elwynn Forest"] = { discoveredSubzones = { ["Goldshire"] = true, ["Lion's Pride Inn"] = true }, completedQuests = {}, questTitles = {}, secretsFound = {} },
        ["Stormwind City"] = { discoveredSubzones = { ["Trade District"] = true }, completedQuests = {}, questTitles = {}, secretsFound = {} },
    } } },
}
load(legacy)
fire("ADDON_LOADED", "WorldExplorerHUD")
local acc = WorldExplorerDB.account.zones
check(WorldExplorerDB.schemaVersion == 2, "schema bumped")
check(acc["Mul Gore"] == nil and acc["Zephras Isle"] == nil, "alias keys removed")
check(acc["Mulgore"].discoveredSubzones["Bloodhoof Village"] and acc["Mulgore"].discoveredSubzones["Thunder Bluff"], "alias records merged, case normalized")
check(acc["Mulgore"].completedQuests[1] and acc["Mulgore"].completedQuests[2], "quests merged")
check(acc["Mulgore"].extraSubzones["Some Hut"] and not acc["Mulgore"].discoveredSubzones["Some Hut"], "non-DB subzone moved to extra")
check(acc["Isle of Zefris"].discoveredSubzones["Galecliff"] and #acc["Isle of Zefris"].customPins == 1, "Zephras -> Zefris")
check(acc["Elwynn Forest"].discoveredSubzones["My Spot2"], "custom pin kept as point")
check(acc["Elwynn Forest"].extraSubzones["Lion's Pride Inn"], "Elwynn extra")
check(WorldExplorerDB.characters["Alice-Forever"].zones["Mulgore"].discoveredSubzones["Thunder Bluff"], "char alias migrated")
check(acc["Stormwind City"].displayName == "Stormwind City", "unknown legacy zone keeps name")
local migratedMsg = false
for _, m in ipairs(chat) do if m:find("upgraded") then migratedMsg = true end end
check(migratedMsg, "migration message shown")

---------------------------------------------------------------- 2. localized client, mapID keys
fire("PLAYER_ENTERING_WORLD")
local st = WE.Tracker:GetZoneStats(nil, false)
check(st.zoneKey == "Elwynn Forest", "localized zone text resolves via mapID (got " .. tostring(st.zoneKey) .. ")")
check(st.subTotal == 6, "subTotal derived from points (6), got " .. tostring(st.subTotal))
check(st.subFound == 1 and st.extraFound == 1, "only DB points counted: found=" .. st.subFound .. " extra=" .. st.extraFound)
check(st.mapPct == 17, "pct 1/6 = 17, got " .. st.mapPct)
check(st.questsTotal == 33, "quest total = #quest list (33), got " .. tostring(st.questsTotal))
-- localized subzone text unknown to DB -> extra, not inflating %
goTo(1429, 0.30, 0.30, "Ферма Маклюра")
st = WE.Tracker:GetZoneStats(nil, false)
check(st.subFound == 1 and st.extraFound == 2, "localized subzone goes to extra")
-- proximity discovers Northshire (48.2, 41.5) regardless of locale
goTo(1429, 0.482, 0.415, "Долина Нортшир")
st = WE.Tracker:GetZoneStats(nil, false)
check(WE.Tracker:GetZoneRecords("Elwynn Forest").discoveredSubzones["Northshire Valley"], "proximity discovery")
check(st.subFound == 2 and st.mapPct == 33, "2/6 = 33%")
-- micro map (cave) resolves to parent zone, coords from zone map
goTo(9001, 0.5, 0.5, "")
check(WE:GetCurrentZone().key == "Elwynn Forest" and WE:GetCurrentZone().mapID == 1429, "micro map walks up to zone")
-- quest sync from client flags; turn-in outside list counted separately
state.completed[7] = true
WE.Tracker:SyncCompletedQuests("Elwynn Forest")
fire("QUEST_TURNED_IN", 99999, "Random")
st = WE.Tracker:GetZoneStats("Elwynn Forest", false)
check(st.questsDone == 1 and st.questsTurnedIn == 2, "list quests vs all turned in: " .. st.questsDone .. "/" .. st.questsTurnedIn)
-- zone without quest list: no fake total
st = WE.Tracker:GetZoneStats("Westfall", false)
check(st.questsTotal == nil, "no fake quest total")
check(st.secretsTotal == 0 and st.secretsPct == 0, "no secrets -> 0%, not 100%")
-- unknown zone by mapID adopts legacy name record
goTo(1453, 0.5, 0.5, "Trade District", "Stormwind City")
check(acc["map:1453"] and acc["map:1453"].extraSubzones["Trade District"] and acc["Stormwind City"] == nil, "legacy unknown zone adopted into map:1453")
check(WE:GetZoneDisplayName("map:1453") == "Stormwind City", "display name for map key")

---------------------------------------------------------------- 3. custom zone learned by name, then localized
goTo(2001, 0.1, 0.1, "")
check(WE:GetCurrentZone().key == "Isle of Zefris", "custom zone by name")
check(WorldExplorerDB.mapIDCache[2001] == "Isle of Zefris", "mapID learned")
maps[2001].name = "Острів Зефріс"
check(WE:GetCurrentZone().key == "Isle of Zefris", "learned ID works with localized name")
maps[2001].name = "Isle of Zefris"

---------------------------------------------------------------- 4. account-scope unmark safety
-- Bob discovers Goldshire too; Alice unmarks in character scope -> account keeps it (Bob)
state.player = "Bob"; package.loaded = package.loaded
WE.Tracker.GetCharKey = function() return state.player .. "-Forever" end
goTo(1429, 0.421, 0.658, "")
check(WorldExplorerDB.characters["Bob-Forever"].zones["Elwynn Forest"].discoveredSubzones["Goldshire"], "Bob found Goldshire")
state.player = "Alice"
WE.Tracker:SetDiscoveryState("Elwynn Forest", "discoveredSubzones", "Goldshire", false, false)
check(not WorldExplorerDB.characters["Alice-Forever"].zones["Elwynn Forest"].discoveredSubzones["Goldshire"], "Alice unmarked")
check(acc["Elwynn Forest"].discoveredSubzones["Goldshire"], "account keeps Bob's discovery")
-- now Bob unmarks in char scope -> nobody has it -> account cleared
state.player = "Bob"
WE.Tracker:SetDiscoveryState("Elwynn Forest", "discoveredSubzones", "Goldshire", false, false)
check(not acc["Elwynn Forest"].discoveredSubzones["Goldshire"], "account cleared when no char has it")
-- account scope unmark clears all
WE.Tracker:SetDiscoveryState("Elwynn Forest", "discoveredSubzones", "Northshire Valley", true, false)
state.player = "Alice"
WE.Tracker:SetDiscoveryState("Elwynn Forest", "discoveredSubzones", "Northshire Valley", false, true)
check(not acc["Elwynn Forest"].discoveredSubzones["Northshire Valley"]
  and not WorldExplorerDB.characters["Bob-Forever"].zones["Elwynn Forest"].discoveredSubzones["Northshire Valley"], "account unmark clears every char")

---------------------------------------------------------------- 5. secret tracking auto-completes
state.player = "Alice"
goTo(1429, 0.70, 0.40, "")
WorldMapFrame.shown = true; state.viewMap = 1429
WE.MapPins:Refresh()
local secretPin = WorldPins(function(b) return b.kind == "secret" end)[1]
check(#WorldPins() == 8, "6 points + 1 secret + 1 migrated custom pin on Elwynn, got " .. #WorldPins())
check(secretPin ~= nil and secretPin.pointTitle == WE:L("secretPinPrefix") .. "Abandoned Camp", "secret pin placed with localized prefix")
secretPin.scripts.OnClick(secretPin, "LeftButton")
check(_G.WorldExplorerCompass.shown, "compass shown while tracking")
chat = {}
goTo(1429, 0.795, 0.582, "") -- walk onto the secret
tick()
local reachedMsg = false
for _, m in ipairs(chat) do if m:find("Target reached") then reachedMsg = true end end
check(reachedMsg and not _G.WorldExplorerCompass.shown, "secret tracking finished automatically")
-- right-click on a pin in char scope uses SetDiscoveryState (no account wipe)
WE.MapPins:Refresh()
local pointPin
pointPin = WorldPins(function(b) return b.pointKey == "Goldshire" end)[1]
pointPin.scripts.OnClick(pointPin, "RightButton")
check(WorldExplorerDB.characters["Alice-Forever"].zones["Elwynn Forest"].discoveredSubzones["Goldshire"], "right-click marks")
-- tracking an already-explored point ends on arrival, not instantly
WE.MapPins:Refresh()
pointPin = WorldPins(function(b) return b.pointKey == "Goldshire" end)[1]
pointPin.scripts.OnClick(pointPin, "LeftButton"); tick()
check(_G.WorldExplorerCompass.shown, "tracking explored point stays active until arrival")
local floatPin = MiniPins(function(b) return b.pointKey == "Goldshire" end)[1]
check(floatPin and MockPins.mini[floatPin].float == true, "tracked target floats on minimap edge")
check(#MiniPins(function(b) return b.isDiscovered and b.pointKey ~= "Goldshire" end) == 0, "minimap hides explored points (except target)")
goTo(1429, 0.421, 0.658, ""); tick()
check(not _G.WorldExplorerCompass.shown, "arrival ends tracking")
-- dungeon map viewed: no pins
maps[9100] = { name = "Deadmines", mapType = 4, parentMapID = 1436 }
state.viewMap = 9100; WE.MapPins:Refresh()
check(#WorldPins() == 0, "no pins on dungeon map")
-- continent map: nothing either
state.viewMap = 1415; WE.MapPins:Refresh()
check(#WorldPins() == 0, "no pins on continent map")
-- view another zone while standing in Elwynn: world pins for Westfall, minimap stays Elwynn
state.viewMap = 1436; WE.MapPins:Refresh()
check(#WorldPins() == 8, "Westfall world pins, got " .. #WorldPins())
check(#MiniPins(function(b) return b.zoneKey ~= "Elwynn Forest" end) == 0, "minimap pins only for current zone")
check(WE.MapPins._zonePins["Elwynn Forest"] and #WE.MapPins._zonePins["Elwynn Forest"].world == 0, "Elwynn world pins released")
-- close map: all world pins released
WorldMapFrame.shown = false; WE.MapPins:Refresh()
check(count(MockPins.world) == 0, "world pins released when map closed")
-- toggles
SlashCmdList["WORLDEXPLORER"]("minimap")
check(count(MockPins.mini) == 0, "/we minimap hides minimap pins")
SlashCmdList["WORLDEXPLORER"]("minimap")
check(count(MockPins.mini) > 0, "/we minimap shows them again")
WorldMapFrame.shown = true; state.viewMap = 1429
SlashCmdList["WORLDEXPLORER"]("pins")
check(#WorldPins() == 0, "/we pins hides world pins")
SlashCmdList["WORLDEXPLORER"]("pins")
check(#WorldPins() == 8, "/we pins shows them again")
-- frames are pooled, not leaked
local before = MockPins.created
for _ = 1, 50 do WE.MapPins:Refresh() end
check(MockPins.created == before, "no new frames on repeated refresh (" .. before .. " -> " .. MockPins.created .. ")")
-- custom pin shows up on both maps
WE.Tracker:AddCustomPin("Camp")
check(#WorldPins(function(b) return b.kind == "custom" end) == 2, "new custom pin added next to migrated one")
-- right-click in account scope from world map
WorldExplorerCharDB.accountScope = true
WE.MapPins:Refresh()
local nPin = WorldPins(function(b) return b.pointKey == "Goldshire" end)[1]
nPin.scripts.OnClick(nPin, "RightButton")
check(not acc["Elwynn Forest"].discoveredSubzones["Goldshire"], "account-scope right-click unmarks")
WorldExplorerCharDB.accountScope = false
WorldMapFrame.shown = false

---------------------------------------------------------------- 6. UI + slash commands don't error
state.viewMap = nil
WE.UI:Refresh()
WE.UI.frame.scripts.OnEnter(WE.UI.frame)
for _, c in ipairs({ "zones", "quests", "status", "lang ua", "status", "units", "pins", "pins", "", "toggle", "toggle" }) do
    local ok, err = pcall(SlashCmdList["WORLDEXPLORER"], c)
    check(ok, "/we " .. c .. ": " .. tostring(err))
end
check(WE.UI.frame.secretBar.label.text ~= nil, "bars rendered")

---------------------------------------------------------------- 8. settings panel
check(SettingsCalls.registered == 1, "settings category registered via Settings API")
SlashCmdList["WORLDEXPLORER"]("")
check(SettingsCalls.opened == 4242, "/we opens settings panel")
local panel = _G.WorldExplorerSettingsPanel
-- find the map-pins checkbox by its option key and click it
local function FindWidget(f, pred)
    -- widgets are created as children of the panel; we scan created frames via the Options keys
    return nil
end
local pinsBefore = WorldExplorerCharDB.showMapPins
WE.Options:Set("showMapPins", false)
check(WorldExplorerCharDB.showMapPins == false and WorldExplorerCharDB.showMapPins ~= pinsBefore, "Options:Set writes value")
WE.Options:Set("showMapPins", true)
WE.Options:Toggle("showHUD")
check(not WE.UI.frame:IsShown(), "showHUD=false hides HUD")
SlashCmdList["WORLDEXPLORER"]("toggle")
check(WE.UI.frame:IsShown(), "/we toggle shows HUD again (persisted option)")
check(WorldExplorerCharDB.showHUD == true, "showHUD persisted")
WE.Options:CycleDistanceUnit(); local u1 = WorldExplorerCharDB.distanceUnit
WE.Options:CycleDistanceUnit(); WE.Options:CycleDistanceUnit(); WE.Options:CycleDistanceUnit()
check(WorldExplorerCharDB.distanceUnit == u1, "distance unit cycles through 3 values")
WE.Settings:Refresh() -- all widgets sync without error
check(true, "settings widgets sync")

---------------------------------------------------------------- 9. minimap button (built-in fallback, no LibDBIcon in repo)
check(WE.MinimapButton:GetBackend() == "builtin", "fallback minimap button used without LibDBIcon")
local ldbObj = LibStub("LibDataBroker-1.1"):GetDataObjectByName("WorldExplorerHUD")
check(ldbObj and ldbObj.type == "launcher", "LDB launcher registered")
local mmb = _G.WorldExplorerMinimapButton
check(mmb and mmb:IsShown(), "minimap button shown")
WE.Options:Set("minimapButton", false)
check(not mmb:IsShown() and WorldExplorerDB.minimapIcon.hide == true, "minimap button hidden via option (LibDBIcon-compatible db)")
WE.Options:Set("minimapButton", true)
-- drag stores angle
GetCursorPosition = function() return 100, 200 end -- straight up from minimap centre
mmb.scripts.OnDragStart(mmb); mmb.scripts.OnUpdate(mmb, 0.1); mmb.scripts.OnDragStop(mmb)
check(math.abs(WorldExplorerDB.minimapIcon.minimapPos - 90) < 0.01, "drag stores angle (90°), got " .. WorldExplorerDB.minimapIcon.minimapPos)
-- clicks
SettingsCalls.opened = nil
mmb.scripts.OnClick(mmb, "RightButton")
check(SettingsCalls.opened == 4242, "right-click opens settings")
mmb.scripts.OnClick(mmb, "LeftButton")
check(WE.Journal:GetFrame() and WE.Journal:GetFrame():IsShown(), "left-click opens journal")
ShiftDown = true; mmb.scripts.OnClick(mmb, "LeftButton"); ShiftDown = false
check(not WE.UI.frame:IsShown(), "shift-click toggles HUD")
WE.Options:Set("showHUD", true)
local tt = { lines = {} }
function tt:AddLine(t) table.insert(self.lines, t) end
function tt:AddDoubleLine(a) table.insert(self.lines, a) end
ldbObj.OnTooltipShow(tt)
check(#tt.lines >= 4, "LDB tooltip has content")

---------------------------------------------------------------- 10. explorer's journal
local model = WE.Journal:BuildModel(false, false)
local totalPts = 0
for _, m in pairs(WE.ZoneData) do totalPts = totalPts + #m.discoveryPoints end
check(model.areasTotal == totalPts, "journal total = all DB points (" .. totalPts .. ")")
check(model.sections[1].name == "Eastern Kingdoms" and model.sections[2].name == "Kalimdor", "continent order")
local elw
for _, r in ipairs(model.sections[1].rows) do if r.key == "Elwynn Forest" then elw = r end end
local st = WE.Tracker:GetZoneStats("Elwynn Forest", false)
check(elw and elw.done == st.subFound and elw.total == 6, "Elwynn row matches zone stats")
local ekCount = 0
for _, m in pairs(WE.ZoneData) do if m.continent == "Eastern Kingdoms" then ekCount = ekCount + 1 end end
check(#model.sections[1].rows == ekCount, "all EK zones listed when not hiding")
local hidden = WE.Journal:BuildModel(false, true)
local visibleRows = 0
for _, sec in ipairs(hidden.sections) do visibleRows = visibleRows + #sec.rows end
check(visibleRows > 0 and visibleRows < #model.sections[1].rows + #model.sections[2].rows, "hide-unvisited filters rows")
local otherKeys = {}
for _, o in ipairs(model.other) do otherKeys[o.key] = true end
check(otherKeys["map:1453"], "unknown visited zone listed under Other")
-- render + click a row opens the zone on the world map
WE.Journal:Refresh()
local rows = WE.Journal:GetUsedRows()
check(#rows > 40, "journal rendered rows: " .. #rows)
local westRow
for _, r in ipairs(rows) do if r.zoneKey == "Westfall" then westRow = r end end
WorldMapFrame.shown = false
westRow.scripts.OnClick(westRow)
check(WorldMapFrame.shown and state.viewMap == 1436, "row click opens Westfall on the world map")
WorldMapFrame.shown = false; state.viewMap = nil
local poolBefore = #rows
for _ = 1, 5 do WE.Journal:Refresh() end
check(#WE.Journal:GetUsedRows() == poolBefore, "journal rows reused on refresh")

---------------------------------------------------------------- 11. toasts
local toast = _G.WorldExplorerToast
for _ = 1, 400 do if not WE.Toast:IsBusy() then break end toast.scripts.OnUpdate(toast, 0.5) end
check(not WE.Toast:IsBusy(), "toast queue drained")
-- reset Westfall discoveries for Alice and walk to a point
state.player = "Alice"
local wf = WE.ZoneData["Westfall"].discoveryPoints
maps[1436] = { name = "Westfall", mapType = 3, parentMapID = 1415 }
chat = {}; Sounds = 0
goTo(1436, wf[1].x / 100, wf[1].y / 100, "")
check(toast and toast:IsShown(), "toast shown on discovery")
check(toast.title.text == wf[1].name, "toast title = area name")
check(toast.sub.text:find("1/8", 1, true), "toast shows zone progress 1/8: " .. tostring(toast.sub.text))
check(Sounds > 0, "discovery sound played")
local chatLine = false
for _, m in ipairs(chat) do if m:find(wf[1].name, 1, true) then chatLine = true end end
check(chatLine, "chat message still printed")
local q0 = WE.Toast:QueueLength()
goTo(1436, wf[2].x / 100, wf[2].y / 100, "")
check(WE.Toast:QueueLength() == q0 + 1, "next discovery is queued behind the current toast")
local firstTitle = toast.title.text
for _ = 1, 30 do toast.scripts.OnUpdate(toast, 0.25) end
check(toast:IsShown() and toast.title.text ~= firstTitle, "queued toast shown after the first")
for _ = 1, 400 do if not WE.Toast:IsBusy() then break end toast.scripts.OnUpdate(toast, 0.5) end
check(not toast:IsShown() and not WE.Toast:IsBusy(), "toast fades out")
-- options off
WE.Options:Set("toasts", false); WE.Options:Set("chatMessages", false)
chat = {}
goTo(1436, wf[3].x / 100, wf[3].y / 100, "")
check(not toast:IsShown(), "no toast when disabled")
local anyChat = false
for _, m in ipairs(chat) do if m:find(wf[3].name, 1, true) then anyChat = true end end
check(not anyChat, "no chat line when disabled")
WE.Options:Set("toasts", true); WE.Options:Set("chatMessages", true)
-- complete the zone -> one "zone complete" toast
local zoneToasts = 0
local origShow = WE.Toast.Show
WE.Toast.Show = function(self, kind, ...) if kind == "zone" then zoneToasts = zoneToasts + 1 end return origShow(self, kind, ...) end
for i = 4, #wf do goTo(1436, wf[i].x / 100, wf[i].y / 100, "") end
check(zoneToasts == 1, "zone-complete toast exactly once, got " .. zoneToasts)
check(WorldExplorerDB.characters["Alice-Forever"].zones["Westfall"].completedAt, "completedAt stored")
WE.Tracker:SetDiscoveryState("Westfall", "discoveredSubzones", wf[1].name, false, false)
goTo(1436, wf[1].x / 100, wf[1].y / 100, "")
check(zoneToasts == 1, "no repeated zone-complete toast")
WE.Toast.Show = origShow

---------------------------------------------------------------- 12. pin sharing
local accZ = WorldExplorerDB.account.zones
accZ["Westfall"].customPins = {
    { name = "Camp ~ by the river; ok!", x = 12.345, y = 67.891 },
    { name = "Табір |cffff0000червоний|r", x = 50, y = 50 },
}
local str, n = WE.PinShare:Export("Westfall")
check(n == 2 and str:match("^!WEP1!"), "export produces versioned string")
check(not str:find("|", 1, true), "export contains no raw pipe characters")
local exportAll = WE.PinShare:Export(nil)
check(exportAll and #exportAll > #str, "export all includes other zones")
-- import into a clean account
local savedZones = accZ["Westfall"].customPins
accZ["Westfall"].customPins = {}
local added, dupes, invalid = WE.PinShare:Import(str)
check(added == 2 and dupes == 0 and invalid == 0, "import adds 2 pins")
local names = {}
for _, p in ipairs(accZ["Westfall"].customPins) do names[p.name] = p end
check(names["Camp ~ by the river; ok!"] and math.abs(names["Camp ~ by the river; ok!"].x - 12.35) < 0.001, "special characters + coords round-trip")
check(names["Табір червоний"] ~= nil, "UI escape codes stripped from names (Ukrainian text kept)")
check(WE.SanitizePinName("|TInterface\\Icons\\X:0|t|Hitem:1|h[Link]|h ok") == "[Link] ok", "textures/hyperlinks stripped")
check(#WE.SanitizePinName(string.rep("ї", 40)) == 60, "long UTF-8 name cut on a character boundary")
added, dupes = WE.PinShare:Import(str)
check(added == 0 and dupes == 2, "re-import skips duplicates")
-- tampering & garbage
local tampered = str:gsub("Camp", "Kamp", 1)
local ok1, e1 = WE.PinShare:Import(tampered)
check(ok1 == nil and e1 == WE:L("errChecksum"), "tampered string rejected")
local ok2, e2 = WE.PinShare:Import("hello world")
check(ok2 == nil and e2 == WE:L("errFormat"), "garbage rejected")
local ok3, e3 = WE.PinShare:Import("!WEP9!x~1~1~a!0000")
check(ok3 == nil and e3 == WE:L("errVersion"), "newer version rejected")
local function mk(payload) return "!WEP1!" .. payload .. "!" .. WE.PinShare._Checksum(payload) end
local a4, d4, i4 = WE.PinShare:Import(mk("Nowhere Land~10~10~X;Westfall~150~10~Y;Westfall~20.5~30.5~Good"))
check(a4 == 1 and i4 == 2, "invalid zone / out-of-range coords counted as invalid")
local big = {}
for i = 1, 501 do big[i] = "Westfall~" .. (i % 100) .. "~1~P" .. i end
local a5, e5 = WE.PinShare:Import(mk(table.concat(big, ";")))
check(a5 == nil and e5:find("500"), "more than 500 pins rejected")
local a6 = WE.PinShare:Import("  " .. str .. "\n")
check(a6 == 0, "surrounding whitespace/newline tolerated")
-- dialog
WE.PinShare:ShowDialog()
local dlg = WE.PinShare:GetDialog()
state.mapID = 1436; WE.PinShare:FillExport(false)
check(dlg.edit:GetText():match("^!WEP1!"), "dialog export fills edit box")
dlg.edit:SetText(mk("Westfall~77~77~FromFriend"))
WE.PinShare:ImportFromDialog()
local fromFriend = false
for _, p in ipairs(accZ["Westfall"].customPins) do if p.name == "FromFriend" then fromFriend = true end end
check(fromFriend and dlg.edit:GetText() == "", "dialog import works")
-- shift+right-click deletes a custom pin on the world map
WorldMapFrame.shown = true; state.viewMap = 1436; WE.MapPins:Refresh()
local cp = WorldPins(function(b) return b.kind == "custom" and b.pointKey == "FromFriend" end)[1]
check(cp ~= nil, "imported pin visible on map")
ShiftDown = true; cp.scripts.OnClick(cp, "RightButton"); ShiftDown = false
local still = false
for _, p in ipairs(accZ["Westfall"].customPins) do if p.name == "FromFriend" then still = true end end
check(not still and #WorldPins(function(b) return b.pointKey == "FromFriend" end) == 0, "shift+right-click deletes custom pin")
WorldMapFrame.shown = false
accZ["Westfall"].customPins = savedZones

---------------------------------------------------------------- 13. LibDBIcon backend when available
UseMockDBIcon = true
load(nil); fire("ADDON_LOADED", "WorldExplorerHUD")
check(WE.MinimapButton:GetBackend() == "LibDBIcon", "LibDBIcon used when present")
check(MockDBIcon.registered["WorldExplorerHUD"] and MockDBIcon.registered["WorldExplorerHUD"].db == WorldExplorerDB.minimapIcon, "registered with shared db table")
WE.Options:Set("minimapButton", false)
check(MockDBIcon.shown["WorldExplorerHUD"] == false, "LibDBIcon:Hide on option off")
UseMockDBIcon = false

-- Settings API missing -> legacy Interface Options fallback
local savedSettings = Settings
Settings = nil
local legacyAdded = false
InterfaceOptions_AddCategory = function(p) legacyAdded = (p.name == "World Explorer HUD") end
load(nil); fire("ADDON_LOADED", "WorldExplorerHUD")
check(legacyAdded, "legacy InterfaceOptions fallback")
Settings = savedSettings

---------------------------------------------------------------- 7. fresh install
chat = {}
load(nil)
coreFrame.scripts.OnUpdate(coreFrame, 1) -- before ADDON_LOADED must not error
fire("ADDON_LOADED", "WorldExplorerHUD")
check(WorldExplorerDB.schemaVersion == 2, "fresh install schema")
local mig = false
for _, m in ipairs(chat) do if m:find("upgraded") then mig = true end end
check(not mig, "no migration message on fresh install")
state.mapID = 1429; fire("PLAYER_ENTERING_WORLD"); tick()

print(string.format("%d passed, %d failed", passed, failed))
os.exit(failed == 0 and 0 or 1)
