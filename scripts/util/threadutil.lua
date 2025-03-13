-- Thread tool
-- 呼吸: the interface of quite failed, the data_act and other logic are not successfully returned.
-- There is time to improve in the future

-- 呼吸 until September 2024: It’s actually not a bad interface, at least it can “guarantee” a certain operation
local p_util = require "util/playerutil"
local e_util = require "util/entutil"
local m_util = require "util/modutil"
local c_util = require "util/calcutil"

local d_util = {
    time_wait = FRAMES * 3,
    time_out = 1,
    dist_click = 60,
}

local rpc_timestamp = "_hx_timestamp"
local rpc_data = "_hx_rpc_data"

local function GetCurrentScheduler()
    local co = coroutine.running()
    if co then
        if scheduler.tasks[co] then
            return scheduler
        elseif staticScheduler.tasks[co] then
            return staticScheduler
        end
    end
end


function d_util:Wait(time_wait)
    time_wait = time_wait or d_util.time_wait
    time_wait = time_wait < 0 and d_util.time_wait or time_wait
    if GetCurrentScheduler() then
        -- Avoid waiting in the main thread due to unexpected interruptions
        Sleep(time_wait)
    else
        print("Sleep should not be called in the main thread! Please contact the developer to fix it!")
    end
end

-- Execute the cycle when the conditions are met, the failure returns to true, and the success will not return
-- The loop is executed when func is true
function d_util:TaskLoop(func, time_wait, time_out)
    local time_start = GetTime()
    time_out = time_out or self.time_out
    while func() do
        self:Wait(time_wait)
        if GetTime() - time_start > time_out then
            return true
        end
    end
end

-- Pick up the item
function d_util:TakeActiveItem(item, ...)
    local data = p_util:GetSlotFromAll(nil, nil, function(ent)
        return ent == item
    end, "mouse")
    if data then
        local cont, slot = data.cont, data.slot
        if slot == "mouse" then return end
        local item_active = p_util:GetActiveItem()
        if type(slot) == "number" then
            return self:TaskLoop(function()
                if item_active then
                    -- The items of the same name cannot be stacked
                    if item_active.prefab == item.prefab and item.skinname == item_active.skinname and e_util:GetStackSize(item) ~= 1 then
                        p_util:ReturnActiveItem()
                    else
                        p_util:SwapActiveItemWithSlot(cont, slot)
                    end
                else
                    p_util:TakeActiveItemFromAllOfSlot(cont, slot)
                end
                item_active = p_util:GetActiveItem()
                return item_active ~= item
            end, ...)
        else
            -- The situation of items in the equipment bar
            return self:TaskLoop(function()
                if item_active then
                    if e_util:GetItemEquipSlot(item_active) == e_util:GetItemEquipSlot(item) then
                        p_util:SwapActiveItemWithSlot(cont, slot)
                    else
                        p_util:ReturnActiveItem()
                    end
                else
                    p_util:TakeActiveItemFromAllOfSlot(cont, slot)
                end
                item_active = p_util:GetActiveItem()
                return item_active ~= item
            end, ...)
        end
    end
    return true
end

-- Put down an item (if there is an empty space, put it there, if there are items, stack them, 
-- return true if there is no space or it is full)
function d_util:PutOneOfActiveItemInSlot(cont, slot, ...)
    if p_util:GetActiveItem() then
        local item_cont = p_util:GetItemInSlot(cont, slot)
        local item_size = item_cont and e_util:GetStackSize(item_cont) or 0

        return self:TaskLoop(function()
            p_util:PutOneOfActiveItemInSlot(cont, slot)
            local item_cont_new = p_util:GetItemInSlot(cont, slot)
            local item_size_new = item_cont_new and e_util:GetStackSize(item_cont_new) or 0
            return item_size == item_size_new
        end, ...)
    end
    return true
end

-- Put down the item
function d_util:PutActiveItemInSlot(cont, slot, ...)
    local item_active = p_util:GetActiveItem()
    local size_active = e_util:GetStackSize(item_active)
    if item_active then
        local item_to = p_util:GetItemInSlot(cont, slot)
        return self:TaskLoop(function()
            if item_to then
                if item_to.prefab == item_active.prefab and item_to.skinname == item_active.skinname then
                    local size_max, size_stack = e_util:GetMaxSize(item_to), e_util:GetStackSize(item_to)                   
                    if size_max > size_stack then
                        p_util:PutAllOfActiveItemInSlot(cont, slot)
                        item_active = p_util:GetActiveItem()
                        return item_active and size_active == e_util:GetStackSize(item_active)
                    else
                        if size_max == 1 then
                            p_util:SwapActiveItemWithSlot(cont, slot)
                            return p_util:GetItemInSlot(cont, slot) ~= item_active
                        else
                            return
                        end
                    end
                else
                    p_util:SwapActiveItemWithSlot(cont, slot)
                    return p_util:GetItemInSlot(cont, slot) ~= item_active
                end
            else
                p_util:PutAllOfActiveItemInSlot(cont, slot)
                return not p_util:GetItemInSlot(cont, slot)
            end
        end, ...)
    end
end

-- Move items from one grid to another
function d_util:MoveItemInSlot(item, cont, slot, ...)
    local item_to = p_util:GetItemInSlot(cont, slot)
    if not item_to or item_to.prefab ~= item.prefab then
        return self:TakeActiveItem(item, ...) or self:PutActiveItemInSlot(cont, slot, ...)
    end
end

-- No items are left on the mouse
function d_util:ReturnActiveItem(...)
    if p_util:GetActiveItem() then
        return self:TaskLoop(function()
            p_util:ReturnActiveItem()
            return p_util:GetActiveItem()
        end, ...)
    end
end

-- Make item
function d_util:MakeItem(prefab,skin, ...)
    local time_wait, time_out = ...
    time_wait = time_wait or 3*FRAMES
    time_out = time_out or 5

    self:TaskLoop(function()
        p_util:MakeSth(prefab, skin)
        if not p_util:GetItemFromAll(prefab) then return true end
    end, time_wait, time_out)
end

-- Modrpc adaptation
function d_util:QueryShowme(target, time_wait, time_out)
    time_wait = time_wait or FRAMES
    time_out = time_out or 1
    local data
    self:TaskLoop(function()
        data = m_util:QueryShowme(target)
        return not data
    end, time_wait, time_out)
    return data
end

-- Remote click (recommended with p_util:GetMouseActionClick)
-- data = {act, target, (right)}
function d_util:RemoteClick(data)
    local inst = data.target
    local dist = e_util:GetDist(inst)
    if not m_util:GetMovementPrediction() and dist and dist > self.dist_click then
        local dirx, diry = c_util:GetUnitDirection(ThePlayer:GetPosition(), inst:GetPosition())
        SendRPCToServer(RPC.DirectWalking, dirx, diry)
        local pusher = m_util:GetPusher()
        if pusher then
            pusher:RegNowTask(function()
                local dist = e_util:GetDist(inst)
                if dist then
                    if dist < self.dist_click then
                        p_util:StopWalking()
                        p_util:DoMouseAction(data.act, data.right)
                        return true
                    end
                else
                    return true
                end
                self:Wait()
            end)
        end
    else
        p_util:DoMouseAction(data.act, data.right)
    end
end

-- Open the box
function d_util:OpenContainer(cont, timewait)
    while not p_util:IsOpenContainer(cont) do
        local act, right = p_util:GetMouseActionSoft({"RUMMAGE"}, cont)
        if act then
            p_util:DoMouseAction(act, right)
        end
        self:Wait(timewait)
    end
end

return d_util