if m_util:IsServer() then return end
local save_id = "sw_atreel"
local default_data = {
    sw = true,
    makesth = true,
    mount = 3,
    say = true,
    switch = false,
    pick = true,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local string_reel, id_mount, id_start, id_lock  = "Pond fishing", "_hx_id_pondmount", "_hx_id_pondstart", "_hx_id_pondlock"
local function Say(a,b,...)
    if save_data.say then
        u_util:Say(a,b, nil, nil, true)
    end
    return true
end
local function GetAmount(pond)
    return pond and pond[id_mount] or 0
end


local function GetPond(prefab)
    
    local ponds = e_util:FindEnts(nil, prefab, nil, {"fishable"})
    local pond = t_util:IGetElement(ponds, function(pond)
        return GetAmount(pond) < save_data.mount and pond
    end)
    if pond then
        return pond
    end
    
    t_util:IPairs(ponds, function(pond)
        pond[id_mount] = pond[id_start] and -1 or 0
    end)
    
    table.sort(ponds, function(a, b)
        return GetAmount(a) < GetAmount(b)
    end)
    return ponds[1]
end


i_util:AddLeftClickFunc(function (pc, player, down, act, pond)
    if not (not down and save_data.sw and act and act.action == ACTIONS.FISH) then return end
    local pusher = m_util:GetPusher()
    local pond_prefab = pond and pond.prefab
    if not (pusher and pond_prefab) then return end
    local hand = p_util:GetEquip("hands")
    local rod_prefab = hand and hand.prefab
    if not rod_prefab then return end

    local str_reel = t_util:GetRecur(ACTIONS, "REEL.str") or {}
    local str_click = {str_reel.GENERIC, str_reel.REEL}
    pond[id_start] = true
    local mv = m_util:GetMovementPrediction()
    m_util:SetMovementPrediction(false)
    Say(string_reel, "Start")
    pusher:RegNowTask(function(player)
        if p_util:GetActiveItem() then
            return Say("Inventory full")
        end
        local fish = save_data.pick and e_util:FindEnt(nil, nil, 2, {"pondfish"})
        if fish then
            Say("Pick up fish")
            d_util:TabPickUp(fish)
        end
        hand = p_util:GetEquip("hands")
        if hand and hand.prefab==rod_prefab then
            if save_data.switch then
                pond = GetAmount(pond) < save_data.mount and pond or GetPond(pond)
            end
            local trans = e_util:IsValid(pond)
            local anim = e_util:GetAnim(player)
            if trans and anim then
                local act = p_util:GetAction("equip", {"fish", "reel"}, false, hand, pond)
                local fg = t_util:GetRecur(hand, "replica.fishingrod")
                local tar = fg and fg:GetTarget()
                if (anim == "fish_catch" or anim:find("bite_heavy")) and tar and not tar[id_lock] then
                    tar[id_lock] = true
                elseif act then
                    local act_id = act.action and act.action.id
                    local act_str = act:GetActionString()
                    if act_id == "FISH" or table.contains(str_click, act_str) or anim:find("bite_light") then
                        local x,_,z = trans:GetWorldPosition()
                        p_util:DoAction(act, RPC.LeftClick, act.action.code, x, z, pond, true, 10, true, act.action.mod_name)
                    end
                else
                    
                end
                if tar and tar[id_lock] and anim:find("fishing") then
                    tar[id_lock] = false
                    tar[id_mount] = (tar[id_mount] or 0) + 1
                end
            else
                return Say("No available pond, unable to fish automatically")
            end
        else
            
            local rod = p_util:GetItemFromAll(rod_prefab)
            if rod then
                p_util:Equip(rod)
            else
                if save_data.makesth and p_util:CanBuild(rod_prefab) then
                    Say("Make fishing rod")
                    if d_util:MakeItem(rod_prefab) then
                        return Say("Failure to make a fishing rod")
                    end
                else
                    return Say("No fishing rod, unable to fish automatically")
                end
            end
        end
        d_util:Wait()
    end, function()
        m_util:SetMovementPrediction(mv)
    end)
end)

local frame_datatable = require("data/valuetable").frame_datatable
local screen_data = {
    {
        id = "sw",
        label = string_reel,
        fn = fn_save("sw"),
        hover = "Enable or disable automatic fishing",
        default = fn_get,
    },
    {
        id = "say",
        label = "Floating text",
        fn = fn_save("say"),
        hover = "Whether to show fishing-related floating text prompts",
        default = fn_get,
    },{
        id = "pick",
        label = "Auto pick fish",
        fn = fn_save("pick"),
        hover = "Automatically pick up fish that drop",
        default = fn_get,
    },
    {
        id = "makesth",
        label = "Craft fishing rod",
        fn = fn_save("makesth"),
        hover = "Enable to craft a fishing rod when none is equipped",
        default = fn_get,
    },{
        id = "switch",
        label = "Auto switch pond",
        fn = fn_save("switch"),
        hover = "Switch to another pond after catching a few fish",
        default = fn_get,
    },{
        id = "mount",
        label = "Limit:",
        fn = fn_save("mount"),
        hover = "Auto switch pond sub-feature\nAutomatically switch ponds after the specified number of catches",
        default = fn_get,
        type = "radio",
        data = t_util:BuildNumInsert(1, 20, 1, function(i)
            return {data = i, description = i.." catches"}
        end)
    },{
        id = "reset",
        type = "imgstr",
        label = "Clear pond memory",
        prefab = "pondeel",
        hover = "Auto switch pond sub-feature\nClears pond memory; all ponds start counting from zero again",
        fn = function()
            h_util:CreatePopupWithClose("Warning", "Are you sure you want to clear pond memory?", {
                {
                    text = h_util.no,
                },{
                    text = h_util.yes,
                    cb = function()
                        t_util:IPairs(e_util:FindEnts(nil, nil, nil, {"fishable"}), function(pond)
                            if pond[id_mount] then
                                pond[id_mount] = 0
                            end
                        end)
                        h_util:PlaySound("learn_map")
                    end
                }
            })
        end
    },
}
local func_right = m_util:AddBindShowScreen({
    title = string_reel,
    id = "hx_" .. save_id,
    data = screen_data,
        icon = 
    {{
        id = "thanks",
        prefab = "abigail_flower_handmedown",
        hover = "Special thanks",
        fn = function()
            h_util:CreatePopupWithClose("󰀍 Special Thanks 󰀍", 'The auto pond fishing feature was commissioned by sponsor Longwu Qingfeng v.\n\nMessage: We will eventually play fully automated Don’t Starve!', {{text = "󰀍"}})
        end,
    }}
})
local function func_left()
    local state = not save_data.sw
    fn_save("sw")(state)
    Say(string_reel, state)
end
m_util:AddBindConf(save_id, func_left, nil,
    { string_reel, "pondeel", STRINGS.LMB .. 'Quick toggle' .. STRINGS.RMB .. 'Advanced settings', true, func_left, func_right })