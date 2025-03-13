
-- Other mods can increase their filter style through require!
return {
    default = {
        label = "Original game",
        hover = "This is the default filter of the game. automatically transform at different seasons and time \nthis this function requires a day to take a day to take effect!",
        priority = 100,
    },
    spring = {
        label = "Spring",
        hover = "Chunyu jingchun \n who can refuse the four seasons?",
        cube = "images/colour_cubes/spring_day_cc.tex",
    },
    summer = {
        label = "Summer",
        hover = "Xia manmangxia \n hey, brother, you will not like this",
        cube = "images/colour_cubes/summer_day_cc.tex",
    },
    autumn = {
        label = "Autumn",
        hover = "Autumn at luqiu \n filter on the fifth day of autumn",
        cube = "images/colour_cubes/day05_cc.tex",
    },
    winter = {
        label = "Winter",
        hover = "Winter xuexuedong \n we saw a fireworks rising from the distance, and the ground under his feet roared.",
        cube = "images/colour_cubes/snow_cc.tex",
    },
    bright = {
        label = "Brilliant",
        hover = "The more bright filter seems to have improved the picture quality!\n the most recommended filters!",
        cube = "images/colour_cubes/identity_colourcube.tex",
        priority = 99,
    },
    full_moon = {
        label = "Full moon",
        hover = "Write",
        cube = "images/colour_cubes/purple_moon_cc.tex",
        priority = -1,
    },
    insane_day = {
        label = "Collapse during the day",
        hover = "San value explosion",
        cube = "images/colour_cubes/insane_day_cc.tex",
        priority = -2
    },
    -- insane_dusk = {
    --     Label = 'broken dusk',
    --     Hover = 'san value explosion',
    --     cube = "images/colour_cubes/insane_dusk_cc.tex",
    --     priority = -2,
    -- },
    insane_night = {
        label = "Collapse night",
        hover = "San value explosion",
        cube = "images/colour_cubes/insane_night_cc.tex",
        priority = -2,
    },
    lunacy = {
        label = "Enlightenment",
        hover = "Open lingshi ...",
        cube = "images/colour_cubes/lunacy_regular_cc.tex",
        priority = -3,
    },
    moonstorm = {
        label = "Moon storm",
        hover = "It's quite difficult to be in famine",
        cube = "images/colour_cubes/moonstorm_cc.tex",
        priority = -4,
    },
    cave = {
        label = "Cave -related",
        hover = "Dark filter in the cave",
        cube = "images/colour_cubes/caves_default.tex",
    },
    
}