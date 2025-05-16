local c_util, e_util, h_util, i_util, m_util, p_util, t_util  = 
require "util/calcutil",
require "util/entutil",
require "util/hudutil",
require "util/inpututil",
require "util/modutil",
require "util/playerutil",
require "util/tableutil"
local id_push_thread, id_periodic_task = "id_push_thread", "id_periodic_task"
local frame_periodic = 5
local Mouse_controls = {
    [CONTROL_PRIMARY] = true,
    [CONTROL_SECONDARY] = true,
}
---@class Pusher
---@field inst any
---@field ishost boolean
---@field func_equip table<function, table<number, boolean>>
---@field func_unequip table<function, table<number, boolean>>
---@field func_destroyequip table<function, table<number, boolean>>
---@field func_addinv table<function, table<number, boolean>>
---@field func_deleteinv table<function, table<number, boolean>>
---@field func_control table<function, table<number, boolean>>
---@field func_chaninv table<function, table<number, boolean>>
---@field func_periodic table<function, table<number, boolean>>
---@field func_indark table<function, boolean>
---@field func_perpos table<function, function>
---@field items table
---@field invs table
---@field onremove_equip function
---@field listen_itemget function
---@field listen_itemlose function
local Pusher = Class(function(self, player)
    self.inst = player
    self.ishost = m_util:isHost()

    self.func_equip = {}
    self.func_unequip = {}
    self.func_destroyequip = {}
    self.func_addinv = {}
    self.func_deleteinv = {}
    self.func_control = {}
    self.func_chaninv = {}
    self.func_periodic = {}
    self.func_indark = {}
    self.func_perpos = {}

    self.items = {}  -- This table records the container id+position = item
    self.invs = {}  -- This table records the items on the player's body


    self.onremove_equip = function(item) 
        self:DestroyEquip(item) 
    end
    self.listen_itemget = function (cont, meta)
        if meta then
            local slot, item = meta.slot, meta.item
            if item then
                self:SetItem(cont, slot, item)
            end
        end
    end
    self.listen_itemlose = function (cont, meta)
        local slot = meta and meta.slot
        self:SetItem(cont, slot)
    end
    ---------- treatment items ---------------------
    player:ListenForEvent("equip", function(_, meta)
        e_util:SetBindEvent(meta.item, "onremove", self.onremove_equip)
        self:Equip(meta.eslot, meta.item)
    end)
    player:ListenForEvent("unequip", function (_, meta)
        self:UnEquip(meta.eslot)
    end)
    player:ListenForEvent("newactiveitem", function(_, meta)
        self:SetItem(player, "mouse", meta and meta.item)
    end)
    self:AddListenContainer(player)
    ---------- treatment container --------------------
    local HUD = player.HUD
    if HUD then
        -- Record the item after the box is opened
        local _OpenContainer = HUD.OpenContainer
        HUD.OpenContainer = function(HUD, cont_inst, ...)
            local result = _OpenContainer(HUD, cont_inst, ...)
            local cont = e_util:GetContainer(cont_inst)
            if cont then
                -- M_util: print ('open the container', cont_inst)
                self:AddListenContainer(cont_inst)
                t_util:Pairs(cont:GetItems(), function(slot, item)
                    self:SetItem(cont_inst, slot, item)
                end)
            end
            return result
        end
        -- Remove the record after the gate
        local _CloseContainer = HUD.CloseContainer
        HUD.CloseContainer = function(HUD, cont_inst, ...)
            local cont = e_util:GetContainer(cont_inst)
            local result = _CloseContainer(HUD, cont_inst, ...)
            if cont then
                for slot = 1,cont:GetNumSlots() do
                    -- Mandatory removal of the entity
                    self:SetItem(cont_inst, slot, nil, true)
                end
            end
            return result
        end
    end
    
    self:AllRefresh()
    ---------- treatment control ---------------------
    local pc = player.components.playercontroller
    if pc then
        local _OnControl = pc.OnControl
        pc.OnControl = function(pc, control, down, ...)
            if down then
                if m_util:InGame() and not TheInput:IsControlPressed(CONTROL_FORCE_INSPECT) -- Skip
                and not (Mouse_controls[control] and TheInput:GetHUDEntityUnderMouse()) then  -- Skip hud
                    t_util:Pairs(self.func_control, function(func, controls)
                        if controls[control] then
                            if func(pc) then
                                self.func_control[func] = nil
                            end
                        end
                    end)
                end
            end
            return _OnControl(pc, control, down, ...)
        end
    end

    ---------- surveillance light source and position -----------------------------------------------------------------
    local lh = {1, 1, 1}
    player:DoPeriodicTask(1, function(player)
        -- Dark incident
        local lightvalue = p_util:GetLightValue()
        if lightvalue then
            local lw = player.LightWatcher
            lh[1] = lh[2] lh[2] = lh[3] lh[3] = lightvalue
            if lightvalue == 0 or not lw:IsInLight() then
                t_util:IPairs(self.func_indark, function (func)
                    func(true)
                end)
            else
                if lh[3]>lh[2] and lh[2]>lh[1] then
                    t_util:IPairs(self.func_indark, function (func)
                        func(false)
                    end)
                end
            end
        end

        -- Location
        if player.Transform then
            local x, _, z = player.Transform:GetWorldPosition()
            if x and z then
                t_util:Pairs(self.func_perpos, function(_, func)
                    func(x, z)
                end)
            end
        end
    end)
end)
-- Registered container
function Pusher:AddListenContainer(cont)
    if not e_util:GetContainer(cont) then return end
    e_util:SetBindEvent(cont, "itemget", self.listen_itemget)
    e_util:SetBindEvent(cont, "itemlose", self.listen_itemlose)
end
-- Adding items to a container
function Pusher:AddInv(cont, slot, item)
    if not item then return end     -- Prevent the outside world from calling
    local info = self.invs[item]
    if info then
        if info.cont ~= cont or info.slot ~= slot then
            t_util:IPairs(self.func_chaninv, function(func)
                func(item, cont, slot, info.cont, info.slot)
            end)
        end
    else
        t_util:IPairs(self.func_addinv, function (func)
            func(cont, slot, item)
        end)
    end
    self.invs[item] = {
        cont = cont,
        slot = slot
    }
end
function Pusher:DeleteInv(item)
    if item then                    -- Determine additional insurance again
        local meta = self.invs[item]
        if meta then
            local cont, slot = meta.cont, meta.slot
            if cont and slot then
                t_util:IPairs(self.func_deleteinv, function (func)
                    func(cont, slot, item)
                end)
            end
        end
        self.invs[item] = nil
    end
end
-- Reducing items
function Pusher:RemoveInv(item)
    if not item then return end
    self.inst:DoTaskInTime(0, function()
        if not e_util:IsValid(item) or not item:HasTag("inlimbo") then
            self:DeleteInv(item)
        end
    end)
end
-- Registered item
function Pusher:SetItem(cont, slot, item, force)
    local c_guid = cont and cont.GUID
    local id = c_guid and slot and c_guid..slot
    if id then
        -- m_util:print(cont, slot, item, force)
        if item then
            self:AddInv(cont, slot, item)
        else
            local item_ret = self:GetItem(cont, slot)
            if force then
                self:DeleteInv(item_ret)
            else
                self:RemoveInv(item_ret)
            end
        end
        self.items[id] = item
    end
end
-- Obtain item
function Pusher:GetItem(cont, slot)
    local c_guid = cont and cont.GUID
    local id = c_guid and slot and c_guid..slot
    return id and self.items[id]
end



function Pusher:Equip(slot, item)
    self:UnEquip(slot)
    if slot and item then
        t_util:IPairs(self.func_equip, function (func)
            func(slot, item)
        end)
        self:SetItem(self.inst, slot, item)
    end
end
-- Uninstalled equipment
function Pusher:UnEquip(slot)
    local item = self:GetItem(self.inst, slot)
    if item and slot then
        t_util:IPairs(self.func_unequip, function (func)
            func(slot, item)
        end)
        self:SetItem(self.inst, slot)
    end
end
-- Destroy equipment
function Pusher:DestroyEquip(item)
    local slot = e_util:GetItemEquipSlot(item)
    if item and slot and item == p_util:GetEquip(slot) then
        t_util:IPairs(self.func_destroyequip, function (func)
            func(slot, item)
        end)
    end
    self:UnEquip(slot)
end

-- The recommended interface is here; feel free to hook the one above if you want
-- Refresh tracking
-- In fact, this is not very recommended. this method will forcibly refresh all the items containers on the body and immediately re -trigger the binding events
function Pusher:AllRefresh()
    self.invs = {}
    self.items = {}
    -- Registered item
    t_util:IPairs(p_util:GetSlotsFromAll(nil, nil, nil, {"container", "backpack", "body"}) or {}, function (meta)
        self:AddListenContainer(meta.item)
        self:SetItem(meta.cont, meta.slot, meta.item)
    end)
    -- Registered equipment
    t_util:Pairs(p_util:GetEquips() or {}, function (slot, equip)
        e_util:SetBindEvent(equip, "onremove", self.onremove_equip)
        self:AddListenContainer(equip)
        self:Equip(slot, equip)
    end)
end
-- Register equipment installation
-- It will take effect once all equipment items, and every time there are new equipment, it will take effect
---@param func function Function triggered when the equipment is installed
function Pusher:RegEquip(func)
    table.insert(self.func_equip, func)
    t_util:Pairs(p_util:GetEquips() or {}, function (slot, equip)
        func(slot, equip)
    end)
end
function Pusher:DelEquip(func)
    local id = t_util:Pairs(self.func_equip, function (id, func)
        return func == func and id
    end)
    if id then
        table.remove(self.func_equip, id)
    end
end
-- Uninstalling the registered equipment, triggers when the player uninstalls the equipment, each uninstallation will take effect
---@param func function Function triggered when the equipment is uninstalled
function Pusher:RegUnequip(func)
    table.insert(self.func_unequip, func)
end
function Pusher:DelUnequip(func)
    local id = t_util:Pairs(self.func_unequip, function (id, func)
        return func == func and id
    end)
    if id then
        table.remove(self.func_unequip, id)
    end
end
-- Register equipment destroy
function Pusher:RegDestroyEquip(func)
    table.insert(self.func_destroyequip, func)
end
-- Register to get items
function Pusher:RegAddInv(func)
    table.insert(self.func_addinv, func)
    t_util:Pairs(self.invs, function (item, data)
        func(data.cont, data.slot, item)
    end)
end
-- The location of the registered item is changed (only detection changes, not obtained and lost)
-- item, cont, slot, info.cont, info.slot
function Pusher:RegChanInv(func)
    table.insert(self.func_chaninv, func)
end
-- Register to lose items
function Pusher:RegDeleteInv(func)
    table.insert(self.func_deleteinv, func)
end
-- Stop the task currently executed
function Pusher:StopNowTask()
    if self.thread_push then
        KillThreadsWithID(id_push_thread)
        -- self.thread_push:SetList(nil)
        self.thread_push = nil
        if type(self.task_func_stop) == "function" then
            self.task_func_stop(self.inst)
        end
    end
end
-- Register a task that is executed immediately and remember to delete
-- func_loop(player, pc) return true
-- func_stop(player)
-- Ctrls: default movement or click will be interrupted
function Pusher:RegNowTask(func_loop, func_stop, controls)
    self:StopNowTask()
    self.task_func_stop = func_stop
    self:RegFuncControls(function () self:StopNowTask() return true end, controls)
    self.thread_push = StartThread(function()
        while self.thread_push and e_util:IsValid(self.inst) and self.inst.components.playercontroller do
            -- You need players to write sleep manually in func_loop
            if func_loop(self.inst, self.inst.components.playercontroller) then
                break
            end
        end
        self:StopNowTask()
    end, id_push_thread)
    return self.thread_push
end
-- Registered controller binding
-- If func returns true, then the function will only be executed once
function Pusher:RegFuncControls(func, controls)
    local ret = {}
    local function addkeyboard()
        for control = CONTROL_ATTACK, CONTROL_MOVE_RIGHT do
            ret[control] = true
        end
    end
    local function addmouse()
        ret[CONTROL_PRIMARY] = true
        ret[CONTROL_SECONDARY] = true
    end
    if controls == "keyboard" then
        addkeyboard()
    elseif controls == "mouse" then
        addmouse()
    elseif controls == "null" then
        ret = nil
    elseif type(controls) == "table" then
        ret = controls
    else
        addkeyboard()
        addmouse()
    end
    if type(func) == "function" then
        self.func_control[func] = ret
    end
end
-- Get public thread
function Pusher:GetNowTask()
    return self.thread_push
end
-- Increase the cycle task (default 5 frame test)
function Pusher:RegPeriodic(func, id)
    if type(func) ~= "function" then return end
    -- Execute it once
    func(self.inst)
    local id = id or func
    if self.func_periodic[id] then return end
    self.func_periodic[id] = func
    if not self.inst[id_periodic_task] then
        self.inst[id_periodic_task] = self.inst:DoPeriodicTask(frame_periodic*FRAMES, function(player)
            t_util:Pairs(self.func_periodic, function(id, func)
                if func(player) then
                    self:RemovePeriodic(id)
                end
            end)
        end)
    end
end
-- Remove the loop task
function Pusher:RemovePeriodic(id)
    if not id then return end
    if self.func_periodic[id] then
        self.func_periodic[id] = nil
        if table.count(self.func_periodic) == 0 then
            self.inst[id_periodic_task]:Cancel()
            self.inst[id_periodic_task] = nil
        end
        return true
    end
end
-- Register the dark mission
-- True -darkness: continue push
-- False -the dawn of dawn: push once when it brightens
-- Do not push when there is a light source
function Pusher:RegInDark(func)
    table.insert(self.func_indark, func)
end
-- Location task, return to x, z per second
function Pusher:RegPerPos(func)
    table.insert(self.func_perpos, func)
end
-- Removal position task
function Pusher:RemovePerPos(func)
    t_util:Pairs(self.func_perpos, function(k, v)
        if v == func then
            self.func_perpos[k] = nil
        end
    end)
end

-- Implement (load) execution, recommend this method in dotimeinstask0
-- Func_near (x, z) is executed once closer until you leave
-- Func_leave (x, z, isremove) leaves once and executes it once until it is close
--[[example code
    AddPrefabPostInit("multiplayer_portal", function(inst)
        inst:DoTaskInTime(0, function()
            local pusher = m_util:GetPusher()
            if pusher then
                pusher:RegNearStart(inst, function(x, z)
                    print("Near the birth door", x, z, inst)
                end, function(x, z)
                    print("Leave the birth door", x, z, inst)
                end)
            end
        end)
    end)
--]]

-- This method can be used to refresh point marks, more map icons, etc.
-- Do not write for the time being, wait for others to customize these functions to enhance the version
-- func_near executes x, z when approaching
-- func_leave executes x, z when leaving
function Pusher:RegNearStart(ent, func_near, func_leave, range)
    local trans = e_util:IsValid(ent)
    if not trans then return end
    if self.ishost or range then
        range = range or 64
        local lock
        local function pos_hook(x, z)
            trans = e_util:IsValid(ent)
            if trans then
                local x_e,_, z_e = trans:GetWorldPosition()
                if c_util:GetDist(x, z, x_e, z_e) < range then
                    -- Execute it once and wait to leave
                    if not lock then
                        func_near(x_e, z_e)
                        lock = true
                    end
                else
                    -- Wait for the first time to leave before leaving, and wait for the execution to approach
                    if lock and func_leave then
                        func_leave(x_e, z_e)
                        lock = false
                    end
                end
            else
                -- Abnormal situation
            end
        end
        self:RegPerPos(pos_hook)
        ent:ListenForEvent("onremove", function(inst)
            trans = ent.Transform
            if trans and func_leave then
                local x_e, _, z_e = trans:GetWorldPosition()
                func_leave(x_e, z_e, true)
            end
            self:RemovePerPos(pos_hook)
        end)
    else
        local x_e, _, z_e = trans:GetWorldPosition()
        func_near(x_e, z_e)
        ent:ListenForEvent("onremove", function(inst)
            trans = ent.Transform
            if trans and func_leave then
                local x_e, _, z_e = trans:GetWorldPosition()
                func_leave(x_e, z_e, true)
            end
        end)
    end
    return true
end
return Pusher