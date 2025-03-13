-- This interface is used for newbies who know a little bit of code
return {
    overlays = {
        label = "Screen halo",
        hover = "There is a circle of dark filter around the screen\nor is it called 'depth of field'?",
        shelter = {
            [{"vig"}] = {"vigpaint", "vig"},   
        },
    },
    sandover = {
        label = "Sandstorm or moon storm",
        hover = "Sandstorm filter\nMoon storm filter",
        shelter = {
            [{"sanddustover"}] = {"sand_texture2", "sand_over"},
            [{"moonstormdust"}] = true,
            [{"sandover", "bg"}] = {"gradient2", "sand_over"},
            [{"moonstormover","bg"}] = {"gradient2", "moonstorm_over"},
        },
    },
    pauseover = {
        label = "Pause black screen",
        hover = "This was originally the content of developer mode\nDo you want to display the black screen when paused?",
        shelter = {
            [{"serverpause_underlay"}] = true,
        }
    },
    -- helmover = {
    --     label = "Equipment filter",
    --     hover = "Goggles,\nGardeneer hat,\nW.A.R.B.I.S. head gear\nand other equipment depth of field",
    --     shelter = {
    --         [{"gogglesover","bg"}] = true,
    --         [{"nutrientsover","bg"}] = true,
    --         [{"Wagpunkui","overlay"}] = {"ui_parts", "wagpunk_over"},
    --     },
    -- },
    wagpunkui = {
        label = "W.A.R.B.I.S. head gear",
        hover = "W.A.R.B.I.S. head gear filter",
        shelter = {
            [{"Wagpunkui","overlay"}] = {"ui_parts", "wagpunk_over"},
        },
    },
    nutrientsover = {
        label = "Gardeneer hat",
        hover = "Gardeneer hat filter",
        shelter = {
            [{"nutrientsover","bg"}] = true,
        },
    },
    gogglesover = {
        label = "Goggles",
        hover = "Goggles filter",
        shelter = {
            [{"gogglesover","bg"}] = true,
        },
    },
    scrapmonocleover = {
        label = "Horizon expandinator",
        hover = "Horizon expandinator filter",
        shelter = {
            [{"scrapmonocleover"}] = {"ui_parts", "scrap_monocle_over"},
        },
    },
    inspectaclesover = {
        label = "Inspectacles",
        hover = "Inspectacles filter\n【Winona's Equipment】",
        shelter = {
            [{"inspectaclesover"}] = {"ui_parts", "inspectacles_over"},
        },
    },
    roseglasseshat = {
        label = "Rose-colored glasses",
        hover = "Rose-colored glasses filter\n【Winona's Equipment】",
        shelter = {
            [{"roseglassesover"}] = {"ui_parts", "roseglasseshat_over"},
        },
    },
    fruitover = {
        label = "Nightberry filter",
        hover = "Night vision filter after eating nightberry",
        shelter = {
            [{"nightvisionfruitover"}] = {"ui_parts1", "nightvision_fruit_over"},
            [{"nightvisionfruitover"}] = {"ui_parts2", "nightvision_fruit_over"},
            [{"nightvisionfruitover"}] = {"ui_parts_tint", "nightvision_fruit_over"},
        },
    },
    outline = {
        label = "Insane bloodshot",
        hover = "Whether to display bloodshot vision that indicates mental breakdown",
        shelter = {
            [{"vig"}] = {"vein01", "vig"},
            [{"vig"}] = {"vein02", "vig"},
            [{"vig"}] = {"vein03", "vig"},
            [{"vig"}] = {"vein04", "vig"},
        },
    },
    clouds = {
        label = "Cloud",
        hover = "The clouds when the vision is raised",
        shelter = {
            [{"clouds"}] = {"cloud", "clouds_ol"},
        },
    }
}