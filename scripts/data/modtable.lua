-- Total configuration table
-- Note that the order of loading this table should not be modified at will, and move the whole body
-- If you need to add deletion, change the configuration, please follow this format
--[[
{
    "sw_shizhong",                                                                  -- The first parameter write the config name, the type is a string or table. this item does not have the mod below and will not capture the prompt
    {"Seasonal clock","Combined Staus", "Combination status", "Combined state column",},                         -- The second parameter writes the mod to be checked, the type is a string or table. the first parameter is the functional prompt. there will be prompts after the conflict.
    {1, 49},                                                                        -- The third parameter writes loaded mods. the type is string, number or table.
    "Hahaha .lua",                                                                    -- The fourth parameter (optional), the detailed location of the mod to be loaded, the mod here will give priority to the third parameter load
},
]] 
local m_table = {}

m_table.load = {
    {
        {"sw_cave"},
        {"Cave clock", "Cave Clock"},
        1,
    },
    {
        "sw_mainboard",
        "Function panel",
        2
    },{
        {"sw_beauti", },
        {"Filter", "Picture quality rendering","Color regulation"},
        3,
    },{
        {"sw_shutup", },
        {"Mute noise", "Noise", "noise"},
        4
    },
    {
        {"sw_unlock",},
        "Developer",
        5
    },
    {
        "sw_error",
        {"Log location", "Collapse","Wrong tracking"},
        6
    },
    {
        "sw_mapseed",
        {"Map seed"},
        7,
    },
    {
        {"sw_cookbook",},
        {"Culinary guide", "Cookbook",},
        8,
    },
    {
        {"sw_C"},
        {"Perspective change", "Ob perspective","Observer Camera",},
        9,
    },{
        "range_board",
        "Scope tracking",
        10,
    },{
        "ex_board",
        "Item manager",
        11
    },{
        {"sw_autosort", "ex_board"},
        {"Merging", "Automatic classification", "autosort"},
        16
    },{    
        -- Vanca: Preserve the [Night vision] function
        {"sw_nightsight",},
        "Smart night vision",
        12
    },
    {
        {"sw_autorow", },
        {"Automatic rowing", "lazy control", "rowing"},
        13,
    },
    {
        {"sw_toggle",},
        {"Switch delay compensation","Delay compensation","compensation"},
        14,
    },
    {
        "sw_multiscreen",
        "Wallpaper mode",
        15,
    },
    {
        {"sw_autoreel",},
        "Automatic fishing",
        17,
    },
    {
        {"sw_wagstaff",},
        "Storm mission",
        18,
    },
    {
        {"sw_wildfires",},
        {"Wildfire warning","Spontaneous warning"},
        19,
    },
    {
        {"sw_fishname",},
        {"Sea fishing assistant","Automatic sea fishing","Sea fishing master","Auto fishing","Names of fish", "Fish group display"},
        20,
    },
    {
        {"sw_shadowheart"},
        {"Statue production", "Last statue","Black -hearted factory"},
        21,
    },
    {
        {"sw_DAG"},
        {"Automatically do archive mission", "Archive task", "ArchiveTask","Archive","Archive"},
        {22,},
    },
    {
        {"sw_hideshell"},
        {"Hidden shell"},
        {23},
    },
    {
        {"sw_skinHistory"},
        {"Gift record","Turn on the skin in the bureau","Skins extender","Automatic gift","Hanging to open the skin","super AFK"},
        {
            24,
        },
    },
    {
        {"sw_skinQueue"},
        {"Duplicate skin decomposition","Duplicate skin", "SkinQueue"},
        25,
    },
    {
        {"sw_rescue"},
        {"One-click rescue"},
        26,
    },
    -- {
    --     {"sw_wendy"},
    --     {"Wendy assist", "Abigail Keybinds","Abigail shortcut keys"},
    --     27,
    -- },
    {
        {"sw_wanda"},
        {"Wanda shortcut keys", "wanda keybinds"},
        29,
    },
    {
        {"rt_take", "sw_right"},
        {"Recipe take", "Right click take", "Right click strengthen", "Memory"},
        30,
    },
	{
        {"sw_autoread"},
        {"Auto reading","Wickerbottom assist","Old grandma assist", "book reader"},
        31,
    },
    {
        "sw_roll",
        {"Precise pick up", "Quick access", "Quick pick up", "Item Scroller"},
        33,
    },
    {
        "sw_log",
        {"Changelog"},
        34,
    },
    -- {
    --     "sw_wath",
    --     {"Wigfrid assist","Valkyrie assist"},
    --     35,
    -- },
    -- {
    --     "sw_wax",
    --     {"Maxwell assist", "Old man assist", "Old man shortcut keys"},
    --     36,
    -- },
    {
        "sw_space",
        {"Space bar filter","Space bar filter", "pickup filter"},
        37,
    },
    {
        {"sw_mySeedTex"},
        {"Seed sticker restore", "Seed map", "Item icon", "High-definition icon"},
        38,
    },
    {
        "sw_planthant",
        {"Plowing illustration", "Pioneer","Gardening cap","Gardeneer Hat"},
        39,
    },
    {
        "sw_nutrients",
        {"Pioneer", "Gardening cap","Gardeneer Hat"},
        40,
    },
    {
        "sw_stat",
        {"State change", "Stat Change Display"},
        41,
    },
    {
        "sw_wall",
        {"Don't hit the wall", "No wall attack", "Hit the wall", "Advanced control", "Advanced Attack", "Advanced Controls"},
        42,
    },
    {
        "sw_tele",
        "Transmit",
        43,
    },
    {
        {},-- To enable this function, take the info tray as part of the basic library after the scroll
        {"Info tray"},
        44,
    },
    {
        "sw_folder",
        {"Mod directory","Show Mod Folder",},
        45,
    },
    {
        "sw_nickname",
        {"Nickname display", "nickname"},
        46,
    },
    {
        "sw_peopleNum",
        {"Increase the number of people", "Maximum number of people"},
        47,
    },
    {
        "sw_hidecrown",
        {"Bone helmet disable shadow monster", "Bone helmet: remove the shadow monster","Bone Helm","Bone helmet"},
        48,
    },
    {
        "sw_double",
        {"Double-click", "Double-click quickly", "Double-click to transfer", "Double-click to discard", "lazy control",},
        49,
    },
    {
        {"sw_castspell", "sw_right"},
        {"Accurate casting", "Cancellation of casting restrictions", "Right-click to enhance", "lazy control",},
        50,
    },
    {
        {"sw_cane"},
        {"Automatic cut cane", "Cut a cane"},
        51,
    },
    {
        {"sw_lantern",},
        {"Button to drop items"},
        52,
    },
    {
        "sw_craft",
        {"Crafting bar information","More Crafting Details"},
        27,
    },
    {
        {"sw_server",},
        {"Simulation heavy company", "Corporation"},
        55,
    },
    {
        {},-- To enable this function, the memory is used as part of the basic library after painting
        {"Memory+", "Memory"},
        53,
    },
    {
        "mid_search",
        {"Mid-key enhancement", "Memory"},
        56,
    },
    {
        "sw_autocook",
        {"Automatic cooking", "auto cooking","Crockpot Repeater", "Automatically cook","Memory"},
        57,
    },
    {
        {"huxi_buff","sw_timer"},
        {"Buff countdown", "Memory"},
        58,
    },
    {
        {"huxi_nightmare","sw_timer"},
        {"Nightmare phase", "Nightmare countdown", "Riot clock", "nightmare phase indicator"},
        59,
    },
    {
        {"huxi_rain", "sw_timer"},
        {"Rainfall", "Weather forecast", "Rain Predict"},
        60,
    },
    {
        {"huxi_boss","sw_timer"},
        {"Boss countdown", "Memory"},
        61,
    },
    {
        {"huxi_warn","sw_timer"},
        {"Monster warning", "Monster warning", "Advanced Warning"},
        62,
    },
    {
        {},-- Forced to enable this function, as the basic library of painting volume
        {"Map icon+",},
        63,
    },
    {
        {"map_animal","sw_map"},
        {"More creature icons", "Map icon",},
        64,
    },
    {
        {"huxi_clock","sw_timer"},
        {"Current time", "Real clock",},
        65,
    },
    {
        {"huxi_pos","sw_timer"},
        {"Current coordinates", "Reality coordinates",},
        66,
    },
    {
        {"map_wormhole", "sw_map"},
        {"Wormhole mark", "Map icon"},
        67,
    },
    {
        {"map_gogo", "sw_map"},
        {"Automatic way", "Map icon"},
        68,
    },
    {
        {"map_alter", "sw_map"},
        {"Positioning celestial body", "Map icon"},
        69,
    },
    {
        {"map_preview","sw_map"},
        {"Terrain preview", "Map scan", "Terrain scan"},
        32,
    },
    {
        {"sw_right"},
        {"Right-click to enhance"},
        70,
    },
    {
        {"rt_dirtpile", "sw_right", "sw_timer"},
        {"Automatically turn footprint", "Right-click to enhance", "lazy control", "Animal Tracker"},
        71,
    },
    {
        {"rt_double", "sw_right"},
        {"Double-click transmission"},
        72,
    },
    {
        {"sw_modplayer", "sw_right"},
        {"Mod character icon", "Character archive icon", "Show Character Portrait"},
        73,
    },
    {
        "sw_starfish",
        {"Ruin anenemy", "Moonnight's customized feature"},
        75,
    },
    {
        "sw_mynote",
        {"My notes", "呼吸's customized feature"},
        76,
    },
    -- {
    --     {"sw_tolock",},
    --     "Spawn",
    --     77
    -- },
    {
        {"sw_autopush",},
        {"Auto push", "Keep following", "Auto follow", "Follow like a shadow", "keep following",},
        78
    },
    {
        {"sw_winch",},
        {"Salvage positioning", "Ynou's customized feature",},
        79
    },
    {
        {"sw_indicator",},
        {"Directions", "虾远山's customized feature",},
        80
    },
    {
        {"sw_compass",},
        {"Compass", "猫头军师's customized feature",},
        81
    },
    {
        {"sw__keytweak"},
        {"Key prompts"},
        28,
    },
    {
        {"sw_suggest"},
        {"Gift pack purchase advice", "Look at the spool", "Cost-effectiveness"},
        54,
    },
    {
        {"sw_skinpreset"},
        {"Skin Preset Pack",},
        74,
    },
}

-- Conflict collection
m_table.ban = {"Cocktail-forever god", "Survival auxiliary", "Xiaobai client", "Super client", "Keeth client",
"Cheating device", "One -click client", "Pusheen", "Fraud", "Collection-client", "Mushroom mousse"}
-- Automatic shutdown function
m_table.close = {}
-- Conflicting function
m_table.clash = {}

return m_table
