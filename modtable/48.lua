
local save_id, str_show, logo = "sw_hideshadow", "Hide shadows", "skeletonhat"
local prefabs = {
    "crawlinghorror","terrorbeak",          
    "crawlingnightmare","nightmarebeak",    
    "oceanhorror",                          
    "ruinsnightmare",                       
    "shadowskittish",                       
    "gestalt_guard",                        
    "gestalt",                              
    "gestalt_guard_evolved",                
}
local SW
local function func(inst)
    if SW then
        inst:Hide()
        if inst.SoundEmitter then
            inst.SoundEmitter:SetMute(true)
        end
    else
        inst:Show()
        if inst.SoundEmitter then
            inst.SoundEmitter:SetMute(false)
        end
    end
end

t_util:IPairs(prefabs, function(prefab)
    AddPrefabPostInit(prefab, function(inst)
        inst:DoPeriodicTask(FRAMES, func)
    end)
end)

local function fn_sw(value)
    SW = not SW
    u_util:Say(str_show, SW, nil, nil, true)
    t_util:IPairs(e_util:FindEnts(nil, prefabs, nil, {}, {}, nil, {}), func)
end

m_util:AddBindConf(save_id, fn_sw, nil, {str_show, logo, STRINGS.LMB .. "Toggle (Auto turns off upon re-entering the game)", true, fn_sw, function()
    h_util:CreatePopupWithClose("󰀍 Special Thanks 󰀍", "This feature was commissioned by sponsor 花间随柳.\n(It can also hide Moon Spirits)", {{text = "󰀍"}})
end, 8002})