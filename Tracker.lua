local addonName, WE = ...

WE.Tracker = {}
local Tracker = WE.Tracker

-- Distance (in map percent) at which a discovery point / secret counts as reached.
local STRICT_PROXIMITY_RADIUS = 1.25

-- 2: zones keyed by uiMapID (0.5.0). 3: quest-title / custom-pin cleanup (0.7.1).
local SCHEMA_VERSION = 3
Tracker.SCHEMA_VERSION = SCHEMA_VERSION

local function CountKeys(tbl)
    if not tbl then return 0 end
    local count = 0
    for _, v in pairs(tbl) do
        if v then count = count + 1 end
    end
    return count
end
Tracker.CountKeys = CountKeys

local function IsQuestCompletedInClient(questID)
    if not questID then return false end
    if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
        local ok, res = pcall(C_QuestLog.IsQuestFlaggedCompleted, questID)
        if ok and res then return true end
    end
    if IsQuestFlagCompleted then
        local ok, res = pcall(IsQuestFlagCompleted, questID)
        if ok and res then return true end
    end
    if IsQuestCompleted then
        local ok, res = pcall(IsQuestCompleted, questID)
        if ok and res then return true end
    end
    return false
end

local function HasPerQuestAPI()
    return (C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted) or IsQuestFlagCompleted or IsQuestCompleted
end

function Tracker:GetActiveQuestLogCount()
    if C_QuestLog and C_QuestLog.GetNumQuestLogEntries then
        local ok, num = pcall(C_QuestLog.GetNumQuestLogEntries)
        if ok and type(num) == "number" then
            return math.max(0, num)
        end
    end
    if GetNumQuestLogEntries then
        local ok, num = pcall(GetNumQuestLogEntries)
        if ok and type(num) == "number" then
            return math.max(0, num)
        end
    end
    return 0
end

local cachedCharKey = nil
function Tracker:GetCharKey()
    if cachedCharKey then return cachedCharKey end
    local name = UnitName("player")
    local realm = GetRealmName and GetRealmName()
    if not name or name == "" or name == UNKNOWNOBJECT then
        return (name or "Unknown") .. "-" .. (realm or "Forever")
    end
    cachedCharKey = name .. "-" .. ((realm and realm ~= "") and realm or "Forever")
    return cachedCharKey
end

-- Player position (0-100) on the given zone-level map; defaults to the current zone.
function Tracker:GetPlayerMapCoords(zoneMapID)
    if C_Map and C_Map.GetPlayerMapPosition then
        if not zoneMapID then
            local ctx = WE:GetCurrentZone()
            zoneMapID = ctx and ctx.mapID
        end
        if zoneMapID then
            local pos = C_Map.GetPlayerMapPosition(zoneMapID, "player")
            if pos then
                local x, y = pos:GetXY()
                if x and y and (x > 0 or y > 0) then
                    return x * 100, y * 100
                end
            end
        end
        return nil, nil
    end
    if GetPlayerMapPosition then
        local x, y = GetPlayerMapPosition("player")
        if x and y and (x > 0 or y > 0) then
            return x * 100, y * 100
        end
    end
    return nil, nil
end

function Tracker:CalculateDistance(mapID, x1, y1, x2, y2)
    -- Prefer HereBeDragons: it knows the real world size of every zone.
    local HBD = LibStub and LibStub("HereBeDragons-2.0", true)
    if HBD and mapID then
        local yards = HBD:GetZoneDistance(mapID, x1 / 100, y1 / 100, mapID, x2 / 100, y2 / 100)
        if yards then
            return math.floor(yards + 0.5), math.floor(yards * 0.9144 + 0.5)
        end
    end

    local worldW, worldH = 3200, 2133
    if mapID and C_Map and C_Map.GetMapWorldSize then
        local w, h = C_Map.GetMapWorldSize(mapID)
        if w and h and w > 0 and h > 0 then
            worldW, worldH = w, h
        end
    end

    local dxYards = ((x2 - x1) / 100) * worldW
    local dyYards = ((y2 - y1) / 100) * worldH
    local yards = math.sqrt(dxYards * dxYards + dyYards * dyYards)
    local meters = yards * 0.9144
    return math.floor(yards + 0.5), math.floor(meters + 0.5)
end

---------------------------------------------------------------------------
-- Saved data records
---------------------------------------------------------------------------

local SET_FIELDS = { "discoveredSubzones", "extraSubzones", "completedQuests", "secretsFound" }

local function NewCharZone()
    return { discoveredSubzones = {}, extraSubzones = {}, completedQuests = {}, questTitles = {}, secretsFound = {} }
end

local function NewAccZone()
    local z = NewCharZone()
    z.learnedPins = {}
    z.customPins = {}
    return z
end

local function NormalizeZone(z, isAccount)
    for _, f in ipairs(SET_FIELDS) do z[f] = z[f] or {} end
    z.questTitles = z.questTitles or {}
    if isAccount then
        z.learnedPins = z.learnedPins or {}
        z.customPins = z.customPins or {}
    end
    return z
end

local function MergeZone(dst, src)
    for _, f in ipairs(SET_FIELDS) do
        for k, v in pairs(src[f] or {}) do
            if v then dst[f][k] = true end
        end
    end
    for k, v in pairs(src.questTitles or {}) do
        if dst.questTitles[k] == nil then dst.questTitles[k] = v end
    end
    if dst.learnedPins and src.learnedPins then
        for k, v in pairs(src.learnedPins) do
            if dst.learnedPins[k] == nil then dst.learnedPins[k] = v end
        end
    end
    if dst.customPins and src.customPins then
        local have = {}
        for _, p in ipairs(dst.customPins) do have[p.name] = true end
        for _, p in ipairs(src.customPins) do
            if not have[p.name] then
                table.insert(dst.customPins, p)
                have[p.name] = true
            end
        end
    end
    dst.displayName = dst.displayName or src.displayName
end

local function GetCharEntry(create)
    local charKey = Tracker:GetCharKey()
    local chars = WorldExplorerDB.characters
    local entry = chars[charKey]
    if not entry and create then
        entry = {
            class = select(2, UnitClass("player")),
            race = select(2, UnitRace("player")),
            level = UnitLevel("player"),
            zones = {},
        }
        chars[charKey] = entry
    end
    return entry
end

-- Moves a legacy name-keyed record (pre-0.5.0, unknown zones) into its new "map:<id>" key.
local function AdoptLegacyRecord(zonesTbl, newKey, legacyName, isAccount)
    if not legacyName or legacyName == newKey then return end
    local legacy = zonesTbl[legacyName]
    if not legacy or WE:GetZoneMeta(legacyName) then return end
    local dst = zonesTbl[newKey]
    if not dst then
        zonesTbl[newKey] = NormalizeZone(legacy, isAccount)
    else
        MergeZone(dst, NormalizeZone(legacy, isAccount))
    end
    zonesTbl[legacyName] = nil
end

-- Read-only access: returns charZone, accZone (either may be nil).
function Tracker:GetZoneRecords(zoneKey)
    if not zoneKey or not WorldExplorerDB then return nil, nil end
    local entry = GetCharEntry(false)
    local charZone = entry and entry.zones[zoneKey] or nil
    local accZone = WorldExplorerDB.account.zones[zoneKey]
    return charZone, accZone
end

-- Creates the records on first write. displayName is remembered for zones not in the database.
function Tracker:EnsureZoneRecord(zoneKey, displayName)
    if not zoneKey or zoneKey == "" or not WorldExplorerDB then return nil, nil end

    local accZones = WorldExplorerDB.account.zones
    local entry = GetCharEntry(true)
    entry.level = UnitLevel("player")

    if not accZones[zoneKey] then
        AdoptLegacyRecord(accZones, zoneKey, displayName, true)
    end
    if not entry.zones[zoneKey] then
        AdoptLegacyRecord(entry.zones, zoneKey, displayName, false)
    end

    accZones[zoneKey] = NormalizeZone(accZones[zoneKey] or NewAccZone(), true)
    entry.zones[zoneKey] = NormalizeZone(entry.zones[zoneKey] or NewCharZone(), false)

    if displayName and displayName ~= "" and not WE:GetZoneMeta(zoneKey) then
        accZones[zoneKey].displayName = displayName
    end

    return entry.zones[zoneKey], accZones[zoneKey]
end

-- Is this flag set for any character? (used to rebuild the account-wide view)
local function AnyCharacterHas(zoneKey, field, id)
    for _, entry in pairs(WorldExplorerDB.characters) do
        local z = entry.zones and entry.zones[zoneKey]
        if z and z[field] and z[field][id] then return true end
    end
    return false
end

--[[
Manually set a discovery flag (map pin right-click).
  field:  "discoveredSubzones" or "secretsFound"
  Character scope: changes only the current character; the account flag is then
                   recomputed as "any character has it", so other characters'
                   progress is never erased.
  Account scope:   marking marks the current character + account; unmarking
                   clears the flag from every character and the account.
Returns the new state for the given scope.
]]
function Tracker:SetDiscoveryState(zoneKey, field, id, state, accountScope)
    local charZone, accZone = self:EnsureZoneRecord(zoneKey)
    if not charZone or not id then return nil end

    if state then
        charZone[field][id] = true
        accZone[field][id] = true
        return true
    end

    if accountScope then
        for _, entry in pairs(WorldExplorerDB.characters) do
            local z = entry.zones and entry.zones[zoneKey]
            if z and z[field] then z[field][id] = nil end
        end
        accZone[field][id] = nil
    else
        charZone[field][id] = nil
        accZone[field][id] = AnyCharacterHas(zoneKey, field, id) or nil
    end
    return false
end

---------------------------------------------------------------------------
-- Custom pin names
---------------------------------------------------------------------------

-- Custom pins share the discoveredSubzones namespace with database points, so a
-- custom pin must never carry a database point's name: reaching it would complete
-- that point. Returns the name unchanged, or a suffixed variant ("Name *").
local function UniqueCustomName(zoneKey, name)
    local meta = WE:GetZoneMeta(zoneKey)
    if not meta or not WE:FindDiscoveryPoint(meta, name) then return name end
    local candidate, n = name .. " *", 2
    while WE:FindDiscoveryPoint(meta, candidate) do
        candidate = name .. " *" .. n
        n = n + 1
    end
    return candidate
end
Tracker.UniqueCustomName = UniqueCustomName

---------------------------------------------------------------------------
-- Migration of saved variables (pre-0.5.0 -> schema 2)
---------------------------------------------------------------------------

local function MigrateZonesTable(zonesTbl, isAccount, accountZones)
    local result = {}
    for oldKey, rec in pairs(zonesTbl) do
        rec = NormalizeZone(rec, isAccount)
        local newKey = WE:ResolveZoneKeyByName(oldKey) or oldKey
        if not WE:GetZoneMeta(newKey) and isAccount then
            rec.displayName = rec.displayName or oldKey
        end
        if result[newKey] then
            MergeZone(result[newKey], rec)
        else
            result[newKey] = rec
        end
    end

    -- Split subzones: known DB points (canonical name) / custom pins stay, everything else -> extraSubzones.
    for key, rec in pairs(result) do
        local meta = WE:GetZoneMeta(key)
        local customNames = {}
        local acc = isAccount and rec or (accountZones and accountZones[key])
        for _, p in ipairs((acc and acc.customPins) or {}) do customNames[p.name] = true end

        local kept = {}
        for name, v in pairs(rec.discoveredSubzones) do
            if v then
                local pt = WE:FindDiscoveryPoint(meta, name)
                if pt then
                    kept[pt.name] = true
                elseif customNames[name] then
                    kept[name] = true
                else
                    rec.extraSubzones[name] = true
                end
            end
        end
        rec.discoveredSubzones = kept
    end
    return result
end

-- Schema 3 (0.7.1):
--  * drops quest "titles" that were really XP numbers (QUEST_TURNED_IN arg bug in 0.7.0);
--  * renames custom pins that carry a database point's name.
local function CleanQuestTitles(rec)
    for qid, title in pairs(rec.questTitles or {}) do
        if type(title) ~= "string" or title == "" then rec.questTitles[qid] = nil end
    end
end

local function MigrateToV3(db)
    for zoneKey, rec in pairs(db.account.zones) do
        CleanQuestTitles(rec)
        for _, p in ipairs(rec.customPins or {}) do
            p.name = UniqueCustomName(zoneKey, p.name)
        end
    end
    for _, entry in pairs(db.characters) do
        for _, rec in pairs(entry.zones or {}) do CleanQuestTitles(rec) end
    end
end

-- Returns true only when the zone-key format changed (that is what the chat notice says).
function Tracker:MigrateSavedVariables()
    local db = WorldExplorerDB
    local from = db.schemaVersion or 1
    if from >= SCHEMA_VERSION then return false end

    if from < 2 then
        db.account.zones = MigrateZonesTable(db.account.zones or {}, true, nil)
        for _, entry in pairs(db.characters) do
            entry.zones = MigrateZonesTable(entry.zones or {}, false, db.account.zones)
        end
    end
    if from < 3 then
        MigrateToV3(db)
    end
    db.schemaVersion = SCHEMA_VERSION
    return from < 2
end

---------------------------------------------------------------------------
-- Tracking
---------------------------------------------------------------------------

function Tracker:SyncCompletedQuests(zoneKey)
    local meta = WE:GetZoneMeta(zoneKey)
    if not meta or not meta.quests or #meta.quests == 0 then return false end

    local completedMap = nil
    if not HasPerQuestAPI() and GetQuestsCompleted then
        local ok, map = pcall(GetQuestsCompleted)
        if ok and type(map) == "table" then completedMap = map end
    end

    local charZone, accZone
    local changed = false
    for _, qid in ipairs(meta.quests) do
        local done
        if completedMap then
            done = completedMap[qid] and true or false
        else
            done = IsQuestCompletedInClient(qid)
        end
        if done then
            if not charZone then charZone, accZone = self:EnsureZoneRecord(zoneKey) end
            if not charZone.completedQuests[qid] then
                charZone.completedQuests[qid] = true
                accZone.completedQuests[qid] = true
                changed = true
            end
        end
    end
    return changed
end

function Tracker:SyncFogOfWarOverlays(mapID, zoneKey)
    if not mapID or not zoneKey then return false end
    if not (C_MapExplorationInfo and C_MapExplorationInfo.GetExploredMapTextures) then
        return false
    end

    local meta = WE:GetZoneMeta(zoneKey)
    if not meta or not meta.discoveryPoints then return false end

    local explored = C_MapExplorationInfo.GetExploredMapTextures(mapID)
    if not explored or #explored == 0 then return false end

    local charZone, accZone = self:EnsureZoneRecord(zoneKey)
    if not charZone then return false end

    local mapW, mapH = 1002, 668
    if C_Map and C_Map.GetMapArtSize then
        local w, h = C_Map.GetMapArtSize(mapID)
        if w and h and w > 0 and h > 0 then
            mapW, mapH = w, h
        end
    end

    local changed = false
    for _, pt in ipairs(meta.discoveryPoints) do
        if not charZone.discoveredSubzones[pt.name] then
            local px = (pt.x / 100) * mapW
            local py = (pt.y / 100) * mapH

            for _, tex in ipairs(explored) do
                if tex.hitRect then
                    local left = tex.hitRect.left or 0
                    local right = tex.hitRect.right or 0
                    local top = tex.hitRect.top or 0
                    local bottom = tex.hitRect.bottom or 0
                    if px >= left and px <= right and py >= top and py <= bottom then
                        charZone.discoveredSubzones[pt.name] = true
                        accZone.discoveredSubzones[pt.name] = true
                        changed = true
                        break
                    end
                end
            end
        end
    end

    return changed
end

-- Makes a user-supplied pin name safe: strips WoW UI escape sequences (colors,
-- textures, hyperlinks), control characters and limits the length.
local MAX_PIN_NAME = 60
function WE.SanitizePinName(name)
    name = tostring(name or "")
    name = name:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    name = name:gsub("|T.-|t", ""):gsub("|H.-|h(.-)|h", "%1")
    name = name:gsub("|", ""):gsub("%c", ""):gsub("^%s+", ""):gsub("%s+$", "")
    if #name > MAX_PIN_NAME then
        name = name:sub(1, MAX_PIN_NAME)
        -- do not cut a UTF-8 character in half
        name = name:gsub("[\192-\255][\128-\191]*$", function(tail)
            local b = tail:byte(1)
            local need = (b >= 240 and 4) or (b >= 224 and 3) or 2
            return (#tail == need) and tail or ""
        end)
    end
    return name
end

function Tracker:AddCustomPin(pinName)
    local ctx = WE:GetCurrentZone()
    local px, py = self:GetPlayerMapCoords(ctx and ctx.mapID)
    if not ctx or not px or not py then
        DEFAULT_CHAT_FRAME:AddMessage(WE:L("unableCoords"))
        return
    end
    local _, accZone = self:EnsureZoneRecord(ctx.key, ctx.name)
    pinName = WE.SanitizePinName(pinName)
    if pinName == "" then pinName = string.format("(%.1f, %.1f)", px, py) end
    local unique = UniqueCustomName(ctx.key, pinName)
    if unique ~= pinName then
        DEFAULT_CHAT_FRAME:AddMessage(string.format(WE:L("customPinRenamed"), pinName, unique))
        pinName = unique
    end
    table.insert(accZone.customPins, { name = pinName, x = px, y = py })
    DEFAULT_CHAT_FRAME:AddMessage(string.format(WE:L("customPinAdded"), pinName, px, py))
    if WE.MapPins then WE.MapPins:Refresh() end
end

-- Announces "zone fully explored" once per character, the first time it happens.
function Tracker:CheckZoneComplete(ctx)
    local charZone = self:GetZoneRecords(ctx.key)
    if not charZone or charZone.completedAt then return false end
    local stats = self:GetZoneStats(ctx.key, false)
    if stats.subTotal and stats.subFound == stats.subTotal
        and (stats.secretsTotal == 0 or stats.secretsDone == stats.secretsTotal) then
        charZone.completedAt = time and time() or 0
        WE:Notify("zone", ctx.name, nil, nil, nil, string.format(WE:L("zoneCompleteChat"), ctx.name))
        return true
    end
    return false
end

-- Marks a database discovery point or a custom pin (by its canonical name).
function Tracker:DiscoverPoint(ctx, pointKey, displayText, silent)
    local charZone, accZone = self:EnsureZoneRecord(ctx.key, ctx.name)
    if not charZone or charZone.discoveredSubzones[pointKey] then return false end
    charZone.discoveredSubzones[pointKey] = true
    accZone.discoveredSubzones[pointKey] = true
    if not silent then
        local stats = self:GetZoneStats(ctx.key, false)
        WE:Notify("area", displayText or pointKey, ctx.name, stats.subFound, stats.subTotal,
            string.format(WE:L("areaDiscovered"), displayText or pointKey, ctx.name))
        self:CheckZoneComplete(ctx)
    end
    if WE.MapPins then WE.MapPins:Refresh() end
    return true
end

-- Adds a custom pin to any zone. Returns true if added, false if it duplicates an
-- existing pin (same name, or practically the same spot).
local MAX_PINS_PER_ZONE = 200
function Tracker:AddCustomPinTo(zoneKey, name, x, y, displayName)
    local _, accZone = self:EnsureZoneRecord(zoneKey, displayName)
    if not accZone then return false end
    if #accZone.customPins >= MAX_PINS_PER_ZONE then return false end
    name = UniqueCustomName(zoneKey, name)
    for _, p in ipairs(accZone.customPins) do
        if p.name == name or (math.abs(p.x - x) < 0.3 and math.abs(p.y - y) < 0.3) then
            return false
        end
    end
    table.insert(accZone.customPins, { name = name, x = x, y = y })
    return true
end

-- Deletes a custom pin and its discovery flags (unless a database point shares the name).
function Tracker:RemoveCustomPin(zoneKey, name)
    local _, accZone = self:GetZoneRecords(zoneKey)
    if not accZone or not accZone.customPins then return false end
    local removed = false
    for i = #accZone.customPins, 1, -1 do
        if accZone.customPins[i].name == name then
            table.remove(accZone.customPins, i)
            removed = true
        end
    end
    local meta = WE:GetZoneMeta(zoneKey)
    if removed and not (meta and meta.pointByName and meta.pointByName[name:lower()]) then
        accZone.discoveredSubzones[name] = nil
        for _, entry in pairs(WorldExplorerDB.characters) do
            local z = entry.zones and entry.zones[zoneKey]
            if z and z.discoveredSubzones then z.discoveredSubzones[name] = nil end
        end
    end
    return removed
end

-- Marks a subzone that is not in the database (counted separately, never in the %).
function Tracker:DiscoverExtraSubzone(ctx, subZoneText, px, py)
    local charZone, accZone = self:EnsureZoneRecord(ctx.key, ctx.name)
    if not charZone or charZone.extraSubzones[subZoneText] then return false end
    charZone.extraSubzones[subZoneText] = true
    accZone.extraSubzones[subZoneText] = true
    if px and py and not accZone.learnedPins[subZoneText] then
        accZone.learnedPins[subZoneText] = { x = px, y = py }
    end
    -- Minor areas (buildings, inns...) only get a chat line, no toast/sound.
    if WorldExplorerCharDB.chatMessages ~= false then
        DEFAULT_CHAT_FRAME:AddMessage(string.format(WE:L("areaDiscovered"), subZoneText, ctx.name))
    end
    return true
end

local function Dist(px, py, x, y)
    local dx, dy = px - x, py - y
    return math.sqrt(dx * dx + dy * dy)
end

function Tracker:CheckProximityToPins(ctx)
    ctx = ctx or WE:GetCurrentZone()
    if not ctx then return end

    local meta = ctx.meta
    local charZone, accZone = self:GetZoneRecords(ctx.key)
    local px, py = self:GetPlayerMapCoords(ctx.mapID)
    local currentSubZone = GetSubZoneText() or ""
    local enteredPoint = WE:FindDiscoveryPoint(meta, currentSubZone)
    local changed = false

    local function isDone(field, id)
        return charZone and charZone[field][id]
    end

    if meta and meta.discoveryPoints then
        for _, pt in ipairs(meta.discoveryPoints) do
            if not isDone("discoveredSubzones", pt.name) then
                local reached = (enteredPoint == pt) or (px and Dist(px, py, pt.x, pt.y) <= STRICT_PROXIMITY_RADIUS)
                if reached then
                    changed = self:DiscoverPoint(ctx, pt.name, WE:GetLocalizedPointName(pt)) or changed
                    charZone, accZone = self:GetZoneRecords(ctx.key)
                end
            end
        end
    end

    if px and accZone and accZone.customPins then
        for _, pt in ipairs(accZone.customPins) do
            if not isDone("discoveredSubzones", pt.name) and Dist(px, py, pt.x, pt.y) <= STRICT_PROXIMITY_RADIUS
                and not WE:FindDiscoveryPoint(meta, pt.name) then -- never complete a database point via a custom pin
                changed = self:DiscoverPoint(ctx, pt.name, pt.name) or changed
                charZone = self:GetZoneRecords(ctx.key)
            end
        end
    end

    if px and meta and meta.secrets then
        for _, sec in ipairs(meta.secrets) do
            if not isDone("secretsFound", sec.id) and Dist(px, py, sec.x, sec.y) <= STRICT_PROXIMITY_RADIUS then
                self:MarkSecretFound(ctx.key, sec.id)
                charZone = self:GetZoneRecords(ctx.key)
                local desc = WE:GetLocalizedSecretField(sec, "description")
                local stats = self:GetZoneStats(ctx.key, false)
                WE:Notify("secret", sec.name, ctx.name, stats.secretsDone, stats.secretsTotal,
                    string.format(WE:L("secretDiscovered"), sec.name, desc))
                self:CheckZoneComplete(ctx)
                if WE.MapPins then WE.MapPins:Refresh() end
                changed = true
            end
        end
    end

    if changed and WE.UI then WE.UI:Refresh() end
end

function Tracker:RecordCurrentLocation()
    local ctx = WE:GetCurrentZone()
    if not ctx then return end

    self:EnsureZoneRecord(ctx.key, ctx.name)
    self:SyncCompletedQuests(ctx.key)
    if ctx.mapID then
        self:SyncFogOfWarOverlays(ctx.mapID, ctx.key)
    end

    local subZone = GetSubZoneText()
    if subZone and subZone ~= "" and not WE:FindDiscoveryPoint(ctx.meta, subZone) then
        local _, accZone = self:GetZoneRecords(ctx.key)
        local isCustom = false
        for _, p in ipairs((accZone and accZone.customPins) or {}) do
            if p.name == subZone then isCustom = true break end
        end
        if not isCustom then
            local px, py = self:GetPlayerMapCoords(ctx.mapID)
            self:DiscoverExtraSubzone(ctx, subZone, px, py)
        end
    end
    self:CheckProximityToPins(ctx)
end

function Tracker:RecordQuestTurnIn(questID, questTitle)
    local ctx = WE:GetCurrentZone()
    if not ctx or not questID then return end

    local charZone, accZone = self:EnsureZoneRecord(ctx.key, ctx.name)
    if not charZone then return end

    charZone.completedQuests[questID] = true
    accZone.completedQuests[questID] = true

    -- Only a real string counts as a title (0.7.0 stored the XP reward here by mistake).
    local title = (type(questTitle) == "string" and questTitle ~= "") and questTitle or nil
    if not title and C_QuestLog and C_QuestLog.GetTitleForQuestID then
        local ok, t = pcall(C_QuestLog.GetTitleForQuestID, questID)
        if ok and t then title = t end
    end
    if title and title ~= "" then
        charZone.questTitles[questID] = title
        accZone.questTitles[questID] = title
    end
end

function Tracker:MarkSecretFound(zoneKey, secretId)
    self:SetDiscoveryState(zoneKey, "secretsFound", secretId, true)
end

---------------------------------------------------------------------------
-- Queries
---------------------------------------------------------------------------

local function ScopeSource(zoneKey, useAccountScope)
    local charZone, accZone = Tracker:GetZoneRecords(zoneKey)
    return useAccountScope and accZone or charZone, accZone
end

function Tracker:GetCompletedQuestList(zoneKey, useAccountScope)
    if not zoneKey then return {} end

    self:SyncCompletedQuests(zoneKey)
    local source = ScopeSource(zoneKey, useAccountScope)
    if not source or not source.completedQuests then return {} end

    local list = {}
    for qid, done in pairs(source.completedQuests) do
        if done then
            local title = source.questTitles and source.questTitles[qid]
            if type(title) ~= "string" or title == "" then title = nil end
            if not title and C_QuestLog and C_QuestLog.GetTitleForQuestID then
                local ok, t = pcall(C_QuestLog.GetTitleForQuestID, qid)
                if ok and type(t) == "string" and t ~= "" then
                    title = t
                    source.questTitles[qid] = t
                end
            end
            table.insert(list, {
                id = qid,
                title = title or string.format(WE:L("questFallback"), tonumber(qid) or 0),
            })
        end
    end

    table.sort(list, function(a, b)
        if a.title ~= b.title then
            return a.title < b.title
        end
        return (tonumber(a.id) or 0) < (tonumber(b.id) or 0)
    end)

    return list
end

function Tracker:GetExploredZonesList(useAccountScope)
    local sourceZones
    if useAccountScope then
        sourceZones = (WorldExplorerDB and WorldExplorerDB.account and WorldExplorerDB.account.zones) or {}
    else
        local entry = WorldExplorerDB and GetCharEntry(false)
        sourceZones = (entry and entry.zones) or {}
    end

    local result = {}
    for zKey, zData in pairs(sourceZones) do
        local subCount = CountKeys(zData.discoveredSubzones) + CountKeys(zData.extraSubzones)
        local questCount = CountKeys(zData.completedQuests)
        local secretCount = CountKeys(zData.secretsFound)
        if subCount > 0 or questCount > 0 or secretCount > 0 then
            local meta = WE:GetZoneMeta(zKey)
            table.insert(result, {
                zoneKey = zKey,
                zoneName = WE:GetZoneDisplayName(zKey),
                continent = (meta and meta.continent) or WE:L("continentWorld"),
                subCount = subCount,
                questCount = questCount,
                secretCount = secretCount,
            })
        end
    end

    table.sort(result, function(a, b)
        return a.zoneName < b.zoneName
    end)

    return result
end

local function Pct(done, total)
    if not total or total <= 0 then return 0 end
    return math.min(100, math.floor((done / total) * 100 + 0.5))
end

-- zoneKey nil -> current zone.
function Tracker:GetZoneStats(zoneKey, useAccountScope)
    local displayName
    if not zoneKey then
        local ctx = WE:GetCurrentZone()
        zoneKey = ctx and ctx.key
        displayName = ctx and ctx.name
    end
    displayName = displayName or (zoneKey and WE:GetZoneDisplayName(zoneKey)) or WE:L("unknownZone")

    local source, accZone = ScopeSource(zoneKey, useAccountScope)
    local meta = WE:GetZoneMeta(zoneKey)

    -- Areas: only database discovery points count toward the percentage.
    local subTotal = (meta and meta.totalSubzones and meta.totalSubzones > 0) and meta.totalSubzones or nil
    local subFound = 0
    if subTotal and source then
        for _, pt in ipairs(meta.discoveryPoints) do
            if source.discoveredSubzones[pt.name] then subFound = subFound + 1 end
        end
    end
    local extraFound = source and CountKeys(source.extraSubzones) or 0
    local customFound = 0
    if source and accZone then
        for _, p in ipairs(accZone.customPins or {}) do
            if source.discoveredSubzones[p.name] then customFound = customFound + 1 end
        end
    end

    -- Quests: a total exists only when the zone has a real quest-ID list.
    local questsTurnedIn = source and CountKeys(source.completedQuests) or 0
    local questsTotal = (meta and meta.quests and #meta.quests > 0) and #meta.quests or nil
    local questsDone = questsTurnedIn
    if questsTotal then
        questsDone = 0
        for qid in pairs(meta.questSet) do
            if source and source.completedQuests[qid] then questsDone = questsDone + 1 end
        end
    end

    local secretsTotal = (meta and meta.secrets and #meta.secrets) or 0
    local secretsDone = 0
    if source and secretsTotal > 0 then
        for _, sec in ipairs(meta.secrets) do
            if source.secretsFound[sec.id] then secretsDone = secretsDone + 1 end
        end
    end

    local statusLabel = WE:L("statusUnexplored")
    local statusColor = "|cff9d9d9d"
    if subFound > 0 or extraFound > 0 or customFound > 0 or questsTurnedIn > 0 or secretsDone > 0 then
        statusLabel = WE:L("statusActive")
        statusColor = "|cff1eff00"
    end
    if subTotal and subFound == subTotal and (secretsTotal == 0 or secretsDone == secretsTotal) then
        statusLabel = WE:L("statusComplete")
        statusColor = "|cffffd100"
    end

    return {
        zoneKey = zoneKey,
        zoneName = displayName,
        meta = meta,
        isKnownZone = meta ~= nil,
        subFound = subFound,
        subTotal = subTotal,
        extraFound = extraFound,
        customFound = customFound,
        mapPct = Pct(subFound, subTotal),
        questsDone = questsDone,
        questsTotal = questsTotal,
        questsTurnedIn = questsTurnedIn,
        activeQuestLogCount = self:GetActiveQuestLogCount(),
        questPct = questsTotal and Pct(questsDone, questsTotal) or 0,
        secretsDone = secretsDone,
        secretsTotal = secretsTotal,
        secretsPct = Pct(secretsDone, secretsTotal),
        statusLabel = statusLabel,
        statusColor = statusColor,
        source = source,
        accZone = accZone,
    }
end
