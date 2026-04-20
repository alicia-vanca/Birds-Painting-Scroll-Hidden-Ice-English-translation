local id_per_last, logo = "_unequip_lastperc", "yellowamulet"
local save_id, str_show = "sw_hjsl_unequip", "Auto Unequip"
local list_one = {"molehat", "featherhat", "tophat", "walterhat", "goggleshat", "deserthat", "moonstorm_goggleshat",
                  "catcoonhat", "earmuffshat", "winterhat", "walrushat", "beefalohat", "strawhat", "eyebrellahat",
                  "trunkvest_summer", "raincoat", "sweatervest", "trunkvest_winter", "beargervest", "armorslurper",
                  "carnival_vest_b", "carnival_vest_c", "monkey_mediumhat", "monkey_smallhat", "antlionhat",
                  "nightcaphat"}
local default_data = {
    color_say = "Pink",
    sw = true,
    list = {
        eyemaskhat = 12,
        shieldofterror = 12,
        armordreadstone = 6,
        dreadstonehat = 6,
        orangeamulet = 3,
        yellowamulet = 3,
        shadow_battleaxe = 3
    }
}
t_util:IPairs(list_one, function(prefab)
    default_data.list[prefab] = 1
end)

local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)

local function NeedAutoUnEquip(equip)
    local prefab = equip and equip.prefab
    local per_now = e_util:GetPercent(equip)
    if save_data.sw and prefab and per_now then
        local per_num = save_data.list[prefab]
        return type(per_num) == "number" and per_num >= per_now and equip
    end
end
i_util:AddPlayerActivatedFunc(function(player, world, pusher)
    
    local function listen_unequip(equip)
        local slot = e_util:GetItemEquipSlot(equip)
        
        local per_now = e_util:GetPercent(equip)
        if slot and p_util:GetEquip(slot) == equip then
            local per_last = equip[id_per_last]
            local prefab = equip.prefab
            
            if type(per_last) == "number" and per_last > per_now then
                if NeedAutoUnEquip(equip) then
                    p_util:UnEquip(equip)
                    local slot = e_util:GetItemEquipSlot(equip)
                    e_util:WaitToDo(player, 0.1, 20, function()
                        if equip == p_util:GetEquip(slot) then
                            p_util:UnEquip(equip)
                        else
                            return true
                        end
                    end)
                    u_util:Say(str_show, equip.name, nil, save_data.color_say)
                end
            end
        end
        equip[id_per_last] = per_now
    end
    
    pusher:RegEquip(function(_, equip)
        e_util:SetBindEvent(equip, "percentusedchange", listen_unequip)
        equip[id_per_last] = e_util:GetPercent(equip)
    end)
end)

local function fn_equip(prefab)
    h_util:CreateWriteWithClose("Please enter durability percent (1-100):", {
        text = "Confirm",
        cb = function(str)
            local num = tonumber(str)
            if num and num >= 1 and num <= 100 and num % 1 == 0 then
                save_data.list[prefab] = num
                fn_save()
            else
                h_util:CreatePopupWithClose("Invalid", "Please enter an integer between 1 and 100.")
            end
        end
    })
end

local function fn_add()
    m_util:PushPrefabScreen{
        text_title = "Select equipment to auto unequip",
        text_btnok = "Set durability",
        hover_btnok = "Add this equipment to the "..str_show.." list",
        fn_btnok = function(prefab)
            if save_data.list[prefab] then
                h_util:CreatePopupWithClose("Duplicate", "This equipment is already in the "..str_show.." list.\nPlease add another equipment.")
            else
                fn_equip(prefab)
            end
        end,
    }
end

local function fn_list()
    
    local pdata = t_util:PairToIPair(save_data.list, function(prefab, num)
        return type(num) == "number" and {prefab = prefab, num = num}
    end)
    table.sort(pdata, function(a, b)
        return a.num > b.num
    end)
    return t_util:IPairToIPair(pdata, function(info)
        local prefab = info.prefab
        local name = e_util:GetPrefabName(prefab)
        name = name == e_util.NullName and prefab or name
        local data = {id = prefab, fn = function()
            h_util:CreatePopupWithClose(str_show..":"..name, "Are you sure you want to remove auto unequip for this equipment?\n(Currently auto unequips when durability is less than or equal to "..info.num.."%)", {{
                text = h_util.no
            }, {
                text = "Change durability",
                cb = function()
                    i_util:DoTaskInTime(0, function()
                        fn_equip(prefab)
                    end)
                end
            }, {
                text = "Confirm removal",
                cb = function()
                    save_data.list[prefab] = nil
                    fn_save()
                end
            }})
        end}
        local str = c_util:TruncateChineseString(info.num.."% "..name, 10)
        if h_util:GetPrefabAsset(prefab) then
            data.type = "imgstr"
            data.label = str
            data.hover = "Prefab code: " .. prefab .. "\nClick to modify settings!"
            data.prefab = prefab
        else
            data.type = "textbtn"
            data.default = str
            data.label = "Mod Equipment:"
            data.hover = "This is a mod item and cannot display an icon".."\nClick to modify settings!"
        end
        return data
    end)
end

local screen_data = {{
    id = "sw",
    label = "Master Switch",
    fn = fn_save("sw"),
    hover = "Master switch for auto unequip",
    default = fn_get
}, {
    id = "color_say",
    label = "Text color:",
    fn = fn_save("color_say"),
    hover = "The color of the prompt after auto unequip",
    default = fn_get,
    type = "radio",
    data = require("data/valuetable").RGB_datatable
}, {
    id = "reset",
    type = "imgstr",
    prefab = "moonrockseed",
    hover = "Restore default equipment list",
    label = "Reset equipment list",
    fn = function()
        h_util:CreatePopupWithClose("Warning",
            "Are you sure you want to restore the default auto unequip equipment list?\nThis will overwrite your existing settings!", {{
                text = h_util.no
            }, {
                text = h_util.yes,
                cb = function()
                    
                    save_data.list = t_util:MergeMap(default_data.list)
                    fn_save()
                    h_util:PlaySound("learn_map")
                end
            }})
    end
}, {
    id = "list",
    type = "imgstr",
    prefab = logo,
    hover = STRINGS.LMB .. "View auto unequip equipment list",
    label = "Set auto unequip equipment",
    fn = m_util:AddBindShowScreen{
        title = "Auto Unequip List",
        id = save_id .. "_list",
        data = fn_list,
        help = "When equipment durability is less than or equal to the set value, it will automatically unequip.\nClick the wrench button on the right to add equipment, click the item name below to remove auto unequip for that equipment.",
        fn_active = true,
        dontpop = true,
        icon = {{
            id = "add",
            prefab = "mods",
            hover = "Add equipment to auto unequip!",
            fn = fn_add,
        }}
    }
}}

m_util:AddBindShowScreen(save_id, str_show, logo, "Auto unequip related settings", {
    title = str_show,
    id = save_id,
    data = screen_data,
    icon = {{
        id = "thanks",
        prefab = "abigail_flower_handmedown",
        hover = "Special thanks",
        fn = function()
            h_util:CreatePopupWithClose("󰀍 Special Thanks 󰀍", "This mod feature was commissioned by sponsor 花间随柳.", {{text = "󰀍"}})
        end
    }}
}, nil, 8000.9)

Mod_ShroomMilk.Func.NeedAutoUnEquip = NeedAutoUnEquip
