local g_util = require "util/fn_gallery"
local cates = {
    {
        id = "all",
        icon = "filter_none",
        name = "All",
        prefabs = g_util.ground_all,
    },
    {
        id = "craftingstation",
        icon = "researchlab2",
        name = "Science Stations", 
        prefabs = g_util.ground_lab,
    },{
        id = "wall",
        icon = "wall_stone_item",
        name = "Walls", 
        prefabs = g_util.ground_wall,
    },
    {
        id = "structure",
        icon = "firepit",
        name = "Structures",
        prefabs = g_util.ground_structure,
    },
    {
        id = "atrium",
        icon = "atrium_key",
        name = "Ancient",
        prefabs = g_util.ground_atrium,
    },
    {
        id = "plants",
        icon = "carrot",
        name = "Plants",
        prefabs = g_util.ground_plants,
    },
    {
        id = "container",
        icon = "treasurechest",
        name = "Containers",
        prefabs = g_util.ground_container,
    },
}



return {
    default = "craftingstation",
    cates = cates,
}