local addonName, WE = ...

--[[
Discovery toasts: a small banner at the top of the screen that fades in,
stays for a few seconds and fades out. Toasts are queued so several discoveries
in a row are shown one after another. Click a toast to dismiss it.

WE:Notify() is the single entry point used by the tracker: it prints the chat
message, plays the sound and shows the toast, each according to the options.
]]

WE.Toast = {}
local Toast = WE.Toast

local FADE_IN, HOLD, FADE_OUT = 0.25, 3.5, 0.8
local MAX_QUEUE = 6

local KIND_STYLE = {
    area   = { icon = "Interface\\Icons\\INV_Misc_Map_01",          r = 0.35, g = 0.75, b = 1.0 },
    secret = { icon = "Interface\\Icons\\INV_Misc_Gem_Amethyst_02",  r = 0.80, g = 0.45, b = 1.0 },
    zone   = { icon = "Interface\\Icons\\Ability_Hunter_Pathfinding", r = 1.0, g = 0.82, b = 0.2 },
}

local frame, queue, current, elapsed = nil, {}, nil, 0

local function CreateToastFrame()
    local f = CreateFrame("Button", "WorldExplorerToast", UIParent, "BackdropTemplate")
    f:SetSize(320, 58)
    f:SetPoint("TOP", UIParent, "TOP", 0, -140)
    f:SetFrameStrata("HIGH")
    f:SetClampedToScreen(true)
    if f.SetBackdrop then
        f:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 14,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        f:SetBackdropColor(0.05, 0.06, 0.09, 0.95)
    end

    f.icon = f:CreateTexture(nil, "ARTWORK")
    f.icon:SetSize(38, 38)
    f.icon:SetPoint("LEFT", f, "LEFT", 10, 0)

    f.header = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.header:SetPoint("TOPLEFT", f.icon, "TOPRIGHT", 10, -1)
    f.header:SetPoint("RIGHT", f, "RIGHT", -10, 0)
    f.header:SetJustifyH("LEFT")

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.title:SetPoint("TOPLEFT", f.header, "BOTTOMLEFT", 0, -2)
    f.title:SetPoint("RIGHT", f, "RIGHT", -10, 0)
    f.title:SetJustifyH("LEFT")
    f.title:SetWordWrap(false)

    f.sub = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    f.sub:SetPoint("TOPLEFT", f.title, "BOTTOMLEFT", 0, -2)
    f.sub:SetPoint("RIGHT", f, "RIGHT", -10, 0)
    f.sub:SetJustifyH("LEFT")
    f.sub:SetWordWrap(false)

    f:SetScript("OnClick", function() elapsed = math.max(elapsed, FADE_IN + HOLD) end)
    f:SetScript("OnUpdate", function(self, dt) Toast:OnUpdate(dt) end)
    f:SetAlpha(0)
    f:Hide()
    return f
end

local function Present(item)
    current, elapsed = item, 0
    local style = KIND_STYLE[item.kind] or KIND_STYLE.area
    frame.icon:SetTexture(style.icon)
    frame.header:SetText(item.header or "")
    frame.header:SetTextColor(style.r, style.g, style.b)
    frame.title:SetText(item.title or "")
    frame.sub:SetText(item.sub or "")
    frame:SetAlpha(0)
    frame:Show()
end

function Toast:OnUpdate(dt)
    if not current then return end
    elapsed = elapsed + dt
    local total = FADE_IN + HOLD + FADE_OUT
    if elapsed < FADE_IN then
        frame:SetAlpha(elapsed / FADE_IN)
    elseif elapsed < FADE_IN + HOLD then
        frame:SetAlpha(1)
    elseif elapsed < total then
        frame:SetAlpha(1 - (elapsed - FADE_IN - HOLD) / FADE_OUT)
    else
        current = nil
        frame:SetAlpha(0)
        frame:Hide()
        local nextItem = table.remove(queue, 1)
        if nextItem then Present(nextItem) end
    end
end

-- kind: "area" | "secret" | "zone"
function Toast:Show(kind, title, header, sub)
    if not frame then frame = CreateToastFrame() end
    local item = { kind = kind, title = title, header = header, sub = sub }
    if current then
        if #queue >= MAX_QUEUE then table.remove(queue, 1) end
        table.insert(queue, item)
    else
        Present(item)
    end
end

function Toast:IsBusy() return current ~= nil end
function Toast:QueueLength() return #queue end

local SOUNDS = {
    area = (SOUNDKIT and SOUNDKIT.UI_MAP_UNLOCK) or 888,
    secret = (SOUNDKIT and SOUNDKIT.UI_EPICLOOT_TOAST) or 888,
    zone = (SOUNDKIT and SOUNDKIT.ACHIEVEMENT_MENU_OPEN) or 888,
}

--[[
WE:Notify(kind, name, zoneName, done, total, chatText)
  name      — what was found (area / secret / zone name)
  zoneName  — zone the discovery belongs to
  done/total— zone progress after the discovery (optional)
  chatText  — preformatted chat line (optional)
]]
function WE:Notify(kind, name, zoneName, done, total, chatText)
    local opts = WorldExplorerCharDB or {}
    if opts.chatMessages ~= false and chatText then
        DEFAULT_CHAT_FRAME:AddMessage(chatText)
    end
    if opts.toastSound ~= false and PlaySound then
        pcall(PlaySound, SOUNDS[kind] or SOUNDS.area)
    end
    if opts.toasts ~= false then
        local header = WE:L(kind == "secret" and "toastSecret" or (kind == "zone" and "toastZone" or "toastArea"))
        local sub = zoneName
        if done and total and total > 0 then
            sub = string.format(WE:L("toastProgress"), zoneName or "", done, total)
        end
        Toast:Show(kind, name, header, sub)
    end
end
