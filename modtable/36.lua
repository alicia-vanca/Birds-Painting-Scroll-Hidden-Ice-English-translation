
local save_id, str_auto, img_show = "sw_watering", "Auto Watering", "wateringcan"
local default_data = {
    
    towater = true,
    
    tofill = true,
    
    tosay = true,
    
    
    perwater = 90,
    perfill = 90,
    
    range = 40,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local function Say(str)
    if str and save_data.tosay then
        u_util:Say(str_auto, str, "head", "LightSkyBlue", true)
    end
    return true
end
local prefabs_inv = {"wateringcan", "premiumwateringcan"}
local function GetMoisture(nut)
    local wet = nut and nut.AnimState and nut.AnimState:GetCurrentAnimationTime() or 1
    return wet < 0 and 0 or (wet > 1 and 1 or wet)
end
local function fn_left()
    local pusher = m_util:GetPusher()
    if not pusher then return end
    if pusher:GetNowTask() then
        return pusher:StopNowTask()
    end
    local flag = save_data.towater and "Watering mode" or "Refill mode"

    pusher:RegNowTask(function(player, pc)
        if save_data.towater and flag == "Watering mode" then
            local nuts = e_util:FindEnts(nil, "nutrients_overlay", save_data.range, nil, {})
            if not nuts[1] and not save_data.tofill then
                return Say("No farmland nearby")
            end
            local nut = t_util:IGetElement(nuts, function(nut)
                return GetMoisture(nut)*100 < save_data.perwater and nut
            end)
            if nut then
                local tool = p_util:GetItemFromAll(prefabs_inv, nil, function(item)
                    return e_util:GetPercent(item) > 1
                end, {"equip", "body", "backpack", "container"})
                if tool then
                    
                    if p_util:GetEquip("hands") == tool then
                        local pos = nut:GetPosition()
                        local act = p_util:GetAction("pos", "POUR_WATER_GROUNDTILE", true, tool, nil, pos)
                        if act then
                            p_util:DoAction(act, RPC.RightClick, act.action.code, pos.x, pos.z, act.target, act.rotation, true, nil, nil, act.action.mod_name)
                        end
                    else
                        p_util:Equip(tool)
                    end
                else
                    tool = p_util:GetItemFromAll(prefabs_inv, nil, nil, {"equip", "body", "backpack", "container"})
                    if tool then
                        
                        if save_data.tofill then
                            flag = "Refill mode"
                            Say(flag)
                            return
                        else
                            return Say("The watering can is empty")
                        end
                    else
                        return Say("No watering can found")
                    end
                end
            elseif save_data.tofill then
                
                local tool = p_util:GetItemFromAll(prefabs_inv, nil, function(item)
                    return e_util:GetPercent(item) < save_data.perfill
                end, {"equip", "body", "backpack", "container"})
                if tool then
                    flag = "Refill mode"
                    Say(flag)
                    return
                end
            end
        elseif save_data.tofill and flag == "Refill mode" then
            local tool = p_util:GetItemFromAll(prefabs_inv, nil, function(item)
                return e_util:GetPercent(item) < save_data.perfill
            end, {"equip", "body", "backpack", "container"})
            if tool then
                if p_util:GetEquip("hands") == tool then
                    local act
                    local pond = e_util:FindEnt(nil, nil, save_data.range, nil, nil, nil, nil, function(ent)
                        act = p_util:GetAction("equip", "FILL", true, tool, ent)
                        return act
                    end)
                    if pond then
                        local pos = pond:GetPosition()
                        p_util:DoAction(act, RPC.RightClick, act.action.code, pos.x, pos.z, pond, act.rotation, nil, nil, true, act.action.mod_name)
                    else
                        m_util:print("No pond found")
                    end
                else
                    p_util:Equip(tool)
                end
            else
                flag = "Watering mode"
                Say(flag)
                return
            end
        else
            return Say("No task")
        end
        m_util:print(flag)
        d_util:Wait(.5)
    end, function()
        u_util:Say(str_auto, "Finish")
    end)
end


local r_data = require("data/valuetable")
local fn_right = m_util:AddBindShowScreen{
    title="Auto Watering Advanced Settings",
    id=save_id,
    data = {
        {
            id = "towater",
            label = "Water farmland",
            fn = fn_save("towater"),
            hover = "Whether to automatically water farmland",
            default = fn_get,
        },
        {
            id = "perwater",
            label = "Moisture:",
            fn = fn_save("perwater"),
            hover = "Stop watering when farmland moisture reaches this value",
            type = "radio",
            data = t_util:BuildNumInsert(5, 95, 5, function(i)
                return {data = i, description = i .. "%"}
            end),
            default = fn_get,
        },
        {
            id = "tofill",
            label = "Refill watering can",
            fn = fn_save("tofill"),
            hover = "Whether to automatically refill the watering can",
            default = fn_get,
        },
        {
            id = "perfill",
            label = "Reserve:",
            fn = fn_save("perfill"),
            hover = "When idle, the watering can should stay above this threshold",
            type = "radio",
            data = t_util:BuildNumInsert(5, 95, 5, function(i)
                return {data = i, description = i .. "%"}
            end),
            default = fn_get,
        },
        {
            id = "tosay",
            label = "Text prompts",
            fn = fn_save("tosay"),
            hover = "Whether to display text prompts over the character",
            default = fn_get,
        },
        {
            id = "range",
            label = "Range:",
            fn = fn_save("range"),
            type = "radio",
            hover = "Range to search for farmland or ponds",
            default = fn_get,
            data = t_util:BuildNumInsert(4, 60, 4, function(i)
                return {data = i, description = i .. " wall points"}
            end),
        },
    },
    icon = {{
        id = "thanks",
        prefab = "abigail_flower_handmedown",
        hover = "Special thanks",
        fn = function()
            h_util:CreatePopupWithClose("󰀍 Special Thanks 󰀍", 'The auto watering feature was commissioned by player "Xiaoyu".\n\nMessage: "Pure worlds only, small servers don’t count"', {{text = "󰀍"}})
        end,
    }}
}


m_util:AddBindConf(save_id, fn_left, fn_left, {str_auto, img_show , STRINGS.LMB .. 'Start/Stop ' .. STRINGS.RMB .. 'Advanced Settings'
, true, fn_left, fn_right, 5999})