_G.MOD_SRM_LOCK = false
AddGlobalClassPostConstruct("entityscript", "EntityScript", function(self)
    local _RegisterComponentActions = self.RegisterComponentActions
    self.RegisterComponentActions = function(...)
        return _G.MOD_SRM_LOCK or _RegisterComponentActions(...)
    end

    local _UnregisterComponentActions = self.UnregisterComponentActions
    self.UnregisterComponentActions = function(...)
        return _G.MOD_SRM_LOCK or _UnregisterComponentActions(...)
    end
end)

AddPrefabPostInit("world", function(world)
    t_util:IPairs(i_util.world_func_in, function(func)
        func(world)
    end)
    local saver
    world:ListenForEvent("playeractivated", function(world, player)
        if player ~= ThePlayer then
            return
        end
        local pusher = player:AddComponent("hx_pusher")
        if not saver then
            saver = world:AddComponent("hx_saver")
            t_util:IPairs(i_util.data_func_load, function(func)
                func(saver, world, player, pusher)
            end)
        end
        t_util:IPairs(i_util.player_func_in, function(func)
            func(player, world, pusher, saver)
        end)
        if not world.ismastersim then
            return
        end
        local ltor = player and player.components.locomotor
        if ltor then
            local _PushAction = ltor.PushAction
            Mod_ShroomMilk.Func.PushAction = function(...)
                _PushAction(ltor, ...)
            end
            ltor.PushAction = function(ltor, ...)
                for _, func in ipairs(i_util.ltor_push_func) do
                    if func(...) then
                        return
                    end
                end
                return _PushAction(ltor, ...)
            end
        end
    end)
    world:ListenForEvent("playerdeactivated", function(world, player)
        if player == ThePlayer then
            i_util.server_rpc_func = {}
            i_util.ltor_push_func = {}
            t_util:IPairs(i_util.player_func_out, function(func)
                func(player, world)
            end)
        end
    end)
end)
-- It can be done by practical pusher, but it seems professional with this
-- It can be done by practical hud, there are too many methods
AddComponentPostInit("playercontroller", function(self, player)
    if player ~= ThePlayer then
        return
    end
    local _OnRightClick = self.OnRightClick
    self.OnRightClick = function(self, down, ...)
        if self:UsingMouse() and not self.placer_recipe and not self.placer and not self:IsAOETargeting() and
            self:IsEnabled() then
            local act_right = self:GetRightMouseAction()
            local ent_mouse = TheInput:GetWorldEntityUnderMouse()
            if t_util:IGetElement(i_util.rightclick_func, function(func)
                return func(self, player, down, act_right, ent_mouse)
            end) then
                return
            end
        end
        return _OnRightClick(self, down, ...)
    end

    local _OnLeftClick = self.OnLeftClick
    self.OnLeftClick = function(self, down, ...)
        if self:UsingMouse() and self:IsEnabled() and not TheInput:GetHUDEntityUnderMouse() and
            not (self.placer_recipe and self.placer) and not self:IsAOETargeting() then
            local act_left = self:GetLeftMouseAction()
            local ent_mouse = TheInput:GetWorldEntityUnderMouse()
            t_util:IPairs(i_util.leftclick_func, function(func)
                func(self, player, down, act_left, ent_mouse)
            end)
        end
        return _OnLeftClick(self, down, ...)
    end
end)

AddClassPostConstruct("widgets/hoverer", function(self, player)
    if not self.text then
        return
    end
    local _SetString = self.text.SetString
    local _Hide = self.text.Hide
    local hoverer_func_out = {}

    self.text.SetString = function(Text, str, ...)
        t_util:IPairs(i_util.hoverer_func_in, function(func)
            if not str then
                return
            end
            local item_inv = t_util:GetRecur(TheInput:GetHUDEntityUnderMouse() or {}, "widget.parent.item")
            local item_world = TheInput:GetWorldEntityUnderMouse()
            local ret_str, ret_func = func(str, player, item_inv, item_world)
            if ret_func and not hoverer_func_out[str] then
                hoverer_func_out[str] = ret_func
            end
            str = ret_str or str
        end)
        return _SetString(Text, str, ...)
    end

    self.text.Hide = function(...)
        t_util:Pairs(hoverer_func_out, function(id, func)
            if type(func) == "function" then
                func()
            end
            hoverer_func_out[id] = nil
        end)
        return _Hide(...)
    end
end)

local _SendRPCToServer = _G.SendRPCToServer
Mod_ShroomMilk.Func.SendRPCToServer = _SendRPCToServer
_G.SendRPCToServer = function(...)
    for _, func in ipairs(i_util.server_rpc_func) do
        if func(...) then
            return
        end
    end
    return _SendRPCToServer(...)
end

AddClassPostConstruct("screens/playerhud", function(self)
    local _OnMouseButton = self.OnMouseButton
    self.OnMouseButton = function(self, button, down, x, y, ...)
        if button == MOUSEBUTTON_MIDDLE and down and not TheInput:GetWorldEntityUnderMouse() and
            not TheInput:GetHUDEntityUnderMouse() then
            t_util:IPairs(i_util.midclick_func, function(func)
                func(self, x, y)
            end)
        end
        return _OnMouseButton(self, button, down, x, y, ...)
    end
end)

local function LeaveTheWorld()
    local world = TheWorld
    local saver = t_util:GetRecur(TheWorld, "components.hx_saver")
    if saver then
        saver:Leave()
    end
end

local _DoRestart = _G.DoRestart
function _G.DoRestart(...)
    LeaveTheWorld()
    return _DoRestart(...)
end
local _MigrateToServer = _G.MigrateToServer
function _G.MigrateToServer(ip, port, ...)
    LeaveTheWorld()
    return _MigrateToServer(ip, port, ...)
end

-- Advanced monitoring, listening to left-click actions on the player themselves and right-click actions on items
local function fn_actcode(code, item)
    if not code then
        return
    end
    local fns_pre = i_util.listencode_pre[code]
    local fns_end = i_util.listencode_end[code]
    if not fns_pre and not fns_end then
        return
    end
    local prefab = type(item) == "table" and item.prefab
    if not prefab then
        return
    end
    if fns_pre then
        t_util:IPairs(fns_pre, function(fn_pre)
            fn_pre(prefab, item)
        end)
    end
    if not fns_end then
        return
    end
    local size = e_util:GetStackSize(item)
    -- Check if the quantity has decreased within 2 seconds
    -- TODO: Check for infinite capacity
    e_util:WaitToDo(nil, 0.1, 20, function()
        if e_util:IsValid(item) then
            return size > e_util:GetStackSize(item)
        else
            return true
        end
    end, function()
        t_util:IPairs(fns_end, function(fn_end)
            fn_end(prefab, item)
        end)
    end)
end
i_util:AddPlayerActivatedFunc(function()
    i_util:AddServerRPCFunc(function(rpc, ...)
        local args = {...}
        if rpc == RPC.LeftClick then
            fn_actcode(args[1], p_util:GetActiveItem())
        elseif rpc == RPC.UseItemFromInvTile or rpc == RPC.ControllerUseItemOnSelfFromInvTile then
            fn_actcode(args[1], args[2])
        end
    end)
    i_util:AddPushActionFunc(function(act)
        fn_actcode(act and act.action and act.action.code, act and act.invobject)
    end)
end)
