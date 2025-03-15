GLOBAL.setmetatable(env, {
    __index = function(k, v)
        return GLOBAL.rawget(GLOBAL, v)
    end
})

_G.Mod_ShroomMilk = {
    PrefabCopy = {},
    Setting = {},
    Func = {
        -- All mods in the scroll series should call this function in modmain
        WriteToMod = function(mod_id, modname)
            Mod_ShroomMilk.Mod[mod_id] = {
                name = KnownModIndex:GetModInfo(modname).name,
                path = modname
            }
        end
    },
    Mod = {
        -- mod_id = {
        --     name = "Mod Name E All",
        --     path = "Mod relative path",
        -- }
    },
    Data = {} -- This interface allows external mods to customize the mousefs functionality, such as adding or modifying buttons
}
Mod_ShroomMilk.Func.WriteToMod("藏冰", modname)

c_util, e_util, h_util, i_util, m_util, p_util, t_util, s_mana, u_util, d_util = 
require "util/calcutil", -- Manage Calculations
require "util/entutil", -- Manage Entity States
require "util/hudutil", -- Manage UI and HUD
require "util/inpututil", -- Manage Remote Execution and Game Event Registration
require "util/modutil", -- Manage Mod Configurations, Including Function Panels
require "util/playerutil", -- Manage Player Actions and Items
require "util/tableutil",  -- Perform Operations on Tables, Various Iteration Methods
require "util/settingmanager", -- Manage Data Storage
require "util/userutil", -- Manage Player "Speech"
require "util/threadutil" -- Automation Tools

local function import_mod_name(m_name)
    modimport("modtable/" .. m_name .. ".lua")
end
local function iMod(m_name)
    if type(m_name) == "table" then
        t_util:IPairs(m_name, import_mod_name)
    else
        import_mod_name(m_name or {})
    end
end
iMod("start")
local mods = require "data/modtable"
assert(not t_util:IGetElement(mods.ban, function(modname)
    return m_util:HasModName(modname)
end), Mod_ShroomMilk.Mod["藏冰"].name .. "Can't enable with other collection mods at the same time")

iMod("preload")
t_util:IPairs(mods.load, function(moddata)
    local modconf, banlist, mod_name = unpack(moddata)
    if not m_util:IsTurnOn(modconf) then
        return
    end
    local modname_con = m_util:IsInBan(banlist)
    if modname_con then
        local deedname = type(banlist) == "table" and banlist[1] or banlist
        t_util:Add(mods.clash, modname_con) -- Conflict mod name
        t_util:Add(mods.close, deedname)    -- The function name of being turned off
    else
        iMod(mod_name)
    end
end)

if m_util:IsHuxi() then
    iMod({"modder", "test", 77, 35})
end


iMod({"thanks", "end"})
