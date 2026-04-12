
local t_util = require "util/tableutil"
local h_util = require "util/hudutil"
local data = {
    default = "normal",
    cates = {{
        id = "all",
        icon = "filter_none",
        name = STRINGS.UI.COOKBOOK.FILTER_ALL,
        filter = function(data) return true end
    },{
        id = "normal",
        icon = "filter_cosmetic",
        name = "Common",
        filter = function(data) return data.inv or data.code:find("OCEAN_") or table.contains({"DIRT", "IMPASSABLE", "FARMING_SOIL", "VAULT", "RIFT_MOON"}, data.code) end
    },{
        id = "inv",
        icon = "station_turfcrafting",
        name = "Has Turf",
        filter = function(data) return data.inv end
    },{
        id = "sea",
        icon = "station_hermitcrab_shop",
        name = "Ocean",
        filter = function(data) return data.code:find("OCEAN_") or table.contains({"MONKEY_DOCK"}, data.code) end
    },{
        id = "quag",
        icon = "recipe_unknown",
        name = "Gluttony",
        filter = function(data) return data.code:find("QUAGMIRE_") end
    },{
        id = "lava",
        icon = "lavaarena_crowndamagerhat",
        name = "Lava\nThis tile category is not recommended! May crash!",
        filter = function(data) return data.code:find("LAVAARENA_") end
    },{
        id = "noise",
        icon = "station_cartography",
        name = "Noise",
        filter = function(data) return data.code:find("_NOISE") end
    },}, 
}

local data_mods = {}
local minimaps = require ("worldtiledefs").minimap
t_util:IPairs(minimaps or {}, function(set)
    local tile_id, minimap_tile_def = set[1], set[2]
    if minimap_tile_def then
        local noise_texture = minimap_tile_def.noise_texture
        local modpath = type(noise_texture) == "string" and string.match(noise_texture, "mods/([^/]+)")
        if modpath then
            if not data_mods[modpath] then
                data_mods[modpath] = {}
            end
            table.insert(data_mods[modpath], tile_id)
        end
    end
end)

t_util:Pairs(data_mods, function(modpath, tile_ids)
    local asset = h_util:GetModAsset(modpath)
    table.insert(data.cates, {
        id = modpath,
        name = asset.name,
        icon = function()
            if asset.xml and TheSim:AtlasContains(asset.xml, asset.tex) then
                return asset.xml, asset.tex
            else
                return h_util:GetPrefabAsset("filter_modded")
            end
        end,
        filter = function(data) return table.contains(tile_ids, data.id) end
    })
end)

table.insert(data.cates, {
    id = "isold",
    icon = "pitchfork",
    name = "Unofficial API",
    filter = function(data) return data.isold end
})

return data