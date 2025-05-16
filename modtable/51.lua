-- Tools switch initialization
if m_util:IsServer() then
    return
end
local save_id, string_cane = "sw_cane", "Auto tools"
local default_data = {
    sw = m_util:IsHuxi() and "on" or "off",
    light_unequip = true,
    right_hold = false,
    starve_value = 0,
}

local function func_hand(item)
    return e_util:GetItemEquipSlot(item) == "hands" and p_util:GetAction("inv", {"equip", "unequip"}, true, item)
end
local function func_light(item)
    return e_util:IsLightSourceEquip(item) and e_util:GetPercent(item) > 0
end
local function func_food(item)
    return p_util:GetAction("inv", "eat", true, item)
end

local slots = {"walk", "attack", "light", "right", "eat"}
local act_codes = {"LOOKAT", "WALKTO"}
t_util:IPairs(slots, function(slot)
    default_data["ui_"..slot] = true
end)
default_data.ui_right = m_util:IsHuxi()
default_data.ui_eat = false
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)



-- Formal writing function
local function GetEquip(prefab)
    if prefab then
        local NeedAutoUnEquip = Mod_ShroomMilk.Func.NeedAutoUnEquip
        local slot_data = p_util:GetSlotFromAll(prefab, nil, function(item)
            return p_util:GetAction("inv", {"equip", "unequip"}, true, item) and e_util:GetPercent(item) > 0 and (NeedAutoUnEquip and not NeedAutoUnEquip(item))
        end, {"equip", "body", "backpack", "container", "mouse"})
        if slot_data and not t_util:GetElement(EQUIPSLOTS, function(_, slot)
            return slot == slot_data.slot
        end) then
            return slot_data.item
        end
    end
end
local function EquipIt(prefab)
    local equip = GetEquip(prefab)
    if equip then
        p_util:Equip(equip)
    end
end
local function FilterActs(acts)
    return t_util:IPairFilter(acts or {}, function(act)
        local act_id = t_util:GetRecur(act, "action.id")
        return act_id and not table.contains(act_codes, act_id) and act
    end)
end
local function GetEquipAct(item, target)
    local acts_right = FilterActs(p_util:GetActions("equip", true, item, target))
    local acts_left = FilterActs(p_util:GetActions("equip", false, item, target))
    -- Traversing, if this action is on the right button, the Right-click action
    local act_right = t_util:IGetElement(acts_right, function(act_right)
        local r_id = t_util:GetRecur(act_right, "action.id")
        return r_id and not t_util:IGetElement(acts_left, function(act_left)
            return t_util:GetRecur(act_left, "action.id") == r_id
        end) and act_right
    end)
    if act_right then
        return act_right, true
    end
    return acts_left[1], false
end
local function UseEquip(item, target)
    local trans = e_util:IsValid(target)
    if item and trans then
        -- Get the action first, have action and then equipment
        local x,_,z = trans:GetWorldPosition()
        if table.contains({"yellowstaff", "opalstaff", "trident"}, item.prefab) then
            local act = p_util:GetAction("pos", "CASTSPELL", true, item, nil, Vector3(x, 0, z))
            if act then
                p_util:Equip(item)
                return i_util:DoTaskInTime(FRAMES, function()
                    p_util:DoAction(act, RPC.RightClick, act.action.code, x, z)
                end)
            end
        end

        local act, right = GetEquipAct(item, target)
        -- Here processing special bugs
        -- When you do not hit the wall, you will not attack the wounders in an invincible state, causing the bright eggplant staff to fail
        if not act and item.prefab=="staff_lunarplant" and target.prefab == "stalker_atrium" and e_util:GetPercent(item)>0 then
            act = BufferedAction(ThePlayer, target, ACTIONS.ATTACK)
        end
        
        if act then
            p_util:Equip(item)
            -- Open delay to ease one ha
            i_util:DoTaskInTime(FRAMES, function()
                local released = not save_data.right_hold
                if right then
                    p_util:DoAction(act, RPC.RightClick, act.action.code, x, z, target, act.rotation, released, nil, true, act.action.mod_name)
                else
                    p_util:DoAction(act, RPC.LeftClick, act.action.code, x, z, target, released, 10, true, act.action.mod_name)
                end
            end)
        end
    end
end
-- Attack
local atk_target
local function PressAttack()
    if not (save_data.sw=="on" and save_data.ui_attack and m_util:InGame()) then return end
    local pc = t_util:GetRecur(ThePlayer, "components.playercontroller")
    if pc then
        atk_target = pc:GetCombatTarget() or pc:GetAttackTarget(TheInput:IsControlPressed(CONTROL_FORCE_ATTACK)) or atk_target
        if e_util:IsValid(atk_target) and not p_util:IsRider() then
            if atk_target:HasOneOfTags({"butterfly", "stalkerminion"}) or atk_target.prefab == "shadowchanneler" then
                return
            end
            local equip = GetEquip(save_data.item_attack)
            if equip then
                p_util:Equip(equip)
                if equip ~= p_util:GetEquip("hands") then
                    local pos = atk_target:GetPosition()
                    p_util:DoAction(BufferedAction(ThePlayer, atk_target, ACTIONS.ATTACK), RPC.LeftClick, ACTIONS.ATTACK.code, pos.x, pos.z, atk_target, true, 10, true, nil, nil, false)
                end
                return true
            end
        end
    end
end
-- 250428 VanCa: Add some items with switch cooldown
local not_cane_prefabs = {"thurible", "bootleg", "bugnet", "thulecitebugnet", "magicalbroom", "spear_wathgrithr_lightning", "spear_wathgrithr_lightning_charged", "wathgrithr_shield"}
local switch_cane_prefabs = {"voidcloth_scythe", "wortox_nabbag", "elderwand", "shadowscythe"}
local function PressWalk()
    if not (save_data.sw=="on" and save_data.ui_walk) then return end
    local hand = p_util:GetEquip("hands")
    -- 250428 VanCa: Compatible with some Casino host's items
    if hand and table.contains(not_cane_prefabs, hand.prefab) then
        return
    end
    if hand and not table.contains(switch_cane_prefabs, hand.prefab) then
        if hand:HasOneOfTags({"castfrominventory", "umbrella", "_oceanfishingrod", "fishingrod", "tool"}) 
        or e_util:HasOneOfComps(hand, {"farmtiller", "wateryprotection", "terraformer", "oar"})
        or e_util:IsLightSourceEquip(hand) 
        then
            return
        end
    end
    if p_util:IsHeavy() then
        return
    end
    EquipIt(save_data.item_walk)
    return true
end

-- This interface is provided outside
Mod_ShroomMilk.Func.EquipWalk = PressWalk
Mod_ShroomMilk.Func.EquipAttack = PressAttack


AddComponentPostInit("playercontroller", function(self, player)
    if player ~= ThePlayer then
        return
    end
    local _DoDirectWalking = self.DoDirectWalking
    function self:DoDirectWalking(...)
        if self.directwalking then
            PressWalk()
        elseif TheInput:IsControlPressed(CONTROL_ATTACK) then
            PressAttack()
        end
        return _DoDirectWalking(self, ...)
    end
end)

local function InHunger(player, meta)
    local prefab = save_data.item_eat
    if not (save_data.ui_eat and prefab and save_data.sw=="on") then return end
    local hunger = player.replica and player.replica.hunger and player.replica.hunger:GetCurrent() <= save_data.starve_value
    if not hunger then return end
    local food = p_util:GetItemFromAll(prefab, nil, func_food, "mouse")
    if food then
        p_util:Eat(food)
    end
end
i_util:AddPlayerActivatedFunc(function(player, world, pusher)
    -- Lighting binding
    pusher:RegInDark(function(indark)
        if not (save_data.ui_light and save_data.sw=="on") then return end
        local prefab = save_data.item_light
        if prefab then
            if indark then
                EquipIt(prefab)
            elseif save_data.light_unequip and prefab~=save_data.item_walk and world:HasTag("forest") then
                local item = p_util:IsEquipped(prefab)
                if item then
                    p_util:UnEquip(item, true)
                    if save_data.ui_walk then
                        EquipIt(save_data.item_walk)
                    end
                end
            end
        end
    end)
    -- Food binding
    player:ListenForEvent("hungerdelta", InHunger)
    player:ListenForEvent("healthdelta", InHunger)
end)
-- Right-click binding
i_util:AddRightClickFunc(function(pc, player, down, act_right, ent_mouse)
    if not (down and ent_mouse and save_data.ui_right and save_data.sw=="on" and not TheInput:IsControlPressed(CONTROL_FORCE_TRADE)) then
        return
    end
    local prefab = save_data.item_right
    if prefab then
        local item = p_util:IsEquipped(prefab)
        if item then
            UseEquip(item, ent_mouse)
        else
            -- The current Right-click is useless to check
            if not act_right or t_util:IGetElement(act_codes, function(str)
                return ACTIONS[str] == act_right.action
            end) then
                UseEquip(GetEquip(prefab), ent_mouse)
            end
        end
    end
end)
-- Synchronous ui skin in the gear
i_util:AddPlayerActivatedFunc(function(player)
    local ectrl = h_util:GetECtrl()
    if ectrl then
        ectrl:ResetIcon()
    end
end)

-- Filter: filter work: click to trigger
local data_slots = {
    walk = {
        hover = "Auto switch to this equipment while running",
        label = "[running] slot",
        filter = func_hand,
        work = function()
            for control = CONTROL_MOVE_UP, CONTROL_MOVE_RIGHT do
                if TheInput:IsControlPressed(control) then
                    EquipIt(save_data.item_walk)
                end
            end
        end
    },
    attack = {
        hover = "Auto switch to this equipment while attacking",
        label = "[attack] slot",
        filter = func_hand,
    },
    light = {
        hover = "Auto switch to this equipment when it gets dark",
        label = "[lighting] slot",
        filter = func_light,
    },
    right = {
        hover = "Auto switch to this equipment when perform a [right-click] work\n(chop, mine, hammer, etc.)",
        label = "[right-click] slot",
        filter = func_hand,
    },
    eat = {
        hover = "Auto eat this when hungry",
        label = "[food] slot",
        filter = func_food,
    }
}

-- Add UI
local funcs_ui = {
    SavePos = function(pos)
        fn_save("posx")(pos.x)
        fn_save("posy")(pos.y)
    end,
    SaveData = fn_save
}
AddClassPostConstruct("widgets/inventorybar",function(self, player)
    if self.ectrl then self.ectrl:Kill() end
    self.ectrl = self:AddChild(require("widgets/huxi/huxi_ectrl")(self, player, save_data, funcs_ui, {
        slots = slots,
        data_slots = data_slots,
    }))
end)



-- Add to function panel
local function fn()
    local value = save_data.sw == "on" and "off" or "on"
    local show = value == "on"
    fn_save("sw")(value)
    local ectrl = h_util:GetECtrl()
    if not ectrl then return end
    ectrl:UI_Build(save_data)
    u_util:Say(string_cane, show, nil, nil, true)
end
local screen_data = {
    {
        id = "sw",
        label = "Enable Auto tools",
        hover = "Turn all functions on/off with one click",
        default = function()
            return save_data.sw == "on"
        end,
        fn = fn,
    },
    {
        id = "resetpos",
        label = "Reset UI position",
        hover = "If the panel is stuck, please click me!",
        default = true,
        fn = function()
            local ectrl = h_util:GetECtrl()
            if ectrl then
                ectrl:ResetPos()
            end
        end,
    },
}
t_util:IPairs(slots, function(slot)
    local id = "ui_"..slot
    local data = data_slots[slot]
    table.insert(screen_data, {
        id = id,
        label = data.label,
        hover = "Whether to display "..data.label.."\n"..data.hover,
        default = fn_get,
        fn = function(value)
            fn_save(id)(value)
            local ectrl = h_util:GetECtrl()
            if ectrl then
                ectrl:UI_Build(save_data)
            end
        end,
    })
end)
table.insert(screen_data, {
    id = "light_unequip",
    label = "Unequip [lighting]",
    hover = "Remove the lighting equipment when it is daylight or when there is light [Only on the surface]",
    default = fn_get,
    fn = fn_save("light_unequip"),
})
table.insert(screen_data, {
    id = "right_hold",
    label = "Right-click as hold",
    hover = "[Only for worlds with caves enabled and without the Don't Starve Alone mod]\nContinuously perform the action while the [right-click] equipment is still active\nTurn off this option if you like fighting monsters, turn it on if you prefer working",
    default = fn_get,
    fn = fn_save("right_hold"),
})
table.insert(screen_data, {
    id = "starve_value",
    label = "Hunger value:",
    hover = "Auto eat the food in the [food] slot when Hunger below this value",
    default = fn_get,
    fn = fn_save("starve_value"),
    type = "radio",
    data = t_util:IPairToIPair({0, 5, 10, 15, 25, 50, 100, 125, 150, 175, 200, 225, 250, 275, 300, 400, 500, 600, 700, 800, 900, 1000}, function(value)
        return {data = value, description = value}
    end)
})
local fn_right = m_util:AddBindShowScreen({
    title = string_cane,
    id = "hx_" .. save_id,
    data = screen_data
})
m_util:AddBindConf(save_id, fn, nil, {string_cane, "cane_candycane", STRINGS.LMB .. "On/Off " .. STRINGS.RMB .. "Advanced settings", true, fn, fn_right, 7992})