local c_util, e_util, h_util, m_util, t_util, p_util = 
require "util/calcutil",
require "util/entutil",
require "util/hudutil",
require "util/modutil",
require "util/tableutil",
require "util/playerutil"

return {
    {
        id = "all",
        name = STRINGS.UI.MODSSCREEN.ALL_FILTER,
        icon = "filter_none",
    },
    {
        id = "fav", 
        name = STRINGS.UI.CRAFTING_MENU.SORTING.FAVORITE,
        icon = "filter_favorites",
        hot = true, 
    },{
        id = "craft", 
        name = STRINGS.TABS.WAGPUNK_WORKSTATION,
        icon = "station_none",
    },{
        id = "creature",
        name = STRINGS.SCRAPBOOK.CATS.CREATURES,
        icon = "bunnyman",
    },{
        id = "food", 
        name = STRINGS.SCRAPBOOK.CATS.FOOD,
        icon = "vegstinger",
    },{
        id = "equip", 
        name = STRINGS.ACTIONS.EQUIP,
        icon = "winterhat",
        hot = true,
    },{
        id = "items", 
        name = STRINGS.SCRAPBOOK.CATS.ITEMS,
        icon = "goldnugget",
    },{
        id = "ground", 
        name = "Placement",
        icon = "tent",
    },{
        id = "mod",
        name = STRINGS.UI.MAINSCREEN.MODS,
        icon = "filter_modded",
    },{
        id = "poi",
        name = STRINGS.ACTIONS.TRAVEL,
        hot = true,
    },
    
    
    
    
}