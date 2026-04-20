
local save_id, str_show, logo = "sw_autoeat", "Auto Eat", "icon_hunger"
local default_data = {
    sw_hunger = false,
    sw_health = false,
    value_hun = 0,
    value_hea = 0,
    prefab_hun = "shroomcake",
    prefab_hea = "vegstinger",
    sw_cont = true,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local _lock_eat

i_util:AddPlayerActivatedFunc(function(player)
    local function AutoEat(prefab_food)
        if _lock_eat then
            return
        end
        local food = p_util:GetItemFromAll(prefab_food, nil, nil, "mouse")
        if food then
            p_util:Eat(food)
        elseif save_data.sw_cont and not p_util:GetActiveItem() then
            local cont = p_util:GetItemFromAll(nil, nil, function(ent)
                return not p_util:IsOpenContainer(ent) and Mod_ShroomMilk.Func.HasPrefabWithBox and Mod_ShroomMilk.Func.HasPrefabWithBox(ent, prefab_food, true)
            end, {"container", "backpack", "body",})
            if cont then
                local act = cont and p_util:GetAction("inv", "RUMMAGE", true, cont)
                if act then
                    _lock_eat = true
                    p_util:DoAction(act, RPC.ControllerUseItemOnSelfFromInvTile, act.action.code, cont)
                    e_util:WaitToDo(player, .1, 10, function()
                        return p_util:IsOpenContainer(cont)
                    end, function()
                        local food = p_util:GetItemFromAll(prefab_food, nil, nil, "mouse")
                        if food then
                            p_util:Eat(food)
                        else
                            act = cont and p_util:GetAction("inv", "RUMMAGE", true, cont)
                            if act then
                                p_util:DoAction(act, RPC.ControllerUseItemOnSelfFromInvTile, act.action.code, cont)
                            end
                        end
                        _lock_eat = nil
                    end, function()
                        _lock_eat = nil
                    end)
                end
            end
        end
    end
    local function InHunger()
        return save_data.sw_hunger and t_util:GetRecur(player, "replica.hunger") and player.replica.hunger:GetCurrent() <= save_data.value_hun
    end
    local function InHealth()
        return save_data.sw_health and t_util:GetRecur(player, "replica.health") and player.replica.health:GetCurrent() <= save_data.value_hea
    end
    player:ListenForEvent("hungerdelta", function()
        if InHunger() then
            AutoEat(save_data.prefab_hun)
        end
    end)
    player:ListenForEvent("healthdelta", function()
        if InHunger() then
            AutoEat(save_data.prefab_hun)
        elseif InHealth() then
            AutoEat(save_data.prefab_hea)
        end
    end)
end)

local function fn_textbtn(val_id, label, hover)
    return {
        id = val_id,
        label = label,
        hover = hover,
        default = fn_get,
        type = "textbtn",
        fn = function()
            h_util:CreateWriteWithClose("Enter value for "..label, {
                text = "Confirm",
                cb = function(str)
                    local val = tonumber(str)
                    if val and val >= 0 then
                        fn_save(val_id)(val)
                    else
                        h_util:CreatePopupWithClose("Invalid input", "Please enter a number greater than or equal to 0.")
                    end
                end
            })
        end
    }
end
local screen_data = {
    {
        id = "sw_hunger",
        label = "Monitor hunger",
        hover = "When enabled, auto eat when hunger is low",
        default = fn_get,
        fn = fn_save("sw_hunger"),
    },
    fn_textbtn("value_hun", "Hunger threshold:", "Auto eat when hunger is at or below this value"),
    {
        id = "sw_health",
        label = "Monitor health",
        hover = "When enabled, auto eat when health is low",
        default = fn_get,
        fn = fn_save("sw_health"),
    },
    fn_textbtn("value_hea", "Health threshold:", "Auto eat when health is at or below this value"),
}
local function fn_set_prefab(pid, title, prefix)
    local prefab = save_data[pid] or default_data[pid]
    local name = e_util:GetPrefabName(prefab)
    name = name == e_util.NullName and prefab or name
    local data = {
        id = prefab, 
        fn = function()
            m_util:PushPrefabScreen{
                text_title = title,
                text_btnok = "Confirm selection",
                hover_btnok = "Confirm auto eat",
                fn_btnok = function(prefab)
                    fn_save(pid)(prefab)
                end
            }
        end
    }
    local str = c_util:TruncateChineseString(prefix..name, 10)
    if h_util:GetPrefabAsset(prefab) then
        data.type = "imgstr"
        data.label = str
        data.hover = prefix .. name .. "\nClick to change food!"
        data.prefab = prefab
    else
        data.type = "textbtn"
        data.default = str
        data.label = prefix
        data.hover = "This food is a mod item and cannot show an icon".."\nClick to change food!"
    end
    return data
end

local function fn_get_screen_data()
    local ui_data = {
    {
        id = "sw_cont",
        label = "Search containers",
        hover = "Allow opening containers such as Wargstaff crates to find food",
        default = fn_get,
        fn = fn_save("sw_cont"),
    },}
    table.insert(ui_data, 1, fn_set_prefab("prefab_hea", "Choose low-health food", "Eat at low health:"))
    table.insert(ui_data, 1, fn_set_prefab("prefab_hun", "Choose low-hunger food", "Eat when hungry:"))
    return t_util:MergeList(screen_data, ui_data)
end
m_util:AddBindShowScreen(save_id, str_show, logo, str_show.." settings", {
    title = str_show,
    id = save_id,
    data = fn_get_screen_data,
    icon = {{
        id = "thanks",
        prefab = "abigail_flower_handmedown",
        hover = "Special thanks",
        fn = function()
            h_util:CreatePopupWithClose("󰀎 Special thanks 󰀎", 'The Auto Eat feature was customized by player "忆往昔".\n\nMessage: "Hungry!"', {{text = "󰀎"}})
        end,
    }},
    help = "This feature is for fully automated AFK play and is not recommended for normal gameplay.",
    fn_active = true,
})