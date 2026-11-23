-- luacheck configuration for World Explorer HUD (WoW Lua 5.1 environment)
std = "lua51"
max_line_length = false
codes = true

exclude_files = {
    "Libs/",      -- third-party libraries, linted upstream
    ".release/",  -- BigWigs packager output
}

ignore = {
    "212/self",   -- unused argument 'self' (methods)
    "212/_.*",    -- unused arguments prefixed with _
    "211/addonName", -- `local addonName, WE = ...` header in every file
    "432/self",   -- shadowing 'self' in nested script handlers (standard WoW style)
}

-- Globals this addon creates
globals = {
    "WorldExplorerDB",
    "WorldExplorerCharDB",
    "SLASH_WORLDEXPLORER1",
    "SLASH_WORLDEXPLORER2",
    "SlashCmdList",
    "UISpecialFrames",
}

-- WoW API / FrameXML used by the addon
read_globals = {
    "C_AddOns", "C_Map", "C_MapExplorationInfo", "C_QuestLog",
    "CreateFrame", "DEFAULT_CHAT_FRAME", "Enum", "GameTooltip", "UIParent", "Minimap",
    "WorldMapFrame", "ChatFontNormal", "GameFontNormal", "GameFontHighlight", "GameFontDisable",
    "GetAddOnMetadata", "GetCursorPosition", "GetLocale", "GetNumQuestLogEntries",
    "GetPlayerMapPosition", "GetQuestsCompleted", "GetRealZoneText", "GetRealmName",
    "GetSubZoneText", "IsQuestCompleted", "IsQuestFlagCompleted", "IsShiftKeyDown",
    "InterfaceOptions_AddCategory", "InterfaceOptionsFrame_OpenToCategory",
    "LibStub", "PlaySound", "SOUNDKIT", "Settings", "ShowUIPanel",
    "UnitClass", "UnitLevel", "UnitName", "UnitRace", "UNKNOWNOBJECT",
    "time", "wipe",
    string = { fields = { "trim" } },
}

files["tests/"] = {
    std = "lua51+busted",
    allow_defined_top = true,
    globals = { "_G" },
    ignore = { "111", "112", "113", "121", "122", "131", "142", "143", "211", "212", "213", "231", "311", "411", "421", "431", "432", "542", "631" },
}
