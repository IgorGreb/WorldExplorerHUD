local addonName, WE = ...

local function GetMeta(field)
    local fn = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
    return fn and fn(addonName, field) or nil
end
WE.version = GetMeta("Version") or "?"
if WE.version:find("@", 1, true) then WE.version = "dev" end -- unpackaged checkout
WE.ready = false

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
eventFrame:RegisterEvent("QUEST_TURNED_IN")

local function InitSavedVariables()
    WorldExplorerDB = WorldExplorerDB or {}
    WorldExplorerDB.account = WorldExplorerDB.account or { zones = {} }
    WorldExplorerDB.characters = WorldExplorerDB.characters or {}
    WorldExplorerDB.mapIDCache = WorldExplorerDB.mapIDCache or {}
    if next(WorldExplorerDB.account.zones) == nil and next(WorldExplorerDB.characters) == nil then
        WorldExplorerDB.schemaVersion = WE.Tracker.SCHEMA_VERSION -- fresh install, nothing to migrate
    end
    WE.Options:InitDefaults()
end

local function Print(key, ...)
    DEFAULT_CHAT_FRAME:AddMessage(select("#", ...) > 0 and string.format(WE:L(key), ...) or WE:L(key))
end

local HELP_KEYS = {
    "helpOptions", "helpJournal", "helpShare", "helpZones", "helpQuests", "helpStatus", "helpAddPin",
    "helpClear", "helpLang", "helpUnits", "helpPins", "helpMinimap", "helpToggle", "helpLock",
    "helpHints", "helpAccount", "helpCommands",
}

-- Simple boolean toggles: command -> option key
local TOGGLES = {
    pins = "showMapPins",
    minimap = "showMinimapPins",
    lock = "locked",
    hints = "showHints",
    account = "accountScope",
}

SLASH_WORLDEXPLORER1 = "/we"
SLASH_WORLDEXPLORER2 = "/worldexplorer"
SlashCmdList["WORLDEXPLORER"] = function(msg)
    if not WE.ready then return end
    local raw = (msg or ""):trim()
    local cmd, arg = raw:match("^(%S+)%s*(.-)$")
    cmd = (cmd or ""):lower()

    if cmd == "" or cmd == "options" or cmd == "config" or cmd == "settings" then
        WE.Settings:Open()
    elseif cmd == "journal" or cmd == "j" then
        WE.Journal:Toggle()
    elseif cmd == "share" or cmd == "export" or cmd == "import" then
        WE.PinShare:ShowDialog()
        if cmd == "export" then WE.PinShare:FillExport(arg:lower() == "all") end
    elseif TOGGLES[cmd] then
        WE.Options:Toggle(TOGGLES[cmd], true)
    elseif cmd == "toggle" then
        WE.Options:Toggle("showHUD")
    elseif cmd == "units" then
        WE.Options:CycleDistanceUnit(true)
    elseif cmd == "lang" then
        local argLow = (arg or ""):lower()
        local target
        if argLow == "ua" or argLow == "uk" or argLow == "ukua" then
            target = "ukUA"
        elseif argLow == "en" or argLow == "enus" then
            target = "enUS"
        else
            target = (WE.Locale:GetLang() == "ukUA") and "enUS" or "ukUA"
        end
        WE.Options:Set("lang", target, true)
    elseif cmd == "zones" or cmd == "explored" then
        local zones = WE.Tracker:GetExploredZonesList(WorldExplorerCharDB.accountScope)
        Print("zonesHeader", #zones)
        if #zones == 0 then
            Print("zonesEmpty")
        else
            for _, z in ipairs(zones) do
                Print("zoneEntryFmt", z.zoneName, z.continent, z.subCount, z.questCount)
            end
        end
    elseif cmd == "quests" then
        local ctx = WE:GetCurrentZone()
        local zoneName = ctx and ctx.name or WE:L("unknownZone")
        local list = WE.Tracker:GetCompletedQuestList(ctx and ctx.key, WorldExplorerCharDB.accountScope)
        Print("questsHeader", zoneName, #list)
        if #list == 0 then
            Print("questsEmpty")
        else
            for _, q in ipairs(list) do
                Print("questDonePrefix", q.title, q.id)
            end
        end
    elseif cmd == "clear" or cmd == "cancel" then
        WE.MapPins:ClearTarget()
    elseif cmd == "addpin" then
        WE.Tracker:AddCustomPin(arg)
    elseif cmd == "status" then
        local stats = WE.Tracker:GetZoneStats(nil, WorldExplorerCharDB.accountScope)
        Print("zoneStatusLine", stats.zoneName, stats.subFound + stats.extraFound + stats.customFound, stats.questsTurnedIn, stats.statusLabel)
    else
        Print("helpHeader", WE.version)
        for _, key in ipairs(HELP_KEYS) do Print(key) end
    end
end

local elapsedAcc = 0
eventFrame:SetScript("OnUpdate", function(self, elapsed)
    if not WE.ready then return end
    elapsedAcc = elapsedAcc + elapsed
    if elapsedAcc >= 0.5 then
        elapsedAcc = 0
        if WE.Tracker then
            WE.Tracker:CheckProximityToPins()
        end
        if WE.MapPins then
            WE.MapPins:UpdateCompass()
        end
    end
end)

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        InitSavedVariables()
        local migrated = WE.Tracker:MigrateSavedVariables()
        WE.UI:Init()
        WE.MapPins:Init()
        WE.Settings:Init()
        WE.ready = true
        WE.MinimapButton:Init()
        DEFAULT_CHAT_FRAME:AddMessage(string.format(WE:L("addonLoaded"), WE.version))
        if migrated then
            DEFAULT_CHAT_FRAME:AddMessage(WE:L("dataMigrated"))
        end
    elseif not WE.ready then
        return
    elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED_INDOORS" then
        WE.Tracker:RecordCurrentLocation()
        WE.UI:Refresh()
        WE.MapPins:Refresh()
    elseif event == "QUEST_TURNED_IN" then
        -- QUEST_TURNED_IN args are questID, xpReward, moneyReward: there is no title.
        WE.Tracker:RecordQuestTurnIn(arg1)
        WE.UI:Refresh()
    end
end)
