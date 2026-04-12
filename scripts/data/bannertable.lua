local UIAnim = require "widgets/uianim"
local t_util = require "util/tableutil"

local function ShiftUI(ui)
    ui:SetPosition(0.06*RESOLUTION_X, 0.07*RESOLUTION_Y)
end

return {
    {
        anim = "dst_menu_waterlogged",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_waterlogged")
            anim:GetAnimState():SetBank("dst_menu_waterlogged")
            anim:SetScale(.667)
            anim:GetAnimState():PlayAnimation("loop", true)
        end,
        desc = "2021/08/31 Waterlogged update"
    },
    {
        anim = {"dst_menu_moonstorm_background", "dst_menu_moonstorm_wrench", "dst_menu_moonstorm_wagstaff", "dst_menu_moonstorm_foreground"},
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_moonstorm_background")
            anim:GetAnimState():SetBank ("dst_menu_moonstorm_background")
            anim:GetAnimState():PlayAnimation("loop_w1", true)
            anim:SetScale(.667)

            banner_root.need_kill = {}

            local anim_wrench = banner_root:AddChild(UIAnim())
            anim_wrench:GetAnimState():SetBuild("dst_menu_moonstorm_wrench")
            anim_wrench:GetAnimState():SetBank ("dst_menu_moonstorm_wrench")
            anim_wrench:GetAnimState():PlayAnimation("loop_w1")
            anim_wrench:SetScale(.667)
            anim_wrench:GetAnimState():SetErosionParams(0.06, 0, -1.0)
            ShiftUI(anim_wrench)
            table.insert(banner_root.need_kill, anim_wrench)
            
            local anim_wagstaff = banner_root:AddChild(UIAnim())
            anim_wagstaff:GetAnimState():SetBuild("dst_menu_moonstorm_wagstaff")
            anim_wagstaff:GetAnimState():SetBank ("dst_menu_moonstorm_wagstaff")
            local _, str_anim = t_util:GetRandomItem({"loop_w1","loop_w2", "loop_w3", "loop_w1_console"})
            anim_wagstaff:GetAnimState():PlayAnimation(str_anim, true)
            anim_wagstaff:SetScale(.667)
            anim_wagstaff:GetAnimState():SetErosionParams(1, math.random(), -math.random()) 
            anim_wagstaff:GetAnimState():SetMultColour(1, 1, 1, 0.9)
            table.insert(banner_root.need_kill, anim_wagstaff)

            local anim_foreground = banner_root:AddChild(UIAnim())
            anim_foreground:GetAnimState():SetBuild("dst_menu_moonstorm_foreground")
            anim_foreground:GetAnimState():SetBank ("dst_menu_moonstorm_foreground")
            anim_foreground:GetAnimState():PlayAnimation("loop_w"..math.random(3), true)
            anim_foreground:SetScale(.667)
            ShiftUI(anim_foreground)
            table.insert(banner_root.need_kill, anim_foreground)
        end,
        desc = "2021/05/06 Old Gods Return series: 'Eye of the Storm'",
    },{
        anim = "dst_menu_yotd",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_yotd")
            anim:GetAnimState():SetBank ("dst_menu_yotd")
            anim:SetScale(.667)
            anim:GetAnimState():PlayAnimation("loop", true)
        end,
        desc = "2024/02/09 Year of the Dragonfly"
    },{
        anim = "dst_menu_yot_catcoon",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_yot_catcoon")
            anim:GetAnimState():SetBank ("dst_menu_yot_catcoon")
            anim:SetScale(.667)
            anim:GetAnimState():PlayAnimation("loop", true)
        end,
        desc = "2022/01/28 Year of the Catcoon is here!"
    },{
        anim = "dst_menu_yotr",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_yotr")
            anim:GetAnimState():SetBank ("dst_menu_yotr")
            anim:SetScale(.667)
            anim:GetAnimState():PlayAnimation("loop", true)
        end,
        desc = "2023/01/20 Year of the Bunnyman is here"
    },{
        anim = "dst_menu_halloween2",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_halloween2")
            anim:GetAnimState():SetBank ("dst_menu_halloween2")
            anim:SetScale(.667)
            anim:GetAnimState():PlayAnimation("loop", true)
        end,
        desc = "2021/10/22 Halloween Returns"
    },{
        anim = "dst_menu_carnival",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_carnival")
            anim:GetAnimState():SetBank ("dst_menu_carnival")
            anim:SetScale(.667)
            anim:GetAnimState():PlayAnimation("loop", true)
        end,
        desc = "2021/06/04 First 'Crawfest' · Midsummer Crow Celebration"
    },{
        anim = {"dst_menu_webber", "dst_menu_webber_carnival",},
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_webber_carnival")
            anim:GetAnimState():SetBank("dst_menu_webber")
            anim:SetScale(.667)
            anim:GetAnimState():PlayAnimation("loop", true)
        end,
        desc = "2021/06/25 Webber character update"
    },
    
    
    
    
    
    
    
    
    
    
    {
        anim = "dst_menu_wes2",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_wes2")
            anim:GetAnimState():SetBank ("dst_menu_wes2")
            anim:SetScale(.667)
            anim:GetAnimState():PlayAnimation("loop", true)
        end,
        desc = "2021/04/02 Fully authentic Wes character update"
    },{
        anim = "dst_menu_wanda",
        fn = function(self, banner_root, anim)
            local anim_bg = anim
            anim_bg:GetAnimState():SetBuild("dst_menu_wanda")
            anim_bg:GetAnimState():SetBank("dst_menu_wanda")
            anim_bg:SetScale(0.667)
            anim_bg:GetAnimState():PlayAnimation("loop_"..math.random(3), true)
            anim_bg:MoveToBack()
        end,
        desc = "2021/09/10 New adventurer: meet Wanda!"
    },{
        anim = "dst_menu_terraria",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_terraria")
            anim:GetAnimState():SetBank("dst_menu_terraria")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        desc = "2021/11/19 Eye for Eye · Terraria crossover",
    },{
        anim = "dst_menu_wolfgang",
        fn = function(self, banner_root, anim)
            local WOLFGANG_STATES = {"wimpy", "mid", "mighty"}
            anim:GetAnimState():SetBuild("dst_menu_wolfgang")
            anim:GetAnimState():SetBank("dst_menu_wolfgang")
            anim:GetAnimState():PlayAnimation("loop", true)
        
            local wolfgang_state_index = math.random(3)
            for i, state in ipairs(WOLFGANG_STATES) do
                if i == wolfgang_state_index then
                    anim:GetAnimState():Show(WOLFGANG_STATES[i])
                else
                    anim:GetAnimState():Hide(WOLFGANG_STATES[i])
                end
            end
            anim:SetScale(.667)
        end,
        desc = "2021/12/17 Wolfgang character rework",
    },{
        anim = "dst_menu_wx",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_wx")
            anim:GetAnimState():SetBank("dst_menu_wx")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        desc = "2022/04/29 WX-78 character rework",
    },{
        anim = "dst_menu_wickerbottom",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_wickerbottom")
            anim:GetAnimState():SetBank ("dst_menu_wickerbottom")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        desc = "2022/08/05 Wickerbottom character rework",
    },{
        anim = "dst_menu_pirates",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_pirates")
            anim:GetAnimState():SetBank("dst_menu_pirates")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        desc = "2022/07/01 Curse of the Moon Dock",
    },{
        anim = {"dst_menu_charlie2", "dst_menu_charlie"},
        fn = function(self, banner_root, anim)
            local anim_bg = banner_root:AddChild(UIAnim())
            anim_bg:GetAnimState():SetBuild("dst_menu_charlie2")
            anim_bg:GetAnimState():SetBank("dst_menu_charlie2")
            anim_bg:GetAnimState():PlayAnimation("loop_bg", true)
            anim_bg:SetScale(0.667)
            anim_bg:MoveToBack()
            banner_root.need_kill = {anim_bg}
            anim:GetAnimState():SetBuild("dst_menu_charlie")
            anim:GetAnimState():SetBank ("dst_menu_charlie")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(0.667)
        end,
        pos = {0, 0},
        desc = "2022/10/21 A Little Play · Quality of Life"
    },{
        anim = {"dst_menu_charlie2", "dst_menu_charlie_halloween"},
        fn = function(self, banner_root, anim)
            local anim_bg = banner_root:AddChild(UIAnim())
            anim_bg:GetAnimState():SetBuild("dst_menu_charlie2")
            anim_bg:GetAnimState():SetBank("dst_menu_charlie2")
            anim_bg:GetAnimState():PlayAnimation("loop_bg", true)
            anim_bg:SetScale(0.667)
            anim_bg:MoveToBack()
            banner_root.need_kill = {anim_bg}
            anim:GetAnimState():SetBuild("dst_menu_charlie_halloween")
            anim:GetAnimState():SetBank ("dst_menu_charlie_halloween")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(0.667)
        end,
        pos = {0, 0},
        desc = "2022/10/21 A Little Play · Halloween Event"
    },{
        anim = "dst_menu_waxwell",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_waxwell")
            anim:GetAnimState():SetBank("dst_menu_waxwell")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        desc = "2022/11/23 Maxwell character rework",
    },{
        anim = "dst_menu_wilson",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_wilson")
            anim:GetAnimState():SetBank("dst_menu_wilson")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        desc = "2023/03/17 Wilson character rework",
    },{
        anim = "dst_menu_lunarrifts",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_lunarrifts")
            anim:GetAnimState():SetBank("dst_menu_lunarrifts")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        desc = "2023/04/28 Rooted from Beyond",
    },{
        anim = "dst_menu_rift2",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_rift2")
            anim:GetAnimState():SetBank("dst_menu_rift2")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        desc = "2023/06/16 New Fear",
    },{
        anim = "dst_menu_meta2_cotl",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_meta2_cotl")
            anim:GetAnimState():SetBank("dst_menu_meta2")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        desc = "2023/08/22 Sheep Revelation crossover · Wormwood, Wolfgang, Woody skill hub"
    },{
        anim = {"dst_menu_rift3_BG", "dst_menu_rift3"},
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_rift3_BG")
            anim:GetAnimState():SetBank("dst_menu_rift3_BG")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
            anim:GetAnimState():Hide("HOLLOW")
        
            local anim_front = banner_root:AddChild(UIAnim())
            anim_front:GetAnimState():SetBuild("dst_menu_rift3")
            anim_front:GetAnimState():SetBank ("dst_menu_rift3")
            anim_front:GetAnimState():PlayAnimation("loop", true)
            anim_front:SetScale(.667)
            anim_front:GetAnimState():Hide("HOLLOW")
            banner_root.need_kill = {anim_front}
        end,
        desc = "2023/10/20 Fear Host",
    },{
        anim = "dst_menu_meta3",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_meta3")
            anim:GetAnimState():SetBank("dst_menu_meta3")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        desc = "2023/12/20 Wigfrid and Willow skill hub"
    },{
        anim = "dst_menu_riftsqol",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_riftsqol")
            anim:GetAnimState():SetBank("banner")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        desc = "2024/03/28 Scavenger Fighter"
    },{
        anim = {"dst_menu_rift3_BG", "dst_menu_rift3"},
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_rift3_BG")
            anim:GetAnimState():SetBank("dst_menu_rift3_BG")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        
            local anim_front = banner_root:AddChild(UIAnim())
            anim_front:GetAnimState():SetBuild("dst_menu_rift3")
            anim_front:GetAnimState():SetBank ("dst_menu_rift3")
            anim_front:GetAnimState():PlayAnimation("loop", true)
            anim_front:SetScale(.667)
            banner_root.need_kill = {anim_front}
        end,
        desc = "2023/10/27 Fear Host · Halloween Event", 
    },{
        anim = {"dst_menu_winona_wurt", "dst_menu_winona_wurt_carnival_foreground"},
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_winona_wurt")
            anim:GetAnimState():SetBank("dst_menu_winona_wurt")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        
            local anim_front = banner_root:AddChild(UIAnim())
            anim_front:GetAnimState():SetBuild("dst_menu_winona_wurt_carnival_foreground")
            anim_front:GetAnimState():SetBank ("dst_menu_winona_wurt")
            anim_front:GetAnimState():PlayAnimation("loop_foreground", true)
            anim_front:SetScale(.667)  
            banner_root.need_kill = {anim_front}
        end,
        desc = "2024/06/28 Stay Afloat"
    },{
        anim = {"dst_menu_rift4"},
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_rift4")
            anim:GetAnimState():SetBank("dst_menu_rift4")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        desc = "2024/09/13 Profound and Unfathomable"
    },{
        anim = {"dst_menu_halloween3"},
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_halloween3")
            anim:GetAnimState():SetBank("dst_menu_halloween3")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        desc = "2024/10/25 Halloween Returns"
    },{
        anim = {"dst_menu_v2_bg", "dst_menu_v2"},
        fn = function(self, banner_root, anim)
            local anim_bg = banner_root:AddChild(UIAnim())
            anim_bg:GetAnimState():SetBuild("dst_menu_v2_bg")
            anim_bg:GetAnimState():SetBank("dst_menu_v2_bg")
            anim:SetScale(.667)
            anim_bg:GetAnimState():PlayAnimation("loop", true)
            anim_bg:MoveToBack()
            banner_root.need_kill = {anim_bg}
        
            anim:GetAnimState():SetBuild("dst_menu_v2")
            anim:GetAnimState():SetBank("dst_menu_v2")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        
            local creatures =
            {
                "creature_cookie",
                "creature_squid",
                "creature_gnarwail",
                "creature_puffin",
                "creature_hound",
                "creature_malbatross",
            }
        
            for _,v in pairs(creatures) do
                anim:GetAnimState():Hide(v)
            end
        
            local c1 = creatures[math.random(1,#creatures)]
            local c2 = creatures[math.random(1,#creatures)]
            local c3 = creatures[math.random(1,#creatures)]
        
            
            anim:GetAnimState():Show(c1)
            anim:GetAnimState():Show(c2)
            anim:GetAnimState():Show(c3)
        end,
        pos = {-0.06, 0.18},
        desc = "Classic"
    },{
        anim = {"dst_menu_carrat_bg", "dst_menu_carrat", "dst_menu_carrat_swaps"},
        fn = function(self, banner_root, anim)
            local anim_bg = banner_root:AddChild(UIAnim())
            anim_bg:GetAnimState():SetBuild("dst_menu_carrat_bg")
            anim_bg:GetAnimState():SetBank("dst_carrat_bg")
            anim_bg:SetScale(0.7)
            anim_bg:GetAnimState():PlayAnimation("loop", true)
            anim_bg:MoveToBack()

            banner_root.need_kill = {anim_bg}

            anim:GetAnimState():SetBuild("dst_menu_carrat")
            anim:GetAnimState():SetBank("dst_carrat")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(0.6)

            local colors ={
                "blue",
                "brown",
                "pink",
                "purple",
                "yellow",
                "green",
                "white",
                nil, 
                }

            local color = colors[math.random(1,#colors)]

            if color then
                anim:GetAnimState():OverrideSymbol("ear1", "dst_menu_carrat_swaps", color.."_ear1")
                anim:GetAnimState():OverrideSymbol("ear2", "dst_menu_carrat_swaps", color.."_ear2")
                anim:GetAnimState():OverrideSymbol("tail", "dst_menu_carrat_swaps", color.."_tail")
            end
        end,
        pos = {0, 0.238},
        bg = true,
        desc = "2020/01/22 Year of the Carrot Rat Debut"
    },{
        anim = "dst_menu_wurt",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_wurt")
            anim:GetAnimState():SetBank("dst_menu_wurt")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        pos = {0, 0.18},
        bg = true,
    },{
        anim = "dst_menu_wormwood",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_wormwood")
            anim:GetAnimState():SetBank("dst_menu_wormwood")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        pos = {0, 0.18},
        bg = true,
    },{
        anim = "dst_menu_wortox",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_wortox")
            anim:GetAnimState():SetBank("dst_menu_wortox")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        pos = {0, 0.18},
        bg = true,
    },{
        anim = "dst_menu_woodie",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_woodie")
            anim:GetAnimState():SetBank("dst_menu_woodie")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        pos = {0, 0.18},
        bg = true,
    },{
        anim = "dst_menu_winona",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_winona")
            anim:GetAnimState():SetBank("dst_menu_winona")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        pos = {0.12, 0.1},
        bg = true,
    },{
        anim = "dst_menu_willow",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_willow")
            anim:GetAnimState():SetBank("dst_menu_willow")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        pos = {0, 0.18},
        bg = true,
    },{
        anim = "dst_menu_wathgrithr",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_wathgrithr")
            anim:GetAnimState():SetBank("dst_menu_wathgrithr")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        pos = {0, 0},
        bg = true,
    },{
        anim = "dst_menu_warly",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_warly")
            anim:GetAnimState():SetBank("dst_menu_warly")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        pos = {0, 0.18},
        bg = true,
    },{
        anim = "dst_menu_walter",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_walter")
            anim:GetAnimState():SetBank("dst_menu_walter")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        pos = {0, 0.18},
        bg = true,
    },{
        anim = "dst_menu_rot2",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_rot2")
            anim:GetAnimState():SetBank("dst_menu_rot2")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        pos = {0, 0.18},
        bg = true,
    },{
        anim = "dst_menu_shesells",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_shesells")
            anim:GetAnimState():SetBank("dst_menu_shesells")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        pos = {0, 0.18},
        bg = true,
    },{
        anim = "dst_menu_lunacy",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_lunacy")
            anim:GetAnimState():SetBank("dst_menu_lunacy")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        pos = {0, 0.18},
        bg = true,
    },{
        anim = "dst_menu_inker_winter",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_inker_winter")
            anim:GetAnimState():SetBank("dst_menu_inker_winter")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        pos = {0, 0.18},
        bg = true,
    },{
        anim = "dst_menu_inker",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_inker")
            anim:GetAnimState():SetBank("dst_menu_inker")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        pos = {0, 0.18},
        bg = true,
    },{
        anim = "dst_menu_dangerous_sea",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_dangerous_sea")
            anim:GetAnimState():SetBank("dst_menu_dangerous_sea")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        pos = {-.05, .15},
        bg = true,
    },{
        anim = "dst_menu_beefalo",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_beefalo")
            anim:GetAnimState():SetBank("dst_menu_beefalo")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        pos = {-.02, .18},
        bg = true,
    },{
        anim = "dst_menu_grotto",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_grotto")
            anim:GetAnimState():SetBank("dst_menu_grotto")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        pos = {-.1, 0.18},
        bg = true,
    },{
        anim = "dst_menu_farming_winter",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_farming_winter")
            anim:GetAnimState():SetBank("dst_menu_farming_winter")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        pos = {-.05, .15},
        bg = true,
    },{
        anim = "dst_menu_farming",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_farming")
            anim:GetAnimState():SetBank("dst_menu_farming")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        pos = {-.05, .15},
        bg = true,
    },{
        anim = "dst_menu_lavaarena_s2",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_lavaarena_s2")
            anim:GetAnimState():SetBank("dst_menu_lavaarena_s2")
            anim:GetAnimState():PlayAnimation("idle", true)
            anim:SetScale(.667)
        end,
        pos = {-.06, -.06},
        bg = true,
        desc = "Lava Arena S2"
    },{
        anim = "dst_menu_pigs",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_pigs")
            anim:GetAnimState():SetBank("dst_menu_pigs")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        pos = {0, 0.18},
        bg = true,
    },{
        anim = "dst_menu_moonstorm",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_moonstorm")
            anim:GetAnimState():SetBank("dst_menu_moonstorm")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        bg = true,
    },{
        anim = "dst_menu_yotv",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_yotv")
            anim:GetAnimState():SetBank("dst_menu")
            anim:SetScale(0.6)
            anim:GetAnimState():PlayAnimation("loop", true)
        end,
        pos = {0.08, 0.22},
        bg = true,
    },
    {
        anim = "dst_menu_wes",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_wes")
            anim:GetAnimState():SetBank("dst_menu_wes")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        bg = true,
        pos = {0, 0.15},
        desc = "2021/04/02 Fully authentic Wes character update"
    },{
        anim = "dst_menu_wendy",
        fn = function(self, banner_root, anim)
            anim:GetAnimState():SetBuild("dst_menu_wendy")
            anim:GetAnimState():SetBank("dst_menu_wendy")
            anim:GetAnimState():PlayAnimation("loop", true)
            anim:SetScale(.667)
        end,
        pos = {0, 0.2},
        bg = true,
        desc = "2020/03/20 Wendy character rework"
    },
}