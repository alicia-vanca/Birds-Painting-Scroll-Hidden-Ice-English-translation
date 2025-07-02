-- There is no need to judge theplayer in this file, without player will automatically return nil
-- It should be better to write this library in the form of practical components, but it is really lazy. how convenient to copy the code of the old mousse
-- p_util ThePlayer
-- i_util inventory
-- b_util builder
local t_util = require "util/tableutil"
local e_util = require "util/entutil"
local c_util = require "util/calcutil"
local g_func = Mod_ShroomMilk.Func

local i_util = {}
local p_util = {}
local b_util = {}
local d_util = {}

local function getinvent()
    return ThePlayer.replica.inventory
end
local function getsiminvent()
    return ThePlayer.components.inventory
end
local function getpicker()
    return ThePlayer.components.playeractionpicker
end
local function getpusher()
    return ThePlayer.components.hx_pusher
end
local function getcontrol()
    return ThePlayer.components.playercontroller
end


-- Item bar is available
function i_util:IsInvEnabled()
    return getinvent().classified
end


-- This function does not check the parameters, keep in mind!(pay attention to the case)
function i_util:GetActions(cate, right, ...)
    -- Inv: the action of the item bar item item item
    -- Useitem: the action of the item is the action of the scene object it, target
    -- Point: the action of items at a certain position it, pos
    local picker = getpicker()
    local actions = {}
    if picker then
        local item, target, pos = ...
        if cate == "inv" and item then -- Get single items action
            item:CollectActions("INVENTORY", ThePlayer, actions, right)
        elseif cate == "useitem" and item and target then   -- Items and items/target interaction
            item:CollectActions("USEITEM", ThePlayer, target, actions, right)
        elseif cate == "pos" and pos then 
            if item then -- Items and location interaction
                item:CollectActions("POINT", ThePlayer, pos, actions, right, target)
            elseif picker.pointspecialactionsfn then -- Empty -handed position interaction
                actions = picker.pointspecialactionsfn(ThePlayer, pos, nil, right)
            end
            target = pos
        elseif cate == "scene" and item then -- Target interaction (empty -handed)
            item:CollectActions("SCENE", ThePlayer, actions, right)
            target = item
            item = nil
        elseif cate == "equip" and item and target then --Equipment and target interaction (in fact, recommend the following hands)  
            item:CollectActions("EQUIPPED", ThePlayer, target, actions, right)
        elseif cate == "hands" and item then -- Hand equipment and external interaction
            target = item
            item = i_util:GetEquip("hands")
            if item then
                item:CollectActions("EQUIPPED", ThePlayer, target, actions, right)
            end
        end
        actions = picker:SortActionList(actions, target, item)
    end
    return actions
end

function i_util:GetAction(cate, code, right, ...)
    if not cate then
        return getpicker():DoGetMouseActions()
    end
    local acts = i_util:GetActions(cate, right, ...)
    if not code then
        return acts[1]
    end
    local codes = type(code) == "table" and code or { code }
    local acts_code = t_util:IPairFilter(codes, function(code)
        return ACTIONS[tostring(code):upper()]
    end)
    return t_util:GetElement(acts, function(_, act)
        return table.contains(acts_code, act.action) and act
    end)
end

function i_util:GetTargetActions(target, pos, right)
    local active_item = i_util:GetActiveItem()
    local acts_mouse = active_item and i_util:GetActions("useitem", right, active_item, target, pos) or {}
    local acts_scene = i_util:GetActions("scene", right, target) or {}
    local acts_hands = i_util:GetActions("hands", right, target) or {}
    return t_util:MergeList(acts_mouse, active_item and {} or acts_hands, active_item and {} or acts_scene)
end

-- Get the action of the specified click action
-- This function will strictly determine whether the function of the left or Right-click
function i_util:GetMouseAction(code_list, target, right)
    local picker = getpicker()
    local pos = target:GetPosition()
    local acts_left = i_util:GetTargetActions(target, pos, false)
    if right then
        local acts_right = i_util:GetTargetActions(target, pos, true)
        return t_util:IGetElement(acts_right, function(act_right)
            local r_id = t_util:GetRecur(act_right, "action.id")
            return r_id and table.contains(code_list, r_id) and not t_util:IGetElement(acts_left, function(act_left)
                return t_util:GetRecur(act_left, "action.id") == r_id
            end) and act_right
        end)
    else
        return t_util:IGetElement(acts_left, function(act_left)
            local l_id = t_util:GetRecur(act_left, "action.id")
            return l_id and table.contains(code_list, l_id) and act_left
        end)
    end
end
-- If you don't get strictly, you will return to act, right
function i_util:GetMouseActionSoft(code_list, target)
    local act = i_util:GetMouseAction(code_list, target, true)
    if act then
        return act, true
    end
    act = i_util:GetMouseAction(code_list, target)
    return act, false
end
-- Common acquisition
local act_codes_default = {"RUMMAGE", "ACTIVATE", "STORE", "PICKUP", "JUMPIN", "FEED"}
function i_util:GetMouseActionClick(ent, act_codes)
    local act, right = i_util:GetMouseActionSoft(act_codes or act_codes_default, ent)
    if act then
        return {
            target = ent,
            act = act,
            right = right
        }
    else
        return {
            target = ent,
            act = BufferedAction(ThePlayer, ent, ACTIONS.WALKTO, nil, ent:GetPosition())
        }
    end
end


-- The attack interface does not judge biological legitimacy. please see the other mod i wrote in biological legality.
-- Note: after the fenghua article is enabled, this interface will be covered!
function i_util:Attack(target, needequip)
    if needequip and g_func.EquipAttack then
        g_func.EquipAttack()
    end
    local pos = target:GetPosition()
    p_util:DoAction(BufferedAction(ThePlayer, target, ACTIONS.ATTACK), RPC.LeftClick, ACTIONS.ATTACK.code, pos.x, pos.z, target, true, 10, true, nil, nil, false)
end
-- Eat and eat
function i_util:Eat(food)
    if not e_util:IsValid(food) then
        return
    end
    local act = i_util:GetAction("inv", "eat", true, food)
    p_util:DoAction(act, RPC.ControllerUseItemOnSelfFromInvTile, act and act.action.code, food)
end


-- Equipment
function i_util:Equip(item)
    local siminv = getsiminvent()
    if siminv then
        -- Byd when i can't help it, right?
        local picker = getpicker()
        local can_equip = true
        if picker.rightclickoverride then
            can_equip = false
            local acts = picker.rightclickoverride(ThePlayer, item)
            if acts and #acts > 0 then
                can_equip = t_util:GetElement(acts, function(_, act)
                    -- print(act and act.action and act.action.id)
                    return act and act.action == ACTIONS.EQUIP
                end)
            end
        end
        -- When guandong cave, the items that have already equip cannot be equip again
        if can_equip and i_util:GetEquip(e_util:GetItemEquipSlot(item)) ~= item then
            siminv:Equip(item)
        end
    else
        SendRPCToServer(RPC.ControllerUseItemOnSelfFromInvTile, ACTIONS.EQUIP.code, item)
        SendRPCToServer(RPC.UseItemFromInvTile, ACTIONS.EQUIP.code, item)
    end
end

-- Find and equip
function i_util:FindAndEquip(prefab, func)
    local equip = i_util:GetItemFromAll(prefab, nil, func, "mouse")
    if equip then
        i_util:Equip(equip)
    end
end


-- Uninstall
-- Notmouse: can't uninstall the equipment on the mouse: roughly determine whether there is a place with the backpack and backpack.
function i_util:UnEquip(item, notmouse)
    if notmouse then
        local bp_cont = e_util:GetContainer(i_util:GetBackpack())
        local inv = getinvent()
        if inv:IsFull() and (not bp_cont or bp_cont:IsFull()) then
            return true
        end
    end
    if item and item:HasTag("heavy") then
        getinvent():DropItemFromInvTile(item)
    else
        if TheWorld and TheWorld.ismastersim then
            getinvent():ControllerUseItemOnSelfFromInvTile(item)
        else
            SendRPCToServer(RPC.ControllerUseItemOnSelfFromInvTile, ACTIONS.UNEQUIP.code, item)
        end
    end
end

-- Equipment
function i_util:IsEquipped(prefab)
    local prefabs = type(prefab) == "string" and {prefab} or prefab or {}
    return t_util:GetElement(EQUIPSLOTS or {}, function(_, slot)
        local equip = i_util:GetEquip(slot)
        return equip and table.contains(prefabs, equip.prefab) and equip
    end)
end
function i_util:EquipPrefab(prefab)
    if not i_util:IsEquipped(prefab) then
        local equip = i_util:GetItemFromAll(prefab, nil, nil, "mouse")
        if equip then
            i_util:Equip(equip)
        end
    end
end

-- Transfer item
function i_util:MoveItemFromAllOfSlot(slot, srccontainer, destcontainer)
    local invent = getsiminvent()
    if invent then
        local container = e_util:GetContainer(srccontainer)
        if container then
            container:MoveItemFromAllOfSlot(slot, destcontainer)
        end
    else
        if srccontainer == ThePlayer then
            SendRPCToServer(RPC.MoveInvItemFromAllOfSlot, slot, destcontainer)
        else
            SendRPCToServer(RPC.MoveItemFromAllOfSlot, slot, srccontainer, destcontainer)
        end
    end
end

local function containerCanHas(invent, item)
    for i = 1, invent:GetNumSlots() do
        local inv_item = invent:GetItemInSlot(i)
        if inv_item then
            if inv_item.prefab == item.prefab and inv_item.skinname == item.skinname then
                -- Even if you are not all taken away, you can take part
                if e_util:GetMaxSize(inv_item) > e_util:GetStackSize(inv_item) then
                    return true
                end
            end
        else
            return true
        end
    end
end
-- Can get items
function i_util:CanTakeItem(item)
    if containerCanHas(getinvent(), item) then
        return ThePlayer
    end
    local backpack = i_util:GetBackpack()
    local container = e_util:GetContainer(backpack)
    return container and containerCanHas(container, item) and backpack
end

-- Have you already opened a container
function i_util:IsOpenContainer(cont_inst)
    local container = e_util:GetContainer(cont_inst)
    if container then
        local invent = getinvent()
        return (t_util:GetElement(invent:GetOpenContainers() or {}, function(open_inst)
            return open_inst == cont_inst
        end) or e_util:GetContUI(cont_inst) or container:IsOpenedBy(ThePlayer)) and container
    end
end

-- Get the items on the mouse
function i_util:GetActiveItem(prefab)
    local item = getinvent():GetActiveItem()
    if not prefab or not item then
        return item
    end
    local prefabs = type(prefab) == "table" and prefab or { prefab }
    return table.contains(prefabs, item.prefab) and item
end

-- Put down the items on the mouse
function i_util:ReturnActiveItem(dontDrop)
    return getinvent():ReturnActiveItem()
end

-- A certain item is discarded in place
function i_util:DropItemFromInvTile(item, single)
    if not item then return end
    single = single and true or false
    return getinvent():DropItemFromInvTile(item, single)
end

-- Exchange a certain item
function i_util:SwapActiveItemWithSlot(cont, slot)
    local container = e_util:GetContainer(cont)
    if container then
        if type(slot) == "number" then
            container:SwapActiveItemWithSlot(slot)
        else
            container:SwapEquipWithActiveItem()
        end
    end
end

-- Pick up a certain item
function i_util:TakeActiveItemFromAllOfSlot(cont, slot)
    local container = e_util:GetContainer(cont)
    if container then
        if type(slot) == "number" then
            container:TakeActiveItemFromAllOfSlot(slot)
        else
            container:TakeActiveItemFromEquipSlot(slot)
        end
    end
end
-- Pick up half of an item
function i_util:TakeActiveItemFromHalfOfSlot(cont, slot)
    local container = e_util:GetContainer(cont)
    if container then
        if type(slot) == "number" then
            container:TakeActiveItemFromHalfOfSlot(slot)
        else
            container:TakeActiveItemFromEquipSlot(slot)
        end
    end
end
-- Pick up a specified number of items
function i_util:TakeActiveItemFromCountOfSlot(cont, slot, count)
    local container = e_util:GetContainer(cont)
    if container then
        if TheWorld and TheWorld.ismastersim then
            -- 科雷接口有bug，暂时不能统一用这个完成
            container:TakeActiveItemFromCountOfSlot(slot, count, ThePlayer)
        else
            if cont == ThePlayer then
                SendRPCToServer(RPC.TakeActiveItemFromCountOfSlot, slot, nil, count)
            else
                SendRPCToServer(RPC.TakeActiveItemFromCountOfSlot, slot, cont, count)
            end
        end
    end
end
-- Put down one of the items
function i_util:PutOneOfActiveItemInSlot(cont, slot)
    local container = e_util:GetContainer(cont)
    if container then
        if type(slot) == "number" then
            if e_util:GetStackSize(self:GetActiveItem()) == 1 then
                return self:PutAllOfActiveItemInSlot(cont, slot)
            else
                if self:GetItemInSlot(cont, slot) then
                    container:AddOneOfActiveItemToSlot(slot)
                else
                    container:PutOneOfActiveItemInSlot(slot)
                end
            end
        else
            container:EquipActiveItem()
        end
    end
end
-- Put down an item
function i_util:PutAllOfActiveItemInSlot(cont, slot)
    local container = e_util:GetContainer(cont)
    if container then
        if type(slot) == "number" then
            if self:GetItemInSlot(cont, slot) then
                container:AddAllOfActiveItemToSlot(slot)
            else
                container:PutAllOfActiveItemInSlot(slot)
            end
        else
            container:EquipActiveItem()
        end
    end
end


-- Obtain items in a container
function i_util:GetItemInSlot(cont, slot)
    if type(slot) == "number" then
        local container = e_util:GetContainer(cont)
        if container then
            return container:GetItemInSlot(slot)
        end
    else
        return i_util:GetEquip(slot)
    end
end

-- Get the equipment of the equipment bar
function i_util:GetEquip(slot)
    return slot and getinvent():GetEquippedItem(slot)
end


-- Get backpack
function i_util:GetBackpack()
    local equips = i_util:GetEquips() or {}
    return t_util:GetElement(equips, function (eslot, equip)
        return equip:HasTag("backpack") and equip
    end)
end


local order_all = { "container", "backpack", "equip", "body", "mouse" }
-- Get all items (item name, tag, condition function, order of obtaining items) [Items under the mouse will only be included if order == ‘mouse’]
function i_util:GetItemsFromAll(prefab, needtags, func, order)
    local result = {}
    local invent = getinvent()
    local items = {
        body = invent:GetItems(),
        equip = invent:GetEquips(),
        mouse = { i_util:GetActiveItem() },
        backpack = {},
        container = {}
    }

    t_util:Pairs(invent:GetOpenContainers() or {}, function(container_inst)
        local container = e_util:GetContainer(container_inst)
        if container then
            if container_inst:HasTag("INLIMBO") then
                items.backpack = t_util:MergeList(items.backpack, container:GetItems())
            else
                items.container = t_util:MergeList(items.container, container:GetItems())
            end
        end
    end)

    local t = type(order)
    if order == "mouse" then
        order = order_all
    elseif t == "string" and order_all[order] then
        order = { order }
    elseif t == "table" then
        -- do nothing
    else
        order = { "container", "backpack", "equip", "body" }
    end

    local all_items = {}
    t_util:IPairs(order, function(o)
        if items[o] then
            all_items = t_util:MergeList(all_items, items[o])
        end
    end)

    needtags = type(needtags) == "string" and { needtags } or (type(needtags) == "table" and needtags)
    for _, item in pairs(all_items) do
        if (not prefab or prefab == item.prefab or (type(prefab) == "table" and table.contains(prefab, item.prefab))) and
            (not needtags or item:HasTags(needtags)) and (not func or func(item)) then
            table.insert(result, item)
        end
    end
    return result
end

-- Get a item
function i_util:GetItemFromAll(prefab, needtags, func, oreder)
    return i_util:GetItemsFromAll(prefab, needtags, func, oreder)[1]
end


function i_util:GetEquips()
    return getinvent():GetEquips()
end

-- Get the location of the item and its container. Actually, tags are legacy code
function i_util:GetSlotsFromAll(prefab, needtags, func, order)
    local result = {}
    local invent = getinvent()

    local tp = type(order)
    if order == "mouse" then
        order = order_all
    elseif tp == "string" and order_all[order] then
        order = { order }
    elseif tp == "table" then
        -- do nothing
    else
        order = { "container", "backpack", "equip", "body" }
    end
    needtags = type(needtags) == "string" and { needtags } or (type(needtags) == "table" and needtags)
    local function add_ret(cont, slot, item)
        if item and (not prefab or prefab == item.prefab or (type(prefab) == "table" and table.contains(prefab, item.prefab))) and
            (not needtags or item:HasTags(needtags)) and (not func or func(item, cont, slot)) then
            table.insert(result, {
                cont = cont,
                slot = slot,
                item = item,
            })
        end
    end

    local c1, c2 = {}, {}
    t_util:Pairs(invent:GetOpenContainers() or {}, function(container_inst)
        table.insert(container_inst:HasTag("INLIMBO") and c1 or c2, container_inst)
    end)
    local function add_container(conts)
        t_util:IPairs(conts, function(cont_inst)
            local container = e_util:GetContainer(cont_inst)
            if container then
                t_util:Pairs(container:GetItems(), function(slot, item)
                    add_ret(cont_inst, slot, item)
                end)
            end
        end)
    end

    t_util:IPairs(order, function(o)
        if o == "body" then
            t_util:Pairs(invent:GetItems(), function(slot, item)
                add_ret(ThePlayer, slot, item)
            end)
        elseif o == "equip" then
            t_util:Pairs(invent:GetEquips(), function(slot, item)
                add_ret(ThePlayer, slot, item)
            end)
        elseif o == "mouse" then
            add_ret(ThePlayer, "mouse", i_util:GetActiveItem())
        elseif o == "backpack" then
            add_container(c1)
        elseif o == "container" then
            add_container(c2)
        end
    end)

    return result
end

-- Item: object slot: position container: cont_instst
function i_util:GetSlotFromAll(prefab, needtags, func, order)
    return i_util:GetSlotsFromAll(prefab, needtags, func, order)[1]
end

-- Get the grid of a certain item (called slot and conflict with the above, it is better to be called hud)
function i_util:GetItemHUD(item)
    local data = i_util:GetSlotFromAll(item.prefab, nil, function(ent)
        return item == ent
    end)
    if data then
        local invs
        if data.cont == ThePlayer then
            invs = t_util:GetRecur(ThePlayer, "HUD.controls.inv.inv")
        else
            local conts = t_util:GetRecur(ThePlayer, "HUD.controls.containers")
            invs =  conts and conts[data.cont] and conts[data.cont].inv
        end
        return invs and invs[data.slot]
    end
end

-- Ride
function p_util:IsRider()
    return ThePlayer.replica.rider and ThePlayer.replica.rider.classified and
        ThePlayer.replica.rider.classified.ridermount:value()
end

function p_util:DoAction(act, rpc, ...)
    local pc = getcontrol()
    local meta = { ... }
    if pc and rpc and act then
        act.preview_cb = function()
            SendRPCToServer(rpc, unpack(meta))
        end
        if pc.locomotor then
            pc:DoAction(act)
        else
            act.preview_cb()
        end
    end
end

-- This method can only move within the loading range
function p_util:WalkTo(pos, needequip)
    if needequip and g_func.EquipWalk then
        g_func.EquipWalk()
    end
    p_util:DoAction(BufferedAction(ThePlayer, nil, ACTIONS.WALKTO, nil, pos), RPC.LeftClick, ACTIONS.WALKTO.code, pos.x, pos.z)
end
-- Statue in the back of the back
function i_util:IsHeavy()
    return getinvent():IsHeavyLifting()
end

-- Get the container id
function i_util:GetInvID(cont, slot)
    if not (cont and slot) then return end
    if cont:HasTag("inlimbo") then
        -- Container
        local cont_data = i_util:GetSlotFromAll(nil, nil, function(ent)
            return ent == cont
        end)
        if cont_data then
            local pos_id = i_util:GetInvID(cont_data.cont, cont_data.slot)
            if pos_id then
                return pos_id.. "_"..slot
            end
        end
    elseif cont == ThePlayer then
        -- Body
        return "inv_"..slot
    else
        -- Note that the code here is 10,000.
        -- Ground
        local pos_id = e_util:GetPosID(cont)
        if pos_id then
            return pos_id .. "_" .. slot
        end
    end
end
-- Nearby
function p_util:IsNear(ent)
    local dist = e_util:GetDist(ent)
    if dist then
        local mv = Profile:GetMovementPredictionEnabled()
        return (mv and 3.5 or 4) > dist
    end
end

-- Click on
function p_util:Click(ent, right)
    local pos
    if e_util:IsValid(ent) then
        pos = ent:GetPosition()
    elseif not ent then
        assert(ent, "Illegal entity or location!")
    elseif ent.x and ent.z then
        pos = ent
        ent = nil
    end
    local picker = getpicker()
    local controller = getcontrol()
    if pos and picker and controller then
        local _, act
        if right then
            _, act = next(picker:GetRightClickActions(pos, ent))
        else
            _, act = next(picker:GetLeftClickActions(pos, ent))
            -- print(_, act)
        end
        if not act then
            act = BufferedAction(ThePlayer, ent, ACTIONS.WALKTO, nil, pos)
            right = nil
        end
        act.preview_cb = function()
            if right then
                SendRPCToServer(RPC.RightClick, act.action.code, pos.x, pos.z, act.target,
                    -- rotation, isreleased, controlmods, noforce, mod_name, platform, platform_relative
                    act.rotation, nil, nil, true, act.action.mod_name)
            else
                SendRPCToServer(RPC.LeftClick, act.action.code, pos.x, pos.z, act.target,
                    -- isreleased, controlmods, noforce, mod_name, platform, platform_relative, spellbook, spell_id
                    nil, nil, true, act.action.mod_name)
            end
        end
        if controller.locomotor then
            controller:DoAction(act)
        else
            act.preview_cb()
        end
        return act
    end
end

local function getactid(act)
    return act and act.action and act.action.id
end



-- If you can order, you can return, can you click if you can’t order it.
function p_util:TryClick(ent, actid)
    local pos
    if e_util:IsValid(ent) then
        pos = ent:GetPosition()
    elseif not ent then
        assert(ent, "Illegal entity or location!")
    elseif ent.x and ent.z then
        pos = ent
        ent = nil
    end
    local actid = type(actid) == "table" and actid or { actid }
    local picker = getpicker()
    local controller = getcontrol()
    if pos and picker and controller then
        local lmb, rmb = picker:DoGetMouseActions(pos, ent)
        local right, act
        if table.contains(actid, getactid(rmb)) then
            right = true
            act = rmb
        else
            act = table.contains(actid, getactid(lmb)) and lmb
        end
        if act then
            act.preview_cb = function()
                if right then
                    SendRPCToServer(RPC.RightClick, act.action.code, pos.x, pos.z, act.target, act.rotation, nil, nil,
                        true, act.action.mod_name)
                else
                    SendRPCToServer(RPC.LeftClick, act.action.code, pos.x, pos.z, act.target, nil, nil, true,
                        act.action.mod_name)
                end
            end
            if controller.locomotor then
                controller:DoAction(act)
            else
                act.preview_cb()
            end
        end
        return act
    end
end

-- Obtain
function p_util:GetAllActions(target, right)
    if not e_util:IsValid(target) then return end
    local acts_scene = i_util:GetActions("scene", right, target) or {}
    local acts_hands = i_util:GetActions("hands", right, target) or {}
    local active_item = i_util:GetActiveItem()
    local acts_mouse = active_item and i_util:GetActions("useitem", right, active_item, target, target:GetPosition()) or {}
    return t_util:MergeList(acts_mouse, acts_hands, acts_scene)
end
-- Get all support of target
function p_util:GetActionsID(target)
    local actions_left = p_util:GetAllActions(target) or {}
    local actions_right = p_util:GetAllActions(target, true) or {}
    return t_util:PairToIPair(t_util:MergeList(actions_left, actions_right), function(_, act)
        return act and act.action and act.action.id
    end)
end

function p_util:GetActionWithID(target, ids)
    local actions_left = p_util:GetAllActions(target) or {}
    local actions_right = p_util:GetAllActions(target, true) or {}
    local act = t_util:IGetElement(actions_right, function(act)
        local id = act and act.action and act.action.id
        return table.contains(ids, id) and act
    end)
    if act then
        return act, true
    end
    act = t_util:IGetElement(actions_left, function(act)
        local id = act and act.action and act.action.id
        return table.contains(ids, id) and act
    end)
    if act then
        return act, false
    end
end

-- Perform clicks
function p_util:DoMouseAction(act, right)
    local target = act.target
    if not (target) then return end
    local pos = target:GetPosition()
    if act.action.id == "WALKTO" then
        local item = i_util:GetActiveItem()
        if item and not Profile:GetMovementPredictionEnabled() then
            -- i_util:ReturnActiveItem()
            act = BufferedAction(ThePlayer, nil, ACTIONS.DROP, item, pos)
        else
            act = BufferedAction(ThePlayer, nil, ACTIONS.WALKTO, nil, pos)
        end
    end
    if right then
        p_util:DoAction(act, RPC.RightClick, act.action.code, pos.x, pos.z, act.target, act.rotation, nil, nil, true, act.action.mod_name)
    else
        p_util:DoAction(act, RPC.LeftClick, act.action.code, pos.x, pos.z, act.target, nil, nil, true, act.action.mod_name)
    end
end
-- Determine whether the player is busy
function p_util:IsInBusy()
    return -- e_util:IsAnim({"pickup", "pickup_pst"}, ThePlayer) or
        (ThePlayer.sg and ThePlayer.sg:HasStateTag("moving")) or
        (ThePlayer:HasTag("moving") and not ThePlayer:HasTag("idle")) or getcontrol():IsDoingOrWorking()
end

-- Stop moving
function p_util:StopWalking(force, needequip)
    local pc = getcontrol()
    if not pc then return end
    local loc = t_util:GetRecur(pc, "locomotor")
    if force then
        p_util:WalkTo(ThePlayer:GetPosition(), needequip)
        SendRPCToServer(RPC.StopWalking)
    else
        if loc then
            loc:Stop()
        else
            SendRPCToServer(RPC.StopWalking)
        end
    end
end

-- Pc binding event
function p_util:SetBindEvent(eventname, func)
    ThePlayer.player_classified:RemoveEventCallback(eventname, func)
    ThePlayer.player_classified:ListenForEvent(eventname, func)
end

-- Is the player dead?
-- The official one is inst:HasTag("playerghost")
function p_util:IsDead()
    return ThePlayer.player_classified.isghostmode:value()
end

-- Player attack range
function p_util:GetAttackRange()
    return ThePlayer.replica and ThePlayer.replica.combat and ThePlayer.replica.combat:GetAttackRangeWithWeapon()
end

-- Whether it is within the player's attack range
function p_util:AttackInRange(target)
    if e_util:IsValid(target) then
        local w_range = p_util:GetAttackRange() or 2
        local can_dist = w_range + target:GetPhysicsRadius(0)
        local dist = e_util:GetDist(target)
        return dist and dist < can_dist
    end
end

-- Can attack or forced attack
function p_util:CanAttack(target)
    if e_util:IsValid(target) and not IsEntityDead(target) then
        local combat = ThePlayer and ThePlayer.replica and ThePlayer.replica.combat
        return combat and combat:CanTarget(target)
    end
end


local function GetSpeed(locomotor)
    local speed = locomotor:GetRunSpeed()
    return p_util:IsRider() and speed or speed / (locomotor:TempGroundSpeedMultiplier() or locomotor.groundspeedmultiplier or 1)
end
-- Get the movement speed, but not calculate the plus bonus
function p_util:GetSpeed()
    local pc = getcontrol()
    if not pc then return end
    if pc.locomotor then
        return GetSpeed(pc.locomotor)
    else
        local speed = GetSpeed(ThePlayer:AddComponent("locomotor"))
        ThePlayer:RemoveComponent("locomotor")
        return speed
    end
end


-- Get lighting
function p_util:GetLightValue()
    local value = ThePlayer.LightWatcher and ThePlayer.LightWatcher:GetLightValue()
    if value then
        return tonumber(string.format("%.2f", value))
    end
end

-- Transmit
function p_util:Blink(pos, func)
    local equip = i_util:GetEquip("hands")
    local act = i_util:GetAction("pos", "BLINK", true, nil, nil, pos) or i_util:GetAction("pos", "BLINK", true, equip, nil, pos)
    local function BLINK()
        p_util:DoAction(act, RPC.RightClick, act.action.code, pos.x, pos.z, act.target, act.rotation, true, nil, nil, act.action.mod_name)
        if func then
            func()
        end
    end
    if act then
        BLINK()
    else
        local items = i_util:GetItemsFromAll(nil, nil, function(item)
            return e_util:GetItemEquipSlot(item) == "hands"
        end, "mouse")
        act = t_util:IGetElement(items, function(item)
            equip = item
            return i_util:GetAction("pos", "BLINK", true, item, nil, pos)
        end)
        if act then
            i_util:Equip(equip)
            ThePlayer:DoTaskInTime(FRAMES, BLINK)
        end
    end
end

-- Is the skill tree active?
function p_util:IsSkillTreeActivated(skillname)
    local skill = t_util:GetRecur(ThePlayer, "components.skilltreeupdater")
    return skill and skill:IsActivated(skillname)
end


local function getbuilder()
    return ThePlayer.replica.builder
end

-- Whether it can make
function b_util:CanBuild(recipename)
    local recipe = GetValidRecipe(recipename)
    if recipe then
        local builder = getbuilder()
        local knows_recipe = builder:KnowsRecipe(recipe)
        if builder:IsFreeBuildMode() then
            return true
        end
        local tech_trees = builder:GetTechTrees()
        local should_hint_recipe = ShouldHintRecipe(recipe.level, tech_trees)
        local is_build_tag_restricted = not builder:CanLearn(recipe.name)
        if knows_recipe or should_hint_recipe then
            if builder:IsBuildBuffered(recipe.name) and not is_build_tag_restricted then
                return true
            elseif knows_recipe or CanPrototypeRecipe(recipe.level, tech_trees) then
                for i, v in ipairs(recipe.ingredients) do
                    if not builder.inst.replica.inventory:Has(v.type, math.max(1, RoundBiasedUp(
                                v.amount * builder:IngredientMod())),
                            true) then
                        return false
                    end
                end
                for i, v in ipairs(recipe.character_ingredients) do
                    if not builder:HasCharacterIngredient(v) then
                        return false
                    end
                end
                return true
            end
        end
    end
end

-- Make
-- This method will not be interrupted for multiple sends, so it may cause continuous sending and cause more production
function b_util:MakeSth(prefab, skin)
    local recipe = GetValidRecipe(prefab)
    return recipe and getbuilder():MakeRecipeFromMenu(recipe, skin)
end

-- FOR MODDER
-- Only debugging can be available
local tiles_data = {}
function d_util:ChanTile(t1, t2)
    local px, py = TheWorld.Map:GetTileXYAtPoint(ThePlayer:GetPosition():Get())
    for i = px - 10, px + 10 do
        for j = py - 10, py + 10 do
            if TheWorld.Map:GetTile(i, j) == t1 then
                TheWorld.Map:SetTile(i, j, t2)
                if not tiles_data[i] then
                    tiles_data[i] = {}
                end
                if not tiles_data[i][j] then
                    tiles_data[i][j] = t1
                end
            end
        end
    end
end

function d_util:ResetTile()
    t_util:Pairs(tiles_data, function(i, i_data)
        t_util:Pairs(i_data, function(j, t_data)
            TheWorld.Map:SetTile(i, j, t_data)
        end)
    end)
end

function d_util:GetTile()
    local tile_id = TheWorld.Map:GetTileAtPoint(ThePlayer:GetPosition():Get())
    print(tile_id, t_util:GetElement(WORLD_TILES, function(name, index)
        return tile_id == index and name
    end))
end

function d_util:GetItemID(item)
    if item then
        local data = i_util:GetSlotFromAll(nil, nil, function(ent)
            return ent == item
        end)
        return data and i_util:GetInvID(data.cont, data.slot, data.item)
    end
end

function d_util:GetShadowCont()
    local invent = ThePlayer and getinvent()
    return invent and t_util:GetElement(invent:GetOpenContainers() or {}, function(cont)
        return cont.prefab == "shadow_container" and cont
    end)
end

-- The method of abandonment, but continues here to be compatible with some old functions
function i_util:GetInvAction(item, right, code)
    return i_util:GetAction("inv", code, right, item)
end


-- The function used by using to me to test
-- pu = require("util/playerutil")

local r_util = {}
for name, func in pairs(p_util) do
    r_util[name] = function(...)
        return ThePlayer and ThePlayer.player_classified and func(...)
    end
end
for name, func in pairs(i_util) do
    r_util[name] = function(...)
        return ThePlayer and getinvent() and func(...)
    end
end
for name, func in pairs(b_util) do
    r_util[name] = function(...)
        return ThePlayer and getbuilder() and func(...)
    end
end
for name, func in pairs(d_util) do
    r_util[name] = function(...)
        return ThePlayer and TheWorld and TheWorld.Map and func(...)
    end
end
return r_util
