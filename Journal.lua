local addonName, WE = ...

--[[
Explorer's Journal: every database zone grouped by continent with progress bars,
plus "other" zones the player visited that are not in the database.
BuildModel() is pure data (unit-tested); the frame only renders it.
]]

WE.Journal = {}
local Journal = WE.Journal

local CONTINENT_ORDER = { ["Eastern Kingdoms"] = 1, ["Kalimdor"] = 2 }
local ROW_W = 404

---------------------------------------------------------------------------
-- Model
---------------------------------------------------------------------------

local function IsVisited(st)
    return st.subFound > 0 or st.extraFound > 0 or st.customFound > 0 or st.questsTurnedIn > 0 or st.secretsDone > 0
end

function Journal:BuildModel(accountScope, hideUnvisited)
    local sectionsByName, sections = {}, {}
    local model = { areasDone = 0, areasTotal = 0, secretsDone = 0, secretsTotal = 0, visited = 0, sections = sections, other = {} }

    for key, meta in pairs(WE.ZoneData) do
        local st = WE.Tracker:GetZoneStats(key, accountScope)
        local visited = IsVisited(st)
        local contName = meta.continent or WE:L("continentWorld")
        local sec = sectionsByName[contName]
        if not sec then
            sec = { name = contName, done = 0, total = 0, rows = {} }
            sectionsByName[contName] = sec
            table.insert(sections, sec)
        end
        sec.done = sec.done + st.subFound
        sec.total = sec.total + (st.subTotal or 0)
        model.areasDone = model.areasDone + st.subFound
        model.areasTotal = model.areasTotal + (st.subTotal or 0)
        model.secretsDone = model.secretsDone + st.secretsDone
        model.secretsTotal = model.secretsTotal + st.secretsTotal
        if visited then model.visited = model.visited + 1 end

        if visited or not hideUnvisited then
            table.insert(sec.rows, {
                key = key,
                name = st.zoneName,
                isNew = meta.category == "FOREVER_NEW",
                levelMin = meta.levelRange and meta.levelRange[1],
                levelMax = meta.levelRange and meta.levelRange[2],
                done = st.subFound, total = st.subTotal or 0, pct = st.mapPct,
                secretsDone = st.secretsDone, secretsTotal = st.secretsTotal,
                questsDone = st.questsDone, questsTotal = st.questsTotal, questsTurnedIn = st.questsTurnedIn,
                complete = st.statusLabel == WE:L("statusComplete"),
                visited = visited,
            })
        end
    end

    for _, sec in ipairs(sections) do
        sec.pct = sec.total > 0 and math.floor(sec.done / sec.total * 100 + 0.5) or 0
        table.sort(sec.rows, function(a, b)
            if (a.levelMin or 0) ~= (b.levelMin or 0) then return (a.levelMin or 0) < (b.levelMin or 0) end
            return a.name < b.name
        end)
    end
    table.sort(sections, function(a, b)
        local oa, ob = CONTINENT_ORDER[a.name] or 99, CONTINENT_ORDER[b.name] or 99
        if oa ~= ob then return oa < ob end
        return a.name < b.name
    end)

    for _, z in ipairs(WE.Tracker:GetExploredZonesList(accountScope)) do
        if not WE:GetZoneMeta(z.zoneKey) then
            model.visited = model.visited + 1
            table.insert(model.other, { key = z.zoneKey, name = z.zoneName, subCount = z.subCount, questCount = z.questCount })
        end
    end

    model.pct = model.areasTotal > 0 and math.floor(model.areasDone / model.areasTotal * 100 + 0.5) or 0
    return model
end

---------------------------------------------------------------------------
-- Map helper
---------------------------------------------------------------------------

function Journal:GetZoneMapID(zoneKey)
    local meta = WE:GetZoneMeta(zoneKey)
    if meta and meta.mapIDs and meta.mapIDs[1] then return meta.mapIDs[1] end
    local id = tonumber(zoneKey:match("^map:(%d+)$"))
    if id then return id end
    for cachedID, k in pairs(WorldExplorerDB.mapIDCache or {}) do
        if k == zoneKey then return cachedID end
    end
    return nil
end

function Journal:OpenOnMap(zoneKey)
    local mapID = self:GetZoneMapID(zoneKey)
    if not mapID or not WorldMapFrame then return end
    if not WorldMapFrame:IsShown() then
        if ShowUIPanel then ShowUIPanel(WorldMapFrame) else WorldMapFrame:Show() end
    end
    if WorldMapFrame.SetMapID then WorldMapFrame:SetMapID(mapID) end
end

---------------------------------------------------------------------------
-- Frame
---------------------------------------------------------------------------

local frame
local rowPool, usedRows = {}, {}

local function CreateRow(parent)
    local row = CreateFrame("Button", nil, parent)
    row:SetSize(ROW_W, 30)

    row.hl = row:CreateTexture(nil, "HIGHLIGHT")
    row.hl:SetAllPoints(true)
    row.hl:SetColorTexture(1, 1, 1, 0.06)

    row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.name:SetPoint("TOPLEFT", row, "TOPLEFT", 6, -3)
    row.name:SetWidth(200)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)

    row.sub = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    row.sub:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -1)
    row.sub:SetWidth(200)
    row.sub:SetJustifyH("LEFT")
    row.sub:SetWordWrap(false)

    row.bar = CreateFrame("StatusBar", nil, row)
    row.bar:SetSize(150, 12)
    row.bar:SetPoint("RIGHT", row, "RIGHT", -28, 0)
    row.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    row.bar:SetMinMaxValues(0, 100)
    local bg = row.bar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    row.bar.text = row.bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.bar.text:SetPoint("CENTER")

    row.check = row:CreateTexture(nil, "OVERLAY")
    row.check:SetSize(16, 16)
    row.check:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    row.check:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")

    row:SetScript("OnClick", function(self)
        if self.zoneKey then Journal:OpenOnMap(self.zoneKey) end
    end)
    row:SetScript("OnEnter", function(self)
        if not self.zoneKey then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(self.name:GetText() or "", 1, 0.82, 0)
        GameTooltip:AddLine(WE:L("journalZoneClick"), 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return row
end

local function AcquireRow(parent)
    local row = table.remove(rowPool) or CreateRow(parent)
    row:SetParent(parent)
    row:ClearAllPoints()
    row:Show()
    table.insert(usedRows, row)
    return row
end

local function ReleaseRows()
    for _, r in ipairs(usedRows) do
        r:Hide()
        r.zoneKey = nil
        table.insert(rowPool, r)
    end
    wipe(usedRows)
end

local function CreateJournalFrame()
    local f = CreateFrame("Frame", "WorldExplorerJournal", UIParent, "BackdropTemplate")
    f:SetSize(460, 540)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetClampedToScreen(true)
    if f.SetBackdrop then
        f:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 24,
            insets = { left = 6, right = 6, top = 6, bottom = 6 },
        })
    end
    table.insert(UISpecialFrames, "WorldExplorerJournal")

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.title:SetPoint("TOP", f, "TOP", 0, -16)

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)

    f.scopeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.scopeBtn:SetSize(170, 22)
    f.scopeBtn:SetPoint("TOPLEFT", f, "TOPLEFT", 18, -42)
    f.scopeBtn:SetScript("OnClick", function() WE.Options:Toggle("accountScope") end)

    f.hideCB = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
    f.hideCB:SetSize(24, 24)
    f.hideCB:SetPoint("LEFT", f.scopeBtn, "RIGHT", 12, 0)
    f.hideCB.label = f.hideCB:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.hideCB.label:SetPoint("LEFT", f.hideCB, "RIGHT", 2, 1)
    f.hideCB:SetScript("OnClick", function(self)
        WE.Options:Set("journalHideUnvisited", self:GetChecked() and true or false)
    end)

    f.summary = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.summary:SetPoint("TOPLEFT", f.scopeBtn, "BOTTOMLEFT", 0, -8)
    f.summary:SetPoint("RIGHT", f, "RIGHT", -18, 0)
    f.summary:SetJustifyH("LEFT")

    f.scroll = CreateFrame("ScrollFrame", "WorldExplorerJournalScroll", f, "UIPanelScrollFrameTemplate")
    f.scroll:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -94)
    f.scroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -34, 16)
    f.content = CreateFrame("Frame", nil, f.scroll)
    f.content:SetSize(ROW_W, 10)
    f.scroll:SetScrollChild(f.content)

    f:SetScript("OnShow", function() Journal:Refresh() end)
    f:Hide()
    return f
end

local function SetBar(bar, pct, text, r, g, b)
    bar:SetValue(pct)
    bar:SetStatusBarColor(r, g, b)
    bar.text:SetText(text)
end

function Journal:Refresh()
    if not frame or not frame:IsShown() then return end
    local accountScope = WorldExplorerCharDB.accountScope
    local model = self:BuildModel(accountScope, WorldExplorerCharDB.journalHideUnvisited)

    frame.title:SetText(WE:L("journalTitle"))
    frame.scopeBtn:SetText(accountScope and WE:L("scopeValAccount") or WE:L("scopeValChar"))
    frame.hideCB.label:SetText(WE:L("journalHideUnvisited"))
    frame.hideCB:SetChecked(WorldExplorerCharDB.journalHideUnvisited and true or false)
    frame.summary:SetText(string.format(WE:L("journalTotal"), model.areasDone, model.areasTotal, model.pct,
        model.secretsDone, model.secretsTotal, model.visited))

    ReleaseRows()
    local content, y = frame.content, 0

    local function Header(text, done, total, pct)
        local row = AcquireRow(content)
        row:SetHeight(26)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
        row.name:SetFontObject(GameFontNormal)
        row.name:SetText(text)
        row.sub:SetText("")
        row.check:Hide()
        if total then
            row.bar:Show()
            SetBar(row.bar, pct, string.format("%d/%d (%d%%)", done, total, pct), 0.95, 0.76, 0.18)
        else
            row.bar:Hide()
        end
        y = y + 28
    end

    for _, sec in ipairs(model.sections) do
        Header(sec.name, sec.done, sec.total, sec.pct)
        for _, z in ipairs(sec.rows) do
            local row = AcquireRow(content)
            row:SetHeight(30)
            row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
            row.zoneKey = z.key
            row.name:SetFontObject(GameFontHighlight)
            row.name:SetText((z.isNew and "|cff00e5ff[F]|r " or "") .. (z.visited and z.name or ("|cff888888" .. z.name .. "|r")))
            local parts = {}
            if z.levelMin then table.insert(parts, string.format(WE:L("journalLevels"), z.levelMin, z.levelMax or z.levelMin)) end
            if z.secretsTotal > 0 then table.insert(parts, string.format(WE:L("journalSecrets"), z.secretsDone, z.secretsTotal)) end
            if z.questsTotal then
                table.insert(parts, string.format(WE:L("journalQuestsOf"), z.questsDone, z.questsTotal))
            elseif z.questsTurnedIn > 0 then
                table.insert(parts, string.format(WE:L("journalQuests"), z.questsTurnedIn))
            end
            row.sub:SetText(table.concat(parts, " • "))
            row.bar:Show()
            SetBar(row.bar, z.pct, string.format("%d/%d", z.done, z.total), 0.25, 0.72, 0.95)
            if z.complete then row.check:Show() else row.check:Hide() end
            y = y + 32
        end
        y = y + 6
    end

    if #model.other > 0 then
        Header(WE:L("journalOther"))
        table.sort(model.other, function(a, b) return a.name < b.name end)
        for _, z in ipairs(model.other) do
            local row = AcquireRow(content)
            row:SetHeight(30)
            row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
            row.zoneKey = z.key
            row.name:SetFontObject(GameFontHighlight)
            row.name:SetText(z.name)
            local sub = string.format(WE:L("journalAreasOnly"), z.subCount)
            if z.questCount > 0 then sub = sub .. " • " .. string.format(WE:L("journalQuests"), z.questCount) end
            row.sub:SetText(sub)
            row.bar:Hide()
            row.check:Hide()
            y = y + 32
        end
    end

    if model.visited == 0 then
        local row = AcquireRow(content)
        row:SetHeight(30)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
        row.name:SetFontObject(GameFontDisable)
        row.name:SetText(WE:L("journalEmpty"))
        row.sub:SetText("")
        row.bar:Hide()
        row.check:Hide()
        y = y + 32
    end

    content:SetHeight(math.max(y, 10))
end

function Journal:Toggle(forceShow)
    if not frame then frame = CreateJournalFrame() end
    if frame:IsShown() and not forceShow then
        frame:Hide()
    else
        frame:Show()
        self:Refresh()
    end
end

function Journal:GetFrame() return frame end
function Journal:GetUsedRows() return usedRows end
