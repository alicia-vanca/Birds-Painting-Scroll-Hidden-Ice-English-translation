local g_util = require "util/fn_gallery"
local t_util = require "util/tableutil"

local cates = {{
        id = "all",
        icon = "filter_none",
        name = STRINGS.UI.COOKBOOK.FILTER_ALL,
        prefabs = g_util.items_all,
    }, 
    {
        id = "material",
        icon = "twigs",
        name = "Materials"..g_util.str_seemore,
        prefabs = g_util.items_material,
        nosort = true,
        fn_rr = g_util.SeeMore("Material Sorting", "Materials are sorted by the total usage count across all recipes. With different mods enabled, the ordering may change."),
    },{
        id = "prop",
        icon = "terrarium",
        name = "Items"..g_util.str_seemore,
        prefabs = g_util.items_prop,
        fn_rr = g_util.SeeMore("Item Definitions", "Items can be placed in the inventory, cannot be crafted, and are not materials, equipment, food, decorations, plants, or tradable goods."),
        hot = true,
    },{
        id = "plant",
        icon = "dug_sapling",
        name = "Planting", 
        prefabs = g_util.items_plant,
    },
    
    
    
    
    
    
    {
        id = "trinket",
        icon = "trinket_4",
        name = t_util:GetRecur(STRINGS, "UI.TRADESCREEN.TRADE") or "Trade",
        prefabs = g_util.items_trinket,
    },{
        id = "ornament",
        icon = "winter_ornament_light1",
        name = STRINGS.ACTIONS.DECORATEVASE or "Decoration",
        prefabs = g_util.items_ornament,
    },{
        id = "turf",
        icon = "dock_kit",
        name = "Turf", 
        prefabs = g_util.items_turf,
    },{
        id = "wall",
        icon = "wall_stone_item",
        name = "Wall", 
        prefabs = g_util.items_wall,
    },{
        id = "seafaring",
        icon = "steeringwheel",
        name = "Seafaring",
        prefabs = g_util.items_seafaring,
    },{
        id = "eceanfishing",
        icon = "oceanfishinglure_hermit_heavy",
        name = "Ocean Fishing",
        prefabs = g_util.items_fishing,
    },
}



return {
    default = "material",
    cates = cates,
}