-- Smoke test: loads the REAL embedded LibStub/CallbackHandler/HereBeDragons(-Pins)
-- against a minimal WoW API emulation and exercises the calls the addon makes.
local D = (arg[1] or ".") .. "/Libs/"
local function frame()
    local f = { scripts = {} }
    return setmetatable(f, { __index = function(_, k)
        if k == "SetScript" then return function(self, n, fn) self.scripts[n] = fn end end
        if k == "IsShown" or k == "IsVisible" then return function() return false end end
        return function() end
    end })
end
CreateFrame = function() return frame() end
WOW_PROJECT_CAMELOT, WOW_PROJECT_CLASSIC, WOW_PROJECT_ID = 99, 2, 99
Enum = { UIMapType = { Cosmic = 0, World = 1, Continent = 2, Zone = 3, Dungeon = 4, Micro = 5, Orphan = 6 } }
-- tiny map tree: World 947 > Eastern Kingdoms 1415 > Elwynn 1429 / Westfall 1436
local M = {
    [947]  = { mapID = 947,  name = "Azeroth", mapType = 1, parentMapID = 0 },
    [1415] = { mapID = 1415, name = "Eastern Kingdoms", mapType = 2, parentMapID = 947 },
    [1429] = { mapID = 1429, name = "Elwynn Forest", mapType = 3, parentMapID = 1415 },
    [1436] = { mapID = 1436, name = "Westfall", mapType = 3, parentMapID = 1415 },
}
-- world rects (instance 0): left, right, top, bottom in world yards
local R = { [1415] = { 4000, -4000, 2000, -10000 }, [1429] = { 1066, -2400, -7000, -10000 + 700 }, [1436] = { -1066, -2400, -9200, -10000 } }
local function vec(x, y) return { x = x, y = y, GetXY = function(s) return s.x, s.y end } end
CreateVector2D = vec
C_Map = {
    GetMapInfo = function(id) return M[id] end,
    GetMapChildrenInfo = function(id)
        local out = {}
        for _, m in pairs(M) do if m.parentMapID == id then table.insert(out, m) end end
        return out
    end,
    GetWorldPosFromMapPos = function(id, pos)
        local r = R[id] if not r then return nil end
        -- map x grows "left->right" = world y decreasing; map y grows "top->bottom" = world x decreasing
        local wy = r[1] + (r[2] - r[1]) * pos.x
        local wx = r[3] + (r[4] - r[3]) * pos.y
        return 0, vec(wx, wy)
    end,
    GetMapGroupID = function() return nil end,
    GetBestMapForUnit = function() return 1429 end,
    GetPlayerMapPosition = function() return vec(0.5, 0.5) end,
}
C_Minimap = nil
UnitPosition = function() return -8500, -300, 0, 0 end
GetPlayerFacing = function() return 0 end
GetCVar = function() return "0" end
Minimap = frame(); function Minimap:GetZoom() return 0 end
function Minimap:GetWidth() return 140 end
function Minimap:GetHeight() return 140 end
IsInInstance = function() return false end
IsLoggedIn = function() return true end
GetInstanceInfo = function() return "Eastern Kingdoms", "none", 0, "", 5, 0, false, 0 end
C_MapExplorationInfo = nil
wipe = function(t) for k in pairs(t) do t[k] = nil end return t end
geterrorhandler = function() return function(e) error(e, 2) end end
securecallfunction = function(f, ...) return f(...) end
-- MapCanvas mixins used by HBD-Pins
function CreateFromMixins(...) local t = {} for _, m in ipairs({ ... }) do for k, v in pairs(m) do t[k] = v end end return t end
MapCanvasDataProviderMixin = { GetMap = function(self) return self.map end }
MapCanvasPinMixin = {}
local acquired = {}
CreateFramePool = function() return {} end
WorldMapFrame = frame(); WorldMapFrame.pinPools = {}
function WorldMapFrame:AddDataProvider(p) p.map = self; self.provider = p end
function WorldMapFrame:GetMapID() return 1429 end
function WorldMapFrame:AcquirePin(_, icon, x, y) table.insert(acquired, { icon = icon, x = x, y = y }) end
function WorldMapFrame:EnumeratePinsByTemplate() return function() end end
function WorldMapFrame:RemovePin() end

for _, f in ipairs({ "LibStub/LibStub.lua", "CallbackHandler-1.0/CallbackHandler-1.0.lua",
                     "HereBeDragons/HereBeDragons-2.0.lua", "HereBeDragons/HereBeDragons-Pins-2.0.lua" }) do
    assert(loadfile(D .. f))()
end
local HBD = LibStub("HereBeDragons-2.0")
local pins = LibStub("HereBeDragons-Pins-2.0")
local ok = true
local function check(c, m) if not c then ok = false print("FAIL: " .. m) end end

check(HBD.mapData[1429] ~= nil, "HBD built map data for Elwynn (Forever project path)")
local d = HBD:GetZoneDistance(1429, 0.10, 0.10, 1429, 0.20, 0.10)
check(d and math.abs(d - 346.6) < 1, "zone distance uses real zone width: " .. tostring(d))
local icon = frame(); icon.SetPoint = function() end
check(pins:AddWorldMapIconMap("WE", icon, 1429, 0.42, 0.66, 0) == true, "AddWorldMapIconMap accepted")
check(#acquired == 1 and math.abs(acquired[1].x - 0.42) < 1e-6 and math.abs(acquired[1].y - 0.66) < 1e-6, "pin placed at zone coords on viewed map")
WorldMapFrame.GetMapID = function() return 1436 end
acquired = {}
WorldMapFrame.provider:RefreshAllData()
check(#acquired == 0, "Elwynn pin not drawn on Westfall map (showFlag 0)")
local mini = frame(); mini.SetPoint = function() end
check(pins:AddMinimapIconMap("WE", mini, 1429, 0.5, 0.5, false, true) == true, "AddMinimapIconMap accepted")
pins:RemoveMinimapIcon("WE", mini); pins:RemoveWorldMapIcon("WE", icon)
print(ok and "HBD smoke: OK" or "HBD smoke: FAILED")
os.exit(ok and 0 or 1)
