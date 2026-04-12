
local save_id, str_auto, img_show = "sw_fishkill", "Auto Slaughter", "oceanfish_medium_8_inv"
local default_data = {
    cate = "all",
    pos = "all",
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)



local function fn_left()
    local pusher = m_util:GetPusher()
    if not pusher then return end
    
    local order = "mouse"
    local pos = save_data.pos
    if pos == "backpack" then
        order = {"backpack"}
    elseif order == "inv" then
        order = {"body"}
    elseif order == "player" then
        order = {"backpack", "body"}
    elseif order == "cont" then
        order = {"container"}
    end

    pusher:RegNowTask(function()
        local fish = p_util:GetItemFromAll(nil, nil, function(item)
            if p_util:GetAction("inv", "MURDER", true, item) then
                local cate, prefab = save_data.cate, item.prefab
                if table.contains({"pondfish", "pondeel"}, cate) then
                    return prefab == cate
                elseif table.contains({"oceanfish", "wobster"}, cate)then
                    return prefab:find(cate)
                elseif table.contains({"spider", "fish"}, cate) then
                    return item:HasTag(cate)
                end
                return true
            end
        end, order)
        if fish then
            local act = p_util:GetAction("inv", "MURDER", true, fish)
            if act then
                p_util:DoAction(act, RPC.ControllerUseItemOnSelfFromInvTile, act.action.code, fish, act.action.mod_name)
            end
        else
            return true
        end
        d_util:Wait()
    end, function()
        u_util:Say(str_auto, "Ended")
    end)
end



local fn_right = m_util:AddBindShowScreen{
    title="Auto Slaughter Advanced Settings",
    id=save_id,
    data = {{
            id = "cate",
            type = "radio",
            label = "Category:",
            hover = "Choose which creatures to slaughter",
            data = {
                {description="All", data="all"},
                {description="Pond fishs", data="pondfish"},
                {description="Eels", data="pondeel"},
                {description="Sea fishs", data="oceanfish"},
                {description="Fishs", data="fish"},
                {description="Spiders", data="spider"},
                {description="Lobsters", data="wobster"},
            },
            fn = fn_save("cate"),
            default = fn_get,
        },{
            id = "pos",
            type = "radio",
            label = "Area:",
            hover = "Choose which locations to slaughter",
            data = {
                {description="All", data="all"},
                {description="Backpack", data="backpack"},
                {description="Inventory", data="inv"},
                {description="Bpack+Inv", data="player"},
                {description="Container", data="cont"},
            },
            fn = fn_save("pos"),
            default = fn_get,
        },
    },
    icon = {{
        id = "thanks",
        prefab = "abigail_flower_handmedown",
        hover = "Special thanks",
        fn = function()
            h_util:CreatePopupWithClose("󰀍 Special thanks 󰀍", 'The Auto Slaughter feature was customized by player "小宇".\n\nMessage: "Pure save, small server doesn\'t count as open"', {{text = "󰀍"}})
        end,
    }}
}


m_util:AddBindConf(save_id, fn_left, fn_left, {str_auto, img_show , STRINGS.LMB .. 'Start ' .. STRINGS.RMB .. 'Advanced Settings'
, true, fn_left, fn_right})