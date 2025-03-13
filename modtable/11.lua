-- Item manager
if m_util:IsServer() then return end
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local default_data = {
    ex_re_equip_way = "low",
    uppercent = 80,
    color_say = "Pink",
    ueq_dreadstone = true,
    num_dreadstone = 6,
    ueq_fedbyall = true,
    num_fedbyall = 12,
    ueq_sew = true,
    num_sew = 1,
    ueq_amulet = true,
    num_amulet = 3,
    ueq_shadow_battleaxe = true,
    num_shadow_battleaxe = 3,
    busy_repair = true,
    ueq_watch = true,
    num_watch = 12,
    ueq_ske = true,
    num_ske = 25,
    ueq_else = true,
    num_else = 25,
    horrorfuel = false,
}
local m_data = {
    ex_re_equip = m_util:IsTurnOn("ex_re_equip"),
    ex_re_ammo = m_util:IsTurnOn("ex_re_ammo"),
    auto_unequip = m_util:IsTurnOn("auto_unequip"),
    auto_repair = m_util:IsTurnOn("auto_repair"),
    cd_skeleton = m_util:IsTurnOn("cd_skeleton"),
    sw_skeleton = m_util:IsTurnOn("sw_skeleton"),
    text_cd = m_util:IsTurnOn("text_cd"),
}
local save_id = "sw_explorer"
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local fn_moddata = function(id) return m_data[id] end
local dontuseitem = {"lunarplant_kit", "voidcloth_kit" } -- Don't add it as a fuel
local feed_useitem = { "monstermeat", "spoiled_food", "rock_avocado_fruit_ripe" }
local feed_target = { "eyemaskhat", "shieldofterror" }
local rpcodes = { "ADDWETFUEL", "ADDFUEL", "SEW", "REPAIR_BONE", "REPAIRCOMMON", "REPAIR", "FEED" }
local dontunequip = { "piratepack", "pocketwatch_weapon","ndnr_armorvortexcloak","backcub" } -- Do not fall off automatically
local id_per_last = "_huxi_lastperc"
local id_charge_cd, id_charge_start, id_charge_func = "_huxi_id_charge_cd", "_huxi_id_charge_start", "_huxi_id_charge_func"

if not save_data.horrorfuel then
    t_util:Add(dontuseitem, "horrorfuel")
end

-- Key repair
local function fn_manu()
    local items = p_util:GetItemsFromAll(nil, nil, nil, { "equip", "body", "container", "backpack" }) or {}
    local data = t_util:IGetElement(items, function(target)
        if e_util:GetPercent(target) > save_data.uppercent then return end
        return t_util:IGetElement(items, function(useitem)
            if target == useitem or table.contains(dontuseitem, useitem.prefab) then return end
            local act = p_util:GetAction("useitem", rpcodes, true, useitem, target)
            local id = act and act.action and act.action.id
            local str = act and act.GetActionString and act:GetActionString()
            if not id or not str then return end
            -- Special treatment: monster meat and rotten foods for eye masks and shields can be repaired
            if id == "FEED" and not (table.contains(feed_useitem, useitem.prefab) and table.contains(feed_target, target.prefab)) then return end
            return { act = act, item = useitem, target = target, str = str }
        end)
    end)
    if data then
        local str, item, target = data.str, data.item, data.target
        p_util:DoAction(data.act, RPC.ControllerUseItemOnItemFromInvTile, data.act.action.code, target, item, data.act.action.mod_name)
        u_util:Say(item.name .. " " .. str .. " " .. target.name, e_util:GetPercent(target) .. "%", "head",
            save_data.color_say)
    else
        u_util:Say("Fast repair", "Complete", "head", save_data.color_say, true)
    end
end

local function AutoRepair(equip)
    local items = p_util:GetItemsFromAll() or {}
    local data = t_util:IGetElement(items, function(useitem)
        if equip == useitem or table.contains(dontuseitem, useitem.prefab) then return end
        local act = p_util:GetAction("useitem", { "ADDWETFUEL", "ADDFUEL", "REPAIR"}, true, useitem, equip)
        local str = act and act.GetActionString and act:GetActionString()
        return act and act.action and str and { act = act, str = str, item = useitem }
    end)
    if data then
        p_util:DoAction(data.act, RPC.ControllerUseItemOnItemFromInvTile, data.act.action.code, equip, data.item)
    end
end


local function SetCharge(equip, cooldown)
    local func, start, cd = equip[id_charge_func], equip[id_charge_start] or 0, equip[id_charge_cd] or TUNING.ARMOR_SKELETON_COOLDOWN
    if func then
        local now = GetTime()
        local cd_left = start + cd - now
        cooldown = cooldown or TUNING.ARMOR_SKELETON_COOLDOWN
        if cooldown > cd_left then
            func(cooldown, cooldown)
            equip[id_charge_start], equip[id_charge_cd] = now, cooldown
        else
            func(cd, cd_left)
        end
    end
end

local function NeedAutoUnEquip(equip)
    local prefab = equip and equip.prefab
    local per_now = e_util:GetPercent(equip)
    if m_data.auto_unequip and prefab and per_now then
        if (equip:HasTag("dreadstone") and save_data.ueq_dreadstone and save_data.num_dreadstone >= per_now)                                                                -- Despair
            or (equip:HasTag("fedbyall") and save_data.ueq_fedbyall and save_data.num_fedbyall >= per_now)                                                                  -- Feeding equipment
            or (equip:HasOneOfTags({ "repairable_nightmare", "NIGHTMARE_fueled" }) and not equip:HasTag("fossil") and save_data.ueq_amulet and save_data.num_amulet >= per_now) --Amulet
            or (equip:HasTag("needssewing") and save_data.ueq_sew and save_data.num_sew >= per_now)                                                                         -- Repairable equipment
            or (equip.prefab == "shadow_battleaxe" and save_data.ueq_shadow_battleaxe and save_data.num_shadow_battleaxe >= per_now)                                                                   -- ? Repairable equipment ?
        then
            if not table.contains(dontunequip, prefab) then
                return equip
            end
        end
    end
end

Mod_ShroomMilk.Func.NeedAutoUnEquip = NeedAutoUnEquip

i_util:AddPlayerActivatedFunc(function(player, world, pusher)
    -- Supplement
    pusher:RegUnequip(function(slot, equip)
        if not m_data.ex_re_equip then return end
        -- If the equipment is explosive (destroy is fine) or durability is 0
        local prefab = equip.prefab
        if not prefab then return end
        player:DoTaskInTime(0, function()
            if not e_util:IsValid(equip) or e_util:GetPercent(equip) == 0 or not equip:HasTag("inlimbo") then
                player:DoTaskInTime(0, function()
                    -- Players do not install new equipment
                    if not p_util:GetEquip(slot) then
                        local equips = p_util:GetItemsFromAll(prefab, nil, function(ent)
                            return e_util:GetPercent(ent) ~= 0
                        end) or {}
                        -- Sort, priority consume high or low or low
                        table.sort(equips, function(a, b)
                            local ap, bp = e_util:GetPercent(a), e_util:GetPercent(b)
                            if save_data.ex_re_equip_way == "low" then
                                return ap < bp
                            else
                                return ap > bp
                            end
                        end)
                        local equip_new = equips[1]
                        if equip_new then
                            e_util:WaitToDo(player, 0.1, 20, function()
                                p_util:Equip(equip_new)
                                return p_util:IsEquipped(prefab)
                            end)
                        end
                    end
                end)
            end
        end)
    end)
    -- Supplement
    pusher:RegDeleteInv(function(cont, slot, item)
        if cont == player or not m_data.ex_re_ammo then return end
        local equips = p_util:GetEquips()
        if not equips then
            print("Unable to read equipment, please contact the developer for feedback!")
        end
        -- Only replenish hand equipment and head equipment
        if t_util:GetElement(equips or {}, function(eslot, equip)
                return equip == cont and (eslot == "hands" or eslot == "head")
            end) then
            local prefab = item.prefab
            if not prefab then return end
            player:DoTaskInTime(0, function()
                if not p_util:GetItemInSlot(cont, slot) then
                    local emmo = p_util:GetSlotFromAll(prefab, nil, function(ent, container)
                        return container ~= cont
                    end)
                    local container = emmo and emmo.cont and emmo.slot and e_util:GetContainer(emmo.cont)
                    if container then
                        container:MoveItemFromAllOfSlot(emmo.slot, cont)
                    end
                end
            end)
        end
    end)
    -- Durable monitoring
    local function listen_per(equip)
        local slot = e_util:GetItemEquipSlot(equip)
        -- Statistically wearing items
        local per_now = e_util:GetPercent(equip)
        if slot and p_util:GetEquip(slot) == equip then
            local per_last = equip[id_per_last]
            local prefab = equip.prefab
            -- Only the items that are durable and durable
            if type(per_last) == "number" then
                if per_last > per_now then
                    -- Bone armor
                    if prefab == "armorskeleton" then
                        SetCharge(equip, TUNING.ARMOR_SKELETON_COOLDOWN)
                        -- Cut the equipment first and repair
                        if m_data.sw_skeleton then
                            local skeletons = p_util:GetItemsFromAll("armorskeleton", nil,
                                    function(ent) return e_util:GetPercent(ent) ~= 0 end,
                                    { "container", "backpack", "body", "mouse" }) or
                                {}
                            -- Find the smallest time
                            table.sort(skeletons, function(a, b)
                                local cd_a, cd_b = a[id_charge_cd] or 5, b[id_charge_cd] or 5
                                local s_a, s_b = a[id_charge_start] or 0, b[id_charge_start] or 0
                                return cd_a+s_a < cd_b+s_b
                            end)
                            local ske_toequip = skeletons[1]
                            if ske_toequip then
                                p_util:Equip(ske_toequip)
                            end
                        end
                    end
                    
                    -- Automatic repair
                    if m_data.auto_repair then
                        -- Busy time
                        if save_data.busy_repair or not p_util:IsInBusy() then
                            if prefab == "pocketwatch_weapon" then
                                if save_data.ueq_watch and save_data.num_watch >= per_now then
                                    AutoRepair(equip)
                                end
                            elseif prefab == "armorskeleton" then
                                if save_data.ueq_ske and save_data.num_ske >= per_now then
                                    AutoRepair(equip)
                                end
                            elseif save_data.ueq_else and save_data.num_else >= per_now then
                                AutoRepair(equip)
                            end
                        end
                    end
                    -- Fall off
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
                        u_util:Say("Unequip", equip.name, nil, save_data.color_say)
                    end
                end
            end
        end
        equip[id_per_last] = per_now
    end
    -- Bone armor
    pusher:RegAddInv(function(cont, slot, item)
        if item.prefab == "armorskeleton" then
            item[id_per_last] = e_util:GetPercent(item)
        end
    end)
    pusher:RegEquip(function(_, equip)
        -- BYD klei
        e_util:SetBindEvent(equip, "percentusedchange", listen_per)
        if equip.prefab == "armorskeleton" then
            SetCharge(equip, TUNING.ARMOR_SKELETON_FIRST_COOLDOWN)
        end
    end)
end)

-- Byd corey planning component code passenger plane cannot be used
AddClassPostConstruct("widgets/itemtile", function (self)
    -- Bone armor increase ui display cooling
    if self.item.prefab == "armorskeleton" and not self.rechargeframe then
        self.rechargepct = 1
        self.rechargetime = 1
        self.rechargeframe = self:AddChild(UIAnim())
        self.rechargeframe:GetAnimState():SetBank("recharge_meter")
        self.rechargeframe:GetAnimState():SetBuild("recharge_meter")
        self.recharge = self:AddChild(UIAnim())
        self.recharge:GetAnimState():SetBank("recharge_meter")
        self.recharge:GetAnimState():SetBuild("recharge_meter")
        self.recharge:GetAnimState():SetMultColour(0, 0, 0.4, 0.64) -- 'Cooldown until' with BLUE colour.
        -- Am i really a genius?
        self.item[id_charge_func] = function (cd, left)
            if type(cd) ~= "number" or cd <= 0 then return end
            if type(left) ~= "number" or cd < 0 then return end
            self.rechargetime = cd
            if m_data.cd_skeleton then
                self:SetChargePercent((cd - left) / cd)
            end
        end
        local cd, start = self.item[id_charge_cd], self.item[id_charge_start]
        if cd and start then
            self.item[id_charge_func](cd, cd+start-GetTime())
        end
    end
    -- Display all the increase in cooling
    if self.rechargeframe then
        if not self.text_charge then
            self.text_charge = self:AddChild(Text(NUMBERFONT, 45))
            self.text_charge:SetPosition(5, -17)
            self.text_charge:Hide()
        end

        local _SetChargePercent = self.SetChargePercent
        self.SetChargePercent = function(self, pct, ...)
            local cd = self.rechargetime or 1
            local left = math.floor(cd - cd * pct)
            if left > 0 and cd > 3 and m_data.text_cd then
                local mm, ss = math.floor(left / 60), left % 60
                self.text_charge:SetString(string.format("%02d:%02d", mm, ss))
                self.text_charge:Show()
            else
                self.text_charge:Hide()
            end
            return _SetChargePercent(self, pct, ...)
        end
    end
end)


local function add_screen_ueq(id, label, hover)
    return {
        id = id,
        label = label,
        fn = fn_save(id),
        hover = "[Auto unequip] additional setting\nWhether to enable auto unequip " .. hover,
        default = fn_get,
    }
end
local function add_screen_rep(id, label, hover)
    return {
        id = id,
        label = label,
        fn = fn_save(id),
        hover = "[Auto refuel] additional setting\nWhether to enable auto refuel " .. hover,
        default = fn_get,
    }
end
local nums_long = t_util:IPairToIPair(
    { 0, 1, 2, 3, 4, 5, 6, 8, 10, 12, 14, 16, 18, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 99 },
    function(i)
        return { data = i, description = i .. "%" }
    end)
local function add_screen_num(id)
    return {
        id = id,
        label = "Below:",
        fn = fn_save(id),
        hover = "<-- Below this value, item on the left will automatically unequip/refuel",
        default = fn_get,
        type = "radio",
        data = nums_long
    }
end
local function ModSave(conf)
    return function(value)
        m_data[conf] = m_util:SaveModOneConfig(conf, value)
    end
end
local screen_data = {
    {
        id = "ex_re_equip",
        label = "Auto re-equip",
        fn = ModSave("ex_re_equip"),
        hover = "When the durability of weapons, wands, etc. is exhausted,\nthe next one will be automatically equipped",
        default = fn_moddata,
    },
    {
        id = "ex_re_equip_way",
        label = "Priority:",
        type = "radio",
        fn = fn_save("ex_re_equip_way"),
        hover = "What equipment should be prioritized to re-equip after an equipment breaks?\nNote: Some equipment in the original version of Don’t Starve can also be automatically replaced and have higher priority.",
        default = fn_get,
        data = {
            { data = "high", description = "High %", },
            { data = "low", description = "Low %", },
        }
    },
    {
        id = "ex_re_ammo",
        label = "Auto reload",
        fn = ModSave("ex_re_ammo"),
        hover = "Slingshots, Turf-Raiser Helm, etc. are automatically replenished",
        default = fn_moddata,
    },
    {
        id = "uppercent",
        label = "Hotkey repair:",
        fn = fn_save("uppercent"),
        hover = "When the durability of an item falls below this value, pressing the key will repair it.\nIf the key is not remapped, the default is 'V' to repair all equipment on the player",
        default = fn_get,
        type = "radio",
        data = t_util:BuildNumInsert(5, 100, 5, function(i)
            return { data = i, description = "Up to " .. i .. "%" }
        end)
    },
    {
        id = "cd_skeleton",
        label = "Bone Armor cooldown",
        fn = ModSave("cd_skeleton"),
        hover = "Add a blue circle to display the cooldown of Bone Armor",
        default = fn_moddata,
    },
    {
        id = "sw_skeleton",
        label = "Bone Armor switch",
        fn = ModSave("sw_skeleton"),
        hover = "After the Bone Armor is hit, auto switch to the next one with the shortest cooldown",
        default = fn_moddata,
    },
    {
        id = "text_cd",
        label = "Cooldown timer",
        fn = ModSave("text_cd"),
        hover = "Display a timer for items with cooldown such as Wanda’s watch and Bone Armor",
        default = fn_moddata,
    },
    {
        id = "auto_unequip",
        label = "Auto unequip",
        fn = ModSave("auto_unequip"),
        hover = "Whether the item automatically unequips when its durability decreases\nThe following settings are its additional settings",
        default = fn_moddata,
    },
    add_screen_ueq("ueq_fedbyall", "Terraria series", "Eye mask and horror shield"),
    add_screen_num("num_fedbyall"),
    add_screen_ueq("ueq_dreadstone", "Dreadstone series", "Despair helmet and armor"),
    add_screen_num("num_dreadstone"),
    add_screen_ueq("ueq_amulet", "Orange/yellow amulet", "Lazy dog ​​amulet and magic light amulet"),
    add_screen_num("num_amulet"),
    add_screen_ueq("ueq_shadow_battleaxe", "Shadow Mallet", "Movie Queen Equipment"),
    add_screen_num("num_shadow_battleaxe"),
    add_screen_ueq("ueq_sew", "Sew-able equips", "Equipments that can be repaired with a sewing kit"),
    add_screen_num("num_sew"),
    {
        id = "auto_repair",
        label = "Auto refuel",
        fn = ModSave("auto_repair"),
        hover = "Whether the durability reduction will be refueled automatically\nThe following settings are its additional settings",
        default = fn_moddata,
    },
    {
        id = "busy_repair",
        label = "Refuel when busy",
        fn = fn_save("busy_repair"),
        hover = "[Auto refuel] additional setting\nIs it allowed to refuel equipment while busy in combat or other states?",
        default = fn_get,
    },
    add_screen_rep("ueq_watch", "Alarm Clock", "Wanda exclusive weapon [Alarm Clock]"),
    add_screen_num("num_watch"),
    add_screen_rep("ueq_ske", "Bone Armor", "Ancient Fuelweaver’s drop [Bone Armor]"),
    add_screen_num("num_ske"),
    add_screen_rep("ueq_else", "Fuel-driven equips", "Lanterns, amulets and other equipment that add light"),
    add_screen_num("num_else"),
    {
        id = "color_say",
        label = "Color:",
        fn = fn_save("color_say"),
        hover = "The color of some prompts of the Item manager",
        default = fn_get,
        type = "radio",
        data = require("data/valuetable").RGB_datatable
    },
    {
        id = "horrorfuel",
        label = "Pure Horror",
        fn = function(v)
            local func_t = v and "Sub" or "Add"
            t_util[func_t](t_util, dontuseitem, "horrorfuel")
            fn_save("horrorfuel")(v)
        end,
        hover = "[Customization function]\nWhether to allow Pure Horror to be used as fuel to repair equipment",
        default = fn_get,
    },
}

m_util:AddBindConf("sw_manualAdd", fn_manu, true)
m_util:AddBindShowScreen("ex_board", "Item manager", "krampus_sack_voidbag", STRINGS.LMB .. "Item manager related settings", {
    title = "Item manager",
    id = save_id,
    data = screen_data
}, nil, 8001)
