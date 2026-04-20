local id_per_last, logo = "_repair_lastperc", "orangeamulet"
local save_id, str_show = "sw_hjsl_repair", "Auto Repair"
local default_data = {
    sw = true,
    list = {
        lantern = {num = 25, ing = {"lightbulb"}},
        lighter = {num = 25, ing = {"willow_ember"}},
        minerhat = {num = 25, ing = {"lightbulb"}},
        molehat = {num = 25, ing = {"wormlight_lesser", "wormlight"}},
        thurible = {num = 25, ing = {"nightmarefuel"}},
        armorskeleton = {num = 25, ing = {"nightmarefuel"}},
        orangeamulet = {num = 25, ing = {"nightmarefuel"}},
        yellowamulet = {num = 25, ing = {"nightmarefuel"}},
        waxwelljournal = {num = 25, ing = {"nightmarefuel"}, force = true},
        pocketwatch_weapon = {num = 12, ing = {"nightmarefuel"}},
    }
}

local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)

local function RepairNow(item, items)
    local data = t_util:IGetElement(items, function(useitem)
        if item == useitem then return end
        
        
        local act = p_util:GetAction("useitem", nil, true, useitem, item)
        return act and act.action and { act = act, useitem = useitem }
    end)
    if data then
        p_util:DoAction(data.act, RPC.ControllerUseItemOnItemFromInvTile, data.act.action.code, item, data.useitem, data.act.action.mod_name)
    end
end



local Lock = {}
local function TryAutoRepair(item, per_now)
    local prefab = item and item.prefab
    local line = prefab and save_data.list[prefab] or {}
    per_now = per_now or e_util:GetPercent(item)
    if type(line) == "table" and type(line.num)=="number" and line.num >= per_now then
        local items = p_util:GetItemsFromAll(line.ing or {}) or {}
        if items[1] then
            RepairNow(item, items)
            if line.force and not Lock[item] then
                Lock[item] = true
                e_util:WaitToDo(item, 1, 10, function()
                    if e_util:GetPercent(item) > per_now then
                        return true
                    end
                    RepairNow(item, items)
                end, function()
                    m_util:print("Repair successful!")
                    Lock[item] = nil
                end, function()
                    m_util:print("Repair failed, abort!")
                    Lock[item] = nil
                end)
            end
        end
    end
end

local function listen_repair(item)
    
    local per_now = e_util:GetPercent(item)
    local per_last = item[id_per_last]
    
    if save_data.sw and type(per_last) == "number" and per_last > per_now then
        TryAutoRepair(item, per_now)
    end
    item[id_per_last] = per_now
end
i_util:AddPlayerActivatedFunc(function(player, world, pusher)
    
    pusher:RegAddInv(function(cont, slot, item)
        e_util:SetBindEvent(item, "percentusedchange", listen_repair)
        item[id_per_last] = e_util:GetPercent(item)
    end)
    pusher:RegDeleteInv(function(cont, slot, item)
        item:RemoveEventCallback("percentusedchange", listen_repair)
    end)
end)

local function fn_item(prefab)
    h_util:CreateWriteWithClose("Please enter durability percentage (1-100):", {
        text = "Confirm",
        cb = function(str)
            local num = tonumber(str)
            if num and num >= 1 and num <= 100 and num % 1 == 0 then
                if not save_data.list[prefab] then
                    save_data.list[prefab] = {num = num, ing = {"nightmarefuel"}}
                else
                    save_data.list[prefab].num = num
                end
                fn_save()
            else
                h_util:CreatePopupWithClose("Invalid input", "Please enter an integer from 1 to 100.")
            end
        end
    })
end

local function fn_add()
    m_util:PushPrefabScreen{
        text_title = "Select item to auto repair",
        text_btnok = "Add item",
        hover_btnok = "Add this item to "..str_show.." list",
        fn_btnok = function(prefab)
            if save_data.list[prefab] then
                h_util:CreatePopupWithClose("Duplicate add", "This item is already in the "..str_show.." list.\nPlease add another item.")
            else
                
                save_data.list[prefab] = {num = 5, ing = {"nightmarefuel"}}
                fn_save()
            end
        end,
    }
end
local function fn_ing(info, name_item)
    return function()
        local line = save_data.list[info.prefab] or {}
        local num = line.num or 5
        local list_per = {
            {
                id = "setitempercent",
                type = "textbtn",
                label = "Repair durability:",
                hover = "Below or equal to this durability, subsequent materials will be used to repair\n"..STRINGS.LMB.."Modify durability",
                default = num.."%",
                fn = function()
                    fn_item(info.prefab)
                end
            },{
                id = "force",
                type = "box",
                label = "Force repair",
                hover = "Force repair this item?\n(If currently controlled by another action, keep trying to repair.)",
                default = line.force,
                fn = function(val)
                    line.force = val
                    fn_save()
                end
            }
        }
        local list_ing = t_util:IPairFilter(line.ing or {}, function(prefab)
            local name = e_util:GetPrefabName(prefab)
            local label = name == e_util.NullName and prefab or name
            local data = {}
            if h_util:GetPrefabAsset(prefab) then
                data.type = "imgstr"
                data.prefab = prefab
                data.label = label
            else
                data.type = "textbtn"
                data.label = "Unknown material:"
                data.default = label
            end
            return t_util:MergeMap({
                id = prefab,
                hover = "Item code: " .. prefab .. "\n"..STRINGS.LMB.."Stop using this material to repair "..name_item,
                fn = function()
                    h_util:CreatePopupWithClose(str_show, "Are you sure you no longer want to use " .. label .. " to repair "..name_item.."?",
                        {{
                            text = h_util.no
                        }, {
                            text = h_util.yes,
                            cb = function()
                                local line = save_data.list[info.prefab]
                                local ings = line and line.ing or {}
                                t_util:Sub(ings, prefab)
                                fn_save()
                            end
                        }})
                end
            }, data)
        end)
        return t_util:MergeList(list_per, list_ing)
    end
end
local function fn_ing_add(info, name_item)
    return function()
        m_util:PushPrefabScreen{
            text_title = "Select material to repair "..name_item,
            text_btnok = "Add material",
            hover_btnok = "Use this material to repair "..name_item,
            fn_btnok = function(prefab)
                local line = save_data.list[info.prefab] or {}
                local ing = line.ing or {}
                if table.contains(ing, prefab) then
                    h_util:CreatePopupWithClose("Duplicate item", "This material is already added, please choose another one.")
                else
                    t_util:Add(ing, prefab)
                    fn_save()
                end
            end
        }
    end
end
local function fn_remove(prefab, name, num)
    return function()
        h_util:CreatePopupWithClose(str_show.."："..name, "Are you sure you want to stop auto-repairing this item?\n(Auto repair triggers when durability is at or below "..num.."%.)", {{
                text = h_util.no
            }, {
                text = "Confirm remove",
                cb = function()
                    save_data.list[prefab] = nil
                    fn_save()
                    TheFrontEnd:PopScreen()
                end
            }})
    end
end

local function fn_list()
    
    local pdata = t_util:PairToIPair(save_data.list, function(prefab, line)
        return type(line) == "table" and {prefab = prefab, num = line.num, ing = line.ing}
    end)
    table.sort(pdata, function(a, b)
        return a.num < b.num
    end)
    return t_util:IPairToIPair(pdata, function(info)
        local prefab = info.prefab
        local name = e_util:GetPrefabName(prefab)
        name = name == e_util.NullName and prefab or name
        local data = {id = prefab, fn = m_util:AddBindShowScreen{
            title = name.." Materials",
            id = save_id.."_"..prefab,
            data = fn_ing(info, name),
            help = "Use the listed materials to repair this item when durability falls to or below the set value.\nClick the wrench icon to add materials and the broom icon to remove auto-repair for this item.",
            fn_active = true,
            dontpop = true,
            icon = {{
                id = "remove",
                prefab = "clean_all",
                hover = "Remove this item!",
                fn = fn_remove(prefab, name, info.num),
            },{
                id = "add",
                prefab = "mods",
                hover = "Add repair material",
                fn = fn_ing_add(info, name),
            }}
        }}
        local str = c_util:TruncateChineseString(info.num.."% "..name, 10)
        if h_util:GetPrefabAsset(prefab) then
            data.type = "imgstr"
            data.label = str
            data.hover = "Item code: " .. prefab .. "\nClick to modify settings!"
            data.prefab = prefab
        else
            data.type = "textbtn"
            data.default = str
            data.label = "Mod item:"
            data.hover = "This is a mod item and cannot display an icon.".."\nClick to modify settings!"
        end
        return data
    end)
end

local screen_data = {{
    id = "sw",
    label = "Master switch",
    fn = fn_save("sw"),
    hover = "Master switch for auto-repair",
    default = fn_get
}, {
        id = "bilibili",
        prefab = "bilibili",
        type = "imgstr",
        label = "Tutorial demo",
        hover = "Click to view video tutorial or feature demo",
        fn = function()VisitURL("https://www.bilibili.com/video/BV1czygBkENd/", true)end
    },{
    id = "reset",
    type = "imgstr",
    prefab = "moonrockseed",
    hover = "Restore default item list",
    label = "Reset item list",
    fn = function()
        h_util:CreatePopupWithClose("Warning",
            "Are you sure you want to restore the default item list?\nThis will overwrite your current settings!", {{
                text = h_util.no
            }, {
                text = h_util.yes,
                cb = function()
                    
                    save_data.list = {}
                    t_util:EasyCopy(save_data.list, default_data.list)
                    fn_save()
                    h_util:PlaySound("learn_map")
                end
            }})
    end
}, {
    id = "list",
    type = "imgstr",
    prefab = logo,
    hover = STRINGS.LMB .. "View repair list",
    label = "Configure repair items",
    fn = m_util:AddBindShowScreen{
        title = "Auto Repair List",
        id = save_id .. "_list",
        data = fn_list,
        help = "When durability falls to or below the set value, the item is auto-repaired.\nClick the wrench icon to add items and click the item name below to view advanced settings for that item.",
        fn_active = true,
        dontpop = true,
        icon = {{
            id = "add",
            prefab = "mods",
            hover = "Click to add an item for auto-repair!",
            fn = fn_add,
        }}
    }
}}

m_util:AddBindShowScreen(save_id, str_show, logo, str_show.." Settings", {
    title = str_show,
    id = save_id,
    data = screen_data,
    icon = {{
        id = "thanks",
        prefab = "abigail_flower_handmedown",
        hover = "Special thanks",
        fn = function()
            h_util:CreatePopupWithClose("󰀍 Special thanks 󰀍", 'This feature was commissioned by sponsor "花间随柳".', {{text = "󰀍"}})
        end
    }}
}, nil, 8000.8)

Mod_ShroomMilk.Func.TryAutoRepair = TryAutoRepair