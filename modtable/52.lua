local save_id, str_show, logo = "sw_newrepair", "Quick Repair", "sewing_kit"
local str_repair = str_show
local default_data = {
    sw = m_util:IsHuxi(),
    torepair_key = 118,
    list_repair = {
        lantern = {num = 80, ing = {"lightbulb"}},
        lighter = {num = 80, ing = {"willow_ember"}},
        minerhat = {num = 80, ing = {"lightbulb"}},
        molehat = {num = 80, ing = {"wormlight_lesser", "wormlight"}},
        thurible = {num = 80, ing = {"nightmarefuel"}},
        armorskeleton = {num = 80, ing = {"nightmarefuel"}},
        orangeamulet = {num = 80, ing = {"nightmarefuel"}},
        yellowamulet = {num = 80, ing = {"nightmarefuel"}},
        waxwelljournal = {num = 80, ing = {"nightmarefuel"}},
        pocketwatch_weapon = {num = 80, ing = {"nightmarefuel"}},
        shieldofterror = {num = 75, ing = {"monstermeat"}},
        eyemaskhat = {num = 75, ing = {"monstermeat"}},
        raincoat = {num = 49, ing = {"sewing_tape", "sewing_kit"}},
        eyebrellahat = {num = 20, ing = {"sewing_tape", "sewing_kit"}},
        walrushat = {num = 80, ing = {"sewing_tape", "sewing_kit"}},
        heatrock = {num = 49, ing = {"sewing_tape", "sewing_kit"}},
    },
    jh_say = true,
    color_say = "Pink",
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local function Say(str1, str2)
    if not save_data.jh_say then return end
    u_util:Say(str1, str2, "head", save_data.color_say, true)
end

local function fn_to_repair()
    
    local items = p_util:GetItemsFromAll(nil, nil, nil, {"equip", "body", "container", "backpack"}) or {}
    local data = t_util:IGetElement(items, function(target)
        local line = save_data.list_repair[target.prefab]
        
        if line and e_util:GetPercent(target) <= line.num then
            return t_util:IGetElement(items, function(useitem)
                if target ~= useitem and table.contains(line.ing or {}, useitem.prefab) then
                    local act = p_util:GetAction("useitem", nil, true, useitem, target)
                    local id = act and act.action and act.action.id
                    local str = act and act.GetActionString and act:GetActionString()
                    return id and str and { act = act, item = useitem, target = target, str = str }
                end
            end)
        end
    end)
    if data then
        p_util:DoAction(data.act, RPC.ControllerUseItemOnItemFromInvTile, data.act.action.code, data.target, data.item, data.act.action.mod_name)
        Say(data.item.name .. " " .. data.str .. " " .. data.target.name, e_util:GetPercent(data.target) .. "%")
        return true
    end
end

local function fn_press()
    if not save_data.sw then return end
    
    if fn_to_repair() then
        return
    end
    Say(str_show, "Completed")
end
local function fn_item(prefab)
    h_util:CreateWriteWithClose("Please enter a durability percentage (1-100):", {
        text = "Confirm",
        cb = function(str)
            local num = tonumber(str)
            if num and num >= 1 and num <= 100 and num % 1 == 0 then
                if save_data.list_repair[prefab] then
                    save_data.list_repair[prefab].num = num
                else
                    save_data.list_repair[prefab] = {num = num, ing = {"nightmarefuel"}}
                end
                fn_save()
            else
                h_util:CreatePopupWithClose("Invalid", "Please enter an integer between 1 and 100.")
            end
        end
    })
end

local function fn_ing(info, name_item)
    return function()
        local line = save_data.list_repair[info.prefab] or {}
        local num = line.num or 5
        local list_per = {
            {
                id = "setitempercent",
                type = "textbtn",
                label = "Repair threshold:",
                hover = "When durability falls below this threshold, the hotkey will use the materials below to repair\n"..STRINGS.LMB.."Modify threshold",
                default = num.."%",
                fn = function()
                    fn_item(info.prefab)
                end
            },
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
                    h_util:CreatePopupWithClose(str_repair, "Are you sure you no longer want to use " .. label .. " to repair "..name_item.."?",
                        {{
                            text = h_util.no
                        }, {
                            text = h_util.yes,
                            cb = function()
                                local line = save_data.list_repair[info.prefab]
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


local function fn_remove(prefab, name, num)
    return function()
        h_util:CreatePopupWithClose(str_repair..": "..name, "Are you sure you want to remove hotkey repair for this item?\n(Currently repairs when durability is at or below "..num.."%.)", {{
                text = h_util.no
            }, {
                text = "Remove",
                cb = function()
                    save_data.list_repair[prefab] = nil
                    fn_save()
                    TheFrontEnd:PopScreen()
                end
            }})
    end
end


local function fn_ing_add(info, name_item)
    return function()
        m_util:PushPrefabScreen{
            text_title = "Select materials to repair "..name_item,
            text_btnok = "Add material",
            hover_btnok = "Use this material for hotkey repair of "..name_item,
            fn_btnok = function(prefab)
                local line = save_data.list_repair[info.prefab] or {}
                local ing = line.ing or {}
                if table.contains(ing, prefab) then
                    h_util:CreatePopupWithClose("Duplicate add", "This material has already been added, please choose another.")
                else
                    t_util:Add(ing, prefab, true)
                    fn_save()
                end
            end
        }
    end
end



local function fn_list_repair()
    
    local pdata = t_util:PairToIPair(save_data.list_repair, function(prefab, line)
        return type(line) == "table" and {prefab = prefab, num = line.num, ing = line.ing}
    end)
    table.sort(pdata, function(a, b) return a.num < b.num end)
    return t_util:IPairToIPair(pdata, function(info)
        local prefab = info.prefab
        local name = e_util:GetPrefabName(prefab)
        name = name == e_util.NullName and prefab or name
        local data = {id = prefab, fn = m_util:AddBindShowScreen{
            title = name.." materials used",
            id = save_id.."_"..prefab,
            data = fn_ing(info, name),
            help = "When item durability is at or below the set value, the hotkey repairs the item using the materials below.\nClick the wrench button on the right to add materials, and the broom button to remove hotkey repair for the item.",
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
            data.hover = "Item code: " .. prefab .. "\nClick to edit settings!"
            data.prefab = prefab
        else
            data.type = "textbtn"
            data.default = str
            data.label = "Mod item:"
            data.hover = "This item is a mod item and cannot display an icon".."\nClick to edit settings!"
        end
        return data
    end)
end


local function fn_add_repair()
    m_util:PushPrefabScreen{
        text_title = "Choose an item for hotkey repair",
        text_btnok = "Add item",
        hover_btnok = "Add this item to the "..str_repair.." list",
        fn_btnok = function(prefab)
            if save_data.list_repair[prefab] then
                h_util:CreatePopupWithClose("Duplicate add", "This item is already in the "..str_repair.." list.\nPlease add another item.")
            else
                
                save_data.list_repair[prefab] = {num = 80, ing = {"nightmarefuel"}}
                fn_save()
            end
        end,
    }
end



local fn_set_repair = m_util:AddBindShowScreen{
    title = "Hotkey Repair List",
    id = "list_repair",
    data = fn_list_repair,
    help = "When item durability is at or below the set value, the hotkey repairs the item.\nClick the wrench button on the right to add items, and click an item name below to view advanced settings.",
    fn_active = true,
    dontpop = true,
    icon = {{
        id = "add_repair",
        prefab = "mods",
        hover = "Click to add an item for hotkey repair!",
        fn = fn_add_repair,
    },{
        id = "reset_repair",
        prefab = "revert2",
        hover = "Click to reset the hotkey repair item list!",
        fn = m_util:FuncListReset(save_data, default_data, fn_save, "Are you sure you want to reset the hotkey repair item list?", "list_repair"),
    }}
}


local screen_data = {
    {
        id = "sw",
        label = "Master switch",
        hover = "Master on/off switch for hotkey repair",
        default = fn_get,
        fn = fn_save("sw"),
    },r_util:ScreenPack(save_data, fn_get, fn_save, fn_press, "torepair_key", "Hotkey Repair"),{
        id = "jh_say",
        label = "Toggle: text prompt",
        hover = "Whether to show action status above the character",
        default = fn_get,
        fn = fn_save("jh_say"),
    },{
        id = "color_say",
        label = "Text color:",
        default = fn_get,
        type = "radio",
        data = require("data/valuetable").RGB_datatable,
        fn = fn_save("color_say"),
    },{
        id = "list_repair",
        type = "imgstr",
        prefab = "sewing_tape",
        hover = STRINGS.LMB .. "View repair item list",
        label = "Settings: repair items",
        fn = fn_set_repair,
    }
}


m_util:AddBindShowScreen(save_id, str_show, logo, str_show.." settings", {
    title = str_show,
    id = save_id,
    data = screen_data,
    icon = {{
        id = "thanks",
        prefab = "abigail_flower_handmedown",
        hover = "Special Thanks",
        fn = function()
            h_util:CreatePopupWithClose("󰀍 Special Thanks 󰀍", "This feature was commissioned by sponsor '69年专业刮痧'.\n\nMessage: Wilderness is blessed.", {{text = "󰀍"}})
        end,
    }},
}, nil, 8000.8)  