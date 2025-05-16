local save_id, string_db = "sw_double", "Double-click"
local default_data = {
    time_min = 0.3,
    drop = true,
    trade = true,
    trade_mode = 1,
    bundle = true,
    cookpot = true,
    trade_cookpot = false,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local last_time = 0
local last_cont, last_prefab

local function HookContainer(self)
    local _MoveItemFromAllOfSlot = self.MoveItemFromAllOfSlot
    self.MoveItemFromAllOfSlot = function(self, slot, cont, ...)
        last_cont = cont
        return _MoveItemFromAllOfSlot(self, slot, cont, ...)
    end
end
local function FindBestContainer(self, item, containers, exclude_containers)
    if item == nil or containers == nil then
        return
    end

    --Construction containers
    --NOTE: reusing containerwithsameitem variable
    local containerwithsameitem = self.owner ~= nil and self.owner.components.constructionbuilderuidata ~= nil and self.owner.components.constructionbuilderuidata:GetContainer() or nil
    if containerwithsameitem ~= nil then
        if containers[containerwithsameitem] ~= nil and (exclude_containers == nil or not exclude_containers[containerwithsameitem]) then
            local slot = self.owner.components.constructionbuilderuidata:GetSlotForIngredient(item.prefab)
            if slot ~= nil then
                local container = containerwithsameitem.replica.container
                if container ~= nil and container:CanTakeItemInSlot(item, slot) then
                    local existingitem = container:GetItemInSlot(slot)
                    if existingitem == nil or (container:AcceptsStacks() and existingitem.replica.stackable ~= nil and not existingitem.replica.stackable:IsFull()) then
                        return containerwithsameitem
                    end
                end
            end
        end
        containerwithsameitem = nil
    end

    --local containerwithsameitem = nil --reused with construction containers code above
    local containerwithemptyslot = nil
    local containerwithnonstackableslot = nil
    local containerwithlowpirority = nil

    for k, v in pairs(containers) do
        if exclude_containers == nil or not exclude_containers[k] then
            local container = k.replica.container or k.replica.inventory
            if container ~= nil and container:CanTakeItemInSlot(item) then
                local isfull = container:IsFull()
                if container:AcceptsStacks() then
                    if not isfull and containerwithemptyslot == nil then
                        if container.lowpriorityselection then
                            containerwithlowpirority = k
                        else
                            containerwithemptyslot = k
                        end
                    end
                    if item.replica.equippable ~= nil and container == k.replica.inventory then
                        local equip = container:GetEquippedItem(item.replica.equippable:EquipSlot())
                        if equip ~= nil and equip.prefab == item.prefab and equip.skinname == item.skinname then
                            if equip.replica.stackable ~= nil and not equip.replica.stackable:IsFull() then
                                return k
                            elseif not isfull and containerwithsameitem == nil then
                                containerwithsameitem = k
                            end
                        end
                    end
                    for k1, v1 in pairs(container:GetItems()) do
                        if v1.prefab == item.prefab and v1.skinname == item.skinname then
                            if v1.replica.stackable ~= nil and not v1.replica.stackable:IsFull() then
                                if container.lowpriorityselection then
                                    containerwithlowpirority = k
                                else
                                    return k
                                end
                            elseif not isfull and containerwithsameitem == nil then
                                containerwithsameitem = k
                            end
                        end
                    end
                elseif not isfull and containerwithnonstackableslot == nil then
                    containerwithnonstackableslot = k
                end
            end
        end
    end

    return containerwithsameitem or containerwithemptyslot or containerwithnonstackableslot or containerwithlowpirority
end

AddClassPostConstruct("components/inventory_replica", HookContainer)
AddClassPostConstruct("components/container_replica", HookContainer)
AddClassPostConstruct("widgets/invslot", function(self)
    local _DropItem = self.DropItem
    self.DropItem = function(self, single)
        local now = GetTime()
        if save_data.drop and now - last_time < save_data.time_min then
            local pusher = ThePlayer and ThePlayer.components.hx_pusher
            local item = self.tile and self.tile.item
            local prefab = item and item.prefab
            if pusher and prefab then
                pusher:RegNowTask(function(player, pc)
                    Sleep(FRAMES)
                    item = (single and e_util:IsValid(item) and item:HasTag("inlimbo") and item) or
                               p_util:GetItemFromAll(prefab, nil, nil, {"body", "backpack", "container"})
                    if item then
                        p_util:DropItemFromInvTile(item, single)
                    else
                        return true
                    end
                end)
            end
        end
        last_time = now
        return _DropItem(self, single)
    end

    local _TradeItem = self.TradeItem
    if _TradeItem and not self._hx_lock then
        local _FindBestContainer, up = c_util:GetFnValue(_TradeItem, "FindBestContainer")
        if up then
            self._hx_lock = true
            debug.setupvalue(_TradeItem, up, function(self, item, conts, ...)
                local data = p_util:GetSlotFromAll(item and item.prefab, nil, function(ent)
                    return ent == item
                end, {"body", "backpack", "container"})
                local cont_source = data and data.cont
                local function GetContHasTag(tag)
                    return t_util:GetElement(conts or {}, function(cont, _)
                        return _ and cont and cont ~= cont_source and cont:HasTag(tag) and
                                   e_util:CanPutInItem(cont, item) and cont
                    end)
                end
                return
                    (save_data.bundle and GetContHasTag("bundle")) or (save_data.cookpot and GetContHasTag("stewer")) or
                    FindBestContainer(self, item, conts, ...)
            end)

            self.TradeItem = function(self, half, ...)
                local now = GetTime()
                local item = self.tile and self.tile.item
                local prefab = item and item.prefab
                last_prefab = prefab or last_prefab
                if save_data.trade and now - last_time < save_data.time_min and not half then
                    local pusher = ThePlayer and ThePlayer.components.hx_pusher
                    local container = self.container
                    local cont = container and container.inst
                    if pusher and last_prefab and e_util:GetContainer(last_cont) and cont and cont ~= last_cont 
                    and (save_data.trade_cookpot or not last_cont:HasTag("stewer"))
                    then
                        local function BP(c) -- Belong To Player
                            return c == ThePlayer or c:HasTag("backpack")
                        end
                        local function func_from(data)
                            return data.cont == cont and data
                        end
                        local function func_bp(data)
                            return BP(data.cont) and data
                        end
                        local a, b = BP(cont), BP(last_cont)
                        -- On your body or backpack, send it to your body or backpack.
                        func_from = (a and not b) and func_bp or func_from
                        local _last_cont = last_cont
                        pusher:RegNowTask(function(player, pc)
                            Sleep(0)
                            local slots_data = p_util:GetSlotsFromAll(last_prefab, nil, nil,
                                {"body", "backpack", "container"}) or {}
                            local function MoveData(dest_inst, data)
                                if dest_inst then
                                    p_util:MoveItemFromAllOfSlot(data.slot, data.cont, dest_inst)
                                else
                                    return true
                                end
                            end
                            if save_data.trade_mode == 1 then
                                -- High -speed mode: no brain placing, anyway, no error can be reported anyway
                                local datas = t_util:IPairFilter(slots_data, func_from)
                                local _item = datas[1] and datas[1].item
                                if not _item then return true end
                                if not a and b then
                                    local backpack = p_util:GetBackpack()
                                    if e_util:CanPutInItem(ThePlayer, _item) or e_util:CanPutInItem(backpack, _item) then
                                        return t_util:IGetElement(datas, function(data)
                                            return MoveData(ThePlayer, data)
                                        end) or t_util:IGetElement(datas, function(data)
                                            return MoveData(backpack, data)
                                        end)
                                    else
                                        return true
                                    end
                                else
                                    if e_util:CanPutInItem(_last_cont, _item) then
                                        return t_util:IGetElement(datas, function(data)
                                            return MoveData(_last_cont, data)
                                        end)
                                    else
                                        return true
                                    end
                                end
                            else
                                -- Low -speed mode: judge one by one one by one
                                local data = t_util:IGetElement(slots_data, func_from)
                                local dest_inst
                                if data then
                                    if not a and b then
                                        local backpack = p_util:GetBackpack()
                                        dest_inst = (e_util:CanPutInItem(ThePlayer, data.item) and ThePlayer) or
                                                        (e_util:CanPutInItem(backpack, data.item) and backpack)
                                    else
                                        dest_inst = e_util:CanPutInItem(_last_cont, data.item) and _last_cont
                                    end
                                end
                                return MoveData(dest_inst, data)
                            end
                        end, nil, "null")
                    end
                end
                last_time = now
                return _TradeItem(self, half, ...)
            end
        end
    end
end)

local screen_data = {{
    id = "bundle",
    label = "Prefer Bundle Wrap",
    fn = fn_save("bundle"),
    hover = "When open the container and bundle wrap at the same time,\ntransfer items to the bundle wrap first",
    default = fn_get
}, {
    id = "cookpot",
    label = "Prefer Crock Pot",
    fn = fn_save("cookpot"),
    hover = "When open the refrigerator and crock pot at the same time,\ntransfer items to the crock pot first",
    default = fn_get
}, {
    id = "drop",
    label = "Quick discard",
    fn = fn_save("drop"),
    hover = "If you double click to discard an item, the discard will repeat with all same items",
    default = fn_get
}, {
    id = "trade",
    label = "Quick transfer",
    fn = fn_save("trade"),
    hover = "If you double click to transfer an item, the transfer will repeat with all same items",
    default = fn_get
}, {
    id = "trade_cookpot",
    label = "Quick pot filling",
    fn = fn_save("trade_cookpot"),
    hover = "[Quick transfer] additional setting\n Whether to allow quick transfer to fill the crock pot",
    default = fn_get
}, {
    id = "trade_mode",
    label = "Trans speed:",
    fn = fn_save("trade_mode"),
    hover = "Transfer speed: High speed mode is unstable, low speed mode is slower but stable",
    default = fn_get,
    type = "radio",
    data = {{
        data = 1,
        description = "Fast"
    }, {
        data = 2,
        description = "Slow"
    }}
}, {
    id = "time_min",
    label = "Doubleclick:",
    fn = fn_save("time_min"),
    hover = "Double-click judgment time",
    default = fn_get,
    type = "radio",
    data = t_util:BuildNumInsert(0.1, 1, 0.1, function(i)
        return {
            data = i,
            description = i .. " sec"
        }
    end)
}}
m_util:AddBindShowScreen(save_id, string_db, "treasurechest_poshprint", STRINGS.LMB .. "Advanced settings", {
    title = string_db,
    id = save_id,
    data = screen_data
})
