local addonName, WE = ...

WE.UI = {}
local UI = WE.UI

local function CreateMiniBar(parent, yOffset, r, g, b)
    local bar = CreateFrame("StatusBar", nil, parent)
    bar:SetSize(188, 10)
    bar:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, yOffset)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bar:GetStatusBarTexture():SetHorizTile(false)
    bar:SetMinMaxValues(0, 100)
    bar:SetValue(0)
    bar:SetStatusBarColor(r, g, b)

    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.75)

    local text = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("CENTER", bar, "CENTER", 0, 0)
    bar.label = text

    return bar
end

function UI:Init()
    local f = CreateFrame("Frame", "WorldExplorerMiniWidget", UIParent, "BackdropTemplate")
    f:SetSize(212, 92)
    f:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -220, -180)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetClampedToScreen(true)

    if f.SetBackdrop then
        f:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        f:SetBackdropColor(0.06, 0.07, 0.09, 0.88)
        f:SetBackdropBorderColor(0.45, 0.45, 0.5, 0.9)
    end

    f:SetScript("OnDragStart", function(self)
        if not WorldExplorerCharDB.locked then
            self:StartMoving()
        end
    end)

    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relPoint, x, y = self:GetPoint()
        WorldExplorerCharDB.pos = { point, relPoint, x, y }
    end)

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    title:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -9)
    title:SetWidth(188)
    title:SetJustifyH("LEFT")
    title:SetWordWrap(false)
    f.title = title

    local statusText = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    statusText:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -23)
    statusText:SetWidth(188)
    statusText:SetJustifyH("LEFT")
    statusText:SetWordWrap(false)
    f.statusText = statusText

    f.mapBar = CreateMiniBar(f, -38, 0.25, 0.72, 0.95)
    f.questBar = CreateMiniBar(f, -52, 0.95, 0.76, 0.18)
    f.secretBar = CreateMiniBar(f, -66, 0.72, 0.38, 0.95)

    f:SetScript("OnMouseUp", function(self, button)
        if button == "RightButton" then
            WE.Options:Toggle("accountScope")
        elseif button == "LeftButton" and IsShiftKeyDown and IsShiftKeyDown() then
            WE.Journal:Toggle()
        end
    end)

    f:SetScript("OnEnter", function(self)
        local stats = WE.Tracker:GetZoneStats(nil, WorldExplorerCharDB.accountScope)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(stats.zoneName, 1, 0.82, 0)
        GameTooltip:AddLine(stats.statusColor .. stats.statusLabel .. "|r", 1, 1, 1)
        GameTooltip:AddLine(" ")

        local scopeName = WorldExplorerCharDB.accountScope and WE:L("scopeValAccount") or WE:L("scopeValChar")
        GameTooltip:AddDoubleLine(WE:L("scopeLabel"), scopeName, 0.7, 0.7, 0.7, 1, 1, 1)

        if stats.subTotal then
            GameTooltip:AddDoubleLine(WE:L("areasLabel"), string.format(WE:L("areasFmt"), stats.subFound, stats.subTotal), 0.8, 0.9, 1, 1, 1, 1)
        else
            GameTooltip:AddDoubleLine(WE:L("areasLabel"), string.format(WE:L("areasAutoFmt"), stats.subFound + stats.customFound), 0.8, 0.9, 1, 1, 1, 1)
        end

        if stats.extraFound > 0 then
            GameTooltip:AddDoubleLine(WE:L("extraAreasLabel"), tostring(stats.extraFound), 0.7, 0.8, 0.9, 1, 1, 1)
        end

        if stats.questsTotal then
            GameTooltip:AddDoubleLine(WE:L("questsLabel"), string.format(WE:L("questsFmt"), stats.questsDone, stats.questsTotal), 1, 0.9, 0.6, 1, 1, 1)
            if stats.questsTurnedIn > stats.questsDone then
                GameTooltip:AddDoubleLine(WE:L("questsAllTurnedInLabel"), tostring(stats.questsTurnedIn), 0.8, 0.75, 0.6, 1, 1, 1)
            end
        else
            GameTooltip:AddDoubleLine(WE:L("questsLabel"), string.format(WE:L("questsAutoFmt"), stats.questsDone), 1, 0.9, 0.6, 1, 1, 1)
        end

        GameTooltip:AddDoubleLine(WE:L("activeQuestsLabel"), string.format(WE:L("activeQuestsFmt"), stats.activeQuestLogCount or 0), 0.75, 0.85, 0.95, 0.85, 0.95, 1)

        local subList = {}
        if stats.source then
            local seen = {}
            for _, pt in ipairs((stats.meta and stats.meta.discoveryPoints) or {}) do
                if stats.source.discoveredSubzones[pt.name] then
                    table.insert(subList, WE:GetLocalizedPointName(pt))
                    seen[pt.name] = true
                end
            end
            for sName, ok in pairs(stats.source.discoveredSubzones) do
                if ok and not seen[sName] then table.insert(subList, sName) end
            end
            for sName, ok in pairs(stats.source.extraSubzones or {}) do
                if ok then table.insert(subList, "|cff999999" .. sName .. "|r") end
            end
            table.sort(subList)
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(string.format(WE:L("subzonesHeader"), #subList), 0.5, 0.85, 1.0)
        if #subList == 0 then
            GameTooltip:AddLine(WE:L("subzonesEmpty"), 0.65, 0.65, 0.65)
        else
            local maxSub = math.min(#subList, 12)
            for i = 1, maxSub do
                GameTooltip:AddLine("  |cff1eff00•|r " .. subList[i], 0.9, 0.95, 1.0)
            end
            if #subList > maxSub then
                GameTooltip:AddLine(string.format(WE:L("moreCompletedQuests"), #subList - maxSub), 0.7, 0.7, 0.7)
            end
        end

        local exploredZones = WE.Tracker:GetExploredZonesList(WorldExplorerCharDB.accountScope)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(string.format(WE:L("exploredZonesSection"), #exploredZones), 1.0, 0.82, 0.2)
        if #exploredZones == 0 then
            GameTooltip:AddLine(WE:L("exploredZonesNone"), 0.65, 0.65, 0.65)
        else
            local maxZ = math.min(#exploredZones, 12)
            for i = 1, maxZ do
                local ez = exploredZones[i]
                GameTooltip:AddLine(string.format(WE:L("exploredZoneLine"), ez.zoneName, ez.subCount), 0.95, 0.95, 0.9)
            end
            if #exploredZones > maxZ then
                GameTooltip:AddLine(string.format(WE:L("moreCompletedQuests"), #exploredZones - maxZ), 0.7, 0.7, 0.7)
            end
        end

        local doneQuests = WE.Tracker:GetCompletedQuestList(stats.zoneKey, WorldExplorerCharDB.accountScope)
        if doneQuests and #doneQuests > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(string.format(WE:L("completedQuestsTitle"), #doneQuests), 1.0, 0.82, 0.2)
            local maxShown = math.min(#doneQuests, 10)
            for i = 1, maxShown do
                local q = doneQuests[i]
                GameTooltip:AddLine(string.format(WE:L("completedQuestItem"), q.title, q.id), 0.9, 0.95, 0.9)
            end
            if #doneQuests > maxShown then
                GameTooltip:AddLine(string.format(WE:L("moreCompletedQuests"), #doneQuests - maxShown), 0.7, 0.7, 0.7)
            end
        end

        if stats.meta and stats.meta.secrets and #stats.meta.secrets > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(WE:L("secretsInZone"), 0.85, 0.65, 1)
            for _, sec in ipairs(stats.meta.secrets) do
                local found = stats.source and stats.source.secretsFound[sec.id]
                local prefix = found and WE:L("secretFoundPrefix") or WE:L("secretUnfoundPrefix")
                if WorldExplorerCharDB.showHints or found then
                    local descText = WE:GetLocalizedSecretField(sec, "description")
                    local desc = (descText ~= "") and (" — " .. descText) or ""
                    GameTooltip:AddLine(prefix .. sec.name .. desc, 0.92, 0.92, 0.95, true)
                else
                    GameTooltip:AddLine(prefix .. WE:L("secretHiddenHints"), 0.6, 0.6, 0.6)
                end
            end
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cff888888" .. WE:L("widgetFooterMap") .. "|r", 0.6, 0.6, 0.6)
        GameTooltip:AddLine("|cff888888" .. WE:L("widgetFooterCmds") .. "|r", 0.6, 0.6, 0.6)
        GameTooltip:Show()
    end)

    f:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    self.frame = f
    self:RestorePosition()
    if WorldExplorerCharDB.showHUD == false then f:Hide() end
    self:Refresh()
end

function UI:ResetPosition()
    if not self.frame then return end
    self.frame:ClearAllPoints()
    self.frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -220, -180)
end

function UI:RestorePosition()
    if not self.frame or not WorldExplorerCharDB or not WorldExplorerCharDB.pos then return end
    local p = WorldExplorerCharDB.pos
    self.frame:ClearAllPoints()
    self.frame:SetPoint(p[1], UIParent, p[2], p[3], p[4])
end

function UI:Refresh()
    if WE.Journal then WE.Journal:Refresh() end
    if not self.frame then return end
    local stats = WE.Tracker:GetZoneStats(nil, WorldExplorerCharDB.accountScope)
    local exploredZones = WE.Tracker:GetExploredZonesList(WorldExplorerCharDB.accountScope)

    local tag = (stats.meta and stats.meta.category == "FOREVER_NEW") and "|cff00e5ff[F]|r " or ""
    self.frame.title:SetText(tag .. stats.zoneName)
    self.frame.statusText:SetText(string.format("|cffffd100%s|r", string.format(WE:L("zoneHeaderSummary"), stats.subFound + stats.extraFound + stats.customFound, stats.questsTurnedIn, #exploredZones)))

    -- Bars show a percentage only when the database has a real reference list;
    -- otherwise they are grey and show a plain count.
    self.frame.mapBar:SetValue(stats.mapPct)
    if stats.subTotal then
        self.frame.mapBar:SetStatusBarColor(0.25, 0.72, 0.95)
        self.frame.mapBar.label:SetText(string.format(WE:L("barMapFmt"), stats.subFound, stats.subTotal))
    else
        self.frame.mapBar:SetStatusBarColor(0.4, 0.4, 0.4)
        self.frame.mapBar.label:SetText(string.format(WE:L("barAreasFmt"), stats.subFound + stats.extraFound + stats.customFound))
    end

    self.frame.questBar:SetValue(stats.questPct)
    if stats.questsTotal then
        self.frame.questBar:SetStatusBarColor(0.95, 0.76, 0.18)
        self.frame.questBar.label:SetText(string.format(WE:L("barQuestsFmt"), stats.questsDone, stats.questsTotal))
    else
        self.frame.questBar:SetStatusBarColor(0.4, 0.4, 0.4)
        self.frame.questBar.label:SetText(string.format(WE:L("barQuestsAutoFmt"), stats.questsTurnedIn))
    end

    self.frame.secretBar:SetValue(stats.secretsPct)
    if stats.secretsTotal > 0 then
        self.frame.secretBar:SetStatusBarColor(0.72, 0.38, 0.95)
        self.frame.secretBar.label:SetText(string.format(WE:L("barSecretsFmt"), stats.secretsDone, stats.secretsTotal))
    else
        -- Empty grey bar instead of a misleading "100%".
        self.frame.secretBar:SetStatusBarColor(0.4, 0.4, 0.4)
        self.frame.secretBar.label:SetText(WE:L("barSecretsNone"))
    end
end
