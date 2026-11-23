local addonName, WE = ...

--[[
Import / export of custom pins as a single copy-pasteable line.

Format (version 1):
    !WEP1!<record>;<record>;...!<checksum>
    record   = zoneKey~x~y~name
    zoneKey  = canonical database zone key ("Elwynn Forest") or "map:<uiMapID>",
               so strings work across client languages
    x, y     = map coordinates 0-100, two decimals
    checksum = 4 hex digits (Adler-style, over the payload between the "!")
Fields are percent-encoded for "%", "~", ";", "!", "|" and control characters,
so the line survives chat/editboxes and can never inject UI escape codes.
]]

WE.PinShare = {}
local PinShare = WE.PinShare

local PREFIX = "!WEP"
local VERSION = 1
local MAX_IMPORT = 500

---------------------------------------------------------------------------
-- Encoding
---------------------------------------------------------------------------

local function Escape(str)
    return (str:gsub("[%%~;!|%c]", function(c) return string.format("%%%02X", c:byte()) end))
end

local function Unescape(str)
    return (str:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
end

local function Checksum(str)
    local a, b = 1, 0
    for i = 1, #str do
        a = (a + str:byte(i)) % 251
        b = (b + a) % 251
    end
    return string.format("%02X%02X", b, a)
end
PinShare._Checksum = Checksum

local function ValidZoneKey(key)
    return WE:GetZoneMeta(key) ~= nil or key:match("^map:%d+$") ~= nil
end

local SanitizeName = WE.SanitizePinName

---------------------------------------------------------------------------
-- Export / import
---------------------------------------------------------------------------

-- zoneKey nil -> all zones. Returns string (or nil if there is nothing), count.
function PinShare:Export(zoneKey)
    local zones = WorldExplorerDB.account.zones
    local keys = {}
    if zoneKey then
        if zones[zoneKey] then keys[1] = zoneKey end
    else
        for k in pairs(zones) do table.insert(keys, k) end
        table.sort(keys)
    end

    local records = {}
    for _, k in ipairs(keys) do
        for _, p in ipairs(zones[k].customPins or {}) do
            table.insert(records, table.concat({
                Escape(k), string.format("%.2f", p.x), string.format("%.2f", p.y), Escape(p.name),
            }, "~"))
        end
    end
    if #records == 0 then return nil, 0 end

    local payload = table.concat(records, ";")
    return PREFIX .. VERSION .. "!" .. payload .. "!" .. Checksum(payload), #records
end

-- Parses without touching saved data. Returns pins list or nil, errorText.
function PinShare:Decode(str)
    -- Only strip line breaks and outer whitespace: names may contain spaces.
    str = (str or ""):gsub("[\r\n]", ""):gsub("^%s+", ""):gsub("%s+$", "")
    local ver, payload, sum = str:match("^!WEP(%d+)!(.*)!(%x%x%x%x)$")
    if not ver then return nil, WE:L("errFormat") end
    if tonumber(ver) > VERSION then return nil, WE:L("errVersion") end
    if Checksum(payload) ~= sum:upper() then return nil, WE:L("errChecksum") end
    if payload == "" then return nil, WE:L("errEmpty") end

    local pins, invalid = {}, 0
    for record in payload:gmatch("[^;]+") do
        if #pins >= MAX_IMPORT then
            return nil, string.format(WE:L("errTooMany"), MAX_IMPORT)
        end
        local zk, xs, ys, nm = record:match("^([^~]+)~([^~]+)~([^~]+)~([^~]*)$")
        local x, y = tonumber(xs), tonumber(ys)
        zk = zk and Unescape(zk)
        nm = nm and SanitizeName(Unescape(nm))
        if zk and ValidZoneKey(zk) and x and y and x >= 0 and x <= 100 and y >= 0 and y <= 100 and nm and nm ~= "" then
            table.insert(pins, { zoneKey = zk, x = x, y = y, name = nm })
        else
            invalid = invalid + 1
        end
    end
    if #pins == 0 and invalid == 0 then return nil, WE:L("errEmpty") end
    return pins, nil, invalid
end

-- Returns added, duplicates, invalid (or nil, errorText).
function PinShare:Import(str)
    local pins, err, invalid = self:Decode(str)
    if not pins then return nil, err end
    local added, dupes = 0, 0
    for _, p in ipairs(pins) do
        if WE.Tracker:AddCustomPinTo(p.zoneKey, p.name, p.x, p.y) then
            added = added + 1
        else
            dupes = dupes + 1
        end
    end
    if WE.MapPins then WE.MapPins:Refresh() end
    if WE.Journal then WE.Journal:Refresh() end
    return added, dupes, invalid or 0
end

---------------------------------------------------------------------------
-- Dialog
---------------------------------------------------------------------------

local dialog

local function CreateDialog()
    local f = CreateFrame("Frame", "WorldExplorerPinShare", UIParent, "BackdropTemplate")
    f:SetSize(460, 300)
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
    table.insert(UISpecialFrames, "WorldExplorerPinShare")

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.title:SetPoint("TOP", f, "TOP", 0, -14)

    f.help = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.help:SetPoint("TOPLEFT", f, "TOPLEFT", 18, -36)
    f.help:SetPoint("RIGHT", f, "RIGHT", -18, 0)
    f.help:SetJustifyH("LEFT")

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)

    local scroll = CreateFrame("ScrollFrame", "WorldExplorerPinShareScroll", f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", f, "TOPLEFT", 18, -72)
    scroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -36, 50)

    local edit = CreateFrame("EditBox", nil, scroll)
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetFontObject(ChatFontNormal)
    edit:SetWidth(390)
    edit:SetMaxLetters(0)
    edit:SetScript("OnEscapePressed", function() f:Hide() end)
    scroll:SetScrollChild(edit)
    f.edit = edit

    local function Button(textKey, onClick, anchorPoint, rel, relPoint, x, y)
        local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        b:SetSize(130, 24)
        b:SetPoint(anchorPoint, rel, relPoint, x, y)
        b:SetScript("OnClick", onClick)
        b.textKey = textKey
        return b
    end

    f.btnZone = Button("btnExportZone", function() PinShare:FillExport(false) end, "BOTTOMLEFT", f, "BOTTOMLEFT", 18, 16)
    f.btnAll = Button("btnExportAll", function() PinShare:FillExport(true) end, "LEFT", f.btnZone, "RIGHT", 8, 0)
    f.btnImport = Button("btnImport", function() PinShare:ImportFromDialog() end, "LEFT", f.btnAll, "RIGHT", 8, 0)
    f:Hide()
    return f
end

function PinShare:FillExport(all)
    local zoneKey = nil
    if not all then
        local ctx = WE:GetCurrentZone()
        zoneKey = ctx and ctx.key
    end
    local str, n = self:Export(zoneKey)
    if not str then
        DEFAULT_CHAT_FRAME:AddMessage(WE:L("exportEmpty"))
        dialog.edit:SetText("")
        return
    end
    dialog.edit:SetText(str)
    dialog.edit:SetFocus()
    dialog.edit:HighlightText()
    DEFAULT_CHAT_FRAME:AddMessage(string.format(WE:L("exportDone"), n))
end

function PinShare:ImportFromDialog()
    local added, a2, a3 = self:Import(dialog.edit:GetText())
    if not added then
        DEFAULT_CHAT_FRAME:AddMessage(string.format(WE:L("importBad"), a2))
        return
    end
    DEFAULT_CHAT_FRAME:AddMessage(string.format(WE:L("importResult"), added, a2, a3))
    dialog.edit:SetText("")
end

function PinShare:ShowDialog()
    if not dialog then dialog = CreateDialog() end
    dialog.title:SetText(WE:L("shareTitle"))
    dialog.help:SetText(WE:L("shareHelp"))
    for _, b in ipairs({ dialog.btnZone, dialog.btnAll, dialog.btnImport }) do b:SetText(WE:L(b.textKey)) end
    dialog.edit:SetText("")
    dialog:Show()
    dialog.edit:SetFocus()
end

function PinShare:GetDialog() return dialog end
