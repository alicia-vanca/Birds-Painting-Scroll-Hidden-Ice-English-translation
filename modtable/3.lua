if m_util:IsServer() then return end
local save_id = "gamefiler"
local save_data = s_mana:GetSettingLine(save_id, true)
local save__id = "colorfilter"
local save__data = s_mana:GetSettingLine(save__id, true)

-- Now: current filter style bright: brightness

local cube_default, bright_default, bright_start, bright_end = "bright", 1.3, 0.1, 4 -- Default filter style
local screen_data = {}

local function NullFunction() end
local function SaveFunction(meta)
    t_util:Pairs(meta, function (key, value)
        save_data[key] = value and true or nil
    end)
    s_mana:SaveSettingLine(save_id, save_data)
end

-----------------------snow--------------------
local value_insanity, -- Insanity
value_lunacy, -- Enlightenment
value_sob,  -- Superposition
value_bright,
mode_insanity, mode_lunacy = 0, 0, 0, 1, 1, 2

local dusk_data, day_data = {}, {}
AddComponentPostInit("ambientlighting", function (self, inst)
    local colors = t_util:GetRecur(c_util:GetFnEnv(self.GetVisualAmbientValue), "_overridecolour.currentcolourset.PHASE_COLOURS")
    if not colors then return print("Unable to change filter color! Please contact the mod author!") end

    t_util:Pairs(colors, function (cate, color)
        if not dusk_data[cate] then
            dusk_data[cate] = {}
            day_data[cate] = {}
        end
        local c_data = t_util:GetRecur(color, "dusk.colour")
        local d_data = t_util:GetRecur(color, "day.colour")
        if not c_data then return print("Unable to change filter color! Please contact the mod author!")end
        t_util:Pairs(c_data, function (k, v)
            dusk_data[cate][k] = v
        end)
        t_util:Pairs(d_data, function (k, v)
            day_data[cate][k] = v
        end)
    end)
end)


i_util:AddWorldActivatedFunc(function(world)
    local mapfuncs = getmetatable(world.Map).__index
    local _SetOverlayLerp = mapfuncs.SetOverlayLerp
    mapfuncs.SetOverlayLerp = function(map, level, ...)
        return _SetOverlayLerp(map, save_data.snowtile and level or 0, ...)
    end

    local pcrfuncs = getmetatable(PostProcessor).__index
    local _SetColourCubeLerp = pcrfuncs.SetColourCubeLerp
    pcrfuncs.SetColourCubeLerp = function(u_data, mode, value, ...)
        local v = save_data.sanity
        if mode == mode_insanity then
            value_insanity = value
            value = v and value or 0
        elseif mode == mode_lunacy then
            value_lunacy = value
            value = v and value or 0
        end

        return _SetColourCubeLerp(u_data, mode, value, ...)
    end

    local _SetOverlayBlend = pcrfuncs.SetOverlayBlend
    pcrfuncs.SetOverlayBlend = function (u_data, level, ...)
        value_sob = level
        return _SetOverlayBlend(u_data, save_data.sanity and level or 0, ...)
    end

    local function SanityFn(open)
        save_data.sanity = open
        _SetColourCubeLerp(PostProcessor, mode_insanity, open and value_insanity or 0)
        _SetColourCubeLerp(PostProcessor, mode_lunacy, open and value_lunacy or 0)
        _SetOverlayBlend(PostProcessor, open and value_sob or 0)
        PostProcessor:SetDistortionEnabled(open and true or false) -- I am really witty
    end
    SanityFn(save_data.sanity)

    table.insert(screen_data, 1, {
        id = "sanity",
        label = "Mental filter",
        fn = function (show)
            SanityFn(show)
            SaveFunction({sanity = show})
        end,
        hover = "Insanity/Enlightenment filter"
    })
    
    local cube_ori = type(save__data.now) == "nil" and false or save__data.now==cube_default

    local data_cc = {}
    local _SetColourCubeData = pcrfuncs.SetColourCubeData
    pcrfuncs.SetColourCubeData = function (u_data, mode, tex_old, tex_new, ...)
        data_cc[mode] = {
            tex_old = tex_old,          -- It doesn't seem to be useful, but it's all here
            tex_new = tex_new,
            meta = ...,
        }
        if cube_ori then
            return _SetColourCubeData(u_data, mode, tex_old, tex_new, ...)
        end
    end



    local data_cube = require "data/colorcube"

    local function ChangeCube(id)
        if id == "default" then
            cube_ori = true
            t_util:Pairs(data_cc, function(mode, data)
                _SetColourCubeData(PostProcessor, mode, data.tex_new, data.tex_new, data.meta)
            end)
        else
            id = id or cube_default
            cube_ori = false
            local cube = data_cube[id] and data_cube[id].cube
            if not cube then return end
            t_util:Pairs(data_cc, function(mode, data)
                _SetColourCubeData(PostProcessor, mode, cube, cube, data.meta)
            end)
            for i = 0,2 do
                _SetColourCubeData(PostProcessor, i, cube, cube)
            end
        end
    end
    ChangeCube(save__data.now)

    local function setbtns(btns, id, bool)
        local btn = btns[id]
        if btn then
            btn.uiSwitch(bool)
        end
    end

    local function fn_cube(btns, id)
        t_util:Pairs(data_cube, function (id)
            setbtns(btns, id, false)
        end)
        setbtns(btns, id, true)
        -- Filter modification
        ChangeCube(id)
        -- Storage
        s_mana:SaveSettingLine(save__id, save__data, {now = id})
    end

    
    local _SetColourModifier = pcrfuncs.SetColourModifier
    pcrfuncs.SetColourModifier = function (u_data, value, ...)
        value_bright = value
        if save__data.bright==1 then
            return _SetColourModifier(u_data, value, ...)
        end
    end


    local function ChangeBright(i)
        i = type(i)=="nil" and bright_default or i
        _SetColourModifier(PostProcessor, i==1 and value_bright or i)
    end
    ChangeBright(save__data.bright)
    local function ChangeDusk(state)
        local fn = t_util:GetRecur(world, "components.ambientlighting.GetVisualAmbientValue")
        if not fn then return end
        local colors = t_util:GetRecur(c_util:GetFnEnv(fn), "_overridecolour.currentcolourset.PHASE_COLOURS")
        if not colors then return end
        t_util:Pairs(colors, function (cate, color)
            -- cate:default/spring
            local lt = state and day_data[cate] or dusk_data[cate]
            if not lt then return end
            t_util:Pairs(lt, function (k, v)
                color.dusk.colour[k] = v
            end)
        end)
    end
    if type(save__data.dusk)=="nil" or save__data.dusk then
        ChangeDusk(true)
    end
    local function fn_bright(i)
        ChangeBright(i)
        s_mana:SaveSettingLine(save__id, save__data, {bright = i})
    end

    local function fn_dusk(state)
        ChangeDusk(state)
        s_mana:SaveSettingLine(save__id, save__data, {dusk = state})
    end

    local function GetFilterData()
        local filter_data = t_util:PairToIPair(data_cube, function(id, data)
            return {
                id = id,
                label = data.label.."Filter",
                fn = function(_, btns)
                    fn_cube(btns, id)
                end,
                hover = data.hover,
                default = id==cube_default and type(save__data.now)=="nil" or save__data.now==id,
                priority = data.priority or 0,
                notload = true,
            }
        end)
        local radiodata = {}
        for i = bright_start, bright_end,0.1 do
            table.insert(radiodata, {
                description = string.format("%d%%", i*100),
                data = i
            })
        end
        table.insert(filter_data, {
            id = "bright",
            label = "Brightness:",
            type = "radio",
            data = radiodata,
            default = function ()
                return type(save__data.bright)=="nil" and bright_default or save__data.bright
            end,
            hover = "The game defaults to 100%\nThis mod defaults to 130%",
            priority = 200,
            fn = fn_bright,
        })
        table.insert(filter_data, {
            id = "dusk",
            label = "Dusk",
            hover = "[Note: This feature will only take effect when you enter the next stage]\nEnabling this will change the dusk brightness to daytime brightness",
            default = function ()
                return type(save__data.dusk) == "nil" and true or save__data.dusk
            end,
            priority = 199,
            fn = fn_dusk,
        })
        t_util:SortIPair(filter_data)
        return filter_data    
    end
    
    local function filter_fn()
        m_util:PopShowScreen()
        TheFrontEnd:PushScreen(require("screens/huxi/showscreen")({
            title = "Screen rendering",
            id = "filter",
            data = GetFilterData(),
        }))
    end
    table.insert(screen_data, 1, {
        id = "filter",      -- This id is useless
        label = "Four seasons filters",
        fn = filter_fn,
        hover = "Choose any filter style!",
        default = true,
    })
end)


table.insert(screen_data,
    {
        id = "snowtile",
        label = "Snow ground",
        fn = function(show)
            SaveFunction({snowtile = show})
        end,
        hover = "Do you want to display the snow on the ground?"
    })
--------------------Waterlogged-------------------------
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
        lc_hud.OnUpdate = NullFunction
        lc_hud:Hide()
    end
end

AddClassPostConstruct("widgets/leafcanopy", function(self)
    if not save_data.leafcanopy then
        self:Hide()
    end
    leafcanopy = self.OnUpdate
end)

table.insert(screen_data, {
    id = "leafcanopy",
    label = "Waterlogged - Giant tree canopy",
    fn = function (show)
        LeafcanopyFn(show)
        SaveFunction({leafcanopy = show})
    end,
    hover = "The clear light shines through the water and trees,\nripples through the windows."
})

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
        save_data.light_rays = true
        t_util:Pairs(light_rays, function(_, light_ray)
            light_ray:Show()
        end)
    else
        save_data.light_rays = false
        t_util:Pairs(light_rays, function(_, inst)
            inst:Hide()
            inst:CancelAllPendingTasks()
            if inst.components.distancefade then
                inst:RemoveComponent("distancefade")
            end
        end)
    end
end
table.insert(screen_data, {
    id = "light_rays",
    label = "Waterlogged - Light rays",
    fn = function (show)
        LightRaysFn(show)
        SaveFunction({light_rays = show})
    end,
    hover = "The courtyard is as clear as accumulated water,\nwith algae and water plants intertwined in the water,\nreflecting the shadows of bamboo and cypress."
})

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

table.insert(screen_data, {
    id = "oceanvine_deco",
    label = "Waterlogged - Vine decoration",
    fn = function (show)
        OceanvineDecoFn(show)
        SaveFunction({oceanvine_deco = show})
    end,
    hover = "Wisteria hangs on the cloud-reaching trees, its flowers and vines thrive in the spring sun.\nHidden among the dense leaves, birds sing, and the fragrant breeze lingers, enchanting the beauty"
})

-------------------Halo and pause--------------------

local gfilter_data = require "data/gamefilter"
local fns = {}
t_util:Pairs(gfilter_data, function (id, data)
    fns[id] = function (state)
        t_util:Pairs(data.shelter, function(sls, info)
            h_util:VisibleUI(t_util:GetRecur(h_util:GetHUD(), sls), state, info)
        end)
    end
    table.insert(screen_data, {
        id = id,
        label = data.label,
        fn = function (show)
            fns[id](show)
            SaveFunction({[id] = show})
        end,
        hover = data.hover,
        default = type(save_data[id]) == "nil" and data.default or save_data[id]
    })
end)

AddClassPostConstruct("screens/playerhud", function(self)
    local _CreateOverlays = self.CreateOverlays
    self.CreateOverlays = function(self, ...)
        local result = _CreateOverlays(self, ...)
        t_util:Pairs(fns, function (id, fn)
            fn(save_data[id])
        end)
        LeafcanopyFn(save_data.leafcanopy)
        return result
    end
end)


--------------------- Woodie -------------------------
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

table.insert(screen_data, {
    id = "woodieover",
    label = "Woodie transformed",
    fn = function (show)
        SaveFunction({woodieover = show})
        WoodieFn()
    end,
    hover = "Does it show the yellow depth of field\nafter Woodie's transformation?"
})
-------------------------- Map ----------------------
AddClassPostConstruct("widgets/mapwidget", function(self)
    if save_data.map_bg then
        self.bg:Hide()
    end
end)


---------------------- Hiding berries near Terraria ------------------

local prefab = "terrariumchest"
AddPrefabPostInit(prefab, function(inst)
    inst:DoPeriodicTask(2, function()
        if e_util:FindEnt(inst, prefab .. "_fx", 0.1, { "fx" }, {}) then
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
table.insert(screen_data, {
    id = "terr_berry",
    label = "Highlight Terraria",
    fn = function(show)
        SaveFunction({terr_berry = show})
    end,
    hover = "Should berry bushes near Terraria chests be displayed?"
})
table.insert(screen_data, {
    id = "map_bg",
    label = "Map transparency",
    fn = function(show)
        SaveFunction({map_bg = show})
    end,
    hover = "Enable map transparency?"
})
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
table.insert(screen_data, {
    id = "mapbtn_hide",
    label = "Hide Map Button",
    fn = function(show)
        SaveFunction({mapbtn_hide = show})
        HideMapBtn()
    end,
    hover = "Whether to hide the map button"
})


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
-------------------------Load-------------------
m_util:AddBindShowScreen("sw_beauti", "Game filters", "butter", "Modify various filters in the game in real time", {
    title = "Game filters",
    id = save_id,
    data = screen_data,
    default = function (id)
        return save_data[id] and true or false
    end
}, nil, 9995)

-- getupvalue, setfenv, 
-- sethook, setlocal, setmetatable, setupvalue, traceback