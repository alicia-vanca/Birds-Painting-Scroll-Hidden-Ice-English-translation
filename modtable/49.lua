local save_id, string_db = "sw_double", "Double-Click"
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

AddClassPostConstruct("components/inventory_replica", HookContainer)
AddClassPostConstruct("components/container_replica", HookContainer)
local _TradeItem = require("widgets/invslot").TradeItem
if _TradeItem then
    local _FindBestContainer, up = c_util:GetFnValue(_TradeItem, "FindBestContainer")
    if not up then return end
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
            _FindBestContainer(self, item, conts, ...)
    end)
end


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

    local function TradeItem(half)
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
                local function BP(c) 
                    return c == ThePlayer or c:HasTag("backpack")
                end
                local function func_from(data)
                    return data.cont == cont and data
                end
                local function func_bp(data)
                    return BP(data.cont) and data
                end
                local a, b = BP(cont), BP(last_cont)
                
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
    end


    local _OnControl = self.OnControl
    if not self.OnControl then return end
    self.OnControl = function(self, ctrl, down, ...)
        if down then
            local onlyread = self.container.IsReadOnlyContainer and self.container:IsReadOnlyContainer()
            if not onlyread then
                if ctrl == CONTROL_ACCEPT and not TheInput:IsControlPressed(CONTROL_FORCE_INSPECT) and TheInput:IsControlPressed(CONTROL_FORCE_TRADE) then
                    TradeItem(TheInput:IsControlPressed(CONTROL_FORCE_STACK))
                elseif ctrl == CONTROL_SECONDARY then
                elseif ctrl == CONTROL_SPLITSTACK then
                elseif ctrl == CONTROL_TRADEITEM then
                    TradeItem(false)
                elseif ctrl == CONTROL_TRADESTACK then
                    TradeItem(true)
                end
            end
        end
        return _OnControl(self, ctrl, down, ...)
    end

end)

local screen_data = {{
    id = "bundle",
    label = "Prefer BundleWrap",
    fn = fn_save("bundle"),
    hover = "When both Chest and BundleWrap are open, move items to BundleWrap first",
    default = fn_get
}, {
    id = "cookpot",
    label = "Prefer Crockpot",
    fn = fn_save("cookpot"),
    hover = "When IceBox and Crockpot are both open, move items to the Crockpot first",
    default = fn_get
}, {
    id = "drop",
    label = "Fast drop",
    fn = fn_save("drop"),
    hover = "Drop repeatedly when you double-click-drop",
    default = fn_get
}, {
    id = "trade",
    label = "Fast transfer",
    fn = fn_save("trade"),
    hover = "Transfer repeatedly when you Shift + double-click-transfer",
    default = fn_get
}, {
    id = "trade_cookpot",
    label = "Quick Crockpot fill",
    fn = fn_save("trade_cookpot"),
    hover = "[Fast transfer] additional function\nAllow fast transfer to fill the Crockpot",
    default = fn_get
}, {
    id = "trade_mode",
    label = "Mode:",
    fn = fn_save("trade_mode"),
    hover = "Choose the fast transfer mode\nHigh-speed mode is unstable; low-speed mode is slower but stable",
    default = fn_get,
    type = "radio",
    data = {{
        data = 1,
        description = "High-speed"
    }, {
        data = 2,
        description = "Low-speed"
    }}
}, {
    id = "time_min",
    label = "Interval:",
    fn = fn_save("time_min"),
    hover = "The timing window for double-click detection",
    default = fn_get,
    type = "radio",
    data = t_util:BuildNumInsert(0.1, 1, 0.1, function(i)
        return {
            data = i,
            description = i .. " sec"
        }
    end)
}}

local function fn_checkdata()
    if m_util:HasModName("简易存储") then
        i_util:DoTaskInTime(.1, function()
            h_util:CreatePopupWithClose("Notice", "Priority settings are currently overridden by the server mod Simple Storage, so these settings are temporarily disabled.")
        end)
    end
    return screen_data
end


m_util:AddBindShowScreen(save_id, string_db, "treasurechest_poshprint", STRINGS.LMB .. 'Advanced settings', {
    title = string_db,
    id = save_id,
    data = fn_checkdata,
    
            icon = 
    {{
        id = "add",
        prefab = "mods",
        hover = "Treat as same type",
        fn = function()
            h_util:CreatePopupWithClose(nil, "No custom feature has been added yet. Stay tuned.")
        end,
    }},
})
