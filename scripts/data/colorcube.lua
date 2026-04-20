
-- Other mods can increase their filter style through require!
return {
    default = {
        label = "Original game",
        hover = "The default filter of the game. Automatically change at different seasons and time\nThis option requires a day to take effect!",
        priority = 100,
    },
    spring = {
        label = "Spring",
        hover = "Spring rain awakens spring\nWho could resist four seasons like spring?",
        cube = "images/colour_cubes/spring_day_cc.tex",
    },
    summer = {
        label = "Summer",
        hover = "Summer Begins, Grain Buds, Grain in Ear, Summer Solstice.\nHey buddy, you're not going to like this.",
        cube = "images/colour_cubes/summer_day_cc.tex",
    },
    autumn = {
        label = "Autumn",
        hover = "Autumn Dew\nthe filter for the fifth day of autumn",
        cube = "images/colour_cubes/day05_cc.tex",
    },
    winter = {
        label = "Winter",
        hover = "Winter snow, snow, winter\nWe see fireworks rising on the distant horizon, and the earth beneath our feet rumbles.",
        cube = "images/colour_cubes/snow_cc.tex",
    },
    bright = {
        label = "Brilliant",
        hover = "The filter is more vibrant, and the image quality seems to have improved!\nThis is the most recommended filter!",
        cube = "images/colour_cubes/identity_colourcube.tex",
        priority = 99,
    },
    full_moon = {
        label = "Full moon",
        hover = "Writing for fun",
        cube = "images/colour_cubes/purple_moon_cc.tex",
        priority = -1,
    },
    insane_day = {
        label = "Insane",
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
        hover = "Sanity value explosion",
        cube = "images/colour_cubes/insane_night_cc.tex",
        priority = -2,
    },
    lunacy = {
        label = "Enlightenment",
        hover = "Activate spirit vision...",
        cube = "images/colour_cubes/lunacy_regular_cc.tex",
        priority = -3,
    },
    moonstorm = {
        label = "Moon storm",
        hover = "It's quite like a famine or shipwreck.",
        cube = "images/colour_cubes/moonstorm_cc.tex",
        priority = -4,
    },
    cave = {
        label = "Cave",
        hover = "The dim filter in the cave",
        cube = "images/colour_cubes/caves_default.tex",
    },
    
}