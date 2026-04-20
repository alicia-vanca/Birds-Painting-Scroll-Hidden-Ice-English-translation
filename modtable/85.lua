local save_id, str_auto, img_show = "sw_beauti2", "Effect filters", "butter"
local default_data = {
    sw_snow = true, 
    snow_level = .1,
    leafcanopy = true, 
    light_rays = false, 
    oceanvine_deco = not m_util:IsHuxi(), 
    woodieover = not m_util:IsHuxi(), 
    terr_berry = not m_util:IsHuxi(),
    map_bg = false, 
    mapbtn_hide = false, 
    voidcloth_umb = true, 
    mist = true,        
    sw_bright = true, 
    bright_level = 130, 
}


local g_filts = require "data/gamefilter"
t_util:IPairs(g_filts, function(filt)
    default_data[filt.id] = filt.default
end)

local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)

local leafcanopy
local function LeafcanopyFn(show)
    local lc_hud = h_util:GetHUD().leafcanopy
    if not lc_hud then return end
    if show then
        if type(leafcanopy) == "function" then
            lc_hud.OnUpdate = leafcanopy
        end
        lc_hud:Show()
    else
        lc_hud.OnUpdate = i_util:GetNullFunction()
        lc_hud:Hide()
    end
end
AddClassPostConstruct("widgets/leafcanopy", function(self)
    if not save_data.leafcanopy then
        self:Hide()
    end
    leafcanopy = self.OnUpdate
end)
AddPrefabPostInit("lightrays_canopy", function(inst)
    if not save_data.light_rays then
        inst:Hide()
        inst.AnimState:SetBuild("oceantree_short")
        inst:CancelAllPendingTasks()
        if inst.components.distancefade then
            inst:RemoveComponent("distancefade")
        end
    end
end)
local function LightRaysFn(show)
    local light_rays = e_util:FindEnts(nil, "lightrays_canopy", nil, { "lightrays", "exposure" }, {})
    if show then
        t_util:Pairs(light_rays, function(_, light_ray)
            light_ray:Show()
        end)
    else
        t_util:Pairs(light_rays, function(_, inst)
            inst:Hide()
            inst:CancelAllPendingTasks()
            if inst.components.distancefade then
                inst:RemoveComponent("distancefade")
            end
        end)
    end
end
AddPrefabPostInit("oceanvine_deco", function(inst)
    if not save_data.oceanvine_deco then
        inst:Hide()
    end
end)
local function OceanvineDecoFn(show)
    local decos = e_util:FindEnts(nil, "oceanvine_deco", nil, { "flying" }, {})
    if show then
        t_util:Pairs(decos, function(_, deco) deco:Show() end)
    else
        t_util:Pairs(decos, function(_, deco) deco:Hide() end)
    end
end
local set_watertree = m_util:AddBindShowScreen{
    title = "About Water Tree",
    id = "sw_watertree",
    dontpop = true,
    help = "Check ✓ to enable and X to disable the effect.\nThe scroll filter will not change the canopy color. Recommended to enable Giant Tree Canopy for a nice look.",
    data = {
        {
            id = "leafcanopy",
            label = "Giant Tree Canopy",
            hover = "Cool sheen over water trees,\nflowing across the window.",
            default = fn_get,
            fn = function(show)
                fn_save("leafcanopy")(show)
                LeafcanopyFn(show)
            end,
        },{
            id = "light_rays",
            label = "Forest Light",
            hover = "Under the courtyard, the water is clear as if pooled,\nin the water, algae and lotus leaves crisscross,\ncovered by shadows of bamboo and cypress.",
            default = fn_get,
            fn = function(show)
                fn_save("light_rays")(show)
                LightRaysFn(show)
            end,
        },{
            id = "oceanvine_deco",
            label = "Vine Decoration",
            hover = "Wisteria hangs from cloud-like wood, flower vines suit the sunny spring.\nDense leaves hide singing birds, fragrant breeze leaves beauty behind.",
            default = fn_get,
            fn = function(show)
                fn_save("oceanvine_deco")(show)
                OceanvineDecoFn(show)
            end,
        },{
            id = "dynamictreeshadows",
            label = "Tree Shade",
            hover = "Dense summer shade from green trees,\nbuilding reflections in the pond.",
            default = function()
                return Profile:GetDynamicTreeShadowsEnabled()
            end,
            fn = function(value)
                Profile:SetDynamicTreeShadowsEnabled(value)
                EnableShadeRenderer(value)
            end
        }
    }
}

local function InitVoidclothUmbrella()
    if not ThePlayer then return end
    local function VisableUMB()
        local umb = h_util:GetHUD().raindomeover
        if umb and not save_data.voidcloth_umb then
            umb:StopUpdating()
            umb:Hide()
        end
    end
    ThePlayer:ListenForEvent("underraindomes", VisableUMB)
    ThePlayer:ListenForEvent("exitraindome", VisableUMB)
end
local function fn_umb(v)
    local umb = h_util:GetHUD().raindomeover
    if umb then
        if v then
            if umb.domes then
                umb:Show()
                umb:StartUpdating()
            end
        else
            umb:StopUpdating()
            umb:Hide()
        end
    end
end

local fn_set_bright = i_util:GetNullFunction()
local set_bright = m_util:AddBindShowScreen{
    title = "Screen Brightness Adjustment",
    id = "sw_bright",
    help = "Adjust screen brightness. Higher values make the screen brighter.\nRecommended setting: around 130%-150%.",
    dontpop = true,
    data = {
        {
            id = "sw_bright",
            label = "Brightness switch",
            hover = "Enable screen brightness modification effect",
            default = fn_get,
            fn = function(v)
                fn_save("sw_bright")(v)
                fn_set_bright()
            end,
        },{
            id = "bright_level",
            label = "Brightness:",
            hover = "Modify player's screen brightness",
            type = "radio",
            default = fn_get,
            data = t_util:BuildNumInsert(0, 500, 10, function(i)
                if i == 100 then
                    return {data = i, description = "No change"}
                end
                return {data = i, description = i.."%"}
            end),
            fn = function(v)
                fn_save("bright_level")(v)
                fn_set_bright()
            end,
        },
    }
}



local set_snow = m_util:AddBindShowScreen{
    title = "About Snow",
    id = "sw_snow",
    help = "I like leaving a thin layer of snow on the ground so it doesn't affect building while keeping the winter atmosphere.\nRecommended maximum snow depth: 10%",
    dontpop = true,
    data = {
        {
            id = "sw_snow",
            label = "Snow modify switch",
            hover = "Enable/disable modified snow effect",
            default = fn_get,
            fn = fn_save("sw_snow"),
        },{
            id = "snow_level",
            label = "Max snow:",
            hover = "Maximum snow depth level (0% = disable snow)",
            type = "radio",
            default = fn_get,
            data = t_util:BuildNumInsert(0, 100, 5, function(i)
                if i == 0 then
                    return {data = i*.01, description = "Remove all snow"}
                elseif i == 100 then
                    return {data = i*.01, description = "Keep all snow"}
                end
                return {data = i*.01, description = i.."%"}
            end),
            fn = fn_save("snow_level"),
        },
        
        
    }
}

i_util:AddWorldActivatedFunc(function(world)
    local mapfuncs = t_util:GetMetaIndex(world.Map)
    
    local _SetOverlayLerp = mapfuncs.SetOverlayLerp
    mapfuncs.SetOverlayLerp = function(map, level, ...)
        if save_data.sw_snow then
            local _level = save_data.snow_level * 3
            return _SetOverlayLerp(map, level > _level and _level or level, ...)
        end
        return _SetOverlayLerp(map, level, ...)
    end
    
    local Pcrs = t_util:GetMetaIndex(PostProcessor)
    local _SetColourModifier = Pcrs.SetColourModifier
    Pcrs.SetColourModifier = function(pcrs, level, ...)
        if save_data.sw_bright then
            return _SetColourModifier(pcrs, save_data.bright_level * .01, ...)
        end
        return _SetColourModifier(pcrs, level, ...)
    end
    fn_set_bright = function()
        _SetColourModifier(PostProcessor, save_data.sw_bright and save_data.bright_level * .01 or 1)
    end
    fn_set_bright()
end)

local function WoodieFn()
    h_util:VisibleUI(h_util:GetHUD().beaverOL, save_data.woodieover)
end

i_util:AddPlayerActivatedFunc(function(player, world)
    if not player:HasTag("werehuman") then
        return
    end
    player:ListenForEvent("weremodedirty", WoodieFn)
    WoodieFn()
end)


AddClassPostConstruct("widgets/mapwidget", function(self)
    if save_data.map_bg then
        self.bg:Hide()
    end
end)
local mapbtns = {"pauseBtn", "minimapBtn", "rotleft", "rotright"} 
local function HideMapBtn(screen)
    screen = screen or h_util:GetControls().mapcontrols
    if not screen then return end
    if save_data.mapbtn_hide then
        if screen.pauseBtn then
            t_util:IPairs(mapbtns, function(mapbtn)
                screen[mapbtn]:Hide()
            end)
        end
    else
        t_util:IPairs(mapbtns, function(mapbtn)
            screen[mapbtn]:Show()
        end)
    end
end


AddClassPostConstruct("widgets/mapcontrols", function(self)
    t_util:IPairs(mapbtns, function(mapbtn)
        local btn = self[mapbtn]
        if btn and btn.Show then
            local _Show = btn.Show
            btn.Show = function(...)
                if save_data.mapbtn_hide then
                    return
                end
                return _Show(...)
            end
        end
    end)
    HideMapBtn(self)
end)



local prefab_terr = "terrariumchest"
AddPrefabPostInit(prefab_terr, function(inst)
    inst:DoPeriodicTask(2, function()
        if e_util:FindEnt(inst, prefab_terr .. "_fx", 0.1, { "fx" }, {}) then
            e_util:FindEnts(inst, nil, 3, { "bush", "plant" }, { 'FX', 'DECOR', 'NOCLICK', 'player', 'INLIMBO' }, nil, nil, function(bush)
                if save_data.terr_berry then
                    bush:Show()
                else
                    bush:Hide()
                end
            end)
        end
    end)
end)

local fns = {}
local screen_add = t_util:IPairToIPair(g_filts, function(filt)
    local function fn(show)
        t_util:Pairs(filt.shelter, function(sls, info)
            h_util:VisibleUI(t_util:GetRecur(h_util:GetHUD(), sls), show, info)
        end)
    end
    local id = filt.id
    fns[id] = fn
    return {
        id = id,
        type = "dashimg",
        hover = filt.hover,
        default = fn_get,
        prefab = filt.prefab or "missing_asset",
        xml = filt.xml,
        tex = filt.tex,
        fn = function(v)
            fn_save(id)(v)
            fn(v)
        end,
        data = {
            [true] = {label = filt.label.." ON", color = "blue"},
            [false] = {label = filt.label.." OFF", color = "black"},
        }
    }
end)
AddClassPostConstruct("screens/playerhud", function(self)
    local _CreateOverlays = self.CreateOverlays
    self.CreateOverlays = function(self, ...)
        local result = _CreateOverlays(self, ...)
        t_util:Pairs(fns, function (id, fn)
            fn(save_data[id])
        end)
        LeafcanopyFn(save_data.leafcanopy)
        InitVoidclothUmbrella()
        return result
    end
end)


AddPrefabPostInit("mist", function(inst)
    if not save_data.mist then
        inst:DoTaskInTime(0.1, function()
            inst:Remove()
        end)
    end
end)



local screen_data = {
    {
        id = "set_snow",
        type = "imgstr",
        label = "About Snow",
        hover = "Modify snow settings",
        prefab = "icon_cold",
        fn = set_snow
    },
    {
        id = "set_bright",
        type = "imgstr",
        label = "Screen brightness",
        hover = "Modify the player's screen brightness",
        prefab = "mushroom_light2_victorian",
        fn = set_bright,
    },
    {
        id = "set_watertree",
        type = "imgstr",
        label = "About Water Tree",
        hover = "Modify Water Tree settings",
        prefab = "watertree_pillar",
        fn = set_watertree,
    },
}

local screen_last = {
    {
        id = "mist",
        type = "dashimg",
        hover = "Show mist above grave in merge area",
        prefab = "screen_mists",
        default = fn_get,
        fn = function(v)
            fn_save("mist")(v)
            h_util:CreatePopupWithClose("Grave mist notice", "This filter change requires restarting the game to take effect")
        end,
        data = {
            [true] = {label = "Show grave mist", color = "blue"},
            [false] = {label = "Hide grave mist", color = "black"},
        }
    },
    {
        id = "voidcloth_umb",
        type = "dashimg",
        hover = "Show opened shadow umbrella filter above ground",
        prefab = "voidcloth_umbrella",
        default = fn_get,
        fn = function(v)
            fn_save("voidcloth_umb")(v)
            fn_umb(v)
        end,
        data = {
            [true] = {label = "Show Shadow Umbrella", color = "blue"},
            [false] = {label = "Hide Shadow Umbrella", color = "black"},
        }
    },
    {
        id = "map_bg",
        type = "dashimg",
        hover = "Make map transparent",
        prefab = "mapscroll",
        default = fn_get,
        fn = fn_save("map_bg"),
        data = {
            [true] = {label = "Map transparent", color = "blue"},
            [false] = {label = "Map opaque", color = "black"},
        }
    },{
        id = "mapbtn_hide",
        type = "dashimg",
        hover = "Hide the map icon?",
        default = fn_get,
        xml = "images/hud.xml",
        tex = "map_button.tex",
        fn = function(v)
            fn_save("mapbtn_hide")(v)
            HideMapBtn()
        end,
        data = {
            [true] = {label = "Hide map icon", color = "blue"},
            [false] = {label = "Show map icon", color = "black"},
        }
    },{
        id = "woodieover",
        type = "dashimg",
        hover = "Show yellow depth after Woodie transformation?",
        prefab = "woodie",
        default = fn_get,
        fn = function(v)
            fn_save("woodieover")(v)
            WoodieFn()
        end,
        data = {
            [true] = {label = "Show yellow depth", color = "blue"},
            [false] = {label = "Hide yellow depth", color = "black"},
        }
    },{
        id = "terr_berry",
        type = "dashimg",
        hover = "Hide berry bushes near Terrarium chest?",
        prefab = "terrarium",
        default = fn_get,
        fn = fn_save("terr_berry"),
        data = {
            [true] = {label = "Show nearby bushes", color = "blue"},
            [false] = {label = "Hide nearby bushes", color = "black"},
        }
    },
}

local screen_pop = {
    title = "Effect Filters",
    id = save_id,
    data = t_util:MergeList(screen_data, screen_add, screen_last),
    icon = 
    {{
        id = "thanks",
        prefab = "abigail_flower_handmedown",
        hover = "Special thanks",
        fn = function()
            h_util:CreatePopupWithClose("󰀍 Special thanks 󰀍", 'Some filters were customized by supporter "宇神".', {{text = "󰀍"}})
        end,
    },{
        id = "bilibili",
        prefab = "bilibili",
        hover = "Tutorial demo",
        fn = function()VisitURL("https://www.bilibili.com/video/BV1aKCXB3EAJ", true)end,
    }}
}

m_util:AddBindIcon(str_auto, img_show, "Rewriting filters", true, m_util:AddBindShowScreen(screen_pop), nil, 9994.999)