
-- Vanca: Preserve the [Night vision] function        
-- Smart night vision
if m_util:IsServer() and not m_util:IsLava() then return end
local save_id = "sw_nightsight"
local save_data = s_mana:GetSettingLine(save_id, true)
local default_data = {
    state = false,
    say = true,
    say_color = "Blue",
    ns = 0.8,
    in_night = 0.4,
    ori = false or m_util:IsHuxi(),
}
local fn_savedata = function(id) return save_data[id] end
local function Save(key)
    return function(value)
        s_mana:SaveSettingLine(save_id, save_data, { [key] = value })
    end
end
s_mana:LoadDefaults(save_data, default_data)
local function calc(c)
    return (save_data.in_night-save_data.ns)/save_data.in_night*c + save_data.ns
end
local function setFNV(value)
    local pv = t_util:GetRecur(ThePlayer or {}, "components.playervision")
    if pv then
        pv:ForceNightVision(value)
    end
end
local tip_lock
i_util:AddWorldActivatedFunc(function(world)
    local mt = t_util:GetMetaIndex(TheSim)
    local _SetVisualAmbientColour = mt.SetVisualAmbientColour
    mt.SetVisualAmbientColour = function(sim, c1, c2, c3, ...)
        if save_data.state and c1 < save_data.in_night and c2 < save_data.in_night and c3 < save_data.in_night then
            if not tip_lock then
                tip_lock = true
                if save_data.say then
                    u_util:Say("Hint", "At night, please prepare the light source", nil, save_data.say_color)
                end
                if save_data.ori then
                    setFNV(true)
                end
            else
                if save_data.ori then
                    setFNV(true)
                else
                    c1, c2, c3 = calc(c1), calc(c2), calc(c3)
                end 
            end
        else
            tip_lock = false
        end
        _SetVisualAmbientColour(sim, c1, c2, c3, ...)
    end
    world:WatchWorldState("startday", function()
        if save_data.ori then
            i_util:DoTaskInTime(5, function()
                setFNV(false)
            end)
        end
    end)
end)

local color_data = require("data/valuetable").RGB_datatable

local screen_data = {
    {
        id = "state",
        label = "Night vision switch",
        fn = function (value)
            Save("state")(value)
            if save_data.ori and not value then
                setFNV(false)
            end
        end,
        hover = "Turn night vision ON or OFF",
        default = fn_savedata,
    },
    {
        id = "say",
        label = "Dark reminder",
        fn = Save("say"),
        hover = "Whether to prompt 'at night, please prepare the light source'",
        default = fn_savedata,
    },{
        id = "say_color",
        label = "Prompt color:",
        fn = Save("say_color"),
        hover = "It's too idle, add this settings, otherwise the panel is empty and empty",
        default = fn_savedata,
        type = "radio",
        data = color_data,
    },{
        id = "in_night",
        label = "Understanding:",
        fn = Save("in_night"),
        hover = "The brightness is lower than this, even if it is dark, the default is"..default_data.in_night,
        default = fn_savedata,
        type = "radio",
        data = t_util:BuildNumInsert(0.1, 1, 0.1, function (i)
            return {data = i, description = i}
        end),
    },{
        id = "ns",
        label = "Night vision brightness:",
        fn = Save("ns"),
        hover = "If you turn on [old edition night view] this function will fail\nof the brightness of the night vision, adjust it yourself, the default is "..default_data.ns,
        default = fn_savedata,
        type = "radio",
        data = t_util:BuildNumInsert(0.1, 1, 0.1, function (i)
            return {data = i, description = i}
        end),
    },
    {
        id = "ori",
        label = "Old version of night vision",
        fn = function (value)
            Save("ori")(value)
            if not value then
                setFNV(value)
            end
        end,
        hover = "Enabling this option will restore the mousse version of the night vision\n(the kind that will not be beaten by charlie without opening the cave, items in the dark can interact)",
        default = fn_savedata,
    },
}

local function func_left()
    local state = not save_data.state
    Save("state")(state)
    if state then
        u_util:Say("Hint", t_util:GetRecur(TheWorld or {}, "state.isnight") and "Smart night vision has been opened" or "Smart night vision has been opened, and it will be automatically enabled at night", nil, save_data.say_color)
    else
        if save_data.ori then
            setFNV(false)
        end
        u_util:Say("Hint", "Smart night vision has been closed", nil, save_data.say_color)
    end
end


local func_right = m_util:AddBindShowScreen({
    title = "Smart night vision",
    id = "hx_" .. save_id,
    data = screen_data
})
m_util:AddBindConf(save_id, func_left, nil,
    { "Night vision", "wx78module_nightvision", STRINGS.LMB .. "Fast switch" .. STRINGS.RMB .. "Advanced settings", true, func_left, func_right })
