local addonName, WE = ...

--[[
Settings panel. Uses the modern Settings API (Settings.RegisterCanvasLayoutCategory)
when the client has it, and falls back to InterfaceOptions_AddCategory otherwise.
All widgets read/write through WE.Options, so the panel, minimap button and slash
commands always agree.
]]

WE.Settings = {}
local SettingsPanel = WE.Settings

local PANEL_NAME = "World Explorer HUD"
local widgets = {}      -- every widget with a :Sync() method
local category = nil    -- Settings API category (modern clients)

local function Header(parent, textKey, anchor, yOff)
    local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fs:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff or -18)
    fs.textKey = textKey
    function fs:Sync() self:SetText(WE:L(self.textKey)) end
    table.insert(widgets, fs)
    return fs
end

local function Check(parent, optionKey, textKey, anchor, yOff)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetSize(26, 26)
    cb:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff or -4)
    local label = cb:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    label:SetPoint("LEFT", cb, "RIGHT", 4, 1)
    cb.label = label
    cb.optionKey, cb.textKey = optionKey, textKey
    cb:SetScript("OnClick", function(self)
        WE.Options:Set(self.optionKey, self:GetChecked() and true or false)
    end)
    function cb:Sync()
        self.label:SetText(WE:L(self.textKey))
        self:SetChecked(WE.Options:Get(self.optionKey) and true or false)
    end
    table.insert(widgets, cb)
    return cb
end

-- "Label: [ value ]" button that cycles through values on click.
local function Cycle(parent, textKey, anchor, getText, onClick, yOff)
    local label = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    label:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 4, yOff or -10)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetSize(170, 22)
    btn:SetPoint("LEFT", label, "LEFT", 190, 0)
    btn:SetScript("OnClick", onClick)
    btn.label = label
    function btn:Sync()
        self.label:SetText(WE:L(textKey))
        self:SetText(getText())
    end
    table.insert(widgets, btn)
    -- anchor for the next row = the label (shift back the 4px indent)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetSize(1, 22)
    holder:SetPoint("TOPLEFT", label, "TOPLEFT", -4, 4)
    return holder
end

local function Action(parent, textKey, onClick, width)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetSize(width or 170, 24)
    btn:SetScript("OnClick", onClick)
    function btn:Sync() self:SetText(WE:L(textKey)) end
    table.insert(widgets, btn)
    return btn
end

function SettingsPanel:Init()
    local panel = CreateFrame("Frame", "WorldExplorerSettingsPanel", UIParent)
    panel.name = PANEL_NAME
    panel:Hide()
    self.panel = panel

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -16)
    title:SetText(PANEL_NAME)

    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
    subtitle:SetJustifyH("LEFT")
    function subtitle:Sync() self:SetText(string.format(WE:L("settingsSubtitle"), WE.version)) end
    table.insert(widgets, subtitle)

    -- Display
    local h = Header(panel, "secDisplay", subtitle)
    local w = Check(panel, "showHUD", "optShowHUD", h)
    w = Check(panel, "locked", "optLocked", w)
    w = Check(panel, "showMapPins", "optMapPins", w)
    w = Check(panel, "showMinimapPins", "optMinimapPins", w)
    w = Check(panel, "minimapButton", "optMinimapButton", w)
    w = Check(panel, "showHints", "optHints", w)

    -- Tracking
    h = Header(panel, "secTracking", w)
    w = Check(panel, "accountScope", "optAccountScope", h)
    w = Cycle(panel, "optDistance", w,
        function() return WE:L("unit" .. (WorldExplorerCharDB.distanceUnit or "BOTH")) end,
        function() WE.Options:CycleDistanceUnit() end)
    w = Cycle(panel, "optLang", w,
        function() return (WE.Locale:GetLang() == "ukUA") and "Українська" or "English" end,
        function() WE.Options:Set("lang", (WE.Locale:GetLang() == "ukUA") and "enUS" or "ukUA") end)

    -- Notifications
    h = Header(panel, "secNotify", w, -22)
    w = Check(panel, "toasts", "optToasts", h)
    w = Check(panel, "toastSound", "optToastSound", w)
    w = Check(panel, "chatMessages", "optChat", w)

    -- Tools
    h = Header(panel, "secTools", w)
    local b1 = Action(panel, "btnJournal", function() if WE.Journal then WE.Journal:Toggle(true) end end)
    b1:SetPoint("TOPLEFT", h, "BOTTOMLEFT", 0, -8)
    local b2 = Action(panel, "btnPinShare", function() if WE.PinShare then WE.PinShare:ShowDialog() end end)
    b2:SetPoint("LEFT", b1, "RIGHT", 8, 0)
    local b3 = Action(panel, "btnResetHUD", function()
        WorldExplorerCharDB.pos = nil
        if WE.UI then WE.UI:ResetPosition() end
        DEFAULT_CHAT_FRAME:AddMessage(WE:L("hudPositionReset"))
    end)
    b3:SetPoint("TOPLEFT", b1, "BOTTOMLEFT", 0, -6)
    local b4 = Action(panel, "btnTestToast", function()
        if WE.Toast then WE.Toast:Show("area", "Goldshire", WE:L("toastArea"), string.format(WE:L("toastProgress"), "Elwynn Forest", 3, 6)) end
    end)
    b4:SetPoint("LEFT", b3, "RIGHT", 8, 0)

    panel:SetScript("OnShow", function() SettingsPanel:Refresh() end)

    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        category = Settings.RegisterCanvasLayoutCategory(panel, PANEL_NAME)
        Settings.RegisterAddOnCategory(category)
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    end
    self:Refresh()
end

function SettingsPanel:Refresh()
    for _, wdg in ipairs(widgets) do wdg:Sync() end
end

function SettingsPanel:Open()
    if category and Settings.OpenToCategory then
        Settings.OpenToCategory(category:GetID())
    elseif InterfaceOptionsFrame_OpenToCategory then
        -- Called twice: the first call may only open the frame on old clients.
        InterfaceOptionsFrame_OpenToCategory(self.panel)
        InterfaceOptionsFrame_OpenToCategory(self.panel)
    end
end
