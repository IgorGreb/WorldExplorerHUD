local addonName, WE = ...

--[[
Minimap button.
  * A LibDataBroker "launcher" object is always created, so Titan Panel, ElvUI,
    Bazooka etc. can show it too.
  * If LibDBIcon-1.0 is available (embedded by the release packager, or loaded
    by another addon) it draws the minimap button.
  * Otherwise a small built-in button is used. It stores its position in the
    same table/keys LibDBIcon uses (WorldExplorerDB.minimapIcon.minimapPos/hide),
    so switching between the two keeps the button where the player left it.
]]

WE.MinimapButton = {}
local MB = WE.MinimapButton

local LDB_NAME = "WorldExplorerHUD"
local ICON = "Interface\\Icons\\INV_Misc_Map_01"

local dataObject, libIcon, fallback

local function OnClick(_, button)
    if IsShiftKeyDown and IsShiftKeyDown() then
        WE.Options:Toggle("showHUD")
    elseif button == "RightButton" then
        WE.Settings:Open()
    else
        WE.Journal:Toggle()
    end
end

local function OnTooltipShow(tt)
    tt:AddLine("World Explorer HUD", 1, 0.82, 0)
    local stats = WE.Tracker:GetZoneStats(nil, WorldExplorerCharDB.accountScope)
    if stats.subTotal then
        tt:AddDoubleLine(stats.zoneName, string.format("%d/%d (%d%%)", stats.subFound, stats.subTotal, stats.mapPct), 1, 1, 1, 0.6, 0.9, 1)
    else
        tt:AddLine(stats.zoneName, 1, 1, 1)
    end
    tt:AddLine(" ")
    tt:AddLine(WE:L("mmLeft"), 0.9, 0.9, 0.9)
    tt:AddLine(WE:L("mmRight"), 0.9, 0.9, 0.9)
    tt:AddLine(WE:L("mmShift"), 0.9, 0.9, 0.9)
    if not libIcon then tt:AddLine(WE:L("mmDrag"), 0.9, 0.9, 0.9) end
end

---------------------------------------------------------------------------
-- Built-in fallback button
---------------------------------------------------------------------------

local function PositionFallback(btn)
    local angle = math.rad(WorldExplorerDB.minimapIcon.minimapPos or 220)
    local radius = (Minimap:GetWidth() / 2) + 5
    btn:ClearAllPoints()
    btn:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

local function DragUpdate(btn)
    local mx, my = Minimap:GetCenter()
    local cx, cy = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    cx, cy = cx / scale, cy / scale
    local deg = math.deg(math.atan2(cy - my, cx - mx)) % 360
    WorldExplorerDB.minimapIcon.minimapPos = deg
    PositionFallback(btn)
end

local function CreateFallback()
    local btn = CreateFrame("Button", "WorldExplorerMinimapButton", Minimap)
    btn:SetSize(31, 31)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:RegisterForDrag("LeftButton")
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local overlay = btn:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(53, 53)
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    overlay:SetPoint("TOPLEFT")

    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetSize(20, 20)
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    bg:SetPoint("TOPLEFT", 7, -5)

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetSize(17, 17)
    icon:SetTexture(ICON)
    icon:SetPoint("TOPLEFT", 7, -6)
    btn.icon = icon

    btn:SetScript("OnClick", OnClick)
    btn:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", DragUpdate)
    end)
    btn:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        OnTooltipShow(GameTooltip)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    PositionFallback(btn)
    return btn
end

---------------------------------------------------------------------------

function MB:Init()
    local LDB = LibStub and LibStub("LibDataBroker-1.1", true)
    if LDB then
        dataObject = LDB:NewDataObject(LDB_NAME, {
            type = "launcher",
            text = "World Explorer",
            icon = ICON,
            OnClick = OnClick,
            OnTooltipShow = OnTooltipShow,
        })
    end

    libIcon = LibStub and LibStub("LibDBIcon-1.0", true)
    if libIcon and dataObject then
        libIcon:Register(LDB_NAME, dataObject, WorldExplorerDB.minimapIcon)
    else
        libIcon = nil
        if Minimap then fallback = CreateFallback() end
    end
    self:Update()
end

function MB:Update()
    local show = not WorldExplorerDB.minimapIcon.hide
    if libIcon then
        if show then libIcon:Show(LDB_NAME) else libIcon:Hide(LDB_NAME) end
    elseif fallback then
        if show then
            PositionFallback(fallback)
            fallback:Show()
        else
            fallback:Hide()
        end
    end
end

-- for tests / debugging
function MB:GetBackend()
    return libIcon and "LibDBIcon" or (fallback and "builtin") or "none"
end
MB._OnClick = OnClick
