if m_util:IsServer() then return end
local save_id = "sw_catcher"
local string_task = "Static task+"
local default_data = {
    bird_warn = 12,
    range_pick = 30,
    range_catch = 30,
    sw_f = true,
    sw_g = true,
    sw_p = true,
    sw_m = true,
    sw_n = true
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local prefab_core = "moonstorm_static_nowag"
local prefab_birds = {"bird_mutant", "bird_mutant_spitter"}
local function Say(who, what)
    u_util:Say(who, what, nil, nil, true)
end



local function fn()
    local pusher = m_util:GetPusher()
    if not pusher then return end
    if pusher:GetNowTask() then
        return pusher:StopNowTask()
    end
    local core = e_util:FindEnt(nil, prefab_core)
    if not core then
        return Say("Can't find "..e_util:GetPrefabName(prefab_core))
    end
    local weapon = p_util:GetEquip("hands")
    if not weapon or type(weapon.name)~="string" then
        return Say("Please equip a weapon first")
    end
    Say("Started, weapon is "..weapon.name)
    local mode = "Wait mode"
    local bird_core, item_give, item_tool, item_mine, equip_mine, item_net, equip_net
    
    
    
    
    local function SetMode(M)
        Say(M)
        mode = M
    end

    local function Can_Attack_Bird()
        bird_core = save_data.sw_f and e_util:FindEnt(core, prefab_birds, save_data.bird_warn)
        return bird_core
    end
    local function Can_Give_NPC()
        item_give = save_data.sw_g and e_util:GetAnim(core) == "needtool_idle" and p_util:GetItemFromAll(nil, "wagstafftool")
        return item_give
    end
    local function Can_Pick_Tool()
        
        item_tool = save_data.sw_p and not p_util:GetItemFromAll(nil, "wagstafftool") and e_util:FindEnt(core, nil, save_data.range_pick, {"wagstafftool"})
        return item_tool
    end
    local function Can_Mine_Glass()
        
        item_mine = save_data.sw_m and e_util:FindEnt(core, "moonstorm_glass", save_data.range_catch, nil, nil, nil, nil, function(ent)
            return not e_util:FindEnt(ent, prefab_birds, 8)
        end)
        
        equip_mine = item_mine and p_util:GetItemFromAll(nil, nil, function(equip)
                return p_util:GetAction("equip", "MINE", false, equip, item_mine)
            end, {"equip", "mouse", "container", "backpack", "body"})
        return equip_mine
    end
    local function Can_Net_Spark()
        
        item_net = save_data.sw_n and e_util:FindEnt(core, "moonstorm_spark", save_data.range_catch, nil, nil, nil, nil, function(ent)
            return not e_util:FindEnt(ent, prefab_birds, 2)
        end)
        
        equip_net = item_net and p_util:GetItemFromAll(nil, nil, function(equip)
                return p_util:GetAction("equip", "NET", false, equip, item_net)
            end, {"equip", "mouse", "container", "backpack", "body"})
        return equip_net
    end


    local mv = m_util:GetMovementPrediction()
    m_util:SetMovementPrediction(false)
    pusher:RegNowTask(function(player)
        if not e_util:IsValid(core) or p_util:GetActiveItem() then
            return true
        end
        if mode == "Wait mode" then 
            
            if Can_Give_NPC() then
                SetMode("Give mode")
            elseif Can_Attack_Bird() then
                SetMode("Combat mode")
            elseif Can_Pick_Tool() then
                SetMode("Pick up tool")
            
            elseif Can_Mine_Glass() then
                SetMode("Mine mode")
            elseif Can_Net_Spark() then
                SetMode("Capture mode")
            else
                
                local pos = c_util:GetIntersectPotRadiusPot(core:GetPosition(), 3.5, player:GetPosition())
                p_util:ForceWalkTo(pos)
            end
        elseif mode=="Combat mode" then
            bird_core = e_util:FindEnt(bird_core, prefab_birds, 9)
            if bird_core then
                d_util:TabWeaponAtk(weapon, bird_core)
            else
                SetMode("Wait mode")
            end
        elseif mode=="Give mode" then
            d_util:TabGive(core, item_give)
            SetMode("Wait mode")
        elseif mode == "Pick up tool" then
            d_util:TabPickUp(item_tool)
            SetMode("Wait mode")
        elseif mode == "Mine mode" then
            d_util:TabEquipTarget(item_mine, equip_mine, "MINE")
            SetMode("Pick up ore")
        elseif mode == "Pick up ore" then
            local item_glass = e_util:FindEnt(nil, "moonglass_charged", 4)
            if item_glass then
                d_util:TabPickUp(item_glass)
            else
                SetMode("Wait mode")
            end
        elseif mode == "Capture mode" then
            d_util:TabEquipSingle(item_net, equip_net, "NET")
            SetMode("Wait mode")
        end
        d_util:Wait()
    end, function()
        m_util:SetMovementPrediction(mv)
        Say("Stopped")
    end)
end



local range_table = t_util:BuildNumInsert(5, 80, 5, function(i)
    return {
        data = i,
        description = i
    }
end)
local screen_data = {{
    id = "sw_f",
    label = "Combat mode",
    fn = fn_save("sw_f"),
    hover = "Whether to automatically attack birds",
    default = fn_get
}, {
    id = "sw_g",
    label = "Give mode",
    fn = fn_save("sw_g"),
    hover = "Whether to automatically give Wagstaff tools",
    default = fn_get
}, {
    id = "sw_p",
    label = "Pick up tools",
    fn = fn_save("sw_p"),
    hover = "Whether to automatically pick up Wagstaff tools",
    default = fn_get
}, {
    id = "sw_m",
    label = "Mine mode",
    fn = fn_save("sw_m"),
    hover = "Whether to automatically mine Charged Glassy Rock",
    default = fn_get
}, {
    id = "sw_n",
    label = "Capture mode",
    fn = fn_save("sw_n"),
    hover = "Whether to automatically catch Moongleams",
    default = fn_get
}, {
    id = "bird_warn",
    label = "Alert range:",
    fn = fn_save("bird_warn"),
    hover = "If moonblind crows enter this range around the NPC, switch to combat mode",
    default = fn_get,
    type = "radio",
    data = t_util:BuildNumInsert(6, 60, 2, function(i)
        return {
            data = i,
            description = i
        }
    end)
}, {
    id = "range_pick",
    label = "Pickup range:",
    fn = fn_save("range_pick"),
    hover = "Range to pick up tools for Wagstaff",
    default = fn_get,
    type = "radio",
    data = range_table
}, {
    id = "range_catch",
    label = "Collection range:",
    fn = fn_save("range_catch"),
    hover = "Range for collecting Moongleams or mining Charged Glassy Rock",
    default = fn_get,
    type = "radio",
    data = range_table
}}
local func_right = m_util:AddBindShowScreen({
    title = string_task,
    id = "hx_" .. save_id,
    data = screen_data,
    icon = {{
        id = "bilibili",
        prefab = "bilibili",
        hover = "Tutorial demo",
        fn = function()
           VisitURL("https://www.bilibili.com/video/BV16ymkBuEKn/", true)
        end,
    },{
        id = "thanks",
        prefab = "abigail_flower_handmedown",
        hover = "Special thanks",
        fn = function()
            h_util:CreatePopupWithClose("󰀍 Special thanks 󰀍", 'This function was customized by player "饭港鬼影诺梦".\n\nMessage: "Note: waste consumption"', {{text = "󰀍"}})
        end,
    }},
    help = "Use this function to auto complete the Static Task after Wagstaff is captured.\nWhen started, the player's equipped hand item is treated as the combat weapon."
})

m_util:AddBindConf(save_id, fn, nil,
    {string_task, "moonstorm_static_catcher_item", STRINGS.LMB .. ' quick toggle ' .. STRINGS.RMB .. ' advanced settings', true, fn,
     func_right, 1.1})