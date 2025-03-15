local save_id, map_str = "map_gogo", "Auto walking"
local default_data = {
    tele = m_util:IsHuxi(),
    sw = true,
    double = false,
    double_time = 3,
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local pos_old

local ui_data = {{
    id = "readme",
    label = "Instruction",
    fn = function()
        h_util:CreatePopupWithClose("Automatic way to find ways · use instructions",
            "When the Right-click is right, the Right-click the way to find the road will not take effect, \n, you can change other keys or open the following [Double-click replacement].", {{
                text = h_util.ok
            }})
    end,
    hover = "Click to view the tutorial",
    default = true
}, {
    id = "tele",
    label = "One-click transmission",
    fn = fn_save("tele"),
    hover = "In God mode, map pathfinding is directly transmitted\nOnly when the cave closing, delay compensation is turned on!",
    default = fn_get
}, {
    id = "double",
    label = "Double-click replacement",
    fn = fn_save("double"),
    hover = "Should we change the original right click action on the map to double click, so that Wotox can right click to find the way. \n Note: Throwing a boot will also become a double click",
    default = fn_get,
}, {
    id = "double_time",
    label = "Double-click interval:",
    fn = fn_save("double_time"),
    hover = "[Double-click replacement addition setting] The time interval for double-clicking the right button",
    default = fn_get,
    type = "radio",
    data = t_util:BuildNumInsert(1, 10, 1, function(t)
        return {data = t, description = t*0.1 .. " second"}
    end),
}}

i_util:AddSessionLoadFunc(function(saver, world, player, pusher)
    saver:RegHMap(save_id, map_str, "Whether to display " .. map_str .. " Icon", function()
        return save_data.sw
    end, fn_save("sw"), {
        screen_data = ui_data,
        nothud = true,
    })
end)

-- Set icon
local function SetIcon(pos)
    local saver = m_util:GetSaver()
    if not (pos and pos.x and pos.z and saver) then
        return
    end
    local info = {
        x = pos.x,
        z = pos.z,
        icon = "mark_x",
    }
    if pos_old then
        saver:ChanHMap(save_id, {
            x = pos_old.x,
            z = pos_old.z,
            icon = "mark_x",
        }, info)
    else
        saver:AddHMap(save_id, info, true)
    end
    pos_old = pos
end

local function GoTo(pos_target, pc)
    -- Stop the current task
    local pusher = m_util:GetPusher()
    if not pusher then return end
    pusher:StopNowTask()

    local pos_init = ThePlayer:GetPosition()
    -- Transfer mode
    if save_data.tele and not p_util:IsDead() and not pc.locomotor then
        local fnstr =
            "local h = ThePlayer and ThePlayer.Transform and ThePlayer.components.health if h and h:IsInvincible() then ThePlayer.Transform:SetPosition(" ..
                pos_target.x .. ", 0, " .. pos_target.z .. ") end"
        i_util:ExRemote(fnstr)
    end
    -- Way of searching
    if pc.locomotor then
        p_util:WalkTo(pos_target)
    else
        local dirx, diry = c_util:GetUnitDirection(pos_init, pos_target)
        SendRPCToServer(RPC.DirectWalking, dirx, diry)
    end
    -- Set icon
    SetIcon(pos_target)
    -- Stop at destination
    local dist_max = c_util:GetDist(pos_init.x, pos_init.z, pos_target.x, pos_target.z)
    pusher:RegNowTask(function(player, pc)
        d_util:Wait()
        local pos = player:GetPosition()
        return c_util:GetDist(pos.x, pos.z, pos_init.x, pos_init.z) >= dist_max
    end, function(player)
        p_util:StopWalking() 
    end)
end
local time_click = 0
AddClassPostConstruct("screens/mapscreen", function(self)
    -- There is a problem with the global positioning writing, you can only use oncontrol here
    local _OnControl = self.OnControl
    self.OnControl = function(self, ctrl, down, ...)
        if down and ctrl == CONTROL_SECONDARY then
            local pc = ThePlayer and ThePlayer.components.playercontroller
            if not pc then
                return _OnControl(self, ctrl, down, ...)
            end

            local pos_target = Vector3(self:GetWorldPositionAtCursor())
            local lmb, rmb = pc:GetMapActions(pos_target)
            if rmb then
                local now = GetTime()
                local isdouble = now - time_click < save_data.double_time * 0.1
                time_click = now
                -- Open the replacement and execute the way
                if save_data.double then
                    -- BLINK_MAP
                    if isdouble then
                        -- There are action, replacement, no way to find, execute the original version
                        p_util:StopWalking()
                    else
                        -- There are action, replacement, finding the way, not performing the original version
                        return GoTo(pos_target, pc)
                    end
                else
                    -- There are movements, not replacement, do not find ways, execute the original version
                end
            else
                -- Right-click without action
                GoTo(pos_target, pc)
            end
        end
        return _OnControl(self, ctrl, down, ...)
    end
end)
