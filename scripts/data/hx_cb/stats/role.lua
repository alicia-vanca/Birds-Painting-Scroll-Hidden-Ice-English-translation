local f_util = require "util/fn_hxcb"
local e_util = require "util/entutil"
local lmb, rmb = STRINGS.LMB, "\n"..STRINGS.RMB
local code_ghost = f_util:CodeGhost()
local code_beard = 'local b=_U_.components.beard if not b then return end if {bits}~=0 then b.daysgrowth={days} b.bits={bits} b:UpdateBeardInventory()b:SetSkin()else b:Reset()end'

local function fn_ex(a, ...)
    return f_util:FuncExRemote(code_ghost..a, ...)
end

local function Send40(prefab)
    local name = e_util:GetPrefabName(prefab)
    return{
        icon = prefab,
        hover = lmb.."1 "..name..rmb.."40 "..name,
        left = function()
            fn_ex(f_util:CodePrefab({prefab}), "Generate 1 "..name)()
        end,
        right = function()
            fn_ex(f_util:CodePrefab({[prefab] = 40}), "Generate 40 "..name)()
        end
    }
end
local function fn_wormwood(level)
    local meta = {level = level or 0}
    return {
        icon = "icon_badge_wormwood_lv"..level,
        hover = "Set bloom level to "..level,
        left = fn_ex('local h=_U_.components.bloomness if h then h:SetLevel({level})end', "Bloom Level: {level}", meta)
    }
end

local role_stats = {
    wilson = {
        {
            icon = "icon_badge_wilson_lv0",
            hover = "Remove Beard",
            left = fn_ex(code_beard, "Remove All Beard", {days=0, bits = 0}),
        },
        {
            icon = "icon_badge_wilson_lv1",
            hover = "Beard Level 1",
            left = fn_ex(code_beard, "Beard Level 1", {days=4, bits = TUNING.WILSON_BEARD_BITS.LEVEL1})
        },
        {
            icon = "icon_badge_wilson_lv2",
            hover = "Beard Level 2",
            left = fn_ex(code_beard, "Beard Level 2", {days=8, bits = TUNING.WILSON_BEARD_BITS.LEVEL2})
        },
        {
            icon = "icon_badge_wilson_lv3",
            hover = "Beard Level 3",
            left = fn_ex(code_beard, "Beard Level 3", {days=16, bits = TUNING.WILSON_BEARD_BITS.LEVEL3})
        },
    },
    willow = {
        Send40("willow_ember"),
        Send40("lighter"),
        Send40("bernie_inactive")
    },
    wolfgang = {
        {
            icon = "icon_badge_wolfgang_h0",
            hover = "Set Might to 0",
            left = fn_ex("local m=_U_.components.mightiness if m then m:SetPercent(0)end", "Might: 0")
        },
        {
            icon = "icon_badge_wolfgang_h2",
            hover = "Set Might to 50%",
            left = fn_ex("local m=_U_.components.mightiness if m then m:SetPercent(.5)end", "Might: 50%")
        },
        {
            icon = "icon_badge_wolfgang_h1",
            hover = "Set Might to 100%",
            left = fn_ex("local m=_U_.components.mightiness if m then m:SetPercent(1)end", "Might: 100%")
        },
    },
    wendy = {
        {
            icon = "icon_badge_wendy_h0",
            hover = "Set Abigail Health to 0",
            left = fn_ex("local m=_U_.components.pethealthbar local h=m and m.pet and m.pet.components.health if h then h:SetPercent(0)end", "Abigail Health: 0")
        },
        {
            icon = "icon_badge_wendy_h1",
            hover = "Set Abigail Health to 100%",
            left = fn_ex("local m=_U_.components.pethealthbar local h=m and m.pet and m.pet.components.health if h then h:SetPercent(1)end", "Abigail Health: 100%")
        },
        {
            icon = "icon_badge_wendy_lv1",
            hover = "Set Abigail Level to 1",
            left = fn_ex("local m=_U_.components.ghostlybond if m then m:SetBondLevel(1)end", "Abigail Level: 1")
        },
        {
            icon = "icon_badge_wendy_lv2",
            hover = "Set Abigail Level to 2",
            left = fn_ex("local m=_U_.components.ghostlybond if m then m:SetBondLevel(2)end", "Abigail Level: 2")
        },
        {
            icon = "icon_badge_wendy_lv3",
            hover = "Set Abigail Level to 3",
            left = fn_ex("local m=_U_.components.ghostlybond if m then m:SetBondLevel(3)end", "Abigail Level: 3")
        },
    },
    wx78 = {
        {
            icon = "icon_badge_wx78_lv0",
            hover = "Decrease Robot Charge",
            left = fn_ex("local m=_U_.components.upgrademoduleowner if m then m:AddCharge(-1)end", "Robot Charge: -1")
        },
        {
            icon = "icon_badge_wx78_lv1",
            hover = "Increase Robot Charge",
            left = fn_ex("local m=_U_.components.upgrademoduleowner if m then m:AddCharge(1)end", "Robot Charge: +1")
        },
    },
    wickerbottom = {
        Send40("papyrus")
    },
    woodie = {
        {
            icon = "icon_badge_woodie_lv0",
            hover = "Transform into Human!",
            left = fn_ex('local h=_U_.components.wereness if h then h:SetPercent(0)end', "Woodie transforms into Human")
        },
        {
            icon = "icon_badge_woodie_lv1",
            hover = "Transform into Goose!",
            left = fn_ex('local h=_U_.components.wereness if h then h:SetWereMode("goose")h:SetPercent(1)end', "Woodie transforms into Goose"),
        },
        {
            icon = "icon_badge_woodie_lv2",
            hover = "Transform into Moose!",
            left = fn_ex('local h=_U_.components.wereness if h then h:SetWereMode("moose")h:SetPercent(1)end', "Woodie transforms into Moose")
        },
        {
            icon = "icon_badge_woodie_lv3",
            hover = "Transform into Beaver!",
            left = fn_ex('local h=_U_.components.wereness if h then h:SetWereMode("beaver")h:SetPercent(1)end', "Woodie transforms into Beaver")
        },
        Send40("monstermeat"),
        Send40("log")
    },
    wes = {
        Send40("balloon"),
        Send40("balloonspeed"),
        Send40("balloonparty"),
    },
    waxwell = {
        Send40("nightmarefuel"),
    },
    wathgrithr = {
        {
            icon = "icon_badge_wathgrithr_lv0",
            hover = "Set Inspiration to 0",
            left = fn_ex('local h=_U_.components.singinginspiration if h then h:SetPercent(0)end', "Wigfrid Inspiration: 0")
        },
        {
            icon = "icon_badge_wathgrithr_lv1",
            hover = "Set Inspiration to 100%",
            left = fn_ex('local h=_U_.components.singinginspiration if h then h:SetPercent(1)end', "Wigfrid Inspiration: 100%")
        },
        Send40("wathgrithrhat"),
        Send40("spear_wathgrithr"),
    },
    webber = {
        {
            icon = "icon_badge_webber_lv0",
            hover = "Remove Beard",
            left = fn_ex(code_beard, "Remove All Beard", {days=0, bits = 0}),
        },
        
        {
            icon = "icon_badge_webber_lv1",
            hover = "Beard Level 1",
            left = fn_ex(code_beard, "Beard Level 1", {days=3, bits = 1}),
        },
        {
            icon = "icon_badge_webber_lv2",
            hover = "Beard Level 2",
            left = fn_ex(code_beard, "Beard Level 2", {days=6, bits = 3}),
        },
        {
            icon = "icon_badge_webber_lv3",
            hover = "Beard Level 3",
            left = fn_ex(code_beard, "Beard Level 3", {days=9, bits = 6}),
        },
        Send40("silk"),
        Send40("spidereggsack"),
        Send40("monstermeat"),
    },
    winona = {
        Send40("winona_catapult_item"),
        Send40("winona_spotlight_item"),
        Send40("winona_battery_high_item"),
        Send40("bluegem"),
        Send40("sewing_tape"),
        Send40("purebrilliance"),
        Send40("horrorfuel"),
    },
    warly = {
        Send40("portablecookpot_item"),
        Send40("voltgoatjelly"),
        Send40("glowberrymousse"),

        Send40("spice_sugar"),
        Send40("spice_salt"),
        Send40("spice_chili"),
        Send40("spice_garlic"),
    },
    wortox = {
        Send40("wortox_soul"),
        Send40("bee"),
        Send40("panflute"),
        Send40("wortox_souljar"),
        Send40("killerbee"),
        Send40("wortox_nabbag"),
    },
    wormwood = {
        fn_wormwood(0),
        fn_wormwood(1),
        fn_wormwood(2),
        fn_wormwood(3),
    },
    wurt = {
        {
            icon = "icon_badge_wurt_lv0",
            hover = "Wurt Form 1",
            left = f_util:FuncExRemote('if TheWorld then TheWorld:PushEvent("onmermkingdestroyed_anywhere")end', "You want to help the fish people"),
        },
        {
            icon = "icon_badge_wurt_lv1",
            hover = "Wurt Form 2",
            left = f_util:FuncExRemote('if TheWorld then TheWorld:PushEvent("onmermkingcreated_anywhere")end', "Make the fish people great again"),
        },
        Send40("merm"),
        Send40("mermguard"),
        Send40("mermking"),
    },
    walter = {
        {
            icon = "icon_badge_walter_lv0",
            hover = "Set Woby Hunger to 0",
            left = f_util:FuncExRemote('local h=_U_.woby and _U_.woby.components.hunger if h then h:SetPercent(0)end', "Woby Hunger: 0"),
        },
        {
            icon = "icon_badge_walter_lv1",
            hover = "Set Woby Hunger to 100%",
            left = f_util:FuncExRemote('local h=_U_.woby and _U_.woby.components.hunger if h then h:SetPercent(1)end', "Woby Hunger: 100%"),
        },
    },
    wanda = {
        {
            icon = "icon_badge_wanda_lv0",
            hover = "Young Form",
            left = f_util:FuncExRemote('local h = _U_.components.health if h then local p1,p2=h:GetPercent(),1 local meta={oldpercent=p1,newpercent=p2,overtime=true,cause="mod_huxi",amount=p2-p1>0}h:SetPercent(meta.newpercent)_U_:PushEvent("healthdelta",meta)h:ForceUpdateHUD(true)end', "Wanda: Young Form"),
        },
        {
            icon = "icon_badge_wanda_lv1",
            hover = "Middle-aged Form",
            left = f_util:FuncExRemote('local h = _U_.components.health if h then local p1,p2=h:GetPercent(),(TUNING.WANDA_AGE_THRESHOLD_YOUNG or .75)-.001 local meta={oldpercent=p1,newpercent=p2,overtime=true,cause="mod_huxi",amount=p2-p1>0}h:SetPercent(meta.newpercent)_U_:PushEvent("healthdelta",meta)h:ForceUpdateHUD(true)end', "Wanda: Middle-aged Form"),
        },
        {
            icon = "icon_badge_wanda_lv2",
            hover = "Old Form",
            left = f_util:FuncExRemote('local h = _U_.components.health if h then local p1,p2=h:GetPercent(),TUNING.WANDA_AGE_THRESHOLD_OLD or .25 local meta={oldpercent=p1,newpercent=p2,overtime=true,cause="mod_huxi",amount=p2-p1>0}h:SetPercent(meta.newpercent)_U_:PushEvent("healthdelta",meta)h:ForceUpdateHUD(true)end', "Wanda: Old Form"),
        },
        Send40("nightmarefuel"),
    }
}

return role_stats