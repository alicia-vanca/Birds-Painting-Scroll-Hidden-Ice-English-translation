local c_util, e_util, h_util, m_util, t_util, p_util = 
require "util/calcutil",
require "util/entutil",
require "util/hudutil",
require "util/modutil",
require "util/tableutil",
require "util/playerutil"
local l_wet = require "widgets/hx_cb/console/lines"
local isHuxi = m_util:IsHuxi()

return {{
    prefab = "common",
    name = "Common",
    icon = "filter_common",
    ui = function()
        return l_wet:PackLines(
            l_wet:world_season(),
            l_wet:world_phase(),
            l_wet:world_weather(),
            l_wet:cave_npc(),
            l_wet:ent_near(),
            l_wet:ent_all(),
            l_wet:server_common(),
            l_wet:player_single(),
            l_wet:player_speed(),
            l_wet:server_rollback()
        )
    end
}, {
    prefab = "world",
    name = "World/Server",
    icon = "filter_world",
    ui = function()
        return l_wet:PackLines(
            l_wet:world_season(),
            l_wet:world_phase(),
            l_wet:world_weather(),
            l_wet:cave_npc(),
            l_wet:world_star(),
            l_wet:server_common(),
            l_wet:server_speed(),
            l_wet:server_rollback(),
            l_wet:server_advance()
        )
    end
}, {
    prefab = "player",
    name = "Adventurers",
    icon = "filter_player",
    ui = function()
        return l_wet:PackLines(
            l_wet:player_single(),
            l_wet:player_all(),
            l_wet:player_unlock(),
            l_wet:player_speed(),
            l_wet:player_telepos(),
            l_wet:player_hunger()
        )
    end
}, {
    prefab = "entity",
    name = "Items or Creatures",
    icon = "filter_gardening",
    ui = function()
        return l_wet:PackLines(
            l_wet:ent_near(),
            l_wet:ent_plant(),
            l_wet:ent_beef(),
            l_wet:ent_all(),
            l_wet:ent_spawn()
        )
    end
},{
    prefab = "role",
    name = "Character Exclusive",
    icon = "station_celestial",
    ui = function()
        return l_wet:PackRoleStats()
    end
},{
    prefab = "modder1",
    name = isHuxi and "Debug Features" or "Reserved Features",
    icon = "yellowmooneye",
    ui = function()
        return isHuxi and
            l_wet:PackLines(
                l_wet:test_boss(),
                l_wet:test_treerock(),
                l_wet:test_beebox()
            ) or l_wet:test_show()
    end
}, {
    prefab = "modder2",
    name = "Reserved Features",
    icon = "station_science",
    ui = function()
        return l_wet:test_show()
    end
},}