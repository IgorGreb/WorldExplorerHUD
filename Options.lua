local addonName, WE = ...

--[[
Single source of truth for user options. The settings panel, the minimap button
and the slash commands all go through Options:Set(), so side effects (refreshing
the HUD, pins, minimap button, panel widgets) live in one place.
]]

WE.Options = {}
local Options = WE.Options

-- Per-character options (WorldExplorerCharDB)
local CHAR_DEFAULTS = {
    showHUD = true,
    locked = false,
    showMapPins = true,
    showMinimapPins = true,
    showHints = true,
    accountScope = false,
    distanceUnit = "BOTH",
    toasts = true,
    toastSound = true,
    chatMessages = true,
    journalHideUnvisited = false,
}

-- Chat feedback for boolean toggles changed from a slash command: { onKey, offKey }
local TOGGLE_MESSAGES = {
    showMapPins = { "pinsShown", "pinsHidden" },
    showMinimapPins = { "minimapPinsShown", "minimapPinsHidden" },
    locked = { "lockEnabled", "lockDisabled" },
    showHints = { "hintsShown", "hintsHidden" },
    accountScope = { "scopeAccount", "scopeChar" },
}

Options.DISTANCE_UNITS = { "BOTH", "METERS", "FEET" }

function Options:InitDefaults()
    WorldExplorerCharDB = WorldExplorerCharDB or {}
    for k, v in pairs(CHAR_DEFAULTS) do
        if WorldExplorerCharDB[k] == nil then WorldExplorerCharDB[k] = v end
    end
    if WorldExplorerCharDB.lang == nil then
        local clientLocale = GetLocale and GetLocale() or "enUS"
        WorldExplorerCharDB.lang = (clientLocale == "ukUA") and "ukUA" or "enUS"
    end
    -- Account-wide minimap icon settings, same layout LibDBIcon expects.
    WorldExplorerDB.minimapIcon = WorldExplorerDB.minimapIcon or { hide = false, minimapPos = 220 }
end

function Options:Get(key)
    if key == "minimapButton" then
        return not WorldExplorerDB.minimapIcon.hide
    end
    return WorldExplorerCharDB[key]
end

-- Re-applies everything that depends on options. Cheap; called after each change.
function Options:ApplyAll()
    if not WE.ready then return end
    if WE.UI and WE.UI.frame then
        if WorldExplorerCharDB.showHUD then WE.UI.frame:Show() else WE.UI.frame:Hide() end
        WE.UI:Refresh()
    end
    if WE.MapPins then
        WE.MapPins:Refresh()
        WE.MapPins:UpdateCompass()
    end
    if WE.MinimapButton then WE.MinimapButton:Update() end
    if WE.Journal then WE.Journal:Refresh() end
    if WE.Settings then WE.Settings:Refresh() end
end

-- verbose = true prints the chat confirmation (used by slash commands).
function Options:Set(key, value, verbose)
    if key == "minimapButton" then
        WorldExplorerDB.minimapIcon.hide = not value
    elseif key == "lang" then
        WE.Locale:SetLang(value)
        if verbose then
            local label = (WE.Locale:GetLang() == "ukUA") and "Українська (ukUA)" or "English (enUS)"
            DEFAULT_CHAT_FRAME:AddMessage(string.format(WE:L("langChanged"), label))
        end
    else
        WorldExplorerCharDB[key] = value
        if verbose then
            local msgs = TOGGLE_MESSAGES[key]
            if msgs then
                DEFAULT_CHAT_FRAME:AddMessage(WE:L(value and msgs[1] or msgs[2]))
            elseif key == "distanceUnit" then
                DEFAULT_CHAT_FRAME:AddMessage(string.format(WE:L("unitModeChanged"), WE:L("unit" .. value)))
            end
        end
    end
    self:ApplyAll()
end

function Options:Toggle(key, verbose)
    self:Set(key, not self:Get(key), verbose)
end

function Options:CycleDistanceUnit(verbose)
    local cur = WorldExplorerCharDB.distanceUnit or "BOTH"
    local nextUnit = self.DISTANCE_UNITS[1]
    for i, u in ipairs(self.DISTANCE_UNITS) do
        if u == cur then
            nextUnit = self.DISTANCE_UNITS[i % #self.DISTANCE_UNITS + 1]
            break
        end
    end
    self:Set("distanceUnit", nextUnit, verbose)
end
