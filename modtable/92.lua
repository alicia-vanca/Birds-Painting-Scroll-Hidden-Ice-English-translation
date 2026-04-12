local save_id, str_auto = "sw_autowork", "Auto Work"
local logo = "shadowlumber_builder"
local default_data = {
    showrange = true,
    range = 36,
    color = "Blue",
    prefabs = {"flower"}
}



local data_act = {
    CHOP = {
        chs = "Chop",
        hover = "Chop tall trees",
        type = "equip",
        check = function(target)
            if table.contains({"evergreen", "deciduoustree", "moon_tree", "twiggytree", "palmconetree", "evergreen_sparse"}, target.prefab) then
                return e_util:IsAnim(function(anim)return anim:find("_loop_tall")end, target)
            end
            return true
        end
    },
    PICK = {
        chs = "Pick",
        hover = "Pick berries from saplings",
        type = "scene",
    },
    PICKUP = {
        chs = "Pickup",
        hover = "Pick up dropped items",
        type = "scene",
    },
    DIG = {
        chs = "Dig",
        hover = "Dig up tree stumps",
        type = "equip",
        check = function(target)
            return target:HasTag("stump")
        end
    },
    FERTILIZE = {
        chs = "Fertilize",
        hover = "Fertilize withered plants",
        type = "useitem",
        check = function(target)
            return target:HasTag("witherable")
        end
    },
    TAKEITEM = {
        chs = "Take",
        hover = "Take meat from carnivorous plants",
        type = "scene",
    },
    MINE = {
        chs = "Mine",
        hover = "Mine ore",
        type = "equip",
        check = function(target)
            if target.prefab == "marbleshrub" then
                return e_util:IsAnim({"idle_tall", "hit_tall"}, target)
            end
            return true
        end
    },
}
t_util:Pairs(data_act, function(act)
    default_data[act] = true
end)
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local function Say(str)
    u_util:Say(str_auto, str, nil, nil, true)
    return true
end
local function CheckAct(act, target, item)
    local info = act and data_act[act.action.id]
    return info and (not info.check or info.check(target, item))
end
local ent_highlight
local function func_left()
    local pusher = ThePlayer and ThePlayer.components.hx_pusher
    if not pusher then return end
    if pusher:GetNowTask() then
        return pusher:StopNowTask()
    end
    Say("Started")
    local hrange = SpawnPrefab("hrange"):SetVisable(save_data.showrange):SetRadius(save_data.range):SetColor(save_data.color)
    local pos_core = ThePlayer:GetPosition()
    hrange.Transform:SetPosition(pos_core:Get())
    pusher:RegNowTask(function(player, pc)
        if p_util:GetActiveItem() then
            return Say("Inventory full")
        end
        local items = p_util:GetItemsFromAll(nil, nil, function(tool)
            return e_util:GetPercent(tool) > 0 
        end, {"equip", "mouse", "container", "backpack", "body"})
        local codes = {}
        t_util:Pairs(data_act, function(act, data)
            if save_data[act] then
                local tp = data.type
                if codes[tp] then
                    table.insert(codes[tp], act)
                else
                    codes[tp] = {act}
                end
            end
        end)
        local data
        if e_util:FindEnt(nil, nil, 2*save_data.range, nil, nil, nil, nil, function(ent)
            
            if table.contains(save_data.prefabs, ent.prefab) then return end

            
            local dist = c_util:GetDist(pos_core.x, pos_core.z, ent:GetPosition().x, ent:GetPosition().z)
            if dist > save_data.range then return end

            data = t_util:IGetElement(items or {}, function(item)
                local act_equip = e_util:GetItemEquipSlot(item) == "hands" and (p_util:GetAction("equip", codes.equip, nil, item, ent) or p_util:GetAction("equip", codes.equip, true, item, ent))
                if CheckAct(act_equip, ent, item) then
                    return {act = act_equip, item = item, target = ent, type = "equip"}
                else
                    local act_use = p_util:GetAction("useitem", codes.useitem, nil, item, ent)
                    if CheckAct(act_use, ent, item) then
                        return {act = act_use, item = item, target = ent, type = "useitem"}
                    else
                        local act_scene = p_util:GetAction("scene", codes.scene, nil, ent)
                        return CheckAct(act_scene, ent, item) and {act = act_scene, target = ent, type = "scene"}
                    end
                end
            end)
            return data
        end) then
            
            if ent_highlight ~= data.target then
                if e_util:IsValid(ent_highlight) then
                    h_util.SetAddColor(ent_highlight)
                end
                ent_highlight = data.target
                h_util.SetAddColor(ent_highlight, "DarkSilver")
            end
            if data.type == "equip" then
                d_util:TabEquipTarget(data.target, data.item, data.act.action.id)
            elseif data.type == "useitem" then
                d_util:SpaceUseitem(data.item, data.target, data.act.action.id)
            else
                d_util:SpaceScene(data.target, data.act.action.id)
            end
        else
            if e_util:IsValid(ent_highlight) then
                h_util.SetAddColor(ent_highlight)
            end
            d_util:Wait(.5)
            
        end
        d_util:Wait()
    end, function()
        if e_util:IsValid(hrange) then
            hrange:Remove()
            hrange = nil
        end
        if e_util:IsValid(ent_highlight) then
            h_util.SetAddColor(ent_highlight)
            ent_highlight = nil
        end
        u_util:Say(str_auto, "Stopped")
    end)
end

local fn_show, fn_text = r_util:InitPack(save_data, fn_get, fn_save, func_left, "tostart_key")
local screen_data = {{
        id = "tostart_key",
        label = "Hotkey:",
        hover = "Extra bind key for [Auto Work]\nYou can also left-click the panel button to start",
        type = "textbtn",
        default = fn_show,
        fn = fn_text("tostart_key", str_auto),
    },{
        id = "showrange",
        label = "Range indicator",
        hover = "Whether to visualize the work range",
        default = fn_get,
        fn = fn_save("showrange"),
    },{
        id = "range",
        label = "Range:",
        hover = "The working range for auto work",
        default = fn_get,
        fn = fn_save("range"),
        type = "radio",
        data = t_util:BuildNumInsert(2, 60, 2, function(i)
            return {data = i, description = i.." walls"}
        end)
    },{
        id = "color",
        label = "Range color:",
        hover = "The color for the work range indicator",
        default = fn_get,
        fn = fn_save("color"),
        type = "radio",
        data = (require "data/valuetable").WRGB_datatable,
    },{
        id = "list_self",
        label = "Filtered item list",
        hover = "Items in the list will not be auto worked",
        prefab = logo,
        type = "imgstr",
        fn = m_util:AddBindShowScreen{
            title = "Custom filter list",
            id = "list_self",
            data = m_util:FuncListRemove(save_data, "prefabs", fn_save, function(name)
                return "Filter: "..name
            end, "Are you sure you want to filter this item?", function(name, prefab)
                return "Item code: " .. prefab .. "\nClick to remove from list!"
            end, "This item is a mod item and cannot display an icon\nClick to remove from list!"),
            fn_active = true,
            dontpop = true,
            icon = {{
                id = "add",
                prefab = "mods",
                hover = "Click to add an item that should not be auto worked",
                fn = m_util:FuncListAdd(save_data, fn_save, "prefabs", "Item filter", "Item"),
            },{
                id = "reset_repair",
                prefab = "revert2",
                hover = "Click to reset the auto filter item list",
                fn = m_util:FuncListReset(save_data, default_data, fn_save, "Are you sure you want to reset the auto filter item list?", "prefabs"),
            }}
    },}
}

t_util:Pairs(data_act, function(act, data)
    table.insert(screen_data, {
        id = act,
        label = data.chs,
        hover = "Action support:\n"..data.hover,
        default = fn_get,
        fn = fn_save(act),
    })
end)

local func_right = m_util:AddBindShowScreen({
    id = save_id,
    title = str_auto,
    data = screen_data,
    icon = {},
})
m_util:AddBindConf(save_id, func_left, nil, {str_auto, logo , STRINGS.LMB .. ' Start/Stop ' .. STRINGS.RMB .. ' Advanced settings'
, true, func_left, func_right, -2026}, modname)