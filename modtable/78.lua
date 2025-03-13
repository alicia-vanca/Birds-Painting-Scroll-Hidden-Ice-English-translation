local save_id, str_push = "sw_autopush", "Auto push"
local default_data = {
    sw = true
}
local save_data, fn_get, fn_save = s_mana:InitLoad(save_id, default_data)
local string_ori

-- Load string into file
i_util:AddSessionLoadFunc(function()
    string_ori = t_util:GetRecur(STRINGS, "ACTIONS.LOOKAT.GENERIC") or string_ori
end)
-- Conditions that can be pushed
local function CanPush(player, item_world)
    if player and item_world and save_data.sw and item_world ~= player then
        if item_world:HasOneOfTags({"wall", "structure"}) then
            return
        end
        local rep = item_world.replica
        if rep then
            if rep.health and rep.combat then
                return player.components.playercontroller
            end
        end
    end
end
-- Change right click display
i_util:AddHoverOverFunc(function(str, player, item_inv, item_world)
    local pc = CanPush(player, item_world)
    if not pc then
        return
    end
    local ract = pc:GetRightMouseAction()
    local press = TheInput:IsKeyDown(KEY_SHIFT)
    if ract then
        if ract.action == ACTIONS.LOOKAT then
            if t_util:GetRecur(STRINGS, "ACTIONS.LOOKAT.GENERIC") then
                STRINGS.ACTIONS.LOOKAT.GENERIC = press and str_push or string_ori
            end
            return nil, function()
                if t_util:GetRecur(STRINGS, "ACTIONS.LOOKAT.GENERIC") then
                    STRINGS.ACTIONS.LOOKAT.GENERIC = string_ori
                end
            end
        end
    elseif press then
        return str .. "\n" .. h_util:GetStringKeyBoardMouse(MOUSEBUTTON_RIGHT) .. str_push
    end
end)

-- Change right click
local mv
i_util:AddRightClickFunc(function(pc, player, down, act_right, ent_mouse)
    if not down and CanPush(player, ent_mouse) then
        if not act_right or act_right.action == ACTIONS.LOOKAT then
            local press = TheInput:IsKeyDown(KEY_SHIFT)
            local pusher = press and m_util:GetPusher()
            if pusher then
                -- It is recommended to turn off the delay when pushing automatically. The efficiency of pushing with delay is slow. Here it is automatically turned off.
                mv = m_util:GetMovementPrediction()
                if mv then
                    m_util:SetMovementPrediction(false)
                end
                u_util:Say(str_push, ent_mouse.name or ent_mouse.prefab, nil, nil, true)
                pusher:RegNowTask(function(player, pc)
                    if e_util:IsValid(ent_mouse) then
                        p_util:WalkTo(ent_mouse:GetPosition(), true)
                    else
                        return true
                    end
                    Sleep(3 * FRAMES)
                end, function(player)
                    if mv then
                        m_util:SetMovementPrediction(mv)
                    end
                    -- u_util:Say(str_push, "End", nil, nil, true)
                end)
            end
        end
    end
end)

-- Register to menu
m_util:AddRightMouseData(save_id, str_push, "Enabled?" .. str_push, function()
    return save_data.sw
end, fn_save("sw"), {
    screen_data = {{
        id = "readme",
        label = "Usage Guidelines",
        fn = function()
            h_util:CreatePopupWithClose(str_push .. " · Usage Guidelines",
                "Thanks to the player 虾仁平安 for the customization!\nThis function is used to push creatures. Just hold down SHIFT + right click.",
                {{
                    text = h_util.ok
                }})
        end,
        hover = "Click to view tutorial",
        default = true
    }}
})
