local CPS = require "widgets/huxi/huxi_compass"
local save_id, str_show = "sw_compass", "Compass"
local default_data = {
    -- posx, posy
    scale = 1,
    offset = not m_util:IsHuxi(),
    text = true,
    shake = true,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)

local UI_funcs = {
    SavePos = function(pos)
        fn_save("posx")(pos.x)
        fn_save("posy")(pos.y)
    end
}

local function GetCPS()
    local cps = h_util:GetControls().hx_compass
    return cps and h_util:IsValid(cps)
end

local function MakeCPS()
    local ctrls = t_util:GetRecur(ThePlayer, "HUD.controls")
    if ctrls then
        ctrls.hx_compass = ctrls:AddChild(CPS(UI_funcs, save_data))
    end
end

local function fn_set(id)
    return function(val)
        fn_save(id)(val)
        local cps = GetCPS()
        if cps then
            cps:Kill()
            MakeCPS()
        end
    end
end

local function fn_left()
    local cps = GetCPS()
    if cps then
        cps:Kill()
        u_util:Say(str_show, "Off", nil, "Red", true)
    else
        MakeCPS()
        u_util:Say(str_show, "On", nil, "Green", true)
    end
end

local screen_data = {
    {
        id = "reset",
        label = "Reset compass position",
        hover = "If the icons are misplaced, try this option",
        fn = function()
            local cps = GetCPS()
            if cps then
                cps:SetUIPos(true)
            else
                u_util:Say(str_show, "You have not enabled this feature", "self", "红色", true)
            end
        end,
        default = true,
    },
    {
        id = "scale",
        label = "Scale：",
        hover = "Adjust the size of the compass",
        fn = fn_set("scale"),
        default = fn_get,
        type = "radio",
        data = t_util:BuildNumInsert(0.1, 4, 0.1, function(i)
            return {data = i, description = i}
        end)
    },
    {
        id = "shake",
        label = "Realistic compass",
        hover = "Is the compass shaking?\n If this option is disabled, the next option will not take effect",
        fn = fn_set("shake"),
        default = fn_get,
    },
    {
        id = "offset",
        label = "More realistic",
        hover = "Sanity and moon phase will affect the compass angle\n Enable this option and it will be exactly like the vanilla compass",
        fn = fn_set("offset"),
        default = fn_get,
    },
    {
        id = "text",
        label = "Display number",
        hover = "Are there number showing the exact direction?",
        fn = fn_set("text"),
        default = fn_get,
    },
    {
        id = "readme",
        label = "Special thanks!",
        fn = function()
            h_util:CreatePopupWithClose("󰀍"..str_show.." · Special thanks󰀍",
                "This function is specially customized by 猫头军师 (Cathead Military Advisor)\n\nMessage: Meow meow meow, meow meow meow, meow meow!!")
        end,
        hover = "Special thanks",
        default = true
    },
}
local fn_right = m_util:AddBindShowScreen({
    title = str_show,
    id = "hx_" .. save_id,
    data = screen_data
})
m_util:AddBindConf(save_id, fn_left, nil, {str_show, "compass",
                                           STRINGS.LMB .. 'On/Off' .. STRINGS.RMB .. 'Advanced settings', true,
                                           fn_left, fn_right, 2997})