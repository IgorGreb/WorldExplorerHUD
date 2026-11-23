local addonName, WE = ...

--[[
World map + minimap pins, rendered through HereBeDragons-Pins-2.0.

HBD-Pins registers a proper MapCanvas data provider on WorldMapFrame, so pins
live in the map's own pin layer (correct frame levels, zoom scaling, no overlap
with other UI) and are only drawn on the zone map they belong to. The same
library positions minimap pins (incl. rotating minimap and edge floating).

Only the zone shown on the world map and the player's current zone have pins
registered at any time; everything else is released back to the frame pools.
]]

WE.MapPins = {}
local MapPins = WE.MapPins

local HBDPins = LibStub and LibStub("HereBeDragons-Pins-2.0", true)
MapPins.available = HBDPins ~= nil

local REF = "WorldExplorerHUD"
local ARRIVAL_YARDS = 10
local WORLD_PIN_SIZE = 20
local MINI_PIN_SIZE = 14

local activeTarget = nil
local compassFrame = nil
local lastViewedMapID = nil

local worldPool, miniPool = {}, {}
-- [zoneKey] = { world = { frames }, mini = { frames } }
local zonePins = {}
MapPins._zonePins = zonePins -- exposed for tests / debugging

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

local function IsZoneLevelMap(mapType)
    if not (Enum and Enum.UIMapType) or mapType == nil then return true end
    return mapType == Enum.UIMapType.Zone
end

local function IsTracked(zoneKey, kind, id)
    return activeTarget ~= nil and activeTarget.zoneKey == zoneKey and activeTarget.kind == kind and activeTarget.id == id
end

local function IsTargetDoneForChar(target)
    local charZone = WE.Tracker:GetZoneRecords(target.zoneKey)
    if not charZone then return false end
    if target.kind == "secret" then
        return charZone.secretsFound[target.id] and true or false
    end
    return charZone.discoveredSubzones[target.id] and true or false
end

-- Map the player is looking at in the world map: mapID, zoneKey (exact, no parent walk).
local function GetViewedZone()
    if not (WorldMapFrame and WorldMapFrame:IsShown() and WorldMapFrame.GetMapID) then return nil end
    local mapID = WorldMapFrame:GetMapID()
    if not mapID then return nil end
    local info = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(mapID)
    if not IsZoneLevelMap(info and info.mapType) then return nil end
    return mapID, WE:ResolveZoneKeyByMapID(mapID, true)
end

---------------------------------------------------------------------------
-- Pin frames
---------------------------------------------------------------------------

local function Pin_OnEnter(self)
    self.ring:Show()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine(self.pointTitle or WE:L("discoveryPointDefault"), 1, 0.82, 0)

    if self.isDiscovered then
        GameTooltip:AddLine(WE:L("discoveredTag"), 0.8, 1, 0.8)
    else
        GameTooltip:AddLine(WE:L("unexploredTag"), 1, 0.9, 0.7, true)
    end

    if self.descriptionText and self.descriptionText ~= "" then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(WE:L("whatsHere") .. self.descriptionText, 0.95, 0.9, 1.0, true)
    end

    if self.hintText and self.hintText ~= "" and WorldExplorerCharDB.showHints then
        GameTooltip:AddLine(WE:L("locationHint") .. self.hintText, 0.75, 0.85, 1, true)
    end

    GameTooltip:AddLine(string.format(WE:L("coordsLine"), self.coordX or 0, self.coordY or 0), 0.7, 0.7, 0.7)

    if IsTracked(self.zoneKey, self.kind, self.pointKey) then
        GameTooltip:AddLine(WE:L("leftClickCancel"), 0.4, 1, 0.8)
    else
        GameTooltip:AddLine(WE:L("leftClickTrack"), 0.6, 0.6, 0.6)
    end
    GameTooltip:AddLine(WE:L("rightClickToggle"), 0.6, 0.6, 0.6)
    if self.kind == "custom" then
        GameTooltip:AddLine(WE:L("shiftRightDelete"), 0.6, 0.6, 0.6)
    end
    GameTooltip:Show()
end

local function Pin_OnLeave(self)
    self.ring:Hide()
    GameTooltip:Hide()
end

local function Pin_OnClick(self, mouseButton)
    if mouseButton == "RightButton" and self.kind == "custom" and IsShiftKeyDown and IsShiftKeyDown() then
        if WE.Tracker:RemoveCustomPin(self.zoneKey, self.pointKey) then
            DEFAULT_CHAT_FRAME:AddMessage(string.format(WE:L("customPinDeleted"), self.pointTitle))
            if IsTracked(self.zoneKey, self.kind, self.pointKey) then activeTarget = nil end
            GameTooltip:Hide()
            if WE.UI then WE.UI:Refresh() end
            MapPins:Refresh()
        end
        return
    end

    if mouseButton == "RightButton" then
        -- Toggle in the scope the player is looking at (see Tracker:SetDiscoveryState).
        local accountScope = WorldExplorerCharDB.accountScope
        local field = (self.kind == "secret") and "secretsFound" or "discoveredSubzones"
        local newState = not self.isDiscovered
        WE.Tracker:SetDiscoveryState(self.zoneKey, field, self.pointKey, newState, accountScope)
        if not newState and accountScope then
            DEFAULT_CHAT_FRAME:AddMessage(string.format(WE:L("unmarkedAllChars"), self.pointTitle))
        end
        if WE.UI then WE.UI:Refresh() end
        MapPins:Refresh()
        return
    end

    if IsTracked(self.zoneKey, self.kind, self.pointKey) then
        MapPins:ClearTarget()
        return
    end

    activeTarget = {
        mapID = self.mapID,
        zoneKey = self.zoneKey,
        kind = self.kind,
        id = self.pointKey,
        title = self.pointTitle,
        x = self.coordX,
        y = self.coordY,
    }
    -- Already explored by this character? Then finish on arrival instead of on discovery.
    activeTarget.wasDone = IsTargetDoneForChar(activeTarget)
    DEFAULT_CHAT_FRAME:AddMessage(string.format(WE:L("trackingStarted"), self.pointTitle, self.coordX, self.coordY))
    MapPins:Refresh()
    MapPins:UpdateCompass()
end

local function CreatePin(size)
    local btn = CreateFrame("Button", nil, UIParent)
    btn:SetSize(size, size)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetSize(size + 4, size + 4)
    bg:SetPoint("CENTER", btn, "CENTER", 0, 0)
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    bg:SetAlpha(0.7)
    btn.bg = bg

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints(true)
    btn.icon = icon

    local ring = btn:CreateTexture(nil, "OVERLAY")
    ring:SetSize(size * 1.5, size * 1.5)
    ring:SetPoint("CENTER", btn, "CENTER", 0, 0)
    ring:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    ring:SetBlendMode("ADD")
    ring:Hide()
    btn.ring = ring

    btn:SetScript("OnEnter", Pin_OnEnter)
    btn:SetScript("OnLeave", Pin_OnLeave)
    btn:SetScript("OnClick", Pin_OnClick)
    btn:Hide()
    return btn
end

local function AcquireFrom(pool, size)
    local f = table.remove(pool)
    if not f then f = CreatePin(size) end
    return f
end

local function ApplyVisual(btn, entry, isTracked)
    btn.icon:SetTexCoord(0, 1, 0, 1)
    btn.icon:SetVertexColor(1, 1, 1)
    if isTracked then
        btn.icon:SetTexture("Interface\\MINIMAP\\TRACKING\\None")
        btn:SetAlpha(1.0)
    elseif entry.discovered then
        btn.icon:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
        btn:SetAlpha(0.9)
    elseif entry.kind == "secret" then
        btn.icon:SetTexture("Interface\\MINIMAP\\UI-Minimap-Ping-Center")
        btn.icon:SetVertexColor(0.8, 0.4, 1.0)
        btn:SetAlpha(1.0)
    else
        btn.icon:SetTexture("Interface\\TaxiFrame\\UI-Taxi-Icon-Yellow")
        btn:SetAlpha(1.0)
    end
end

local function FillPin(btn, zoneKey, mapID, entry)
    btn.mapID = mapID
    btn.zoneKey = zoneKey
    btn.kind = entry.kind
    btn.pointKey = entry.key
    btn.pointTitle = entry.title
    btn.coordX = entry.x
    btn.coordY = entry.y
    btn.isDiscovered = entry.discovered
    btn.hintText = entry.hint
    btn.descriptionText = entry.description
    ApplyVisual(btn, entry, IsTracked(zoneKey, entry.kind, entry.key))
end

---------------------------------------------------------------------------
-- Pin lists
---------------------------------------------------------------------------

-- kind: "point" | "custom" | "secret"; key: canonical point name / custom pin name / secret id.
local function BuildPinList(zoneKey)
    local stats = WE.Tracker:GetZoneStats(zoneKey, WorldExplorerCharDB.accountScope)
    local meta, source = stats.meta, stats.source
    local list = {}
    local function has(field, id)
        return (source and source[field] and source[field][id]) and true or false
    end

    local shown = {}
    if meta and meta.discoveryPoints then
        for _, pt in ipairs(meta.discoveryPoints) do
            shown[pt.name] = true
            table.insert(list, {
                kind = "point", key = pt.name, title = WE:GetLocalizedPointName(pt),
                x = pt.x, y = pt.y, discovered = has("discoveredSubzones", pt.name),
                description = pt.description,
            })
        end
    end

    if stats.accZone and stats.accZone.customPins then
        for _, pt in ipairs(stats.accZone.customPins) do
            if not shown[pt.name] then
                shown[pt.name] = true
                table.insert(list, {
                    kind = "custom", key = pt.name, title = pt.name,
                    x = pt.x, y = pt.y, discovered = has("discoveredSubzones", pt.name),
                    description = pt.description,
                })
            end
        end
    end

    if meta and meta.secrets then
        for _, sec in ipairs(meta.secrets) do
            local found = has("secretsFound", sec.id)
            if found or WorldExplorerCharDB.showHints or IsTracked(zoneKey, "secret", sec.id) then
                table.insert(list, {
                    kind = "secret", key = sec.id, title = WE:L("secretPinPrefix") .. sec.name,
                    x = sec.x, y = sec.y, discovered = found,
                    hint = WE:GetLocalizedSecretField(sec, "hint"),
                    description = WE:GetLocalizedSecretField(sec, "description"),
                })
            end
        end
    end
    return list
end

local function ReleaseZone(zoneKey)
    local z = zonePins[zoneKey]
    if not z then return end
    for _, f in ipairs(z.world) do
        HBDPins:RemoveWorldMapIcon(REF, f)
        f:Hide()
        table.insert(worldPool, f)
    end
    for _, f in ipairs(z.mini) do
        HBDPins:RemoveMinimapIcon(REF, f)
        f:Hide()
        table.insert(miniPool, f)
    end
    zonePins[zoneKey] = nil
end

local function BuildZone(zoneKey, want)
    ReleaseZone(zoneKey)
    local z = { world = {}, mini = {} }
    zonePins[zoneKey] = z

    for _, entry in ipairs(BuildPinList(zoneKey)) do
        local isTracked = IsTracked(zoneKey, entry.kind, entry.key)
        if want.worldMapID then
            local f = AcquireFrom(worldPool, WORLD_PIN_SIZE)
            FillPin(f, zoneKey, want.worldMapID, entry)
            if HBDPins:AddWorldMapIconMap(REF, f, want.worldMapID, entry.x / 100, entry.y / 100, 0) then
                table.insert(z.world, f)
            else
                table.insert(worldPool, f)
            end
        end
        -- Minimap: only what is still to be found, plus the tracked target (floats on the edge).
        if want.miniMapID and (isTracked or not entry.discovered) then
            local f = AcquireFrom(miniPool, MINI_PIN_SIZE)
            FillPin(f, zoneKey, want.miniMapID, entry)
            if HBDPins:AddMinimapIconMap(REF, f, want.miniMapID, entry.x / 100, entry.y / 100, false, isTracked) then
                table.insert(z.mini, f)
            else
                table.insert(miniPool, f)
            end
        end
    end
end

---------------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------------

function MapPins:Refresh()
    if not self.available or not WE.ready then return end

    local wanted = {}

    if WorldExplorerCharDB.showMapPins then
        local viewedMapID, viewedKey = GetViewedZone()
        if viewedKey then
            local questsChanged = WE.Tracker:SyncCompletedQuests(viewedKey)
            local fogChanged = WE.Tracker:SyncFogOfWarOverlays(viewedMapID, viewedKey)
            if (questsChanged or fogChanged) and WE.UI then WE.UI:Refresh() end
            wanted[viewedKey] = { worldMapID = viewedMapID }
        end
    end

    if WorldExplorerCharDB.showMinimapPins then
        local ctx = WE:GetCurrentZone()
        if ctx and ctx.mapID then
            wanted[ctx.key] = wanted[ctx.key] or {}
            wanted[ctx.key].miniMapID = ctx.mapID
        end
    end

    for key in pairs(zonePins) do
        if not wanted[key] then ReleaseZone(key) end
    end
    for key, want in pairs(wanted) do
        BuildZone(key, want)
    end
end

function MapPins:ClearTarget()
    if activeTarget then
        DEFAULT_CHAT_FRAME:AddMessage(string.format(WE:L("trackingCancelled"), activeTarget.title))
        activeTarget = nil
        if compassFrame then compassFrame:Hide() end
        self:Refresh()
    end
end

function MapPins:FormatDistanceText(yards, meters)
    local unitMode = WorldExplorerCharDB.distanceUnit or "BOTH"
    if unitMode == "METERS" then
        return string.format("%d m", meters)
    elseif unitMode == "FEET" then
        local feet = math.floor(yards * 3 + 0.5)
        return string.format("%d ft", feet)
    else
        local feet = math.floor(yards * 3 + 0.5)
        return string.format("%d m / %d ft", meters, feet)
    end
end

function MapPins:UpdateCompass()
    if not compassFrame then return end
    if not activeTarget then
        compassFrame:Hide()
        return
    end

    local ctx = WE:GetCurrentZone()
    if not ctx or ctx.key ~= activeTarget.zoneKey then
        compassFrame.text:SetText(string.format(WE:L("targetOtherZone"), activeTarget.title, WE:GetZoneDisplayName(activeTarget.zoneKey)))
        compassFrame:Show()
        return
    end

    local px, py = WE.Tracker:GetPlayerMapCoords(ctx.mapID)
    local yards, meters
    if px and py then
        yards, meters = WE.Tracker:CalculateDistance(ctx.mapID or activeTarget.mapID, px, py, activeTarget.x, activeTarget.y)
    end

    -- Finished: newly discovered by this character (points AND secrets), or reached a point
    -- that was already explored when tracking started.
    local reached = (not activeTarget.wasDone and IsTargetDoneForChar(activeTarget))
        or (activeTarget.wasDone and yards and yards <= ARRIVAL_YARDS)
    if reached then
        DEFAULT_CHAT_FRAME:AddMessage(string.format(WE:L("trackingReached"), activeTarget.title))
        activeTarget = nil
        compassFrame:Hide()
        self:Refresh()
        return
    end

    if yards then
        local distStr = self:FormatDistanceText(yards, meters)
        compassFrame.text:SetText(string.format(WE:L("compassDistFmt"), activeTarget.title, distStr))
        compassFrame:Show()
    end
end

function MapPins:Init()
    if not self.available then
        DEFAULT_CHAT_FRAME:AddMessage(WE:L("pinsLibMissing"))
    elseif WorldMapFrame then
        WorldMapFrame:HookScript("OnShow", function()
            lastViewedMapID = nil
            MapPins:Refresh()
        end)
        WorldMapFrame:HookScript("OnHide", function()
            lastViewedMapID = nil
            MapPins:Refresh()
        end)
        -- Cheap numeric check: rebuild only when the viewed map actually changes.
        WorldMapFrame:HookScript("OnUpdate", function(frame)
            local id = frame.GetMapID and frame:GetMapID()
            if id ~= lastViewedMapID then
                lastViewedMapID = id
                MapPins:Refresh()
            end
        end)
    end

    compassFrame = CreateFrame("Frame", "WorldExplorerCompass", UIParent, "BackdropTemplate")
    compassFrame:SetSize(236, 26)
    compassFrame:SetPoint("TOP", (WE.UI and WE.UI.frame) or UIParent, "BOTTOM", 0, -4)
    compassFrame:EnableMouse(true)
    if compassFrame.SetBackdrop then
        compassFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        compassFrame:SetBackdropColor(0.05, 0.08, 0.12, 0.92)
    end

    local closeBtn = CreateFrame("Button", nil, compassFrame, "UIPanelCloseButton")
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("RIGHT", compassFrame, "RIGHT", -2, 0)
    closeBtn:SetScript("OnClick", function()
        MapPins:ClearTarget()
    end)

    compassFrame:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" then
            MapPins:ClearTarget()
        end
    end)

    compassFrame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WE:L("compassTooltipTitle"), 1, 0.82, 0)
        GameTooltip:AddLine(WE:L("compassTooltipHint"), 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    compassFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)

    compassFrame.text = compassFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    compassFrame.text:SetPoint("LEFT", compassFrame, "LEFT", 8, 0)
    compassFrame.text:SetPoint("RIGHT", closeBtn, "LEFT", -2, 0)
    compassFrame.text:SetJustifyH("CENTER")
    compassFrame.text:SetWordWrap(false)
    compassFrame:Hide()
end
