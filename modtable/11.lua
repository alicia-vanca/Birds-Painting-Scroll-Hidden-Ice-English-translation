-- Item manager
if m_util:IsServer() then return end
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local default_data = {
    ex_re_equip_way = "low",
}
local m_data = {
    ex_re_equip = m_util:IsTurnOn("ex_re_equip"),
    ex_re_ammo = m_util:IsTurnOn("ex_re_ammo"),
    cd_skeleton = m_util:IsTurnOn("cd_skeleton"),
    sw_skeleton = m_util:IsTurnOn("sw_skeleton"),
    text_cd = m_util:IsTurnOn("text_cd"),
}
local save_id = "sw_explorer"
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local fn_moddata = function(id) return m_data[id] end
local id_per_last = "_huxi_lastperc"
local id_charge_cd, id_charge_start, id_charge_func = "_huxi_id_charge_cd", "_huxi_id_charge_start", "_huxi_id_charge_func"



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



i_util:AddPlayerActivatedFunc(function(player, world, pusher)
    
    pusher:RegUnequip(function(slot, equip)
        if not m_data.ex_re_equip then return end
        
        local prefab = equip.prefab
        if not prefab then return end
        player:DoTaskInTime(0, function()
            if not e_util:IsValid(equip) or e_util:GetPercent(equip) == 0 or not equip:HasTag("inlimbo") then
                player:DoTaskInTime(0, function()
                    
                    if not p_util:GetEquip(slot) then
                        local equips = p_util:GetItemsFromAll(prefab, nil, function(ent)
                            return e_util:GetPercent(ent) ~= 0
                        end) or {}
                        
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
        hover = "<- Below this value, item on the left will automatically unequip/refuel",
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
local screen_data = {{
        id = "bilibili",
        prefab = "bilibili",
        type = "imgstr",
        label = "Tutorial Demo",
        hover = "Click to view video tutorial or feature demonstration",
        fn = function()VisitURL("https://www.bilibili.com/video/BV1ZB2XBFEJY/", true)end
    },
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
}

m_util:AddBindShowScreen("ex_board", "Item manager", "krampus_sack_voidbag", STRINGS.LMB .. "Item manager related settings", {
    title = "Item manager",
    id = save_id,
    data = screen_data,
        icon = 
    {{
        id = "add",
        prefab = "mods",
        hover = "Customize",
        fn = function()
            h_util:CreatePopupWithClose("Item Manager", "This feature has been split into [Domestication Repair], [Auto Drop], [Auto Repair], etc. Please look for the buttons in the function panel.")
        end,
    }}
}, nil, 8001)
