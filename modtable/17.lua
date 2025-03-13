if m_util:IsServer() then return end
local save_id = "sw_autoreel"
local default_data = {
    sw = true,
    frame = 3,
    makesth = true,
    showme = true,
    amount = 0,
    text = true,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local string_reel = "Pond fishing"

local function Say(...)
    if save_data.text then
        u_util:Say(...)
    end
end
i_util:AddLeftClickFunc(function (pc, player, down, act, pond)
    if not (not down and save_data.sw and act and act.action == ACTIONS.FISH) then return end
    local pusher = player.components.hx_pusher
    local pond_prefab = pond and pond.prefab
    if not (pusher and pond_prefab) then return end
    local hand = p_util:GetEquip("hands")
    local rod_prefab = hand and hand.prefab
    if not rod_prefab then return end
    local frames = save_data.frame * FRAMES
    local showme = save_data.showme and m_util:EnableShowme()
    local str_reel = t_util:GetRecur(ACTIONS, "REEL.str") or {}
    local str_click = {str_reel.GENERIC, str_reel.REEL}

    Say(string_reel, "Start")
    pusher:RegNowTask(function()
        hand = p_util:GetEquip("hands")
        if hand and hand.prefab==rod_prefab then
            if showme then
                local pond_data = d_util:QueryShowme(pond)
                if pond_data then
                    if not (pond_data[1] and pond_data[1]>save_data.amount) then
                        local ponds = e_util:FindEnts(nil, pond_prefab, nil, {"fishable"}, nil, nil, nil, function(ent)
                            return ent ~= pond
                        end)
                        pond = t_util:IGetElement(ponds, function(ent)
                            local data = d_util:QueryShowme(ent)
                            return data and data[1] and data[1]>save_data.amount and ent 
                        end) or pond
                    end
                else
                    Say("The network condition is not good, please turn the [Change pond] function Off")
                end
            end
            local trans = e_util:IsValid(pond)
            if trans then
                local act = p_util:GetAction("equip", {"fish", "reel"}, false, hand, pond)
                if act then
                    local act_id = act.action and act.action.id
                    local act_str = act:GetActionString()
                    if act_id == "FISH" or table.contains(str_click, act_str) then
                        local x,_,z = trans:GetWorldPosition()
                        p_util:DoAction(act, RPC.LeftClick, act.action.code, x, z, pond, true, 10, true, act.action.mod_name)
                    end
                elseif table.contains({"fish_catch", "bite_light_pre", "bite_light_loop"}, e_util:GetAnim(player)) then
                    -- Todo is forced to click when you can't get action
                end
            else
                Say("No fish pond available, no automatic fishing")
                return true
            end
        else
            local rod = p_util:GetItemFromAll(rod_prefab)
            if rod then
                p_util:Equip(rod)
            else
                if save_data.makesth and p_util:CanBuild(rod_prefab) then
                    Say("Make fishing rod")
                    if d_util:MakeItem(rod_prefab) then
                        Say("Failure to make a fishing rod")
                        return true
                    end
                else
                    Say("No fishing rod, unable to fish automatically")
                    return true
                end
            end
        end
        d_util:Wait(frames)
    end, function()
        Say(string_reel, "Finish")
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
        id = "text",
        label = "Prompt text",
        fn = fn_save("text"),
        hover = "Whether to display text prompts about fishing",
        default = fn_get,
    },
    {
        id = "makesth",
        label = "Try making fishing rod",
        fn = fn_save("makesth"),
        hover = "Enable this item to make fishing rod when there is no fishing rod",
        default = fn_get,
    },
    {
        id = "showme",
        label = "Change pond",
        fn = fn_save("showme"),
        hover = "This function requires enabling mod [ShowMe]\nAutomatically change pond when the number of fish in pond reach the limit",
        default = fn_get,
    },
    {
        id = "amount",
        label = "Min fish:",
        fn = fn_save("amount"),
        hover = "[Change pond] Additional setting\nWhen the number of fish is greater than this number, continue fishing, otherwise change the pond or stop fishing",
        default = fn_get,
        type = "radio",
        data = t_util:BuildNumInsert(0, 20, 1, function(i)
            return {data = i, description = i.." fishes"}
        end)
    },
    {
        id = "frame",
        label = "RPC interval:",
        fn = fn_save("frame"),
        hover = "The default is "..default_data.frame.." frames, the smaller the setting, the faster",
        default = fn_get,
        type = "radio",
        data = frame_datatable,
    },
}
local func_right = m_util:AddBindShowScreen({
    title = string_reel,
    id = "hx_" .. save_id,
    data = screen_data
})
local function func_left()
    local state = not save_data.sw
    fn_save("sw")(state)
    Say(string_reel, state)
end
m_util:AddBindConf(save_id, func_left, nil,
    { string_reel, "fishsticks", STRINGS.LMB .. "On/Off " .. STRINGS.RMB .. "Advanced settings", true, func_left, func_right })