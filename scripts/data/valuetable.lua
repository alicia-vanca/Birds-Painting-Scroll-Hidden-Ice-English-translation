local t_util = require "util/tableutil"
local V = {}

-- Standard colors
V.RGB = {

    ['Red'] = RGB(255, 0, 0),
    ['Orange'] = RGB(255, 125, 0),
    ['Yellow'] = RGB(255, 255, 0),
    ['Green'] = RGB(0, 255, 0),
    ['Cyan'] = RGB(0, 255, 255),
    ['Blue'] = RGB(0, 0, 255),
    ['Purple'] = RGB(255, 0, 255),
    ['Basalt'] = RGB(75, 75, 75),

    ["VioletBlue"] = RGB(100, 0, 255),
    ["Orange"] = RGB(255, 100, 0),
    ["Capri"] = RGB(0, 200, 255),
    ["NeonBlue"] = RGB(75, 75, 255),
    ["DarkSilver"] = RGB(175, 175, 175),
    -- pinks
    ["Pink"] = RGB(255, 192, 203),
    ["VioletRed"] = RGB(219, 112, 147),
    -- reds
    ["Salmon"] = RGB(250, 128, 114),
    ["Crimson"] = RGB(220, 20, 60),
    ["Firebrick"] = RGB(178, 34, 34),
    ["RedLustre"] = RGB(139, 0, 0),
    -- oranges
    ["Tomato"] = RGB(255, 99, 71),
    ["Coral"] = RGB(255, 127, 80),
    
    ["Khaki"] = RGB(240, 230, 140),
    
    ["Bisque"] = RGB(255, 228, 196),
    ["Burlywood"] = RGB(222, 184, 135),
    ["Tan"] = RGB(210, 180, 140),
    ["RosyBrown"] = RGB(188, 143, 143),
    ["SandyBrown"] = RGB(244, 164, 96),
    ["Goldenrod"] = RGB(218, 165, 32),
    ["Peru"] = RGB(205, 133, 63),
    ["Chocolate"] = RGB(210, 105, 30),
    ["SaddleBrown"] = RGB(139, 69, 19),
    ["Auburn"] = RGB(165, 42, 42),
    
    ["SpringGreen"] = RGB(0, 255, 127),
    
    ["Turquoise"] = RGB(64, 224, 208),
    ["Teal"] = RGB(0, 128, 128),
    
    ["LightSkyBlue"] = RGB(135, 206, 250),
    ["CornflowerBlue"] = RGB(100, 149, 237),
    
    ["Lavender"] = RGB(230, 230, 250),
    ["Thistle"] = RGB(216, 191, 216),
    ["Plum"] = RGB(221, 160, 221),
    ["MediumPurple"] = RGB(147, 112, 219),
    
    ["White"] = RGB(255, 255, 255),
    ["Original/Black"] = RGB(0, 0, 0),
    ['Black'] = {.1, .1, .1, 1},
    ["RedLustre"] = RGB(207, 61, 61),
    ["NeonGreen"] = RGB(59, 222, 99),
    ["MediumOrchid"] = RGB(184, 87, 198),
    ["ElegantBrown"] = RGB(127, 76, 51),
    ["Gray"] = RGB(128, 128, 128),
    ['WildSand'] = RGB(243, 244, 243),
}
V.RGB_datatable = t_util:PairToIPair(V.RGB, function(c)
    return {
        data = c,
        description = c
    }
end)
-- Adaptive to world colors
V.WRGB = {
    ["Blue"] = RGB(149, 191, 242),
    ["Yellow"] = RGB(222, 222, 99),
    ["Green"] = RGB(59, 222, 99),
    ["LightMaroon"] = RGB(216, 60, 84),
    ["GrassGreen"] = RGB(129, 168, 99),
    ["SeaGreen"] = RGB(150, 206, 169),
    ["Lilac"] = RGB(206, 145, 192),
    ["Capri"] = RGB(113, 125, 194),
    ["BrushedGold"] = RGB(205, 191, 121),
    ["Magenta"] = RGB(170, 85, 129),
    ["Turquoise"] = RGB(150, 201, 206),
    ["Orange"] = RGB(206, 150, 100),
    ["Copper"] = RGB(208, 120, 86),
    ["Purple"] = RGB(125, 81, 156),
    -- Colour theme to better match the world tones
    -- (So these colour names don't match standard web colours).
    ["Tomato"] = RGB(205, 79, 57),
    ["Hemp"] = RGB(255, 165, 79),
    ["Violet"] = RGB(205, 150, 205),
    ["NaturalOak"] = RGB(205, 170, 125),
    ["Red"] = RGB(238, 99, 99),
    ["Peru"] = RGB(205, 133, 63),
    ["FrenchLilac"] = RGB(139, 102, 139),
    ["Eggshell"] = RGB(252, 230, 201),
    ["Salmon"] = RGB(255, 140, 105),
    ["Chocolate"] = RGB(255, 127, 36),
    ["CannonPink"] = RGB(139, 71, 93),
    ["SandyBrown"] = RGB(244, 164, 96),
    ["Auburn"] = RGB(165, 42, 42),
    ["Bisque"] = RGB(205, 183, 158),
    ["VioletRed"] = RGB(255, 130, 171),
    ["Goldenrod"] = RGB(255, 193, 37),
    ["RosyBrown"] = RGB(255, 193, 193),
    ["LightLilac"] = RGB(255, 225, 255),
    ["Pink"] = RGB(255, 192, 203),
    ["Lemon"] = RGB(255, 250, 205),
    ["Firebrick"] = RGB(238, 44, 44),
    ["Goldenrod"] = RGB(255, 236, 139),
    ["VioletBlue"] = RGB(171, 130, 255),
    ["Thistle"] = RGB(205, 181, 205)
}

V.gifttype_table = {
    DAILY_GIFT = "Daily gift",
    DEFAULT = "Thank you for your enjoyment",
    TWITCH_DROP = "Live drop",
    YOTP = "Pig king's year",
    YOTB = "The year of pipfloo",
    LUNAR = "Year of turkey",
    VARG = "Wolf",
    ANRARG = "Ancient canes and boxes",
    ARG = "Ancient torch",
    CUPID = "Valentine's day",
    ONI = "Hypoxia",
    WINTER = "Winter feast",
    ROT2 = "Shellfish",
    TOT = "Change the tide",
    HAMLET = "Hamlet",
    HOTLAVA = "Hot lava",
    ROG = "Giant country play",
    ROGR = "Giant country to buy",
    SW = "Marine play",
    SWR = "Shipdium purchase",
    GORGE = "Overeating",
    GORGE_TOURNAMENT = "Blasting championship",
    STORE = "Shop purchase"
}

V.WRGB_datatable = t_util:PairToIPair(V.WRGB, function(c)
    return {
        data = c,
        description = c
    }
end)

V.frame_datatable = t_util:IPairFilter({1, 2, 3, 5, 10, 15, 20, 30, 45, 60, 75, 90}, function(i)
    return {
        data = i,
        description = i .. " frames"
    }
end)

V.range_datatable = t_util:BuildNumInsert(5, 80, 5, function(i)
    return {
        data = i,
        description = i
    }
end)

V.weekday_en_to_cn = {
    Sunday = "Sunday",
    Monday = "Monday",
    Tuesday = "Tuesday",
    Wednesday = "Wednesday",
    Thursday = "Thursday",
    Friday = "Friday",
    Saturday = "Saturday"
}

local Fonts = {DEFAULTFONT, DIALOGFONT, TITLEFONT, UIFONT, BUTTONFONT, NEWFONT, NEWFONT_SMALL, NEWFONT_OUTLINE,
               NEWFONT_OUTLINE_SMALL, NUMBERFONT, TALKINGFONT, TALKINGFONT_WORMWOOD, TALKINGFONT_TRADEIN,
               TALKINGFONT_HERMIT, CHATFONT, HEADERFONT, CHATFONT_OUTLINE, SMALLNUMBERFONT, BODYTEXTFONT, CODEFONT,
               FALLBACK_FONT, FALLBACK_FONT_FULL, FALLBACK_FONT_OUTLINE, FALLBACK_FONT_FULL_OUTLINE
            }
V.font_datatable = {}
t_util:IPairs(Fonts, function(font)
    if not table.contains(V.font_datatable, font) then
        table.insert(V.font_datatable, font)
    end
end)
V.font_datatable = t_util:IPairToIPair(V.font_datatable, function(font)
    return {data = font, description = font}
end)
return V
