
local save_id, str_show, logo = "sw_drop", "Quick drop", "boomerang_bandedwood"
local prefab_umb = "voidcloth_umbrella"
local default_data = {
    sw = m_util:IsHuxi(),
    todrop_key = 122,
    sculp = true,
    range = 4,
    list_drop = {
        {prefab = prefab_umb, find = false, num = 1},
        {prefab = "canary_poisoned", find = true, prefabs = {"toadstool_cap"}, num = 1},
        {prefab = "birdtrap", find = false, prefabs = {}, num = 1},
        {prefab = "seeds", find = true, prefabs = {"birdtrap"}, num = 1},
        {prefab = "heatrock", find = true, prefabs = {"dragonflyfurnace", "stafflight", "staffcoldlight","moonbase","fire","lava_pond"}, num = 1},
        {prefab = "trap", find = true, prefabs = {"rabbithole", "rabbit"}, num = 1},
        {prefab = "lantern", find = false, prefabs = {}, num = 1},
        {prefab = "lightbulb", find = false, prefabs = {}, num = 1},
        {prefab = "thurible", find = true, prefabs = {"stalker_atrium", "stalker_forest", "stalker"}, num = 1},
    },
    umb = true,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)

local function fn_item()
    if save_data.sculp then
        local item = t_util:GetElement(p_util:GetEquips() or {}, function(_, it)
            return it and it:HasTag("heavy") and it
        end)
        if item then
            return {item = item, num = 1}
        end
    end
    local prefabs = t_util:IPairFilter(save_data.list_drop, function(data)
        return data.prefab
    end)
    local data = p_util:GetSlotsFromAll(prefabs) or {}
    return t_util:IGetElement(save_data.list_drop, function(dropdata)
        local prefab = dropdata.prefab
        local line = t_util:IGetElement(data, function(line)
            return line.item.prefab == prefab and line
        end)
        if line then
            if not dropdata.find or e_util:FindEnt(nil, dropdata.prefabs or {}, save_data.range, nil, {'INLIMBO', 'player'}) then
                return t_util:MergeMap(line, {num = dropdata.num})
            end
        end
    end)
end

local function fn_press()
    if not save_data.sw then return end
    local data = fn_item()
    if not data then return end
    if data.num == 1 then
        p_util:DropItemFromInvTile(data.item, true)
    elseif data.num == 0 then
        p_util:DropItemFromInvTile(data.item)
    elseif type(data.num) == "number" then
        p_util:TakeActiveItemFromCountOfSlot(data.cont, data.slot, data.num)
        e_util:WaitToDo(ThePlayer, .1, 10, function()
            return p_util:GetActiveItem(data.item.prefab)
        end, function()
            local item_active = p_util:GetActiveItem()
            if item_active then
                local pos = ThePlayer:GetPosition()
                local act = BufferedAction(ThePlayer, nil, ACTIONS.DROP, item_active, pos)
                act.options.wholestack = true
                p_util:DoAction(act, RPC.LeftClick, act.action.code, pos.x, pos.z, nil, true)
            end
        end)
    end
    if data.item.prefab == prefab_umb and save_data.umb then
        e_util:WaitToDo(ThePlayer, .1, 10, function()
            return e_util:FindEnt(nil, prefab_umb, 1)
        end, function(umb)
            local act, right = p_util:GetMouseActionSoft({"TURNON"}, umb)
            if act then
                p_util:DoMouseAction(act, right)
            end
        end)
    end
end

local screen_data = {
    {
        id = "sw",
        label = "Master switch",
        hover = "Master switch for Quick drop",
        default = fn_get,
        fn = fn_save("sw"),
    },r_util:ScreenPack(save_data, fn_get, fn_save, fn_press, "todrop_key", "Quick drop"),{
        id = "range",
        label = "Check range:",
        hover = "Search surrounding item range to drop only when specified entities exist nearby",
        type = "radio",
        default = fn_get,
        fn = fn_save("range"),
        data = t_util:BuildNumInsert(1, 20, 1, function(i)
            return {data = i, description = i.." walls"}
        end)
    },
    {
        id = "sculp",
        label = "Drop statues",
        hover = "Drop statues by key when carrying heavy items",
        default = fn_get,
        fn = fn_save("sculp"),
    },{
        id = "umb",
        label = "Open shadow umbrella",
        hover = "Automatically open the dropped shadow umbrella",
        default = fn_get,
        fn = fn_save("umb"),
    },{
        id = "reset",
        type = "imgstr",
        label = "Reset list",
        prefab = logo,
        hover = "Click to reset key drop items!",
        fn = function()
            h_util:CreatePopupWithClose("Warning", "Are you sure you want to reset the key drop item list?\nThis cannot be undone!", {
                {
                    text = h_util.no,
                },{
                    text = h_util.yes,
                    cb = function()
                        
                        save_data.list_drop = {}
                        t_util:EasyCopy(save_data.list_drop, default_data.list_drop)
                        fn_save()
                        h_util:PlaySound("learn_map")
                    end
                }
            })
        end
    },
}
local function fn_prefab_data(data_drop)
    return function()
        local ret1 = {
            {
                id = "num",
                label = "Drop quantity:",
                hover = "Dropping one or a whole stack drops directly,\nother amounts will be held on the cursor before dropping.",
                type = "radio",
                default = data_drop.num or 0,
                data = t_util:BuildNumInsert(0, 40, 1, function(i)
                    if i == 0 then
                        return {data = i, description = "Drop whole stack"}
                    elseif i == 1 then
                        return {data = i, description = "Drop single"}
                    else
                        return {data = i, description = i.." items"}
                    end
                end),
                fn = function(value)
                    data_drop.num = value
                    fn_save()
                end
            },{
                id = "find",
                label = "Range check",
                hover = "Enable: drop only when specified nearby items exist.\nDisable: drop directly.",
                default = data_drop.find,
                fn = function(value)
                    data_drop.find = value
                    fn_save()
                end
            }
        }
        local ret2 = t_util:IPairFilter(data_drop.prefabs or {}, function(prefab)
            local name = e_util:GetPrefabName(prefab)
            name = name == e_util.NullName and prefab or name
            local data = {
                id = prefab, 
                fn = function()
                    h_util:CreatePopupWithClose(str_show.."："..name, "Are you sure you want to stop checking this item during range checks?", {{
                        text = h_util.no
                    }, {
                        text = "Confirm removal",
                        cb = function()
                            t_util:Sub(data_drop.prefabs or {}, prefab)
                            fn_save()
                        end
                    }})
                end
            }
            local str = c_util:TruncateChineseString(name, 10)
            if h_util:GetPrefabAsset(prefab) then
                data.type = "imgstr"
                data.label = str
                data.hover = "Item code: " .. prefab .. "\nClick to remove this item!"
                data.prefab = prefab
            else
                data.type = "textbtn"
                data.default = str
                data.label = "Mod item:"
                data.hover = "This is a mod item and cannot display an icon.".."\nClick to remove this item!"
            end
            return data
        end)
        return t_util:MergeList(ret1, ret2)
    end
end

local function fn_remove(prefab, name)
    return function()
        h_util:CreatePopupWithClose(str_show.."："..name, "Are you sure you want to stop dropping this item by key?", {{
            text = h_util.no
        }, {
            text = "Confirm remove",
            cb = function()
                save_data.list_drop = t_util:IPairFilter(save_data.list_drop, function(data_drop)
                    return data_drop.prefab ~= prefab and data_drop
                end)
                fn_save()
                TheFrontEnd:PopScreen()
            end
        }})
    end
end
local function fn_ing_add(data_drop, name_item)
    return function()
        m_util:PushPrefabScreen{
            text_title = "Select items for range check when dropping "..name_item,
            text_btnok = "Add item",
            hover_btnok = "Check this item before dropping",
            fn_btnok = function(prefab)
                if table.contains(data_drop.prefabs or {}, prefab) then
                    h_util:CreatePopupWithClose("Duplicate add", "This item is already on the list, please add another item.")
                else
                    t_util:Add(data_drop.prefabs, prefab, true)
                    fn_save()
                end
            end
        }
    end
end

local function fn_get_screen_data()
    local ui_data = t_util:IPairFilter(save_data.list_drop, function(data_drop)
        local prefab = data_drop.prefab
        local name = e_util:GetPrefabName(prefab)
        name = name == e_util.NullName and prefab or name
        local data = {
            id = prefab, 
            fn = m_util:AddBindShowScreen{
                id = save_id.."_"..prefab,
                title = str_show.." "..name,
                help = "When range check is disabled: drop directly.\nWhen range check is enabled: drop only if specified items are within range.",
                data = fn_prefab_data(data_drop),
                fn_active = true,
                dontpop = true,
                icon = {
                    {
                        id = "remove",
                        prefab = "clean_all",
                        hover = "Remove this item!",
                        fn = fn_remove(prefab, name),
                    },{
                        id = "add",
                        prefab = "mods",
                        hover = "Add range check item",
                        fn = fn_ing_add(data_drop, name),
                    }
                },
            }
        }
        local str = c_util:TruncateChineseString(name, 10)
        if h_util:GetPrefabAsset(prefab) then
            data.type = "imgstr"
            data.label = str
            data.hover = "Item code: " .. prefab .. "\nClick to configure this item!"
            data.prefab = prefab
        else
            data.type = "textbtn"
            data.default = str
            data.label = "Mod item:"
            data.hover = "This is a mod item and cannot display an icon.".."\nClick to configure this item!"
        end
        return data
    end)

    return t_util:MergeList(screen_data, ui_data)
end

local function fn_add()
    return m_util:PushPrefabScreen{
        text_title = "Select items to drop by key",
        text_btnok = "Add item",
        hover_btnok = "Drop this item by key",
        fn_btnok = function(prefab)
            if t_util:IGetElement(save_data.list_drop, function(data)
                return data.prefab == prefab
            end) then
                h_util:CreatePopupWithClose("Duplicate add", "This item is already on the list, please add another item.")
            else
                t_util:Add(save_data.list_drop, {prefab = prefab, find = false, prefabs = {}, num = 0}, true)
                fn_save()
            end
        end
    }
end

m_util:AddBindShowScreen(save_id, str_show, logo, str_show.." Settings", {
    title = str_show,
    id = save_id,
    data = fn_get_screen_data,
    icon = {{
        id = "thanks",
        prefab = "abigail_flower_handmedown",
        hover = "Special thanks",
        fn = function()
            h_util:CreatePopupWithClose("󰀬 Special thanks 󰀬", 'The Quick drop feature was customized by player "隔壁の老怂".\n\nMessage: "Stay away! 隔壁の老怂~~" "I am opening fire!"', {{text = "󰀬"}})
        end,
    },{
        id = "add",
        prefab = "mods",
        hover = "Add item for key drop",
        fn = fn_add,
    }},
    help = "First bind a key. Items will be dropped in order by condition.\nDropping one item or a whole stack drops directly, but other amounts require freeing the cursor.",
    fn_active = true,
}, nil, 8000.6)