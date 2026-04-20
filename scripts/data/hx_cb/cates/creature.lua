local g_util = require "util/fn_gallery"


local data = {
    default = "common",
    cates = {{
        id = "all",
        icon = "filter_none",
        name = STRINGS.UI.COOKBOOK.FILTER_ALL..g_util.str_seemore,
        prefabs = g_util.creature_all,
        
        fn_rr = g_util.SeeMore("Mod Support", 'This category is automatically organized based on scrapbook data.\nIf you want your mod to appear here, add it via this file:\nrequire("screens/redux/scrapbookdata")')
    }, {
        id = "common",
        icon = "filter_pigman",
        name = STRINGS.UI.RARITY.Common..g_util.str_seemore,
        prefabs = g_util.creature_common,
        fn_rr = g_util.SeeMore("Creatures", "Compared to the old T-key, creatures that can be placed in inventory are no longer in this category.\nFor fish and other small critters, see the 'Small Beasts' category to the right.")
    }, {
        id = "giants",
        icon = "filter_giants",
        name = STRINGS.SCRAPBOOK.CATS.GIANTS,
        prefabs = g_util.creature_giants,
    }, {
        id = "inv",
        icon = "robin",
        name = "Small Beasts"..g_util.str_seemore,
        prefabs = g_util.creature_inv,
        fn_rr = g_util.SeeMore("Small Beasts", "Creatures that can be placed in the inventory are all in this category, even including the Slurper.")
    }, {
        id = "player",
        icon = "filter_player",
        name = "Adventurers",
        prefabs = g_util.creature_player,
    },{
        id = "pet",
        icon = "critterlab",
        name = "Pets"..g_util.str_seemore,
        prefabs = g_util.creature_pet,
        fn_rr = g_util.SeeMore("Pets", "In later versions, spawned pets will automatically follow; this feature is not supported yet.")
    },{
        id = "shadow",
        icon = "shadowrift_portal",
        name = STRINGS.SCRAPBOOK.NOTE_SHADOW_ALIGNED..g_util.str_seemore,
        prefabs = g_util.creature_shadow,
        fn_rr = g_util.SeeMore(STRINGS.SCRAPBOOK.NOTE_SHADOW_ALIGNED, "This category is based on scrapbook data, so it may also include non-creatures like the boxing bag.\n(This category is not counted in the left 'All' category; authorize to see more creatures)."),
        hot = true,
    },{
        id = "lunar",
        icon = "lunarrift_portal",
        name = STRINGS.SCRAPBOOK.NOTE_LUNAR_ALIGNED..g_util.str_seemore,
        prefabs = g_util.creature_lunar,
        fn_rr = g_util.SeeMore(STRINGS.SCRAPBOOK.NOTE_LUNAR_ALIGNED, "This category is based on scrapbook data, so it may also include non-creatures like the boxing bag.\n(This category is not counted in the left 'All' category; authorize to see more creatures)."),
        hot = true,
    },{
        id = "normal",
        icon = "beefalo",
        name = "Neutral"..g_util.str_seemore,
        prefabs = g_util.creature_normal,
        fn_rr = g_util.SeeMore("Neutral", "A further filtered view of 'common', showing more familiar creatures.\nThis category may still include some faction creatures; authorization is required to filter those out."),
        hot = true,
    }}
}


return data